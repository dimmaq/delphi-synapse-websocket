unit uAnsiStringList;

interface

{$IFNDEF UNICODE}

uses
  Classes;

type
  TAnsiStrings = TStrings;
  TAnsiStringList = TStringList;
  TAnsiStringListSimple = TStringList;


implementation

{$ELSE}

uses
  System.Classes, System.SysUtils;

type

{ TAnsiStrings class }

  TAnsiStrings = class;

  TAnsiStringsEnumerator = class
  private
    FIndex: Integer;
    FStrings: TAnsiStrings;
  public
    constructor Create(AStrings: TAnsiStrings);
    function GetCurrent: AnsiString; inline;
    function MoveNext: Boolean;
    property Current: AnsiString read GetCurrent;
  end;

  TAnsiStrings = class(TPersistent)
  private
    FEncoding: TEncoding;
    FDefaultEncoding: TEncoding;
    FLineBreak: AnsiString;
//    FAdapter: IStringsAdapter;
    FUpdateCount: Integer;
    FDelimiter: AnsiChar;
    FQuoteChar: AnsiChar;
    FNameValueSeparator: AnsiChar;
    FOptions: TStringsOptions;
    function GetCommaText: AnsiString;
    function GetDelimitedText: AnsiString;
    function GetName(Index: Integer): AnsiString;
    function GetValue(const Name: AnsiString): AnsiString;
    procedure ReadData(Reader: TReader);
    procedure SetCommaText(const Value: AnsiString);
    procedure SetDelimitedText(const Value: AnsiString);
    //procedure SetAnsiStringsAdapter(const Value: IStringsAdapter);
    procedure SetValue(const Name, Value: AnsiString);
    procedure WriteData(Writer: TWriter);
    function GetStrictDelimiter: Boolean; inline;
    procedure SetStrictDelimiter(const Value: Boolean);
    function GetValueFromIndex(Index: Integer): AnsiString;
    procedure SetValueFromIndex(Index: Integer; const Value: AnsiString);
    procedure SetDefaultEncoding(const Value: TEncoding);
    function GetTrailingLineBreak: Boolean; inline;
    procedure SetTrailingLineBreak(const Value: Boolean);
    function GetUseLocale: Boolean; inline;
    procedure SetUseLocale(const Value: Boolean);
    function GetWriteBOM: Boolean; inline;
    procedure SetWriteBOM(const Value: Boolean);
    function GetUpdating: Boolean; inline;
    function GetKeyName(Index: Integer): AnsiString;
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure Error(const Msg: string; Data: Integer); overload;
    procedure Error(Msg: PResStringRec; Data: Integer); overload;
    function ExtractName(const S: AnsiString): AnsiString; overload; inline;
    function ExtractName(const S: AnsiString; AllNames: Boolean): AnsiString; overload;
    function Get(Index: Integer): AnsiString; virtual; abstract;
    function GetCapacity: Integer; virtual;
    function GetCount: Integer; virtual; abstract;
    function GetObject(Index: Integer): TObject; virtual;
    function GetTextStr: AnsiString; virtual;
    procedure Put(Index: Integer; const S: AnsiString); virtual;
    procedure PutObject(Index: Integer; AObject: TObject); virtual;
    procedure SetCapacity(NewCapacity: Integer); virtual;
    procedure SetEncoding(const Value: TEncoding); virtual;
    procedure SetTextStr(const Value: AnsiString); virtual;
    procedure SetUpdateState(Updating: Boolean); virtual;
    function CompareStrings(const S1, S2: AnsiString): Integer; virtual;
    property UpdateCount: Integer read FUpdateCount;
  public
    constructor Create; overload;
    destructor Destroy; override;
    function Add(const S: AnsiString): Integer; overload; virtual;
    function Add(const S: string): Integer; overload; virtual;
    /// <summary>
    ///    Adds Name=Value list item using current NameValueSeparator. Method
    ///    returns reference to this AnsiString list, allowing to populate list
    ///    using fluent coding style.
    /// </summary>
    function AddPair(const Name, Value: AnsiString): TAnsiStrings; overload;
    /// <summary>
    ///    Adds Name=Value list item and corresponding AObject using current
    ///    NameValueSeparator. Method returns reference to this AnsiString list,
    ///    allowing to populate list using fluent coding style.
    /// </summary>
    function AddPair(const Name, Value: AnsiString; AObject: TObject): TAnsiStrings; overload;
    function AddObject(const S: AnsiString; AObject: TObject): Integer; virtual;
    procedure Append(const S: AnsiString);
    procedure AddStrings(Strings: TAnsiStrings); overload; virtual;
    procedure AddStrings(Strings: TStrings); overload; virtual;
    procedure AddStrings(const Strings: TArray<AnsiString>); overload;
    procedure AddStrings(const Strings: TArray<AnsiString>; const Objects: TArray<TObject>); overload;
    procedure Assign(Source: TPersistent); override;
    /// <summary>
    ///    Assigns the strings from another TAnsiStrings object to this list.
    ///    Before assignment this list will be erased. The main difference
    ///    between Assign and SeTAnsiStrings methods is that SeTAnsiStrings method
    ///    preserves other properties, like QuoteChar or Delimiter.
    /// </summary>
    procedure SetStrings(Source: TAnsiStrings);
    procedure BeginUpdate;
    procedure Clear; virtual; abstract;
    procedure Delete(Index: Integer); virtual; abstract;
    procedure EndUpdate;
    function Equals(Strings: TAnsiStrings): Boolean; reintroduce;
    procedure Exchange(Index1, Index2: Integer); virtual;
    function GetEnumerator: TAnsiStringsEnumerator;
    function GetText: PAnsiChar; virtual;
    function IndexOf(const S: AnsiString): Integer; virtual;
    function IndexOfName(const Name: AnsiString): Integer; virtual;
    function IndexOfObject(AObject: TObject): Integer; virtual;
    procedure Insert(Index: Integer; const S: AnsiString); virtual; abstract;
    procedure InsertObject(Index: Integer; const S: AnsiString;
      AObject: TObject); virtual;
    procedure LoadFromFileIfExists(const FileName: TFileName);
    procedure LoadFromFile(const FileName: TFileName); overload; virtual;
    procedure LoadFromFile(const FileName: TFileName; Encoding: TEncoding); overload; virtual;
    procedure LoadFromStream(Stream: TStream); overload; virtual;
    procedure LoadFromStream(Stream: TStream; Encoding: TEncoding); overload; virtual;
    procedure Move(CurIndex, NewIndex: Integer); virtual;
    procedure SaveToFile(const FileName: TFileName); overload; virtual;
    procedure SaveToFile(const FileName: TFileName; Encoding: TEncoding); overload; virtual;
    procedure SaveToStream(Stream: TStream); overload; virtual;
    procedure SaveToStream(Stream: TStream; Encoding: TEncoding); overload; virtual;
    procedure SetText(Text: PAnsiChar); virtual;
    function ToStringArray: TArray<AnsiString>;
    function ToObjectArray: TArray<TObject>;
    /// <summary>
    ///    Returns True, when UpdateCount is greater than zero. It is greater
    ///    than zero inside of BeginUpdate / EndUpdate calls.
    /// </summary>
    property Updating: Boolean read GetUpdating;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property CommaText: AnsiString read GetCommaText write SetCommaText;
    property Count: Integer read GetCount;
    property DefaultEncoding: TEncoding read FDefaultEncoding write SetDefaultEncoding;
    property Delimiter: AnsiChar read FDelimiter write FDelimiter;
    property DelimitedText: AnsiString read GetDelimitedText write SetDelimitedText;
    property Encoding: TEncoding read FEncoding;
    property LineBreak: AnsiString read FLineBreak write FLineBreak;
    property Names[Index: Integer]: AnsiString read GetName;
    /// <summary>
    ///    When the list of strings includes strings that are name-value pairs or just names,
    ///    read Keys to access the name part of a AnsiString. If the AnsiString is not a name-value
    ///    pair, Keys returns full AnsiString. Assigning Keys will write new name for name-value
    ///    pair. This is in contrast to Names property.
    /// </summary>
    property KeyNames[Index: Integer]: AnsiString read GetKeyName;
    property Objects[Index: Integer]: TObject read GetObject write PutObject;
    property QuoteChar: AnsiChar read FQuoteChar write FQuoteChar;
    property Values[const Name: AnsiString]: AnsiString read GetValue write SetValue;
    property ValueFromIndex[Index: Integer]: AnsiString read GetValueFromIndex write SetValueFromIndex;
    property NameValueSeparator: AnsiChar read FNameValueSeparator write FNameValueSeparator;
    property StrictDelimiter: Boolean read GetStrictDelimiter write SetStrictDelimiter;
    property Strings[Index: Integer]: AnsiString read Get write Put; default;
    property Text: AnsiString read GetTextStr write SetTextStr;
