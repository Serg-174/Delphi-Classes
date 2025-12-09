unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.IOUtils, Vcl.ExtCtrls, System.Generics.Collections, SQLiteUserDatabase,
  System.StrUtils, Vcl.Mask, FireDAC.Stan.Def, FireDAC.VCLUI.Wait, FireDAC.VCLUI.Controls, FireDAC.Stan.Intf,
  FireDAC.Phys, FireDAC.Phys.SQLite, Vcl.ComCtrls, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, Data.DB, FireDAC.Comp.Client, uTreeLoader, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TfMain = class(TForm)
    edDBName: TEdit;
    btnKeysCount: TButton;
    btnEraseSectionKeys: TButton;
    btnReadKeys: TButton;
    btnValueExists: TButton;
    ledKey: TLabeledEdit;
    btnVACUUM: TButton;
    ledKeyValue: TLabeledEdit;
    ledDescription: TLabeledEdit;
    btnWriteValue: TButton;
    btnWriteStream: TButton;
    btnReadStream: TButton;
    btnWriteDescription: TButton;
    cbCompress: TCheckBox;
    Button2: TButton;
    btnReadValue: TButton;
    ReadInteger: TButton;
    btnReadFloat: TButton;
    btnReadDateTime: TButton;
    Button1: TButton;
    btnReadDate: TButton;
    btnReadTime: TButton;
    btnReadBool: TButton;
    btnDeleteKey: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TreeView1: TTreeView;
    FDConnection: TFDConnection;
    Panel1: TPanel;
    btnRefresh: TButton;
    Panel2: TPanel;
    btnSectionExists: TButton;
    btnCreateSection: TButton;
    ledSection: TLabeledEdit;
    btnDeleteSection: TButton;
    btnDeleteAll: TButton;
    btnReadSections: TButton;
    lbLog: TListBox;
    Button3: TButton;
    FDQuery1: TFDQuery;
    FDStoredProc1: TFDStoredProc;
    Label1: TLabel;
    Label2: TLabel;
    Button5: TButton;
    Label3: TLabel;
    Label4: TLabel;
    Button4: TButton;
    btnGetSectionFullPath: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    btnReadKey: TButton;
    Edit4: TEdit;
    Edit5: TEdit;
    CheckBox1: TCheckBox;
    btnReadSection: TButton;
    Edit6: TEdit;
    Edit7: TEdit;
    btnRenameSection: TButton;
    Edit8: TEdit;
    btnWriteSectionDescription: TButton;
    btnCountOfWords: TButton;
    Label5: TLabel;
    CheckBox2: TCheckBox;
    btnGetWordNum: TButton;
    Edit9: TEdit;
    btnMakeRoot: TButton;
    Edit10: TEdit;
    btnForceSections: TButton;
    Edit11: TEdit;
    btnChangeSectionSortOrder: TButton;
    btnChangeKeySortOrder: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSectionExistsClick(Sender: TObject);
    procedure btnCreateSectionClick(Sender: TObject);
    procedure btnKeysCountClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnDeleteSectionClick(Sender: TObject);
    procedure btnDeleteAllClick(Sender: TObject);
    procedure btnEraseSectionKeysClick(Sender: TObject);
    procedure btnReadKeysClick(Sender: TObject);
    procedure btnReadSectionsClick(Sender: TObject);
    procedure btnValueExistsClick(Sender: TObject);
    procedure btnVACUUMClick(Sender: TObject);
    procedure btnWriteValueClick(Sender: TObject);
    procedure btnWriteStreamClick(Sender: TObject);
    procedure btnWriteDescriptionClick(Sender: TObject);
    procedure btnReadStreamClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnReadValueClick(Sender: TObject);
    procedure ReadIntegerClick(Sender: TObject);
    procedure btnReadFloatClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnReadDateTimeClick(Sender: TObject);
    procedure btnReadDateClick(Sender: TObject);
    procedure btnReadTimeClick(Sender: TObject);
    procedure btnReadBoolClick(Sender: TObject);
    procedure btnDeleteKeyClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure TreeView1StartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure TreeView1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeView1DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure btnGetSectionFullPathClick(Sender: TObject);
    procedure btnReadKeyClick(Sender: TObject);
    procedure btnReadSectionClick(Sender: TObject);
    procedure btnRenameSectionClick(Sender: TObject);
    procedure btnWriteSectionDescriptionClick(Sender: TObject);
    procedure btnCountOfWordsClick(Sender: TObject);
    procedure btnGetWordNumClick(Sender: TObject);
    procedure btnMakeRootClick(Sender: TObject);
    procedure btnForceSectionsClick(Sender: TObject);
    procedure btnChangeSectionSortOrderClick(Sender: TObject);
    procedure btnChangeKeySortOrderClick(Sender: TObject);

  private
    { Private declarations }
    FMyOptions: TmsaSQLiteUserDatabase;
    FSectionsLoader: TTreeViewSectionsLoader;
    FDraggedSectionID: Integer;
    procedure UpdateSectionParent(SectionID: Integer; NewParentID: Variant);
  public
    { Public declarations }
  end;

