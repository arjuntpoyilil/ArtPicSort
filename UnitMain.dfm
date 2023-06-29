object FormMain: TFormMain
  Left = 0
  Top = 0
  Anchors = []
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'ArtPicSort'
  ClientHeight = 177
  ClientWidth = 338
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object LabelPer: TLabel
    Left = 168
    Top = 126
    Width = 2
    Height = 12
    Color = clAqua
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 15725383
    Font.Height = -9
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object SourceLabel: TLabel
    Left = 8
    Top = 20
    Width = 39
    Height = 15
    Caption = 'Source'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object DestinationLabel: TLabel
    Left = 8
    Top = 49
    Width = 64
    Height = 15
    Caption = 'Destination'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LabelCopy: TLabel
    Left = 274
    Top = 126
    Width = 60
    Height = 12
    Caption = #169'Arjun T Poyilil'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 15725383
    Font.Height = -9
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object LabelFileName: TLabel
    Left = 1
    Top = 126
    Width = 2
    Height = 12
    Color = clAqua
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 15725383
    Font.Height = -9
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object ProgressBar: TProgressBar
    Left = 0
    Top = 160
    Width = 338
    Height = 17
    Align = alBottom
    TabOrder = 5
    ExplicitTop = 155
    ExplicitWidth = 334
  end
  object SourceEdit: TEdit
    Left = 79
    Top = 16
    Width = 218
    Height = 23
    TabOrder = 0
    Text = 'Select the source folder'
  end
  object DestinationEdit: TEdit
    Left = 79
    Top = 45
    Width = 218
    Height = 23
    TabOrder = 1
    Text = 'Select the destination folder'
  end
  object SourceButton: TButton
    Left = 304
    Top = 16
    Width = 26
    Height = 23
    Caption = '...'
    TabOrder = 2
    OnClick = SourceButtonClick
  end
  object DestinationButton: TButton
    Left = 304
    Top = 45
    Width = 26
    Height = 23
    Caption = '...'
    TabOrder = 3
    OnClick = DestinationButtonClick
  end
  object TransferButton: TButton
    Left = 132
    Top = 97
    Width = 75
    Height = 25
    Caption = 'Transfer'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnClick = TransferButtonClick
  end
  object RdBtnCopy: TRadioButton
    Left = 80
    Top = 74
    Width = 57
    Height = 17
    Caption = 'Copy'
    Checked = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 6
    TabStop = True
  end
  object RdBtnMove: TRadioButton
    Left = 201
    Top = 74
    Width = 56
    Height = 17
    Caption = 'Move'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 7
  end
  object ProgressBarSingle: TProgressBar
    Left = 0
    Top = 143
    Width = 338
    Height = 17
    Align = alBottom
    TabOrder = 8
    ExplicitTop = 138
    ExplicitWidth = 334
  end
  object BackgroundWorker: TBackgroundWorker
    OnWork = BackgroundWorkerWork
    OnWorkComplete = BackgroundWorkerWorkComplete
    OnWorkProgress = BackgroundWorkerWorkProgress
    Left = 16
    Top = 80
  end
end
