unit uCookieManagerSimple;

interface

uses
  System.SysUtils,
  //
  uCookieManagerInterface;

function CreateCookieManagerSimple(const ASavePath: TFileName): ICookieManager;

implementation

uses
  System.Classes, System.Generics.Collections, System.SyncObjs, System.Types,
  System.IOUtils, System.AnsiStrings,
  //
  AcedStrings,
  //
  uStringUtils, uGlobalFileIoFunc, uGlobalFunctions,
  uAnsiStringList;

type
  {$IFNDEF UNICODE}
    TDictionaryStringStringList = class
      FItems: TStringList;
      constructor Create;
      destructor Destroy; override;
      function Count: Integer;
      function TryGetValue(const AHost: string; var AList: TStrings): Boolean;
      procedure Add(const AHost: string; AList: TStrings);
      procedure Clear;
    end;
  {$ENDIF}

  TCookieList = class(
                    {$IFDEF UNICODE}
                        TObjectDictionary<AnsiString,TAnsiStrings>
                    {$ELSE}
                      TDictionaryStringStringList
                    {$ENDIF});

  TCookies = class(TInterfacedObject, ICookieManager)
  private
    FList: TCookieList;
    FLock: TCriticalSection;
    FSavePath: TFileName;
    FPathExists: Boolean;
    //---
    function GetFilePath(const AHost: AnsiString): TFileName;
    procedure _LoadFromPath(const AHost: AnsiString; const AList: TAnsiStrings);
    procedure _SaveToPath(const AHost: AnsiString; const AList: TAnsiStrings);
    procedure _SaveHostList(const AHost: AnsiString; const AList: TAnsiStrings;
      const ARewriteList, ASaveToPath: Boolean);
    procedure _SetRawCookie(const AHost, ACookie: AnsiString);
    procedure _SetValue(const AHost, AName, AValue: AnsiString);
    function _GetValue(const AHost, AName: AnsiString): AnsiString;
    function _Get(const AHost: AnsiString; const AAppend, ALoadFromPath: Boolean) : TAnsiStrings;
    procedure _GetRecursive(const AHost: AnsiString; const ADest: TAnsiStrings);
    function _FindRecursive(const AHost, AName: AnsiString): AnsiString;
    procedure _Clear;
  public
    constructor Create(const ASavePath: TFileName);
    destructor Destroy; override;
    //---
    procedure LoadFrom(const AHost: string; const ASrc: TStrings);
    procedure LoadFromA(const AHost: AnsiString; const ASrc: TAnsiStrings);
    procedure SaveTo(const AHost: string; const ADest: TStrings);
    procedure SaveToA(const AHost: AnsiString; const ADest: TAnsiStrings);
    // load &save host, name, value
    procedure SetValue(const AHost, AName, AValue: string);
    procedure SetValueA(const AHost, AName, AValue: AnsiString);
    function GetValue(const AHost, AName: string): string;
    function GetValueA(const AHost, AName: AnsiString): AnsiString;
    //
    // Cookie: yummy_cookie=choco; tasty_cookie=strawberry
    function GetCookie(const AHost: string): string;
    function GetCookieA(const AHost: AnsiString): AnsiString;
    //
    // Set-Cookie: name=newvalue; expires=date; path=/; domain=.example.org.
    // Set-Cookie: RMID=732423sdfs73242; expires=Fri, 31 Dec 2010 23:59:59 GMT; path=/; domain=.example.net
    procedure SetCookie(const AHost, ACookie: string);
    procedure SetCookieA(const AHost, ACookie: AnsiString);
    //
    procedure Clear;
    function IsEmpty: Boolean;
  end;

function CreateCookieManagerSimple(const ASavePath: TFileName): ICookieManager;
begin
  Result := TCookies.Create(ASavePath);
end;