var
  fMain: TfMain;
  AppPath: string;
  SQLiteDll: string;

const
  SSQLiteDllFileName = 'sqlite3.dll';

function ExtractSQLiteDll: Boolean;

implementation


{$R *.dfm}

uses
  uCommon, msaClassHelpers;

function ExtractSQLiteDll: Boolean;

  function ExtractRes(AResName, AResType, AFileName: string): Boolean;
  var
    Res: TResourceStream;
  begin
    Res := TResourceStream.Create(hInstance, UpperCase(AResName), Pchar(UpperCase(AResType)));
    try
      Res.SavetoFile(AFileName);
    finally
      Res.Free;
    end;
    Result := True;
  end;

begin
  if not FileExists(SQLiteDll) then
    ExtractRes('SQLiteDLL', 'DLL', SQLiteDll);
  Result := True;
end;

procedure TfMain.btnVACUUMClick(Sender: TObject);
begin
  FMyOptions.Vacuum;
end;

procedure TfMain.btnValueExistsClick(Sender: TObject);
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  lbLog.Items.Add(format('ValueExists: %s', [BoolToStr(FMyOptions.ValueExists(SectionId, ledKey.Text), True)]));
end;

procedure TfMain.btnDeleteAllClick(Sender: TObject);
begin
  FMyOptions.DeleteAll;
  lbLog.Items.Add('DeleteAll');
  FSectionsLoader.LoadSections;
end;

procedure TfMain.btnSectionExistsClick(Sender: TObject);
var
  S: string;
  Parent: Integer;
begin
  Parent := FSectionsLoader.GetSelectedSectionID;
  S := format('SectionExists: id = %d', [FMyOptions.SectionExists(Parent, ledSection.Text)]);
  lbLog.Items.Add(S);
  Panel2.Caption := S + ' ' + ledSection.Text;
end;

procedure TfMain.btnCountOfWordsClick(Sender: TObject);
begin
  Label5.Caption := CountOfWords(edDBName.Text, ' ', CheckBox2.Checked).ToString;
end;

procedure TfMain.btnGetWordNumClick(Sender: TObject);
begin
  Label5.Caption := GetWordNum(edDBName.Text, ' ', StrToInt(Edit9.Text), CheckBox2.Checked);
end;

procedure TfMain.btnCreateSectionClick(Sender: TObject);
var
  Parent: Integer;
begin
  Parent := FSectionsLoader.GetSelectedSectionID;
  lbLog.Items.Add(format('CreateSection: id = %d', [FMyOptions.CreateSection(Parent, ledSection.Text, 'Описание(пример)')]));
  FSectionsLoader.LoadSections;
  TreeView1.AutoExpand := True;
end;

procedure TfMain.btnDeleteSectionClick(Sender: TObject);
var
  SectionId: integer;
