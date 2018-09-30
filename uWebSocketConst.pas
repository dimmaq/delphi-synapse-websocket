unit uWebSocketConst;

interface

type
  TWsOpcode = Int8;

const
  wsCodeNoFrame      = -1;
  {:Constants section defining what kind of data are sent from one pont to another}
  {:Continuation frame }
  wsCodeContinuation = $0;
  {:Text frame }
  wsCodeText         = $1;
  {:Binary frame }
  wsCodeBinary       = $2;
  {:Close frame }
  wsCodeClose        = $8;
  {:Ping frame }
  wsCodePing         = $9;
  {:Frame frame }
  wsCodePong         = $A;

  {:Constants section defining close codes}
  {:Normal valid closure, connection purpose was fulfilled}
  wsCloseNormal              = 1000;
  {:Endpoint is going away (like server shutdown) }
  wsCloseShutdown            = 1001;
  {:Protocol error }
  wsCloseErrorProtocol       = 1002;
  {:Unknown frame data type or data type application cannot handle }
  wsCloseErrorData           = 1003;
  {:Reserved }
  wsCloseReserved1           = 1004;
  {:Close received by peer but without any close code. This close code MUST NOT be sent by application. }
  wsCloseNoStatus            = 1005;
  {:Abnotmal connection shutdown close code. This close code MUST NOT be sent by application. }
  wsCloseErrorClose          = 1006;
  {:Received text data are not valid UTF-8. }
  wsCloseErrorUTF8           = 1007;
  {:Endpoint is terminating the connection because it has received a message that violates its policy. Generic error. }
  wsCloseErrorPolicy         = 1008;
  {:Too large message received }
  wsCloseTooLargeMessage     = 1009;
  {:Client is terminating the connection because it has expected the server to negotiate one or more extension, but the server didn't return them in the response message of the WebSocket handshake }
  wsCloseClientExtensionError= 1010;
  {:Server is terminating the connection because it encountered an unexpected condition that prevented it from fulfilling the request }
  wsCloseErrorServerRequest  = 1011;
  {:Connection was closed due to a failure to perform a TLS handshake. This close code MUST NOT be sent by application. }
  wsCloseErrorTLS            = 1015;

  WEBSOCKET_KEY_LEN = 16;

implementation

end.
