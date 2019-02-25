unit uCookieManagerInterface;

interface

uses
  Windows, SysUtils, Classes,
  //
  uAnsiStringList;

type
  ICookieManager = interface
    // load&save list:
    // name=value
    // name2=val2
    procedure LoadFrom(const AHost: string; const ASrc: TStrings);
    procedure LoadFromA(const AHost: AnsiString; const ASrc: TAnsiStrings);
    procedure SaveTo(const AHost: string; const ADest: TStrings);
    procedure SaveToA(const AHost: AnsiString; const ADest: TAnsiStrings);
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

implementation

end.

