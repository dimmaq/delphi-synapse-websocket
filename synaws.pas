unit synaws;

interface

uses
  SysUtils, Classes, AnsiStrings, SyncObjs,
  //
  blcksock, synautil, synaip, synacode, synsock, ssl_openssl,
  //
  uWebSocketUpgrade, uWebSocketConst, uConnectParamInterface,
  //
  uCookieManager;

type
  TSynaws = class
  private
    function RecvPacketToBuffer(const ATimeout: Integer = 0): Boolean;
    function ReadFrameFromBuffer(var AData: RawByteString;
      var AOpcode: TWsOpcode): Boolean;
  protected
    FIsConnected: Boolean;
    FSocket: TTCPBlockSocket;
    FConnectParam: IConnectParam;
    FUpgrader: TWebSocketUpgrade;
    FCookies: ICookieManager;
    FUrl: AnsiString;
    FOrigin: RawByteString;
    FUserAgent: RawByteString;
    //FAddHeaders: TAnsiStrings;
    FReadBuffer: RawByteString;
    FSendLock: TCriticalSection;
  public
    constructor Create(const AConnectParam: IConnectParam);
    destructor Destroy; override;
    //---
    procedure Disconnect;
    function Connect(const AUrl: AnsiString): Boolean;
    function Send(const A: RawByteString; const ACode: TWsOpcode = wsCodeText): Boolean;
    function SendText(const S: string): Boolean;
    function WaitData(const ATimeout: Integer): Boolean;
    function Recv(var AData: RawByteString; var ACode: TWsOpcode): Boolean;
    //---
    property IsConnected: Boolean read FIsConnected;
    property Socket: TTCPBlockSocket read FSocket;
    property Cookies: ICookieManager read FCookies write FCookies;
    property ConnectParam: IConnectParam read FConnectParam write FConnectParam;
    property Url: AnsiString read FUrl write FUrl;
    property Origin: RawByteString read FOrigin write FOrigin;
    property UserAgent: RawByteString read FUserAgent write FUserAgent;
  end;

implementation

uses
  AcedStrings,
  //
  uStringUtils;


constructor TSynaws.Create(const AConnectParam: IConnectParam);
begin
  inherited Create;

  FSendLock := TCriticalSection.Create;

  FConnectParam := AConnectParam;

  FSocket := TTCPBlockSocket.Create;
  FSocket.Owner := Self;

  FSocket.NagleMode := False; // nodelay switch on

  FUpgrader := TWebSocketUpgrade.Create;
end;

destructor TSynaws.Destroy;
begin
  FreeAndNil(FSendLock);
  FreeAndNil(FUpgrader);
  FreeAndNil(FSocket);
  inherited Destroy;
end;

procedure TSynaws.Disconnect;
begin
  FSocket.CloseSocket;
end;

function TSynaws.Connect(const AUrl: AnsiString): Boolean;
const
  PROXY_PORT_DEFAULT: AnsiString = '1080';
var
  lproxy: AnsiString;
  lresp_headers: AnsiString;
  lcookies: AnsiString;
