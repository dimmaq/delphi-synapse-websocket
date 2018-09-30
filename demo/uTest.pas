unit uTest;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Types,
  //
  uLoggerInterface;

procedure TestDumpDir(const ADir: TFileName; const ALog: ILoggerInterface);

implementation

uses
  uStringUtils, uGlobalFileIoFunc,
  uWebSocketUpgrade, uWebSocketFrame;

const
  CRLFCRLF: RawByteString = #13#10#13#10;

function TestUpgrader(const ws: TWebSocketUpgrade;
  S: RawByteString; const ALog: ILoggerInterface): Boolean;
var
  Z, b: RawByteString;
  fr: TWebSocketFrame;
begin
  Result := False;
  Z := S;
  while S <> '' do
  begin
    if ws.ReadDataFrame(S, fr) then
    begin
     // ALog.Info('%d %d', [fr.Opcode, fr.DecodedData]);
//      ALog.Info('%d %d %s', [fr.Opcode, fr.PayloadLen, fr.DecodedData]);
      b := fr.ToBuffer();
      if b <> Copy(Z, 1, Length(Z) - Length(S)) then
      begin
        ALog.Error('no same frame');
        Exit;
      end;
      Delete(Z, 1, Length(b))
    end
    else
    begin
      ALog.Error('read frame');
      Exit;
    end;
  end;
  Result := True;
end;


function TestResponseRaw(S: RawByteString; const ALog: ILoggerInterface): Boolean;
const
  CRLFCRLF: RawByteString = #13#10#13#10;
var
  ws: TWebSocketUpgrade;
  h: RawByteString;
begin
  h := StrCut(S, CRLFCRLF);
  ws := TWebSocketUpgrade.CreateClient('ws://test/', True);
  try
    ws.Headers;
    if not ws.ClientConfirm(h, True) then
      raise Exception.Create('client confirm');

    Result := TestUpgrader(ws, S, ALog);
  finally
    ws.Free;
  end;
end;

function TestRequestRaw(S: RawByteString; const ALog: ILoggerInterface): Boolean;
const
  CRLFCRLF: RawByteString = #13#10#13#10;
var
  ws: TWebSocketUpgrade;
  h: RawByteString;
begin
  h := StrCut(S, CRLFCRLF);
  ws := TWebSocketUpgrade.CreateServer(h);
  try
    ws.Headers;
    Result := TestUpgrader(ws, S, ALog);
  finally
    ws.Free;
  end;
end;

function BytesToRawStr(const A: TBytes): RawByteString;
begin
  SetString(Result, PAnsiChar(@A[0]), Length(A));
end;

function TestResponseFile(const F: TFileName; const ALog: ILoggerInterface): Boolean;
begin
  ALog.Info('---- file ' + F);
  Result := TestResponseRaw(BytesToRawStr(TFile.ReadAllBytes(F)), ALog)
end;

function TestRequestFile(const F: TFileName; const ALog: ILoggerInterface): Boolean;
begin
  ALog.Info('---- file ' + F);
  Result := TestRequestRaw(BytesToRawStr(TFile.ReadAllBytes(F)), ALog)
end;

procedure TestDumpDir(const ADir: TFileName; const ALog: ILoggerInterface);
var
  z: string;
begin
  for z in TDirectory.GetFiles(ADir, '*.response') do
    if not TestResponseFile(z, ALog) then
    begin
      ALog.Error(z);
      Exit;
    end;

  for z in TDirectory.GetFiles(ADir, '*.request') do
    if not TestRequestFile(z, ALog) then
    begin
      ALog.Error(z);
      Exit;
    end;
end;

end.
