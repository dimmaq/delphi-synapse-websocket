unit uWorkThreadBase;

interface

uses
  System.Classes, System.SysUtils, System.SyncObjs, Winapi.Windows, Vcl.Forms,
  System.StrUtils,
  //---
  uReLog3, uLoggerInterface,
  uTextWriter;

type
  TWorkThreadBase = class abstract(TThread)
  private
    // terminate
    FAborted: Boolean;
    FAbortEvent: TEvent;
    // saving dump
    FDumpPath: TFileName;  // path for saving traffic and dump-file
    FDumpFile : TAnsiStreamWriter; // trafic flow file
    FDumpFileName: TFileName;
    FDumpCreateFailed: Boolean;
    FDumpFlow: Boolean;
    //---
    // Сохранение трафика
    procedure DumpFileCreate;
    //---
    function GetAborted: Boolean;
    //---
    function IncFileDumpCounter: Integer;
  protected
    // какой-нибудь результат работы потока
    FReturn: string;
    //---
    procedure TerminatedSet; override;
    // переопределение файла дампа
    function GetDumpFileName: TFileName; virtual;
    procedure AddDump(ATyp: AnsiChar; const AData: RawByteString); overload;
    procedure AddDump(ATyp: AnsiChar; const AData: string); overload;
    procedure SaveDumpFile(const ABuf: RawByteString);
  protected
    FLogger: ILoggerInterface;
    procedure SetLogger; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    //---
    procedure Abort(const S: string); overload;
    procedure Abort(const F: string; const AArgs: array of const); overload;
    // пауза потока
    function SleepWait(const A: Cardinal; const AWaitObj: THandleObject;
      var ASignaledObj: THandleObject): TWaitResult;
    function Sleep(const A: Cardinal; const AWaitObj: THandleObject = nil): THandleObject; virtual;
    //---
    {$HINTS OFF}
    procedure LogLog(const ALevel: TLogLevel; const A: string); overload;
    procedure LogLogA(const ALevel: TLogLevel; const A: AnsiString); overload;
    procedure LogLog(const ALevel: TLogLevel; const AFormat: string; const AArgs: array of const); overload;
    procedure LogLogA(const ALevel: TLogLevel; const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure LogInfo(const A: string); overload;
    procedure LogInfoA(const A: AnsiString); overload;
    procedure LogInfo(const AFormat: string; const AArgs: array of const); overload;
    procedure LogInfoA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure LogDebug(const AMessage: string); overload;
    procedure LogDebugA(const AMessage: AnsiString); overload;
    procedure LogDebug(const AFormat: string; const AArgs: array of const); overload;
    procedure LogDebugA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure LogSuccess(const AMessage: string); overload;
    procedure LogSuccessA(const AMessage: AnsiString); overload;
    procedure LogSuccess(const AFormat: string; const AArgs: array of const); overload;
    procedure LogSuccessA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure LogError(const AMessage: string); overload;
    procedure LogErrorA(const AMessage: AnsiString); overload;
    procedure LogError(const AFormat: string; const AArgs: array of const); overload;
    procedure LogErrorA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure LogError(const E: Exception; const APrefix: string = ''); overload;
    {$HINTS ON}
    //---
    property Aborted: Boolean read GetAborted;
    property IsAborted: Boolean read GetAborted;
    property AbortEvent: TEvent read FAbortEvent;
    property Logger: ILoggerInterface read FLogger;// write FLogger;
    property Return: string read FReturn write FReturn;
    property DumpPath: TFileName read FDumpPath write FDumpPath;
    property DumpFileName: TFileName read FDumpFileName write FDumpFileName;
    property DumpFlow: Boolean read FDumpFlow write FDumpFlow;
    property DumpCreateFailed: Boolean read FDumpCreateFailed;
  end;

implementation

uses
  uGlobalConstants, uGlobalVars, uStringUtils, uGlobalFunctions, uGlobalFileIoFunc,
  AcedStrings, uRegExprFunc;


{ TWorkThreadBase }

procedure TWorkThreadBase.Abort(const F: string; const AArgs: array of const);
begin
  Abort(Format(F, AArgs))
end;

procedure TWorkThreadBase.Abort(const S: string);
begin
  LogError(S);
  Terminate();
end;

procedure TWorkThreadBase.AddDump(ATyp: AnsiChar; const AData: string);
begin
  AddDump(ATyp, RawByteString(AData));
end;

var
  gFileCounterDump: Integer = 0;

function TWorkThreadBase.IncFileDumpCounter: Integer;
begin
  Result := TInterlocked.Increment(gFileCounterDump)
end;

procedure TWorkThreadBase.SaveDumpFile(const ABuf: RawByteString);
var k: Integer;
begin
  k := IncFileDumpCounter();
  StringSaveToFile(FDumpPath + IntToStr(k) + '.txt', ABuf);
end;

procedure TWorkThreadBase.SetLogger;
begin
end;

constructor TWorkThreadBase.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
  //---
  FAbortEvent := TEvent.Create(nil, True, False, '');
  //---
  SetLogger();
end;

destructor TWorkThreadBase.Destroy;
begin
  FLogger := nil;
  FreeAndNil(FDumpFile);
  FreeAndNil(FAbortEvent);
  //---
  inherited;
end;

procedure TWorkThreadBase.TerminatedSet;
begin
  inherited;
  FAborted := True;
  FAbortEvent.SetEvent;
end;


procedure TWorkThreadBase.LogLog(const ALevel: TLogLevel; const A: string);
begin
  if Assigned(FLogger) then
    FLogger.Log(ALevel, A);
end;

procedure TWorkThreadBase.LogLog(const ALevel: TLogLevel; const AFormat: string;
  const AArgs: array of const);
begin
  if Assigned(FLogger) then
    FLogger.Log(ALevel, AFormat, AArgs);
end;

procedure TWorkThreadBase.LogLogA(const ALevel: TLogLevel; const A: AnsiString);
begin
  LogLog(ALevel, string(A))  // cast
end;

procedure TWorkThreadBase.LogLogA(const ALevel: TLogLevel;
  const AFormat: AnsiString; const AArgs: array of const);
begin
  LogLog(ALevel, string(AFormat), AArgs) // cast
end;

procedure TWorkThreadBase.LogDebug(const AFormat: string; const AArgs: array of const);
begin
  LogLog(TLogLevel.logDebug, AFormat, AArgs)
end;

procedure TWorkThreadBase.LogDebugA(const AMessage: AnsiString);
begin
  LogDebug(string(AMessage))  // cast
end;

procedure TWorkThreadBase.LogDebugA(const AFormat: AnsiString;
  const AArgs: array of const);
begin
  LogDebug(string(AFormat), AArgs)  // cast
end;

procedure TWorkThreadBase.LogDebug(const AMessage: string);
begin
  LogLog(TLogLevel.logDebug, AMessage)
end;

procedure TWorkThreadBase.LogError(const E: Exception; const APrefix: string);
begin
  if APrefix.IsEmpty then
    LogError('%s: %s', [E.ClassName, E.Message])
  else
    LogError('%s %s: %s', [APrefix, E.ClassName, E.Message])
end;

procedure TWorkThreadBase.LogErrorA(const AMessage: AnsiString);
begin
  LogError(string(AMessage))  // cast
end;

procedure TWorkThreadBase.LogErrorA(const AFormat: AnsiString;
  const AArgs: array of const);
begin
  LogError(string(AFormat), AArgs)  // cast
end;

procedure TWorkThreadBase.LogError(const AFormat: string; const AArgs: array of const);
begin
  LogLog(TLogLevel.logError, AFormat, AArgs)
end;

procedure TWorkThreadBase.LogError(const AMessage: string);
begin
  LogLog(TLogLevel.logError, AMessage)
end;

procedure TWorkThreadBase.LogInfo(const AFormat: string; const AArgs: array of const);
begin
  LogLog(TLogLevel.logInfo, AFormat, AArgs)
end;

procedure TWorkThreadBase.LogInfoA(const A: AnsiString);
begin
  LogInfo(string(A))  // cast
end;

procedure TWorkThreadBase.LogInfoA(const AFormat: AnsiString;
  const AArgs: array of const);
begin
  LogInfo(string(AFormat), AArgs)  // cast
end;

procedure TWorkThreadBase.LogInfo(const A: string);
begin
  LogLog(TLogLevel.logInfo, A)
end;

procedure TWorkThreadBase.LogSuccess(const AMessage: string);
begin
  LogLog(TLogLevel.logSuccess, AMessage)
end;

procedure TWorkThreadBase.LogSuccess(const AFormat: string; const AArgs: array of const);
begin
  LogLog(TLogLevel.logSuccess, AFormat, AArgs)
end;


procedure TWorkThreadBase.LogSuccessA(const AFormat: AnsiString;
  const AArgs: array of const);
begin
  LogSuccess(string(AFormat), AArgs)  // cast
end;

procedure TWorkThreadBase.LogSuccessA(const AMessage: AnsiString);
begin
  LogSuccess(string(AMessage))  // cast
end;

function TWorkThreadBase.GetAborted: Boolean;
begin
  Result := (Application = nil) or Application.Terminated or FAborted or Terminated
end;

procedure TWorkThreadBase.DumpFileCreate;
var
  l_dumpFileName: TFileName;
begin
  if FDumpFlow and (not FDumpCreateFailed) and (not Assigned(FDumpFile)) then
  begin
    l_dumpFileName := GetDumpFileName();
    if l_dumpFileName <> '' then
    begin
      try
        FDumpFile := TAnsiStreamWriter.Create(FDumpPath + l_dumpFileName, True);
        FDumpFile.UseBuffer := False;
      except
        on E: Exception do
        begin
          if Assigned(Logger) then
            LogError('%s %s'#13#19'%s', [E.ClassName, E.Message, E.StackTrace]);
          FDumpCreateFailed := True;
          FDumpFile := nil;
        end;
      end;
    end
    else
    begin
      FDumpCreateFailed := True;
    end;
  end;
end;

procedure TWorkThreadBase.AddDump(ATyp: AnsiChar; const AData: RawByteString);
const
  UnSafeChars = [#0..#8,#11,#12,#14..#31];
var
  S: TAnsiStringBuilder;
  z: AnsiString;
  j: Integer;
  l: Integer;
  ch: AnsiChar;
begin
  if (not FDumpFlow) or (FDumpCreateFailed) then
    Exit;
  //---
  // создание дампа
  DumpFileCreate();
  if FDumpCreateFailed then
    Exit;
  //---
  // если в строке непечатные смволы - перевод в Hex
  if {False and }(CharsPos(UnSafeChars, AData) > 0) then
  begin
    z := '';
    l := Length(AData);
    S := TAnsiStringBuilder.Create(l * 3);
    try
      for j := 1 to l do
      begin
        ch := AData[j];
        if ch in UnSafeChars then
          S.Append('#').Append(Ord(ch))
        else
          S.Append(ch)
      end;
      //---
      z := S.ToString();
    finally
      S.Free;
    end;
  end
    else
  begin
    z := AData;
  end;
  G_TrimRight(z);
  z := ANSICRLF + ATyp + ' ' + z;
  //---
  FDumpFile.Write(z);
end;

function TWorkThreadBase.SleepWait(const A: Cardinal; const AWaitObj: THandleObject; var ASignaledObj: THandleObject): TWaitResult;
var
  l_handleObjs: THandleObjectArray;
begin
  if Aborted then
  begin
    ASignaledObj := FAbortEvent;
    Result := wrSignaled;
    Exit;
  end;
//  FLogger.Debug('sleep ' + A.ToString);
  if Assigned(AWaitObj) then
  begin
    SetLength(l_handleObjs, 2);
    l_handleObjs[0] := FAbortEvent;
    l_handleObjs[1] := AWaitObj;
    Result := TEvent.WaitForMultiple(l_handleObjs, A, False, ASignaledObj);
    Exit;
  end
  else
  begin
    Result := FAbortEvent.WaitFor(A);
    ASignaledObj := FAbortEvent;
    Exit;
  end;
end;

function TWorkThreadBase.Sleep(const A: Cardinal; const AWaitObj: THandleObject): THandleObject;
var r: TWaitResult;
begin
  r := SleepWait(A, AWaitObj, Result);
  if not (r in [wrAbandoned, wrSignaled]) then
    Result := nil;
end;

     (*
function DumpString(const A: string): string;
type
  PStrRec = ^StrRec;
  StrRec = packed record
  {$IF defined(CPUX64)}
    _Padding: LongInt; // Make 16 byte align for payload..
  {$ENDIF}
    codePage: Word;
    elemSize: Word;
    refCnt: Longint;
    length: Longint;
  end;

const
  skew = SizeOf(StrRec);

var
  P: Pointer;
  R: PStrRec;
begin
  P := Pointer(A);
  if P = nil then
    Exit('nil ');
  R := Pointer(Integer(P) - skew);
  Result := Format('$%p %d %d ', [Pointer(A), R.refCnt, R.length])
end;

function StrPointer(const A: string): string;
begin
  Result := Format('$%p', [Pointer(A)])
end;     *)

function TWorkThreadBase.GetDumpFileName: TFileName;
begin
  if FDumpFileName <> '' then
    Result := FDumpFileName
  else
    Result := Format('%s_dump%d.txt', [ClassName, IncFileDumpCounter()])

end;

end.

