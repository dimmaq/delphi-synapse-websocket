unit uWorkThreadWebSocket;

interface

uses
  SysUtils, DateUtils, Classes,
  //
  blcksock,
  //
  uCookieManager, uWorkThreadSynaBase, synaws, uConnectParamInterface,
  uLoggerInterface,
  uWebSocketUpgrade, uWebSocketConst;

type
  TWorkThreadWebSocket = class(TWorkThreadSynaBase)
  private
    FPingTime: TDateTime;
    FAutoPing: Integer; // seconds, < 1 - disable
    FAutoPong: Boolean;
    FPongWait: Integer; // seconds, < 1 - disable
    FIsPongRecv: Boolean;
    FIsClosing: Boolean;
    FConn: TSynaws;
    FSocket: TTCPBlockSocket;
    //
    FOnConnectedEvent: TNotifyEvent;
    //
    procedure ProcessCloseFrame(const AData: RawByteString);
    procedure ProcessRecvData(const ACode: TWsOpcode; const AData: RawByteString);
    procedure DoHeartbeat;
    //
    function GetCookieManager: ICookieManager;
    procedure SetCookieManager(const Value: ICookieManager);
    function GetConnectParam: IConnectParam;
    procedure SetConnectParam(const Value: IConnectParam);
    function GetUrl: AnsiString;
    procedure SetUrl(const Value: AnsiString);
  protected
    procedure OnConnect; virtual;
    procedure OnSendPing(const AData: RawByteString; const ACode: TWsOpcode); virtual;
    procedure OnRecvPing(const AData: RawByteString); virtual;
    procedure OnRecvPong(const AData: RawByteString); virtual;
    procedure OnRecvClose(const ACloseCode: TWsCloseCode; const AReason: UTF8String); virtual;
    procedure OnRecvBinary(const ABin: RawByteString); virtual;
    procedure OnRecvText(const AText: UTF8String); virtual;

    procedure SetLogger; override;
    procedure Execute; override;
    procedure TerminatedSet; override;
  public
    constructor Create(const AUrl: AnsiString; const AConnectParam: IConnectParam;
      const ALog: ILoggerInterface);
    destructor Destroy; override;

    procedure SendClose(const ACode: TWsCloseCode = wsCloseNormal;
      const AReason: UTF8String = '');
    function Send(const S: RawByteString; I: TWsOpcode): Boolean;
    function SendText(const S: string): Boolean; overload;
    procedure SendPing;
    //
    property OnConnectedEvent: TNotifyEvent read FOnConnectedEvent write FOnConnectedEvent;
    //
    property ConnectParam: IConnectParam read GetConnectParam write SetConnectParam;
    property Cookies: ICookieManager read GetCookieManager write SetCookieManager;
    property Url: AnsiString read GetUrl write SetUrl;
    property AutoPing: Integer read FAutoPing write FAutoPing;
    property AutoPong: Boolean read FAutoPong write FAutoPong;

  end;

implementation

const
  PING_INTERVAL_DEFAULT = 60;
  PONG_WAIT_DEFAULT = 10; // 1 minute

{ TWorkThreadWebSocket }

constructor TWorkThreadWebSocket.Create(const AUrl: AnsiString;
    const AConnectParam: IConnectParam;
      const ALog: ILoggerInterface);
begin
  Inherited Create(AConnectParam);

  DumpResponce := False;


  FAutoPing := PING_INTERVAL_DEFAULT;
  FAutoPong := True;
  FPingTime := Now();
  FPongWait := PONG_WAIT_DEFAULT;
  FIsPongRecv := True;


  FConn := TSynaws.Create(AConnectParam);
  FConn.Url := AUrl;

  FSocket := FConn.Socket;
  FSocket.OnMonitor := HookMonitor;
  FSocket.OnStatus := HookSocketStatus;

  FLogger := ALog;
end;

destructor TWorkThreadWebSocket.Destroy;
begin
  FConn.Free;
  inherited;
end;

procedure TWorkThreadWebSocket.Execute;
var
  ldata: AnsiString;
  lcode: TWsOpcode;
begin
  try
    if not FConn.Connect('') then
    begin
      LogError('connect fail %d %s', [FSocket.LastError, FSocket.LastErrorDesc]);
      Exit;
    end;
    LogDebug('conected, wait data');
    OnConnect();
    while not Aborted do
    begin
      DoHeartbeat();
      if Aborted then
        Exit;
      if FConn.WaitData(ConnectParam.RecvTimeout) then
      begin
        if Aborted then
          Exit;
        while FConn.Recv(ldata, lcode) and (not Aborted) do
        begin
          LogDebug('< %d %s', [lcode, ldata]);
          ProcessRecvData(lcode, ldata);
          if Aborted then
            Exit;
        end;
      end;
      if FSocket.LastError <> 0 then
      begin
        LogError('recv fail %d "%s"', [FSocket.LastError, FSocket.LastErrorDesc]);
        Exit;
      end;
    end;
  except
    on E: Exception do
    begin
      LogError(E, 'fatal error ');
      raise
    end;
  end;
end;

function TWorkThreadWebSocket.GetConnectParam: IConnectParam;
begin
  Result := FConn.ConnectParam
end;

function TWorkThreadWebSocket.GetCookieManager: ICookieManager;
begin
  Result := FConn.Cookies
end;

function TWorkThreadWebSocket.GetUrl: AnsiString;
begin
  Result := FConn.Url
end;

procedure TWorkThreadWebSocket.OnConnect;
begin
  LogDebug('onConnect event');
  if Assigned(FOnConnectedEvent) then
  begin
    FOnConnectedEvent(Self)
  end;
