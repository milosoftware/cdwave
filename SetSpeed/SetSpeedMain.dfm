object Form1: TForm1
  Left = 354
  Top = 103
  Width = 323
  Height = 178
  Caption = 'Wave Sample Rate Change'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 40
    Width = 94
    Height = 13
    Caption = 'Current sample rate:'
  end
  object lOldRate: TLabel
    Left = 112
    Top = 40
    Width = 34
    Height = 13
    Caption = '(no file)'
  end
  object Label3: TLabel
    Left = 8
    Top = 64
    Width = 166
    Height = 13
    Caption = 'New sample rate (samples/second)'
  end
  object Label4: TLabel
    Left = 88
    Top = 120
    Width = 219
    Height = 13
    Caption = 'Note: Pressing this button will change your file!'
  end
  object btnPick: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Choose...'
    TabOrder = 0
    OnClick = btnPickClick
  end
  object eNewRate: TEdit
    Left = 48
    Top = 80
    Width = 121
    Height = 21
    Enabled = False
    TabOrder = 1
    Text = '(no file)'
  end
  object btnChange: TButton
    Left = 8
    Top = 112
    Width = 75
    Height = 25
    Caption = 'Change'
    Enabled = False
    TabOrder = 2
    OnClick = btnChangeClick
  end
  object eFileName: TEdit
    Left = 88
    Top = 8
    Width = 217
    Height = 21
    Enabled = False
    TabOrder = 3
    Text = '(choose a WAV file)'
  end
  object OpenDlg: TOpenDialog
    Filter = 'Wave audio (*.wav)|*.wav'
    Options = [ofHideReadOnly, ofFileMustExist, ofNoReadOnlyReturn, ofEnableSizing]
    Title = 'Select file to change'
    Left = 272
    Top = 48
  end
end
