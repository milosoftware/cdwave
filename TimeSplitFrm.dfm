object TimeSplitForm: TTimeSplitForm
  Left = 231
  Top = 124
  ActiveControl = eMinutes
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Time Interval Split'
  ClientHeight = 243
  ClientWidth = 321
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label5: TLabel
    Left = 144
    Top = 240
    Width = 32
    Height = 13
    Caption = 'Label5'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 305
    Height = 161
    Caption = 'Settings'
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 32
      Width = 98
      Height = 13
      Caption = 'Add split point every:'
    end
    object Label2: TLabel
      Left = 72
      Top = 58
      Width = 36
      Height = 13
      Caption = 'minutes'
    end
    object Label3: TLabel
      Left = 72
      Top = 90
      Width = 40
      Height = 13
      Caption = 'seconds'
    end
    object eMinutes: TEdit
      Left = 16
      Top = 56
      Width = 33
      Height = 21
      TabOrder = 0
      Text = '0'
    end
    object udMinutes: TUpDown
      Left = 49
      Top = 56
      Width = 15
      Height = 21
      Associate = eMinutes
      Min = 0
      Max = 80
      Position = 0
      TabOrder = 1
      Wrap = False
    end
    object eSeconds: TEdit
      Left = 16
      Top = 88
      Width = 33
      Height = 21
      TabOrder = 2
      Text = '0'
    end
    object udSeconds: TUpDown
      Left = 49
      Top = 88
      Width = 15
      Height = 21
      Associate = eSeconds
      Min = 0
      Max = 59
      Position = 0
      TabOrder = 3
      Wrap = False
    end
    object Panel1: TPanel
      Left = 128
      Top = 32
      Width = 169
      Height = 89
      BevelInner = bvRaised
      BevelOuter = bvLowered
      TabOrder = 4
      object Label4: TLabel
        Left = 73
        Top = 44
        Width = 40
        Height = 13
        Caption = 'seconds'
      end
      object cbFuzzy: TCheckBox
        Left = 16
        Top = 8
        Width = 129
        Height = 17
        Caption = 'Look for silence within'
        TabOrder = 0
        OnClick = cbFuzzyClick
      end
      object eSilence: TEdit
        Left = 16
        Top = 36
        Width = 33
        Height = 21
        Enabled = False
        TabOrder = 1
        Text = '10'
      end
      object udSilence: TUpDown
        Left = 49
        Top = 36
        Width = 15
        Height = 21
        Associate = eSilence
        Enabled = False
        Min = 0
        Max = 59
        Position = 10
        TabOrder = 2
        Wrap = False
      end
    end
    object cbAtMarker: TCheckBox
      Left = 16
      Top = 128
      Width = 281
      Height = 17
      Caption = 'Start at the marker position'
      TabOrder = 5
    end
  end
  object btnOk: TBitBtn
    Left = 8
    Top = 184
    Width = 65
    Height = 33
    TabOrder = 1
    OnClick = btnApplyClick
    Kind = bkOK
  end
  object btnCancel: TBitBtn
    Left = 248
    Top = 184
    Width = 67
    Height = 33
    TabOrder = 2
    Kind = bkCancel
  end
  object btnHelp: TBitBtn
    Left = 168
    Top = 184
    Width = 67
    Height = 33
    TabOrder = 3
    Kind = bkHelp
  end
  object btnApply: TBitBtn
    Left = 88
    Top = 184
    Width = 65
    Height = 33
    Caption = '&Apply'
    TabOrder = 4
    OnClick = btnApplyClick
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000010000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333444444
      33333333333F8888883F33330000324334222222443333388F3833333388F333
      000032244222222222433338F8833FFFFF338F3300003222222AAAAA22243338
      F333F88888F338F30000322222A33333A2224338F33F8333338F338F00003222
      223333333A224338F33833333338F38F00003222222333333A444338FFFF8F33
      3338888300003AAAAAAA33333333333888888833333333330000333333333333
      333333333333333333FFFFFF000033333333333344444433FFFF333333888888
      00003A444333333A22222438888F333338F3333800003A2243333333A2222438
      F38F333333833338000033A224333334422224338338FFFFF8833338000033A2
      22444442222224338F3388888333FF380000333A2222222222AA243338FF3333
      33FF88F800003333AA222222AA33A3333388FFFFFF8833830000333333AAAAAA
      3333333333338888883333330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
  end
end