function NormalizeHost(const S: AnsiString): AnsiString;
var k: Integer;
begin
  Result := '';
  if S = '' then
    Exit;
  k := G_CountOfChar(S, '.');
  if k = 0 then // ru
    Exit;
  if k = 1 then // .ru
    if S[1] = '.' then
      Exit;
  if S[1] <> '.' then // ya.ru
    Result := '.' + S
  else
    Result := S
end;

function HostUp(const S: AnsiString): AnsiString;
var p: Integer;
begin
  Result := '';
  if G_CountOfChar(S, '.') <= 1 then // .ru ya.ru
    Exit;
  p := 1;
  if S[1] = '.' then   // .ya.ru
    Inc(p);
  p := G_CharPos('.', S, p);
  if p > 0 then
    Result := Copy(S, p, MaxInt);
  if G_CountOfChar(Result, '.') <= 1 then
    Result := ''
end;

{ TCookies }

constructor TCookies.Create(const ASavePath: TFileName);
begin
  inherited Create;
  FList := TCookieList.Create{$IFDEF UNICODE}([doOwnsValues]){$ENDIF};
  FLock := TCriticalSection.Create;

  FPathExists := ASavePath <> '';
  if FPathExists then
  begin
    FSavePath := IncludeTrailingPathDelimiter(ASavePath);
    ForceDirectories(FSavePath)
  end;
end;

destructor TCookies.Destroy;
begin
  FLock.Free;
  FList.Free;
  inherited;
end;

function TCookies.IsEmpty: Boolean;
begin
  Result := FList.Count < 1
end;

function TCookies.GetFilePath(const AHost: AnsiString): TFileName;
begin
  Result := FSavePath + string(AHost) + '.txt' // cast
end;

procedure TCookies._LoadFromPath(const AHost: AnsiString; const AList: TAnsiStrings);
var fp: TFileName;
begin
  if FPathExists then
  begin
    fp := GetFilePath(AHost);
    if FileExists(fp) then
      AList.LoadFromFile(fp);
  end;
end;

procedure TCookies._SaveToPath(const AHost: AnsiString; const AList: TAnsiStrings);
begin
  if FPathExists then
    AList.SaveToFile(GetFilePath(AHost));
end;

procedure TCookies._SaveHostList(const AHost: AnsiString; const AList: TAnsiStrings;
  const ARewriteList, ASaveToPath: Boolean);
var
  sl: TAnsiStrings;
  nh: AnsiString;
begin
  if ARewriteList then
  begin
    nh := NormalizeHost(AHost);
    if nh = '' then
      Exit;
    sl := _Get(nh, True, True);
    if Assigned(sl) then
      sl.Assign(AList)
  end;
  if ASaveToPath then
    _SaveToPath(nh, AList);
end;

function TCookies._Get(const AHost: AnsiString; const AAppend, ALoadFromPath: Boolean): TAnsiStrings;
begin
  Result := nil;
  if not FList.TryGetValue(AHost, Result)  then
  begin
    if AAppend then
    begin
      Result := TAnsiStringListSimple.Create;
      FList.Add(AHost, Result);
      if ALoadFromPath then
        _LoadFromPath(AHost, Result);
    end
  end
end;

procedure TCookies._GetRecursive(const AHost: AnsiString; const ADest: TAnsiStrings);
var
  z: AnsiString;
  sl: TAnsiStrings;
begin
  z := NormalizeHost(AHost);
  if z = '' then
    Exit;
  sl := _Get(z, True, True);
  if not Assigned(sl) then
    Exit;
  ADest.AddStrings(sl);
  Exit;
 // _GetRecursive(HostUp(z), ADest);
end;

function TCookies._FindRecursive(const AHost, AName: AnsiString): AnsiString;
var
  z: AnsiString;
  sl: TAnsiStrings;
begin
  Result := '';
  z := NormalizeHost(AHost);
  if z = '' then
    Exit;
  sl := _Get(z, True, True);
  if not Assigned(sl) then
    Exit;
  Result := sl.Values[AName];
  if Result = '' then
    Result := _FindRecursive(HostUp(AHost), AName)
