//==============================================================================
{
DELPHI SYNAPSE WEBSOCKET

Home: https://github.com/dimmaq/delphi-synapse-websocket

Based on project WebSocketUpgrade
https://github.com/alexpmorris/WebSocketUpgrade.git

}
//==============================================================================
{

used code from Bauglir Internet Library as framework to easily upgrade any
TCP Socket class to a WebSocket implementation including streaming deflate that can
maintain current zlib context and state

v0.12, 2017-10-14, fixed minor issues, client_no_context_takeover wasn't set for client,
                   fncProtocol and fncResourceName weren't properly set
v0.11, 2015-09-01, fixed small issue, ignore deprecated 'x-webkit-deflate-frame' (ios)
v0.10, 2015-07-31, by Alexander Paul Morris

See interface functions for usage details

Requirements: SynAUtil, SynACode (from Synapse), DelphiZlib

References:
http://tools.ietf.org/html/draft-ietf-hybi-thewebsocketprotocol-17
http://tools.ietf.org/html/rfc6455
http://dev.w3.org/html5/websockets/#refsFILEAPI
https://www.igvita.com/2013/11/27/configuring-and-optimizing-websocket-compression/
http://stackoverflow.com/questions/22169036/websocket-permessage-deflate-in-chrome-with-no-context-takeover

}



{==============================================================================|

| Project : Bauglir Internet Library                                           |
|==============================================================================|
| Content: Generic connection and server                                       |
|==============================================================================|
| Copyright (c)2011-2012, Bronislav Klucka                                     |
| All rights reserved.                                                         |
| Source code is licenced under original 4-clause BSD licence:                 |
| http://licence.bauglir.com/bsd4.php                                          |
|                                                                              |
|                                                                              |
| Project download homepage:                                                   |
|   http://code.google.com/p/bauglir-websocket/                                |
| Project homepage:                                                            |
|   http://www.webnt.eu/index.php                                              |
| WebSocket RFC:                                                               |
|   http://tools.ietf.org/html/rfc6455                                         |
|                                                                              |
|==============================================================================|}


unit uWebSocketUpgrade;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}
{$H+}

interface

uses
  Classes, SysUtils,
  //
  ZLibEx, ZLibExApi,
  //
  uAnsiStringList,
  //
  uWebSocketFrame, uWebSocketConst;

