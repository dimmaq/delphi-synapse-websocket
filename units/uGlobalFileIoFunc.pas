unit uGlobalFileIoFunc;

interface

uses
  //
  Windows, SysUtils, Classes, RTLConsts, SyncObjs, Types,
  {$IFDEF UNICODE}
    AnsiStrings, Masks,
  {$ENDIF}
  // Aceds
  AcedContainers, AcedStrings,
  //
  ZLibExGZ, ZLibEx,
  // My
  uGlobalTypes, uGlobalConstants, uAnsiStringList, uUniListReadWrite;

type
  TFindInDirOpt = (foFindDirs, foFindFiles, foIncFullPath,
    foRecurs, foIncFilePath);
  TFindInDirOpts = set of TFindInDirOpt;

  TLoadSaveOpt = (lsoExcept, lsoTestExists, lsoAppend, lsoClear,
    lsoByLines, lsoWriter);
  TLoadSaveOpts = set of TLoadSaveOpt;

/// <summary>
/// Открывает файл для чтения
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="ARaiseException">в случае ошибки вызвать Exception</param>
/// <returns>Handle открытого файла или INVALID_HANDLE_VALUE в случае ошибки</returns>
//function OpenFileRead(const AFileName: TFileName;
//  ARaiseException: Boolean): THandle;

/// <summary>
/// Открывает файл на запись
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="AAppend">добавлять новые данные в конец файла</param>
/// <param name="ARaiseException">в случае ошибки вызвать Exception</param>
/// <returns>Handle открытого файла или INVALID_HANDLE_VALUE в случае ошибки</returns>
function OpenFileWrite(const AFileName: TFileName; AAppend,
  ARaiseException: Boolean): THandle;

function FileWriteText(AHandle: THandle; const AText: AnsiString;
  ARaiseException: Boolean): Boolean; overload;

{$IFDEF UNICODE}
function FileWriteText(AHandle: THandle; const AText: string; AEncoding: TEncoding;
  ARaiseException: Boolean): Boolean; overload;
{$ENDIF}

function StringLoadFromFileHandle(AHandle: THandle; out AOut: AnsiString;
  ARaiseException: Boolean; const ADefault: AnsiString): DWORD;


function StringLoadFromFile(const AFileName: TFileName; out AOut: AnsiString;
  ATestFileExist, ARaiseException: Boolean; const ADefault: AnsiString): DWORD; overload;

/// <summary>
/// Загрузка файла в строку Ansi
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="ATestFileExist">проверять наличие файла</param>
/// <param name="ARaiseException">вызывать исключение в случае ошибки открытия/чтение файла</param>
/// <param name="ADefault">возвращать строку в случае неудачи</param>
/// <returns>содержимое файла в AnsiString</returns>
function StringLoadFromFile(const AFileName: TFileName;
  ATestFileExist: Boolean = False; ARaiseException: Boolean = True;
  const ADefault: AnsiString = ''): AnsiString; overload;

function StringLoadFromFile(const AFileName: TFileName;
  AOpts: TLoadSaveOpts; const ADefault: AnsiString = ''): AnsiString; overload;

/// <summary>
/// Сохранение строки в файл
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="ABuffer">буфер данных</param>
/// <param name="AAppend">добавлять данные в конец файла</param>
/// <param name="ARaiseException">при ошибке вызывать исключение</param>
/// <returns>True - если файнные записыны успешно</returns>
//TODO: добавть параметр для отклбчения ForceDirectory()
//TODO: сдеелать перегрузку с параметрами set of ()
function StringSaveToFile(const AFileName: TFileName; const ABuffer: AnsiString;
  AAppend: Boolean = False; ARaiseException: Boolean = True): Boolean; overload;

//function StringSaveToFile(const AFileName: TFileName; const ABuffer: AnsiString;
//  AOpts: TLoadSaveOpts = [lsoExcept]): Boolean; overload;

/// <summary>
/// Загрузка файла в TAnsiStrings
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="AStrings">куда загружать</param>
/// <param name="ATestFileExist">проверять наличие файла (False def)</param>
/// <param name="AAlwaysClear">очищать AStrings даже если файла нет (True def)</param>
/// <param name="AReadByLine">читать файл по строкам TextReader'ом (False def)</param>
/// <returns>возвращает AStrings</returns>
function StringsLoadFromFileA(
  const AFileName: TFileName;
  AStrings: TAnsiStrings;
  ATestFileExist: Boolean = False;
  AAlwaysClear: Boolean = True;
  AReadByLine: Boolean = False
): TAnsiStrings;  {$IFDEF UNICODE} overload; {$ENDIF}

