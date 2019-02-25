unit uStringUtils;

interface

{$INCLUDE jedi.inc}

uses
  SysUtils, Classes, StrUtils, Types,
  uAnsiStringList, uGlobalTypes;


type
  TStringProcessingFunc = function(const S: string): string;
  PStringProcessingFunc = ^TStringProcessingFunc;

  {$IFDEF UNICODE}
  TAnsiStringProcessingFunc = function(const S: AnsiString): AnsiString;
  PAnsiStringProcessingFunc = ^TStringProcessingFunc;
  {$ENDIF}

//==============================================================================
{$REGION '*** Работа с TStrings ***'}
//==============================================================================

/// <summary>
///   копирование TStrings в TStrings (для совместимости с Unicode версией)
/// </summary>
/// <param name="ASource">источник</param>
/// <param name="ADestination">получатель</param>
procedure StringsAssign(ASource: TStrings; ADestination: TStrings);

/// <summary>
///   добавление в TStrings строк четко по разделителю #13#10
/// </summary>
/// <param name="AStrings">получатель</param>
/// <param name="AText">исходный текст</param>
procedure StringsStrictAdd(AStrings: TAnsiStrings; const AText: AnsiString); overload;
{$IFDEF UNICODE}
procedure StringsStrictAdd(AStrings: TStrings; const AText: string); overload;
{$ENDIF}

/// <summary>
/// Возвращает случайную строку из TStrings
/// </summary>
/// <param name="AStrings"></param>
/// <param name="ADefault">возвращает ADefault если AStrings пустой</param>
/// <returns>случайная строка из AStrings</returns>
function StringsRandom(AStrings: TStrings; const ADefault: string = ''): string;

{$ENDREGION}


//==============================================================================
{$REGION '//=== Поиск символов в строке'}
//==============================================================================


function LastPosStr(const SubStr, S: AnsiString; AEnd: Integer = MaxInt): Integer; overload;
{$IFDEF UNICODE}
function LastPosStr(const SubStr, S: string; AEnd: Integer = MaxInt): Integer; overload;
{$ENDIF}

/// <summary>
///   поиск символа строке с конца
/// </summary>
/// <param name="C">что искать</param>
/// <param name="A">где искать</param>
/// <param name="S">номер символа с которого начинается поиск</param>
/// <returns>индекс символа или 0, если не нашлось</returns>
function LastCharPos(C: Char; const A: string; S: Integer = MaxInt): Integer;
function LastCharsPos(const C: TSysCharSet; const A: string; S: Integer = MaxInt): Integer;

/// <summary>
///   поиск символа строке с начала
/// </summary>
/// <param name="C">что искать</param>
/// <param name="A">где искать</param>
/// <param name="S">номер символа с которого начинается поиск</param>
/// <returns>индекс символа или 0, если не нашлось</returns>
function CharPos(C: Char; const A: string; S: Integer = 1): Integer; overload;
function CharPos(C: Char; A: PChar; S, L: Integer): Integer; overload;

function CharPosLeft(const AChar: Char; const AStr: string;
  AStart: Integer = MaxInt; AEnd: Integer = 1): Integer; overload;

{$IFDEF UNICODE}
function CharPosLeft(const AChar: AnsiChar; const AStr: AnsiString;
  AStart: Integer = MaxInt; AEnd: Integer = 1): Integer; overload;
{$ENDIF}


/// <summary>
/// Поиск первого символа из множества в строке
/// </summary>
/// <param name="AChars">множество искомых символов</param>
/// <param name="AStr">где искать</param>
/// <param name="AStart">с кокого символа начинать поиск</param>
/// <returns>индекс символа в строке</returns>

function CharsPos(const AChars: TSysCharSet; APStr: PChar;
  AStart, AEnd: Integer): Integer; overload;

function CharsPos(const AChars: TSysCharSet; const AStr: AnsiString;
  AStart: Integer = 1; AEnd: Integer = MaxInt): Integer; overload;

{$IFDEF UNICODE}
function CharsPos(const AChars: TSysCharSet; const AStr: string;
  AStart: Integer = 1; AEnd: Integer = MaxInt): Integer; overload;
{$ENDIF}


function CharsPosNot(const AChars: TSysCharSet; const AStr: AnsiString;
  AStart: Integer = 1; AEnd: Integer = MaxInt): Integer; overload;

{$IFDEF UNICODE}
function CharsPosNot(const AChars: TSysCharSet; const AStr: string;
  AStart: Integer = 1; AEnd: Integer = MaxInt): Integer; overload;
{$ENDIF}

function CharsPosLeft(const AChars: TSysCharSet; const AStr: string;
  AStart: Integer = MaxInt; AEnd: Integer = 1): Integer;

function CharsPosLeftNot(const AChars: TSysCharSet; const AStr: string;
  AStart: Integer = MaxInt; AEnd: Integer = 1): Integer; overload;

{$IFDEF UNICODE}
function CharsPosLeftNot(const AChars: TSysCharSet; const AStr: AnsiString;
  AStart: Integer = MaxInt; AEnd: Integer = 1): Integer; overload;
{$ENDIF}

function PosStrArray(const ASubStrArr: array of string; const AStr: string): Integer;

function StartsWith(const S, Value: AnsiString): Boolean; overload;
function StartsWith(const S, Value: AnsiString; IgnoreCase: Boolean): Boolean; overload;
function EndsWith(const S, Value: AnsiString; IgnoreCase: Boolean): Boolean; overload;
function EndsWith(const S, Value: AnsiString): Boolean; overload;


{$ENDREGION}


//==============================================================================
{$REGION '*** Обработка\преобразование строк ***'}
//==============================================================================

function StrAppendWDelim(const AText, ANewText: string;
  const ADelim: string = ';'; const APrefix: string = '';
  const APostfix: string = ''): string; overload;

{$IFDEF UNICODE}
function StrAppendWDelim(const AText, ANewText: AnsiString;
  const ADelim: AnsiString = ';'; const APrefix: AnsiString = '';
  const APostfix: AnsiString = ''): AnsiString; overload;
{$ENDIF}

function RandomChars(const AChars: string; ALength1: Integer = 1;
  ALength2: Integer = -1): string; overload;
{$IFDEF UNICODE}
function RandomChars(const AChars: RawByteString; ALength1: Integer = 1;
  ALength2: Integer = -1): RawByteString; overload;
{$ENDIF}
function RandomStringOfChars(const AChars: string;
  const ALen1: Integer = 1; const ALen2: Integer = -1): string;
function RandomStringOfCharsA(const AChars: TSysCharSet;
  const ALen1: Integer = 1; const ALen2: Integer = -1): RawByteString; overload;
function RandomStringOfCharsA(const AChars: RawByteString;
  const ALen1: Integer = 1; const ALen2: Integer = -1): RawByteString; overload;


{$IFDEF UNICODE}
function RandomRangeStr(const A: string; const AMin: Integer = 0): Integer;
{$ENDIF}
function RandomFromInterval(const A: string; ADef: Integer = 0): Integer;


