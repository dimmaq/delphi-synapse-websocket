unit uCookieManagerFake;

interface

uses uCookieManagerInterface;

function CreateCookieManagerFake: ICookieManager;

implementation

uses
  System.SysUtils, System.Classes
  //
  uAnsiStringList;

type
  TFakeCookies = class(TInterfacedObject, ICookieManager)
  private
  public
    //---
    procedure LoadFrom(const AHost: string; const AList: TStrings);
    procedure LoadFromA(const AHost: AnsiString; const AList: TAnsiStrings);
    procedure SaveTo(const AHost: string; const AList: TStrings);
    procedure SaveToA(const AHost: AnsiString; const AList: TAnsiStrings);
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

function CreateCookieManagerFake: ICookieManager;
begin
  Result := TFakeCookies.Create;
end;



{ TFakeCookies }

procedure TFakeCookies.Clear;
begin
end;

function TFakeCookies.IsEmpty: Boolean;
begin
  Result := True
end;

procedure TFakeCookies.LoadFrom(const AHost: string; const AList: TStrings);
begin
end;

procedure TFakeCookies.LoadFromA(const AHost: AnsiString; const AList: TAnsiStrings);
begin
end;

procedure TFakeCookies.SaveTo(const AHost: string; const AList: TStrings);
begin
end;

procedure TFakeCookies.SaveToA(const AHost: AnsiString; const AList: TAnsiStrings);
begin
end;

// load &save host, name, value
procedure TFakeCookies.SetValue(const AHost, AName, AValue: string);
begin
end;

procedure TFakeCookies.SetValueA(const AHost, AName, AValue: AnsiString);
begin
end;

function TFakeCookies.GetValue(const AHost, AName: string): string;
begin
  Result := '';
end;

function TFakeCookies.GetValueA(const AHost, AName: AnsiString): AnsiString;
begin
  Result := '';
end;

//
// Cookie: yummy_cookie=choco; tasty_cookie=strawberry
function TFakeCookies.GetCookie(const AHost: string): string;
begin
  Result := '';
end;

function TFakeCookies.GetCookieA(const AHost: AnsiString): AnsiString;
begin
  Result := '';
end;

//
// Set-Cookie: name=newvalue; expires=date; path=/; domain=.example.org.
// Set-Cookie: RMID=732423sdfs73242; expires=Fri, 31 Dec 2010 23:59:59 GMT; path=/; domain=.example.net
procedure TFakeCookies.SetCookie(const AHost, ACookie: string);
begin
end;

procedure TFakeCookies.SetCookieA(const AHost, ACookie: AnsiString);
begin
end;


end.