{$IFDEF UNICODE}
/// <summary>
/// Загрузка файла в TStrings
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="AStrings">куда загружать</param>
/// <param name="ATestFileExist">проверять наличие файла (False def)</param>
/// <param name="AAlwaysClear">очищать AStrings даже если файла нет (True def)</param>
/// <param name="AReadByLine">читать файл по строкам TextReader'ом (False def)</param>
/// <returns>возвращает AStrings</returns>
function StringsLoadFromFile(
  const AFileName: TFileName;
  AStrings: TStrings;
  ATestFileExist: Boolean = False;
  AAlwaysClear: Boolean = True;
  AReadByLine: Boolean = False
): TStrings; overload;
{$ENDIF}

/// <summary>
/// Запись в файла из TStrings построчно
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="AStrings">что сохранять</param>
/// <param name="AAppend">добалять в конец файта, False - перезависать файл</param>
/// <param name="AUseTextWriter">использовать TextWriter (т.е. буфер)</param>
/// <param name="ARaiseException">в случае ошибки записи вызвать exception</param>
/// <returns>возвращает AStrings</returns>
function StringsSaveToFileA(const AFileName: TFileName; AStrings: TAnsiStrings;
  AAppend: Boolean = False; AUseTextWriter: Boolean = False;
  ARaiseException: Boolean = True): TAnsiStrings; overload;

procedure StringsSaveToFileA(const AFileName: TFileName;
  const AStrings: array of TAnsiStrings; AAppend: Boolean = False;
  AUseTextWriter: Boolean = False; ARaiseException: Boolean = True); overload;

function StringsSaveToFile(const AFileName: TFileName;
  AStrings: TStrings; {$IFDEF UNICODE}AEncoding: TEncoding;{$ENDIF}
  AAppend: Boolean = False; AUseTextWriter: Boolean = False;
  ARaiseException: Boolean = True): TStrings; overload;

procedure StringsSaveToFile(const AFileName: TFileName;
  const AStrings: array of TStrings; {$IFDEF UNICODE}AEncoding: TEncoding;{$ENDIF}
  AAppend: Boolean = False;
  AUseTextWriter: Boolean = False; ARaiseException: Boolean = True); overload;


/// <summary>
/// полный размер файла (>2ГБ)
/// </summary>
/// <param name="AFileName">Имя файла</param>
/// <returns>размер файла</returns>
function GetFileSize2(const AFileName: string): Int64;

function SafeForceDirectories(const ADirName: TFileName): Boolean;


function FindInDir(const ADirName: string; AStrings: TStrings;
  const AOpts: TFindInDirOpts = [foFindFiles];
  const AFindMask: string = '*'): Integer; overload;

function FindInDirA(const ADirName: string; AStrings: TAnsiStrings;
  const AOpts: TFindInDirOpts = [foFindFiles];
  const AFindMask: string = '*'): Integer; overload;

function FindInDir(const ADirName: string;
  const AOpts: TFindInDirOpts = [foFindFiles];
  const AFindMask: string = '*'): TStringDynArray; overload;
  
/// <summary>
/// поиск файлов\директорий
/// </summary>
/// <param name="ADirName">где искать</param>
/// <param name="AStrings">куда записывать найденное</param>
/// <param name="AFindFile">искать файлы или директории</param>
/// <param name="AFindMask">маска поиска</param>
/// <param name="AIncFullPath">записывать в AStrings полный путь к файлу</param>
/// <param name="ARecurs">рекурсивный поиск, т.е. включая поддиректории</param>
/// <param name="AIncFilePath">при AIncFullPath=False и ARecurs=True записывать найденное с поддиректориями</param>
/// <returns>кол-во найденный файлов\директорий</returns>
function FindInDir(const ADirName: string; AStrings: TStrings;
  AFindFile: Boolean = True; const AFindMask: string = '*';
  AIncFullPath: Boolean = False; ARecurs: Boolean = False;
  AIncFilePath: Boolean = False): Integer; overload;

