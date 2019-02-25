unit uSimpleConnectParam;

interface

uses
  uConnectParamInterface;

type
  TSimpleConnectParam = class(TConnectParamBase)
  protected
    FBind: AnsiString;
    FSocks: AnsiString;
    FConnectTimeout: Integer;
    FRecvTimeout: Integer;
    FSendTimeout: Integer;
    //---
    function GetConnectTimeout: Integer; override;
    function GetRecvTimeout: Integer; override;
    function GetSendTimeout: Integer; override;
    function GetBindAddr: string; override;
    function GetSocksProxy: string; override;
    function GetSocksProxyA: AnsiString; override;
    function GetBindAddrA: AnsiString; override;

//    procedure SetBindAddr(const Value: string);
    procedure SetConnectTimeout(const Value: Integer); override;
    procedure SetRecvTimeout(const Value: Integer); override;
    procedure SetSendTimeout(const Value: Integer); override;
    procedure SetSocksProxy(const A: string); override;
    procedure SetSocksProxyA(const A: AnsiString); override;
  public
    constructor Create; overload;
    constructor Create(const ATimeout: Integer); overload;
  end;

implementation

{ TSimpleConnectParam }

constructor TSimpleConnectParam.Create;
begin
  Create(TIMEOUT_DEFAULT)
end;

constructor TSimpleConnectParam.Create(const ATimeout: Integer);
begin
  inherited Create;

  FBind := '0.0.0.0';
  FSocks := '';

  FConnectTimeout := ATimeout;
  FRecvTimeout := ATimeout;
  FSendTimeout := ATimeout;

end;

function TSimpleConnectParam.GetBindAddr: string;
begin
  Result := string(FBind);  // cast
end;

function TSimpleConnectParam.GetBindAddrA: AnsiString;
begin
  Result := FBind;
end;

function TSimpleConnectParam.GetConnectTimeout: Integer;
begin
  Result := FConnectTimeout
end;

function TSimpleConnectParam.GetRecvTimeout: Integer;
begin
  Result := FRecvTimeout
end;

function TSimpleConnectParam.GetSendTimeout: Integer;
begin
  Result := FSendTimeout
end;

function TSimpleConnectParam.GetSocksProxy: string;
begin
  Result := string(FSocks)   // cast
end;

function TSimpleConnectParam.GetSocksProxyA: AnsiString;
begin
    Result := FSocks
end;

procedure TSimpleConnectParam.SetConnectTimeout(const Value: Integer);
begin
  FConnectTimeout := Value
end;

procedure TSimpleConnectParam.SetRecvTimeout(const Value: Integer);
begin
  FRecvTimeout := Value
end;

procedure TSimpleConnectParam.SetSendTimeout(const Value: Integer);
begin
  FSendTimeout := Value
end;

procedure TSimpleConnectParam.SetSocksProxy(const A: string);
begin
  FSocks := AnsiString(A) // cast
end;

procedure TSimpleConnectParam.SetSocksProxyA(const A: AnsiString);
begin
  FSocks := A
end;

end.