begin
  SectionId := FSectionsLoader.GetSelectedSectionID;
  lbLog.Items.Add(format('DeleteSection: cnt = %d', [FMyOptions.DeleteSection(SectionId)]));
  FSectionsLoader.LoadSections;
  TreeView1.AutoExpand := True;
end;

procedure TfMain.btnKeysCountClick(Sender: TObject);
var
  Section_id: integer;
begin
  Section_id := FSectionsLoader.GetSelectedSectionID;
  lbLog.Items.Add(format('KeysCount: cnt = %d', [FMyOptions.KeysCount(Section_id)]));
end;

procedure TfMain.btnMakeRootClick(Sender: TObject);
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  FMyOptions.ChangeSectionParent(SectionId, null);
  FSectionsLoader.LoadSections;
  TreeView1.AutoExpand := True;
end;

procedure TfMain.btnEraseSectionKeysClick(Sender: TObject);
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  lbLog.Items.Add(format('EraseSection: cnt = %d', [FMyOptions.EraseSectionKeys(SectionId)]));
end;

procedure TfMain.btnForceSectionsClick(Sender: TObject);
begin
  FMyOptions.ForceSections(Trim(Edit10.Text));
  FSectionsLoader.LoadSections;
  TreeView1.AutoExpand := True;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  ExtractSQLiteDll;
  FMyOptions := TmsaSQLiteUserDatabase.Create('C:\Temp\options.db');
  edDBName.Text := FMyOptions.DatabaseFileName;

  FSectionsLoader := TTreeViewSectionsLoader.Create(TreeView1, FDConnection);
  FSectionsLoader.LoadSections;
  TreeView1.HideSelection := False;
  TreeView1.DragMode := dmAutomatic;
  FDraggedSectionID := -1;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FMyOptions);
  FreeAndNil(FSectionsLoader);
end;

procedure TfMain.btnReadKeyClick(Sender: TObject);
begin
  var K: TKeys;
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  K := FMyOptions.ReadKey(SectionId, ledKey.Text);
  Edit2.Text := K.key_name;
  Edit3.Text := K.key_value;
  Edit4.Text := K.description;
  Edit5.Text := DateTimeToStr(K.modif_at);
  CheckBox1.Checked := K.key_blob_compressed;
end;

procedure TfMain.btnReadSectionClick(Sender: TObject);
begin
  var K: TSections;
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  K := FMyOptions.ReadSection(SectionId);

  Edit2.Text := K.id.ToString;
  Edit7.Text := K.section_name;
  Edit3.Text := VariantToStrEx(K.parent_id);
  Edit4.Text := K.description;
  Edit5.Text := DateTimeToStr(K.modif_at);
  Edit6.Text := K.keys_count.ToString;
  CheckBox1.Checked := K.hidden;
end;

procedure TfMain.btnReadKeysClick(Sender: TObject);
  {

  type
  TKeys = record
    key_name: string;
    sections_id: Integer;
    description: string;
    key_value: string;
    key_blob: string;
    key_blob_compressed: Boolean;
    created_at: TDateTime;
    modif_at: TDateTime;
    orderby: Real;

    section_name: string;
    section_path: string;
    section_hidden: Boolean;
    section_level: Integer;
    section_orderby: Real;
  end;

  }
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  var KeysList: TList<TKeys> := TList<TKeys>.Create;
//  KeysList.
  try
    FMyOptions.ReadKeys(SectionId, KeysList);
    lbLog.Items.Add(if SectionId > 0 then format('ReadKeys (sections_id = %d):', [SectionId])else 'ReadKeys(all):');
    for var i := 0 to KeysList.Count - 1 do
    begin
      var Key := KeysList[i];

      lbLog.Items.Add(Format('%d) %s | %d | %s | %s | %s | %s | %s | %s | %s', [i + 1, Key.key_name, Key.sections_id,
        Key.description, Key.key_value, Key.key_blob, BoolToStr(Key.key_blob_compressed, True), DateTimeToStr(Key.created_at),
        DateTimeToStr(Key.modif_at), FloatToStr(Key.orderby)]));
      lbLog.Items.Add(Format('%s | %s | %s | %d | %s', [Key.section_name, Key.section_path, BoolToStr(Key.section_hidden,
        True), Key.section_level, FloatToStr(Key.section_orderby)]));
    end;

  finally
    KeysList.Free;
  end;
