unit uWorkThreadSynaBase;

interface

uses
  System.Classes, System.SysUtils, System.SyncObjs, Winapi.Windows, Vcl.Forms,
  System.StrUtils,
  //---
  blcksock, synsock, synacode,
  //---
  uWorkThreadBase, uCookieManager,
  uConnectParamInterface;

type
  TWorkThreadSynaBase = class abstract(TWorkThreadBase)
  private
    FDumpResponce: Boolean;
    FConnectParam: IConnectParam;
    FCookies: ICookieManager;
    FRaiseProtoError: Boolean;
    FRaiseInetError: Boolean;
  protected
    // события
    procedure HookMonitor(Sender: TObject; Writing: Boolean; const Buffer: TMemory; Len: Integer);
    procedure HookSocketStatus(Sender: TObject; Reason: THookSocketReason; const Value: String);
  public
    constructor Create(const AConnectParam: IConnectParam);
    destructor Destroy; override;
    //---
    property ConnectParam: IConnectParam read FConnectParam write FConnectParam;
    property Cookies: ICookieManager read FCookies write FCookies;
    property DumpResponce: Boolean read FDumpResponce write FDumpResponce;
    property RaiseProtoError: Boolean read FRaiseProtoError write FRaiseProtoError;
    property RaiseInetError: Boolean read FRaiseInetError write FRaiseInetError;
  end;

implementation

uses
  uGlobalConstants, uGlobalVars, uStringUtils, uGlobalFunctions, uGlobalFileIoFunc,
  AcedStrings, uRegExprFunc;

{ TWorkThreadSynaBase }

constructor TWorkThreadSynaBase.Create(const AConnectParam: IConnectParam);
begin
  inherited Create;

  FConnectParam := AConnectParam;
  FRaiseProtoError := True;
  FRaiseInetError := True;
end;

destructor TWorkThreadSynaBase.Destroy;
begin
  //---
  inherited;
end;

procedure TWorkThreadSynaBase.HookMonitor(Sender: TObject; Writing: Boolean;
  const Buffer: TMemory; Len: Integer);
const
  typ: array[Boolean] of AnsiChar = ('>', '<');
var
  buf: RawByteString;
begin
  if DumpCreateFailed or (not DumpFlow) then
    Exit;
  //---
  SetLength(buf, len);
  CopyMemory(Pointer(buf), Buffer, len);
  //---
  AddDump(typ[Writing], buf)
end;

procedure TWorkThreadSynaBase.HookSocketStatus(Sender: TObject;
  Reason: THookSocketReason; const Value: String);
const
  reason_str : array[THookSocketReason] of AnsiString = (
    'HR_ResolvingBegin',
    'HR_ResolvingEnd',
    'HR_SocketCreate',
    'HR_SocketClose',
    'HR_Bind',
    'HR_Connect',
    'HR_CanRead',
    'HR_CanWrite',
    'HR_Listen',
    'HR_Accept',
    'HR_ReadCount',
    'HR_WriteCount',
    'HR_Wait',
    'HR_Error'
  );
begin
  AddDump('*', reason_str[Reason] + ' - ' + AnsiString(Value));
end;

end.

