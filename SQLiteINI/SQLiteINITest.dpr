program SQLiteINITest;
{$R 'MyRes.res' 'MyRes.rc'}
uses
  Vcl.Forms,
  uMain in 'uMain.pas' {fMain},
  SQLiteINI in 'SQLiteINI.pas',
  DataSetEnumerator in 'DataSetEnumerator.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'TmsaSQLiteINI test';
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