end;

procedure TCookies.LoadFrom(const AHost: string; const ASrc: TStrings);
{$IFDEF UNICODE}
var
  sl: TAnsiStrings;
begin
  sl := TAnsiStringListSimple_Create();
  try
    sl.Assign(ASrc);
    LoadFromA(AnsiString(AHost), sl);
  finally
    sl.Free;
  end;
{$ELSE}
begin
  LoadFromA(AHost, ASrc);
{$ENDIF}
end;

procedure TCookies.LoadFromA(const AHost: AnsiString; const ASrc: TAnsiStrings);
begin
  FLock.Enter;
  try
    _SaveHostList(AHost, ASrc, True, True)
  finally
    FLock.Leave
  end;
end;

procedure TCookies.SaveTo(const AHost: string; const ADest: TStrings);
{$IFDEF UNICODE}
var
  sl: TAnsiStrings;
begin
  sl := TAnsiStringListSimple_Create();
  try
    SaveToA(AnsiString(AHost), sl);
    ADest.Assign(sl);
  finally
    sl.Free;
  end;
{$ELSE}
begin
  SaveToA(AHost, ADest);
{$ENDIF}
end;

procedure TCookies.SaveToA(const AHost: AnsiString; const ADest: TAnsiStrings);
begin
  ADest.Clear;
  FLock.Enter;
  try
    _GetRecursive(AHost, ADest)
  finally
    FLock.Leave
  end
end;

procedure TCookies._SetValue(const AHost, AName, AValue: AnsiString);
var sl: TAnsiStrings;
begin
  sl := _Get(AHost, True, True);
  sl.Values[AName] := AValue;
  _SaveHostList(AHost, sl, False, True)
end;

procedure TCookies.SetValue(const AHost, AName, AValue: string);
begin
  SetValueA(AnsiString(AHost), AnsiString(AName), AnsiString(AValue)) // cast
end;

procedure TCookies.SetValueA(const AHost, AName, AValue: AnsiString);
begin
  FLock.Enter;
  try
    _SetValue(AHost, AName, AValue)
  finally
    FLock.Leave
  end;
end;

function TCookies._GetValue(const AHost, AName: AnsiString): AnsiString;
begin
  Result := _FindRecursive(AHost, AName)
end;

function TCookies.GetValue(const AHost, AName: string): string;
begin
  Result := string(GetValueA(AnsiString(AHost), AnsiString(AName))) // cast
end;

function TCookies.GetValueA(const AHost, AName: AnsiString): AnsiString;
begin
  FLock.Enter;
  try
    Result := _GetValue(AHost, AName)
  finally
    FLock.Leave
  end;
end;

function TCookies.GetCookie(const AHost: string): string;
begin
  Result := string(GetCookieA(AnsiString(AHost))) // cast
end;

function TCookies.GetCookieA(const AHost: AnsiString): AnsiString;
var
  sl: TAnsiStrings;
  z: AnsiString;
begin
  sl := TAnsiStringListSimple.Create;
  try
    FLock.Enter;
    try
      _GetRecursive(AHost, sl);
    finally
      FLock.Leave
    end;
    Result := '';
    for z in sl do
      if Result = '' then
        Result := z
      else
        Result := Result + '; ' + z
  finally
    sl.Free
  end
end;

// Cookie: yummy_cookie=choco; tasty_cookie=strawberry
{
procedure TCookies.SetLineA(const AHost, ALine: AnsiString);
var
  z,s,n,v: AnsiString;
  sl: TAnsiStrings;
begin
  FLock.Enter;
  try
    sl := _Get(AHost);
    z := Trim(ALine);
    while z <> '' do
    begin
      s := Trim(StrCut(z, ';'));
      n := Trim(StrCut(s, '='));
      v := Trim(s);
      sl.Values[n] := v
    end
  finally
    FLock.Leave
  end;
end;
}