//    property StringsAdapter: IStringsAdapter read FAdapter write SeTAnsiStringsAdapter;
    property WriteBOM: Boolean read GetWriteBOM write SetWriteBOM;
    /// <summary>
    ///    When TrailingLineBreak property is True (default value) then Text property
    ///    will contain line break after last line. When it is False, then Text value
    ///    will not contain line break after last line. This also may be controlled
    ///    by soTrailingLineBreak option.
    /// </summary>
    property TrailingLineBreak: Boolean read GetTrailingLineBreak write SetTrailingLineBreak;
    /// <summary>
    ///    When UseLocale property is True (default value) then AnsiString list will use
    ///    AnsiCompareStr/AnsiCompareText functions to compare strings. When it is False
    ///    then CompareStr/CompareText functions will be used. This also may be controlled
    ///    by soUseLocale option.
    /// </summary>
    property UseLocale: Boolean read GetUseLocale write SetUseLocale;
    /// <summary>
    ///    Options property controls different aspects of AnsiString list. Each option
    ///    corresponds to one of the Boolean AnsiString list properties, eg soUseLocale
    ///    to UseLocale property.
    /// </summary>
    property Options: TStringsOptions read FOptions write FOptions;
  end;

{ TAnsiStringList class }

  TAnsiStringList = class;

  PAnsiStringItem = ^TAnsiStringItem;
  TAnsiStringItem = record
    FString: AnsiString;
    FObject: TObject;
  end;

  PAnsiStringItemList = ^TAnsiStringItemList;
  TAnsiStringItemList = array of TAnsiStringItem;
  TAnsiStringListSortCompare = function(List: TAnsiStringList; Index1, Index2: Integer): Integer;

  TAnsiStringList = class(TAnsiStrings)
  private
    FList: TAnsiStringItemList;
    FCount: Integer;
    FCapacity: Integer;
    FSorted: Boolean;
    FDuplicates: TDuplicates;
    FCaseSensitive: Boolean;
    FOnChange: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    FOwnsObject: Boolean;
    procedure Grow;
    procedure QuickSort(L, R: Integer; SCompare: TAnsiStringListSortCompare);
    procedure SetSorted(Value: Boolean);
    procedure SetCaseSensitive(const Value: Boolean);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure Changed; virtual;
    procedure Changing; virtual;
    procedure ExchangeItems(Index1, Index2: Integer);
    function Get(Index: Integer): AnsiString; override;
    function GetCapacity: Integer; override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
    procedure Put(Index: Integer; const S: AnsiString); override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
    procedure SetCapacity(NewCapacity: Integer); override;
    procedure SetUpdateState(Updating: Boolean); override;
    function CompareStrings(const S1, S2: AnsiString): Integer; override;
    procedure InsertItem(Index: Integer; const S: AnsiString; AObject: TObject); virtual;
  public
    constructor Create; overload;
    constructor Create(OwnsObjects: Boolean); overload;
    /// <summary>
    ///    This constructor creates new AnsiString list with specified QuoteChar
    ///    and Delimiter property values.
    /// </summary>
    constructor Create(QuoteChar, Delimiter: AnsiChar); overload;
    /// <summary>
    ///    This constructor creates new AnsiString list with specified QuoteChar,
    ///    Delimiter and Options property values.
    /// </summary>
    constructor Create(QuoteChar, Delimiter: AnsiChar; Options: TStringsOptions); overload;
    /// <summary>
    ///    This constructor creates new AnsiString list with specified Duplicates,
    ///    Sorted and CaseSensitive property values.
    /// </summary>
    constructor Create(Duplicates: TDuplicates; Sorted: Boolean; CaseSensitive: Boolean); overload;
    destructor Destroy; override;
    function Add(const S: AnsiString): Integer; override;
    function AddObject(const S: AnsiString; AObject: TObject): Integer; override;
    procedure Assign(Source: TPersistent); override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Exchange(Index1, Index2: Integer); override;
    function Find(const S: AnsiString; var Index: Integer): Boolean; virtual;
    function IndexOf(const S: AnsiString): Integer; override;
    procedure Insert(Index: Integer; const S: AnsiString); override;
    procedure InsertObject(Index: Integer; const S: AnsiString;
      AObject: TObject); override;
    procedure Sort; virtual;
    procedure CustomSort(Compare: TAnsiStringListSortCompare); virtual;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    property Sorted: Boolean read FSorted write SetSorted;
    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    property OwnsObjects: Boolean read FOwnsObject write FOwnsObject;
  end;

  TAnsiStringListSimple = class;

  PAnsiStringSimpleItem = ^TAnsiStringSimpleItem;
  TAnsiStringSimpleItem = AnsiString;

  PAnsiStringSimpleItemList = ^TAnsiStringSimpleItemList;
  TAnsiStringSimpleItemList = array of TAnsiStringSimpleItem;
  TAnsiStringListSimpleSortCompare = function(List: TAnsiStringListSimple; Index1, Index2: Integer): Integer;


  TAnsiStringListSimple = class(TAnsiStrings)
  private
    FList: TAnsiStringSimpleItemList;
    FCount: Integer;
    FCapacity: Integer;
    FSorted: Boolean;
    FDuplicates: TDuplicates;
    FCaseSensitive: Boolean;
    FOnChange: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    procedure Grow;
    procedure QuickSort(L, R: Integer; SCompare: TAnsiStringListSimpleSortCompare);
    procedure SetSorted(Value: Boolean);
    procedure SetCaseSensitive(const Value: Boolean);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure Changed; virtual;
    procedure Changing; virtual;
    procedure ExchangeItems(Index1, Index2: Integer);
    function Get(Index: Integer): AnsiString; override;
    function GetCapacity: Integer; override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
    procedure Put(Index: Integer; const S: AnsiString); override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
    procedure SetCapacity(NewCapacity: Integer); override;
    procedure SetUpdateState(Updating: Boolean); override;
    function CompareStrings(const S1, S2: AnsiString): Integer; override;
    procedure InsertItem(Index: Integer; const S: AnsiString; AObject: TObject); virtual;
  public
    constructor Create; overload;
    constructor Create(OwnsObjects: Boolean); overload;
    /// <summary>
    ///    This constructor creates new AnsiString list with specified QuoteChar
    ///    and Delimiter property values.
    /// </summary>
    constructor Create(QuoteChar, Delimiter: AnsiChar); overload;
    /// <summary>
    ///    This constructor creates new AnsiString list with specified QuoteChar,
    ///    Delimiter and Options property values.
    /// </summary>
    constructor Create(QuoteChar, Delimiter: AnsiChar; Options: TStringsOptions); overload;
    /// <summary>
    ///    This constructor creates new AnsiString list with specified Duplicates,
    ///    Sorted and CaseSensitive property values.
    /// </summary>
    constructor Create(Duplicates: TDuplicates; Sorted: Boolean; CaseSensitive: Boolean); overload;
    destructor Destroy; override;
    function Add(const S: AnsiString): Integer; override;
    function AddObject(const S: AnsiString; AObject: TObject): Integer; override;
    procedure Assign(Source: TPersistent); override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Exchange(Index1, Index2: Integer); override;
    function Find(const S: AnsiString; var Index: Integer): Boolean; virtual;
    function IndexOf(const S: AnsiString): Integer; override;
    procedure Insert(Index: Integer; const S: AnsiString); override;
    procedure InsertObject(Index: Integer; const S: AnsiString;
      AObject: TObject); override;
    procedure Sort; virtual;
    procedure CustomSort(Compare: TAnsiStringListSimpleSortCompare); virtual;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    property Sorted: Boolean read FSorted write SetSorted;
    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
  end;

