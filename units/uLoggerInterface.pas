unit uLoggerInterface;

interface

type
  TLogLevel = (
    logDebug,    // то что реально нужно только автору кода (или человеку который вдруг полезет в исходники что-то там править)
    logInfo,     // то, что может понадобиться техническому специалисту для локализации проблемы и написания качественого bug-report.
    logNotice,   // то, что может понадобиться пользователю, но не обязательно
    logSuccess,  // что-то пошло хорошо. УРА!!!
    logWarning,  // то, что таки есть смысл читать, но можно не читать, если не хочется
    logError,    // с этим нужо че-то делать, но можно потерпеть (недолго ;)
    logCritical, // если с этим ничего не сделать, то будет хуже
    logAlert,    // хуже, о котром говорили на уровне critical уже наступило
    logEmergency // "Приплыли".  За такого рода сообщением обычно следует экстреный выход из программы.
  );
  TLogLevels = set of TLogLevel;

const
  LOG_LEVEL: array[TLogLevel] of string = ('debug', 'info', 'notice', 'success',
    'warning', 'error', 'critical', 'alert', 'emergency');

type
  ILoggerInterface = interface

    procedure Emergency(const AFormat: string; const AArgs: array of const); overload;
    procedure EmergencyA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Emergency(const AMessage: string); overload;
    procedure EmergencyA(const AMessage: AnsiString); overload;

    procedure Alert(const AFormat: string; const AArgs: array of const); overload;
    procedure AlertA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Alert(const AMessage: string); overload;
    procedure AlertA(const AMessage: AnsiString); overload;

    procedure Critical(const AFormat: string; const AArgs: array of const); overload;
    procedure CriticalA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Critical(const AMessage: string); overload;
    procedure CriticalA(const AMessage: AnsiString); overload;

    procedure Error(const AFormat: string; const AArgs: array of const); overload;
    procedure ErrorA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Error(const AMessage: string); overload;
    procedure ErrorA(const AMessage: AnsiString); overload;

    procedure Warning(const AFormat: string; const AArgs: array of const); overload;
    procedure WarningA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Warning(const AMessage: string); overload;
    procedure WarningA(const AMessage: AnsiString); overload;

    procedure Success(const AFormat: string; const AArgs: array of const); overload;
    procedure SuccessA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Success(const AMessage: string); overload;
    procedure SuccessA(const AMessage: AnsiString); overload;

    procedure Notice(const AFormat: string; const AArgs: array of const); overload;
    procedure NoticeA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Notice(const AMessage: string); overload;
    procedure NoticeA(const AMessage: AnsiString); overload;

    procedure Info(const AFormat: string; const AArgs: array of const); overload;
    procedure InfoA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Info(const AMessage: string); overload;
    procedure InfoA(const AMessage: AnsiString); overload;

    procedure Debug(const AFormat: string; const AArgs: array of const); overload;
    procedure DebugA(const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Debug(const AMessage: string); overload;
    procedure DebugA(const AMessage: AnsiString); overload;

    procedure Log(const ALevel: TLogLevel; const AFormat: string; const AArgs: array of const); overload;
    procedure LogA(const ALevel: TLogLevel; const AFormat: AnsiString; const AArgs: array of const); overload;
    procedure Log(const ALevel: TLogLevel; const AMessage: string); overload;
    procedure LogA(const ALevel: TLogLevel; const AMessage: AnsiString); overload;
  end;

  ILoggerAwareInterface = interface
    procedure SetLogger(const ALogger: ILoggerInterface);
    property Logger: ILoggerInterface write SetLogger;
  end;


implementation

end.
