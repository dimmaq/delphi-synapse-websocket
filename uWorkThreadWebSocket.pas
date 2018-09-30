unit uWorkThreadWebSocket;

interface

uses
  SysUtils,
  //
  uWorkThreadSynaBase, synaws, uConnectParamInterface, uLoggerInterface,
  uWebSocketUpgrade, uWebSocketConst;

type
  TWorkThreadWebSocket = class(TWorkThreadSynaBase)
  private
    FConn: TSynaws;
  protected
    procedure SetLogger; override;
    procedure Execute; override;
  public
    constructor Create(const AUrl: AnsiString; const AConnectParam: IConnectParam;
      const ALog: ILoggerInterface);
    destructor Destroy; override;

    function Send(const S: RawByteString; I: TWsOpcode = wsCodeText): Boolean;
    function SendText(const S: string): Boolean; overload;
  end;

implementation

{ TWorkThreadWebSocket }

constructor TWorkThreadWebSocket.Create(const AUrl: AnsiString;
    const AConnectParam: IConnectParam;
      const ALog: ILoggerInterface);
begin
  Inherited Create(AConnectParam);
  FConn := TSynaws.Create(AConnectParam);
  FConn.Url := AUrl;
  FConn.Conn.OnMonitor := HookMonitor;
  FConn.Conn.OnStatus := HookSocketStatus;

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
  FConn.Cookies := FCookies;
  try
    if not FConn.Connect('') then
    begin
      LogError('connect fail %d %s', [FConn.Conn.LastError, FConn.Conn.LastErrorDesc]);
      Exit;
    end;
    LogInfo('conected, wait data');
    //FConn.Send('', wsCodePing);

    while not Aborted do
    begin
      if FConn.WaitData(FConnectParam.RecvTimeout) then
      begin
        if FConn.Recv(ldata, lcode) then
        begin
          LogInfo('< %d %s', [lcode, ldata]);
        end;
      end;
      if FConn.Conn.LastError <> 0 then
      begin
        LogError('recv fail %d %s', [FConn.Conn.LastError, FConn.Conn.LastErrorDesc]);
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

function TWorkThreadWebSocket.SendText(const S: string): Boolean;
begin
  Result := False;
  if FConn.SendText(S) then
  begin
    LogInfo('> %d %s', [wsCodeText, S]);
    Result := True;
  end
  else
  begin
    LogError('> %d %s', [wsCodeText, S]);
    LogError('# %d %s', [FConn.Conn.LastError, FConn.Conn.LastErrorDesc])
  end;
end;

function TWorkThreadWebSocket.Send(const S: RawByteString; I: TWsOpcode): Boolean;
begin
  Result := False;
  if FConn.Send(S, I) then
  begin
    LogInfo('> %d %s', [I, S]);
    Result := True
  end
  else
  begin
    LogError('> %d %s', [I, S]);
    LogError('# %d %s', [FConn.Conn.LastError, FConn.Conn.LastErrorDesc])
  end;
end;

procedure TWorkThreadWebSocket.SetLogger;
begin
  {}
end;

end.