type
  TWebSocketUpgrade = class
  private
    FWasCreated: Boolean;
    FWasHandshake: Boolean;
    FIsServer: Boolean;
    FFragments: TWebSocketFrame;
    //
    FIsPerMessageDeflate: boolean;
    FCookie: RawByteString;
    FOrigin: RawByteString;
    FUserAgent: RawByteString;
    FAddHeaders: TAnsiStrings;
    FVersion: Integer;
    FProtocol: RawByteString;
    FExtensions: RawByteString;
    FPort: RawByteString;
    FHost: RawByteString;
    FIsSecure: Boolean;
    FPath: RawByteString;
    FKey: RawByteString;
    FMasking: boolean;
    FInCompWindowBits: integer;
    FOutCompWindowBits: integer;
    FInCompNoContext: boolean;
    FOutCompNoContext: boolean;
    //---
    FInZBuffer: TZDecompressionBuffer;
    FOutZBuffer: TZCompressionBuffer;
    //---
    function ZCompress(const ARawData: RawByteString): RawByteString;
    function ZDecompress(const ACompData: RawByteString;
      const AIsFinal: Boolean): RawByteString;
    //---
    function GetHeaders: RawByteString;
    function GetServerResponseHeaders: RawByteString;
    function GetClientRequestHeaders: RawByteString;
  public
    constructor Create;
    //creates Server TWebSocketConnection object, with socket.send() headers in fWebSocketHeaders
    //to upgrade the socket if client sent a WebSocket HTTP header
    //tryDeflate = 0 for false, or zlib windowBits for true (ie. default = 15)
    constructor CreateServer(const AClientRequestHeaders: RawByteString; const ATryDeflate: Byte = 15);
    //creates Client TWebSocketConnection object, with socket.send() headers in fncWebSocketHeaders
    constructor CreateClient(const AUrl: RawByteString; const ATryDeflate: Boolean = False);
    destructor Destroy; override;
    //---
    procedure Clear;
    function InitAsServer(const AClientRequestHeaders: RawByteString;
        const ATryDeflate: Byte = 15): Boolean;
    function InitAsClient(const AUrl: RawByteString; const ATryDeflate: boolean): Boolean;
    //confirms Client TWebSocketConnection handshake with server
    //returns true if succesful, or false upon failure
    function ClientConfirm(const AServerResponseHeaders: RawByteString;
      const AIgnoreKey: Boolean = False): Boolean;
    //if websocket, send data packets here to be decoded
    function IsIncompleteFragmentsExists: Boolean;
    function ReadData(var ABuffer: RawByteString; var AWsCode: TWsOpcode): RawByteString;
    function ReadRawFrame(var ABuffer: RawByteString; var AFrame: TWebSocketFrame): Boolean;
    //if websocket, send text to this method to send encoded packet
    //masking should only be used if socket is a ClientSocket and not a ServerSocket
    function SendData(const AData: RawByteString; const AWsCode: TWsOpcode = wsCodeText;
      const ATryDeflate: boolean = true): RawByteString;
    //---
    property AddHeaders: TAnsiStrings read FAddHeaders;
    property Cookies: RawByteString read FCookie write FCookie;
    property UserAgent: RawByteString read FUserAgent write FUserAgent;
    property Origin: RawByteString read FOrigin write FOrigin;
    property Protocol: RawByteString read FProtocol write FProtocol;
    property Extensions: RawByteString read FExtensions write FExtensions;
    property IsServer: Boolean read FIsServer;
    property Headers: RawByteString read GetHeaders;
    property Host: RawByteString read FHost;
    property Port: RawByteString read FPort;
    property IsPerMessageDeflate: Boolean read FIsPerMessageDeflate;
    property Fragments: TWebSocketFrame read FFragments;
  end;

implementation

uses
  Math, {$IFDEF UNICODE}AnsiStrings,{$ENDIF}
  //
  AcedStrings, AcedBinary,
  //
  synautil, synacode;

const
	// Add four bytes as specified in RFC
//	"\x00\x00\xff\xff" +
		// Add final block to squelch unexpected EOF error from flate reader.
