unit uFindInDirHelper;

interface

uses
  SysUtils, Classes, Types,
  uAnsiStringList, uGlobalTypes;

type
  IFindInDirResult = interface
    procedure Add(const A: string);
  end;

  TFindInDirResultStrings = class(TInterfacedObject, IFindInDirResult)
    List: TStrings;
    procedure Add(const A: string);
    constructor Create(const A: TStrings);
  end;

  {$IFDEF UNICODE}
  TFindInDirResultAnsiStrings = class(TInterfacedObject, IFindInDirResult)
    List: TAnsiStrings;
    procedure Add(const A: string);
    constructor Create(const A: TAnsiStrings);
  end;
  {$ELSE}
  TFindInDirResultAnsiStrings =  TFindInDirResultStrings;
  {$ENDIF}

  PStringDynArray = ^TStringDynArray;
  TFindInDirResultStringDynArray = class(TInterfacedObject, IFindInDirResult)
    List: PStringDynArray;
    procedure Add(const A: string);
    constructor Create(const A: PStringDynArray);
  end;

  {$IFDEF UNICODE}
  PAnsiStringDynArray = ^TAnsiStringDynArray;
  TFindInDirResultAnsiStringDynArray = class(TInterfacedObject, IFindInDirResult)
    List: PAnsiStringDynArray;
    procedure Add(const A: string);
    constructor Create(const A: PAnsiStringDynArray);
  end;
  {$ENDIF}

  PArrayString = ^TArrayString;
  TFindInDirResultArrayString = class(TInterfacedObject, IFindInDirResult)
    List: PArrayString;
    procedure Add(const A: string);
    constructor Create(const A: PArrayString);
  end;

  {$IFDEF UNICODE}
  PArrayAnsiString = ^TArrayAnsiString;
  TFindInDirResultArrayAnsiString = class(TInterfacedObject, IFindInDirResult)
    List: PArrayAnsiString;
    procedure Add(const A: string);
    constructor Create(const A: PArrayAnsiString);
  end;
  {$ENDIF}

implementation


{TFindInDirResultStrings}

constructor TFindInDirResultStrings.Create(const A: TStrings);
begin
  inherited Create;
  List := A;
end;

procedure TFindInDirResultStrings.Add(const A: string);
begin
  List.Add(A)
end;


{TFindInDirResultAnsiStrings}

{$IFDEF UNICODE}

constructor TFindInDirResultAnsiStrings.Create(const A: TAnsiStrings);
begin
  inherited Create;
  List := A;
end;

procedure TFindInDirResultAnsiStrings.Add(const A: string);
begin
  List.Add(A)
end;
{$ENDIF}


{TFindInDirResultStringDynArray}

constructor TFindInDirResultStringDynArray.Create(const A: PStringDynArray);
begin
  inherited Create;
  List := A;
end;

procedure TFindInDirResultStringDynArray.Add(const A: string);
var l: Integer;
begin
  l := Length(List^);
  SetLength(List^, l + 1);
  List^[l] := A;
end;


{TFindInDirResultAnsiStringDynArray} {$IFDEF UNICODE}

constructor TFindInDirResultAnsiStringDynArray.Create(const A: PAnsiStringDynArray);
begin
  inherited Create;
  List := A;
end;

procedure TFindInDirResultAnsiStringDynArray.Add(const A: string);
var l: Integer;
begin
  l := Length(List^);
  SetLength(List^, l + 1);
  List^[l] := AnsiString(A);
end;
{$ENDIF}


{TFindInDirResultArrayString}

constructor TFindInDirResultArrayString.Create(const A: PArrayString);
begin
  inherited Create;
  List := A;
end;

procedure TFindInDirResultArrayString.Add(const A: string);
var l: Integer;
begin
  l := Length(List^);
  SetLength(List^, l + 1);
  List^[l] := A;
end;


{TFindInDirResultArrayAnsiString} {$IFDEF UNICODE}

constructor TFindInDirResultArrayAnsiString.Create(const A: PArrayAnsiString);
begin
  inherited Create;
  List := A;
end;

procedure TFindInDirResultArrayAnsiString.Add(const A: string);
var l: Integer;
begin
  l := Length(List^);
  SetLength(List^, l + 1);
  List^[l] := AnsiString(A)
end;
{$ENDIF}


end.