function StrCut(var AStr: string; const ADelim: TSysCharSet): string; overload;
function StrCut(var AStr: string; const ADelim: Char): string; overload;
function StrCut(var AStr: string; const ADelim: string): string; overload;

{$IFDEF UNICODE}
function StrCut(var AStr: AnsiString; const ADelim: TSysCharSet): AnsiString; overload;
function StrCut(var AStr: AnsiString; const ADelim: AnsiChar): AnsiString; overload;
function StrCut(var AStr: RawByteString; const ADelim: RawByteString): RawByteString; overload;
{$ENDIF}

function StrCutEnd(var AStr: AnsiString; const ADelim: AnsiString): AnsiString; overload;
function StrCutEnd(var AStr: AnsiString; const ADelim: AnsiChar): AnsiString; overload;

{$IFDEF UNICODE}
function StrCutEnd(var AStr: string; const ADelim: string): string; overload;
function StrCutEnd(var AStr: string; const ADelim: Char): string; overload;
function StrCutEnd(var AStr: string; const ADelim: TSysCharSet): string; overload;
{$ENDIF}


function StrCopy(var AStart: Integer; const AText: string; const ADelim: TSysCharSet): string; overload;
function StrCopy(var AStart: Integer; const AText: string; const ADelim: Char): string; overload;
function StrCopy(var AStart: Integer; const AText: string; const ADelim: string): string; overload;
function StrCopy(const AText: string; const ADelim: TSysCharSet): string; overload;
function StrCopy(const AText: string; const ADelim: Char): string; overload;
function StrCopy(const AText, ADelim: string): string; overload;
{$IFDEF UNICODE}
function StrCopy(var AStart: Integer; const AText: AnsiString; const ADelim: TSysCharSet): AnsiString; overload;
function StrCopy(var AStart: Integer; const AText: AnsiString; const ADelim: AnsiChar): AnsiString; overload;
function StrCopy(var AStart: Integer; const AText, ADelim: AnsiString): AnsiString; overload;
function StrCopy(const AText: AnsiString; const ADelim: TSysCharSet): AnsiString; overload;
function StrCopy(const AText: AnsiString; const ADelim: AnsiChar): AnsiString; overload;
function StrCopy(const AText, ADelim: AnsiString): AnsiString; overload;
{$ENDIF}

function StrCopyEnd(const AStr: AnsiString; const ADelim: AnsiChar): AnsiString;  overload;
function StrCopyEnd(const AStr, ADelim: AnsiString): AnsiString; overload;
function StrCopyEnd(var AEnd: Integer; const AStr, ADelim: AnsiString): AnsiString; overload;
{$IFDEF UNICODE}
function StrCopyEnd(const AStr: string; const ADelim: Char): string; overload;
function StrCopyEnd(const AStr: string; const ADelim: TSysCharSet): string; overload;
function StrCopyEnd(var AEnd: Integer; const AStr, ADelim: string): string; overload;
function StrCopyEnd(const AStr, ADelim: string): string; overload;
{$ENDIF}

//procedure StrDelete(var A: string; const ADelim: string);
//procedure StrDeleteEnd(var A: string; const ADelim: string);

function StrCompareStart(const AStart, AStr: AnsiString): Boolean;
function StrCompareEnd(const AEnd, AStr: AnsiString): Boolean;


function StringSplit(const A: string; const ADelim: Char;
  const AProcessing: PStringProcessingFunc = nil;
  const AAddEmpty: Boolean = True): TStringDynArray; {$IFDEF UNICODE}overload;{$ENDIF}
{$IFDEF UNICODE}
function StringSplit(const A: AnsiString; const ADelim: AnsiChar;
  const AProcessing: PAnsiStringProcessingFunc = nil;
  const AAddEmpty: Boolean = True): TAnsiStringDynArray; overload;
{$ENDIF}


function StringSplitTrim(const A: string; const ADelim: Char): TStringDynArray; {$IFDEF UNICODE}overload;{$ENDIF}
{$IFDEF UNICODE}
function StringSplitTrim(const A: AnsiString; const ADelim: AnsiChar): TAnsiStringDynArray; overload;
{$ENDIF}

function StringJoin(const A: TStringDynArray; const ADelim: Char): string; {$IFDEF UNICODE}overload;{$ENDIF}
{$IFDEF UNICODE}
function StringJoin(const A: TAnsiStringDynArray; const ADelim: AnsiChar): AnsiString; overload;
{$ENDIF}

{$ENDREGION}


//==============================================================================
{$REGION '*** Сетевые ф-ции ***'}
//==============================================================================

/// <summary>
///   Возврашает домен K-го уровня
/// </summary>
/// <param name="A">домен</param>
/// <param name="K">уровень</param>
/// <returns></returns>
function ExtractDomainParts(const A: string; K: Integer): string;

function AddrGetHost(const A: string): string; {$IFDEF UNICODE}overload;{$ENDIF}
function ExtractAddrHost(const A: string): string; {$IFDEF UNICODE}overload;{$ENDIF}
function AddrGetPort(const A: string; ADefPort: Word): Integer; overload;
function ExtractAddrPort(const A: string; ADefPort: Word): Integer; overload;
function AddrGetPort(const A, ADefPort: string): string; overload;
function ExtractAddrPort(const A, ADefPort: string): string; overload;
{$IFDEF UNICODE}
function AddrGetHost(const A: AnsiString): AnsiString; overload;
function ExtractAddrHost(const A: AnsiString): AnsiString; overload;
function AddrGetPort(const A: AnsiString; ADefPort: Word): Integer; overload;
function ExtractAddrPort(const A: AnsiString; ADefPort: Word): Integer; overload;
function AddrGetPort(const A, ADefPort: AnsiString): AnsiString; overload;
function ExtractAddrPort(const A, ADefPort: AnsiString): AnsiString; overload;
{$ENDIF}
function MailGetName(const A: string): string;
function ExtractMailName(const A: string): string;
function MailGetDomain(const A: string): string;
function ExtractMailDomain(const A: string): string;

function GetUrlProto(const A: string): string;
function GetUrlProtoHost(const A: string): string;
function GetUrlHost(const A: string): string;
function GetUrlHostA(const A: AnsiString): AnsiString;
function GetUrlPath(const A: string): string;

{$ENDREGION}


//==============================================================================
{$REGION '*** Ф-ции преобразования строк в другие типы  и наоборот ***'}
//==============================================================================
/// <summary>
///   UInt64 в строку (в новых версиях есть родная в System.SysUtils)
/// </summary>
/// <param name="Value"></param>
/// <returns></returns>
function UIntToStr(Value: UInt64): string;
function IntToAStr(const I: Integer): AnsiString;
function IntToStrA(const I: Integer): AnsiString;
function TryAStrToInt(const S: AnsiString; var I: Integer): Boolean;
function TryStrToIntA(const S: AnsiString; var I: Integer): Boolean;
function AStrToInt(const S: AnsiString): Integer;
function StrToIntA(const S: AnsiString): Integer;
function AStrToIntDef(const S: AnsiString; const ADef: Integer): Integer;
function StrToIntDefA(const S: AnsiString; const ADef: Integer): Integer;

{$ENDREGION}

