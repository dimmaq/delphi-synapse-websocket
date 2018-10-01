unit uWebSocketFrame;

{
  WEbSocket RFC https://tools.ietf.org/html/rfc6455
}

interface

uses
  SysUtils, Classes,
  //
  uWebSocketConst;

type
  TWebSocketFrame = record
  private
    FIsComplete: Boolean;
  public
    FIN: Boolean;
    RSV1: Boolean;
    RSV2: Boolean;
    RSV3: Boolean;
    Opcode: TWsOpcode;
    Mask: Boolean;
    PayloadLen: UInt64;
    MaskingKey: UInt32;
    PayloadData: RawByteString; // as was received
    DecodedData: RawByteString; // decoded (inflated)

    constructor Create(const ACode: TWsOpcode; const APayload, ADecoded: RawByteString;
      const AMask: Boolean; const AFIN: Boolean = True);
    constructor CreateFromBuffer(var ABuffer: RawByteString);
    procedure LoadFromBuffer(var ABuffer: RawByteString);
    procedure Clear;
    procedure Assign(const A: TWebSocketFrame);
    function IsValid: Boolean;
    function IsValidOpcode: Boolean;
    function IsIncomplete: Boolean;
    function IsDeflated: Boolean;
    procedure SetAsDeflated;
    function ToBuffer: RawByteString;
    procedure SetComplete(const A: Boolean = True);
    property IsComplete: Boolean read FIsComplete;
  end;


implementation

uses
  //
  AcedBinary;

type
  PUInt16 = ^UInt16;
  PUInt32 = ^UInt32;

  UInt32Rec = packed record
    case UInt32 of
      0: (Lo, Hi: Word);
      1: (Words: array [0..1] of Word);
      2: (Bytes: array [0..3] of Byte);
  end;
  PUInt32Rec = ^UInt32Rec;

  TArray4Byte = array[0..3] of UInt8;


// helpers
{$REGION 'helpers'}

function ByteSwap64(Value: UInt64): UInt64;
asm
{$IF Defined(CPUX86)}
  mov    edx, [ebp+$08]
  mov    eax, [ebp+$0c]
  bswap  edx
  bswap  eax
{$ELSEIF Defined(CPUX64)}
  mov    rax, rcx
  bswap  rax
{$ELSE}
{$Message Fatal 'ByteSwap64 has not been implemented for this architecture.'}
{$ENDIF}
end;

function ByteSwap32(Value: UInt32): UInt32;
begin
  Result := G_BSwap(Value)
end;

function ByteSwap16(Value: UInt16): UInt16;
begin
  Result := (Byte(Value and $FF) shl 8) or
            (Byte((Value and $FF00) shr 8));
end;

function Random_UInt32: UInt32;
var
  Overlay: packed record
    a, b: UInt16;
  end absolute Result;
begin
  Assert(SizeOf(Overlay)=SizeOf(Result));
  Overlay.a := Random($10000);
  Overlay.b := Random($10000);
end;

procedure MaskingKeyToArray(const AKey: UInt32; var AArr: TArray4Byte);
begin
  AArr[3] := AKey and $000000FF;
  AArr[2] := (AKey shr 8) and $000000FF;
  AArr[1] := (AKey shr 16) and $000000FF;
  AArr[0] := (AKey shr 24) and $000000FF;
end;

procedure DoXorMasking(P: PByte; const AKey: UInt32; const ACount: Integer);
var
  K: TArray4Byte;
  j: Integer;
begin
  MaskingKeyToArray(AKey, K);
  j := 0;
  while j < ACount do
  begin
    P^ := P^ xor K[j mod 4];
    Inc(P);
    Inc(j);
  end;
end;

{$ENDREGION}

{ TWebSocketFrame }

procedure TWebSocketFrame.Assign(const A: TWebSocketFrame);
begin
  // Self := A; ???

  FIsComplete := A.FIsComplete;
  FIN := A.FIN;
  RSV1 := A.RSV1;
  RSV2 := A.RSV2;
  RSV3 := A.RSV3;
  Opcode := A.Opcode;
  Mask := A.Mask;
  PayloadLen := A.PayloadLen;
  MaskingKey := A.MaskingKey;
  PayloadData := A.PayloadData;
  DecodedData := A.DecodedData;