end;

procedure TWorkThreadWebSocket.OnRecvBinary(const ABin: RawByteString);
begin
  LogDebug('recv binary frame %d', [Length(ABin)]);
end;

procedure TWorkThreadWebSocket.OnRecvClose(const ACloseCode: TWsCloseCode;
  const AReason: UTF8String);
begin
  LogDebug('recv close frame %d "%s"', [ACloseCode, AReason]);
  if not FIsClosing then
  begin
    SendClose(ACloseCode);
  end;
  Terminate;
end;

procedure TWorkThreadWebSocket.OnRecvText(const AText: UTF8String);
begin
  LogDebug('recv text frame %s', [AText]);
end;

procedure TWorkThreadWebSocket.ProcessCloseFrame(const AData: RawByteString);
var
  z: RawByteString;
  code: UInt16;
  reason: UTF8String;
begin
  if Length(AData) < 2 then
  begin
    code := wsCloseNormal;
    reason := '';
  end
  else
  begin
    code := Swap(UInt16(AData[1]));
    z := Copy(AData, 3, MaxInt);
    SetCodePage(z, CP_UTF8, False);
    reason := UTF8String(z);
  end;
  OnRecvClose(code, reason);
end;

procedure TWorkThreadWebSocket.ProcessRecvData(const ACode: TWsOpcode;
  const AData: RawByteString);

  function AsUtf8(S: RawByteString): UTF8String;
  begin
    SetCodePage(S, CP_UTF8, False);
    Result := UTF8String(S);
  end;
  function AsBin(const S: RawByteString): RawByteString;
  begin
    Result := S;
    SetCodePage(Result, $FFFF, False);
  end;


begin
  case ACode of
    wsCodeText:   OnRecvText(AsUtf8(AData));
    wsCodeBinary: OnRecvBinary(AsBin(AData));
    wsCodeClose:  ProcessCloseFrame(AData);
    wsCodePing:   OnRecvPing(AData);
    wsCodePong:   OnRecvPong(AData);
    else
      LogError('recv unknow opcode ' + IntToStr(ACode));
  end;
end;

procedure TWorkThreadWebSocket.OnRecvPing(const AData: RawByteString);
begin
  LogDebug('recv ping');
  if FAutoPong then
    Send(AData, wsCodePong)
end;

procedure TWorkThreadWebSocket.OnRecvPong(const AData: RawByteString);
begin
  FIsPongRecv := True;
  LogDebug('recv pong');
end;

procedure TWorkThreadWebSocket.OnSendPing(const AData: RawByteString;
  const ACode: TWsOpcode);
begin
  FIsPongRecv := False;
  LogDebug('send ping');
  Send(AData, ACode);
end;

procedure TWorkThreadWebSocket.DoHeartbeat;
var
  k: Integer;
begin
  if FAutoPing <= WS_PING_DISABLE then
    Exit;
  //
  k := SecondsBetween(Now(), FPingTime);
  if (not FIsPongRecv) and (k > FPongWait) then
  begin
    LogError('ping timeout %d sec, close', [FPongWait]);
    Terminate;
    Exit;
  end;
  if SecondsBetween(Now(), FPingTime) < FAutoPing then
    Exit;
  OnSendPing('', wsCodePing);
end;

function TWorkThreadWebSocket.SendText(const S: string): Boolean;
begin
  Result := False;
  if FConn.SendText(S) then
  begin
    LogDebug('> %d "%s"', [wsCodeText, S]);
    Result := True;
  end
  else
  begin
    LogError('> %d "%s"', [wsCodeText, S]);
    LogError('# %d "%s"', [FSocket.LastError, FSocket.LastErrorDesc])
  end;
end;

function TWorkThreadWebSocket.Send(const S: RawByteString; I: TWsOpcode): Boolean;
begin
  Result := False;
  if Aborted then
    Exit;
  if FIsClosing and (I <> wsCodeClose) then
    Exit;
  if FConn.Send(S, I) then
  begin
    LogDebug('> %d "%s"', [I, S]);
    Result := True
  end
  else
  begin
    LogError('> %d "%s"', [I, S]);
    LogError('# %d "%s"', [FSocket.LastError, FSocket.LastErrorDesc])
  end;
end;

procedure TWorkThreadWebSocket.SendClose(const ACode: TWsCloseCode;
  const AReason: UTF8String);
var z: RawByteString;
begin
  FIsClosing := True;
  LogDebug('closing %d "%s"', [ACode, AReason]);
  z := #32#32 + UTF8Encode(AReason);
  PWord(Pointer(z))^ := Swap(ACode);
  Send(z, wsCodeClose);
end;


procedure TWorkThreadWebSocket.SendPing;
begin
  OnSendPing('', wsCodePing);
end;

procedure TWorkThreadWebSocket.SetConnectParam(const Value: IConnectParam);
begin
  FConn.ConnectParam := Value
end;

procedure TWorkThreadWebSocket.SetCookieManager(const Value: ICookieManager);
begin
  FConn.Cookies := Value
end;

procedure TWorkThreadWebSocket.SetLogger;
begin
  {}
end;

procedure TWorkThreadWebSocket.SetUrl(const Value: AnsiString);
begin
  FConn.Url := Value
end;

procedure TWorkThreadWebSocket.TerminatedSet;
begin
  FAutoPing := WS_PING_5MINUTES;
  FAutoPong := False;
  FIsClosing := True;
  FSocket.CloseSocket();
  inherited;
end;

end.
