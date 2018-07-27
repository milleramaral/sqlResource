object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Test open resource sqls'
  ClientHeight = 425
  ClientWidth = 733
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 413
    Top = 73
    Height = 327
    Align = alRight
    ExplicitLeft = 280
    ExplicitTop = 112
    ExplicitHeight = 100
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 73
    Width = 413
    Height = 327
    Align = alClient
    DataSource = DtsCnsTable
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 733
    Height = 73
    Align = alTop
    Padding.Left = 8
    Padding.Top = 5
    Padding.Right = 8
    Padding.Bottom = 8
    TabOrder = 0
    object rdgConnection: TRadioGroup
      Left = 9
      Top = 6
      Width = 168
      Height = 58
      Align = alLeft
      Caption = 'Connection type'
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        'firebird'
        'postgres')
      TabOrder = 0
      OnClick = rdgConnectionClick
    end
    object GroupBox1: TGroupBox
      AlignWithMargins = True
      Left = 185
      Top = 6
      Width = 224
      Height = 58
      Margins.Left = 8
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alLeft
      Caption = 'Resource type name'
      TabOrder = 1
      object edtResourceName: TEdit
        Left = 8
        Top = 24
        Width = 201
        Height = 21
        Color = clInactiveBorder
        ReadOnly = True
        TabOrder = 0
      end
    end
  end
  object mmoSql: TMemo
    Left = 416
    Top = 73
    Width = 317
    Height = 327
    Align = alRight
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object DBNavigator1: TDBNavigator
    Left = 0
    Top = 400
    Width = 733
    Height = 25
    DataSource = DtsCnsTable
    VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel, nbRefresh, nbApplyUpdates, nbCancelUpdates]
    Align = alBottom
    TabOrder = 3
  end
  object SqlCnsTable: TSQLResource
    MaxBlobSize = -1
    Params = <>
    SQLConnection = DtmConnection.ConnectionFirebird
    Left = 24
    Top = 176
  end
  object DspCnstable: TDataSetProvider
    DataSet = SqlCnsTable
    Left = 24
    Top = 224
  end
  object CdsCnsTable: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspCnstable'
    OnReconcileError = CdsCnsTableReconcileError
    Left = 24
    Top = 272
  end
  object DtsCnsTable: TDataSource
    DataSet = CdsCnsTable
    Left = 24
    Top = 328
  end
end
