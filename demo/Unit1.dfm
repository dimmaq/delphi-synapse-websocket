object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 645
  ClientWidth = 1082
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object redtlog: TRichEdit
    Left = 0
    Top = 89
    Width = 1082
    Height = 556
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Consolas'
    Font.Style = []
    HideSelection = False
    HideScrollBars = False
    Lines.Strings = (
      'redtlog')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
    Zoom = 100
  end
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 1082
    Height = 89
    Align = alTop
    Caption = 'pnl1'
    TabOrder = 1
    object btnConnect: TButton
      Left = 32
      Top = 24
      Width = 75
      Height = 25
      Caption = 'btnConnect'
      TabOrder = 0
      OnClick = btnConnectClick
    end
    object Edit1: TEdit
      Left = 152
      Top = 8
      Width = 913
      Height = 21
      TabOrder = 1
      Text = 'Edit1'
    end
    object btn1: TButton
      Left = 192
      Top = 48
      Width = 75
      Height = 25
      Caption = 'btn1'
      TabOrder = 2
      OnClick = btn1Click
    end
    object btnSendPing: TButton
      Left = 384
      Top = 48
      Width = 75
      Height = 25
      Caption = 'btnSendPing'
      TabOrder = 3
      OnClick = btnSendPingClick
    end
    object btn2: TButton
      Left = 640
      Top = 48
      Width = 75
      Height = 25
      Caption = 'Test dump'
      TabOrder = 4
      OnClick = btn2Click
    end
  end
end