function UuidCreateRndStr(const ADelim: AnsiString = '-';
  const APrefix: AnsiString = '{';
  const APostfix: AnsiString = '}'): AnsiString;

function GenSimplePassword(ALen: Integer): AnsiString;

function StrToInterval(const A: string): Integer;

var
  RandomCharsA: function (const AChars: RawByteString; ALength1: Integer = 1;
  ALength2: Integer = -1): RawByteString = RandomChars;

var
  StrCutA: function(var AStr: AnsiString; const ADelim: TSysCharSet): AnsiString  = StrCut;

implementation

uses
  SysConst,
  {$IFDEF UNICODE}
  AnsiStrings,
  {$ENDIF}
  Math,
  AcedStrings, AcedCommon,
  uGlobalConstants;


function AnsiStrToIntDef(const S: AnsiString; const ADef: Integer): Integer;
begin
  Result := SysUtils.StrToIntDef(string(S), ADef)  // cast
end;

//==============================================================================
{$REGION 'Поиск символов в строке'}
//==============================================================================

function LastCharPos(C: Char; const A: string; S: Integer): Integer;
var
  j,m: Integer;
  p: PChar;
begin
  if A <> '' then
  begin
    m := 1;
    j := Min(Length(A), S); // начало
    //---
    if j >= m then
    begin
      p := @A[j];
      while j >= m do
      begin
        if p^ = C then
        begin
          Result := j;
          Exit;
        end;
        Dec(p);
        Dec(j);
      end
    end
  end;
  Result := 0;
end;

{$IFNDEF Unicode}
function CharInSet(const AChar: Char; const ACharSet: TSysCharSet): Boolean;
begin
  Result := AChar in ACharSet
end;
{$ENDIF}

function LastCharsPos(const C: TSysCharSet; const A: string; S: Integer): Integer;
var
  j,m: Integer;
  p: PChar;
begin
  if A <> '' then
  begin
    m := 1;
    j := Min(Length(A), S); // начало
    //---
    if j >= m then
    begin
      p := @A[j];
      while j >= m do
      begin
        if CharInSet(p^, C) then
        begin
          Result := j;
          Exit;
        end;
        Dec(p);
        Dec(j);
      end
    end
  end;
  Result := 0;
end;

function CharPos(C: Char; A: PChar; S, L: Integer): Integer;
var
  j: Integer;
begin
  if A <> nil then
  begin
    j := Max(S, 1);
    Inc(A, j - 1);
    while j <= L do
    begin
      if A^ = C then
      begin
        Result := j;
        Exit;
      end;
      Inc(A);
      Inc(j);
    end;
  end;
  Result := 0;
end;

function CharPos(C: Char; const A: string; S: Integer): Integer;
begin
  Result := CharPos(C, PChar(A), S, Length(A))
end;


function CharPosLeft(const AChar: AnsiChar; const AStr: AnsiString;
  AStart, AEnd: Integer): Integer;
var
  j,m: Integer;
  p: PAnsiChar;
begin
  if AStr <> '' then
  begin
    m := Max(AEnd, 1); // конец
    j := Min(Length(AStr), AStart); // начало
    //---
    if j >= m then
    begin
      p := @AStr[j];
      while j >= m do
      begin
        if p^ = AChar then
        begin
          Result := j;
          Exit;
        end;
        Dec(p);
        Dec(j);
      end
    end
  end;
  Result := 0;
end;

function CharsPosLeft(const AChars: TSysCharSet; const AStr: string;
  AStart, AEnd: Integer): Integer;
var
  j,m: Integer;
  p: PChar;
begin
  if AStr <> '' then
  begin
    m := Max(AEnd, 1); // конец
    j := Min(Length(AStr), AStart); // начало
    //---
    if j >= m then
    begin
      p := @AStr[j];
      while j >= m do
      begin
        if CharInSet(p^, AChars) then
        begin
          Result := j;
          Exit;
        end;
        Dec(p);
        Dec(j);
      end
    end
  end;
  Result := 0;
end;

{$IFDEF UNICODE}
function CharPosLeft(const AChar: Char; const AStr: string;
  AStart, AEnd: Integer): Integer;
var
  j,m: Integer;
  p: PChar;
begin
  if AStr <> '' then
  begin
    m := Max(AEnd, 1); // конец
    j := Min(Length(AStr), AStart); // начало
    //---
    if j >= m then
    begin
      p := @AStr[j];
      while j >= m do
      begin
        if p^ = AChar then
        begin
          Result := j;
          Exit;
        end;
        Dec(p);
        Dec(j);
      end
    end
  end;
  Result := 0;
end;
{$ENDIF}

function CharsPos(const AChars: TSysCharSet; APStr: PChar; AStart, AEnd: Integer): Integer;
var
  j: Integer;
begin
  if APStr <> nil then
  begin
    j := AEnd - AStart;
    Inc(APStr, AStart - 1);
    while j >= 0 do
    begin
      if CharInSet(APStr^, AChars) then
      begin
        Result := AStart + j;
        Exit;
      end;
      Inc(APStr);
      Dec(j);
    end;
  end;
  Result := 0;
end;

function CharsPos(const AChars: TSysCharSet; const AStr: AnsiString;
  AStart, AEnd: Integer): Integer;
var
  j,m: Integer;
  p: PAnsiChar;
begin
  if AStr <> '' then
  begin
    m := Min(Length(AStr), AEnd);
    j := Max(AStart, 1);
    if j <= m then
    begin
      p := @AStr[j];
      while j <= m do
      begin
        if p^ in AChars then
        begin
          Result := j;
          Exit;
        end;
        Inc(p);
        Inc(j);
      end;
    end;
  end;
  Result := 0;
end;

{$IFDEF UNICODE}
function CharsPos(const AChars: TSysCharSet; const AStr: string;
  AStart, AEnd: Integer): Integer;
var
  j,m: Integer;
  p: PChar;
begin
  if AStr <> '' then
  begin
    m := Min(Length(AStr), AEnd);
    j := Max(AStart, 1);
    if j <= m then
    begin
      p := @AStr[j];
      while j <= m do
      begin
        if CharInSet(p^, AChars) then
        begin
          Result := j;
          Exit;
        end;
        Inc(p);
        Inc(j);
      end;
    end;
  end;
  Result := 0;
end;
{$ENDIF}


function CharsPosNot(const AChars: TSysCharSet; const AStr: AnsiString;
  AStart, AEnd: Integer): Integer;
var
  j,m: Integer;
  p: PAnsiChar;
begin
  if AStr<>'' then
  begin
    m := Min(Length(AStr), AEnd);
    j := Max(AStart, 1);
    if j <= m then
    begin
      p := @AStr[j];
      while j <= m do
      begin
        if not (p^ in AChars) then
        begin
          Result := j;
          Exit;
        end;
        Inc(p);
        Inc(j);
      end;
    end;
  end;
  Result := 0;
end;


{$IFDEF UNICODE}
function CharsPosNot(const AChars: TSysCharSet; const AStr: string;
  AStart, AEnd: Integer): Integer;
begin
  Result := CharsPosNot(AChars, AnsiString(AStr), AStart, AEnd);
end;
{$ENDIF}


