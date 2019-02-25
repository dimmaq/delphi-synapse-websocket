unit uGlobalFunctions;

interface

uses
  Windows, SysUtils, Classes, RTLConsts, Math,
  {$IFDEF UNICODE}AnsiStrings, Masks,{$ENDIF}
  //
  uGlobalTypes,
  uAnsiStringList
  ;

function TStringList_Create(
  const ASort: Boolean = False;
  const ACaseSens: Boolean = False;
  const ADup: TDuplicates = dupIgnore;
  const AText: string = ''): TStringList;

function TAnsiStringList_Create(
  const ASort: Boolean = False;
  const ACaseSens: Boolean = False;
  const ADup: TDuplicates = dupIgnore;
  const AText: AnsiString = ''): TAnsiStringList;
function TAnsiStringListSimple_Create(
  const ASort: Boolean = False;
  const ACaseSens: Boolean = False;
  const ADup: TDuplicates = dupIgnore;
  const AText: AnsiString = ''): TAnsiStringListSimple;

procedure TStringList_Extract(A, B: TStringList);


function GetTimeStampStr: string;


/// <summary>
/// Перемешивает TStrings
/// </summary>
function RandomStrings(const A: TStrings): TStrings;
function RandomStringsA(const A: TAnsiStrings): TAnsiStrings;
function StringsReverse(AStrings: TStrings): TStrings;


/// <summary>
/// Экранирует спец. символы для JSON
/// </summary>
function JsonStringSafe(const AStr: RawByteString): RawByteString;{$IFDEF UNICODE} overload;{$ENDIF}
{$IFDEF UNICODE}
function JsonStringSafe(const AStr: UnicodeString): UnicodeString; overload;
function unescapeJsonString(const A: RawByteString; AIgnoreU: Boolean): RawByteString;
{$ENDIF}


//---

//---
// *** Разное ***
function IfElse(B: Boolean; const IfTrue: AnsiString;
  const IfFalse: AnsiString = ''): AnsiString; overload; inline;
{$IFDEF UNICODE}
function IfElse(B: Boolean; const IfTrue: UnicodeString;
  const IfFalse: UnicodeString = ''): UnicodeString; overload; inline;
{$ENDIF}
function IfElse(B: Boolean; IfTrue,IfFalse: Byte): Byte; overload; inline;
function IfElse(B: Boolean; IfTrue,IfFalse: Integer): Integer; overload; inline;
function IfElse(B: Boolean; IfTrue,IfFalse: Double): Double; overload; inline;
function IfElse(B: Boolean; IfTrue,IfFalse: Pointer): Pointer; overload; inline;
function IfElse(B: Boolean; IfTrue,IfFalse: TObject): TObject; overload; inline;
function IfElse(B: Boolean; IfTrue,IfFalse: AnsiChar): AnsiChar; overload; inline;
{$IFDEF UNICODE}
function IfElse(B: Boolean; IfTrue,IfFalse: Char): Char; overload; inline;
{$ENDIF}


/// <summary>
/// Если A не пустое, возврашает его,
///  в противном случае возвращает B
/// </summary>

{$IFDEF UNICODE}
  function IfEmpty(const A, B: AnsiString): AnsiString; overload;
{$ENDIF}
function IfEmpty(const A, B: string): string; overload;
function IfEmpty(const A, B: Integer): Integer; overload;
function IfEmpty(const A, B: Int64): Int64; overload;

procedure GetMemoryInfo(AStrings: TStrings);
function IntToBin(Value: LongWord): AnsiString;
Function IntToStr2(AInt, ALen: Integer): string;
Function IntToAnsiStr2(AInt, ALen: Integer): AnsiString;
function BoolToStr2(const AValue: Boolean; const AUseStr: Boolean = False): ShortString;
{$IFDEF UNICODE}
function frmCur(const A: Integer; IsCent: Boolean = False): string;
{$ENDIF}
function Tick2Text(k: Int64): string;
procedure ShowInformation(const AText: string;
  const ACaption: string = 'Information');
function ShowError(const AText: string;
  const AFlags: Integer = MB_OK or MB_ICONERROR): Integer;
function ShowErrorQuestion(const AText: string;
  const AFlags: Integer = MB_YESNO or MB_DEFBUTTON2): Integer;
function ShowQuestion(const AText: string; AFlags: Integer = MB_YESNO): Integer;
function GetTmpFileName(const APrefix: string = '';
  const APostfix: string = '';
  const AExt: string = ''): string;
//---