end;

procedure TfMain.btnReadSectionsClick(Sender: TObject);
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  var SectionsList: TList<TSections> := TList<TSections>.Create;
  try
    FMyOptions.ReadSections(SectionId, SectionsList);
    lbLog.Clear;
    lbLog.Items.Add('ReadSections:');
    for var i := 0 to SectionsList.Count - 1 do
    begin
      var Section := SectionsList[i];
      lbLog.Items.Add(Format('%d) %d | %s | %s | %s | %s | %s | %s | %s | %s |Lvl: %d |Keys: %d', [i + 1, Section.id,
        VariantToStrEx(Section.parent_id), Section.section_name, Section.description, BoolToStr(Section.hidden, True),
        DateTimeToStr(Section.created_at), DateTimeToStr(Section.modif_at), FloatToStr(Section.orderby), Section.path,
        Section.level, Section.keys_count]));
    end;

  finally
    SectionsList.Free;
  end;
end;

procedure TfMain.btnWriteStreamClick(Sender: TObject);
var
  MemStream: TMemoryStream;
  Sz, SzComp: Int64;
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;

  MemStream := TMemoryStream.Create;
  try
    try
      MemStream.LoadFromFile('C:\Temp\P9180009.jpg');
      Sz := MemStream.Size;
      FMyOptions.WriteStream(SectionId, ledKey.Text, MemStream, SzComp, cbCompress.Checked);
    except
      on E: Exception do
      begin
        raise;
      end;
    end;
  finally
    MemStream.Free;
  end;

  lbLog.Items.Add('WriteStream:');
  lbLog.Items.Add(Format('%s(%d) | BLOB %d / %d bytes', [ledSection.Text, SectionId, Sz, SzComp]));
end;

procedure TfMain.btnWriteValueClick(Sender: TObject);
var
  KeyValue: string;
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  KeyValue := ledKeyValue.Text;
  if Length(KeyValue) > 30 then
    KeyValue := KeyValue.Substring(1, 30) + '...';
  FMyOptions.WriteValue(SectionId, ledKey.Text, ledKeyValue.Text);
  lbLog.Items.Add('WriteValue:');
  lbLog.Items.Add(Format('SectionId: %d | %s | %s', [SectionId, ledKey.Text, KeyValue]));
end;

procedure TfMain.btnReadStreamClick(Sender: TObject);
var
  MS: TMemoryStream;
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  MS := TMemoryStream.Create;
  try
    FMyOptions.ReadStream(SectionId, ledKey.Text, MS);
    MS.SaveToFile('C:\Temp\saved.jpg');
    MS.SaveToFile('C:\Temp\saved.bmp');
  finally
    MS.Free;
  end;
end;

procedure TfMain.btnWriteDescriptionClick(Sender: TObject);
var
  Description: string;
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  Description := ledDescription.Text;
  if Length(Description) > 30 then
    Description := Description.Substring(1, 30) + '...';
  FMyOptions.WriteDescription(SectionId, ledKey.Text, ledDescription.Text);
  lbLog.Items.Add('WriteDescription:');
  lbLog.Items.Add(Format('%s(%d) | %s | %s', [ledSection.Text, SectionId, ledKey.Text, Description]));
end;

procedure TfMain.Button1Click(Sender: TObject);
begin
  ledKeyValue.Text := DateTimeToStr(Now);
end;

procedure TfMain.Button2Click(Sender: TObject);
var
  TestString, OutStr: string;
  StrStream: TStringStream;
  Sz, SzComp: Int64;
