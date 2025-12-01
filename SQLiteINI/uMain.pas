unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Winapi.ShlObj, Vcl.StdCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, System.IOUtils, Vcl.Mask, Vcl.ExtCtrls, SQLiteINI;

type
  TfMain = class(TForm)
    edDBName: TEdit;
    FDConnection1: TFDConnection;
    btnSectionExists: TButton;
    btnCreateSection: TButton;
    btnKeysCount: TButton;
    cbDeleteKeysToo: TCheckBox;
    ledSection: TLabeledEdit;
    lbLog: TListBox;
    btnDeleteAll: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSectionExistsClick(Sender: TObject);
    procedure btnCreateSectionClick(Sender: TObject);
    procedure btnKeysCountClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnDeleteSectionsClick(Sender: TObject);
    procedure btnDeleteAllClick(Sender: TObject);
  private
    { Private declarations }
    FMyOptions: TmsaSQLiteINI;
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
  end;

begin
  if not FileExists(SQLiteDll) then
    ExtractRes('SQLiteDLL', 'DLL', SQLiteDll);
end;

procedure TfMain.btnSectionExistsClick(Sender: TObject);
begin
  lbLog.Items.Add(format('SectionExists: id = %d', [FMyOptions.SectionExists(ledSection.Text)]));
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

procedure TfMain.btnDeleteSectionsClick(Sender: TObject);
var
  SectionId: integer;
begin
  SectionId := FMyOptions.SectionId(ledSection.Text);
  lbLog.Items.Add(format('DeleteSection: cnt = %d', [FMyOptions.DeleteSection(SectionId, cbDeleteKeysToo.Checked)]));
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  ExtractSQLiteDll;
  FMyOptions := TmsaSQLiteINI.Create('C:\Temp\options.db');
  edDBName.Text := FMyOptions.DatabaseFileName;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FMyOptions);
end;

initialization
  AppPath := TPath.GetAppPath;
  SQLiteDll := AppPath + SSQLiteDllFileName;

  ReportMemoryLeaksOnShutdown := True;

end.

