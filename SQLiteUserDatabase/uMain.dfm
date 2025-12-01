object fMain: TfMain
  Left = 0
  Top = 0
  Caption = 'TmsaSQLiteINI test'
  ClientHeight = 441
  ClientWidth = 911
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object edDBName: TEdit
    Left = 8
    Top = 8
    Width = 297
    Height = 23
    TabOrder = 0
  end
  object btnSectionExists: TButton
    Left = 8
    Top = 88
    Width = 129
    Height = 25
    Caption = 'SectionExists'
    TabOrder = 1
    OnClick = btnSectionExistsClick
  end
  object btnCreateSection: TButton
    Left = 8
    Top = 119
    Width = 129
    Height = 25
    Caption = 'CreateSection'
    TabOrder = 2
    OnClick = btnCreateSectionClick
  end
  object btnKeysCount: TButton
    Left = 8
    Top = 150
    Width = 129
    Height = 25
    Caption = 'KeysCount'
    TabOrder = 3
    OnClick = btnKeysCountClick
  end
  object cbDeleteKeysToo: TCheckBox
    Left = 143
    Top = 185
    Width = 138
    Height = 17
    Caption = 'Delete keys too'
    TabOrder = 4
  end
  object btnDeleteSections: TButton
    Left = 8
    Top = 181
    Width = 129
    Height = 25
    Caption = 'DeleteSections'
    TabOrder = 5
    OnClick = btnDeleteSectionsClick
  end
  object ledSection: TLabeledEdit
    Left = 8
    Top = 56
    Width = 121
    Height = 23
    EditLabel.Width = 39
    EditLabel.Height = 15
    EditLabel.Caption = 'Section'
    TabOrder = 6
    Text = 'Section Name'
  end
  object lbLog: TListBox
    Left = 327
    Top = 0
    Width = 584
    Height = 441
    Align = alRight
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ItemHeight = 15
    ParentFont = False
    TabOrder = 7
  end
  object btnDeleteAll: TButton
    Left = 8
    Top = 212
    Width = 129
    Height = 25
    Caption = 'DeleteAll'
    TabOrder = 8
    OnClick = btnDeleteAllClick
  end
  object btnEraseSection: TButton
    Left = 8
    Top = 243
    Width = 129
    Height = 25
    Caption = 'EraseSection'
    TabOrder = 9
    OnClick = btnEraseSectionClick
  end
  object btnReadSection: TButton
    Left = 8
    Top = 274
    Width = 129
    Height = 25
    Caption = 'ReadSection'
    TabOrder = 10
    OnClick = btnReadSectionClick
  end
  object btnReadSections: TButton
    Left = 8
    Top = 305
    Width = 129
    Height = 25
    Caption = 'ReadSections'
    TabOrder = 11
    OnClick = btnReadSectionsClick
  end
  object btnValueExists: TButton
    Left = 8
    Top = 336
    Width = 129
    Height = 25
    Caption = 'ValueExists'
    TabOrder = 12
    OnClick = btnValueExistsClick
  end
  object ledKey: TLabeledEdit
    Left = 143
    Top = 337
    Width = 121
    Height = 23
    EditLabel.Width = 19
    EditLabel.Height = 15
    EditLabel.Caption = 'Key'
    TabOrder = 13
    Text = 'Key174'
  end
  object btnVACUUM: TButton
    Left = 176
    Top = 64
    Width = 75
    Height = 25
    Caption = 'VACUUM'
    TabOrder = 14
    OnClick = btnVACUUMClick
  end
  object FDConnection1: TFDConnection
    Left = 520
    Top = 16
  end
end