begin
  TestString := 'Hello World! Это тестовая строка для проверки сжатия. ' + StringOfChar('!', 1000);
  TestString := DupeString(TestString, 100);

  var SectionId := FSectionsLoader.GetSelectedSectionID;
  StrStream := TStringStream(StrToStream(TestString));
  try
    try
      Sz := StrStream.Size;
      StrStream.SaveToFile('C:\Temp\StrStream.dat');
      FMyOptions.WriteStream(SectionId, ledKey.Text, StrStream, SzComp, cbCompress.Checked);
      StrStream.Position := 0;
      StrStream.Clear;
      FMyOptions.ReadStream(SectionId, ledKey.Text, StrStream);
      OutStr := StreamToStr(StrStream);
      if CompareStr(OutStr, TestString) = 0 then
        ShowMessage('Строки одинаковы!');
    except
      on E: Exception do
      begin
        raise;
      end;
    end;
  finally
    StrStream.Free;
  end;

  lbLog.Items.Add('WriteStream:');
  lbLog.Items.Add(Format('%s(%d) | BLOB %d / %d bytes', [ledSection.Text, SectionId, Sz, SzComp]));
end;

procedure TfMain.Button3Click(Sender: TObject);
begin
  lbLog.Clear;
end;

procedure TfMain.Button4Click(Sender: TObject);
var
  KeyCreatedModified: TCreatedModified;
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  KeyCreatedModified := FMyOptions.GetKeyCreatedModified(SectionId, ledKey.Text);
  Label3.Caption := KeyCreatedModified.Created_at;
  Label4.Caption := KeyCreatedModified.Modif_at;
end;

procedure TfMain.Button5Click(Sender: TObject);
var
  SectionCreatedModified: TCreatedModified;
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  SectionCreatedModified := FMyOptions.GetSectionCreatedModified(SectionId);
  Label1.Caption := SectionCreatedModified.Created_at;
  Label2.Caption := SectionCreatedModified.Modif_at;
end;

procedure TfMain.btnGetSectionFullPathClick(Sender: TObject);
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  Edit1.Text := FMyOptions.GetSectionFullPath(SectionId);
end;

procedure TfMain.btnRefreshClick(Sender: TObject);
begin
  FSectionsLoader.LoadSections;
  TreeView1.AutoExpand := True;
end;

procedure TfMain.btnRenameSectionClick(Sender: TObject);
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  FMyOptions.RenameSection(SectionId, ledSection.Text);
  lbLog.Items.Add('RenameSection:');
  lbLog.Items.Add(Format('%d | %s', [SectionId, ledSection.Text]));
  FSectionsLoader.LoadSections;
  TreeView1.AutoExpand := True;
end;

procedure TfMain.btnWriteSectionDescriptionClick(Sender: TObject);
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  FMyOptions.WriteSectionDescription(SectionId, Edit8.Text);
  lbLog.Items.Add('WriteSectionDescription:');
  lbLog.Items.Add(Format('%d | %s', [SectionId, Edit8.Text]));
end;

procedure TfMain.btnReadValueClick(Sender: TObject);
var
  V: string;
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  V := FMyOptions.ReadValue(SectionId, ledKey.Text);
  lbLog.Items.Add('ReadValue:');
  lbLog.Items.Add(Format('%s(%d) | %s | %s', [ledSection.Text, SectionId, ledKey.Text, V]));
end;

procedure TfMain.ReadIntegerClick(Sender: TObject);
var
  V: Int64;
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  V := FMyOptions.ReadInteger(SectionId, ledKey.Text);
  lbLog.Items.Add('ReadInteger:');
  lbLog.Items.Add(Format('%s(%d) | %s | %d', [ledSection.Text, SectionId, ledKey.Text, V]));
end;

procedure TfMain.TreeView1DragDrop(Sender, Source: TObject; X, Y: Integer);
var
  TargetNode: TTreeNode;
  TargetSectionID: Integer;