begin
  if FIsConnected then
    raise Exception.Create('already connected');

  // Set params
  if AUrl <> '' then
    FUrl := AUrl;

  lcookies := '';
  if Assigned(FCookies) then
    lcookies := FCookies.GetCookieA(GetUrlHostA(FUrl));

  FUpgrader.InitAsClient(FUrl, True);
  FUpgrader.Cookies := lcookies;
  FUpgrader.UserAgent := FUserAgent;
  FUpgrader.Origin := FOrigin;
  //FUpgrader.AddHeaders.AddStrings();

  FSocket.ConnectionTimeout := FConnectParam.ConnectTimeout;
  FSocket.SetTimeout(FConnectParam.RecvTimeout);

  FSocket.SSL.SSLType := LT_all;
  FSocket.RaiseExcept := True;

  lproxy := FConnectParam.SocksProxyA;
  if lproxy <> '' then
  begin
    FSocket.SocksType := ST_Socks4;
    FSocket.SocksIP := AddrGetHost(lproxy);
    FSocket.SocksPort := AddrGetPort(lproxy, PROXY_PORT_DEFAULT);
    FSocket.SocksResolver := False;
  end;

  // Connect socket
  FSocket.CloseSocket;
  FSocket.Bind(FConnectParam.BindAddrA, cAnyPort);
  if FSocket.LastError <> 0 then
    Exit(False);

  FSocket.Connect(FUpgrader.Host, FUpgrader.Port);
  if FSocket.LastError <> 0 then
    Exit(False);

  // TLS?
  if Pos('wss://', FUrl) = 1 then
  begin
    if FSocket.SSL.SNIHost = '' then
      FSocket.SSL.SNIHost := FUpgrader.Host;
    FSocket.SSLDoConnect;
    FSocket.SSL.SNIHost := ''; //don't need it anymore and don't wan't to reuse it in next connection
    if FSocket.LastError <> 0 then
      Exit(False);
  end;

  // Sent Request
  FSocket.SendString(FUpgrader.Headers);
  if FSocket.LastError <> 0 then
    Exit(False);

  // read response headers
  lresp_headers := FSocket.RecvTerminated(FConnectParam.RecvTimeout, CRLF + CRLF);
  if FSocket.LastError <> 0 then
    Exit(False);

  if not FUpgrader.ClientConfirm(lresp_headers) then
  begin
    Exit(False);
  end;

  FIsConnected := True;

  Exit(True)
end;

function TSynaws.Send(const A: RawByteString; const ACode: TWsOpcode): Boolean;
var z: RawByteString;
begin
  z := FUpgrader.SendData(A, ACode);
  FSendLock.Enter;
  try
    FSocket.SendString(z);
  finally
    FSendLock.Leave;
  end;
  Result := FSocket.LastError = 0
end;

function TSynaws.SendText(const S: string): Boolean;
var u: UTF8String;
begin
  u := UTF8Encode(S);
  Result := Send(u, wsCodeText)
end;

function TSynaws.WaitData(const ATimeout: Integer): Boolean;
begin
  // wait data
  Result := FSocket.CanRead(ATimeout);
  if Result then
  begin
{    if FConn.WaitingData() = 0 then
      FConn.RecvBuffer(nil, 0)  }
  end;
end;

function TSynaws.ReadFrameFromBuffer(var AData: RawByteString;
  var AOpcode: TWsOpcode): Boolean;
begin
  AData := FUpgrader.ReadData(FReadBuffer, AOpcode);
  Result := AOpcode <> wsNoFrame
end;

function TSynaws.Recv(var AData: RawByteString; var ACode: TWsOpcode): Boolean;

  function IsIncompleteFrameExists: Boolean;
  begin
    Result := FUpgrader.IsIncompleteFragmentsExists or (FReadBuffer <> '')
  end;

begin
  AData := '';
  ACode := wsNoFrame;
  //
  // there is frame in buffer
  if FReadBuffer <> '' then
  begin
    if ReadFrameFromBuffer(AData, ACode) then
    begin
      Result := IsIncompleteFrameExists();
      Exit;
    end;
  end;
  //
  if RecvPacketToBuffer(FConnectParam.RecvTimeout) then
  begin
    if ReadFrameFromBuffer(AData, ACode) then
    begin
      Result := IsIncompleteFrameExists();
      Exit;
    end;
  end;
  Result := False
end;

function TSynaws.RecvPacketToBuffer(const ATimeout: Integer): Boolean;
var z: RawByteString;
begin
  z := FSocket.RecvPacket(ATimeout);
//  SetCodePage(z, #$FFFF, False);
//  SetCodePage(FReadBuffer, #$FFFF, False);
  FReadBuffer := FReadBuffer + z;
  SetCodePage(FReadBuffer, $FFFF, False);
  //
  Result := FSocket.LastError = 0;
end;

end.


