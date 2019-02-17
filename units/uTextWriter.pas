unit uTextWriter;

interface

uses
  Windows, Classes, SysUtils, RTLConsts,
  {$IFDEF UNICODE}
    AnsiStrings,
  {$ENDIF}
  //
  AcedCommon, AcedStrings,
  //
  uGlobalFunctions, uGlobalTypes, uGlobalConstants, uAnsiStringList;

type
  TAnsiStreamWriter = class{$IFDEF UNICODE}(TTextWriter){$ENDIF}
  private
    FStream: TStream;
    FOwner: Boolean;
    FHandle: THandle;
    FBuffer: TAnsiStringBuilder;
    FMaxBufSize: Integer;
    FFlushNow: Boolean; //TODO: ??? оно вообще нужно?
    FAllocBuf: Boolean;
    FUseBuffer: Boolean;
    FWritedSize: Cardinal;
    FCounter1: Cardinal;
    //---
    procedure _CreateBuffer;
    procedure _Write(P: Pointer; L: Integer);
    procedure _WriteLine;
    procedure _FlushBuffer;
    procedure _FlushStream;                    
  public
    constructor Create(AStream: TStream; AOwner: Boolean); overload;
    constructor Create(const AFileName: TFileName; AAppend: Boolean); overload;
    destructor Destroy; override;
    //---
    procedure Close;                                                 {$IFDEF UNICODE} override;{$ENDIF}
    procedure Flush;                                                 {$IFDEF UNICODE} override;{$ENDIF}
    {$IFDEF UNICODE}
      procedure Write(Value: AnsiChar); overload;
    {$ENDIF}
    procedure Write(Value: Boolean);                                 {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure Write(Value: Char);                                    {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure Write(const Value: TCharArray);                        {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure Write(Value: Double);                                  {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure Write(Value: Integer);                                 {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure Write(Value: Int64);                                   {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure Write(Value: TObject);                                 {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure Write(Value: Single);                                  {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure Write(const Value: string);                            {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    {$IFDEF UNICODE}
      procedure Write(const Value: AnsiString); overload;
    {$ENDIF}
    procedure Write(Value: Cardinal);                                {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure Write(Value: UInt64);                                  {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure Write(const Format: string; Args: array of const);     {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    {$IFDEF UNICODE}
      procedure Write(const Format: AnsiString; Args: array of const); overload;
    {$ENDIF}
    procedure Write(const Value: TCharArray; Index, Count: Integer); {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure WriteLine;                                             {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure WriteLine(Value: Boolean);                             {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure WriteLine(Value: Char);                                {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    {$IFDEF UNICODE}
      procedure WriteLine(Value: AnsiChar); overload;
    {$ENDIF}
    procedure WriteLine(const Value: TCharArray);                    {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure WriteLine(Value: Double);                              {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure WriteLine(Value: Integer);                             {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure WriteLine(Value: Int64);                               {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure WriteLine(Value: TObject);                             {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure WriteLine(Value: Single);                              {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure WriteLine(const Value: string);                        {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    {$IFDEF UNICODE}
      procedure WriteLine(const Value: AnsiString); overload;
    {$ENDIF}
    procedure WriteLine(Value: Cardinal);                            {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure WriteLine(Value: UInt64);                              {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    procedure WriteLine(const Format: string; Args: array of const); {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    {$IFDEF UNICODE}
      procedure WriteLine(const Format: AnsiString; Args: array of const); overload;
    {$ENDIF}
    procedure WriteLine(const Value: TCharArray; Index, Count: Integer);   {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    //---
    procedure WriteStrings(AStrings: TStrings);
    procedure WriteStringsA(AStrings: TAnsiStrings);
    //---
    property Stream: TStream read FStream;
    property MaxBufferSize: Integer read FMaxBufSize write FMaxBufSize;
    property FlushFile: Boolean read FFlushNow write FFlushNow;
    property AllocBuf: Boolean read FAllocBuf write FAllocBuf;
    property UseBuffer: Boolean read FUseBuffer write FUseBuffer;
    property WritedSize: Cardinal read FWritedSize write FWritedSize;
    property Counter1: Cardinal read FCounter1 write FCounter1;
    property Handle: THandle read FHandle;
  end;

  {$IFNDEF UNICODE}
    TStreamWriter = TAnsiStreamWriter;
  {$ENDIF}

implementation

uses uGlobalVars, uGlobalFileIOFunc, uStringUtils;

const
  MAX_BUFFER_SIZE = 16*1024;

{ TTextReader }

constructor TAnsiStreamWriter.Create(AStream: TStream; AOwner: Boolean);
begin
  FStream := AStream;
  FOwner := AOwner;
  FBuffer := nil;
  FMaxBufSize := MAX_BUFFER_SIZE;
  FUseBuffer := True;
  FFlushNow := False;
  FAllocBuf := True;
  FWritedSize := 0;
  FCounter1 := 0;
end;

constructor TAnsiStreamWriter.Create(const AFileName: TFileName; AAppend: Boolean);
var f: TFileStream;
begin
  SafeForceDirectories(ExtractFileDir(AFileName));
  FHandle := OpenFileWrite(AFileName, AAppend, True);
  f := TFileStream.Create(FHandle);
  if AAppend then
    f.Seek(0, soEnd);
  Create(f, True);
end;

destructor TAnsiStreamWriter.Destroy;
begin
  Flush;
  //---
  FreeAndNil(FBuffer);
  if FOwner then
    FreeAndNil(FStream);
  inherited;
end;

procedure TAnsiStreamWriter.Close;
begin
  //TODO: ???
end;

procedure TAnsiStreamWriter._FlushBuffer;
begin
  if Assigned(FBuffer) and (FBuffer.Length>0) then
  begin
    FStream.WriteBuffer(Pointer(FBuffer.Chars)^, FBuffer.Length);
    FBuffer.Clear;
  end;
end;

procedure TAnsiStreamWriter._FlushStream;
begin
  if FFlushNow and (Assigned(FStream)) and (FStream is TFileStream) then
    FlushFileBuffers(TFileStream(FStream).Handle);
end;

procedure TAnsiStreamWriter._CreateBuffer;
begin
  if not Assigned(FBuffer) then
    FBuffer := TAnsiStringBuilder.Create(
      IfElse(FAllocBuf, FMaxBufSize, 0)
    );
end;

procedure TAnsiStreamWriter._Write(P: Pointer; L: Integer);
begin
  Inc(FWritedSize, L);
  // записать сразу минуя буфер
  if FUseBuffer and (L<FMaxBufSize) then
  begin
    _CreateBuffer;
    //---
    if (FBuffer.Length+L)>=FMaxBufSize then
      Flush;
    //---
    FBuffer.Append(P, L);
  end
  else
  begin
    _FlushBuffer;
    FStream.WriteBuffer(P^, L);
    Flush;
  end;
end;

procedure TAnsiStreamWriter._WriteLine;
begin
  _Write(@_CRLF[1], 2);
end;

procedure TAnsiStreamWriter.Flush;
begin
  _FlushBuffer;
  _FlushStream;
  //---
  {$WARN SYMBOL_PLATFORM OFF}
  FileSetDate(FHandle, DateTimeToFileDate(Now()));
  {$WARN SYMBOL_PLATFORM ON}
end;

procedure TAnsiStreamWriter.Write(Value: Double);
begin
  Write(FloatToStr(Value));
end;

procedure TAnsiStreamWriter.Write(Value: Integer);
begin
  Write(IntToStr(Value));
end;

procedure TAnsiStreamWriter.Write(Value: Int64);
begin
  Write(IntToStr(Value));
end;

procedure TAnsiStreamWriter.Write(Value: Boolean);
begin
  Write(uGlobalFunctions.BoolToStr2(Value, True));
end;

procedure TAnsiStreamWriter.Write(Value: Char);
begin
  {$IFDEF UNICODE}
    Write(AnsiString(Value));
  {$ELSE}
    Write(Value);
  {$ENDIF}
end;

procedure TAnsiStreamWriter.Write(const Value: TCharArray);
begin
  Write(Value, -1, MaxInt);
end;

procedure TAnsiStreamWriter.Write(Value: TObject);
begin
{$IFDEF UNICODE}
  Write(Value.ToString());
{$ELSE}
  Write(Value.ClassName);
{$ENDIF}
end;

procedure TAnsiStreamWriter.Write(const Format: string; Args: array of const);
begin
{$IFDEF UNICODE}
  Write(AnsiString(SysUtils.Format(Format, Args)));
{$ELSE}
  Write(SysUtils.Format(Format, Args));
{$ENDIF}
end;

{$IFDEF UNICODE}
procedure TAnsiStreamWriter.Write(const Format: AnsiString;
  Args: array of const);
begin
  Write(AnsiStrings.Format(Format, Args));
end;
{$ENDIF}

procedure TAnsiStreamWriter.Write(const Value: TCharArray; Index, Count: Integer);
var
  b1,b2: Boolean;
  I,L,C: Integer;
  {$IFDEF UNICODE}
    z: AnsiString;
    j: Integer;
    k: Integer;
  {$ENDIF}
begin
  L := Length(Value);
  b1 := 0 <= Index;
  b2 := Index < L;
  if b1 and b2 then
    I := Index
  else if not b1 then
    I := 0
  else
    Exit;
  if Count<=0 then
    Exit;
  C := L - I;
  if C>Count then
    C := Count;
{$IFDEF UNICODE}
  SetLength(z, C);
  k := 1;
  for j:=I to C-1 do
  begin
    z[k] := AnsiChar(Value[j]);
    Inc(k)
  end;
  Write(z);
{$ELSE}
  _Write(Pointer(Value[I]), C);
{$ENDIF}
end;

{$IFDEF UNICODE}
procedure TAnsiStreamWriter.Write(Value: AnsiChar);
begin
  _Write(Pointer(Value), SizeOf(Value))
end;
{$ENDIF}

{$IFDEF UNICODE}
procedure TAnsiStreamWriter.Write(const Value: AnsiString);
begin
  Inc(FCounter1);
  _Write(Pointer(Value), Length(Value))
end;
{$ENDIF}

procedure TAnsiStreamWriter.Write(Value: UInt64);
begin
  Write(IntToStr(Value))
end;

procedure TAnsiStreamWriter.Write(Value: Single);
begin
  Write(FloatToStr(Value))
end;

procedure TAnsiStreamWriter.Write(const Value: string);
begin
{$IFDEF UNICODE}
  Write(AnsiString(Value));
{$ELSE}
  Inc(FCounter1);
  _Write(Pointer(Value), Length(Value))
{$ENDIF}
end;

procedure TAnsiStreamWriter.Write(Value: Cardinal);
begin
  Write(UIntToStr(Value));
end;

procedure TAnsiStreamWriter.WriteLine;
begin
  _WriteLine;
end;

procedure TAnsiStreamWriter.WriteLine(Value: Integer);
begin
  Write(Value);
  _WriteLine;
end;

procedure TAnsiStreamWriter.WriteLine(Value: Double);
begin
  Write(Value);
  _WriteLine;
end;

procedure TAnsiStreamWriter.WriteLine(Value: TObject);
begin
  Write(Value);
  _WriteLine;
end;

procedure TAnsiStreamWriter.WriteLine(Value: Int64);
begin
  Write(Value);
  _WriteLine;
end;

procedure TAnsiStreamWriter.WriteLine(Value: Boolean);
begin
  Write(Value);
  _WriteLine;
end;

procedure TAnsiStreamWriter.WriteLine(const Value: TCharArray);
begin
  Write(Value);
  _WriteLine;
end;

procedure TAnsiStreamWriter.WriteLine(Value: Char);
begin
  Write(Value);
  _WriteLine;
end;

procedure TAnsiStreamWriter.WriteLine(const Format: string;
  Args: array of const);
begin
  Write(Format, Args);
  _WriteLine;
end;

procedure TAnsiStreamWriter.WriteLine(Value: UInt64);
begin
  Write(Value);
  _WriteLine;
end;

procedure TAnsiStreamWriter.WriteLine(const Value: TCharArray; Index, Count: Integer);
begin
  Write(Value, Index, Count);
  _WriteLine;
end;

{$IFDEF UNICODE}
procedure TAnsiStreamWriter.WriteLine(Value: AnsiChar);
begin
  _Write(Pointer(Value), 1);
  _WriteLine;
end;
{$ENDIF}

{$IFDEF UNICODE}
procedure TAnsiStreamWriter.WriteLine(const Format: AnsiString;
  Args: array of const);
begin
  Write(Format, Args);
  _WriteLine;
end;
{$ENDIF}

procedure TAnsiStreamWriter.WriteLine(const Value: string);
begin
  Write(Value);
  _WriteLine;
end;

procedure TAnsiStreamWriter.WriteLine(Value: Single);
begin
  Write(Value);
  _WriteLine

end;

procedure TAnsiStreamWriter.WriteLine(Value: Cardinal);
begin
  Write(Value);
  _WriteLine;
end;

{$IFDEF UNICODE}
procedure TAnsiStreamWriter.WriteLine(const Value: AnsiString);
begin
  Write(Value);
  _WriteLine;
end;
{$ENDIF}

procedure TAnsiStreamWriter.WriteStringsA(AStrings: TAnsiStrings);
var j: Integer;
begin
  for j:=0 to AStrings.Count-1 do
  begin
    Write(AStrings[j]);
    _WriteLine;
  end;
end;

procedure TAnsiStreamWriter.WriteStrings(AStrings: TStrings);
var j: Integer;
begin
  for j:=0 to AStrings.Count-1 do
  begin
    {$IFDEF UNICODE}
      Write(AnsiString(AStrings[j]));
    {$ELSE}
      Write(AStrings[j]);
    {$ENDIF}
    _WriteLine;
  end;
end;

end.
