program Project1;

uses
  madExcept,
  madLinkDisAsm,
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  synaws in '..\synaws.pas',
  uWorkThreadWebSocket in '..\uWorkThreadWebSocket.pas',
  uWebSocketUpgrade in '..\uWebSocketUpgrade.pas',
  uWebSocketFrame in '..\uWebSocketFrame.pas',
  uWebSocketConst in '..\uWebSocketConst.pas',
  uTest in 'uTest.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
