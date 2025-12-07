program SQLiteUserDatabaseTest;
{$R 'MyRes.res' 'MyRes.rc'}
uses
  Vcl.Forms,
  uMain in 'uMain.pas' {fMain},
  SQLiteUserDatabase in 'SQLiteUserDatabase.pas',
  DataSetEnumerator in '..\DataSetEnumerator\DataSetEnumerator.pas',
  uCommon in '..\Common\uCommon.pas',
  uTreeLoader in 'uTreeLoader.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'SQLite User Database test';
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
