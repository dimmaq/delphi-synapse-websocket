unit uTextReader;

{$I jedi.inc}

interface

uses
  Classes, SysUtils, Math, AcedStrings, uGlobalTypes,
  uGlobalConstants, uUniListReadWrite, uAnsiStringList;

type
  TAnsiStreamReader = class{$IFDEF UNICODE}(TTextReader){$ENDIF}
  private
    FStream: TStream;
    FStreamSize: Integer;
    FStreamPos: Integer;
    FOwner: Boolean;
    FBuffer: PAnsiChar;
    FDefBufSize: Integer;
    FBufferSize: Integer;
    FBufferPos: Integer;
    FLastLine: TAnsiStringBuilder;
    FBol1: Boolean;
    //---
    function _ReadLine: AnsiString; {$IFNDEF DEBUG}inline;{$ENDIF}
    procedure _ReadBuffer; {$IFNDEF DEBUG}inline;{$ENDIF}
    procedure _NewBuffer(ABufSize: Integer);
  public
    constructor Create(AStream: TStream; AOwner: Boolean); overload;
    constructor Create(const AFileName: TFileName); overload;
    destructor Destroy; override;
    //---
    function EOF: Boolean;
    function ReadLn: AnsiString;
    function ReadStrings(AStrings: TStrings): Integer;
    function ReadStringsA(AStrings: TAnsiStrings): Integer;
    function ReadUniList(AUniList: IUniListWriter): Integer; overload;
    //---
    procedure Close; {$IFDEF UNICODE} override;{$ENDIF}
    function Peek: Integer; {$IFDEF UNICODE} override;{$ENDIF}
    function Read: Integer; {$IFDEF UNICODE}override;{$ELSE}overload;{$ENDIF}
    function Read(var Buffer: TCharArray; Index, Count: Integer): Integer; {$IFDEF UNICODE} override;{$ELSE}overload;{$ENDIF}
    function ReadBlock(var Buffer: TCharArray; Index, Count: Integer): Integer; {$IFDEF UNICODE} override;{$ENDIF}
    function ReadLine: string; {$IFDEF UNICODE} override;{$ENDIF}
    function ReadToEnd: string; {$IFDEF UNICODE} override;{$ENDIF}
    procedure Rewind; {$IFDEF DELPHIX_RIO_UP} override;{$ENDIF}
    //---
    property BufSize: Integer read FDefBufSize write FDefBufSize;
  end;

  {$IFNDEF UNICODE}
    TStreamReader = TAnsiStreamReader;
  {$ENDIF}  

implementation

const
  DEF_BUF_SIZE = 1*1024;

{ TTextReader }

constructor TAnsiStreamReader.Create(AStream: TStream; AOwner: Boolean);
begin
  FStream := AStream;
  FOwner := AOwner;
  FStream.Position := 0;
  FStreamPos := 0;
  FStreamSize := AStream.Size;
  FDefBufSize := DEF_BUF_SIZE;
  FBufferSize := FDefBufSize;
  FBufferPos := MaxInt;
  FBuffer := nil;
  FLastLine := nil;
  FBol1 := False;
end;

constructor TAnsiStreamReader.Create(const AFileName: TFileName);
var stream: TStream;
begin
  stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  Create(stream, True);
end;

destructor TAnsiStreamReader.Destroy;
begin
  FreeMem(FBuffer);
  FreeAndNil(FLastLine);
  if FOwner then
    FreeAndNil(FStream);
  inherited;
end;

function TAnsiStreamReader.EOF: Boolean;
begin
  Result := (FBufferSize=0) or
            (((FStreamSize-FStreamPos)=0) and (FBufferPos>FBufferSize))
end;

function TAnsiStreamReader._ReadLine: AnsiString;
var
  P: PAnsiChar;
  S: PAnsiChar;