function CharsPosLeftNot(const AChars: TSysCharSet; const AStr: AnsiString;
  AStart, AEnd: Integer): Integer;
var
  j,m: Integer;
  p: PAnsiChar;
begin
  if AStr <> '' then
  begin
    m := Max(AEnd, 1); // конец
    j := Min(Length(AStr), AStart); // начало
    //---
    if j >= m then
    begin
      p := @AStr[j];
      while j >= m do
      begin
        if not (p^ in AChars) then
        begin
          Result := j;
          Exit;
        end;
        Dec(p);
        Dec(j);
      end
    end
  end;
  Result := 0;
end;

{$IFDEF UNICODE}
function CharsPosLeftNot(const AChars: TSysCharSet; const AStr: string;
  AStart, AEnd: Integer): Integer;
begin
  Result := CharsPosLeftNot(AChars, AnsiString(AStr), AStart, AEnd)
end;
{$ENDIF}

function LastPosStr(const SubStr, S: AnsiString; AEnd: Integer): Integer;
begin
  if AEnd < 1 then
  begin
    Result := 0;
    Exit;
  end;
  if AEnd < MaxInt then
    AEnd := AEnd + 1;
  Result := G_LastPosStr(SubStr, S, AEnd)
end;
{$IFDEF UNICODE}
function LastPosStr(const SubStr, S: string; AEnd: Integer): Integer;
begin
  if AEnd < 1 then
    Exit(0);
//  if AEnd < MaxInt then
//    AEnd := AEnd + 1;
  Result := S.LastIndexOf(SubStr, AEnd - 1) + 1
end;
{$ENDIF}

function PosStrArray(const ASubStrArr: array of string; const AStr: string): Integer;
var j: Integer;
begin
  for j := Low(ASubStrArr) to High(ASubStrArr) do
  begin
    Result := Pos(ASubStrArr[j], AStr);
    if Result > 0 then
      Exit;
  end;
  Result := 0;
end;

function StartsWith(const S, Value: AnsiString): Boolean;
begin
  Result := StartsWith(S, Value, False);
end;

function StartsWith(const S, Value: AnsiString; IgnoreCase: Boolean): Boolean;
begin
  if Value = '' then
    Result := True
  else
    if IgnoreCase then
      Result := {$IFDEF UNICODE}System.AnsiStrings{$ELSE}StrUtils{$ENDIF}.StartsText(Value, S)
    else
      Result := {$IFDEF UNICODE}System.AnsiStrings{$ELSE}StrUtils{$ENDIF}.StartsStr(Value, S)
end;

function EndsWith(const S, Value: AnsiString; IgnoreCase: Boolean): Boolean;
begin
  if Value = '' then
    Result := True
  else
    if IgnoreCase then
      Result := {$IFDEF UNICODE}System.AnsiStrings{$ELSE}StrUtils{$ENDIF}.EndsText(Value, S)
    else
      Result := {$IFDEF UNICODE}System.AnsiStrings{$ELSE}StrUtils{$ENDIF}.EndsStr(Value, S)
end;

function EndsWith(const S, Value: AnsiString): Boolean;
begin
  Result := EndsWith(S, Value, False);
end;

{$ENDREGION}



//==============================================================================
{$REGION '*** Обработка\преобразование строк ***'}
//==============================================================================

function StrAppendWDelim(const AText, ANewText, ADelim,
  APrefix, APostfix: string): string;
begin
  if ANewText <> '' then
    if AText = '' then
      Result := APrefix + ANewText + APostfix
    else
      Result := AText + ADelim + APrefix + ANewText + APostfix
  else
    Result := AText
end;

{$IFDEF UNICODE}
function StrAppendWDelim(const AText, ANewText, ADelim,
  APrefix, APostfix: AnsiString): AnsiString;
begin
  if ANewText <> '' then
    if AText = '' then
      Result := APrefix + ANewText + APostfix
    else
      Result := AText + ADelim + APrefix + ANewText + APostfix
  else
    Result := AText
end;
{$ENDIF}

function RandomChars(const AChars: string; ALength1: Integer;
  ALength2: Integer): string;
var j,len:Integer;
begin
  if AChars='' then
  begin
    Result := '';
    Exit;
  end;
  if ALength2=-1 then
    len := ALength1
  else
    len := RandomRange(ALength1, ALength2+1);
  SetLength(Result, len);
  for j:=1 to len do
    Result[j] := AChars[Random(Length(AChars))+1]
end;

{$IFDEF UNICODE}
function RandomChars(const AChars: RawByteString; ALength1: Integer;
  ALength2: Integer): RawByteString;
var j,len:Integer;
begin
  if AChars='' then
  begin
    Result := '';
    Exit;
  end;
  if ALength2=-1 then
    len := ALength1
  else
    len := RandomRange(ALength1, ALength2+1);
  SetLength(Result, len);
  for j:=1 to len do
    Result[j] := AChars[Random(Length(AChars))+1]
end;
{$ENDIF}

function RandomStringOfChars(const AChars: string;
  const ALen1, ALen2: Integer): string;
var
  j, k, l: Integer;
begin
  if AChars = '' then
  begin
    Result := '';
    Exit;
  end;
  if ALen2 = -1 then
    k := ALen1
  else
    k := RandomRange(ALen1, ALen2 + 1);
  SetLength(Result, k);
  l := Length(AChars);
  for j := 1 to k do
    Result[j] := AChars[Random(l) + 1]
end;

function RandomStringOfCharsA(const AChars: RawByteString;
  const ALen1, ALen2: Integer): RawByteString;
var
  j, k, l: Integer;
begin
  if AChars = '' then
  begin
    Result := '';
    Exit;
  end;
  if ALen2 = -1 then
    k := ALen1
  else
    k := RandomRange(ALen1, ALen2 + 1);
  SetLength(Result, k);
  l := Length(AChars);
  for j := 1 to k do
    Result[j] := AChars[Random(l) + 1]
end;

function RandomStringOfCharsA(const AChars: TSysCharSet;
  const ALen1, ALen2: Integer): RawByteString;
var
  ch: AnsiChar;
  s: AnsiString;
  k: Integer;
begin
  if AChars = [] then
  begin
    Result := '';
    Exit;
  end;
  SetLength(s, 256);
  k := 0;
  for ch in AChars do
  begin
    if CharInSet(ch, AChars) then
    begin
      Inc(k);
      s[k] := ch;
    end;
  end;
  SetLength(s, k);
  Result := RandomStringOfCharsA(s, ALen1, ALen2)
end;


{$IFDEF UNICODE}
function RandomRangeStr(const A: string; const AMin: Integer): Integer;
var p,k1,k2: Integer;
begin
  p := Pos('-', A);
  if p = 0 then
  begin
    k1 := AMin;
    k2 := StrToIntDef(Trim(A), 0);
    if k1 > k2 then
      Exit(k1);          
  end
  else
  begin
    k1 := StrToIntDef(Trim(Copy(A, 1, p - 1)), 0);
    k2 := StrToIntDef(Trim(Copy(A, p + 1, MaxInt)), 0);
  end;


  if k1 = k2 then
    Exit(k1);

  Result := RandomRange(k1, k2)