//		"\x01\x00\x00\xff\xff"

  DEFLATE_TAIL: RawByteString = RawByteString(#$00#$00#$FF#$FF);
  INFLATE_TAIL: RawByteString = RawByteString(#$00#$00#$FF#$FF#$01#$00#$00#$FF#$FF);
  DEFLATE_TAIL_LEN = 4;

// helpers
{$REGION 'helpers'}

function httpCode(code: integer): RawByteString;
begin
  case (code) of
     100: result := 'Continue';
     101: result := 'Switching Protocols';
     200: result := 'OK';
     201: result := 'Created';
     202: result := 'Accepted';
     203: result := 'Non-Authoritative Information';
     204: result := 'No Content';
     205: result := 'Reset Content';
     206: result := 'Partial Content';
     300: result := 'Multiple Choices';
     301: result := 'Moved Permanently';
     302: result := 'Found';
     303: result := 'See Other';
     304: result := 'Not Modified';
     305: result := 'Use Proxy';
     307: result := 'Temporary Redirect';
     400: result := 'Bad Request';
     401: result := 'Unauthorized';
     402: result := 'Payment Required';
     403: result := 'Forbidden';
     404: result := 'Not Found';
     405: result := 'Method Not Allowed';
     406: result := 'Not Acceptable';
     407: result := 'Proxy Authentication Required';
     408: result := 'Request Time-out';
     409: result := 'Conflict';
     410: result := 'Gone';
     411: result := 'Length Required';
     412: result := 'Precondition Failed';
     413: result := 'Request Entity Too Large';
     414: result := 'Request-URI Too Large';
     415: result := 'Unsupported Media Type';
     416: result := 'Requested range not satisfiable';
     417: result := 'Expectation Failed';
     500: result := 'Internal Server Error';
     501: result := 'Not Implemented';
     502: result := 'Bad Gateway';
     503: result := 'Service Unavailable';
     504: result := 'Gateway Time-out';
     else result := 'unknown code: $code';
  end;
end;

procedure SplitExtension(var extString,key,value: RawByteString);
var i: integer;
    tmps: RawByteString;
begin
  i := Pos('; ',extString);
  if (i <> 0) then begin
    tmps := trim(lowercase(copy(extString,1,i-1)));
    delete(extString,1,i);
   end else begin
     tmps := trim(lowercase(extString));
     extString := '';
    end;
  i := Pos('=',tmps);
  if (i <> 0) then begin
    key := trim(copy(tmps,1,i-1));
    value := trim(copy(tmps,i+1,length(tmps)));
   end else begin
     key := trim(tmps);
     value := '';
    end;
end;

procedure MakeHeaderList(const S: RawByteString; const AList: TStrings);
var j: Integer;
begin
  AList.Text := string(S); // cast
  for j := 0 to Pred(AList.Count) do
  begin
    AList[j] := SysUtils.StringReplace(AList[j], ': ', '=', []);
  end;
end;


function IsControlFrame(const A: TWsOpcode): Boolean;
begin
  Result := (A = wsCodeClose) or (A = wsCodePing) or (A = wsCodePong)
end;

{$ENDREGION}

{TWebSocketUpgrade}
{$REGION 'TWebSocketUpgrade'}
constructor TWebSocketUpgrade.Create;
begin
  inherited;
  FAddHeaders := TAnsiStringListSimple.Create;
  Clear();
end;

constructor TWebSocketUpgrade.CreateServer(const AClientRequestHeaders: RawByteString;
  const ATryDeflate: Byte);
begin
  Create();
  InitAsServer(AClientRequestHeaders, ATryDeflate)
end;

constructor TWebSocketUpgrade.CreateClient(const AUrl: RawByteString; const ATryDeflate: boolean);
begin
  Create();
  InitAsClient(AUrl, ATryDeflate)
end;

procedure FreeZBuffer(const A: TZCustomBuffer);
begin
  // Ignore DATA_ERROR in ZDeflateEnd()
  // waiting zlib update >1.2.11
  // https://github.com/madler/zlib/issues/250
  //
  {
  if Assigned(A) then
  begin
    A.Flush(zfFinish);
    try
      A.Free;
    except
      on E: EZLibError do
      begin
        if E.ErrorCode <> Z_DATA_ERROR then
          raise
      end
      else
      begin
        raise
      end;
    end;
  end;   }
  A.Free;
end;

destructor TWebSocketUpgrade.Destroy;
begin
  FreeZBuffer(FInZBuffer);
  FreeZBuffer(FOutZBuffer);
  FreeAndNil(FAddHeaders);
  inherited Destroy;
end;
{
procedure TWebSocketUpgrade.ZStreamsInit;
begin

  FIsZStreamsInit := True;
  FZBuffer := TZlibBuffer.Create;
  ZCompressCheck(ZDeflateInit2(FOutFZStream, zcLevel8, -1 * FOutCompWindowBits, 9, zsDefault));
  ZDecompressCheck(ZInflateInit2(FInFZStream, -1 * FInCompWindowBits));

end;
}
function TWebSocketUpgrade.ZCompress(const ARawData: RawByteString): RawByteString;
var
  s: AnsiString;
  l: Integer;
begin
  //raise ENotSupportedException.Create('not support');

  if not Assigned(FOutZBuffer) then
    FOutZBuffer := TZCompressionBuffer.Create(zcLevel8, -1 * FOutCompWindowBits, 9, zsDefault);
  //---
  FOutZBuffer.Write(ARawData);
  FOutZBuffer.Flush(zfSyncFlush);  // zfFullFlush ??
//  FOutZBuffer.Flush(zfFullFlush); // zfFullFlush ??
  s := '';
  FOutZBuffer.Read(s);
  //
  if FOutCompNoContext then
  begin
    //FOutZBuffer.Clear();
    FOutZBuffer.Flush(zfFinish);
  end;
  //
  // 0000FFFF
  l := Length(s);
  if l > DEFLATE_TAIL_LEN then
  begin
    l := l - DEFLATE_TAIL_LEN ;
    if CompareMem(@s[l + 1], @DEFLATE_TAIL[1], DEFLATE_TAIL_LEN) then
      SetLength(s, l);
  end;
  //
  Result := s;
  SetCodePage(Result, $FFFF, False);
end;

function TWebSocketUpgrade.ZDecompress(const ACompData: RawByteString;
  const AIsFinal: Boolean): RawByteString;
var
  s: AnsiString;
begin
//  raise ENotSupportedException.Create('not support');
//  Result := '[compressed]';

  if not Assigned(FInZBuffer) then
    FInZBuffer := TZDecompressionBuffer.Create(-1 * FInCompWindowBits);
  //---
  FInZBuffer.Write(ACompData);
  if AIsFinal then
  begin
    FInZBuffer.Write(DEFLATE_TAIL);
  end;
  //
  s := '';
  FInZBuffer.Read(s);
  //
  if FInCompNoContext then
  begin
   // FInZBuffer.Clear();
   // FInZBuffer.Flush(zfFinish);
  end;
  //
  Result := s;
  SetCodePage(Result, $FFFF, False);
end;

procedure TWebSocketUpgrade.Clear;
begin
  FFragments.Clear;
  FWasCreated := False;
  FWasHandshake := False;  
  FIsServer := False;
  FIsPerMessageDeflate := False;
  FCookie := '';
  FVersion := 13;
  FProtocol := '';
  FOrigin := '';
  FExtensions := '';
  FPort := '';
  FHost := '';
  FIsSecure := True;
  FPath := '';
  FKey := '';
  FMasking := False;

  FInCompWindowBits := 0;
  FOutCompWindowBits := 0;
  FInCompNoContext := False;
  FOutCompNoContext := False;

  if Assigned(FInZBuffer) then
    FInZBuffer.Clear();
  if Assigned(FOutZBuffer) then
    FOutZBuffer.Clear();
end;

function TWebSocketUpgrade.InitAsServer(const AClientRequestHeaders: RawByteString;
  const ATryDeflate: Byte): Boolean;
var headers: TStringList;
    get,extKey,extVal: RawByteString;
    z: RawByteString;
begin
  Result := False;
  if FWasCreated then
    Exit;
  Clear();
  //---
  FIsServer := True;
  if AClientRequestHeaders = '' then
    Exit;
  //FRequestHeaders := AClientRequestHeaders;
  //---
  headers := TStringList.Create;
  try
    MakeHeaderList(AClientRequestHeaders, headers);

    //CHECK HTTP GET
    get := RawByteString(headers[0]);  // cast
    if ((Pos('GET ', Uppercase(get)) <> 0) and (Pos(' HTTP/1.1', Uppercase(get)) <> 0)) then
    begin
      FPath := SeparateRight(get, ' ');
      FPath := SeparateLeft(FPath, ' ');
      FPath := Trim(FPath);
    end;
    if FPath = '' then
    begin
      Exit;
    end;

    //CHECK HOST AND PORT
    z := RawByteString(headers.Values['host']);  // cast
    if (z <> '') then
    begin
      FHost := Trim(z);
      FPort := SeparateRight(FHost, ':');
      FHost := SeparateLeft(FHost, ':');
    end;
    FHost := Trim(FHost);
    FPort := Trim(FPort);

    if FHost = '' then
     Exit;

    //WEBSOCKET KEY
    FKey := '';
    z := RawByteString(headers.Values['sec-websocket-key']); // cast
    if (z <> '') then
    begin
      if (Length(DecodeBase64(z)) = WEBSOCKET_KEY_LEN) then
      begin
        FKey := z;
      end;
    end;
    FKey := Trim(FKey);
    if (FKey = '') then
      Exit;

    //WEBSOCKET VERSION
    z := RawByteString(headers.Values['sec-websocket-version']);  // cast
    z := Trim(z);
    if (z <> '') then
    begin
      FVersion := StrToIntDef(z, -1);
    end;
    if not InRange(FVersion, 7, 13) then
    begin
      Exit;
    end;

    // check  "Upgrade: websocket"
    z := RawByteString(headers.Values['upgrade']); // cast
    z := LowerCase(Trim(z));
    if z <> 'websocket' then
      Exit;

    // check "Connection: Upgrade"
    z := RawByteString(headers.Values['connection']); // cast
    z := LowerCase(Trim(z));
    if z <> 'upgrade' then
      Exit;


    // Origin:
    if (FVersion < 13) then
    begin
      FOrigin := Trim(RawByteString(headers.Values['sec-websocket-origin'])); // cast
    end
    else
    begin
      FOrigin := trim(RawByteString(headers.Values['origin'])); // cast
    end;

    // WS Protocol
    FProtocol := Trim(RawByteString(headers.Values['sec-websocket-protocol'])); // cast

    // WS Extensions
    z := Trim(RawByteString(headers.Values['sec-websocket-extensions'])); // cast
    // ignore deprecated 'x-webkit-deflate-frame' (ios devices)
    // 'sec-websocket-extensions: permessage-deflate; client_max_window_bits=12; server_max_window_bits=12';//; client_no_context_takeover';
    if Pos('permessage-deflate', z) > 0 then
    begin
      if ATryDeflate > 0 then
      begin
        FInCompWindowBits := ATryDeflate;
        FOutCompWindowBits := ATryDeflate;
        while (z <> '') do
        begin
          SplitExtension(z, extKey, extVal);
          if (extKey = 'client_max_window_bits') then
          begin
            if (extVal <> '') and (extVal <> '0') then
              FInCompWindowBits := StrToInt(extVal);
            if (FInCompWindowBits < 8) or (FInCompWindowBits > ATryDeflate) then
              FInCompWindowBits := ATryDeflate;
          end;
          if (extKey = 'client_no_context_takeover') then
            FInCompNoContext := True;
        end;

        FExtensions := 'permessage-deflate; client_max_window_bits';
        if (FInCompWindowBits > 0) then
          FExtensions := FExtensions + '=' + IntToStr(FInCompWindowBits);

        FExtensions := FExtensions + '; server_max_window_bits';
        if (FOutCompWindowBits > 0) then
          FExtensions := FExtensions + '=' + IntToStr(FOutCompWindowBits);

        FExtensions := FExtensions + '; ';
        if FInCompNoContext then
          FExtensions := FExtensions + 'client_no_context_takeover; ';

        if FOutCompNoContext then
          FExtensions := FExtensions + 'server_no_context_takeover; ';

        SetLength(FExtensions, length(FExtensions) - 2);  //delete extra '; '

        FIsPerMessageDeflate := true;
      end
      else
      begin
        FExtensions := '';
      end
    end
    else
    begin
      FExtensions := '';
    end;

    // COOKIES
    if (headers.IndexOfName('cookie') > -1) then
      FCookie := Trim(RawByteString(headers.Values['cookie'])); // cast

    if FisPerMessageDeflate then
    begin
      //ZStreamsInit();
    end;   

    FWasCreated := True
  finally
    headers.Free;
  end;
end;

function TWebSocketUpgrade.GetHeaders: RawByteString;
begin
  if FIsServer then
    Result := GetServerResponseHeaders()
  else
    Result := GetClientRequestHeaders()
end;

function TWebSocketUpgrade.GetServerResponseHeaders: RawByteString;
var
  proto,ext,key: RawByteString;
begin
  if not FWasCreated then
  begin
    Result :=
        'HTTP/1.1 400 Bad Request'#13#10 +
        'Connection: close'#13#10 +
        'Content-Length: 0'#13#10 +
        #13#10;
    Exit;
  end;
  //
  if (FProtocol <> '') then
    proto := 'Sec-WebSocket-Protocol: ' + FProtocol + #13#10;
  //
  if (FExtensions <> '') then
    ext := 'Sec-WebSocket-Extensions: ' + FExtensions + #13#10;
  //
  key := EncodeBase64(SHA1(FKey + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'));
  //
  FWasHandshake := True;  
  Result :=
    'HTTP/1.1 101 Switching Protocols'#13#10 +
    'Upgrade: websocket'#13#10 +
    'Connection: Upgrade'#13#10 +
    'Sec-WebSocket-Accept: ' + key + #13#10 +
    proto + ext + #13#10
end;

function TWebSocketUpgrade.GetClientRequestHeaders: RawByteString;
var
  j: Integer;
  z, lproto, lhost, lcookie, lorigin, lext, lagent, laddheader: RawByteString;
begin
  // key
  SetLength(z, WEBSOCKET_KEY_LEN);
  for j := 1 to WEBSOCKET_KEY_LEN do
    z[j] := AnsiChar(Random(85) + 32);
  FKey := EncodeBase64(z);
  // ws proto
  lproto := '';
  if (FProtocol <> '') then
    lproto := 'Sec-WebSocket-Protocol: ' + FProtocol + #13#10;
  // http header host
  lhost := FHost;
  if (FIsSecure and (FPort <> '443')) or ((not FIsSecure) and (FPort <> '80')) then
    lhost := lhost + ':' + FPort;
  // http get path
  if FPath = '' then
    FPath := '/';
  //
  lagent := '';
  if FUserAgent <> '' then
    lagent :=  'User-Agent: ' + FUserAgent + #13#10;
  laddheader := '';
  if FAddHeaders.Count > 0 then
    for z in FAddHeaders do
      laddheader := laddheader + z + #13#10;
  // http headers cookies
  lcookie := '';
  if FCookie <> '' then
    lcookie := 'Cookie: ' + FCookie + #13#10;
  // http header origin
  lorigin := '';
  if FOrigin <> '' then
    if (FVersion < 13) then
        lorigin := 'Sec-WebSocket-Origin: ' + FOrigin + #13#10
      else
        lorigin := 'Origin: ' + FOrigin + #13#10;
  // ws extensions
  lext := '';
  if (FExtensions <> '') then
    lext := 'Sec-WebSocket-Extensions: ' + FExtensions  + #13#10;
  //---
  Result :=
    'GET ' + FPath + ' HTTP/1.1'#13#10 +
    'Host: ' + lhost + #13#10 +
    'Upgrade: websocket'#13#10 +
    'Connection: Upgrade'#13#10 +
    'Pragma: no-cache'#13#10 +
    'Cache-Control: no-cache'#13#10 +
    lagent +
    lorigin +
    lcookie +
    laddheader +
    'Sec-WebSocket-Key: ' + FKey + #13#10 +
    'Sec-WebSocket-Version: ' + IntToStr(FVersion) + #13#10 +
    lproto +
    lext +
    #13#10;

end;

function TWebSocketUpgrade.InitAsClient(const AUrl: RawByteString; const ATryDeflate: boolean): Boolean;
var
  lprot, luser, lpass, lhost, lport, lpath, lpara: AnsiString;
begin
  ParseURL(AUrl, lprot, luser, lpass, lhost, lport, lpath, lpara);

  FHost := lhost;
  FPort := lport;
  FPath := lpath;

  FMasking := True;
  FOrigin := lprot + '://' + FHost;
  FIsSecure := lprot = 'wss';
  if FPort = '' then
    if FIsSecure then
      FPort := '443'
    else
      FPort := '80';
  if ((not FIsSecure) and (FPort <> '80')) or ((FIsSecure) and (FPort <> '443')) then
    FOrigin := FOrigin + ':' + FPort;
  if (lpara <> '') then
    FPath := FPath + '?' + lpara;
  if ATryDeflate then
    FExtensions := 'permessage-deflate; client_max_window_bits';

  FWasCreated := (FHost <> '');
  Result := FWasCreated;
end;


function TWebSocketUpgrade.ClientConfirm(
  const AServerResponseHeaders: RawByteString; const AIgnoreKey: Boolean): Boolean;
var
  headers: TStringList;
  z, key: RawByteString;
  s: string;
  extstr,extKey,extVal: RawByteString;
begin
  Result := False;
  if AServerResponseHeaders = '' then
    Exit;
  //---
  headers := TStringList.Create;
  try
    MakeHeaderList(AServerResponseHeaders, headers);
    //---
    z := RawByteString(headers[0]);  // cast
    if Pos('HTTP/1.1 101', UpperCase(z)) = 0 then
      Exit;
    //
    s := SysUtils.Trim(SysUtils.LowerCase(headers.Values['upgrade']));
    if s <> 'websocket' then
      Exit;    
    //
    s := SysUtils.Trim(SysUtils.LowerCase(headers.Values['connection']));
    if s <> 'upgrade' then
      Exit;   
    //

    z := RawByteString(headers.Values['sec-websocket-accept']); // cast
    key := EncodeBase64(SHA1(FKey + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')); 
    if (not AIgnoreKey) and (z <> key) then
      Exit;
    //
    z := RawByteString(headers.Values['sec-websocket-protocol']); // cast
    FProtocol := Trim(z);
    //
    z := RawByteString(headers.Values['sec-websocket-extensions']); // cast
    FExtensions := Trim(z);
  finally
    headers.Free;
  end;
  //---
  //fncExtensions := 'permessage-deflate; client_max_window_bits=12; server_max_window_bits=12';//; client_no_context_takeover';
  if (Pos('permessage-deflate', FExtensions) <> 0) then
  begin
    FInCompWindowBits := 15;
    FOutCompWindowBits := 15;
    extstr := FExtensions;    
    while (extstr <> '') do
    begin
      SplitExtension(extstr, extKey, extVal);
      //
      if (extKey = 'client_max_window_bits') then
      begin
        if (extVal <> '') and (extVal <> '0') then
          FOutCompWindowBits := StrToInt(extVal);
        if (FoutCompWindowBits < 8) or (FoutCompWindowBits > 15) then 
          FoutCompWindowBits := 15;
      end;
      if (extKey = 'server_max_window_bits') then
      begin
        if (extVal <> '') and (extVal <> '0') then 
          FinCompWindowBits := StrToInt(extVal); 
        if (FinCompWindowBits < 8) or (FInCompWindowBits > 15) then 
          FinCompWindowBits := 15;
      end;
      if (extKey = 'server_no_context_takeover') then 
        FinCompNoContext := true;
      if (extKey = 'client_no_context_takeover') then 
        FoutCompNoContext := true;
    end;
    FIsPerMessageDeflate := True;
    //ZStreamsInit();
  end;
  FWasHandshake := True;
  Result := True;  
end;

function TWebSocketUpgrade.IsIncompleteFragmentsExists: Boolean;
begin
  Result := FFragments.IsValidOpcode and FFragments.IsIncomplete
end;

function TWebSocketUpgrade.ReadRawFrame(var ABuffer: RawByteString; var AFrame: TWebSocketFrame): Boolean;
begin
  Result := False;
  if Length(ABuffer) < WS_FRAME_MIN_SIZE then
    Exit;

  AFrame := TWebSocketFrame.CreateFromBuffer(ABuffer);
  Result := AFrame.IsValid;
  if not Result then
    Exit;
  // clear pred fragment
  if not AFrame.FIN and (AFrame.Opcode <> wsCodeContinuation) and FFragments.IsValidOpcode then
  begin
    FFragments.Clear;
  end;
  //---
  // deflate
  //  https://tools.ietf.org/html/draft-ietf-hybi-permessage-compression-17#section-8.2.3
  //  Note that the RSV1 bit is set only on the first frame.
  if FIsPerMessageDeflate and (Length(AFrame.PayloadData) > 0) then
  begin
    if AFrame.IsDeflated or (IsIncompleteFragmentsExists() and FFragments.IsDeflated) then
    begin
      FFragments.SetAsDeflated();
      AFrame.DecodedData := ZDecompress(AFrame.PayloadData, AFrame.FIN)
    end;
  end;
  //
  //  The "Payload data" is text data encoded as UTF-8. https://tools.ietf.org/html/rfc6455#section-5.6
  if (AFrame.Opcode = wsCodeText) then
    SetCodePage(AFrame.DecodedData, CP_UTF8, False);
  //
  // final fragment
  if AFrame.FIN then
  begin
    if IsIncompleteFragmentsExists() then
    begin
      FFragments.DecodedData := FFragments.DecodedData + AFrame.DecodedData;
      FFragments.SetComplete();
    end
    else
    begin
      // clear pred fragment
      if FFragments.IsValidOpcode then
        FFragments.Clear();
    end;
  end
  else // first fragment
  begin
    if not FFragments.IsValidOpcode then
    begin
      FFragments.Opcode := AFrame.Opcode;
      FFragments.SetComplete(False);
      if FFragments.Opcode = wsCodeText then
        SetCodePage(FFragments.DecodedData, CP_UTF8, False)
    end;
    FFragments.DecodedData := FFragments.DecodedData + AFrame.DecodedData;
  end;
end;

function TWebSocketUpgrade.ReadData(var ABuffer: RawByteString; var AWsCode: TWsOpcode): RawByteString;
var
  frame: TWebSocketFrame;
begin
  AWsCode := wsNoFrame;
  Result := '';

  if Length(ABuffer) < WS_FRAME_MIN_SIZE then
    Exit;

  while ReadRawFrame(ABuffer, frame) do
  begin
    if not IsIncompleteFragmentsExists then
    begin
      if FFragments.IsValidOpcode then
      begin
        AWsCode := FFragments.Opcode;
        Result := FFragments.DecodedData;
        FFragments.Clear();
      end
      else
      begin
        AWsCode := frame.Opcode;
        Result := frame.DecodedData;
        Exit;
      end;
      if AWsCode = wsCodeText then
        SetCodePage(Result, CP_UTF8, False)
    end;
  end;
end;

function TWebSocketUpgrade.SendData(const AData: RawByteString; const AWsCode: TWsOpcode;
  const ATryDeflate: boolean): RawByteString;
var
  payload: RawByteString;
  frame: TWebSocketFrame;
  deflated: Boolean;
begin
  deflated := False;
  payload := AData;
  //
  if ATryDeflate and FIsPerMessageDeflate and (not IsControlFrame(AWsCode)) and (Length(AData) > 0) then
  begin
    payload := ZCompress(AData);
    deflated := True;
  end;
  //
  frame := TWebSocketFrame.Create(AWsCode, payload, AData, not FIsServer);
//  https://tools.ietf.org/html/draft-ietf-hybi-permessage-compression-17#section-8.2.3
//   Note that the RSV1 bit is set only on the first frame.
  if deflated then
    frame.SetAsDeflated();
  //
  Result := frame.ToBuffer()
end;

{$ENDREGION}


end.
