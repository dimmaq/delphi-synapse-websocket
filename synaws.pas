unit synaws;

interface

uses
  SysUtils, Classes, AnsiStrings,
  //
  blcksock, synautil, synaip, synacode, synsock, ssl_openssl,
  //
  uWebSocketUpgrade, uWebSocketConst, uConnectParamInterface,
  //
  uCookieManager;

type
  TSynaws = class
  protected
    FIsConnected: Boolean;
    FConn: TTCPBlockSocket;
    FConnectParam: IConnectParam;
    FUpgrader: TWebSocketUpgrade;
    FCookies: ICookieManager;
    FUrl: AnsiString;
    FReadBuffer: RawByteString;
  public
    constructor Create(const AConnectParam: IConnectParam);
    destructor Destroy; override;
    //---
    function Connect(const AUrl: AnsiString): Boolean;
    function Send(const A: RawByteString; const ACode: TWsOpcode = wsCodeText): Boolean;
    function SendText(const S: string): Boolean;
    function WaitData(const ATimeout: Integer): Boolean;
    function Recv(var AData: AnsiString; var ACode: TWsOpcode): Boolean;
    //---
    property IsConnected: Boolean read FIsConnected;
    property Conn: TTCPBlockSocket read FConn;
    property Cookies: ICookieManager read FCookies write FCookies;
    property Url: AnsiString read FUrl write FUrl;
  end;

implementation

uses
  AcedStrings,
  //
  uStringUtils;


constructor TSynaws.Create(const AConnectParam: IConnectParam);
begin
  inherited Create;

  FConnectParam := AConnectParam;

  FConn := TTCPBlockSocket.Create;
  FConn.Owner := Self;

  FConn.NagleMode := False; // nodelay switch on
end;

destructor TSynaws.Destroy;
begin
  FUpgrader.Free;
  FConn.Free;
  inherited Destroy;
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
    lcookies := AnsiString(FCookies.GetLine(GetUrlHost(string(FUrl)))); // cast


  if not Assigned(FUpgrader) then
    FUpgrader := TWebSocketUpgrade.CreateClient(FUrl, True);
  FUpgrader.Cookies := lcookies;

  FConn.ConnectionTimeout := FConnectParam.ConnectTimeout;
  FConn.SetTimeout(FConnectParam.RecvTimeout);

  FConn.SSL.SSLType := LT_all;
  FConn.RaiseExcept := True;

  lproxy := ansiString(FConnectParam.SocksProxy);
  if lproxy <> '' then
  begin
    FConn.SocksType := ST_Socks4;
    FConn.SocksIP := AddrGetHost(lproxy);
    FConn.SocksPort := AddrGetPort(lproxy, PROXY_PORT_DEFAULT);
    FConn.SocksResolver := False;
  end;

  // Connect socket
  FConn.CloseSocket;
  FConn.Bind(FConnectParam.BindAddrA, cAnyPort);
  if FConn.LastError <> 0 then
    Exit(False);

  FConn.Connect(FUpgrader.Host, FUpgrader.Port);
  if FConn.LastError <> 0 then
    Exit(False);

  // TLS?
  if Pos('wss://', FUrl) = 1 then
  begin
    if FConn.SSL.SNIHost = '' then
      FConn.SSL.SNIHost := FUpgrader.Host;
    FConn.SSLDoConnect;
    FConn.SSL.SNIHost := ''; //don't need it anymore and don't wan't to reuse it in next connection
    if FConn.LastError <> 0 then
      Exit(False);
  end;

  // Sent Request
  FConn.SendString(FUpgrader.Headers);
  if FConn.LastError <> 0 then
    Exit(False);

  // read response headers
  lresp_headers := FConn.RecvTerminated(FConnectParam.RecvTimeout, CRLF + CRLF);
  if FConn.LastError <> 0 then
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
  FConn.SendString(z);
  Result := FConn.LastError = 0
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
  Result := FConn.CanRead(ATimeout);
  if Result then
  begin
{    if FConn.WaitingData() = 0 then
      FConn.RecvBuffer(nil, 0)  }
  end;
end;

function TSynaws.Recv(var AData: AnsiString; var ACode: TWsOpcode): Boolean;
var z: AnsiString;
begin
  AData := '';
  ACode := -1;
  z := FConn.RecvPacket(FConnectParam.RecvTimeout);
  if FConn.LastError <> 0 then
    Exit(False);

  FReadBuffer := FReadBuffer + z;
  AData := FUpgrader.ReadData(FReadBuffer, ACode);
  Result := ACode >= 0;
end;

end.