end;
{$ENDIF}

function RandomFromInterval(const A: string; ADef: Integer): Integer;
var p,k1,k2: Integer;
begin
  p := Pos('-', A);
  if p = 0 then
  begin
    Result := StrToIntDef(Trim(A), ADef);
    Exit;
  end;

  k1 := StrToIntDef(Trim(Copy(A, 1, p - 1)), ADef);
  k2 := StrToIntDef(Trim(Copy(A, p + 1, MaxInt)), ADef);

  if k1 = k2 then
  begin
    Result := k1;
    Exit;
  end;

  Result := RandomRange(k1, k2)
end;


function StrCut(var AStr: string; const ADelim: TSysCharSet): string;
var p: Integer;
begin
  p := CharsPos(ADelim, AStr, 1);
  if p > 0 then
  begin
    Result := Copy(AStr, 1, p - 1);
    Delete(AStr, 1, p);
  end
  else
  begin
    Result := AStr;
    AStr := '';
  end
end;

function StrCut(var AStr: string; const ADelim: Char): string;
begin
  Result := StrCut(AStr, [ADelim])
end;

function StrCut(var AStr: string; const ADelim: string): string;
var p: Integer;
begin
  p := Pos(ADelim, AStr);
  if p > 0 then
  begin
    Result := Copy(AStr, 1, p - 1);
    Delete(AStr, 1, p + Length(ADelim) - 1);
  end
  else
  begin
    Result := AStr;
    AStr := '';
  end
end;

{$IFDEF UNICODE}
function StrCut(var AStr: AnsiString; const ADelim: TSysCharSet): AnsiString; overload;
var p: Integer;
begin
  p := CharsPos(ADelim, AStr, 1);
  if p > 0 then
  begin
    Result := Copy(AStr, 1, p - 1);
    Delete(AStr, 1, p);
  end
  else
  begin
    Result := AStr;
    AStr := '';
  end
end;

function StrCut(var AStr: AnsiString; const ADelim: AnsiChar): AnsiString;
begin
  Result := StrCut(AStr, [ADelim])
end;

function StrCut(var AStr: RawByteString; const ADelim: RawByteString): RawByteString;
var p: Integer;
begin
  p := Pos(ADelim, AStr);
  if p > 0 then
  begin
    Result := Copy(AStr, 1, p - 1);
    Delete(AStr, 1, p + Length(ADelim) - 1);
  end
  else
  begin
    Result := AStr;
    AStr := '';
  end
end;
{$ENDIF}


function StrCutEnd(var AStr: AnsiString; const ADelim: AnsiChar): AnsiString;
var p: Integer;
begin
  p := G_LastCharPos(ADelim, AStr);
  if p > 0 then
  begin
    Result := Copy(AStr, p + 1, MaxInt);
    Delete(AStr,  p, MaxInt);
  end
  else
  begin
    Result := AStr;
    AStr := '';
  end
end;

{$IFDEF UNICODE}
function StrCutEnd(var AStr: string; const ADelim: Char): string;
var p: Integer;
begin
  p := CharPosLeft(ADelim, AStr);
  if p > 0 then
  begin
    Result := Copy(AStr, p + 1, MaxInt);
    Delete(AStr,  p, MaxInt);
  end
  else
  begin
    Result := AStr;
    AStr := '';
  end
end;

function StrCutEnd(var AStr: string; const ADelim: TSysCharSet): string;
var p: Integer;
begin
  p := CharsPosLeft(ADelim, AStr);
  if p > 0 then
  begin
    Result := Copy(AStr, p + 1, MaxInt);
    Delete(AStr,  p, MaxInt);
  end
  else
  begin
    Result := AStr;
    AStr := '';
  end
end;
{$ENDIF}

function StrCutEnd(var AStr: AnsiString; const ADelim: AnsiString): AnsiString;
var p: Integer;
begin
  p := G_LastPosStr(ADelim, AStr);
  if p > 0 then
  begin
    Result := Copy(AStr, p + Length(ADelim), MaxInt);
    Delete(AStr,  p, MaxInt);
  end
  else
  begin
    Result := AStr;
    AStr := '';
  end
end;

{$IFDEF UNICODE}
function StrCutEnd(var AStr: string; const ADelim: string): string;
var p: Integer;
begin
  p := LastPosStr(ADelim, AStr);
  if p > 0 then
  begin
    Result := Copy(AStr, p + Length(ADelim), MaxInt);
    Delete(AStr,  p, MaxInt);
  end
  else
  begin
    Result := AStr;
    AStr := '';
  end
end;
{$ENDIF}


function StrCopyEnd(const AStr: AnsiString; const ADelim: AnsiChar): AnsiString;
var p: Integer;
begin
  p := G_LastPosStr(ADelim, AStr);
  if p > 0 then
  begin
    Result := Copy(AStr, p + Length(ADelim), MaxInt)
  end
  else
  begin
    Result := AStr;
  end;
end;

function StrCopyEnd(var AEnd: Integer; const AStr, ADelim: AnsiString): AnsiString;
var l, p: Integer;
begin
  l := Length(ADelim);
  if AEnd < MaxInt then
    AEnd := AEnd + 1;
  p := G_LastPosStr(ADelim, AStr, AEnd);
  if p > 0 then
  begin
    Result := Copy(AStr, l + p , AEnd - p - l);
    AEnd := p - 1
  end
  else
  begin
    AEnd := 0;
    Result := AStr;
  end;
end;

function StrCopyEnd(const AStr, ADelim: AnsiString): AnsiString;
var p: Integer;
begin
  p := MaxInt;
  Result := StrCopyEnd(p, AStr, ADelim)
end;

{$IFDEF UNICODE}
function StrCopyEnd(const AStr: string; const ADelim: Char): string;
var p: Integer;
begin
  p := LastCharPos(ADelim, AStr);
  if p > 0 then
  begin
    Result := Copy(AStr, p + Length(ADelim), MaxInt)
  end
  else
  begin
    Result := AStr;
  end;
end;


function StrCopyEnd(const AStr: string; const ADelim: TSysCharSet): string;
var p: Integer;
begin
  p := LastCharsPos(ADelim, AStr);
  if p > 0 then
  begin
    Result := Copy(AStr, p + 1, MaxInt)
  end
  else
  begin
    Result := AStr;
  end;
end;

function StrCopyEnd(var AEnd: Integer; const AStr, ADelim: string): string;
var l, p: Integer;
begin
  l := Length(ADelim);
  if AEnd < MaxInt then
    AEnd := AEnd + 1;
  p := LastPosStr(ADelim, AStr, AEnd);
  if p > 0 then
  begin
    Result := Copy(AStr, l + p , AEnd - p - l);
    AEnd := p - 1
  end
  else
  begin
    AEnd := 0;
    Result := AStr;
  end;
end;

function StrCopyEnd(const AStr, ADelim: string): string;
var p: Integer;
begin
  p := MaxInt;
  Result := StrCopyEnd(p, AStr, ADelim)
end;
{$ENDIF}




