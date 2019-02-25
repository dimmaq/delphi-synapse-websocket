unit uGlobalTypes;

interface

uses
  Classes, SysUtils, Types
  {$IFNDEF UNICODE}, AcedStrings{$ENDIF}
  ;

type


  {$IFDEF UNICODE}
  TArrayString = TArray<string>;
  TArrayAnsiString = TArray<AnsiString>;
  TArrayRawByteString = TArray<RawByteString>;
  {$ELSE}
  RawByteString = AnsiString;
  TArrayString = array of string;
  TArrayAnsiString = array of AnsiString;
  TArrayRawByteString = array of RawByteString;
  {$ENDIF}

//  TStringDynArray = array of string;
  {$IFDEF UNICODE}
  TAnsiStringDynArray = array of AnsiString;
  {$ELSE}
  TAnsiStringDynArray = TStringDynArray;
  {$ENDIF}


  TRawByteStringDynArray = TArrayRawByteString;//array of RawByteString;

  {$IFNDEF UNICODE}
  TStringBuilder = AcedStrings.TAnsiStringBuilder;
  {$ENDIF}


  {$IFNDEF UNICODE}
//    RawByteString = AnsiString;
//    UnicodeString = AnsiString;
    TCharArray = array of Char; {SysUtils}
  {$ENDIF}

  //TAnsiCharSet = set of AnsiChar; TSysCharSet

//  TSetOfAnsiChar = set of AnsiChar;
//  TSetOfChar = set of Char;

  TStrIntRec = record
    S: string;
    I: Integer;
  end;

  TStrIntArray = array of TStrIntRec;

  TAnsiStrIntRec = record
    S: AnsiString;
    I: Integer;
  end;
  TAStrIntRec = TAnsiStrIntRec;

  TAnsiStrIntArray = array of TAnsiStrIntRec;


  TSimpleLogEvent = procedure(const AText: AnsiString) of object;

  TStringConvert = function(const S: string): string of object;

  TNextFilterRes3 = (NEXT_FILTER_FALSE, NEXT_FILTER_TRUE, NEXT_FILTER_BREAK);  

function ArrayStringToArrayRawByteString(const A: TArrayString): TArrayRawByteString;

implementation


function ArrayStringToArrayRawByteString(const A: TArrayString): TArrayRawByteString;
var j: Integer;
begin
  SetLength(Result, Length(A));
  for j := 0 to Length(A) - 1 do
    Result[j] := rawbytestring(A[j])
end;

end.