function FindInDirA(const ADirName: string; AStrings: TAnsiStrings;
  AFindFile: Boolean = True; const AFindMask: string = '*';
  AIncFullPath: Boolean = False; ARecurs: Boolean = False;
  AIncFilePath: Boolean = False): Integer; overload;

{$IFDEF UNICODE}
/// <summary>
/// Загрузка UTF8 файла в UncodeString
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="ATestFileExist">проверять наличие файла</param>
/// <param name="ARaiseException">вызывать исключение в случае ошибки открытия/чтение файла</param>
/// <param name="ADefault">возвращать строку в случае неудачи</param>
/// <returns>содержимое файла в UncodeString</returns>
function UnicodeStringLoadFromFile(
  const AFileName: TFileName;
  ATestFileExist: Boolean = False;
  ARaiseException: Boolean = True;
  const ADefault: UnicodeString = ''
): UnicodeString; overload;

/// <summary>
/// Сохранение UnicodeString строки в файл UTF8
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="ABuffer">буфер данных</param>
/// <param name="AAppend">добавлять данные в конец файла</param>
/// <param name="ARaiseException">при ошибке вызывать исключение</param>
/// <returns>True - если файнные записыны успешно</returns>
function UnicodeStringSaveToFile(
  const AFileName: TFileName;
  const ABuffer: UnicodeString;
  AAppend: Boolean = False;
  ARaiseException: Boolean = True
): Boolean;

{$ENDIF}

function SaveStrVarDump(const ABuffer: AnsiString; ALock: TCriticalSection;
  var K: Integer): TFileName;

procedure SafeSaveStringList(const A: TStringList; const AFileName: TFileName);

function GetTempFileName(AExt: string = ''): TFileName;
{$IFNDEF UNICODE}
function GetLongPathName(lpszShortPath: LPCSTR; lpszLongPath: LPSTR;
  cchBuffer: DWORD): DWORD; stdcall;
{$ENDIF}

function DeleteAllFilesInDir(const ADirName: TFileName;
  const ARecurse, ARaiseError, ADeleteDir: Boolean): Boolean; overload;
function DeleteAllFilesInDir(const ADirName: TFileName; const AMask: string;
  const ARecurse, ARaiseError, ADeleteDir: Boolean): Boolean; overload;

implementation

uses
  uGlobalVars, uGlobalFunctions, uTextReader, uTextWriter, uDynArrays, uFindInDirHelper;

{$IFNDEF UNICODE}
function GetLongPathName; external kernel32 name 'GetLongPathNameA';
{$ENDIF}

function OpenFileReadOrWrite(const AFileName: TFileName;
  AOpenRead, AAppend, ARaiseException: Boolean): THandle;
var
  dwDesiredAccess: DWORD;
  dwCreationDisposition: DWORD;
begin
//  Result := INVALID_HANDLE_VALUE;
  if AOpenRead then
  begin
    dwDesiredAccess := GENERIC_READ;
    dwCreationDisposition := OPEN_EXISTING;
  end
  else
  begin
    dwDesiredAccess := GENERIC_WRITE;
    if AAppend then
      dwCreationDisposition := OPEN_ALWAYS
    else
      dwCreationDisposition := CREATE_ALWAYS
  end;
  //---
  SetLastError(0);
  //---
  Result := CreateFile(
    PChar(AFileName),
    dwDesiredAccess,
    FILE_SHARE_READ,
    nil,
    dwCreationDisposition,
    FILE_ATTRIBUTE_NORMAL,
    0);
  //---
  if Result <> INVALID_HANDLE_VALUE then
  begin
    if (not AOpenRead) and AAppend then
      SetFilePointer(Result, 0, nil, FILE_END);
  end
  else if ARaiseException then
  begin
    raise EFOpenError.CreateFmt(
            SFOpenErrorEx,
            [
              SysUtils.ExpandFileName(AFileName),
              SysErrorMessage(GetLastError())
            ]
          );
  end;
end;

function OpenFileRead(const AFileName: TFileName; ARaiseException: Boolean): THandle;
begin
  Result := OpenFileReadOrWrite(AFileName, True, False, ARaiseException)
end;

function OpenFileWrite(const AFileName: TFileName; AAppend, ARaiseException: Boolean): THandle;
begin
  Result := OpenFileReadOrWrite(AFileName, False, AAppend, ARaiseException)