function StrCopy(const AText: string; const ADelim: Char): string;
var p: Integer;
begin
  p := CharPos(ADelim, AText);
  if p > 0 then
    Result := Copy(AText, 1, p - 1)
  else
    Result := AText;
end;
{$IFDEF UNICODE}
function StrCopy(const AText: AnsiString; const ADelim: AnsiChar): AnsiString;
var k: Integer;
begin
  k := 1;
  Result := StrCopy(k, AText, ADelim)
end;
{$ENDIF}

function StrCopy(var AStart: Integer; const AText: string; const ADelim: TSysCharSet): string;
var p: Integer;
begin
  if AStart < 1 then
    AStart := 1;
  p := CharsPos(ADelim, AText, AStart);
  if p > 0 then
  begin
    Result := Copy(AText, AStart, p - AStart);
    AStart := p + 1;
  end
  else
  begin
    Result := Copy(AText, AStart, MaxInt);
    AStart := MaxInt;
  end
end;
{$IFDEF UNICODE}
function StrCopy(var AStart: Integer; const AText: AnsiString; const ADelim: TSysCharSet): AnsiString;
var p: Integer;
begin
  if AStart < 1 then
    AStart := 1;
  p := CharsPos(ADelim, AText, AStart);
  if p > 0 then
  begin
    Result := Copy(AText, AStart, p - AStart);
    AStart := p + 1;
  end
  else
  begin
    Result := Copy(AText, AStart, MaxInt);
    AStart := MaxInt;
  end
end;
{$ENDIF}

function StrCopy(var AStart: Integer; const AText: string; const ADelim: Char): string;
begin
  Result := StrCopy(AStart, AText, [ADelim]);
end;
{$IFDEF UNICODE}
function StrCopy(var AStart: Integer; const AText: AnsiString; const ADelim: AnsiChar): AnsiString;
begin
  Result := StrCopy(AStart, AText, [ADelim]);
end;
{$ENDIF}

function StrCopy(var AStart: Integer; const AText: string; const ADelim: string): string;
var p: Integer;
begin
  if AStart < 1 then
    AStart := 1;
  p := PosEx(ADelim, AText, AStart);
  if p > 0 then
  begin
    Result := Copy(AText, AStart, p - AStart);
    AStart := p + Length(ADelim);
  end
  else
  begin
    Result := Copy(AText, AStart, MaxInt);
    AStart := MaxInt;
  end
end;
{$IFDEF UNICODE}
function StrCopy(var AStart: Integer; const AText, ADelim: AnsiString): AnsiString;
var p: Integer;
begin
  if AStart < 1 then
    AStart := 1;
  p := Pos(ADelim, AText, AStart);
  if p > 0 then
  begin
    Result := Copy(AText, AStart, p - AStart);
    AStart := p + Length(ADelim);
  end
  else
  begin
    Result := Copy(AText, AStart, MaxInt);
    AStart := MaxInt;
  end
end;
{$ENDIF}

function StrCopy(const AText: string; const ADelim: TSysCharSet): string;
var k: Integer;
begin
  k := 1;
  Result := StrCopy(k, AText, ADelim);
end;
{$IFDEF UNICODE}
function StrCopy(const AText: AnsiString; const ADelim: TSysCharSet): AnsiString;
var k: Integer;
begin
  k := 1;
  Result := StrCopy(k, AText, ADelim);
end;
{$ENDIF}

function StrCopy(const AText, ADelim: string): string;
var k: Integer;
begin
  k := 1;
  Result := StrCopy(k, AText, ADelim)
end;
{$IFDEF UNICODE}
function StrCopy(const AText, ADelim: AnsiString): AnsiString;
var k: Integer;
begin
  k := 1;
  Result := StrCopy(k, AText, ADelim)
end;
{$ENDIF}

function StrCompareStart(const AStart, AStr: AnsiString): Boolean;
begin
  Result := G_CompareStrL(AStart, AStr, Length(AStart)) = 0;
end;

function StrCompareEnd(const AEnd, AStr: AnsiString): Boolean;
var
  p: PAnsiChar;
  l: Integer;
begin
  l := Length(AStr) - Length(AEnd);
  if l >= 0 then
  begin
    p := PAnsiChar(AStr);
    Inc(p, l);
    Result := G_CompareStrL(p, PAnsiChar(AEnd)) = 0;
  end
  else
  begin
    Result := False
  end;
end;

{$ENDREGION}



//==============================================================================
{$REGION 'Операции над TStrings'}
//==============================================================================

procedure StringsStrictAdd(AStrings: TAnsiStrings; const AText: AnsiString);
var L,N,K: Integer;
begin
  AStrings.BeginUpdate;
  try
    N := 1;
    L := Length(AText);
    repeat
      K := G_PosStr(CRLF, AText, N);
      if k > 0 then
        AStrings.Add(Copy(AText, N, K-N))
             else
        AStrings.Add(Copy(AText, N, MaxInt));
      N := K + 2;
    until (K=0) or (N>=L);
  finally
    AStrings.EndUpdate;
  end;
end;

{$IFDEF UNICODE}
procedure StringsStrictAdd(AStrings: TStrings; const AText: string);
var L,N,K: Integer;
begin
  AStrings.BeginUpdate;
  try
    N := 1;
    L := Length(AText);
    repeat
      K := Pos(CRLF, AText, N);
      if k > 0 then
        AStrings.Add(Copy(AText, N, K-N))
             else
        AStrings.Add(Copy(AText, N, MaxInt));
      N := K + 2;
    until (K=0) or (N>=L);
  finally
    AStrings.EndUpdate;
  end;
end;
{$ENDIF}

procedure StringsAssign(ASource: TStrings; ADestination: TStrings);
begin
  ADestination.Assign(ASource);
end;

function StringsRandom(AStrings: TStrings; const ADefault: string): string;
var k: Integer;
begin
  k := AStrings.Count;
  if k > 0 then
    Result := AStrings[Random(k)]
  else
    Result := ADefault
end;

{$ENDREGION}


//==============================================================================
{$REGION '*** Ф-ции преобразования строк в другие типы  и наоборот ***'}
//==============================================================================

function UIntToStr(Value: UInt64): string;
begin
  Result := Format('%u', [Value])
end;

function IntToAStr(const I: Integer): AnsiString;
begin
  System.Str(I, Result);
end;

function IntToStrA(const I: Integer): AnsiString;
begin
  Result := IntToAStr(I)
end;

{
function TryAStrToInt(const S: AnsiString; var I: Integer): Boolean;
var
  Index, Len, Digit: Integer;
  Negative: Boolean;
begin
  Index := 1;
  Result := False;
  I := 0;
  Negative := False;
  Len := Length(s);
  while (Index <= Len) and (s[Index] = ' ') do
    inc(Index);
  if Index > Len then
    Exit;
  case s[Index] of
  '-','+':
    begin
      Negative := s[Index] = '-';
      inc(Index);
      if Index > Len then
        Exit;
    end;
  end;
  while Index <= Len do
  begin
    Digit := ord(s[Index]) - ord('0');
    if (Digit < 0) or (Digit > 9) then
      Exit;
    I := I * 10 + Digit;  Integer overflow
    if I < 0 then
      Exit;
    inc(Index);
  end;
  if Negative then
    I := -I;
  Result := True;
end;
}

