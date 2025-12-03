object fMain: TfMain
  Left = 0
  Top = 0
  Caption = 'TmsaSQLiteINI test'
  ClientHeight = 592
  ClientWidth = 907
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
  object btnDeleteSection: TButton
    Left = 8
    Top = 181
    Width = 129
    Height = 25
    Caption = 'DeleteSection'
    Enabled = False
    TabOrder = 4
    OnClick = btnDeleteSectionClick
  end
  object ledSection: TLabeledEdit
    Left = 8
    Top = 56
    Width = 121
    Height = 23
    EditLabel.Width = 39
    EditLabel.Height = 15
    EditLabel.Caption = 'Section'
    TabOrder = 5
    Text = 'Section Name'
  end
  object lbLog: TListBox
    Left = 327
    Top = 0
    Width = 582
    Height = 592
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ItemHeight = 15
    ParentFont = False
    TabOrder = 6
  end
  object btnDeleteAll: TButton
    Left = 8
    Top = 212
    Width = 129
    Height = 25
    Caption = 'DeleteAll'
    Enabled = False
    TabOrder = 7
    OnClick = btnDeleteAllClick
  end
  object btnEraseSectionKeys: TButton
    Left = 8
    Top = 243
    Width = 129
    Height = 25
    Caption = 'EraseSectionKeys'
    Enabled = False
    TabOrder = 8
    OnClick = btnEraseSectionKeysClick
  end
  object btnReadKeys: TButton
    Left = 8
    Top = 274
    Width = 129
    Height = 25
    Caption = 'ReadKeys'
    TabOrder = 9
    OnClick = btnReadKeysClick
  end
  object btnReadSections: TButton
    Left = 8
    Top = 305
    Width = 129
    Height = 25
    Caption = 'ReadSections'
    TabOrder = 10
    OnClick = btnReadSectionsClick
  end
  object btnValueExists: TButton
    Left = 167
    Top = 168
    Width = 129
    Height = 25
    Caption = 'ValueExists'
    TabOrder = 11
    OnClick = btnValueExistsClick
  end
  object ledKey: TLabeledEdit
    Left = 167
    Top = 213
    Width = 121
    Height = 23
    EditLabel.Width = 19
    EditLabel.Height = 15
    EditLabel.Caption = 'Key'
    TabOrder = 12
    Text = 'Key174'
  end
  object btnVACUUM: TButton
    Left = 176
    Top = 64
    Width = 75
    Height = 25
    Caption = 'VACUUM'
    TabOrder = 13
    OnClick = btnVACUUMClick
  end
  object ledKeyValue: TLabeledEdit
    Left = 167
    Top = 259
    Width = 121
    Height = 23
    EditLabel.Width = 47
    EditLabel.Height = 15
    EditLabel.Caption = 'KeyValue'
    TabOrder = 14
    Text = ''
  end
  object ledDescription: TLabeledEdit
    Left = 167
    Top = 306
    Width = 138
    Height = 23
    EditLabel.Width = 60
    EditLabel.Height = 15
    EditLabel.Caption = 'Description'
    TabOrder = 15
    Text = ''
  end
  object btnWriteValue: TButton
    Left = 176
    Top = 344
    Width = 121
    Height = 25
    Caption = 'WriteValue'
    TabOrder = 16
    OnClick = btnWriteValueClick
  end
  object btnWriteStream: TButton
    Left = 175
    Top = 384
    Width = 121
    Height = 25
    Caption = 'WriteStream'
    TabOrder = 17
    OnClick = btnWriteStreamClick
  end
  object FDConnection1: TFDConnection
    FormatOptions.AssignedValues = [fvMaxStringSize]
    FormatOptions.MaxStringSize = 10000000
    Left = 520
    Top = 16
  end
end