begin
  TargetNode := TreeView1.GetNodeAt(X, Y);
  if (TargetNode <> nil) and (FDraggedSectionID > 0) then
  begin
    TargetSectionID := Integer(TargetNode.Data);

    // Обновляем parent_id в базе данных
    UpdateSectionParent(FDraggedSectionID, TargetSectionID);

    FSectionsLoader.LoadSections;
  end;
end;

procedure TfMain.TreeView1DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  Node: TTreeNode;
begin
  // Разрешаем перетаскивание только внутри TreeView
  Accept := (Source = TreeView1);

  // Визуальная обратная связь
  if Accept then
  begin
    Node := TreeView1.GetNodeAt(X, Y);
    TreeView1.DropTarget := Node; // Подсвечиваем узел
  end;
end;

procedure TfMain.UpdateSectionParent(SectionID: Integer; NewParentID: Variant);
begin
  FMyOptions.ChangeSectionParent(SectionID, NewParentID);
end;

procedure TfMain.TreeView1StartDrag(Sender: TObject; var DragObject: TDragObject);
begin
  if TreeView1.Selected <> nil then
    FDraggedSectionID := Integer(TreeView1.Selected.Data);
end;

procedure TfMain.btnReadFloatClick(Sender: TObject);
var
  V: Extended;
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  V := FMyOptions.ReadFloat(SectionId, ledKey.Text);
  lbLog.Items.Add('ReadFloat:');
  lbLog.Items.Add(Format('%s(%d) | %s | %s', [ledSection.Text, SectionId, ledKey.Text, FloatToStr(V)]));
end;

procedure TfMain.btnReadDateTimeClick(Sender: TObject);
var
  V: TDateTime;
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  V := FMyOptions.ReadDateTime(SectionId, ledKey.Text);
  lbLog.Items.Add('ReadDateTime:');
  lbLog.Items.Add(Format('%s(%d) | %s | %s', [ledSection.Text, SectionId, ledKey.Text, DateTimeToStr(V)]));
end;

procedure TfMain.btnReadDateClick(Sender: TObject);
var
  V: TDate;
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  V := FMyOptions.ReadDate(SectionId, ledKey.Text);
  lbLog.Items.Add('ReadDate:');
  lbLog.Items.Add(Format('%s(%d) | %s | %s', [ledSection.Text, SectionId, ledKey.Text, DateToStr(V)]));
end;

procedure TfMain.btnReadTimeClick(Sender: TObject);
var
  V: TTime;
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  V := FMyOptions.ReadTime(SectionId, ledKey.Text);
  lbLog.Items.Add('ReadTime:');
  lbLog.Items.Add(Format('%s(%d) | %s | %s', [ledSection.Text, SectionId, ledKey.Text, TimeToStr(V)]));
end;

procedure TfMain.btnReadBoolClick(Sender: TObject);
var
  V: Boolean;
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  V := FMyOptions.ReadBool(SectionId, ledKey.Text);
  lbLog.Items.Add('ReadBool:');
  lbLog.Items.Add(Format('%s(%d) | %s | %s', [ledSection.Text, SectionId, ledKey.Text, BoolToStr(V, True)]));
end;

procedure TfMain.btnDeleteKeyClick(Sender: TObject);
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  lbLog.Items.Add(format('DeleteKey: cnt = %d', [FMyOptions.DeleteKey(SectionId, ledKey.Text)]));
end;

procedure TfMain.btnChangeKeySortOrderClick(Sender: TObject);
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  FMyOptions.ChangeKeySortOrder(SectionId, ledKey.Text, StrToFloatDef(Edit11.Text, 0));
end;

procedure TfMain.btnChangeSectionSortOrderClick(Sender: TObject);
begin
  var SectionId := FSectionsLoader.GetSelectedSectionID;
  FMyOptions.ChangeSectionSortOrder(SectionId, StrToFloatDef(Edit11.Text, 0));
end;

initialization
  AppPath := TPath.GetAppPath;
  SQLiteDll := AppPath + SSQLiteDllFileName;

  ReportMemoryLeaksOnShutdown := True;

end.