end;

procedure TWebSocketFrame.Clear;
begin
  FIsComplete := False;

  FIN := True;
  RSV1 := False;
  RSV2 := False;
  RSV3 := False;
  Opcode := wsNoFrame;
  Mask := False;
  PayloadLen := 0;
  MaskingKey := 0;
  PayloadData := '';
  DecodedData := '';
end;

constructor TWebSocketFrame.Create(const ACode: TWsOpcode;
  const APayload, ADecoded: RawByteString; const AMask, AFIN: Boolean);
begin
  FIsComplete := True;

  FIN := AFIN;
  RSV1 := False;
  RSV2 := False;
  RSV3 := False;
  Opcode := ACode;
  PayloadLen := Length(APayload);
  Mask := AMask;  //and (PayloadLen > 0);
  MaskingKey := 0;
  PayloadData := APayload;
  DecodedData := ADecoded;
end;

constructor TWebSocketFrame.CreateFromBuffer(var ABuffer: RawByteString);
begin
  LoadFromBuffer(ABuffer);
end;

function TWebSocketFrame.IsDeflated: Boolean;
begin
  Result := RSV1
end;

function TWebSocketFrame.IsIncomplete: Boolean;
begin
  Result := (not FIsComplete)
end;

function TWebSocketFrame.IsValid: Boolean;
begin
  Result := FIsComplete and IsValidOpcode() and (PayloadLen = Length(PayloadData))
end;

function TWebSocketFrame.IsValidOpcode: Boolean;
begin
  Result := ($0 <= Opcode) and (Opcode <= $F)
end;

{     0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-------+-+-------------+-------------------------------+
     |F|R|R|R| opcode|M| Payload len |    Extended payload length    |
     |I|S|S|S|  (4)  |A|     (7)     |             (16/64)           |
     |N|V|V|V|       |S|             |   (if payload len==126/127)   |
     | |1|2|3|       |K|             |                               |
     +-+-+-+-+-------+-+-------------+ - - - - - - - - - - - - - - - +
     |     Extended payload length continued, if payload len == 127  |
     + - - - - - - - - - - - - - - - +-------------------------------+
     |                               |Masking-key, if MASK set to 1  |
     +-------------------------------+-------------------------------+
     | Masking-key (continued)       |          Payload Data         |
     +-------------------------------- - - - - - - - - - - - - - - - +
     :                     Payload Data continued ...                :
     + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
     |                     Payload Data continued ...                |
     +---------------------------------------------------------------+  }
procedure TWebSocketFrame.LoadFromBuffer(var ABuffer: RawByteString);
var
  b: Byte;
  l, i, lmask: Cardinal;
begin
  Clear();
  l := Length(ABuffer);

  // < header
  if l < 2 then
    Exit;

  // base header
  i := 1;
  b := Byte(ABuffer[i]);
  Inc(i);
  FIN := (b and 128) <> 0; // 1000 0000
  RSV1 := (b and 64) <> 0; // 0100 0000
  RSV2 := (b and 32) <> 0; // 0010 0000
  RSV3 := (b and 16) <> 0; // 0001 0000
  Opcode := b and 15;      // 0000 1111

  b := Byte(ABuffer[i]);
  Inc(i);

  // base header #2
  Mask := (b and 128) <> 0;  // 1000 0000
  if Mask then
    lmask := 4
  else
    lmask := 0;
  PayloadLen := b and 127;   // 0111 1111

  if PayloadLen = 127 then
  begin
    // < header + Payload Len
    if l < (2 + 8) then
      Exit;

    PayloadLen := ByteSwap64(PUInt64(@ABuffer[i])^); // network byte order -> x86 byte order
    // < header + Payload Len + Mask + Payload data
    if l < (2 + 8 + lmask + PayloadLen) then
      Exit;

    Inc(i, 8);
  end
  else
  if PayloadLen = 126 then
  begin
    // < header + Payload Len
    if l < (2 + 2) then
      Exit;

    PayloadLen := ByteSwap16(PUInt16(@ABuffer[i])^);
    // < header + Payload Len + Mask + Payload data
    if l < (2 + 2 + lmask + PayloadLen) then
      Exit;

    Inc(i, 2);
  end
  else
  begin
    // < header + data len + mask + data
    if l < (2 + lmask + PayloadLen) then
      Exit;
  end;
  //---
  // masking key
  if Mask then
  begin
    MaskingKey := ByteSwap32(PUInt32(@ABuffer[i])^);
    Inc(i, 4)
  end;
  PayloadData := Copy(ABuffer, i, PayloadLen);
  if Mask and (PayloadLen > 0) then
  begin
    DoXorMasking(@PayloadData[1], MaskingKey, PayloadLen)
  end;
  // delete frame from buffer
  Inc(i, PayloadLen);
  Delete(ABuffer, 1, i - 1);
  //
  DecodedData := PayloadData;
  //
  FIsComplete := True;