end;

function FileWrite_(AHandle: THandle; const Buffer; Count: LongWord;
  ARaiseException: Boolean): Boolean;
begin
  Result := FileWrite(AHandle, Buffer, Count) > -1;
  if (not Result) and (ARaiseException) then
  begin
    raise EWriteError.CreateRes(@SWriteError);
  end
end;

{$IFDEF UNICODE}
function FileWriteText(AHandle: THandle; const AText: string; AEncoding: TEncoding;
  ARaiseException: Boolean): Boolean;
var
  k: Integer;
  bytes: TBytes;
begin
  k := Length(AText);
  if k > 0 then
  begin
    bytes := AEncoding.GetBytes(AText);
    Result := FileWrite_(AHandle, Pointer(bytes)^, Length(bytes), ARaiseException)
  end
  else
    Result := True
end;
{$ENDIF}

function FileWriteText(AHandle: THandle; const AText: AnsiString;
  ARaiseException: Boolean): Boolean;
var k: Integer;
begin
  k := Length(AText);
  if k > 0 then
    Result := FileWrite_(AHandle, Pointer(AText)^, Length(AText) * SizeOf(AnsiChar), ARaiseException)
  else
    Result := True
end;


function StringLoadFromFileHandle(AHandle: THandle; out AOut: AnsiString;
  ARaiseException: Boolean; const ADefault: AnsiString): DWORD;
var
  sizeFile: Cardinal;
  res: Int64;
begin
  AOut := '';
  Result := ERROR_SUCCESS;
  SetLastError(Result);
  sizeFile := GetFileSize(AHandle, nil);
  if sizeFile = 0 then
    Exit; //***
  //---
  SetLength(AOut, sizeFile);
  res := FileRead(Integer(AHandle), Pointer(AOut)^, sizeFile);
  if (res > -1) and (res = sizeFile) then
    Exit //***
  else
    if ARaiseException then
      raise EReadError.CreateRes(@SReadError);
  //---
  AOut := ADefault;
  Result := GetLastError()
end;

function StringLoadFromFile(const AFileName: TFileName; out AOut: AnsiString;
  ATestFileExist, ARaiseException: Boolean;
  const ADefault: AnsiString): DWORD;
var
  hFile: THandle;
  lasterr: DWORD;
begin
  AOut := '';
  Result := ERROR_SUCCESS;
  SetLastError(Result);
  if not ATestFileExist or FileExists(AFileName) then
  begin
    hFile := OpenFileRead(AFileName, ARaiseException);
    if hFile<>INVALID_HANDLE_VALUE then
    begin
      try
        StringLoadFromFileHandle(hFile, AOut, ARaiseException, ADefault);
        Exit;
      finally
        lasterr := GetLastError();
        CloseHandle(hFile);
        SetLastError(lasterr);
      end
    end
  end
  else
  begin
    SetLastError(ERROR_FILE_NOT_FOUND);
  end;
  //---
  AOut := ADefault;
  Result := GetLastError()
end;

function StringLoadFromFile(const AFileName: TFileName;
  ATestFileExist, ARaiseException: Boolean;
  const ADefault: AnsiString): AnsiString;
begin
  StringLoadFromFile(AFileName, Result, ATestFileExist, ARaiseException, ADefault)
end;

function StringLoadFromFile(const AFileName: TFileName;
  AOpts: TLoadSaveOpts; const ADefault: AnsiString): AnsiString;
begin
  StringLoadFromFile(AFileName, Result, lsoTestExists in AOpts,
    lsoExcept in AOpts, ADefault)
end;


function StringSaveToFile(const AFileName: TFileName; const ABuffer: AnsiString;
  AAppend, ARaiseException: Boolean): Boolean;
var hFile: THandle;
begin
  Result := False;
  if SafeForceDirectories(ExtractFileDir(AFileName)) then
  begin
    hFile := OpenFileWrite(AFileName, AAppend, ARaiseException);
    if hFile<>INVALID_HANDLE_VALUE then
    begin
      try
        Result := FileWriteText(hFile, ABuffer, ARaiseException);
      finally
        CloseHandle(hFile)
      end
    end
  end;
end;

function StringsLoadFromFileA(const AFileName: TFileName; AStrings: TAnsiStrings;
  ATestFileExist, AAlwaysClear, AReadByLine: Boolean): TAnsiStrings;