// Set-Cookie: name=newvalue; expires=date; path=/; domain=.example.org.
// Set-Cookie: RMID=732423sdfs73242; expires=Fri, 31 Dec 2010 23:59:59 GMT; path=/; domain=.example.net
procedure TCookies._SetRawCookie(const AHost, ACookie: AnsiString);
var
  name, value, domain: AnsiString;
  h,z,s,n,v: AnsiString;
begin
  z := ACookie;
  G_Trim(z);
  if StartsWith(z, 'Set-Cookie: ', True) then
    Delete(z, 1, 12);
  z := Trim(ACookie);
  // name=newvalue; expires=date; path=/; domain=.example.org.
  name := Trim(StrCut(z, '='));
  // newvalue; expires=date; path=/; domain=.example.org.
  value := Trim(StrCut(z, ';'));
  G_Trim(z);
  domain := '';
  // expires=date; path=/; domain=.example.org.
  while z <> '' do
  begin
    s := Trim(StrCut(z, ';'));
    n := Trim(StrCut(s, '='));
    v := Trim(s);
    if n = 'domain' then
    begin
      domain := v;
      Break;
    end;
  end;
  h := NormalizeHost(AHost);
  if h = '' then
    Exit;
  if domain = '' then
  begin
    domain := h;
  end
  else
  begin
    domain := NormalizeHost(domain);
    if domain = '' then
      Exit;
    if not EndsWith(h, domain) then  // http://ya.ru <> .mail.ru
      Exit;
  end;
  _SetValue(domain, name, value);
end;

procedure TCookies.SetCookie(const AHost, ACookie: string);
begin
  SetCookieA(AnsiString(AHost), AnsiString(ACookie)) // cast
end;

procedure TCookies.SetCookieA(const AHost, ACookie: AnsiString);
begin
  FLock.Enter;
  try
    _SetRawCookie(AHost, ACookie);
  finally
    FLock.Leave
  end;
end;

procedure TCookies._Clear;
var
  arr: TStringDynArray;
  z: string;
begin
  FList.Clear;
  if FPathExists then
  begin
    arr := {$IFDEF UNICODE}
             TDirectory.GetFiles(FSavePath, '*.txt')
           {$ELSE}
             uGlobalFileIoFunc.FindInDir(FSavePath, [foFindFiles], '*.txt')
           {$ENDIF};
    for z in arr do
      DeleteFile(z)
  end;
end;

procedure TCookies.Clear;
begin
  FLock.Enter;
  try
     _Clear
  finally
    FLock.Leave
  end
end;

{$IFNDEF UNICODE}

{ TDictionaryStringStringList }

procedure TDictionaryStringStringList.Add(const AHost: string; AList: TStrings);
begin
  FItems.AddObject(AHost, AList)
end;

procedure TDictionaryStringStringList.Clear;
var j: Integer;
begin
  for j := 0 to FItems.Count - 1 do
  begin
    FItems.Objects[j].Free;
  end;
  FItems.Clear
end;

function TDictionaryStringStringList.Count: Integer;
begin
  Result := FItems.Count
end;

constructor TDictionaryStringStringList.Create;
begin
  inherited;
  FItems := TStringList.Create;
  FItems.CaseSensitive := False;
  FItems.Sorted := True;
end;

destructor TDictionaryStringStringList.Destroy;
begin
  Self.Clear;
  FItems.Free;
  inherited;
end;

function TDictionaryStringStringList.TryGetValue(const AHost: string; var AList: TStrings): Boolean;
var k: Integer;
begin
  k := FItems.IndexOf(AHost);
  if k <> -1 then
  begin
    AList := FItems.Objects[k] as TStringList;
    Result := True;
    Exit;
  end;
  Result := False
end;
{$ENDIF}


end.
