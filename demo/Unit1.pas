unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  //
  synaws, uWorkThreadWebSocket, uSimpleConnectParam, uConnectParamInterface,
  uLoggerInterface, uReLog3, uCookieManager;

type
  TForm1 = class(TForm)
    btnConnect: TButton;
    redtlog: TRichEdit;
    pnl1: TPanel;
    Edit1: TEdit;
    btn1: TButton;
    btnSendPing: TButton;
    btn2: TButton;
    procedure btnConnectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSendPingClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
  private
    FThread: TWorkThreadWebSocket;
    FParams: IConnectParam;
    FLog: ILoggerInterface;
    FCookies: ICookieManager;
    procedure ThreadTermnated(Sender: TObject);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  uGlobalVars, uWebSocketConst, ZLibEx, ZLibExApi,
  //
  uTest;

{$R *.dfm}

procedure TForm1.btn1Click(Sender: TObject);
begin
  FThread.SendText((Edit1.Text));
end;

procedure TForm1.btn2Click(Sender: TObject);
begin
  TestDumpDir('..\..\dump\', FLog);
end;

procedure TForm1.btnConnectClick(Sender: TObject);
const
  URL1 = 'wss://pubsub-edge.twitch.tv/v1';
  URL2 = 'ws://127.0.0.1:8080/echo';
begin
  if FThread <> nil then
    Exit;

  FThread := TWorkThreadWebSocket.Create(URL2, FParams, FLog);
  FThread.OnTerminate := ThreadTermnated;

  FThread.Cookies := FCookies;
  FThread.DumpPath := gDirDump;
  FThread.DumpFileName := 'ws.txt';
  FThread.DumpFlow := True;

  FThread.Start()
end;

procedure TForm1.btnSendPingClick(Sender: TObject);
begin
  FThread.Send('', wsCodePing);
end;

procedure TForm1.FormCreate(Sender: TObject);
const
  COOKIES = 'unique_id=832280750750e794; ' +
            'persistent=55142364%3A%3Al7iv9kh55eb7ltzkndkw6nmfiye20u; ' +
            'sudo=eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1NTE0MjM2NCIsImF1ZCI6WyJzdWRvIl0sImV4cCI6MTUzNzUyMzM3OCwiaWF0IjoxNTM3NTE5Nzc4fQ==.LoYxS2sSEuEAC_uYYpk6OV7x0YpxB-gkGr-Q0UhGaNd0AL3ZqthDmgeA-CnHFvIdiuMFpUNWq0EA-e2sJ0ZRWw==; ' +
            'bits_sudo=eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1NTE0MjM2NCIsImF1ZCI6WyJzdWRvIiwiYml0cyJdLCJleHAiOjE1MzgxMjQ1NzgsImlhdCI6MTUzNzUxOTc3OH0=.9u7CpVUK0r2Qr82T9-m1AKZAkrNACrNV-7Jj8iSmCA8QFtZ3F_wf1JRN_ZLHPEBm54sI5UzDdcEjcwQiMQqOpQ==; ' +
            'login=dimmaq2; ' +
            'name=dimmaq2; ' +
            'last_login=2018-09-21T08:49:38Z; ' +
            'api_token=a0391d9c88e811578a1e4c73b7930c79; ' +
            'device_cookie=eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3Bhc3Nwb3J0LnR3aXRjaC50diIsInN1YiI6ImRpbW1hcTIiLCJhdWQiOiJicnV0ZS1mb3JjZS1wcm90ZWN0aW9uIiwiZXhwIjoxNTUzMDcxNzc4LCJpYXQiOjE1Mzc1MTk3NzgsIm5vbmNlIjoiT0N3bXluSmo5aUN' +
                'xUFk3S0NGZlRNUklPTU92ZHNiMXZtVzVqanBlaXVOaz0ifQ%3D%3D.-5FNnh5SOkOp-HeSc3Sg19d7lRrp3N7KL5s6GY9JqSJzPbUbnaHF1l9yZwSkg8_hVVOMrDp_XVQpAvV_dmDbtw%3D%3D; ' +
            'twilight-user={%22authToken%22:%2295f5ko42wu9tvipc52wdo0w54n08cd%22%2C%22displayName%22:%22dimmaq2%22%2C%22id%22:%2255142364%22%2C%22login%22:%22dimmaq2%22%2C%22roles%22:{%22isStaff%22:false}%2C%22version%22:2}; ' +
            'auth-token=95f5ko42wu9tvipc52wdo0w54n08cd; ' +
            'session_unique_id=Gkbwu5VvZIBCyy0RDTutQja6eMN0JscW; ' +
            'server_session_id=05c946119a134227b078d14783b619e0';
var
  re: TReLog3;
begin
  ApplyGlobalPaths('');
  ForceDirectories(gDirDump);

  FParams := TSimpleConnectParam.Create;
  FParams.SocksProxyA := '127.0.0.1:1088';
  re := TReLog3.Create(redtlog, 'log.txt');;
  re.TrimOut := True;
  FLog := re;
  FCookies := CreateCookieManager('');
  FCookies.AddRaw('pubsub-edge.twitch.tv', COOKIES);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FThread.Free;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  FLog.Info('form show');
end;

procedure TForm1.ThreadTermnated(Sender: TObject);
var
  t: TThread;
  e: Exception;
begin
  FThread := nil;

  t := Sender as TThread;
  e := t.FatalException as Exception;
  if Assigned(e) then
    FLog.Info('TERMINATED %s %s', [E.ClassName, E.Message])
  else
    FLog.Info('TERMINATED');
end;

end.
