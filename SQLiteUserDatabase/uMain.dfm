object fMain: TfMain
  Left = 0
  Top = 0
  Caption = 'TmsaSQLiteINI test'
  ClientHeight = 618
  ClientWidth = 1312
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
    Top = 243
    Width = 129
    Height = 25
    Caption = 'EraseSectionKeys'
    TabOrder = 2
    OnClick = btnEraseSectionKeysClick
  end
  object btnReadKeys: TButton
    Left = 8
    Top = 274
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
    Top = 72
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
    Left = 432
    Top = 0
    Width = 880
    Height = 618
    ActivePage = TabSheet1
    Align = alRight
    TabOrder = 24
    object TabSheet1: TTabSheet
      Caption = 'Tree'
      object TreeView1: TTreeView
        Left = 0
        Top = 121
        Width = 872
        Height = 317
        Align = alClient
        Indent = 19
        TabOrder = 0
        OnDragDrop = TreeView1DragDrop
        OnDragOver = TreeView1DragOver
        OnStartDrag = TreeView1StartDrag
        ExplicitWidth = 490
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 872
        Height = 97
        Align = alTop
        BevelEdges = []
        BevelOuter = bvNone
        TabOrder = 1
        ExplicitWidth = 490
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
      end
      object Panel2: TPanel
        Left = 0
        Top = 97
        Width = 872
        Height = 24
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 2
        ExplicitWidth = 490
      end
      object lbLog: TListBox
        Left = 0
        Top = 438
        Width = 872
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
        ExplicitWidth = 490
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Log'
      ImageIndex = 1
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
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=C:\Temp\options.db'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 320
    Top = 72
  end
end
