unit uConnectParamInterface;

interface

const
  TIMEOUT_DEFAULT = 30000;

type
  IConnectParam = interface
    function GetConnectTimeout: Integer;
    function GetRecvTimeout: Integer;
    function GetSendTimeout: Integer;
    function GetBindAddr: string;
    function GetSocksProxy: string;
    function GetBindAddrA: AnsiString;
    function GetSocksProxyA: AnsiString;

//    procedure SetBindAddr(const Value: string);
    procedure SetConnectTimeout(const Value: Integer);
    procedure SetRecvTimeout(const Value: Integer);
    procedure SetSendTimeout(const Value: Integer);
    procedure SetSocksProxy(const A: string);
    procedure SetSocksProxyA(const A: AnsiString);

    property ConnectTimeout: Integer read GetConnectTimeout write SetConnectTimeout;
    property RecvTimeout: Integer read GetRecvTimeout write SetRecvTimeout;
    property SendTimeout: Integer read GetSendTimeout write SetSendTimeout;
    property BindAddr: string read GetBindAddr;// write SetBindAddr;
    property SocksProxy: string read GetSocksProxy write SetSocksProxy;

    property BindAddrA: AnsiString read GetBindAddrA;// write SetBindAddr;
    property SocksProxyA: AnsiString read GetSocksProxyA write SetSocksProxyA;
  end;

  TConnectParamBase = class(TInterfacedObject, IConnectParam)
  protected
    function GetBindAddr: string; virtual;
    function GetConnectTimeout: Integer; virtual;
    function GetRecvTimeout: Integer; virtual;
    function GetSendTimeout: Integer; virtual;
    function GetSocksProxy: string; virtual;
    function GetBindAddrA: AnsiString; virtual;
    function GetSocksProxyA: AnsiString; virtual;

//    procedure SetBindAddr(const Value: string);
    procedure SetConnectTimeout(const Value: Integer); virtual;
    procedure SetRecvTimeout(const Value: Integer); virtual;
    procedure SetSendTimeout(const Value: Integer); virtual;
    procedure SetSocksProxy(const A: string); virtual;
    procedure SetSocksProxyA(const A: AnsiString); virtual;
  public
    property ConnectTimeout: Integer read GetConnectTimeout write SetConnectTimeout;
    property RecvTimeout: Integer read GetRecvTimeout write SetRecvTimeout;
    property SendTimeout: Integer read GetSendTimeout write SetSendTimeout;
    property BindAddr: string read GetBindAddr;// write SetBindAddr;
    property SocksProxy: string read GetSocksProxy write SetSocksProxy;
    property BindAddrA: AnsiString read GetBindAddrA;// write SetBindAddr;
//    property SocksProxyA: AnsiString read GetSocksProxyA write SetSocksProxyA;
  end;


implementation

const
  BIND_ADDR_DEFAULT = '0.0.0.0';

{ TConnectParamBase }

function TConnectParamBase.GetBindAddr: string;
begin
  Result := BIND_ADDR_DEFAULT
end;

function TConnectParamBase.GetBindAddrA: AnsiString;
begin
  Result := BIND_ADDR_DEFAULT
end;

function TConnectParamBase.GetConnectTimeout: Integer;
begin
  Result := TIMEOUT_DEFAULT
end;

function TConnectParamBase.GetRecvTimeout: Integer;
begin
  Result := TIMEOUT_DEFAULT
end;

function TConnectParamBase.GetSendTimeout: Integer;
begin
  Result := TIMEOUT_DEFAULT
end;

function TConnectParamBase.GetSocksProxy: string;
begin
  Result := ''
end;

function TConnectParamBase.GetSocksProxyA: AnsiString;
begin
  Result := ''
end;

procedure TConnectParamBase.SetConnectTimeout(const Value: Integer);
begin
  {...}
end;

procedure TConnectParamBase.SetRecvTimeout(const Value: Integer);
begin
  {...}
end;

procedure TConnectParamBase.SetSendTimeout(const Value: Integer);
begin
  {...}
end;

procedure TConnectParamBase.SetSocksProxy(const A: string);
begin
  {...}
end;

procedure TConnectParamBase.SetSocksProxyA(const A: AnsiString);
begin
  {...}
end;

end.
