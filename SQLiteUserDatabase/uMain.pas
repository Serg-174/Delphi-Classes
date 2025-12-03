unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Winapi.ShlObj, Vcl.StdCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, System.IOUtils, Vcl.Mask, Vcl.ExtCtrls, System.IniFiles,
  System.Generics.Collections, SQLiteUserDatabase;

type
  TfMain = class(TForm)
    edDBName: TEdit;
    FDConnection1: TFDConnection;
    btnSectionExists: TButton;
    btnCreateSection: TButton;
    btnKeysCount: TButton;
    ledSection: TLabeledEdit;
    lbLog: TListBox;
    btnDeleteAll: TButton;
    btnEraseSectionKeys: TButton;
    btnReadKeys: TButton;
    btnReadSections: TButton;
    btnValueExists: TButton;
    ledKey: TLabeledEdit;
    btnVACUUM: TButton;
    ledKeyValue: TLabeledEdit;
    ledDescription: TLabeledEdit;
    btnWriteValue: TButton;
    btnWriteStream: TButton;
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

  private
    { Private declarations }
    FMyOptions: TmsaSQLiteUserDatabase;
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
  uCommon;

function ExtractSQLiteDll: Boolean;

  function ExtractRes(AResName, AResType, AFileName: string): Boolean;
  var
    Res: TResourceStream;
  begin
    Result := False;
    Res := TResourceStream.Create(hInstance, UpperCase(AResName), Pchar(UpperCase(AResType)));
    try
      Res.SavetoFile(AFileName);
    finally
      Res.Free;
    end;
    Result := True;
  end;

begin
  Result := False;
  if not FileExists(SQLiteDll) then
    ExtractRes('SQLiteDLL', 'DLL', SQLiteDll);
  Result := True;
end;

procedure TfMain.btnSectionExistsClick(Sender: TObject);
begin
  lbLog.Items.Add(format('SectionExists: id = %d', [FMyOptions.SectionExists(ledSection.Text)]));
end;

procedure TfMain.btnVACUUMClick(Sender: TObject);
begin
  FMyOptions.VACUUM;
end;

procedure TfMain.btnValueExistsClick(Sender: TObject);
begin
  var SectionId := FMyOptions.SectionId(ledSection.Text);
  lbLog.Items.Add(format('ValueExists: %s', [BoolToStr(FMyOptions.ValueExists(SectionId, ledKey.Text), True)]));
end;

procedure TfMain.btnDeleteAllClick(Sender: TObject);
begin
  FMyOptions.DeleteAll;
  lbLog.Items.Add('DeleteAll');
end;

procedure TfMain.btnCreateSectionClick(Sender: TObject);
begin
  lbLog.Items.Add(format('CreateSection: id = %d', [FMyOptions.CreateSection(ledSection.Text, 'Описание(пример)')]));
end;

procedure TfMain.btnKeysCountClick(Sender: TObject);
var
  Section_id: integer;
begin
  Section_id := FMyOptions.SectionId(ledSection.Text);
  lbLog.Items.Add(format('KeysCount: cnt = %d', [FMyOptions.KeysCount(Section_id)]));
end;

procedure TfMain.btnDeleteSectionClick(Sender: TObject);
var
  SectionId: integer;
begin
  SectionId := FMyOptions.SectionId(ledSection.Text);
  lbLog.Items.Add(format('DeleteSection: cnt = %d', [FMyOptions.DeleteSection(SectionId)]));
end;

procedure TfMain.btnEraseSectionKeysClick(Sender: TObject);
var
  SectionId: integer;
begin
  SectionId := FMyOptions.SectionId(ledSection.Text);
  lbLog.Items.Add(format('EraseSection: cnt = %d', [FMyOptions.EraseSectionKeys(SectionId)]));
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  ExtractSQLiteDll;
  FMyOptions := TmsaSQLiteUserDatabase.Create('C:\Temp\options.db');
  edDBName.Text := FMyOptions.DatabaseFileName;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FMyOptions);
end;

procedure TfMain.btnReadKeysClick(Sender: TObject);
//var
//  F: TInifile;
begin
  var SectionId := FMyOptions.SectionId(ledSection.Text);
  var KeysList: TList<TKeys> := TList<TKeys>.Create;
  try
    FMyOptions.ReadKeys(SectionId, KeysList);
    lbLog.Items.Add(if SectionId > 0 then format('ReadKeys (sections_id = %d):', [SectionId])else 'ReadKeys(all):');
    for var i := 0 to KeysList.Count - 1 do
    begin
      var Key := KeysList[i];

      lbLog.Items.Add(Format('%d) %s | %d | %s | %s | %s | %s', [i + 1, Key.key_name, Key.sections_id, Key.description,
        VariantToStrEx(Key.key_value), DateTimeToStr(Key.created_at), DateTimeToStr(Key.modif_at)]));
    end;

  finally
    KeysList.Free;
  end;
end;

procedure TfMain.btnReadSectionsClick(Sender: TObject);
begin
  var SectiosList: TList<TSections> := TList<TSections>.Create;
  try
    FMyOptions.ReadSections(SectiosList);
    lbLog.Items.Add('ReadSections:');
    for var i := 0 to SectiosList.Count - 1 do
    begin
      var Section := SectiosList[i];
      lbLog.Items.Add(Format('%d) %d | %s | %s | %s | %s | %s | %s', [i + 1, Section.id, VariantToStrEx(Section.parent_id),
        Section.section_name, Section.description, BoolToStr(Section.hidden, True), DateTimeToStr(Section.created_at),
        DateTimeToStr(Section.modif_at)]));
    end;

  finally
    SectiosList.Free;
  end;
end;

procedure TfMain.btnWriteStreamClick(Sender: TObject);
var
  MemStream: TMemoryStream;
  Sz: Integer;
begin
  var SectionId := FMyOptions.SectionId(ledSection.Text);

  MemStream := TMemoryStream.Create;
  try
    try
      MemStream.LoadFromFile('C:\Temp\P9180009.JPG');
      Sz := MemStream.Size;
      FMyOptions.WriteStream(SectionId, ledKey.Text, ledDescription.Text, MemStream);
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
  lbLog.Items.Add(Format('%s(%d) | %s | %s | Размер: %d', [ledSection.Text, SectionId, ledKey.Text, ledDescription.Text, Sz]));
end;

procedure TfMain.btnWriteValueClick(Sender: TObject);
begin
  var SectionId := FMyOptions.SectionId(ledSection.Text);
  FMyOptions.WriteValue(SectionId, ledKey.Text, ledKeyValue.Text, ledDescription.Text);
  lbLog.Items.Add('WriteValue:');
  lbLog.Items.Add(Format('%s(%d) | %s | %s | %s', [ledSection.Text, SectionId, ledKey.Text, ledKeyValue.Text,
    ledDescription.Text]));
end;

initialization
  AppPath := TPath.GetAppPath;
  SQLiteDll := AppPath + SSQLiteDllFileName;

  ReportMemoryLeaksOnShutdown := True;

end.