var reader: TAnsiStreamReader;
begin
  Result := AStrings;
  AStrings.BeginUpdate;
  try
    if AAlwaysClear then
      AStrings.Clear;
    //---
    if not ATestFileExist or FileExists(AFileName) then
    begin
      if AReadByLine then
      begin
        reader := TAnsiStreamReader.Create(AFileName);
        try
          if not AAlwaysClear then
            AStrings.Clear;
          reader.ReadStringsA(AStrings);
        finally
          reader.Free
        end
      end
      else
      begin
        if not AAlwaysClear then
          AStrings.Clear;
        AStrings.LoadFromFile(AFileName);
      end;
    end
  finally
    AStrings.EndUpdate
  end;
end;

{$IFDEF UNICODE}
function StringsLoadFromFile(const AFileName: TFileName; AStrings: TStrings;
  ATestFileExist, AAlwaysClear, AReadByLine: Boolean): TStrings;
var reader: TStreamReader;
begin
  Result := AStrings;
  AStrings.BeginUpdate;
  try
    if AAlwaysClear then
      AStrings.Clear;
    //---
    if not ATestFileExist or FileExists(AFileName) then
    begin
      if AReadByLine then
      begin
        reader := TStreamReader.Create(AFileName);
        try
          if not AAlwaysClear then
            AStrings.Clear;
          while not reader.EndOfStream do
            AStrings.Add(reader.ReadLine())
        finally
          reader.Free
        end
      end
      else
      begin
        if not AAlwaysClear then
          AStrings.Clear;
        AStrings.LoadFromFile(AFileName);
      end;
    end
  finally
    AStrings.EndUpdate
  end;
end;
{$ENDIF}

procedure StringsSaveToFileA(const AFileName: TFileName; const AStrings: array of TAnsiStrings;
  AAppend, AUseTextWriter, ARaiseException: Boolean);
var
  hFile: THandle;
  writer: TAnsiStreamWriter;
  i,j: Integer;
  z: AnsiString;
begin
  if AUseTextWriter then
  begin
    try
      writer := TAnsiStreamWriter.Create(AFileName, AAppend);
      try
        for i:=0 to Length(AStrings)-1 do
          writer.WriteStringsA(AStrings[i]);
      finally
        writer.Free;
      end;
    except
      on E: Exception do
      begin
        if ARaiseException or (not (E is EStreamError)) then
          raise
      end;
    end;
  end
  else
  begin
    hFile := OpenFileWrite(AFileName, AAppend, ARaiseException);
    if hFile<>INVALID_HANDLE_VALUE then
    begin
      try
        for i:=0 to Length(AStrings)-1 do
          for j := 0 to AStrings[i].Count-1 do
          begin
            z := AStrings[i].Strings[j];
            if not FileWriteText(hFile, z+CRLF, ARaiseException) then
              Exit;
          end;
      finally
        CloseHandle(hFile)
      end
    end
  end;
end;

function StringsSaveToFileA(const AFileName: TFileName; AStrings: TAnsiStrings;
  AAppend, AUseTextWriter, ARaiseException: Boolean): TAnsiStrings;
begin
  StringsSaveToFileA(AFileName, [AStrings], AAppend, AUseTextWriter, ARaiseException);
  Result := AStrings;
end;

procedure StringsSaveToFile(const AFileName: TFileName;
  const AStrings: array of TStrings; {$IFDEF UNICODE}AEncoding: TEncoding;{$ENDIF} AAppend: Boolean;
  AUseTextWriter: Boolean; ARaiseException: Boolean);
var
  hFile: THandle;
  writer: TStreamWriter;
  sl: TStrings;
  z: string;
begin
  if AUseTextWriter then
  begin
    try
      writer := TStreamWriter.Create(AFileName, AAppend{$IFDEF UNICODE}, AEncoding{$ENDIF});
      try
        for sl in AStrings do
          for z in sl do
            writer.WriteLine(z)
      finally
        writer.Free;
      end;
    except
      on E: Exception do
      begin
        if ARaiseException or (not (E is EStreamError)) then
          raise
      end;
    end;
  end
  else
  begin
    hFile := OpenFileWrite(AFileName, AAppend, ARaiseException);
    if hFile <> INVALID_HANDLE_VALUE then
    begin
      try
        for sl in AStrings do
          for z in sl do
          begin
            if not FileWriteText(hFile, z + CRLF{$IFDEF UNICODE}, AEncoding{$ENDIF}, ARaiseException) then
              Exit;
          end;
      finally
        CloseHandle(hFile)
      end
    end
  end
