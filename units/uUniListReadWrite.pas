unit uUniListReadWrite;

interface

uses
  Classes,
  uAnsiStringList;

type
  IUniListReader = interface
  ['{CCF10144-D5E9-41D9-BC99-66DC4843C73F}']
    function MoveNext: Boolean;
    function GetCurrentAsAnsiString: AnsiString;
  end;

  IUniListWriter = interface
  ['{9E29D319-6333-42CE-A1C6-D294D4CA9673}']
    function AddAnsiString(const S: AnsiString): Integer;
    procedure BeginUpdate;
    procedure EndUpdate;
  end;

  TStringsReadWrite = class(TInterfacedObject, IUniListReader, IUniListWriter)
  private
    FIndex: Integer;
    FStrings: TStrings;
  public
    constructor Create(AStrings: TStrings);
    //---
    procedure BeginUpdate;
    procedure EndUpdate;
    function MoveNext: Boolean;
    function AddString(const S: string): Integer;
    function AddAnsiString(const S: AnsiString): Integer;
    function GetCurrentAsString: string;
    function GetCurrentAsAnsiString: AnsiString;
    property CurrentAsAnsiString: AnsiString read GetCurrentAsAnsiString;
  end;

  TAnsiStringsReadWrite = class(TInterfacedObject, IUniListReader, IUniListWriter)
  private
    FIndex: Integer;
    FStrings: TAnsiStrings;
  public
    constructor Create(AStrings: TAnsiStrings);
    //---
    procedure BeginUpdate;
    procedure EndUpdate;
    function MoveNext: Boolean;
    function AddAnsiString(const S: AnsiString): Integer;
    function GetCurrentAsAnsiString: AnsiString;
    property CurrentAsAnsiString: AnsiString read GetCurrentAsAnsiString;
  end;

implementation

{ TStringsEnumerator }

function TStringsReadWrite.AddAnsiString(const S: AnsiString): Integer;
begin
  Result := AddString(string(S))
end;

function TStringsReadWrite.AddString(const S: string): Integer;
begin
  Result := FStrings.Add(S)
end;

procedure TStringsReadWrite.BeginUpdate;
begin
  FStrings.BeginUpdate
end;

constructor TStringsReadWrite.Create(AStrings: TStrings);
begin
  inherited Create;
  FIndex := -1;
  FStrings := AStrings;
end;

procedure TStringsReadWrite.EndUpdate;
begin
  FStrings.EndUpdate
end;

function TStringsReadWrite.GetCurrentAsAnsiString: AnsiString;
begin
  Result := AnsiString(GetCurrentAsString())
end;

function TStringsReadWrite.GetCurrentAsString: string;
begin
  Result := FStrings[FIndex];
end;

function TStringsReadWrite.MoveNext: Boolean;
begin
  Result := FIndex < FStrings.Count - 1;
  if Result then
    Inc(FIndex);
end;

{ TAnsiStringsEnumerator }

function TAnsiStringsReadWrite.AddAnsiString(const S: AnsiString): Integer;
begin
  Result := FStrings.Add(S)
end;

procedure TAnsiStringsReadWrite.BeginUpdate;
begin
  FStrings.BeginUpdate;
end;

constructor TAnsiStringsReadWrite.Create(AStrings: TAnsiStrings);
begin
  inherited Create;
  FIndex := -1;
  FStrings := AStrings;
end;

procedure TAnsiStringsReadWrite.EndUpdate;
begin
  FStrings.EndUpdate
end;

function TAnsiStringsReadWrite.GetCurrentAsAnsiString: AnsiString;
begin
  Result := FStrings[FIndex]
end;

function TAnsiStringsReadWrite.MoveNext: Boolean;
begin
  Result := FIndex < FStrings.Count - 1;
  if Result then
    Inc(FIndex);
end;

end.
