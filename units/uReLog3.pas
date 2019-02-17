unit uReLog3;

interface

uses
  System.SysUtils, System.Classes, Winapi.RichEdit, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Generics.Collections, System.SyncObjs, Vcl.Graphics, System.IOUtils,
  Winapi.Windows, Winapi.Messages, System.AnsiStrings,
  madStackTrace,
  //
  uLoggerInterface;

type
  TReLog3 = class(TInterfacedObject, ILoggerInterface, ILoggerAwareInterface)
//  private
//    FItemIdCounter: Integer;
  private
    type
      TItem = record
//        ID: Cardinal;
        Level: TLogLevel;
        Color: TColor;
        Message: string;
        Time: TDateTime;
        constructor Create(const AMessage: string; const ALevel: TLogLevel; const AColor: TColor);
      end;
  private
//    FInterface: ILoggerInterface;
    FLock: TCriticalSection;
    FRichEdit: TRichEdit;
    //TODO: заменить таймер на поток
    //FTimerOwner: Boolean;
    //FTimer: TThread;
    FScreenThread: TThread;
    FItems: TQueue<TItem>;
    FHist: TQueue<TItem>;
    FFileName: TFileName;
    FFile: TStreamWriter;
    FSaveFile: Boolean;
    FLevelLimit: TLogLevel;
    FFormatFileText: string;
    FFormatFileTime: string;
    FFormatScreenText: string;
    FFormatScreenTime: string;
    FScreenFilter: string;
    FPrefix: string;
    FLogInf: ILoggerInterface;
    FLogHistSize: Integer;
    FTimerPause: Boolean;
    FTrimOut: Boolean;
    //---
    function FormatScreen(const AItem: TItem): string;
    function FormatFile(const AItem: TItem): string;
    procedure CreateLogFile; inline;
    procedure TimerEvent(Sender: TObject);
    procedure SetRichEdit(const Value: TRichEdit);
    procedure SetSaveFile(const Value: Boolean);
    procedure SetScreenFilter(const Value: string);
    procedure ScreenThreadStart;
    procedure ScreenThreadStop;
    procedure ScreenThreadSignal;
  public
    constructor Create(const ARichEdit: TRichEdit; const AFileName: TFileName); overload;
    constructor Create(const ALogger: ILoggerInterface; const APrefix: string = '';
      const AFileName: TFileName = ''); overload;
    destructor Destroy; override;
    //---
    procedure WriteLog(const AMessage: string; const ALevel: TLogLevel; const AColor: TColor); overload;
    procedure WriteLog(const ALevel: TLogLevel; const AMessage: string); overload;
    procedure WriteLog(const AColor: TColor; const AMessage: string); overload;
    //---
    // "Приплыли".  За такого рода сообщением обычно следует экстреный выход из программы.
    procedure Emergency(const AFormat: string; const AArgs: array of const); overload;
    procedure EmergencyA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Emergency(const AMessage: string); overload;
    procedure EmergencyA(const AMessage: AnsiString); overload;
    // хуже, о котром говорили на уровне critical уже наступило
    procedure Alert(const AFormat: string; const AArgs: array of const); overload;
    procedure AlertA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Alert(const AMessage: string); overload;
    procedure AlertA(const AMessage: AnsiString); overload;
    // если с этим ничего не сделать, то будет хуже
    procedure Critical(const AFormat: string; const AArgs: array of const); overload;
    procedure CriticalA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Critical(const AMessage: string); overload;
    procedure CriticalA(const AMessage: AnsiString); overload;
    // с этим нужо че-то делать, но можно потерпеть (недолго ;)
    procedure Error(const AFormat: string; const AArgs: array of const); overload;
    procedure ErrorA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Error(const AMessage: string); overload;
    procedure ErrorA(const AMessage: AnsiString); overload;
    // то, что таки есть смысл читать, но можно не читать, если не хочется
    procedure Warning(const AFormat: string; const AArgs: array of const); overload;
    procedure WarningA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Warning(const AMessage: string); overload;
    procedure WarningA(const AMessage: AnsiString); overload;
    // что-то пошло хорошо
    procedure Success(const AFormat: string; const AArgs: array of const); overload;
    procedure SuccessA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Success(const AMessage: string); overload;
    procedure SuccessA(const AMessage: AnsiString); overload;
    // то, что может понадобиться пользователю, но не обязательно
    procedure Notice(const AFormat: string; const AArgs: array of const); overload;
    procedure NoticeA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Notice(const AMessage: string); overload;
    procedure NoticeA(const AMessage: AnsiString); overload;
    // то, что может понадобиться техническому специалисту для
    //  локализации проблемы и написания качественого bug-report.
    procedure Info(const AFormat: string; const AArgs: array of const); overload;
    procedure InfoA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Info(const AMessage: string); overload;
    procedure InfoA(const AMessage: AnsiString); overload;
    // то что реально нужно только автору кода (или человеку который
    //  вдруг полезет в исходники что-то там править)
    procedure Debug(const AFormat: string; const AArgs: array of const); overload;
    procedure DebugA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Debug(const AMessage: string); overload;
    procedure DebugA(const AMessage: AnsiString); overload;
    //
    procedure Log(const ALevel: TLogLevel; const AFormat: string; const AArgs: array of const); overload;
    procedure LogA(const ALevel: TLogLevel; const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Log(const ALevel: TLogLevel; const AMessage: string); overload;
    procedure LogA(const ALevel: TLogLevel; const AMessage: AnsiString); overload;
    //---
    procedure SetLogger(const ALogger: ILoggerInterface);
    //---
    property LevelLimit: TLogLevel read FLevelLimit write FLevelLimit;
    property FormatFileText: string read FFormatFileText write FFormatFileText;
    property FormatFileTime: string read FFormatFileTime write FFormatFileTime;
    property FormatScreenText: string read FFormatScreenText write FFormatScreenText;
    property FormatScreenTime: string read FFormatScreenTime write FFormatScreenTime;
    property ScreenFilter: string read FScreenFilter write SetScreenFilter;
    property RichEdit: TRichEdit read FRichEdit write SetRichEdit;
    property FileName: TFileName read FFileName write FFileName;
    property SaveFile: Boolean read FSaveFile write SetSaveFile;
    property Logger: ILoggerInterface write SetLogger;
    property Prefix: string read FPrefix write FPrefix;
    property LogHistSize: Integer read FLogHistSize write FLogHistSize;
    property TrimOut: Boolean read FTrimOut write FTrimOut;
  end;

implementation

const
  MAX_BUFFER_LENGTH_ = (MAXWORD div 64);

type
  TReLog3ScreenThread = class(TThread)
  private
    FOwner: TReLog3;
    FAbort: TEvent;
    FSignal: TEvent;
    procedure DoSync;
    function IsAborted: Boolean;
    function Sleep(const A: Integer): Boolean;
    procedure DoSignal;
  protected
    procedure Execute; override;
    procedure TerminatedSet; override;
  public
    constructor Create(const AOwner: TReLog3);
  end;

{ TReLog3 }

constructor TReLog3.Create(const ARichEdit: TRichEdit;
  const AFileName: TFileName);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FItems := TQueue<TItem>.Create;
  FHist := TQueue<TItem>.Create;
  FFileName := AFileName;
  FSaveFile := True;
  FRichEdit := ARichEdit;
  FFile := nil;
  FLevelLimit := logInfo;
  FLogHistSize := MAX_BUFFER_LENGTH_;
  FLogInf := nil;

  FFormatFileText := '[%s] %s%s %s';
  FFormatFileTime := 'yyyy.mm.dd hh:nn:ss:zzz';
  FFormatScreenText := '%s%s %s';
  FFormatScreenTime := 'hh:nn:ss';
  //---
  ScreenThreadStart();
end;

constructor TReLog3.Create(const ALogger: ILoggerInterface; const APrefix: string;
  const AFileName: TFileName);
begin
  Create(nil, '');
  FLogInf := ALogger;
  FPrefix := APrefix;
  FormatScreenTime := '';
  FLogHistSize := 0;

  FFileName := Trim(AFileName);
  FSaveFile := FFileName <> '';
end;

destructor TReLog3.Destroy;
begin
  ScreenThreadStop();
  FLock.WaitFor(INFINITE);
  FRichEdit := nil;
  FLogInf := nil;
  FFileName := '';
  FLock.Free;
  FItems.Free;
  FHist.Free;
  FFile.Free;
  inherited;
end;

function TReLog3.FormatFile(const AItem: TItem): string;
var time: string;
begin
  time := FormatDateTime(FFormatFileTime, AItem.Time);
  Result := Format(FFormatFileText, [time, FPrefix, LOG_LEVEL[AItem.Level], AItem.Message])
end;

function TReLog3.FormatScreen(const AItem: TItem): string;
var time: string;
begin
  if FFormatScreenTime <> '' then
    time := FormatDateTime(FFormatScreenTime, AItem.Time)
  else
    time := '';
  Result := Format(FFormatScreenText, [time, FPrefix, AItem.Message])
end;

procedure TReLog3.TimerEvent(Sender: TObject);
const
  LOG_COLORS: array[TLogLevel] of TColor = (
    clGray, clBlack, clNavy, clGreen, clPurple, clRed, clMaroon, clMaroon, clMaroon
  );
var
  lastChar: TCharRange;
  item: TItem;
  text: string;
  l_clr, l_clrNew: TColor;

  procedure AddText;
  begin
    text := text + FormatScreen(item) + #13#10;
  end;

  procedure WriteText;
  begin
    FRichEdit.SelAttributes.Color := l_clr;
    FRichEdit.Perform(EM_REPLACESEL, 0, Longint(PChar(text)));
    text := '';
  end;

begin
  if Assigned(FRichEdit) and (FItems.Count > 0) and not FTimerPause and Assigned(FScreenThread) then
  begin
    FTimerPause := True;
    FLock.Enter;
    try
      try
      if not Assigned(FRichEdit) or not FRichEdit.HandleAllocated or (FItems.Count = 0) then
        Exit;
      ///---
      FRichEdit.Lines.BeginUpdate;
      try
        if FRichEdit.Lines.Count >= (FLogHistSize + (FLogHistSize div 2)) then
          FRichEdit.Lines.Clear;
        //---
        //raise Exception.Create('Error Message');
        lastChar.cpMin := FRichEdit.GetTextLen;
        lastChar.cpMax := lastChar.cpMin;
        FRichEdit.Perform(EM_EXSETSEL, 0, Longint(@lastChar));
        //---
        text := '';
        l_clr := clWhite;
        while FItems.Count > 0 do
        begin
          item := FItems.Dequeue;
          if (item.Level >= FLevelLimit) and (FScreenFilter.IsEmpty or (Pos(FScreenFilter, LowerCase(item.Message)) > 0)) then
          begin
            //{//$DEFINE RELOG_ADD_OLD_MODE}

            l_clrNew := item.Color;
            if l_clrNew = clWhite then
              l_clrNew := LOG_COLORS[item.Level];

            if (text = '') then
              l_clr := l_clrNew;
            {$IFDEF RELOG_ADD_OLD_MODE}
            AddText();
            WriteText();
            {$ELSE}
            if (text <> '') and (l_clr <> l_clrNew)  then
            begin
              WriteText();
              l_clr := l_clrNew
            end;
            AddText();
            {$ENDIF}
          end
        end;
        if text <> '' then
        begin
          WriteText();
        end;

      finally
        FRichEdit.Lines.EndUpdate;
      end;

      if True then //TODO: add property
        FRichEdit.Perform(EM_SCROLL, SB_PAGEDOWN, 0);

      except
        on E: Exception do
        begin
          text := Format('%s %s'#13#10'%s %s'#13#10'%s', [Self.Prefix, Self.FileName, E.ClassName, E.Message, E.StackTrace]);
          text := text + #13#10#13#10;
          text := text + Format('FRichEdit: %p'#13#10, [Pointer(FRichEdit)]);
          text := text + Format('FThread: %p'#13#10, [Pointer(FScreenThread)]);
          text := text + Format('FItems: %d'#13#10, [FItems.Count]);
          text := text + Format('FHist: %d'#13#10, [FHist.Count]);

          if FSaveFile and Assigned(FFile) then
          begin
            FFile.WriteLine(text);
          end;
          MessageBox(0, PChar(text), nil, 0);
          raise
        end
      end
    finally
      FLock.Leave;
      FTimerPause := False;
    end;
  end
end;

procedure TReLog3.CreateLogFile;
var
  fm: Word;
  fs: TStream;
  l_dir: string;
begin
  if FSaveFile and (FFileName <> '') and (not Assigned(FFile)) then
  begin
    if TFile.Exists(FFileName) then
    begin
      fm := fmOpenWrite
    end
    else
    begin
      fm := fmCreate;
      l_dir := ExtractFileDir(FFileName);
      if not l_dir.IsEmpty then
        ForceDirectories(l_dir)
    end;
    fs := TFileStream.Create(FFilename, fm or fmShareDenyWrite);
    fs.Seek(0, soEnd);
    FFile := TStreamWriter.Create(fs);
    FFile.OwnStream;
    FFile.AutoFlush := True;
  end;
end;

procedure TReLog3.WriteLog(const AMessage: string; const ALevel: TLogLevel;
  const AColor: TColor);
var
  item: TItem;
  s: string;
begin
  FLock.Enter;
  try
    s := AMessage;
    if FTrimOut then
      s := Trim(s);
    item := TItem.Create(s, ALevel, AColor);
//    item.ID := TInterlocked.Increment(FItemIdCounter);
    //---
    CreateLogFile();
    if FSaveFile and Assigned(FFile) then
      FFile.WriteLine(FormatFile(item));
    //---
    if Assigned(FLogInf) then
    begin
      FLogInf.Log(item.Level, FormatScreen(item));
    end;
    //
    if item.Level >= FLevelLimit then
    begin
      if Assigned(FRichEdit) then
        FItems.Enqueue(item);
      if FLogHistSize > 0 then
      begin
        FHist.Enqueue(item);
        while FItems.Count > FLogHistSize do
          FItems.Dequeue();
        while FHist.Count > FLogHistSize do
          FHist.Dequeue();
      end;
    end;

    if ALevel >= logSuccess then
      ScreenThreadSignal()
  finally
    FLock.Leave;
  end;
end;

procedure TReLog3.WriteLog(const AColor: TColor; const AMessage: string);
begin
  WriteLog(AMessage, TLogLevel.logInfo, AColor)
end;

procedure TReLog3.WriteLog(const ALevel: TLogLevel; const AMessage: string);
begin
  WriteLog(AMessage, ALevel, clWhite)
end;

procedure TReLog3.ScreenThreadSignal;
begin
  if Assigned(FScreenThread) then
    (FScreenThread as TReLog3ScreenThread).DoSignal()
end;

procedure TReLog3.ScreenThreadStart;
begin
  if not Assigned(FRichEdit) then
  begin
    ScreenThreadStop();
    Exit
  end;
  if Assigned(FScreenThread) then
  begin
    Exit;
  end;
  FScreenThread := TReLog3ScreenThread.Create(Self);
end;

procedure TReLog3.ScreenThreadStop;
begin
  if Assigned(FScreenThread) then
  begin
    FScreenThread.Terminate;
    FScreenThread.WaitFor;
    FreeAndNil(FScreenThread);
  end;
end;

procedure TReLog3.SetLogger(const ALogger: ILoggerInterface);
begin
  FLogInf := ALogger;
end;

procedure TReLog3.SetRichEdit(const Value: TRichEdit);
var
  l_item: TItem;
//  z: string;
begin
  //z := Format('%p'#13#10'%s'#13#10, [Pointer(Value), madStackTrace.StackTrace()]);
  //WriteLog(TLogLevel.logAlert, z);

  FLock.Enter;
  try
    FItems.Clear;
    for l_item in FHist do
      FItems.Enqueue(l_item);
    //---
    FRichEdit := Value;
    ScreenThreadStart();
  finally
    FLock.Leave
  end;
end;

procedure TReLog3.SetSaveFile(const Value: Boolean);
begin
  FSaveFile := Value;
  if (not FSaveFile) and Assigned(FFile) then
  begin
    FLock.Enter;
    try
      FFile.Free;
      FFile := nil;
    finally
      FLock.Leave
    end;
  end;
end;

procedure TReLog3.SetScreenFilter(const Value: string);
begin
  FScreenFilter := LowerCase(Value)
end;


procedure TReLog3.Log(const ALevel: TLogLevel; const AMessage: string);
begin
  WriteLog(ALevel, AMessage)
end;

procedure TReLog3.LogA(const ALevel: TLogLevel; const AMessage: AnsiString);
begin
  Log(ALevel, string(AMessage)) // cast
end;

procedure TReLog3.LogA(const ALevel: TLogLevel; const AFormat: AnsiString;
  const AArgs: array of const);
begin
  Log(ALevel, string(AFormat), AArgs) // cast
end;

procedure TReLog3.Log(const ALevel: TLogLevel; const AFormat: string;
  const AArgs: array of const);
begin
  Log(ALevel, Format(AFormat, AArgs));
end;

procedure TReLog3.Alert(const AMessage: string);
begin
  Log(logAlert, AMessage);
end;

procedure TReLog3.AlertA(const AMessage: AnsiString);
begin
  Alert(string(AMessage)) // cast
end;

procedure TReLog3.AlertA(const AFormat: AnsiString;
  const AArgs: array of const);
begin
  Alert(string(AFormat), AArgs) // cast
end;

procedure TReLog3.Alert(const AFormat: string; const AArgs: array of const);
begin
  Log(logAlert, AFormat, AArgs);
end;

procedure TReLog3.Critical(const AFormat: string; const AArgs: array of const);
begin
  Log(logCritical, AFormat, AArgs);
end;

procedure TReLog3.Critical(const AMessage: string);
begin
  Log(logCritical, AMessage);
end;

procedure TReLog3.CriticalA(const AFormat: AnsiString;
  const AArgs: array of const);
begin
  Critical(string(AFormat), AArgs) // cast
end;

procedure TReLog3.CriticalA(const AMessage: AnsiString);
begin
  Critical(string(AMessage)) // cast
end;

procedure TReLog3.Debug(const AMessage: string);
begin
  Log(logDebug, AMessage);
end;

procedure TReLog3.DebugA(const AMessage: AnsiString);
begin
  Debug(string(AMessage)) // cast
end;

procedure TReLog3.DebugA(const AFormat: AnsiString;
  const AArgs: array of const);
begin
  Debug(string(AFormat), AArgs) // cast
end;

procedure TReLog3.Debug(const AFormat: string; const AArgs: array of const);
begin
  Log(logDebug, AFormat, AArgs);
end;

procedure TReLog3.Emergency(const AMessage: string);
begin
  Log(logEmergency, AMessage);
end;

procedure TReLog3.EmergencyA(const AFormat: AnsiString;
  const AArgs: array of const);
begin
  Emergency(string(AFormat), AArgs) // cast
end;

procedure TReLog3.EmergencyA(const AMessage: AnsiString);
begin
  Emergency(string(AMessage)) // cast
end;

procedure TReLog3.Emergency(const AFormat: string; const AArgs: array of const);
begin
  Log(logEmergency, AFormat, AArgs);
end;

procedure TReLog3.Error(const AMessage: string);
begin
  Log(logError, AMessage);
end;

procedure TReLog3.ErrorA(const AFormat: AnsiString;
  const AArgs: array of const);
begin
  Error(string(AFormat), AArgs) // cast
end;

procedure TReLog3.ErrorA(const AMessage: AnsiString);
begin
  Error(string(AMessage)) // cast
end;

procedure TReLog3.Error(const AFormat: string; const AArgs: array of const);
begin
  Log(logError, AFormat, AArgs);
end;

procedure TReLog3.Info(const AFormat: string; const AArgs: array of const);
begin
  Log(logInfo, AFormat, AArgs);
end;

procedure TReLog3.Info(const AMessage: string);
begin
  Log(logInfo, AMessage);
end;

procedure TReLog3.InfoA(const AFormat: AnsiString; const AArgs: array of const);
begin
  Info(string(AFormat), AArgs) // cast
end;

procedure TReLog3.InfoA(const AMessage: AnsiString);
begin
  Info(string(AMessage)) // cast
end;

procedure TReLog3.Notice(const AMessage: string);
begin
  Log(logNotice, AMessage);
end;

procedure TReLog3.NoticeA(const AMessage: AnsiString);
begin
  Notice(string(AMessage)) // cast
end;

procedure TReLog3.NoticeA(const AFormat: AnsiString;
  const AArgs: array of const);
begin
  Notice(string(AFormat), AArgs) // cast
end;

procedure TReLog3.Success(const AFormat: string; const AArgs: array of const);
begin
  Log(logSuccess, AFormat, AArgs);
end;

procedure TReLog3.Success(const AMessage: string);
begin
  Log(logSuccess, AMessage);
end;

procedure TReLog3.SuccessA(const AFormat: AnsiString;
  const AArgs: array of const);
begin
  Success(string(AFormat), AArgs) // cast
end;

procedure TReLog3.SuccessA(const AMessage: AnsiString);
begin
  Success(string(AMessage)) // cast
end;

procedure TReLog3.Notice(const AFormat: string; const AArgs: array of const);
begin
  Log(logNotice, AFormat, AArgs);
end;

procedure TReLog3.Warning(const AMessage: string);
begin
  Log(logWarning, AMessage);
end;

procedure TReLog3.WarningA(const AFormat: AnsiString;
  const AArgs: array of const);
begin
  Warning(string(AFormat), AArgs) // cast
end;

procedure TReLog3.WarningA(const AMessage: AnsiString);
begin
  Warning(string(AMessage)) // cast
end;

procedure TReLog3.Warning(const AFormat: string; const AArgs: array of const);
begin
  Log(logWarning, AFormat, AArgs);
end;

{ TReLog3.TItem }

constructor TReLog3.TItem.Create(const AMessage: string; const ALevel: TLogLevel; const AColor: TColor);
begin
  Color := AColor;
  Level := ALevel;
  Time := Now();
  Message := AMessage;
end;

{ TReLog3ScreenThread }

constructor TReLog3ScreenThread.Create(const AOwner: TReLog3);
begin
  FOwner := AOwner;
  inherited Create(False);
  FreeOnTerminate := False;
  NameThreadForDebugging('TReLog3ScreenThread');
end;

procedure TReLog3ScreenThread.DoSignal;
begin
  if Assigned(FSignal) then
    FSignal.SetEvent()
end;

procedure TReLog3ScreenThread.DoSync;
begin
  if (not IsAborted) and Assigned(FOwner.FRichEdit) and (FOwner.FItems.Count > 0) then
    FOwner.TimerEvent(nil)
end;

function TReLog3ScreenThread.IsAborted: Boolean;
begin
  Result := Terminated or (not Assigned(FOwner)) or (FOwner.FScreenThread <> Self)
end;

function TReLog3ScreenThread.Sleep(const A: Integer): Boolean;
var
  arr: THandleObjectArray;
  fired: THandleObject;
  res: TWaitResult;
begin
  if Terminated then
    Exit(False);

  SetLength(arr, 2);
  arr[0] := FAbort;
  arr[1] := FSignal;

  res := TEvent.WaitForMultiple(arr, A, False, fired);
  if res = wrSignaled then
  begin
    if fired = FSignal then
    begin
      FSignal.ResetEvent();
      Exit(True);
    end;
    Exit(False);
  end
  else
  if res = wrTimeout then
  begin
    Exit(True);
  end;
  Exit(False);
end;

procedure TReLog3ScreenThread.Execute;
begin
  FAbort := TEvent.Create();
  FSignal := TEvent.Create;
  try
    FAbort.ResetEvent();
    FSignal.ResetEvent();

    while not IsAborted do
    begin
      if Self.Sleep(500) then
        if not IsAborted then
          Synchronize(DoSync);
    end;
  finally
    FAbort.Free;
    FSignal.Free;
  end;
end;

procedure TReLog3ScreenThread.TerminatedSet;
begin
  inherited;
  if Assigned(FAbort) then
    FAbort.SetEvent();
end;

end.
