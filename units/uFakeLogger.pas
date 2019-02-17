unit uFakeLogger;

interface

uses uLoggerInterface;

type
  TFakeLogger = class(TInterfacedObject, ILoggerInterface)
  public
    procedure Emergency(const AFormat: string; const AArgs: array of const); overload;
    procedure Emergency(const AMessage: string); overload;
    procedure Alert(const AFormat: string; const AArgs: array of const); overload;
    procedure Alert(const AMessage: string); overload;
    procedure Critical(const AFormat: string; const AArgs: array of const); overload;
    procedure Critical(const AMessage: string); overload;
    procedure Error(const AFormat: string; const AArgs: array of const); overload;
    procedure Error(const AMessage: string); overload;
    procedure Warning(const AFormat: string; const AArgs: array of const); overload;
    procedure Warning(const AMessage: string); overload;
    procedure Success(const AFormat: string; const AArgs: array of const); overload;
    procedure Success(const AMessage: string); overload;
    procedure Notice(const AFormat: string; const AArgs: array of const); overload;
    procedure Notice(const AMessage: string); overload;
    procedure Info(const AFormat: string; const AArgs: array of const); overload;
    procedure Info(const AMessage: string); overload;
    procedure Debug(const AFormat: string; const AArgs: array of const); overload;
    procedure Debug(const AMessage: string); overload;
    procedure Log(const ALevel: TLogLevel; const AFormat: string; const AArgs: array of const); overload;
    procedure Log(const ALevel: TLogLevel; const AMessage: string); overload;
  end;


implementation

{ TFakeLogger }

procedure TFakeLogger.Alert(const AMessage: string);
begin

end;

procedure TFakeLogger.Alert(const AFormat: string; const AArgs: array of const);
begin

end;

procedure TFakeLogger.Critical(const AFormat: string;
  const AArgs: array of const);
begin

end;

procedure TFakeLogger.Critical(const AMessage: string);
begin

end;

procedure TFakeLogger.Debug(const AFormat: string; const AArgs: array of const);
begin

end;

procedure TFakeLogger.Debug(const AMessage: string);
begin

end;

procedure TFakeLogger.Emergency(const AMessage: string);
begin

end;

procedure TFakeLogger.Emergency(const AFormat: string;
  const AArgs: array of const);
begin

end;

procedure TFakeLogger.Error(const AMessage: string);
begin

end;

procedure TFakeLogger.Error(const AFormat: string; const AArgs: array of const);
begin

end;

procedure TFakeLogger.Info(const AFormat: string; const AArgs: array of const);
begin

end;

procedure TFakeLogger.Info(const AMessage: string);
begin

end;

procedure TFakeLogger.Log(const ALevel: TLogLevel; const AFormat: string;
  const AArgs: array of const);
begin

end;

procedure TFakeLogger.Log(const ALevel: TLogLevel; const AMessage: string);
begin

end;

procedure TFakeLogger.Notice(const AMessage: string);
begin

end;

procedure TFakeLogger.Notice(const AFormat: string;
  const AArgs: array of const);
begin

end;

procedure TFakeLogger.Success(const AFormat: string;
  const AArgs: array of const);
begin

end;

procedure TFakeLogger.Success(const AMessage: string);
begin

end;

procedure TFakeLogger.Warning(const AFormat: string;
  const AArgs: array of const);
begin

end;

procedure TFakeLogger.Warning(const AMessage: string);
begin

end;

end.