begin
  Result := '';
  if Assigned(FLastLine) then
    FLastLine.Clear;
  while FBufferSize>0 do
  begin
    if FBufferPos>FBufferSize then
      _ReadBuffer;
    //---
    P := FBuffer;
    Inc(P, FBufferPos);
    if FBol1 and (P^ in [#10, #13]) then
    begin
      Inc(P);
      FBol1 := False;
    end;
    S := P;
    // поиск конца строки
    while not (P^ in [#0, #10, #13]) do Inc(P);
    // конец буфера
    if P^=#0 then
    begin
      if not Assigned(FLastLine) then
        FLastLine := TAnsiStringBuilder.Create;
      FLastLine.Append(Pointer(S), P-S);
      FBufferPos := P - FBuffer;
      Inc(FBufferPos);
    end
    else
    // конец строки
    begin
      if (Assigned(FLastLine)) and (FLastLine.Length>0) then
        Result := FLastLine.Append(Pointer(S), P-S).ToString()
      else
        SetString(Result, S, P - S);
      //---
      // перевод строки CRLF или LFCR или CR или LF 
      if P^ = CR then
      begin
        Inc(P);
        FBol1 := P^ = #0;
        if P^ = LF then
        begin
          Inc(P);
          FBol1 := False;
        end;
      end
      else if P^ = LF then
      begin
        Inc(P);
        FBol1 := P^ = #0;
        if P^ = CR then
        begin
          Inc(P);
          FBol1 := False;
        end;
      end;
      if P^ = #0 then
        Inc(P);
      //---
      FBufferPos := P - FBuffer;
      Exit; //***
    end
  end;
  Result := FLastLine.ToString
end;

function TAnsiStreamReader.ReadStringsA(AStrings: TAnsiStrings): Integer;
begin
  Result := ReadUniList(TAnsiStringsReadWrite.Create(AStrings))
end;

function TAnsiStreamReader.ReadStrings(AStrings: TStrings): Integer;
begin
  Result := ReadUniList(TStringsReadWrite.Create(AStrings))
end;

procedure TAnsiStreamReader._NewBuffer(ABufSize: Integer);
var p: PAnsiChar;
begin
  if FBuffer=nil then
    GetMem(FBuffer, ABufSize+4);
  p := FBuffer;
  Inc(p, ABufSize);
  PInteger(p)^ := 0;
end;

procedure TAnsiStreamReader._ReadBuffer;
var k: Integer;
begin
  FBufferSize := Min(FDefBufSize, FStreamSize - FStreamPos);
  _NewBuffer(FBufferSize);
  k := FStream.Read(FBuffer^, FBufferSize);
  FStreamPos := FStream.Seek(0, soCurrent);
  FBufferPos := 0;
  if FBufferSize<>k then
  begin
    FBufferSize := k;
    _NewBuffer(FBufferSize)
  end
end;

procedure TAnsiStreamReader.Close;
begin
  //TODO: ???
end;

function TAnsiStreamReader.ReadToEnd: string;
var S: {$IFDEF UNICODE}SysUtils.{$ENDIF}TStringBuilder;
begin
  S := {$IFDEF UNICODE}SysUtils.{$ENDIF}TStringBuilder.Create;
  try
    while not EOF() do
      S.AppendLine(ReadLine());
    //---
    Result := S.ToString();
  finally
    S.Free
  end;
end;

function TAnsiStreamReader.ReadUniList(AUniList: IUniListWriter): Integer;
begin
  Result := 0;
  AUniList.BeginUpdate;
  try
    while not EOF() do
    begin
      AUniList.AddAnsiString(ReadLn());
      Inc(Result)
    end;
  finally
    AUniList.EndUpdate
  end;
end;

procedure TAnsiStreamReader.Rewind;
begin

end;

function TAnsiStreamReader.ReadLine: string;
begin
  Result := string(_ReadLine())
end;

function TAnsiStreamReader.ReadLn: AnsiString;
begin
  Result := _ReadLine();
end;

function TAnsiStreamReader.Peek: Integer;
begin
  //TODO: ???
  Result := 0;
end;

function TAnsiStreamReader.Read: Integer;
begin
  //TODO: ???
  Result := 0;
end;

function TAnsiStreamReader.Read(var Buffer: TCharArray; Index,
  Count: Integer): Integer;
begin
  //TODO: ???
  Result := 0;
end;

function TAnsiStreamReader.ReadBlock(var Buffer: TCharArray; Index,
  Count: Integer): Integer;
begin
  //TODO: ???
  Result := 0;
end;


end.