function TryAStrToInt(const S: AnsiString; var I: Integer): Boolean;
begin
  Result := G_StrTo_Integer(S, I)
end;

function TryStrToIntA(const S: AnsiString; var I: Integer): Boolean;
begin
  Result := TryAStrToInt(S, I)
end;

function AStrToInt(const S: AnsiString): Integer;
begin
  if not TryAStrToInt(S, Result) then
    raise EConvertError.CreateResFmt(@SInvalidInteger, [S]);
end;

function StrToIntA(const S: AnsiString): Integer;
begin
  Result := AStrToInt(S)
end;

function AStrToIntDef(const S: AnsiString; const ADef: Integer): Integer;
begin
  if not TryAStrToInt(S, Result) then
    Result := ADef
//  Result := SysUtils.StrToIntDef(string(S), ADef)  // cast
end;

function StrToIntDefA(const S: AnsiString; const ADef: Integer): Integer;
begin
  Result := AStrToIntDef(S, ADef)
end;
{$ENDREGION}


//==============================================================================
{$REGION '*** Сетевые функции ***'}
//==============================================================================

function ExtractDomainParts(const A: string; K: Integer): string;
var p, l: Integer;
begin
  l := System.Length(A);
  if l = 0 then
  begin
    Result := '';
    Exit;
  end;
  //---
  // "example.com."
  if A[l] = '.' then
    p := l - 1
  else
   p := l;
  //---
  // поикс частей
  while (p > 0) and (K > 0) do
  begin
    p := {$IFDEF UNICODE}LastCharPos{$ELSE}G_LastCharPos{$ENDIF}('.', A, p - 1);
    Dec(K);
  end;
  if p > 0 then
    Result := Copy(A, p + 1, MaxInt)
  else
    Result := A;
end;

function GetUrlProto(const A: string): string;
var p1: Integer;
begin
  p1 := PosEx('://', A);
  if p1 = 0 then
    Result := ''
  else
    Result := Copy(A, 1, p1 - 1)
end;

function GetUrlHost(const A: string): string;
var p1,p2: Integer;
begin
  p1 := PosEx('://', A) + 3;
  p2 := PosEx('/', A, p1);
  if p2 = 0 then
    p2 := MaxInt
  else
    p2 := p2 - p1;

  Result := StrCopy(Copy(A, p1, p2), ':');
end;

function GetUrlHostA(const A: AnsiString): AnsiString;
var p1,p2: Integer;
begin
  p1 := G_PosStr('://', A) + 3;
  p2 := G_PosStr('/', A, p1);
  if p2 = 0 then
    p2 := MaxInt
  else
    p2 := p2 - p1;

  Result := StrCopy(Copy(A, p1, p2), ':');
end;

function GetUrlProtoHost(const A: string): string;
var p1,p2: Integer;
begin
  p1 := PosEx('://', A) + 3;
  if p1 = 0 then
  begin
    Result := '';
    Exit
  end;
  p2 := PosEx('/', A, p1);
  if p2 = 0 then
    p2 := MaxInt;

  Result := Copy(A, 1, p2 - 1)
end;

function GetUrlPath(const A: string): string;
var p1,p2: Integer;
begin
  p1 := PosEx('://', A) + 3;
  p2 := PosEx('/', A, p1);
  if p2 = 0 then
  begin
    Result := '/';
    Exit
  end;
  Result := Copy(A, p2, MaxInt)
end;

function AddrFindColon(const A: string): Integer;
begin
  Result := {$IFDEF UNICODE}CharPos{$ELSE}G_CharPos{$ENDIF}(':', A);
end;

function AddrGetHost(const A: string): string;
var p: Integer;
begin
  p := AddrFindColon(A);
  if p > 0 then
    Result := Copy(A, 1, p - 1)
  else
    Result := A;
end;
{$IFDEF UNICODE}
function AddrGetHost(const A: AnsiString): AnsiString;
begin
  Result := uStringUtils.StrCopy(A, ':');
end;
{$ENDIF}

function ExtractAddrHost(const A: string): string;
begin
  Result := AddrGetHost(A)
end;
{$IFDEF UNICODE}
function ExtractAddrHost(const A: AnsiString): AnsiString;
begin
  Result := AddrGetHost(A)
end;
{$ENDIF}

function AddrGetPort(const A, ADefPort: string): string;
var p: Integer;
begin
  p := AddrFindColon(A);
  if p > 0 then
    Result := Copy(A, p + 1, MaxInt)
  else
    Result := ADefPort;
end;
{$IFDEF UNICODE}
function AddrGetPort(const A, ADefPort: AnsiString): AnsiString;
var p: Integer;
begin
  p := G_CharPos(':', A);
  if p = 0 then
    Result := ADefPort
  else
    Result := Copy(A, p + 1, MaxInt)
end;
{$ENDIF}

function ExtractAddrPort(const A, ADefPort: string): string;
begin
  Result := AddrGetPort(A, ADefPort)
end;
{$IFDEF UNICODE}
function ExtractAddrPort(const A, ADefPort: AnsiString): AnsiString;
begin
  Result := AddrGetPort(A, ADefPort)
end;
{$ENDIF}

function AddrGetPort(const A: string; ADefPort: Word): Integer;
begin
  Result := StrToIntDef(AddrGetPort(A, EmptyStr), ADefPort)
end;
{$IFDEF UNICODE}
function AddrGetPort(const A: AnsiString; ADefPort: Word): Integer;
begin
  Result := AnsiStrToIntDef(AddrGetPort(A, EmptyAnsiStr), ADefPort)
end;
{$ENDIF}

function ExtractAddrPort(const A: string; ADefPort: Word): Integer;
begin
  Result := AddrGetPort(A, ADefPort)
end;
{$IFDEF UNICODE}
function ExtractAddrPort(const A: AnsiString; ADefPort: Word): Integer;
begin
  Result := AddrGetPort(A, ADefPort)
end;
{$ENDIF}








function MailFindAt(const A: string): Integer;
begin
  Result := {$IFDEF UNICODE}CharPos{$ELSE}G_CharPos{$ENDIF}('@', A);
end;

function MailGetName(const A: string): string;
var p: Integer;
begin
  p := MailFindAt(A);
  if p > 0 then
    Result := Copy(A, 1, p - 1)
  else
    Result := A
end;

function ExtractMailName(const A: string): string;
begin
  Result := MailGetName(A)
end;

function MailGetDomain(const A: string): string;
var p: Integer;
begin
  p := MailFindAt(A);
  if p > 0 then
    Result := Copy(A, p + 1, MaxInt)
  else
    Result := A
end;

function ExtractMailDomain(const A: string): string;
begin
  Result := MailGetDomain(A)
end;

{$ENDREGION}



{$REGION 'генерация'}
function UuidCreateRndStr(const ADelim, APrefix, APostfix: AnsiString): AnsiString;

  function _part(ALen: Integer): AnsiString;
  begin
    result := RandomChars(rawbytestring(gCharsHexStr), ALen)
  end;