end;


procedure TWebSocketFrame.SetAsDeflated;
begin
  RSV1 := True
end;

procedure TWebSocketFrame.SetComplete(const A: Boolean);
begin
  FIsComplete := A;
  FIN := A;
end;

{     0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-------+-+-------------+-------------------------------+
     |F|R|R|R| opcode|M| Payload len |    Extended payload length    |
     |I|S|S|S|  (4)  |A|     (7)     |             (16/64)           |
     |N|V|V|V|       |S|             |   (if payload len==126/127)   |
     | |1|2|3|       |K|             |                               |
     +-+-+-+-+-------+-+-------------+ - - - - - - - - - - - - - - - +
     |     Extended payload length continued, if payload len == 127  |
     + - - - - - - - - - - - - - - - +-------------------------------+
     |                               |Masking-key, if MASK set to 1  |
     +-------------------------------+-------------------------------+
     | Masking-key (continued)       |          Payload Data         |
     +-------------------------------- - - - - - - - - - - - - - - - +
     :                     Payload Data continued ...                :
     + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
     |                     Payload Data continued ...                |
     +---------------------------------------------------------------+  }
function TWebSocketFrame.ToBuffer: RawByteString;
var
  k: Integer;
  h: UInt16;
  extLen, maskKey: RawByteString;
  maskKeyBE: UInt32;
begin
  Result := '';
  if not IsValid then
    Exit;

  h := 0;
  if FIN then
    h := h or $8000;                     // 10000000 00000000
  if RSV1 then
    h := h or $4000;                     // 01000000 00000000
  if RSV2 then
    h := h or $2000;                     // 00100000 00000000
  if RSV3 then
    h := h or $1000;                     // 00010000 00000000

  // opcode
  // isValid() Opcode := Opcode and $7F;    01111111
  h := h or (UInt16(Opcode) shl 8);      // 00001111 00000000

  if Mask then
    h := h or $80;                       // 00000000 10000000

  extLen := '';
  if PayloadLen <= 125 then
  begin
    h := h or PayloadLen;                       // 00000000 01111101
  end
  else
  if PayloadLen <= $FFFF then
  begin
    h := h or 126;                       // 00000000 01111110
    SetLength(extLen, 2);
    PUInt16(@extLen[1])^ := ByteSwap16(UInt16(PayloadLen));
  end
  else
  begin
    h := h or 127;                       // 00000000 01111111
    SetLength(extLen, 8);
    PUInt64(@extLen[1])^ := ByteSwap64(PayloadLen);
  end;

  maskKey := '';
  if Mask then
  begin
    if MaskingKey = 0 then
      MaskingKey := Random_UInt32();
    maskKeyBE := ByteSwap32(MaskingKey);
    SetLength(maskKey, 4);
    PUInt32(@maskKey[1])^ := maskKeyBE;
  end;

  SetLength(Result, 2);
  PUInt16(@Result[1])^ := ByteSwap16(UInt16(h));

  Result := Result + extLen + maskKey + PayloadData;

  if Mask and (PayloadLen > 0) then
  begin
    k := 2 + Length(extLen) + Length(maskKey) + 1;
    DoXorMasking(@Result[K], MaskingKey, PayloadLen)
  end;
end;


end.
