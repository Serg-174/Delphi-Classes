object fMain: TfMain
  Left = 0
  Top = 0
  Caption = 'TmsaSQLiteINI test'
  ClientHeight = 618
  ClientWidth = 1407
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 121
    Width = 34
    Height = 15
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 8
    Top = 142
    Width = 34
    Height = 15
    Caption = 'Label2'
  end
  object Label3: TLabel
    Left = 16
    Top = 200
    Width = 34
    Height = 15
    Caption = 'Label3'
  end
  object Label4: TLabel
    Left = 17
    Top = 221
    Width = 34
    Height = 15
    Caption = 'Label4'
  end
  object Label5: TLabel
    Left = 16
    Top = 40
    Width = 34
    Height = 15
    Caption = 'Label5'
  end
  object edDBName: TEdit
    Left = 8
    Top = 8
    Width = 385
    Height = 23
    TabOrder = 0
    Text = #1089#1098#1077#1096#1100' '#1077#1097#1105' '#1101#1090#1080#1093' '#1084#1103#1075#1082#1080#1093' '#1092#1088#1072#1085#1094#1091#1079#1089#1082#1080#1093' '#1073#1091#1083#1086#1082', '#1076#1072' '#1074#1099#1087#1077#1081' '#1078#1077' '#1095#1072#1102
  end
  object btnKeysCount: TButton
    Left = 9
    Top = 90
    Width = 129
    Height = 25
    Caption = 'KeysCount'
    TabOrder = 1
    OnClick = btnKeysCountClick
  end
  object btnEraseSectionKeys: TButton
    Left = 8
    Top = 298
    Width = 129
    Height = 25
    Caption = 'EraseSectionKeys'
    TabOrder = 2
    OnClick = btnEraseSectionKeysClick
  end
  object btnReadKeys: TButton
    Left = 8
    Top = 329
    Width = 129
    Height = 25
    Caption = 'ReadKeys'
    TabOrder = 3
    OnClick = btnReadKeysClick
  end
  object btnValueExists: TButton
    Left = 167
    Top = 168
    Width = 129
    Height = 25
    Caption = 'ValueExists'
    TabOrder = 4
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
    TabOrder = 5
    Text = 'Key174'
  end
  object btnVACUUM: TButton
    Left = 144
    Top = 90
    Width = 75
    Height = 25
    Caption = 'VACUUM'
    TabOrder = 6
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
    TabOrder = 7
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
    TabOrder = 8
    Text = ''
  end
  object btnWriteValue: TButton
    Left = 176
    Top = 344
    Width = 121
    Height = 25
    Caption = 'WriteValue'
    TabOrder = 9
    OnClick = btnWriteValueClick
  end
  object btnWriteStream: TButton
    Left = 176
    Top = 406
    Width = 121
    Height = 25
    Caption = 'WriteStream'
    TabOrder = 10
    OnClick = btnWriteStreamClick
  end
  object btnReadStream: TButton
    Left = 17
    Top = 464
    Width = 120
    Height = 25
    Caption = 'ReadStream'
    TabOrder = 11
    OnClick = btnReadStreamClick
  end
  object btnWriteDescription: TButton
    Left = 176
    Top = 375
    Width = 121
    Height = 25
    Caption = 'WriteDescription'
    TabOrder = 12
    OnClick = btnWriteDescriptionClick
  end
  object cbCompress: TCheckBox
    Left = 184
    Top = 432
    Width = 97
    Height = 17
    Caption = 'Compress'
    TabOrder = 13
  end
  object Button2: TButton
    Left = 176
    Top = 455
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 14
    OnClick = Button2Click
  end
  object btnReadValue: TButton
    Left = 17
    Top = 495
    Width = 75
    Height = 25
    Caption = 'ReadValue'
    TabOrder = 15
    OnClick = btnReadValueClick
  end
  object ReadInteger: TButton
    Left = 8
    Top = 526
    Width = 75
    Height = 25
    Caption = 'ReadInteger'
    TabOrder = 16
    OnClick = ReadIntegerClick
  end
  object btnReadFloat: TButton
    Left = 98
    Top = 495
    Width = 75
    Height = 25
    Caption = 'ReadFloat'
    TabOrder = 17
    OnClick = btnReadFloatClick
  end
  object btnReadDateTime: TButton
    Left = 98
    Top = 526
    Width = 87
    Height = 25
    Caption = 'ReadDateTime'
    TabOrder = 18
    OnClick = btnReadDateTimeClick
  end
  object Button1: TButton
    Left = 16
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Set now'
    TabOrder = 19
    OnClick = Button1Click
  end
  object btnReadDate: TButton
    Left = 191
    Top = 526
    Width = 97
    Height = 25
    Caption = 'ReadDate'
    TabOrder = 20
    OnClick = btnReadDateClick
  end
  object btnReadTime: TButton
    Left = 191
    Top = 557
    Width = 97
    Height = 25
    Caption = 'ReadTime'
    TabOrder = 21
    OnClick = btnReadTimeClick
  end
  object btnReadBool: TButton
    Left = 40
    Top = 576
    Width = 75
    Height = 25
    Caption = 'ReadBool'
    TabOrder = 22
    OnClick = btnReadBoolClick
  end
  object btnDeleteKey: TButton
    Left = 304
    Top = 212
    Width = 75
    Height = 25
    Caption = 'DeleteKey'
    TabOrder = 23
    OnClick = btnDeleteKeyClick
  end
  object PageControl1: TPageControl
    Left = 409
    Top = 0
    Width = 998
    Height = 618
    ActivePage = TabSheet1
    Align = alRight
    TabOrder = 24
    object TabSheet1: TTabSheet
      Caption = 'Tree'
      object TreeView1: TTreeView
        Left = 0
        Top = 162
        Width = 990
        Height = 276
        Align = alClient
        Indent = 19
        TabOrder = 0
        OnDragDrop = TreeView1DragDrop
        OnDragOver = TreeView1DragOver
        OnStartDrag = TreeView1StartDrag
        ExplicitTop = 121
        ExplicitHeight = 317
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 990
        Height = 97
        Align = alTop
        BevelEdges = []
        BevelOuter = bvNone
        TabOrder = 1
        object btnRefresh: TButton
          Left = 8
          Top = 2
          Width = 75
          Height = 25
          Caption = 'Refresh'
          TabOrder = 0
          OnClick = btnRefreshClick
        end
        object btnSectionExists: TButton
          Left = 8
          Top = 33
          Width = 89
          Height = 25
          Caption = 'SectionExists'
          TabOrder = 1
          OnClick = btnSectionExistsClick
        end
        object btnCreateSection: TButton
          Left = 8
          Top = 64
          Width = 89
          Height = 25
          Caption = 'CreateSection'
          TabOrder = 2
          OnClick = btnCreateSectionClick
        end
        object ledSection: TLabeledEdit
          Left = 103
          Top = 65
          Width = 121
          Height = 23
          EditLabel.Width = 39
          EditLabel.Height = 15
          EditLabel.Caption = 'Section'
          TabOrder = 3
          Text = 'SectionName'
        end
        object btnDeleteSection: TButton
          Left = 392
          Top = 33
          Width = 89
          Height = 25
          Caption = 'DeleteSection'
          TabOrder = 4
          OnClick = btnDeleteSectionClick
        end
        object btnDeleteAll: TButton
          Left = 423
          Top = 2
          Width = 58
          Height = 25
          Caption = 'DeleteAll'
          TabOrder = 5
          OnClick = btnDeleteAllClick
        end
        object btnReadSections: TButton
          Left = 143
          Top = 2
          Width = 89
          Height = 25
          Caption = 'ReadSections'
          TabOrder = 6
          OnClick = btnReadSectionsClick
        end
        object btnGetSectionFullPath: TButton
          Left = 528
          Top = 2
          Width = 201
          Height = 25
          Caption = 'GetSectionFullPath'
          TabOrder = 7
          OnClick = btnGetSectionFullPathClick
        end
        object Edit1: TEdit
          Left = 504
          Top = 33
          Width = 337
          Height = 23
          TabOrder = 8
          Text = 'Edit1'
        end
        object btnRenameSection: TButton
          Left = 230
          Top = 66
          Width = 105
          Height = 25
          Caption = 'RenameSection'
          TabOrder = 9
          OnClick = btnRenameSectionClick
        end
        object Edit8: TEdit
          Left = 360
          Top = 68
          Width = 121
          Height = 23
          TabOrder = 10
          Text = 'Edit8'
        end
        object btnWriteSectionDescription: TButton
          Left = 487
          Top = 66
          Width = 153
          Height = 25
          Caption = 'WriteSectionDescription'
          TabOrder = 11
          OnClick = btnWriteSectionDescriptionClick
        end
        object btnMakeRoot: TButton
          Left = 272
          Top = 8
          Width = 75
          Height = 25
          Caption = 'MakeRoot'
          TabOrder = 12
          OnClick = btnMakeRootClick
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 97
        Width = 990
        Height = 65
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 2
        object Edit10: TEdit
          Left = 8
          Top = 24
          Width = 307
          Height = 23
          TabOrder = 0
          Text = '\'#1056#1072#1079#1076' 1\'#1056#1072#1079#1076' 2\ '#1056#1072#1079#1076' 3\\'
        end
        object btnForceSections: TButton
          Left = 328
          Top = 24
          Width = 185
          Height = 25
          Caption = 'ForceSections'
          TabOrder = 1
          OnClick = btnForceSectionsClick
        end
        object Edit11: TEdit
          Left = 560
          Top = 16
          Width = 121
          Height = 23
          TabOrder = 2
          Text = 'Edit11'
        end
        object btnChangeSectionSortOrder: TButton
          Left = 687
          Top = 6
          Width = 145
          Height = 25
          Caption = 'ChangeSectionSortOrder'
          TabOrder = 3
          OnClick = btnChangeSectionSortOrderClick
        end
        object btnChangeKeySortOrder: TButton
          Left = 687
          Top = 37
          Width = 137
          Height = 25
          Caption = 'ChangeKeySortOrder'
          TabOrder = 4
          OnClick = btnChangeKeySortOrderClick
        end
      end
      object lbLog: TListBox
        Left = 0
        Top = 438
        Width = 990
        Height = 150
        Align = alBottom
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ItemHeight = 15
        ParentFont = False
        TabOrder = 3
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Log'
      ImageIndex = 1
      object Edit2: TEdit
        Left = 24
        Top = 47
        Width = 265
        Height = 23
        TabOrder = 0
        Text = 'Edit2'
      end
      object Edit3: TEdit
        Left = 312
        Top = 47
        Width = 273
        Height = 23
        TabOrder = 1
        Text = 'Edit3'
      end
      object btnReadKey: TButton
        Left = 72
        Top = 7
        Width = 75
        Height = 25
        Caption = 'ReadKey'
        TabOrder = 2
        OnClick = btnReadKeyClick
      end
      object Edit4: TEdit
        Left = 24
        Top = 76
        Width = 273
        Height = 23
        TabOrder = 3
        Text = 'Edit4'
      end
      object Edit5: TEdit
        Left = 303
        Top = 76
        Width = 273
        Height = 23
        TabOrder = 4
        Text = 'Edit5'
      end
      object CheckBox1: TCheckBox
        Left = 32
        Top = 183
        Width = 97
        Height = 17
        Caption = 'CheckBox1'
        TabOrder = 5
      end
      object btnReadSection: TButton
        Left = 168
        Top = 7
        Width = 121
        Height = 25
        Caption = 'ReadSection'
        TabOrder = 6
        OnClick = btnReadSectionClick
      end
      object Edit6: TEdit
        Left = 26
        Top = 105
        Width = 263
        Height = 23
        TabOrder = 7
        Text = 'Edit6'
      end
      object Edit7: TEdit
        Left = 328
        Top = 16
        Width = 265
        Height = 23
        TabOrder = 8
        Text = 'Edit7'
      end
    end
  end
  object Button3: TButton
    Left = 344
    Top = 585
    Width = 59
    Height = 25
    Caption = 'Clear'
    TabOrder = 25
    OnClick = Button3Click
  end
  object Button5: TButton
    Left = 8
    Top = 163
    Width = 75
    Height = 25
    Caption = 'Button5'
    TabOrder = 26
    OnClick = Button5Click
  end
  object Button4: TButton
    Left = 8
    Top = 242
    Width = 75
    Height = 25
    Caption = 'Button4'
    TabOrder = 27
    OnClick = Button4Click
  end
  object btnCountOfWords: TButton
    Left = 8
    Top = 59
    Width = 153
    Height = 25
    Caption = 'btnCountOfWords'
    TabOrder = 28
    OnClick = btnCountOfWordsClick
  end
  object CheckBox2: TCheckBox
    Left = 184
    Top = 64
    Width = 97
    Height = 17
    Caption = 'CheckBox2'
    TabOrder = 29
  end
  object btnGetWordNum: TButton
    Left = 304
    Top = 58
    Width = 99
    Height = 25
    Caption = 'GetWordNum'
    TabOrder = 30
    OnClick = btnGetWordNumClick
  end
  object Edit9: TEdit
    Left = 312
    Top = 96
    Width = 67
    Height = 23
    TabOrder = 31
    Text = '3'
  end
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=C:\Temp\options.db'
      'DriverID=SQLite')
    Connected = True
    LoginPrompt = False
    Left = 336
    Top = 136
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection
    Left = 360
    Top = 376
  end
  object FDStoredProc1: TFDStoredProc
    Connection = FDConnection
    StoredProcName = 'sav'
    Left = 368
    Top = 480
  end
end