implementation

uses
  System.RTLConsts, Winapi.Windows, System.AnsiStrings,
  //
  AcedStrings;


function NextAnsiChar(P: PAnsiChar): PAnsiChar;
begin
{
  Result := P;
  if (Result <> nil) and (Result^ <> #0) then
  begin
    Inc(Result);
    if Result^.IsLowSurrogate then
      Inc(Result);
    while Result^.GetUnicodeCategory = TUnicodeCategory.ucNonSpacingMark do
      Inc(Result);
  end;
}
  Result := System.AnsiStrings.StrNextChar(P)
end;

{ TAnsiStringsEnumerator }

constructor TAnsiStringsEnumerator.Create(AStrings: TAnsiStrings);
begin
  inherited Create;
  FIndex := -1;
  FStrings := AStrings;
end;

function TAnsiStringsEnumerator.GetCurrent: AnsiString;
begin
  Result := FStrings[FIndex];
end;

function TAnsiStringsEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FStrings.Count - 1;
  if Result then
    Inc(FIndex);
end;

{ TAnsiStrings }

constructor TAnsiStrings.Create;
begin
  inherited Create;
  FDefaultEncoding := TEncoding.Default;
  FLineBreak := sLineBreak;
  FDelimiter := ',';
  FQuoteChar := '"';
  FNameValueSeparator := '=';
  FOptions := [soWriteBOM, soTrailingLineBreak, soUseLocale];
end;

destructor TAnsiStrings.Destroy;
begin
  if (FEncoding <> nil) and not TEncoding.IsStandardEncoding(FEncoding) then
    FreeAndNil(FEncoding);
  if not TEncoding.IsStandardEncoding(FDefaultEncoding) then
    FreeAndNil(FDefaultEncoding);
  //StringsAdapter := nil;
  inherited Destroy;
end;

function TAnsiStrings.Add(const S: AnsiString): Integer;
begin
  Result := GetCount;
  Insert(Result, S);
end;

function TAnsiStrings.Add(const S: string): Integer;
begin
  Result := Add(AnsiString(S)) // cast
end;

function TAnsiStrings.AddPair(const Name, Value: AnsiString): TAnsiStrings;
begin
  Add(Name + NameValueSeparator + Value);
  Result := Self;
end;

function TAnsiStrings.AddPair(const Name, Value: AnsiString; AObject: TObject): TAnsiStrings;
begin
  AddObject(Name + NameValueSeparator + Value, AObject);
  Result := Self;
end;

function TAnsiStrings.AddObject(const S: AnsiString; AObject: TObject): Integer;
begin
  Result := Add(S);
  PutObject(Result, AObject);
end;

procedure TAnsiStrings.Append(const S: AnsiString);
begin
  Add(S);
end;

procedure TAnsiStrings.AddStrings(Strings: TAnsiStrings);
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := 0 to Strings.Count - 1 do
      AddObject(Strings[I], Strings.Objects[I]);
  finally
    EndUpdate;
  end;
end;

procedure TAnsiStrings.AddStrings(Strings: TStrings);
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := 0 to Strings.Count - 1 do
      AddObject(AnsiString(Strings[I]), Strings.Objects[I]); // cast
  finally
    EndUpdate;
  end;
end;

procedure TAnsiStrings.AddStrings(const Strings: TArray<AnsiString>);
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := Low(Strings) to High(Strings) do
      Add(Strings[I]);
  finally
    EndUpdate;
  end;
end;

procedure TAnsiStrings.AddStrings(const Strings: TArray<AnsiString>; const Objects: TArray<TObject>);
var
  I: Integer;
begin
  if Length(Strings) <> Length(Objects) then
    raise EArgumentOutOfRangeException.CreateRes(@System.RTLConsts.sInvalidStringAndObjectArrays);
  BeginUpdate;
  try
    for I := Low(Strings) to High(Strings) do
      AddObject(Strings[I], Objects[I]);
  finally
    EndUpdate;
  end;
end;

procedure TAnsiStrings.Assign(Source: TPersistent);
begin
  if Source is TAnsiStrings then
  begin
    BeginUpdate;
    try
      Clear;
      // Must use property setter for DefaultEncoding
      DefaultEncoding := TAnsiStrings(Source).FDefaultEncoding;
      // Must use internal property setter for Encoding
      SetEncoding(TAnsiStrings(Source).FEncoding);
      FLineBreak := TAnsiStrings(Source).FLineBreak;
      FDelimiter := TAnsiStrings(Source).FDelimiter;
      FQuoteChar := TAnsiStrings(Source).FQuoteChar;
      FNameValueSeparator := TAnsiStrings(Source).FNameValueSeparator;
      FOptions := TAnsiStrings(Source).FOptions;
      AddStrings(TAnsiStrings(Source));
    finally
      EndUpdate;
    end;
    Exit;
  end;

  if Source is TStrings then
  begin
    BeginUpdate;
    try
      Clear;
      // Must use property setter for DefaultEncoding
      DefaultEncoding := TStrings(Source).DefaultEncoding;
      // Must use internal property setter for Encoding
      SetEncoding(TStrings(Source).Encoding);
      FLineBreak := AnsiString(TStrings(Source).LineBreak); // cast
      FDelimiter := AnsiChar(TStrings(Source).Delimiter); // cast
      FQuoteChar := AnsiChar(TStrings(Source).QuoteChar); // cast
      FNameValueSeparator := AnsiChar(TStrings(Source).NameValueSeparator); // cast
      FOptions := TStrings(Source).Options;

      AddStrings(TStrings(Source));
    finally
      EndUpdate;
    end;
    Exit;
  end;

  inherited Assign(Source);
end;

procedure TAnsiStrings.AssignTo(Dest: TPersistent);
var
  I: Integer;
begin
  if Dest is TStrings then
  begin
    BeginUpdate;
    try
      TStrings(Dest).Clear;
      // Must use property setter for DefaultEncoding
      TStrings(Dest).DefaultEncoding := DefaultEncoding;
      // Must use internal property setter for Encoding
      //TStrings(Dest).Encoding := Encoding;
      TStrings(Dest).LineBreak := string(LineBreak); // cast
      TStrings(Dest).Delimiter := Char(Delimiter); // cast
      TStrings(Dest).QuoteChar := Char(QuoteChar); // cast
      TStrings(Dest).NameValueSeparator := Char(NameValueSeparator); // cast
      TStrings(Dest).Options := Options;

      for I := 0 to Count - 1 do
        TStrings(Dest).AddObject(string(Strings[I]), Objects[I]); // cast
    finally
      EndUpdate;
    end;
    Exit;
  end;

  inherited AssignTo(Dest);
end;

procedure TAnsiStrings.SetStrings(Source: TAnsiStrings);
begin
  BeginUpdate;
  try
    Clear;
    AddStrings(Source);
  finally
    EndUpdate;
  end;
end;

procedure TAnsiStrings.BeginUpdate;
begin
  if FUpdateCount = 0 then SetUpdateState(True);
  Inc(FUpdateCount);
end;

procedure TAnsiStrings.DefineProperties(Filer: TFiler);

  function DoWrite: Boolean;
  begin
    if Filer.Ancestor <> nil then
    begin
      Result := True;
      if Filer.Ancestor is TAnsiStrings then
        Result := not Equals(TAnsiStrings(Filer.Ancestor))
    end
    else Result := Count > 0;
  end;

begin
  Filer.DefineProperty('Strings', ReadData, WriteData, DoWrite);
end;

procedure TAnsiStrings.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then SetUpdateState(False);
end;

function TAnsiStrings.GetUpdating: Boolean;
begin
  Result := UpdateCount > 0;
end;

function TAnsiStrings.Equals(Strings: TAnsiStrings): Boolean;
var
  I, Count: Integer;
begin
  Result := False;
  Count := GetCount;
  if Count <> Strings.GetCount then Exit;
  for I := 0 to Count - 1 do if Get(I) <> Strings.Get(I) then Exit;
  Result := True;
end;

{$IFOPT O+}
  // Turn off optimizations to force creating a EBP stack frame and
  // place params on the stack.
  {$DEFINE OPTIMIZATIONSON}
  {$O-}
{$ENDIF O+}
procedure TAnsiStrings.Error(const Msg: string; Data: Integer);
begin
  raise EStringListError.CreateFmt(Msg, [Data]) at
    PPointer(PByte(@Msg) + SizeOf(Msg) + SizeOf(Self) + SizeOf(Pointer))^;
end;

procedure TAnsiStrings.Error(Msg: PResStringRec; Data: Integer);
begin
  raise EStringListError.CreateFmt(LoadResString(Msg), [Data]) at
    PPointer(PByte(@Msg) + SizeOf(Msg) + SizeOf(Self) + SizeOf(Pointer))^;
end;
{$IFDEF OPTIMIZATIONSON}
  {$UNDEF OPTIMIZATIONSON}
  {$O+}
{$ENDIF OPTIMIZATIONSON}

procedure TAnsiStrings.Exchange(Index1, Index2: Integer);
var
  TempObject: TObject;
  TempString: AnsiString;
begin
  BeginUpdate;
  try
    TempString := Strings[Index1];
    TempObject := Objects[Index1];
    Strings[Index1] := Strings[Index2];
    Objects[Index1] := Objects[Index2];
    Strings[Index2] := TempString;
    Objects[Index2] := TempObject;
  finally
    EndUpdate;
  end;
end;

function TAnsiStrings.ExtractName(const S: AnsiString): AnsiString;
begin
  Result := ExtractName(S, False);
end;

function TAnsiStrings.ExtractName(const S: AnsiString; AllNames: Boolean): AnsiString;
var
  P: Integer;
begin
  Result := S;
  P := AnsiPos(NameValueSeparator, Result);
  if P <> 0 then
    SetLength(Result, P - 1)
  else if not AllNames then
    SetLength(Result, 0);
end;

function TAnsiStrings.GetCapacity: Integer;
begin  // descendents may optionally override/replace this default implementation
  Result := Count;
end;

function TAnsiStrings.GetCommaText: AnsiString;
var
  LOldDelimiter: AnsiChar;
  LOldQuoteChar: AnsiChar;
begin
  LOldDelimiter := Delimiter;
  LOldQuoteChar := QuoteChar;
  Delimiter := ',';
  QuoteChar := '"';
  try
    Result := GetDelimitedText;
  finally
    Delimiter := LOldDelimiter;
    QuoteChar := LOldQuoteChar;
  end;
end;

function TAnsiStrings.GetDelimitedText: AnsiString;
var
  S: AnsiString;
  P: PAnsiChar;
  I, Count: Integer;
  LDelimiters: set of AnsiChar;
  SB: TAnsiStringBuilder;
begin
  Count := GetCount;
  if (Count = 1) and (Get(0) = '') then
    if QuoteChar = #0 then
      Result := ''
    else
      Result := QuoteChar + QuoteChar
  else
  begin
    Result := '';
    if QuoteChar <> #0 then
    begin
      LDelimiters := [AnsiChar(#0), QuoteChar, Delimiter];
      if not StrictDelimiter then
        LDelimiters := LDelimiters + [AnsiChar(#1)..AnsiChar(#32)];
    end;
    SB := TAnsiStringBuilder.Create;
    try
      for I := 0 to Count - 1 do
      begin
        S := Get(I);
        if QuoteChar <> #0 then
        begin
          P := PAnsiChar(S);
          while not (P^ in LDelimiters) do
            P := NextAnsiChar(P);
          if (P^ <> #0) then S := AnsiQuotedStr(S, QuoteChar);
        end;
        SB.Append(S);
        SB.Append(Delimiter);
      end;
      if SB.Length > 0 then
        Result := SB.ToString(0, SB.Length - 1);
    finally
      SB.Free;
    end;
  end;
end;

function TAnsiStrings.GetEnumerator: TAnsiStringsEnumerator;
begin
  Result := TAnsiStringsEnumerator.Create(Self);
end;

function TAnsiStrings.GetName(Index: Integer): AnsiString;
begin
  Result := ExtractName(Get(Index), False);
end;

function TAnsiStrings.GetKeyName(Index: Integer): AnsiString;
begin
  Result := ExtractName(Get(Index), True);
end;

function TAnsiStrings.GetObject(Index: Integer): TObject;
begin
  Result := nil;
end;

function TAnsiStrings.GetText: PAnsiChar;
begin
  Result := System.AnsiStrings.StrNew(PAnsiChar(GetTextStr));
end;

function TAnsiStrings.GetTextStr: AnsiString;
var
  I, L, Size, Count: Integer;
  P: PAnsiChar;
  S, LB: AnsiString;
begin
  Count := GetCount;
  Size := 0;
  LB := LineBreak;
  for I := 0 to Count - 1 do Inc(Size, Length(Get(I)) + Length(LB));
  if not TrailingLineBreak then
    Dec(Size, Length(LB));
  SetString(Result, nil, Size);
  P := Pointer(Result);
  for I := 0 to Count - 1 do
  begin
    S := Get(I);
    L := Length(S);
    if L <> 0 then
    begin
      System.Move(Pointer(S)^, P^, L * SizeOf(AnsiChar));
      Inc(P, L);
    end;
    if TrailingLineBreak or (I < Count - 1) then
    begin
      L := Length(LB);
      if L <> 0 then
      begin
        System.Move(Pointer(LB)^, P^, L * SizeOf(AnsiChar));
        Inc(P, L);
      end;
    end;
  end;
end;

function TAnsiStrings.GetValue(const Name: AnsiString): AnsiString;
var
  I: Integer;
begin
  I := IndexOfName(Name);
  if I >= 0 then
    Result := Copy(Get(I), Length(Name) + 2, MaxInt) else
    Result := '';
end;

function TAnsiStrings.IndexOf(const S: AnsiString): Integer;
begin
  for Result := 0 to GetCount - 1 do
    if CompareStrings(Get(Result), S) = 0 then Exit;
  Result := -1;
end;

function TAnsiStrings.IndexOfName(const Name: AnsiString): Integer;
var
  P: Integer;
  S: AnsiString;
begin
  for Result := 0 to GetCount - 1 do
  begin
    S := Get(Result);
    P := AnsiPos(NameValueSeparator, S);
    if (P <> 0) and (CompareStrings(Copy(S, 1, P - 1), Name) = 0) then Exit;
  end;
  Result := -1;
end;

function TAnsiStrings.IndexOfObject(AObject: TObject): Integer;
begin
  for Result := 0 to GetCount - 1 do
    if GetObject(Result) = AObject then Exit;
  Result := -1;
end;

procedure TAnsiStrings.InsertObject(Index: Integer; const S: AnsiString; AObject: TObject);
begin
  Insert(Index, S);
  PutObject(Index, AObject);
end;

procedure TAnsiStrings.LoadFromFile(const FileName: TFileName);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TAnsiStrings.LoadFromFile(const FileName: TFileName; Encoding: TEncoding);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream, Encoding);
  finally
    Stream.Free;
  end;
end;

procedure TAnsiStrings.LoadFromFileIfExists(const FileName: TFileName);
begin
  if FileExists(FileName) then
    LoadFromFile(FileName)
end;

procedure TAnsiStrings.LoadFromStream(Stream: TStream);
var
  Size: Integer;
  S: AnsiString;
begin
  BeginUpdate;
  try
    Size := Stream.Size - Stream.Position;
    SetString(S, nil, Size);
    Stream.Read(Pointer(S)^, Size);
    SetTextStr(S);
  finally
    EndUpdate;
  end;
end;

procedure TAnsiStrings.LoadFromStream(Stream: TStream; Encoding: TEncoding);
var
  Size: Integer;
  Buffer: TBytes;
begin
  BeginUpdate;
  try
    Size := Stream.Size - Stream.Position;
    SetLength(Buffer, Size);
    Stream.Read(Buffer, 0, Size);
    Size := TEncoding.GetBufferEncoding(Buffer, Encoding, FDefaultEncoding);
    SetEncoding(Encoding); // Keep Encoding in case the stream is saved
    SetTextStr(AnsiString(Encoding.GetString(Buffer, Size, Length(Buffer) - Size)));  // cast
  finally
    EndUpdate;
  end;
end;

procedure TAnsiStrings.Move(CurIndex, NewIndex: Integer);
var
  TempObject: TObject;
  TempString: AnsiString;
begin
  if CurIndex <> NewIndex then
  begin
    BeginUpdate;
    try
      TempString := Get(CurIndex);
      TempObject := GetObject(CurIndex);
      PutObject(CurIndex, nil);
      Delete(CurIndex);
      InsertObject(NewIndex, TempString, TempObject);
    finally
      EndUpdate;
    end;
  end;
end;

procedure TAnsiStrings.Put(Index: Integer; const S: AnsiString);
var
  TempObject: TObject;
begin
  TempObject := GetObject(Index);
  Delete(Index);
  InsertObject(Index, S, TempObject);
end;

procedure TAnsiStrings.PutObject(Index: Integer; AObject: TObject);
begin
end;

procedure TAnsiStrings.ReadData(Reader: TReader);
begin
  Reader.ReadListBegin;
  BeginUpdate;
  try
    Clear;
    while not Reader.EndOfList do Add(AnsiString(Reader.ReadString)); // cast
  finally
    EndUpdate;
  end;
  Reader.ReadListEnd;
end;

procedure TAnsiStrings.SaveToFile(const FileName: TFileName);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TAnsiStrings.SaveToFile(const FileName: TFileName; Encoding: TEncoding);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream, Encoding);
  finally
    Stream.Free;
  end;
end;

procedure TAnsiStrings.SaveToStream(Stream: TStream);
var
  S: AnsiString;
begin
  S := GetTextStr;
  Stream.WriteBuffer(Pointer(S)^, Length(S));
end;

procedure TAnsiStrings.SaveToStream(Stream: TStream; Encoding: TEncoding);
var
  Buffer, Preamble: TBytes;
begin
  if Encoding = nil then
    Encoding := FDefaultEncoding;
  Buffer := Encoding.GetBytes(string(GetTextStr)); // cast
  if WriteBOM then
  begin
    Preamble := Encoding.GetPreamble;
    if Length(Preamble) > 0 then
      Stream.WriteBuffer(Preamble, Length(Preamble));
  end;
  Stream.WriteBuffer(Buffer, Length(Buffer));
end;

procedure TAnsiStrings.SetCapacity(NewCapacity: Integer);
begin
  // do nothing - descendents may optionally implement this method
end;

procedure TAnsiStrings.SetCommaText(const Value: AnsiString);
var
  LOldDelimiter: AnsiChar;
  LOldQuoteChar: AnsiChar;
begin
  LOldDelimiter := Delimiter;
  LOldQuoteChar := QuoteChar;
  Delimiter := ',';
  QuoteChar := '"';
  try
    SetDelimitedText(Value);
  finally
    Delimiter := LOldDelimiter;
    QuoteChar := LOldQuoteChar;
  end;
end;

{
procedure TAnsiStrings.SetAnsiStringsAdapter(const Value: IStringsAdapter);
begin
  if FAdapter <> nil then
    FAdapter.ReleaseStrings;
  FAdapter := Value;
  if FAdapter <> nil then
    FAdapter.ReferenceStrings(Self);
end;
}

procedure TAnsiStrings.SetText(Text: PAnsiChar);
begin
  SetTextStr(Text);
end;

procedure TAnsiStrings.SetTextStr(const Value: AnsiString);
var
  P, Start, LB: PAnsiChar;
  S: AnsiString;
  LineBreakLen: Integer;
begin
  BeginUpdate;
  try
    Clear;
    P := Pointer(Value);
    if P <> nil then
      if CompareStr(LineBreak, sLineBreak) = 0 then
      begin
        // This is a lot faster than using StrPos/AnsiStrPos when
        // LineBreak is the default (#13#10)
        while P^ <> #0 do
        begin
          Start := P;
          while not (P^ in [#0, #10, #13]) do Inc(P);
          SetString(S, Start, P - Start);
          Add(S);
          if P^ = #13 then Inc(P);
          if P^ = #10 then Inc(P);
        end;
      end
      else
      begin
        LineBreakLen := Length(LineBreak);
        while P^ <> #0 do
        begin
          Start := P;
          LB := System.AnsiStrings.StrPos(P, PAnsiChar(LineBreak));
          while (P^ <> #0) and (P <> LB) do Inc(P);
          SetString(S, Start, P - Start);
          Add(S);
          if P = LB then
            Inc(P, LineBreakLen);
        end;
      end;
  finally
    EndUpdate;
  end;
end;

procedure TAnsiStrings.SetUpdateState(Updating: Boolean);
begin
end;

procedure TAnsiStrings.SetValue(const Name, Value: AnsiString);
var
  I: Integer;
begin
  I := IndexOfName(Name);
  if Value <> '' then
  begin
    if I < 0 then I := Add('');
    Put(I, Name + NameValueSeparator + Value);
  end else
  begin
    if I >= 0 then Delete(I);
  end;
end;

procedure TAnsiStrings.WriteData(Writer: TWriter);
var
  I: Integer;
begin
  Writer.WriteListBegin;
  for I := 0 to Count - 1 do Writer.WriteString(string(Get(I))); // cast
  Writer.WriteListEnd;
end;

procedure TAnsiStrings.SetDelimitedText(const Value: AnsiString);
var
  P, P1: PAnsiChar;
  S: AnsiString;
begin
  BeginUpdate;
  try
    Clear;
    P := PAnsiChar(Value);
    if not StrictDelimiter then
      while (P^ in [#1..' ']) do
        P := NextAnsiChar(P);
    while P^ <> #0 do
    begin
      if (P^ = QuoteChar) and (QuoteChar <> #0) then
        S := System.AnsiStrings.AnsiExtractQuotedStr(P, QuoteChar)
      else
      begin
        P1 := P;
        while ((not StrictDelimiter and (P^ > ' ')) or
              (StrictDelimiter and (P^ <> #0))) and (P^ <> Delimiter) do
          P := NextAnsiChar(P);
        SetString(S, P1, P - P1);
      end;
      Add(S);
      if not StrictDelimiter then
        while (P^ in [#1..' ']) do
          P := NextAnsiChar(P);

      if P^ = Delimiter then
      begin
        P1 := P;
        if NextAnsiChar(P1)^ = #0 then
          Add('');
        repeat
          P := NextAnsiChar(P);
        until not (not StrictDelimiter and (P^ in [#1..' ']));
      end;
    end;
  finally
    EndUpdate;
  end;
end;

function TAnsiStrings.GetTrailingLineBreak: Boolean;
begin
  Result := soTrailingLineBreak in Options;
end;

function TAnsiStrings.GetStrictDelimiter: Boolean;
begin
  Result := soStrictDelimiter in Options;
end;

procedure TAnsiStrings.SetDefaultEncoding(const Value: TEncoding);
begin
  if not TEncoding.IsStandardEncoding(FDefaultEncoding) then
    FDefaultEncoding.Free;
  if TEncoding.IsStandardEncoding(Value) then
    FDefaultEncoding := Value
  else if Value <> nil then
    FDefaultEncoding := Value.Clone
  else
    FDefaultEncoding := TEncoding.Default;
end;

procedure TAnsiStrings.SetEncoding(const Value: TEncoding);
begin
  if not TEncoding.IsStandardEncoding(FEncoding) then
    FEncoding.Free;
  if TEncoding.IsStandardEncoding(Value) then
    FEncoding := Value
  else if Value <> nil then
    FEncoding := Value.Clone
  else
    FEncoding := TEncoding.Default;
end;

procedure TAnsiStrings.SetTrailingLineBreak(const Value: Boolean);
begin
  if Value then
    Include(FOptions, soTrailingLineBreak)
  else
    Exclude(FOptions, soTrailingLineBreak);
end;

procedure TAnsiStrings.SetStrictDelimiter(const Value: Boolean);
begin
  if Value then
    Include(FOptions, soStrictDelimiter)
  else
    Exclude(FOptions, soStrictDelimiter);
end;

function TAnsiStrings.CompareStrings(const S1, S2: AnsiString): Integer;
begin
  if UseLocale then
    Result := AnsiCompareText(S1, S2)
  else
    Result := CompareText(S1, S2);
end;

function TAnsiStrings.GetUseLocale: Boolean;
begin
  Result := soUseLocale in Options;
end;

procedure TAnsiStrings.SetUseLocale(const Value: Boolean);
begin
  if Value then
    Include(FOptions, soUseLocale)
  else
    Exclude(FOptions, soUseLocale);
end;

function TAnsiStrings.GetWriteBOM: Boolean;
begin
  Result := soWriteBOM in Options;
end;

procedure TAnsiStrings.SetWriteBOM(const Value: Boolean);
begin
  if Value then
    Include(FOptions, soWriteBOM)
  else
    Exclude(FOptions, soWriteBOM);
end;

function TAnsiStrings.GetValueFromIndex(Index: Integer): AnsiString;
var
  SepPos: Integer;
begin
  if Index >= 0 then
  begin
    Result := Get(Index);
    SepPos := AnsiPos(NameValueSeparator, Result);
    if (SepPos > 0) then
      System.Delete(Result, 1, SepPos)
    else
      Result := '';
  end
  else
    Result := '';
end;

procedure TAnsiStrings.SetValueFromIndex(Index: Integer; const Value: AnsiString);
begin
  if Value <> '' then
  begin
    if Index < 0 then Index := Add('');
    Put(Index, Names[Index] + NameValueSeparator + Value);
  end
  else
    if Index >= 0 then Delete(Index);
end;

function TAnsiStrings.ToStringArray: TArray<AnsiString>;
var
  I: Integer;
begin
  SetLength(Result, Count);
  for I := 0 to Count - 1 do
    Result[I] := Strings[I];
end;

function TAnsiStrings.ToObjectArray: TArray<TObject>;
var
  I: Integer;
begin
  SetLength(Result, Count);
  for I := 0 to Count - 1 do
    Result[I] := Objects[I];
end;

{ TAnsiStringList }

destructor TAnsiStringList.Destroy;
var
  I: Integer;
  Temp: TArray<TObject>;
begin
  FOnChange := nil;
  FOnChanging := nil;

  // If the list owns the Objects gather them and free after the list is disposed
  if OwnsObjects then
  begin
    SetLength(Temp, FCount);
    for I := 0 to FCount - 1 do
      Temp[I] := FList[I].FObject;
  end;

  inherited Destroy;
  FCount := 0;
  SetCapacity(0);

  // Free the objects that were owned by the list
  if Length(Temp) > 0 then
    for I := 0 to Length(Temp) - 1 do
      Temp[I].DisposeOf;
end;

function TAnsiStringList.Add(const S: AnsiString): Integer;
begin
  Result := AddObject(S, nil);
end;

function TAnsiStringList.AddObject(const S: AnsiString; AObject: TObject): Integer;
begin
  if not Sorted then
    Result := FCount
  else
    if Find(S, Result) then
      case Duplicates of
        dupIgnore: Exit;
        dupError: Error(@SDuplicateString, 0);
      end;
  InsertItem(Result, S, AObject);
end;

procedure TAnsiStringList.Assign(Source: TPersistent);
begin
  if Source is TAnsiStringList then
  begin
    FCaseSensitive := TAnsiStringList(Source).FCaseSensitive;
    FDuplicates := TAnsiStringList(Source).FDuplicates;
    FSorted := TAnsiStringList(Source).FSorted;
  end
  else
  if Source is TAnsiStringListSimple then
  begin
    FCaseSensitive := TAnsiStringListSimple(Source).FCaseSensitive;
    FDuplicates := TAnsiStringListSimple(Source).FDuplicates;
    FSorted := TAnsiStringListSimple(Source).FSorted;
  end
  else
  if Source is TStringList then
  begin
    FCaseSensitive := TStringList(Source).CaseSensitive;
    FDuplicates := TStringList(Source).Duplicates;
    FSorted := TStringList(Source).Sorted;
  end;

  inherited Assign(Source);
end;

procedure TAnsiStringList.AssignTo(Dest: TPersistent);
begin
  if Dest is TStringList then
  begin
    TStringList(Dest).CaseSensitive := FCaseSensitive;
    TStringList(Dest).Duplicates := FDuplicates;
    TStringList(Dest).Sorted := FSorted;
  end;

  inherited AssignTo(Dest);
end;

procedure TAnsiStringList.Changed;
begin
  if (FUpdateCount = 0) and Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TAnsiStringList.Changing;
begin
  if (FUpdateCount = 0) and Assigned(FOnChanging) then
    FOnChanging(Self);
end;

procedure TAnsiStringList.Clear;
var
  I: Integer;
  Temp: TArray<TObject>;
begin
  if FCount <> 0 then
  begin
    Changing;

    // If the list owns the Objects gather them and free after the list is disposed
    if OwnsObjects then
    begin
      SetLength(Temp, FCount);
      for I := 0 to FCount - 1 do
        Temp[I] := FList[I].FObject;
    end;

    FCount := 0;
    SetCapacity(0);

    // Free the objects that were owned by the list
    if Length(Temp) > 0 then
      for I := 0 to Length(Temp) - 1 do
        Temp[I].Free;

    Changed;
  end;
end;

procedure TAnsiStringList.Delete(Index: Integer);
var
  Obj: TObject;
begin
  if (Index < 0) or (Index >= FCount) then Error(@SListIndexError, Index);
  Changing;
  // If this list owns its objects then free the associated TObject with this index
  if OwnsObjects then
    Obj := FList[Index].FObject
  else
    Obj := nil;

  // Direct memory writing to managed array follows
  //  see http://dn.embarcadero.com/article/33423
  // Explicitly finalize the element we about to stomp on with move
  Finalize(FList[Index]);
  Dec(FCount);
  if Index < FCount then
  begin
    System.Move(FList[Index + 1], FList[Index],
      (FCount - Index) * SizeOf(TAnsiStringItem));
    // Make sure there is no danglng pointer in the last (now unused) element
    PPointer(@FList[FCount].FString)^ := nil;
    PPointer(@FList[FCount].FObject)^ := nil;
  end;
  if Obj <> nil then
    Obj.Free;
  Changed;
end;

procedure TAnsiStringList.Exchange(Index1, Index2: Integer);
begin
  if (Index1 < 0) or (Index1 >= FCount) then Error(@SListIndexError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then Error(@SListIndexError, Index2);
  Changing;
  ExchangeItems(Index1, Index2);
  Changed;
end;

procedure TAnsiStringList.ExchangeItems(Index1, Index2: Integer);
var
  Temp: Pointer;
  Item1, Item2: PAnsiStringItem;
begin
  Item1 := @FList[Index1];
  Item2 := @FList[Index2];
  Temp := Pointer(Item1^.FString);
  Pointer(Item1^.FString) := Pointer(Item2^.FString);
  Pointer(Item2^.FString) := Temp;
  Temp := Pointer(Item1^.FObject);
  Pointer(Item1^.FObject) := Pointer(Item2^.FObject);
  Pointer(Item2^.FObject) := Temp;
end;

function TAnsiStringList.Find(const S: AnsiString; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := FCount - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := CompareStrings(FList[I].FString, S);
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        if Duplicates <> dupAccept then L := I;
      end;
    end;
  end;
  Index := L;
end;

function TAnsiStringList.Get(Index: Integer): AnsiString;
begin
  if Cardinal(Index) >= Cardinal(FCount) then
    Error(@SListIndexError, Index);
  Result := FList[Index].FString;
end;

function TAnsiStringList.GetCapacity: Integer;
begin
  Result := FCapacity;
end;

function TAnsiStringList.GetCount: Integer;
begin
  Result := FCount;
end;

function TAnsiStringList.GetObject(Index: Integer): TObject;
begin
  if Cardinal(Index) >= Cardinal(FCount) then
    Error(@SListIndexError, Index);
  Result := FList[Index].FObject;
end;

procedure TAnsiStringList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then Delta := FCapacity div 4 else
    if FCapacity > 8 then Delta := 16 else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TAnsiStringList.IndexOf(const S: AnsiString): Integer;
begin
  if not Sorted then Result := inherited IndexOf(S) else
    if not Find(S, Result) then Result := -1;
end;

procedure TAnsiStringList.Insert(Index: Integer; const S: AnsiString);
begin
  InsertObject(Index, S, nil);
end;

procedure TAnsiStringList.InsertObject(Index: Integer; const S: AnsiString;
  AObject: TObject);
begin
  if Sorted then Error(@SSortedListError, 0);
  if (Index < 0) or (Index > FCount) then Error(@SListIndexError, Index);
  InsertItem(Index, S, AObject);
end;

procedure TAnsiStringList.InsertItem(Index: Integer; const S: AnsiString; AObject: TObject);
begin
  Changing;
  if FCount = FCapacity then Grow;
  if Index < FCount then
    System.Move(FList[Index], FList[Index + 1],
      (FCount - Index) * SizeOf(TAnsiStringItem));
  Pointer(FList[Index].FString) := nil;
  Pointer(FList[Index].FObject) := nil;
  FList[Index].FObject := AObject;
  FList[Index].FString := S;
  Inc(FCount);
  Changed;
end;

procedure TAnsiStringList.Put(Index: Integer; const S: AnsiString);
begin
  if Sorted then Error(@SSortedListError, 0);
  if Cardinal(Index) >= Cardinal(FCount) then
    Error(@SListIndexError, Index);
  Changing;
  FList[Index].FString := S;
  Changed;
end;

procedure TAnsiStringList.PutObject(Index: Integer; AObject: TObject);
begin
  if Cardinal(Index) >= Cardinal(FCount) then
    Error(@SListIndexError, Index);
  Changing;
  FList[Index].FObject := AObject;
  Changed;
end;

procedure TAnsiStringList.QuickSort(L, R: Integer; SCompare: TAnsiStringListSortCompare);
var
  I, J, P: Integer;
begin
  if L < R then
  begin
  repeat
    if (R - L) = 1 then
    begin
      if SCompare(Self, L, R) > 0 then
        ExchangeItems(L, R);
      break;
    end;
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while SCompare(Self, I, P) < 0 do Inc(I);
      while SCompare(Self, J, P) > 0 do Dec(J);
      if I <= J then
      begin
        if I <> J then
          ExchangeItems(I, J);
        if P = I then
          P := J
        else if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if (J - L) > (R - I) then
    begin
      if I < R then
        QuickSort(I, R, SCompare);
      R := J;
    end
    else
    begin
      if L < J then
        QuickSort(L, J, SCompare);
      L := I;
    end;
    until L >= R;
  end;
end;

procedure TAnsiStringList.SetCapacity(NewCapacity: Integer);
begin
  if NewCapacity < FCount then
    Error(@SListCapacityError, NewCapacity);
  if NewCapacity <> FCapacity then
  begin
    SetLength(FList, NewCapacity);
    FCapacity := NewCapacity;
  end;
end;

procedure TAnsiStringList.SetSorted(Value: Boolean);
begin
  if FSorted <> Value then
  begin
    if Value then Sort;
    FSorted := Value;
  end;
end;

procedure TAnsiStringList.SetUpdateState(Updating: Boolean);
begin
  if Updating then Changing else Changed;
end;

function StringListCompareStrings(List: TAnsiStringList; Index1, Index2: Integer): Integer;
begin
  Result := List.CompareStrings(List.FList[Index1].FString,
                                List.FList[Index2].FString);
end;

procedure TAnsiStringList.Sort;
begin
  CustomSort(StringListCompareStrings);
end;

procedure TAnsiStringList.CustomSort(Compare: TAnsiStringListSortCompare);
begin
  if not Sorted and (FCount > 1) then
  begin
    Changing;
    QuickSort(0, FCount - 1, Compare);
    Changed;
  end;
end;

function TAnsiStringList.CompareStrings(const S1, S2: AnsiString): Integer;
begin
  if UseLocale then
    if CaseSensitive then
      Result := AnsiCompareStr(S1, S2)
    else
      Result := AnsiCompareText(S1, S2)
  else
    if CaseSensitive then
      Result := CompareStr(S1, S2)
    else
      Result := CompareText(S1, S2);
end;

constructor TAnsiStringList.Create;
begin
  inherited Create;
end;

constructor TAnsiStringList.Create(OwnsObjects: Boolean);
begin
  Create;
  FOwnsObject := OwnsObjects;
end;

constructor TAnsiStringList.Create(QuoteChar, Delimiter: AnsiChar);
begin
  Create;
  FQuoteChar := QuoteChar;
  FDelimiter := Delimiter;
end;

constructor TAnsiStringList.Create(QuoteChar, Delimiter: AnsiChar;
  Options: TStringsOptions);
begin
  Create;
  FQuoteChar := QuoteChar;
  FDelimiter := Delimiter;
  FOptions := Options;
end;

constructor TAnsiStringList.Create(Duplicates: TDuplicates; Sorted,
  CaseSensitive: Boolean);
begin
  Create;
  FDuplicates := Duplicates;
  FSorted := Sorted;
  FCaseSensitive := CaseSensitive;
end;

procedure TAnsiStringList.SetCaseSensitive(const Value: Boolean);
begin
  if Value <> FCaseSensitive then
  begin
    FCaseSensitive := Value;
    if Sorted then
    begin
      // Calling Sort won't sort the list because CustomSort will
      // only sort the list if it's not already sorted
      Sorted := False;
      Sorted := True;
    end;
  end;
end;


{ TAnsiStringListSimple }

destructor TAnsiStringListSimple.Destroy;
begin
  FOnChange := nil;
  FOnChanging := nil;

  inherited Destroy;
  FCount := 0;
  SetCapacity(0);
end;

function TAnsiStringListSimple.Add(const S: AnsiString): Integer;
begin
  Result := AddObject(S, nil);
end;

function TAnsiStringListSimple.AddObject(const S: AnsiString; AObject: TObject): Integer;
begin
  if not Sorted then
    Result := FCount
  else
    if Find(S, Result) then
      case Duplicates of
        dupIgnore: Exit;
        dupError: Error(@SDuplicateString, 0);
      end;
  InsertItem(Result, S, AObject);
end;

procedure TAnsiStringListSimple.Assign(Source: TPersistent);
begin
  if Source is TAnsiStringList then
  begin
    FCaseSensitive := TAnsiStringList(Source).FCaseSensitive;
    FDuplicates := TAnsiStringList(Source).FDuplicates;
    FSorted := TAnsiStringList(Source).FSorted;
  end
  else
  if Source is TAnsiStringListSimple then
  begin
    FCaseSensitive := TAnsiStringListSimple(Source).FCaseSensitive;
    FDuplicates := TAnsiStringListSimple(Source).FDuplicates;
    FSorted := TAnsiStringListSimple(Source).FSorted;
  end
  else
  if Source is TStringList then
  begin
    FCaseSensitive := TStringList(Source).CaseSensitive;
    FDuplicates := TStringList(Source).Duplicates;
    FSorted := TStringList(Source).Sorted;
  end;

  inherited Assign(Source);
end;

procedure TAnsiStringListSimple.AssignTo(Dest: TPersistent);
begin
  if Dest is TStringList then
  begin
    TStringList(Dest).CaseSensitive := FCaseSensitive;
    TStringList(Dest).Duplicates := FDuplicates;
    TStringList(Dest).Sorted := FSorted;
  end;

  inherited AssignTo(Dest);
end;

procedure TAnsiStringListSimple.Changed;
begin
  if (FUpdateCount = 0) and Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TAnsiStringListSimple.Changing;
begin
  if (FUpdateCount = 0) and Assigned(FOnChanging) then
    FOnChanging(Self);
end;

procedure TAnsiStringListSimple.Clear;
begin
  if FCount <> 0 then
  begin
    Changing;

    FCount := 0;
    SetCapacity(0);

    Changed;
  end;
end;

procedure TAnsiStringListSimple.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then Error(@SListIndexError, Index);
  Changing;

  // Direct memory writing to managed array follows
  //  see http://dn.embarcadero.com/article/33423
  // Explicitly finalize the element we about to stomp on with move
  Finalize(FList[Index]);
  Dec(FCount);
  if Index < FCount then
  begin
    System.Move(FList[Index + 1], FList[Index],
      (FCount - Index) * SizeOf(TAnsiStringSimpleItem));
    // Make sure there is no danglng pointer in the last (now unused) element
    PPointer(@FList[FCount])^ := nil;
  end;
  Changed;
end;

procedure TAnsiStringListSimple.Exchange(Index1, Index2: Integer);
begin
  if (Index1 < 0) or (Index1 >= FCount) then Error(@SListIndexError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then Error(@SListIndexError, Index2);
  Changing;
  ExchangeItems(Index1, Index2);
  Changed;
end;

procedure TAnsiStringListSimple.ExchangeItems(Index1, Index2: Integer);
var
  Temp: Pointer;
  Item1, Item2: PAnsiStringSimpleItem;
begin
  Item1 := @FList[Index1];
  Item2 := @FList[Index2];
  Temp := Pointer(Item1^);
  Pointer(Item1^) := Pointer(Item2^);
  Pointer(Item2^) := Temp;
end;

function TAnsiStringListSimple.Find(const S: AnsiString; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := FCount - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := CompareStrings(FList[I], S);
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        if Duplicates <> dupAccept then L := I;
      end;
    end;
  end;
  Index := L;
end;

function TAnsiStringListSimple.Get(Index: Integer): AnsiString;
begin
  if Cardinal(Index) >= Cardinal(FCount) then
    Error(@SListIndexError, Index);
  Result := FList[Index];
end;

function TAnsiStringListSimple.GetCapacity: Integer;
begin
  Result := FCapacity;
end;

function TAnsiStringListSimple.GetCount: Integer;
begin
  Result := FCount;
end;

function TAnsiStringListSimple.GetObject(Index: Integer): TObject;
begin
  if Cardinal(Index) >= Cardinal(FCount) then
    Error(@SListIndexError, Index);
  Result := nil
end;

procedure TAnsiStringListSimple.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then Delta := FCapacity div 4 else
    if FCapacity > 8 then Delta := 16 else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TAnsiStringListSimple.IndexOf(const S: AnsiString): Integer;
begin
  if not Sorted then Result := inherited IndexOf(S) else
    if not Find(S, Result) then Result := -1;
end;

procedure TAnsiStringListSimple.Insert(Index: Integer; const S: AnsiString);
begin
  InsertObject(Index, S, nil);
end;

procedure TAnsiStringListSimple.InsertObject(Index: Integer; const S: AnsiString;
  AObject: TObject);
begin
  if Sorted then Error(@SSortedListError, 0);
  if (Index < 0) or (Index > FCount) then Error(@SListIndexError, Index);
  InsertItem(Index, S, AObject);
end;

procedure TAnsiStringListSimple.InsertItem(Index: Integer; const S: AnsiString; AObject: TObject);
begin
  Changing;
  if FCount = FCapacity then Grow;
  if Index < FCount then
    System.Move(FList[Index], FList[Index + 1],
      (FCount - Index) * SizeOf(TAnsiStringSimpleItem));
  Pointer(FList[Index]) := nil;
  FList[Index] := S;
  Inc(FCount);
  Changed;
end;

procedure TAnsiStringListSimple.Put(Index: Integer; const S: AnsiString);
begin
  if Sorted then Error(@SSortedListError, 0);
  if Cardinal(Index) >= Cardinal(FCount) then
    Error(@SListIndexError, Index);
  Changing;
  FList[Index] := S;
  Changed;
end;

procedure TAnsiStringListSimple.PutObject(Index: Integer; AObject: TObject);
begin
  if Cardinal(Index) >= Cardinal(FCount) then
    Error(@SListIndexError, Index);
  {...}
end;

procedure TAnsiStringListSimple.QuickSort(L, R: Integer; SCompare: TAnsiStringListSimpleSortCompare);
var
  I, J, P: Integer;
begin
  if L < R then
  begin
  repeat
    if (R - L) = 1 then
    begin
      if SCompare(Self, L, R) > 0 then
        ExchangeItems(L, R);
      break;
    end;
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while SCompare(Self, I, P) < 0 do Inc(I);
      while SCompare(Self, J, P) > 0 do Dec(J);
      if I <= J then
      begin
        if I <> J then
          ExchangeItems(I, J);
        if P = I then
          P := J
        else if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if (J - L) > (R - I) then
    begin
      if I < R then
        QuickSort(I, R, SCompare);
      R := J;
    end
    else
    begin
      if L < J then
        QuickSort(L, J, SCompare);
      L := I;
    end;
    until L >= R;
  end;
end;

procedure TAnsiStringListSimple.SetCapacity(NewCapacity: Integer);
begin
  if NewCapacity < FCount then
    Error(@SListCapacityError, NewCapacity);
  if NewCapacity <> FCapacity then
  begin
    SetLength(FList, NewCapacity);
    FCapacity := NewCapacity;
  end;
end;

procedure TAnsiStringListSimple.SetSorted(Value: Boolean);
begin
  if FSorted <> Value then
  begin
    if Value then Sort;
    FSorted := Value;
  end;
end;

procedure TAnsiStringListSimple.SetUpdateState(Updating: Boolean);
begin
  if Updating then Changing else Changed;
end;

function AnsiStringListSimpleCompareStrings(List: TAnsiStringListSimple; Index1, Index2: Integer): Integer;
begin
  Result := List.CompareStrings(List.FList[Index1],
                                List.FList[Index2]);
end;

procedure TAnsiStringListSimple.Sort;
begin
  CustomSort(AnsiStringListSimpleCompareStrings);
end;

procedure TAnsiStringListSimple.CustomSort(Compare: TAnsiStringListSimpleSortCompare);
begin
  if not Sorted and (FCount > 1) then
  begin
    Changing;
    QuickSort(0, FCount - 1, Compare);
    Changed;
  end;
end;

function TAnsiStringListSimple.CompareStrings(const S1, S2: AnsiString): Integer;
begin
  if UseLocale then
    if CaseSensitive then
      Result := AnsiCompareStr(S1, S2)
    else
      Result := AnsiCompareText(S1, S2)
  else
    if CaseSensitive then
      Result := CompareStr(S1, S2)
    else
      Result := CompareText(S1, S2);
end;

constructor TAnsiStringListSimple.Create;
begin
  inherited Create;
end;

constructor TAnsiStringListSimple.Create(OwnsObjects: Boolean);
begin
  Create;
end;

constructor TAnsiStringListSimple.Create(QuoteChar, Delimiter: AnsiChar);
begin
  Create;
  FQuoteChar := QuoteChar;
  FDelimiter := Delimiter;
end;

constructor TAnsiStringListSimple.Create(QuoteChar, Delimiter: AnsiChar;
  Options: TStringsOptions);
begin
  Create;
  FQuoteChar := QuoteChar;
  FDelimiter := Delimiter;
  FOptions := Options;
end;

constructor TAnsiStringListSimple.Create(Duplicates: TDuplicates; Sorted,
  CaseSensitive: Boolean);
begin
  Create;
  FDuplicates := Duplicates;
  FSorted := Sorted;
  FCaseSensitive := CaseSensitive;
end;

procedure TAnsiStringListSimple.SetCaseSensitive(const Value: Boolean);
begin
  if Value <> FCaseSensitive then
  begin
    FCaseSensitive := Value;
    if Sorted then
    begin
      // Calling Sort won't sort the list because CustomSort will
      // only sort the list if it's not already sorted
      Sorted := False;
      Sorted := True;
    end;
  end;
end;


{$ENDIF UNICODE}

end.

