unit uGlobalVars;

interface

{$INCLUDE jedi.inc}

{$DEFINE SET_THREAD_LOCATE_RUS}

{$IFDEF UNICODE}
  {$WARN IMPLICIT_STRING_CAST OFF}
  {$WARN IMPLICIT_STRING_CAST_LOSS OFF}
{$ENDIF}

uses
  SysUtils, Windows, {$IFDEF DELPHIXE_UP}Vcl.Graphics{$ELSE}Graphics{$ENDIF},
  uGlobalTypes;

var
  gGlobalTerminated: Boolean = False;
  gDirApp: TFileName = '';
  gDirProfile: TFileName = '';
  gDirData: TFileName = '';
  gDirDump: TFileName = '';
  gDirLog: TFileName = '';
  gStartTimeStr: string = '';

  gDirAppProfiles: TFileName = ''; // директория с профилями
  gAppProfileName: string = '';   // выбранный профиль
  gAppProfilePath: TFileName = ''; // папка с профилем
  gDirProfileLog: TFileName = '';

  gDirAppA: AnsiString = '';
  gDirProfileA: AnsiString = '';
  gDirDataA: AnsiString = '';
  gDirDumpA: AnsiString = '';
  gDirLogA: AnsiString = '';
  gStartTime: TDateTime;
  gStartTimeStrA: AnsiString = '';

procedure ApplyGlobalPaths(const ABasePath: TFileName;
  const ACreateDirs: Boolean = False);
procedure ApplyProfilePath(const ABasePath, AProfileDirName, AProfileName: TFileName;
  const ACreateDirs: Boolean = False);

implementation

uses uGlobalFunctions;

function _MakeCharsString(AChars: TSysCharSet): AnsiString;
var
  ch: AnsiChar;
  k: Integer;
begin
  SetLength(Result, 256);
  k := 0;
  for ch:=#0 to #255 do
  begin
    if ch in AChars then
    begin
      Inc(k);
      Result[k] := ch;
    end;
  end;
  SetLength(Result, k);
end;

procedure ApplyGlobalPaths(const ABasePath: TFileName; const ACreateDirs: Boolean);
var z: string;
begin
  z := ABasePath;
  if z = '' then
    z := gDirApp;
  //---
  gDirProfile := z;
  gDirData := z + 'data\';
  if gDirProfileLog <> '' then
    gDirLog := gDirProfileLog
  else
    gDirLog  := z + 'log\' + gStartTimeStr + '\';
  gDirDump := gDirLog + 'dump\';
  //---
  gDirProfileA := gDirProfile;
  gDirDataA := gDirData;
  gDirDumpA := gDirDump;
  gDirLogA  := gDirLog;
  //---
  if ACreateDirs then
  begin
    ForceDirectories(gDirProfile);
    ForceDirectories(gDirData);
    ForceDirectories(gDirLog);
    ForceDirectories(gDirDump);
  end;
end;

procedure ApplyProfilePath(const ABasePath, AProfileDirName, AProfileName: TFileName;
  const ACreateDirs: Boolean);
var z: string;
begin
  z := ABasePath;
  if z = '' then
    z := gDirApp;

  if AProfileDirName <> '' then
    gDirAppProfiles := z + AProfileDirName + '\';

  if (AProfileName <> '') and (gDirAppProfiles <> '') then
  begin
    gAppProfileName := AProfileName;
    gAppProfilePath := gDirAppProfiles + gAppProfileName + '\'
  end
  else
  begin
    gAppProfilePath := z
  end;
  gDirProfileLog := gAppProfilePath + 'log\' + gStartTimeStr + '\';
  gDirProfile := gAppProfilePath;

  uGlobalVars.ApplyGlobalPaths(gAppProfilePath, ACreateDirs);
end;

initialization
  {$IFDEF SET_THREAD_LOCATE_RUS}
  if not SetThreadLocale(1049) then
    {$IFNDEF SILENTMODE}
      ShowError(SysErrorMessage(GetLastError()));
    {$ENDIF}
  {$ENDIF}

  //---
  gStartTime := Now();
  gDirApp := ExtractFilePath(ParamStr(0));
  gStartTimeStr := GetTimeStampStr();
  //---
  gDirAppA       := gDirApp;
  gStartTimeStrA := gStartTimeStr;

end.
