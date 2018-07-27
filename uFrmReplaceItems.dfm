object frmReplaceItems: TfrmReplaceItems
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Replace items'
  ClientHeight = 297
  ClientWidth = 551
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 256
    Width = 551
    Height = 41
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      551
      41)
    object Label1: TLabel
      Left = 8
      Top = 16
      Width = 162
      Height = 13
      Caption = 'for delete row press crtl+DELETE '
    end
    object BitBtn1: TBitBtn
      Left = 387
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 0
    end
    object BitBtn2: TBitBtn
      Left = 467
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 1
    end
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 0
    Width = 551
    Height = 256
    Align = alClient
    DataSource = DataSource1
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'KEY'
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'VALUE'
        Width = 400
        Visible = True
      end>
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 104
    Top = 160
    object ClientDataSet1KEY: TStringField
      DisplayLabel = 'Text'
      FieldName = 'KEY'
      Size = 1000
    end
    object ClientDataSet1VALUE: TStringField
      DisplayLabel = 'Replace to'
      FieldName = 'VALUE'
      Size = 1000
    end
  end
  object DataSource1: TDataSource
    DataSet = ClientDataSet1
    Left = 104
    Top = 208
  end
end