function HtmlSpecCharsDecode(const AText: AnsiString): AnsiString;
procedure HtmlTagsDelete(var AText: AnsiString);
function HtmlTagsDelete2(const AText: AnsiString): AnsiString;
function GZipEncode(var ABuffer: RawByteString): Boolean; overload;
function GZipEncode(var ABuffer: AnsiString): Boolean; overload;
function IsGZipData(const AData: AnsiString): Boolean;

function _ReplaceCRLF(const AText: string): string;
function ExceptionMessage(const E: Exception): string;

// кодирование строки в base64 блоками по 57 символов (на выходе 56*4/3==76)
function Base64Encode(const ASourceText: AnsiString): AnsiString;
function Base64Encode2(const ASourceText: AnsiString; AAppendEnd: Boolean = True;
  ASplitLen: Integer = 76; ASplitStr: AnsiString = #13#10): AnsiString;
// форматированный base64 в текст
function Base64Decode(const ABase64Text: AnsiString): AnsiString;
function QPEncode(const ASourceText: AnsiString): AnsiString;
function QPDecode(const AQPText: AnsiString): AnsiString;

{$IFNDEF UNICODE}
function UTF8ToString(const S: UTF8String): string;
{$ENDIF}

function ChangeFileName(const AFileName: TFileName;
  const APrefix, APostfix: string): TFileName;

function NextIndex(var A: Integer; Max: Integer): Integer;
function TestRange(A, AMin, AMax: Integer): Integer;



procedure RawSetUtf8(var S: RawByteString);
procedure RawSetBin(var S: RawByteString);
function RawAsUtf8(const S: RawByteString): UTF8String;
function RawAsBin(const S: RawByteString): RawByteString;

implementation

uses
  SysConst,
  //
  ZLibExGZ, ZLibEx,
  //
  AcedContainers, AcedStrings, AcedCommon,
  //
  uGlobalVars, uGlobalConstants, uStringUtils;

var
  _iTmpFile : Integer = 1;

function TStringList_Create(const ASort, ACaseSens: Boolean;
  const ADup: TDuplicates; const AText: string): TStringList;
begin
  Result := TStringList.Create;
  Result.Duplicates := ADup;
  Result.CaseSensitive := ACaseSens;
  Result.Sorted := ASort;
  Result.Text := AText;
end;

function TAnsiStringList_Create(const ASort, ACaseSens: Boolean;
  const ADup: TDuplicates; const AText: AnsiString): TAnsiStringList;
begin
  Result := TAnsiStringList.Create;
  Result.Duplicates := ADup;
  Result.CaseSensitive := ACaseSens;
  Result.Sorted := ASort;
  Result.Text := AText;
end;

function TAnsiStringListSimple_Create(const ASort, ACaseSens: Boolean;
  const ADup: TDuplicates; const AText: AnsiString): TAnsiStringListSimple;
begin
  Result := TAnsiStringListSimple.Create;
  Result.Duplicates := ADup;
  Result.CaseSensitive := ACaseSens;
  Result.Sorted := ASort;
  Result.Text := AText;
end;

procedure TStringList_Remove(A: TStringList; const S: string);
var i: Integer;
begin
  i := A.IndexOf(S);
  if i <> -1 then
    A.Delete(i);
end;

// удалить из A строки В
procedure TStringList_Extract(A, B: TStringList);
var z: string;
begin
  for z in B do
    TStringList_Remove(A, z);
end;


//------------------------------------------------------------------------------
// *** Строковые ф-ции ***

function GetTimeStampStr: string;
begin
  Sleep(1);
  Result := FormatDateTime('yyyy-mm-dd-hh-nn-ss-zzz', Now())
end;


function RandomStrings(const A: TStrings): TStrings;
var
  r,l,j: Integer;
  s: string;
  o: TObject;
begin
  Result := A;
  Randomize;
  l := A.Count;
  for j := 0 to l - 1 do
  begin
    r := Random(l);
    //---
    s := A[r];
    o := A.Objects[r];
    //---
    A[r] := A[j];
    A.Objects[r] := A.Objects[j];
    //---
    A[j] := s;
    A.Objects[j] := o;
  end;
end;

function RandomStringsA(const A: TAnsiStrings): TAnsiStrings;
var
  r,l,j: Integer;
  s: AnsiString;
  o: TObject;
begin
  Result := A;
  Randomize;
  l := A.Count;
  for j := 0 to l - 1 do
  begin
    r := Random(l);
    //---
    s := A[r];
    o := A.Objects[r];
    //---
    A[r] := A[j];
    A.Objects[r] := A.Objects[j];
    //---
    A[j] := s;
    A.Objects[j] := o;
  end;
end;

function StringsReverse(AStrings: TStrings): TStrings;
var
  n,k: Integer;
  S: string;
begin
  AStrings.BeginUpdate;
  try
    n := 0;
    k := AStrings.Count - 1;
    while n < k do
    begin
      S := AStrings[n];
      AStrings[n] := AStrings[k];
      AStrings[k] := S;
      Inc(n);
      Dec(k)
    end;
  finally
    AStrings.EndUpdate;
  end;
  Result := AStrings;
end;



function JsonStringSafe(const AStr: RawByteString): RawByteString;
type
  TUnsafeJsonCharRec = record
    c: AnsiChar;
    s: string[2];
  end;
const
  UnSafeJsonChar: array[0..5] of TUnsafeJsonCharRec = (
    (c:'\'; s:'\\'), (c:'"'; s:'\"'), (c:#9; s:'\t'),
    (c:#10; s:'\n'), (c:#12; s:'\f'), (c:#13; s:'\r')
  );
var j: Integer;
begin
  Result := AStr;
  for j:=Low(UnSafeJsonChar) to High(UnSafeJsonChar) do
    Result := G_ReplaceStr(Result, UnSafeJsonChar[j].c, UnSafeJsonChar[j].s);
end;

{$IFDEF UNICODE}
function JsonStringSafe(const AStr: UnicodeString): UnicodeString;
type
  TUnsafeJsonCharRec = record
    c: Char;
    s: UnicodeString;
  end;
const
  UnSafeJsonChar: array[0..5] of TUnsafeJsonCharRec = (
    (c:'\'; s:'\\'), (c:'"'; s:'\"'), (c:#9; s:'\t'),
    (c:#10; s:'\n'), (c:#12; s:'\f'), (c:#13; s:'\r')
  );
var j: Integer;
begin
  Result := AStr;
  for j:=Low(UnSafeJsonChar) to High(UnSafeJsonChar) do
    Result := SysUtils.StringReplace(Result, UnSafeJsonChar[j].c, UnSafeJsonChar[j].s, [rfReplaceAll]);
end;


function unescapeJsonString(const A: RawByteString; AIgnoreU: Boolean): RawByteString;
var
  j,l,k,b: Integer;
  hex: string;
  ch: AnsiChar;

  procedure addChar; overload;
  begin
    Inc(k);
    Result[k] := ch;
  end;
  procedure addChar(C: AnsiChar); overload;
  begin
    Inc(k);
    Result[k] := C;
  end;
  procedure addUChar(C: Char);
  var r: RawByteString;
  i: Integer;
  begin
    r := UTF8Encode(C);
    for i := 1 to Length(r) do
    begin
      Inc(k);
      Result[k] := r[i];
    end;
  end;


begin
  j := 1;
  l := Length(A);
  k := 0;
  SetLength(Result, l);
  while j <= l do
  begin
    ch := A[j];
    if ch = '\' then
    begin
      Inc(j);
      ch := A[j];
      case ch of
        '"': addChar();
        '\': addChar();
        '/': addChar();
        'b': addChar(#08); // backspace
        'f': addChar(#12); // formfeed
        'n': addChar(#10); // newline
        'r': addChar(#13); //carriage return
        't': addChar(#09); // tab
        'u':
          begin
            if AIgnoreU then
            begin
              addChar('\');
              addChar();
              Inc(j); ch := A[j]; addChar();
              Inc(j); ch := A[j]; addChar();
              Inc(j); ch := A[j]; addChar();
            end
            else
            begin
              Inc(j);
              hex := string('$' + Copy(A, j, 4));
              if TryStrToInt(hex, b) then
              begin
                Inc(j, 3);
                addUChar(Char(b));
              end
              else
              begin
                raise Exception.Create('Invalid Unicode found: ' + hex)
              end
            end
          end
      else
        raise Exception.Create('Invalid escape character inside');
      end;
    end
    else
    begin
      addChar();
    end;
    Inc(j);
  end;
  SetLength(Result, k);
end;


{$ENDIF}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
// *** Разное ***

function IfElse(B: Boolean; const IfTrue,IfFalse: AnsiString): AnsiString;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
end;

{$IFDEF UNICODE}
function IfElse(B: Boolean; const IfTrue: UnicodeString;
  const IfFalse: UnicodeString = ''): UnicodeString; overload;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
end;
{$ENDIF}

function IfElse(B: Boolean; IfTrue,IfFalse: Byte): Byte;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
end;

function IfElse(B: Boolean; IfTrue,IfFalse: Integer): Integer;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
end;

function IfElse(B: Boolean; IfTrue,IfFalse: Double): Double;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
end;

function IfElse(B: Boolean; IfTrue,IfFalse: Pointer): Pointer;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
end;

function IfElse(B: Boolean; IfTrue,IfFalse: TObject): TObject;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
end;

function IfElse(B: Boolean; IfTrue,IfFalse: AnsiChar): AnsiChar;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
end;
{$IFDEF UNICODE}
function IfElse(B: Boolean; IfTrue,IfFalse: Char): Char;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
end;
{$ENDIF}


{$IFDEF UNICODE}
function IfEmpty(const A, B: AnsiString): AnsiString;
begin
  if A <> '' then
    Result := A
  else
    Result := B
end;
{$ENDIF}

function IfEmpty(const A, B: string): string;
begin
  if A <> '' then
    Result := A
  else
    Result := B
end;

function IfEmpty(const A, B: Integer): Integer;
begin
  if A <> 0 then
    Result := A
  else
    Result := B
end;

function IfEmpty(const A, B: Int64): Int64;
begin
  if A <> 0 then
    Result := A
  else
    Result := B
end;

procedure GetMemoryInfo(AStrings: TStrings);

  function FormatBytesSize(ABytes: Int64): string;
  var
    s : String;
    b : Extended;
  begin
    b := ABytes;
    if (b < 1024 - 200) then
    begin
      b := b;
      s := 'B';
    end
    else
      if (b < 1024 * (1024 - 200)) then
      begin
        b := b / 1024;
        s := 'kB';
      end
      else
        if (b < 1024 * 1024 * (1024 - 200)) then
        begin
          b := b / (1024 * 1024);
          s := 'MB';
        end
        else
        begin
          b := b / (1024 * 1024 * 1024);
          s := 'GB';
        end;

    Result := SysUtils.FormatFloat('###,###,##0.#', b) + ' ' + s + ' (' + SysUtils.IntToStr(ABytes) + ' B)';
  end;


var
 mem_status : TMemoryStatus;
 free_block_list : TIntegerList;
 base_addr : PByte;
 mem_info : TMemoryBasicInformation;
 res : DWORD;
 j,k : Integer;
begin
  mem_status.dwLength := SizeOf(mem_status);
  GlobalMemoryStatus(mem_status);
  //---
  with mem_status, AStrings do
  begin
    Add('Available Physical Memory = ' + FormatBytesSize(dwAvailPhys));
    Add('Total Physical Memory = ' + FormatBytesSize(dwTotalPhys));
    Add('Available Virtual Memory = ' + FormatBytesSize(dwAvailVirtual));
    Add('Total Virtual Memory = ' + FormatBytesSize(dwTotalVirtual));
  end;
  free_block_list := TIntegerList.Create(16);
  try
    free_block_list.MaintainSorted := True;
    //---
    ZeroMemory(@mem_info, SizeOf(mem_info));
    base_addr := nil;
    res := VirtualQuery(base_addr, mem_info, sizeof(mem_info));
    while res = sizeof(mem_info) do
    begin
      if mem_info.State=MEM_FREE then
      begin
        free_block_list.Add(mem_info.RegionSize);
      end;
      Inc(base_addr, mem_info.RegionSize);
      res := VirtualQuery(base_addr, mem_info, sizeof(mem_info));
    end;
    k := 1;
    for j:=(free_block_list.Count-1) downto 0 do
    begin
      with AStrings do
      begin
        Add('Largest Free Block #' + SysUtils.IntToStr(k) + ' = ' + FormatBytesSize(Cardinal(free_block_list[j])));
      end;
      //---
      if k>=3 then
        Break;
      Inc(k);
    end;
  finally
    free_block_list.Free;
  end;

end;

function IntToBin(Value: LongWord): AnsiString;
var i: Integer;
begin
  SetLength(Result, 32);
  for i := 1 to 32 do begin
    if ((Value shl (i-1)) shr 31) = 0 then begin
      Result[i] := '0'  {do not localize}
    end else begin
      Result[i] := '1'; {do not localize}
    end;
  end;
end;

Function IntToAnsiStr2(AInt, ALen: Integer): AnsiString;
begin
  Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('%.*d', [ALen, AInt])
end;

Function IntToStr2(AInt, ALen: Integer): string;
begin
  Result := SysUtils.Format('%.*d', [ALen, AInt])
end;


function BoolToStr2(const AValue: Boolean; const AUseStr: Boolean): ShortString;
const
  cBoolStrs: array[Boolean] of array[Boolean] of ShortString = (
    ('0', '1'),
    ('False', 'True')
  );
begin
  Result := cBoolStrs[AUseStr][AValue];
end;

function Tick2Text(k: Int64): string;
var h,m,s,l:Int64;
begin
  if k>0 then
  begin
    l := Round(k/1000);
    h := l div 3600;
    m := (l - h*3600) div 60;
    s := l - h*3600 - m*60;
    Result := '';
    if h<>0 then
      Result := SysUtils.IntToStr(h)+' час '+SysUtils.IntToStr(m)+' мин '
    else if m<>0 then
      Result := SysUtils.IntToStr(m)+' мин ';
    Result := Result + SysUtils.IntToStr(s) + ' сек';
  end
  else
  begin
    Result := '';
  end;
end;

{$IFDEF UNICODE}
function frmCur(const A: Integer; IsCent: Boolean): string;
var
  d,m: Integer;
  cent: string;
  function _m: string;
  begin
    Result := IntToStr(m);
    if d > 0 then
    begin
      if m < 10 then
        Result := '00' + Result
      else
      if m < 100 then
        Result := '0' + Result
    end;
  end;

begin
  Result := '';
  cent := '';
  d := Abs(A);
  if IsCent then
  begin
    m := d mod 100;
    d := d div 100;
    cent := IntToStr(m);
    if m < 10 then
      cent := '0' + cent;
  end;
  repeat
    m := d mod 1000;
    d := d div 1000;
    if Result = '' then
      Result := _m
    else
      Result := _m + '''' + Result;
  until d = 0;
  if Result = '' then
    Result := '0';
  if IsCent then
    Result := Result + '.' + cent;

  if A < 0 then
    Result := '-' + Result;
end;
{$ENDIF}


procedure ShowInformation(const AText, ACaption: string);
begin
  Windows.MessageBox(GetActiveWindow(), PChar(AText), PChar(ACaption), MB_OK or MB_ICONINFORMATION);
end;

function ShowError(const AText: string; const AFlags: Integer): Integer;
begin
  Result := Windows.MessageBox(GetActiveWindow(), PChar(AText), 'Error', AFlags)
end;

function ShowErrorQuestion(const AText: string; const AFlags: Integer): Integer;
begin
  Result := ShowError(AText, AFlags)
end;

function ShowQuestion(const AText: string; AFlags: Integer): Integer;
begin
  Result := Windows.MessageBox(GetActiveWindow(), PChar(AText), 'Question', AFlags)
end;


function GetTmpFileName(const APrefix, APostfix, AExt: string): string;
begin
  Result := APrefix + SysUtils.IntToStr(InterlockedIncrement(_iTmpFile)) + APostfix + AExt
end;

function HtmlSpecCharsDecode(const AText: AnsiString):AnsiString;
type
  TSpecStrRec = record
    a: string[6];
    b: string[1];
  end;
const
  SpecStrArray: array[0..5] of TSpecStrRec = (
    (a:'&apos;'; b:''''),
    (a:'&#039;'; b:''''),
    (a:'&quot;'; b:'"'),
    (a:'&gt;';   b:'>'),
    (a:'&lt;';   b:'<'),
    (a:'&amp;';  b:'&')
  );
var
  A: TSpecStrRec;
  j: Integer;
begin
  Result := AText;
  for j:=Low(SpecStrArray) to High(SpecStrArray) do
  begin
    A := SpecStrArray[j];
    Result := G_ReplaceStr(Result, A.a, A.b);
  end;
end;

procedure HtmlTagsDelete(var AText: AnsiString);
const
  not_tag_char = [#0..#255] - gCharsEng;
  block_tag : array[0..3] of AnsiString = (
    'table',
    'div',
    'p',
    'li'
  );

  function _is_block_tag(const AText: AnsiString): Boolean;
  var j: Integer;
  begin
    Result := False;
    for j:=Low(block_tag) to High(block_tag) do
      if G_CompareStr(block_tag[j], AText)=0 then
      begin
        Result := True;
        Exit;
      end
  end;

var
  n,k,l,p : Integer;
  z : TAnsiStringBuilder;
  tag: AnsiString;
begin
  z := TAnsiStringBuilder.Create;
  try
    n := 1;
  //  k := Length(aStr);
    while n>0 do
    begin
      k := G_CharPos('<', AText, n);
      if k>0 then
      begin
        l := k - n;
        if l>0 then
          z.Append(Copy(AText, n, l));
        n := G_CharPos('>', AText, k) + 1;
        if n=1 then // не найдено ">"
        begin
          z.Append(Copy(AText, k, MaxInt));
          Break;
        end
        else
        begin // проверить имя тега
          tag := Copy(AText, k+1, n-k-2);
          if tag<>'' then
          begin
            if tag[1]='/' then
              Delete(tag, 1, 1);
            if tag<>'' then
            begin
              p := CharsPos(not_tag_char, tag);
              if p>0 then
                Delete(tag, p, MaxInt);
              if tag<>'' then
              begin
                if _is_block_tag(G_ToLower(tag)) then
                  z.Append(CR);
              end
            end
          end
        end
      end
        else
      begin // не найдено "<"
        z.Append(Copy(AText, n, MaxInt));
        Break;
      end;
    end;
    //---
    AText := z.ToString;
  finally
    z.Free
  end;
end;

function HtmlTagsDelete2(const AText: AnsiString): AnsiString;
begin
  Result := AText;
  HtmlTagsDelete(Result)
end;

function GZipEncode(var ABuffer: RawByteString): Boolean;
begin
  Result := False;
  try
    if IsGZipData(ABuffer) then
    begin
      ABuffer := GZDecompressStr(ABuffer);
      Result := True;
    end;
  except
    on E:EZDecompressionError do
    begin
      //***
    end
    else
    begin
      raise
    end;
  end;
end;

function GZipEncode(var ABuffer: AnsiString): Boolean;
var z: RawByteString;
begin
  z := RawByteString(ABuffer);
  Result := GZipEncode(z);
  ABuffer := z;
end;

function IsGZipData(const AData: AnsiString): Boolean;
begin
  // if  Copy(buf,1,4)=#$1F#$8B#$08#$00 then
  Result := (Length(AData)>4) and (PInteger(AData)^=$00088B1F);
end;

function _ReplaceCRLF(const AText: string): string;
var S: AnsiString;
begin
  S := AnsiString(AText);
  G_Compact(S);
  Result := string(S);
end;

function ExceptionMessage(const E: Exception): string;
begin
  Result := E.ClassName + ' ' + _ReplaceCRLF(E.Message)
end;


function Base64Encode2(const ASourceText: AnsiString; AAppendEnd: Boolean;
  ASplitLen: Integer; ASplitStr: AnsiString): AnsiString;
var
  splitStrLen, sourceLen, resultLen, sourceSplitLen, resultSplitLen: Integer;
  sourceEnd, resultEnd: PAnsiChar;
  sourcePtr, resultPtr: PAnsiChar;
  k, l: Integer;
begin
  if ASourceText = '' then
  begin
    Result := '';
    Exit;
  end;
  
  splitStrLen := Length(ASplitStr);
  sourceLen := Length(ASourceText);
  resultLen := (((sourceLen + 2) div 3) shl 2); // кол-во букв * 4/3
  if (ASplitLen > 0) and (splitStrLen > 0) then
  begin
    resultSplitLen := (ASplitLen div 4) * 4;
    if resultSplitLen = 0 then
      resultSplitLen := 4;
    sourceSplitLen := (resultSplitLen div 4) * 3; // по сколько разрезать исходную строку
    resultLen := resultLen + (((sourceLen + sourceSplitLen - 1) div sourceSplitLen) * splitStrLen); // добавить разделитель
    if not AAppendEnd then
      resultLen := resultLen - splitStrLen;
  end
  else
  begin
    sourceSplitLen := sourceLen;
    resultSplitLen := ((sourceLen + 2) div 3) * 4;
    ASplitLen := 0;
  end;
  SetString(Result, nil, resultLen);
  sourcePtr := @ASourceText[1];
  resultPtr := @Result[1];
  sourceEnd := @sourcePtr[sourceLen];
  resultEnd := @Result[resultLen];
  while (sourcePtr <= sourceEnd) and (resultPtr < resultEnd) do
  begin
    k := sourceSplitLen;
    l := sourceEnd - sourcePtr;
    if k > l then
    begin
      k := l;
      resultSplitLen := ((k + 2) div 3) * 4;
    end;
    IntBase64Encode(sourcePtr, resultPtr, k);
    Inc(sourcePtr, k);
    Inc(resultPtr, resultSplitLen);
    if (ASplitLen > 0) and (resultPtr <= resultEnd) then
    begin
      Move(Pointer(ASplitStr)^, resultPtr^, splitStrLen);
      Inc(resultPtr, splitStrLen)
    end
  end
end;


// base64 mime
// кодирование строки в base64 блоками по 57 символов
function Base64Encode(const ASourceText: AnsiString): AnsiString;
var
  l,k,j,i : Integer;
begin
  l := Length(ASourceText);
                         {  кол-во букв * 4/3  }   {     кол-во строк * 2     }
  SetString(Result, nil, (((l + 2) div 3) shl 2) + (((l+56) div 57) shl 1));
  k := 1; j := 1;
  while k<=l do
  begin
    i := Min(57,l-k+1);
    IntBase64Encode(@ASourceText[k], @Result[j], i);
    Inc(j, ((i+2) div 3) shl 2);
    Result[j]   := #13;
    Result[j+1] := #10;
    Inc(j, 2);
    Inc(k, 57);
  end;

end;

function Base64Decode(const ABase64Text: AnsiString): AnsiString;
var
  L,N,K: Integer;
  S: TAnsiStringBuilder;
  z: AnsiString;
begin
  N := 1;
  L := Length(ABase64Text);
  S := TAnsiStringBuilder.Create((L div 4) * 3);
  try
    repeat
      K := G_PosStr(CRLF, ABase64Text, N);
      if k>0 then z := Copy(ABase64Text, N, K-N)
             else z := Copy(ABase64Text, N, MaxInt);
      S.Append(G_Base64Decode(z));
      N := K + 2;
    until (K=0) or (N>=L);
    //---
    Result := S.ToString();
  finally
    S.Free;
  end;
end;

function _QP_Decode(oBuf, iBuf: PAnsiChar; len: Integer): Integer;
const
  CR = 13; LF = 10;

const
  xx = $7F;
  QP_DTable: array[0..$FF] of Byte = (
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    $0,$1,$2,$3, $4,$5,$6,$7, $8,$9,xx,xx, xx,xx,xx,xx,
    xx,$A,$B,$C, $D,$E,$F,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,$A,$B,$C, $D,$E,$F,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx
);  

  function isXdigit(x: Byte): Boolean;
  begin
    // RFC 1521: uppercase letters must be used when sending
    // hex data, though a robust implementation may choose to
    // recognize lowercase letters on receipt.
    //
    isXdigit := AnsiChar(x) in ['0'..'9','A'..'F','a'..'f']
  end;

VAR encoded: Boolean;
    i, j: Integer;
    c1, c2: Byte;
    c: AnsiChar;

begin
  i := 0;
  j := 0;

  encoded := FALSE; // used to handle the last hex triplet
  while i < len do
  begin
    c := iBuf[i];
    if c = '=' then // found either a hex triplet: =HEx,
    begin           // or a soft line break
      if i < (len-2) then
      begin
        c1 := Byte(iBuf[i+1]);
        c2 := Byte(iBuf[i+2]);

        if isXdigit(c1) AND isXdigit(c2) then
        begin
          oBuf[j] := AnsiChar((QP_DTable[c1] SHL 4) OR QP_DTable[c2]);
          Inc(i, 2);
          Inc(j);
        end
        else if (c1 = CR) AND (c2 = LF) then  // soft break
          Inc(i, 2);
      end;
      encoded := TRUE;
    end
    else begin
      // MIME ignores trailing spaces and tab characters unless
      // the line is terminated with a hex triplet: =09 or =20.
      // Therefore, we check the encoded flag, and if it is false
      // then we try to remove the trailing spaces.
      //
      if ((c = Chr(CR)) OR (c = Chr(LF))) AND NOT encoded then
      begin
        while (j > 0) AND (oBuf[j-1] in [#9, #32]) do Dec(j);
      end;
      oBuf[j] := c;
      Inc(j);
      encoded := FALSE;
    end;
    Inc(i);
  end;
  _QP_Decode := j
end;

function QPDecode(const AQPText: AnsiString): AnsiString;
begin
  SetLength(Result, Length(AQPText));
  SetLength(Result, _QP_Decode(PAnsiChar(Result), PAnsiChar(AQPText), Length(AQPText)))
end;

function _Qp_Encode(outC, inBeg, inEnd: PAnsiChar): PAnsiChar;
CONST cBasisHex: ARRAY [0..15] of AnsiChar =
  ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

CONST _CR = #13; _LF = #10;
CONST cLineLen = 72;
VAR itsLinePos: Integer;
    itsPrevCh, c: AnsiChar;
    lastSpace: PAnsiChar;
begin
  itsLinePos := 0;
  itsPrevCh  := #0;

  lastSpace := Nil;

  while (inBeg <> inEnd) do
  begin
    c := inBeg^;

    // line-breaks
    if (c = _CR) OR (c = _LF) then
    begin
      if (itsPrevCh = ' ') {OR (itsPrevCh = #9)} then
      begin
        Dec(outC);
        outC^ := '=';
        Inc(outC);
        outC^ := cBasisHex[Byte(itsPrevCh) SHR 4];
        Inc(outC);
        outC^ := cBasisHex[Byte(itsPrevCh) AND $0F];
        Inc(outC);
      end;
      outC^ := c;
      Inc(outC);
      itsLinePos := 0;
      itsPrevCh := c;
      lastSpace := Nil;
    end
    else
      if (c in [{#9, }#32..#60, #62..#126])
         // Following line is to avoid single periods alone on lines,
         // which messes up some dumb SMTP implementations, sigh...
         AND NOT ((itsLinePos = 0) AND (c = '.')) then
         begin
            itsPrevCh := c;
            outC^ := c;
            Inc(outC);
            Inc(itsLinePos);

            if ((c = ' ') {OR (c = #9)}) AND (itsLinePos > cLineLen/2) then
              lastSpace := outC;
         end
         else begin
            outC^ := '=';
            Inc(outC);
            outC^ := cBasisHex[Byte(c) SHR 4];
            Inc(outC);
            outC^ := cBasisHex[Byte(c) AND $0F];
            Inc(outC);
            Inc(itsLinePos, 3);
            itsPrevCh := 'A'; // close enough
         end;

    if (itsLinePos > cLineLen) then
    begin

      if lastSpace <> Nil then
      begin
        itsLinePos := outC - lastSpace;
        Move(lastSpace^, (lastSpace+3)^, outC - lastSpace);
        lastSpace^ := '=';
        Inc(lastSpace);
        lastSpace^ := _CR;
        Inc(lastSpace);
        lastSpace^ := _LF;
        Inc(outC, 3);
        lastSpace := Nil;
      end
      else begin
        outC^ := '=';
        Inc(outC);
        outC^ := _CR;
        Inc(outC);
        outC^ := _LF;
        Inc(outC);
        itsPrevCh := _LF;
        itsLinePos := 0;
      end;
    end;
    Inc(inBeg);
  end;

  if (itsLinePos <> 0) then
  begin
    outC^ := '=';
    Inc(outC);
    outC^ := _CR;
    Inc(outC);
    outC^ := _LF;
    Inc(outC);
  end;

  Result := outC;
end;

function QPEncode(const ASourceText: AnsiString): AnsiString;
var x: PAnsiChar;
begin
  SetLength(Result, 3 * Length(ASourceText));
  x  := _Qp_Encode(PAnsiChar(Result), PAnsiChar(ASourceText), PAnsiChar(ASourceText) + Length(ASourceText));
  SetLength(Result, x - PAnsiChar(Result));
end;

{$IFNDEF UNICODE}
function UTF8ToString(const S: UTF8String): string;
begin
  Result := Utf8ToAnsi(S)
end;
{$ENDIF}

function ChangeFileName(const AFileName: TFileName;
  const APrefix, APostfix: string): TFileName;
var p,n,e: string;
begin
  p := ExtractFilePath(AFileName);
  n := ExtractFileName(AFileName);
  e := ExtractFileExt(n);
  n := ChangeFileExt(n, '');
  Result := p + APrefix + n + APostfix + e;
end;

function NextIndex(var A: Integer; Max: Integer): Integer;
begin
  Inc(A);
  if not InRange(A, 0, Max) then
    A := 0;
  Result := A
end;

function TestRange(A, AMin, AMax: Integer): Integer;
begin
  if A < AMin then
    Result := AMin
  else
  if A > AMax then
    Result := AMax
  else
    Result := A
end;


{$IFNDEF UNICODE}
procedure SetCodePage(var S: RawByteString; CodePage: Word; Convert: Boolean = True);
begin

end;
{$ENDIF}

procedure RawSetUtf8(var S: RawByteString);
begin
  SetCodePage(S, CP_UTF8, False);
end;

procedure RawSetBin(var S: RawByteString);
begin
  SetCodePage(S, $FFFF, False);
end;

function RawAsUtf8(const S: RawByteString): UTF8String;
var z: RawByteString;
begin
  z := S;
  RawSetUtf8(z);
  Result := UTF8String(S);
end;

function RawAsBin(const S: RawByteString): RawByteString;
begin
  Result := S;
  RawSetBin(Result);
end;


end.