begin
  Result := APrefix + _part(8) + ADelim + _part(4) + ADelim + _part(4) + ADelim + _part(4) + ADelim + _part(12) + APostfix
end;


type
  TNearChars = array[AnsiChar] of AnsiString;

function CreateNearCharsArray: TNearChars;
var
  ch: AnsiChar;
  s: AnsiString;

begin
  for ch := #0 to #255 do
  begin
    case ch of
      '1': s := '2qw';
      '2': s := '13qwe';
      '3': s := '24wer';
      '4': s := '35ert';
      '5': s := '46rty';
      '6': s := '57tyu';
      '7': s := '68yui';
      '8': s := '79uio';
      '9': s := '80iop';
      '0': s := '9op';
      'q': s := '12w';
      'w': s := '123qeasd';
      'e': s := '234rfdsw';
      'r': s := 'tgfde345';
      't': s := 'yhgfr456';
      'y': s := 'ujhgt567';
      'u': s := 'ikjhy678';
      'i': s := 'olkju789';
      'o': s := 'plki890';
      'p': s := 'lo90';
      'a': s := 'sxzqw';
      's': s := 'dcxzaqwe';
      'd': s := 'fvcxswer';
      'f': s := 'gbvcdert';
      'g': s := 'hnbvfrty';
      'h': s := 'jmnbgtyu';
      'j': s := 'kmnhyui';
      'k': s := 'lmjuio';
      'l': s := 'kiop';
      'z': s := 'xas';
      'x': s := 'czasd';
      'c': s := 'vxsdf';
      'v': s := 'bcdfg';
      'b': s := 'nvfgh';
      'n': s := 'mbghj';
      'm': s := 'nhjk';
      else
        s := 'a';
    end;
    Result[ch] := s;
  end;

end;

function GenSimplePassword(ALen: Integer): AnsiString;
const START_CHAR = ['a'..'z'];
var
  nearCh: TNearChars;
  j: Integer;
  ch: AnsiChar;
  s: AnsiString;
begin
  Randomize;
  nearCh := CreateNearCharsArray();
  ch := AnsiChar(RandomRange(Ord('a'), Ord('z')+1));
  Result := ch;
  for j := 2 to ALen do
  begin
    s := nearCh[ch];
    while True do
    begin
      if (j <= 2) or (Random(Alen+1) > 0) then
        ch := s[Random(Length(s))+ 1];
      if (j <= 2) or (Result[j - 2] <> ch) then
        if (Ord(ch) - Ord(Result[j-1]) <> 1) or (Ord(Result[j-1]) - Ord(Result[j-2]) <> 1) then
          Break;
    end;

    Result := Result + ch
  end;
end;
{$ENDREGION}


function StrToInterval(const A: string): Integer;
var
  z,s: string;
  p,k: Integer;
  ch: Char;
begin
  Result := 0;
  z := Trim(A);
  if z = '' then
  begin
    {$IFNDEF UNICODE}
    Result := 0;
    Exit;
    {$ELSE}
    Exit(0);
    {$ENDIF}
  end;

  while z <> '' do
  begin
    p := CharsPosNot(['0'..'9'], z);
    if p = 0 then
    begin
      {$IFNDEF UNICODE}
      Result := Result + StrToIntDef(z, 0);
      Exit;
      {$ELSE}
      Exit(Result + StrToIntDef(z, 0));
      {$ENDIF}
    end;
    s := Copy(z, 1, p - 1);
    ch := z[p];
    Delete(z, 1, p);
    k := StrToIntDef(s, 0);
    case ch of
      'D','d','Д','д': k := k * 24 * 60 * 60;
      'H','h','Ч','ч': k := k * 60 * 60;
      'M','m','М','м': k := k * 60;
      'S','s','С','с': k := k;
      else
        k := k;
    end;
    Result := Result + k;
  end;
end;

function CountOfChar(const S: string; C: Char): Integer;
var j: Integer;
begin
  Result := 0;
  for j := 1 to Length(S) do
    if S[j] = C then
      Inc(Result);
end;

function StringSplit(const A: string; const ADelim: Char;
  const AProcessing: PStringProcessingFunc;
  const AAddEmpty: Boolean): TStringDynArray;
var
  j,k,l,m: Integer;
  s: string;
begin
  if A = '' then
  begin
    Result := nil;
    Exit
  end;

  {$IFDEF UNICODE}
  m := CountOfChar(A, ADelim) + 1;
  {$ELSE}
  m := G_CountOfChar(A, ADelim) + 1;
  {$ENDIF}

  SetLength(Result, m);
  k := 0;
  l := Length(A);
  j := 1;
  while j <= l do
  begin
    s := StrCopy(j, A, ADelim);
    if Assigned(AProcessing) then
      s := TStringProcessingFunc(AProcessing)(s);
    if AAddEmpty or (s <> '') then
    begin
      if k >= m then
      begin
        m := m + 1;
        SetLength(Result, m);
      end;            
      Result[k] := s;
      k := k + 1;
    end;
  end;
  if k < m then
    SetLength(Result, k);
end;
{$IFDEF UNICODE}
function StringSplit(const A: AnsiString; const ADelim: AnsiChar;
  const AProcessing: PAnsiStringProcessingFunc;
  const AAddEmpty: Boolean): TAnsiStringDynArray;
var
  j,k,l,m: Integer;
  s: AnsiString;
begin
  if A = '' then
  begin
    Result := nil;
    Exit
  end;

  m := G_CountOfChar(A, ADelim) + 1;
  SetLength(Result, m);
  k := 0;
  l := Length(A);
  j := 1;
  while j <= l do
  begin
    s := StrCopy(j, A, ADelim);
    if Assigned(AProcessing) then
      s := TAnsiStringProcessingFunc(AProcessing)(s);
    if AAddEmpty or (s <> '') then
    begin
      if k >= m then
      begin
        m := m + 1;
        SetLength(Result, m);
      end;
      Result[k] := s;
      k := k + 1;
    end;
  end;
  if k < m then
    SetLength(Result, k);
end;
{$ENDIF}

function StringSplitTrim(const A: string; const ADelim: Char): TStringDynArray;
begin
  Result := StringSplit(A, ADelim, @SysUtils.Trim, False)
end;
{$IFDEF UNICODE}
function StringSplitTrim(const A: AnsiString; const ADelim: AnsiChar): TAnsiStringDynArray;
begin
  Result := StringSplit(A, ADelim, @AnsiStrings.Trim, False)
end;
{$ENDIF}

function StringJoin(const A: TStringDynArray; const ADelim: Char): string;
var j: Integer;
begin
  Result := '';
  for j := 0 to Length(A) - 1 do
  begin
    if Result = '' then
      Result := A[j]
    else
      Result := Result + ADelim + A[j] 
  end;
end;
{$IFDEF UNICODE}
function StringJoin(const A: TAnsiStringDynArray; const ADelim: AnsiChar): AnsiString;
var j: Integer;
begin
  Result := '';
  for j := 0 to Length(A) - 1 do
  begin
    if Result = '' then
      Result := A[j]
    else
      Result := Result + ADelim + A[j]
  end;
end;
{$ENDIF}


end.
