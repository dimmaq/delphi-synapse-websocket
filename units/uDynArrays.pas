unit uDynArrays;

interface

uses
  Types, Math,
  //
  uGlobalTypes;




procedure DynArr_Init(var Arr: TAnsiStringDynArray); {$IFDEF UNICODE}overload;
procedure DynArr_Init(var Arr: TStringDynArray); overload;{$ENDIF}
function DynArr_Add(var Arr: TAnsiStringDynArray; const Val: AnsiString): Integer; overload;
{$IFDEF UNICODE}function DynArr_Add(var Arr: TStringDynArray; const Val: string): Integer; overload;{$ENDIF}
function DynArr_Add(var AArr: TRawByteStringDynArray; const AVal: RawByteString): Integer; overload;
function DynArr_Add(var Arr: TIntegerDynArray; const AVal: Integer): Integer; overload;
function DynArr_ToString(const Arr: TAnsiStringDynArray): AnsiString;
function DynArr_IndexOf(const Arr: TStringDynArray; const Val: string): Integer; overload;
{$IFDEF UNICODE}function DynArr_IndexOf(const Arr: TAnsiStringDynArray; const Val: AnsiString): Integer; overload; {$ENDIF}
function DynArr_IndexOf(const AArr: TRawByteStringDynArray; const AVal: RawByteString): Integer; overload;
procedure DynArr_Remove(var AArr: TRawByteStringDynArray; const AVal: RawByteString);
procedure DynArr_Delete(var AArr: TRawByteStringDynArray; const AIndex: Integer);  overload;
procedure DynArr_Delete(var AArr: TIntegerDynArray; const AIndex: Integer);  overload;

procedure DynArr_Sort(var AArr: TIntegerDynArray; AOrder: Boolean = True);
procedure DynArr_Rand(var AArr: TStringDynArray);

function IsStringDynArrayCross(const A, B: TRawByteStringDynArray): Boolean;


implementation

{$IFDEF UNICODE}
procedure DynArr_Init(var Arr: TAnsiStringDynArray);
begin
  SetLength(Arr, 0);
end;

function DynArr_Add(var Arr: TAnsiStringDynArray; const Val: AnsiString): Integer;
begin
  Result := Length(Arr);
  SetLength(Arr, Result + 1);
  Arr[Result] := Val;
end;
 {$ENDIF}

function DynArr_Add(var Arr: TIntegerDynArray; const AVal: Integer): Integer; overload;
begin
  Result := Length(Arr);
  SetLength(Arr, Result + 1);
  Arr[Result] := AVal;
end;

procedure DynArr_Init(var Arr: TStringDynArray);
begin
  SetLength(Arr, 0);
end;

function DynArr_Add(var Arr: TStringDynArray; const Val: string): Integer;
begin
  Result := Length(Arr);
  SetLength(Arr, Result + 1);
  Arr[Result] := Val;
end;

function DynArr_Add(var AArr: TRawByteStringDynArray; const AVal: RawByteString): Integer;
begin
  Result := Length(AArr);
  SetLength(AArr, Result + 1);
  AArr[Result] := AVal;
end;


function DynArr_ToString(const Arr: TAnsiStringDynArray): AnsiString;
var j: Integer;
begin
  Result := '';
  for j := Low(Arr) to High(Arr) do
    if Result = '' then
      Result := Arr[j]
    else
      Result := Result + ', ' + Arr[j]
end;

function DynArr_IndexOf(const Arr: TStringDynArray; const Val: string): Integer;
var j: Integer;
begin
  for j := Low(Arr) to High(Arr) do
  begin
    if Arr[j] = Val then
    begin
      Result := j;
      Exit;
    end;
  end;
  Result := -1;
end;
{$IFDEF UNICODE}
function DynArr_IndexOf(const Arr: TAnsiStringDynArray; const Val: AnsiString): Integer;
var j: Integer;
begin
  for j := Low(Arr) to High(Arr) do
  begin
    if Arr[j] = Val then
    begin
      Result := j;
      Exit;
    end;
  end;
  Result := -1;
end;
 {$ENDIF}
function DynArr_IndexOf(const AArr: TRawByteStringDynArray; const AVal: RawByteString): Integer;
var j: Integer;
begin
  for j := Low(AArr) to High(AArr) do
  begin
    if AArr[j] = AVal then
    begin
      Result := j;
      Exit;
    end;
  end;
  Result := -1;
end;

procedure DynArr_Delete(var AArr: TIntegerDynArray; const AIndex: Integer);
var l, j: Integer;
begin
  l := Length(AArr);
  Dec(l);
  if not InRange(AIndex, 0, l) then
    Exit;

  if AIndex < l then
  begin
    for j := AIndex + 1 to l do
    begin
      AArr[j - 1] := AArr[j];
    end;
  end;
  SetLength(AArr, l);
end;

procedure DynArr_Delete(var AArr: TRawByteStringDynArray; const AIndex: Integer);
var l, j: Integer;
begin
  l := Length(AArr);
  Dec(l);
  if not InRange(AIndex, 0, l) then
    Exit;

  if AIndex < l then
  begin
    for j := AIndex + 1 to l do
    begin
      AArr[j - 1] := AArr[j];
    end;
  end;
  SetLength(AArr, l);
end;

procedure DynArr_Remove(var AArr: TRawByteStringDynArray; const AVal: RawByteString);
var k: Integer;
begin
  k := DynArr_IndexOf(aarr, AVal);
  if k = -1 then
    Exit;
  DynArr_Delete(AArr, k)
end;

function IsStringDynArrayCross(const A, B: TRawByteStringDynArray): Boolean;
var
  j,i,ka,kb: Integer;
  z: RawByteString;
begin
  ka := Length(A);
  kb := Length(B);
  if (ka > 0) and (kb > 0) then
  begin
    for j := Low(A) to High(A) do
    begin
      z := A[j];
      for i := Low(B) to High(B) do
      begin
        if b[i] = z then
        begin
          Result := True;
          Exit;
        end;
      end;
    end;
  end;
  Result := False
end;

procedure QuickSort(var AArr: TIntegerDynArray; L, R: Integer;
  AOrder: Boolean);
var
  I, J: Integer;
  P, T: Integer;

  function SCompare(A, B: Integer): Integer;
  begin
    if AOrder then
      Result := A - B
    else
      Result := B - A
  end;

begin
  repeat
    I := L;
    J := R;
    P := AArr[(L + R) shr 1];
    repeat
      while SCompare(AArr[I], P) < 0 do
        Inc(I);
      while SCompare(AArr[J], P) > 0 do
        Dec(J);
      if I <= J then
      begin
        T := AArr[I];
        AArr[I] := AArr[J];
        AArr[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSort(AArr, L, J, AOrder);
    L := I;
  until I >= R;
end;

procedure DynArr_Sort(var AArr: TIntegerDynArray; AOrder: Boolean);
var l: Integer;
begin
  l := Length(AArr);
  if l > 1 then
    QuickSort(AArr, 0, l - 1, AOrder);
end;

procedure DynArr_Rand(var AArr: TStringDynArray);
var
  l, j, k: Integer;
  z: string;
begin
  l := Length(AArr);
  for j := 0 to l - 1 do
  begin
    k := Random(l);
    z := AArr[j];
    AArr[j] := AArr[k];
    AArr[k] := z;
  end;
end;

end.
