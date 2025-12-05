object fMain: TfMain
  Left = 0
  Top = 0
  Caption = 'TmsaSQLiteINI test'
  ClientHeight = 618
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
    Left = 440
    Top = 0
    Width = 469
    Height = 618
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
    Left = 176
    Top = 406
    Width = 121
    Height = 25
    Caption = 'WriteStream'
    TabOrder = 17
    OnClick = btnWriteStreamClick
  end
  object btnReadStream: TButton
    Left = 17
    Top = 464
    Width = 120
    Height = 25
    Caption = 'ReadStream'
    TabOrder = 18
    OnClick = btnReadStreamClick
  end
  object btnWriteDescription: TButton
    Left = 176
    Top = 375
    Width = 121
    Height = 25
    Caption = 'WriteDescription'
    TabOrder = 19
    OnClick = btnWriteDescriptionClick
  end
  object cbCompress: TCheckBox
    Left = 184
    Top = 432
    Width = 97
    Height = 17
    Caption = 'Compress'
    TabOrder = 20
  end
  object Button2: TButton
    Left = 176
    Top = 455
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 21
    OnClick = Button2Click
  end
  object btnReadValue: TButton
    Left = 17
    Top = 495
    Width = 75
    Height = 25
    Caption = 'ReadValue'
    TabOrder = 22
    OnClick = btnReadValueClick
  end
  object ReadInteger: TButton
    Left = 17
    Top = 526
    Width = 75
    Height = 25
    Caption = 'ReadInteger'
    TabOrder = 23
    OnClick = ReadIntegerClick
  end
  object btnReadFloat: TButton
    Left = 98
    Top = 495
    Width = 75
    Height = 25
    Caption = 'ReadFloat'
    TabOrder = 24
    OnClick = btnReadFloatClick
  end
  object btnReadDateTime: TButton
    Left = 98
    Top = 526
    Width = 87
    Height = 25
    Caption = 'ReadDateTime'
    TabOrder = 25
    OnClick = btnReadDateTimeClick
  end
  object Button1: TButton
    Left = 16
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Set now'
    TabOrder = 26
    OnClick = Button1Click
  end
  object btnReadDate: TButton
    Left = 191
    Top = 526
    Width = 97
    Height = 25
    Caption = 'ReadDate'
    TabOrder = 27
    OnClick = btnReadDateClick
  end
  object btnReadTime: TButton
    Left = 191
    Top = 557
    Width = 97
    Height = 25
    Caption = 'ReadTime'
    TabOrder = 28
    OnClick = btnReadTimeClick
  end
  object btnReadBool: TButton
    Left = 40
    Top = 576
    Width = 75
    Height = 25
    Caption = 'ReadBool'
    TabOrder = 29
    OnClick = btnReadBoolClick
  end
  object btnDeleteKey: TButton
    Left = 304
    Top = 212
    Width = 75
    Height = 25
    Caption = 'DeleteKey'
    TabOrder = 30
    OnClick = btnDeleteKeyClick
  end
  object btnCommit: TButton
    Left = 328
    Top = 520
    Width = 75
    Height = 25
    Caption = 'Commit'
    TabOrder = 31
  end
  object btnRollback: TButton
    Left = 328
    Top = 551
    Width = 75
    Height = 25
    Caption = 'Rollback'
    TabOrder = 32
  end
  object FDQuery1: TFDQuery
    Left = 344
    Top = 88
  end
end