end;

function StringsSaveToFile(const AFileName: TFileName; AStrings: TStrings;
  {$IFDEF UNICODE}AEncoding: TEncoding;{$ENDIF}
  AAppend: Boolean; AUseTextWriter: Boolean; ARaiseException: Boolean): TStrings;
begin
  StringsSaveToFile(AFileName, [AStrings] {$IFDEF UNICODE}, AEncoding{$ENDIF}, AAppend, AUseTextWriter, ARaiseException);
  Result := AStrings;
end;



function GetFileSize2(const AFileName: string): Int64;
var
  d : TWin32FindData;
  h : hwnd;
begin
  Result := 0;
  h := FindFirstFile(PChar(AFileName), d);
  if (h<>INVALID_HANDLE_VALUE) then
  begin
    Result := d.nFileSizeLow or Int64(d.nFileSizeHigh) shl 32;
    Windows.FindClose(h);
  end;
end;

{$IFDEF UNICODE}
function UnicodeStringLoadFromFile(const AFileName: TFileName;
  ATestFileExist, ARaiseException: Boolean;
  const ADefault: UnicodeString): UnicodeString;
var F: TStreamReader;
begin
  Result := '';
  if not ATestFileExist or FileExists(AFileName) then
  begin
    try
      F := TStreamReader.Create(AFileName, TEncoding.UTF8);
      try
        Result := F.ReadToEnd();
        Exit;
      finally
        F.Free;
      end;
    except
      on E: Exception do
      begin
        if ARaiseException or (not (E is EStreamError)) then
          raise
      end;
    end;
  end;
  //---
  Result := ADefault;
end;

function UnicodeStringSaveToFile(const AFileName: TFileName;
  const ABuffer: UnicodeString; AAppend, ARaiseException: Boolean): Boolean;
var F: TStreamWriter;
begin
  Result := False;
  if SafeForceDirectories(ExtractFileDir(AFileName)) then
  begin
    try
      F := TStreamWriter.Create(AFileName, False, TEncoding.UTF8);
      try
        F.Write(ABuffer);
        Result := True;
      finally
        F.Free;
      end;
    except
      on E: Exception do
      begin
        if ARaiseException or (not (E is EStreamError)) then
          raise
      end;
    end;
  end;
end;

{$ENDIF}


function _FindInDir(const ADirName, ASubDir: string; AResult: IFindInDirResult;
  const AOpts: TFindInDirOpts; const AFindMask: string): Integer;
var
  ssr : TSearchRec;
  mask: string;
  opts: TFindInDirOpts;
//  {$IFDEF UNICODE}
//  MaskCheckObj: Masks.TMask;
//  {$ENDIF}

  procedure _Add(const AStr: string);
  begin
    AResult.Add(AStr)
  end;

//  function _MatchesMask(const AFileName: string): Boolean;
//  begin
//    {$IFDEF UNICODE}
//      Result := MaskCheckObj.Matches(AFileName);
//    {$ELSE}
//      Result := G_ValidateWildText(AFileName, AFindMask);
//    {$ENDIF}
//  end;

begin
  Result := 0;
  //---
  opts := AOpts;
  if not (foFindDirs in opts) then
    opts := opts + [foFindFiles];
  //---
  if AFindMask = '' then
    mask := '*'
  else
  if AFindMask = '*.*' then
    mask := '*'
  else
    mask := AFindMask;
  //---
//  {$IFDEF UNICODE}
//  MaskCheckObj := nil;
//  {$ENDIF}
  //---
  if FindFirst(ADirName + ASubDir + mask, faAnyFile, ssr)=0 then
  try
//    {$IFDEF UNICODE}
//      MaskCheckObj := Masks.TMask.Create(AFindMask);
//    {$ENDIF}
    //---
    repeat
      if (ssr.Name<>'..') and (ssr.Name<>'.') then
      begin
        if ((foFindFiles in opts) and ((ssr.Attr and faDirectory)=0)) or
           ((foFindDirs in opts) and (((ssr.Attr and faDirectory)<>0))) then
        begin
          //if _MatchesMask(ssr.Name) then
          begin
            Inc(Result);
            if foIncFullPath in opts then
              _Add(ADirName+ASubDir+ssr.Name)
            else
              if foIncFilePath in opts then
                _Add(ASubDir+ssr.Name)
              else
                _Add(ssr.Name)
          end;
        end;
        if (foRecurs in opts) and ((ssr.Attr and faDirectory)<>0) then
          Result := Result +
            _FindInDir(ADirName, ASubDir+ssr.Name+'\', AResult, opts, mask)
      end;
    until FindNext(ssr)<>0;
  finally
    SysUtils.FindClose(ssr);
//    {$IFDEF UNICODE}
//      FreeAndNil(MaskCheckObj);
//    {$ENDIF}
  end;
end;

function FindInDirA(const ADirName: string; AStrings: TAnsiStrings;
  AFindFile: Boolean; const AFindMask: string;
  AIncFullPath, ARecurs, AIncFilePath: Boolean): Integer;
var lOpts: TFindInDirOpts;
begin
  lOpts := [];
  if AFindFile then lOpts := lOpts + [foFindFiles]
    else lOpts := lOpts + [foFindDirs];
  if AIncFullPath then lOpts := lOpts + [foIncFullPath];
  if ARecurs then lOpts := lOpts + [foRecurs];
  if AIncFilePath then lOpts := lOpts + [foIncFilePath];

  Result := _FindInDir(
    SysUtils.IncludeTrailingPathDelimiter(ADirName),
    '',
    TFindInDirResultAnsiStrings.Create(AStrings),
    lOpts,
    AFindMask
  );
end;

function FindInDir(const ADirName: string; AStrings: TStrings;
  AFindFile: Boolean; const AFindMask: string;
  AIncFullPath, ARecurs, AIncFilePath: Boolean): Integer;
var lOpts: TFindInDirOpts;
begin
  lOpts := [];
  if AFindFile then lOpts := lOpts + [foFindFiles]
    else lOpts := lOpts + [foFindDirs];
  if AIncFullPath then lOpts := lOpts + [foIncFullPath];
  if ARecurs then lOpts := lOpts + [foRecurs];
  if AIncFilePath then lOpts := lOpts + [foIncFilePath];
  Result := _FindInDir(
    SysUtils.IncludeTrailingPathDelimiter(ADirName),
    '',
    TFindInDirResultStrings.Create(AStrings),
    lOpts,
    AFindMask
  );
end;

function FindInDir(const ADirName: string; AStrings: TStrings;
  const AOpts: TFindInDirOpts; const AFindMask: string): Integer;
begin
  Result := _FindInDir(
    SysUtils.IncludeTrailingPathDelimiter(ADirName),
    '',
    TFindInDirResultStrings.Create(AStrings),
    AOpts,
    AFindMask
  );
end;

function FindInDirA(const ADirName: string; AStrings: TAnsiStrings;
  const AOpts: TFindInDirOpts; const AFindMask: string): Integer;
begin
  Result := _FindInDir(
    SysUtils.IncludeTrailingPathDelimiter(ADirName),
    '',
    TFindInDirResultAnsiStrings.Create(AStrings),
    AOpts,
    AFindMask
  );
end;

function FindInDir(const ADirName: string;
  const AOpts: TFindInDirOpts;
  const AFindMask: string): TStringDynArray;
begin
  SetLength(Result, 0);
  _FindInDir(
    SysUtils.IncludeTrailingPathDelimiter(ADirName),
    '',
    TFindInDirResultStringDynArray.Create(@Result),
    AOpts,
    AFindMask
  )
end;


function SafeForceDirectories(const ADirName: TFileName): Boolean;
var
  Dir: TFileName;
  err: DWORD;
  res: Boolean;
begin
  if ADirName='' then
  begin
    Result := True;
    Exit;
  end;    
  Result := False;
  Dir := ExcludeTrailingPathDelimiter(ADirName);
  if Length(Dir)>=2 then
  begin
    if DirectoryExists(Dir) then
    begin
      Result := True;
      Exit;
    end;
    if SafeForceDirectories(ExtractFileDir(Dir)) then
    begin
      SetLastError(0);
      res := CreateDir(dir);
      err := GetLastError();
      Result := res or (err=ERROR_ALREADY_EXISTS)
    end;
  end;
end;

function SaveStrVarDump(const ABuffer: AnsiString; ALock: TCriticalSection;
  var K: Integer): TFileName;
begin
  ALock.Enter;
  try
    Inc(K);
    Result := gDirLog + IntToStr(K) + '_' + GetTimeStampStr() + '.txt';
    StringSaveToFile(Result, ABuffer, False, False);
  finally
    ALock.Leave;
  end;
end;


procedure SafeSaveStringList(const A: TStringList; const AFileName: TFileName);
var l_bak: TFileName;
begin
  l_bak := AFileName + '.bak';
  MoveFileEx(PChar(AFileName), PChar(l_bak), MOVEFILE_REPLACE_EXISTING);
  A.SaveToFile(AFileName{$IFDEF UNICODE}, TEncoding.UTF8{$ENDIF});
end;

function GetTempPath: string;
var
  Len: Integer;
begin
  SetLastError(ERROR_SUCCESS);

  // get memory for the buffer retaining the temp path (plus null-termination)
  SetLength(Result, MAX_PATH);
  Len := Windows.GetTempPath(MAX_PATH, PChar(Result));
  if Len <> 0 then
  begin
    Len := GetLongPathName(PChar(Result), nil, 0);
    GetLongPathName(PChar(Result), PChar(Result), Len);
    SetLength(Result, Len - 1);
  end
  else
    Result := '';
end;


function GetTempFileName(AExt: string): TFileName;
var
  TempPath: string;
  ErrCode: UINT;
begin
  TempPath := GetTempPath;
  SetLength(Result, MAX_PATH);

  SetLastError(ERROR_SUCCESS);
  ErrCode := Windows.GetTempFileName(PChar(TempPath), 'googletmp', 0, PChar(Result)); // DO NOT LOCALIZE
  if ErrCode = 0 then
    raise EInOutError.Create(SysErrorMessage(GetLastError));

  SetLength(Result, StrLen(PChar(Result)));

  Result := Result + AExt;
end;

function DeleteAllFilesInDir(const ADirName: TFileName; const AMask: string;
  const ARecurse, ARaiseError, ADeleteDir: Boolean): Boolean;
var
  sr : TSearchRec;
  dir: TFileName;
  res: Integer;
begin
  if (Length(ADirName) < 4) or (ADirName[1] = '.') or (ADirName[1] = '\') then
  begin
    Result := False;
    Exit
  end;
  Result := True;
  dir := IncludeTrailingPathDelimiter(ADirName);
  res := FindFirst(dir + AMask, faAnyFile, sr);
  if res <> 0 then
  begin
    if (res = ERROR_FILE_NOT_FOUND) or (res = ERROR_PATH_NOT_FOUND) then
    begin
      Result := True;
      Exit;
    end;
    if ARaiseError then
      RaiseLastOSError();
    Result := False;
    Exit;
  end;
  try
    repeat
      if (sr.Name<>'..') and (sr.Name<>'.') then
      begin
        if (sr.Attr and faDirectory) <> 0 then
        begin
          if ARecurse then
          begin
            if not DeleteAllFilesInDir(dir + sr.Name, ARecurse, ARaiseError, True) then
              Result := False
          end
          else
          begin
            Result := False
          end;
        end
        else
        begin
          if not DeleteFile(dir + sr.Name) then
          begin
            if ARaiseError then
              RaiseLastOSError();
            Result := False
          end
        end
      end;

      res := FindNext(sr);
      if res <> 0 then
      begin
        if ERROR_NO_MORE_FILES = res then
          Break
        else
        if ARaiseError then
          RaiseLastOSError();
        Result := False;
        Exit;
      end;
    until False;

    if ADeleteDir and not RemoveDir(dir) then
    begin
      if ARaiseError then
        RaiseLastOSError();
      Result := False;
    end;
  finally
    SysUtils.FindClose(sr);
  end;
end;

function DeleteAllFilesInDir(const ADirName: TFileName;
  const ARecurse, ARaiseError, ADeleteDir: Boolean): Boolean;
begin
  Result := DeleteAllFilesInDir(ADirName, '*', ARecurse, ARaiseError, ADeleteDir)
end;

end.


