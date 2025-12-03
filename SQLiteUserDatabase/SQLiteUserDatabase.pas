{*******************************************************}
{                                                       }
{           Mamykin Sergey                              }
{                                                       }
{       Copyright(c) 1973-2173 Mamykin Sergey           }
{           All rights reserved                         }
{                                                       }
{*******************************************************}
unit SQLiteUserDatabase;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, Winapi.ShlObj, FireDAC.Comp.Client, FireDAC.Phys.SQLite,
  FireDAC.Stan.Def, FireDAC.DApt, System.IOUtils, Data.DB, System.Generics.Collections, DataSetEnumerator,
  System.Variants;

type
  TKeys = record
    key_name: string;
    sections_id: Integer;
    description: string;
    key_value: Variant;
    created_at: TDateTime;
    modif_at: TDateTime;
  end;

type
  TSections = record
    id: integer;
    parent_id: Variant;
    section_name: string;
    description: string;
    hidden: Boolean;
    created_at: TDateTime;
    modif_at: TDateTime;
  end;

type
  TmsaSQLiteUserDatabase = class
  private
    FConnection: TFDConnection;
    FQuery: TFDQuery;
    FDatabaseFileName: string;
    procedure CreateMetadata;
    procedure SetQueryCommon(const SectionID: Integer; const KeyName: string; Description: string);
    function GetSpecialPath(CSIDL: word): string;
    function MakeDBFileName(const ADatabaseFileName: string): string;
  public
    constructor Create(const ADatabaseFileName: string);
    destructor Destroy; override;
    property DatabaseFileName: string read FDatabaseFileName;
    function SectionExists(const SectionName: string): Integer;
    function CreateSection(const SectionName, Description: string): Integer;
    {The last_insert_rowid() function returns the ROWID of the last row insert from the database
     connection which invoked the function. The last_insert_rowid() SQL function is a wrapper
     around the sqlite3_last_insert_rowid() C/C++ interface function.}
    function Last_Insert_Rowid(): Integer;
    function SectionId(const SectionName: string): Integer;
    function KeysCount(const SectionID: Integer): Integer;
   {function DeleteSection deletes section and all subsections and keys}
    function DeleteSection(const SectionID: Integer): Integer;
    {The changes() function returns the number of database rows that were changed or inserted or deleted
     by the most recently completed INSERT, DELETE, or UPDATE statement,
     exclusive of statements in lower-level triggers. The changes() SQL function is a wrapper
     around the sqlite3_changes64() C/C++ function and hence follows
     the same rules for counting changes.}
    function Changes(): Integer;
    procedure DeleteAll;
    {function EraseSection erases keys entire section}
    function EraseSectionKeys(const SectionID: Integer): Integer;
    {procedure ReadKeys reads keys by section (if SectionID > 0) or all keys into a TList<TKeys>}
    procedure ReadKeys(const SectionID: Integer; KeysList: TList<TKeys>);    
    {procedure ReadSections Reads all sections into a TList<TSections>}
    procedure ReadSections(SectionsList: TList<TSections>);
    {function ValueExists Indicates whether a key exists}
    function ValueExists(const SectionID: Integer; const KeyName: string): Boolean;
    procedure VACUUM;
    procedure WriteValue(const SectionID: Integer; const KeyName: string; Value: Variant; Description: string);
    procedure WriteStream(const SectionID: Integer; const KeyName: string; Description: string; AStream: TStream;
      ACompress: Boolean = False);

  end;

const
  SectionsTableSQL = '''
    CREATE TABLE IF NOT EXISTS sections (
    id           INTEGER  PRIMARY KEY
                          UNIQUE
                          NOT NULL,
    parent_id    INTEGER  REFERENCES sections (id) ON DELETE CASCADE
                                                   ON UPDATE NO ACTION,
    section_name TEXT     NOT NULL
                          UNIQUE ON CONFLICT FAIL,
    description  TEXT,
    hidden       INTEGER  NOT NULL
                          DEFAULT (0)
                          CHECK (hidden IN (0, 1) ),
    created_at   DATETIME NOT NULL
                          DEFAULT (datetime('now', 'localtime') ),
    modif_at     DATETIME NOT NULL
                          DEFAULT (datetime('now', 'localtime') )
   );

   ''';
  KeysTableSQL = '''
    CREATE TABLE IF NOT EXISTS keys (
    key_name    TEXT     NOT NULL,
    sections_id INTEGER  REFERENCES sections (id) ON DELETE CASCADE
                                                  ON UPDATE NO ACTION
                         NOT NULL,
    description TEXT,
    key_value   ANY,
    key_blob    BLOB,
    created_at  DATETIME NOT NULL
                         DEFAULT (datetime('now', 'localtime') ),
    modif_at    DATETIME NOT NULL
                         DEFAULT (datetime('now', 'localtime') ),
    CONSTRAINT keys_primary_key PRIMARY KEY (
        key_name COLLATE NOCASE,
        sections_id
    )
    ON CONFLICT FAIL
      );
    ''';
  SectionsTriggerSQL = '''
    CREATE TRIGGER IF NOT EXISTS sections_update_modif_at
         BEFORE UPDATE OF section_name,
                          description
             ON sections
       FOR EACH ROW
    BEGIN
     UPDATE sections
       SET modif_at = datetime('now', 'localtime')
     WHERE id = NEW.id;
    END;
   ''';
  KeysTriggerSQL = '''
    CREATE TRIGGER IF NOT EXISTS keys_update_modif_at
        BEFORE UPDATE OF key_name,
                         sections_id,
                         description,
                         key_value
            ON keys
      FOR EACH ROW
    BEGIN
     UPDATE keys
        SET modif_at = datetime('now', 'localtime')
      WHERE key_name = NEW.key_name;
    END;
   ''';
  KeysIndex1SQL = '''
   CREATE INDEX IF NOT EXISTS keys_fk_idx ON keys (
    sections_id
    );
   ''';
  SectionsIndex1SQL = '''
   CREATE INDEX IF NOT EXISTS sections_fk_idx ON sections (
    parent_id
    );
   ''';
  SectionsIndex2SQL = '''
   CREATE INDEX IF NOT EXISTS sections_name_idx ON sections (
    section_name ASC
    );
   ''';
  WriteKeyValueSQL = '''
      insert into keys(key_name, sections_id, description, key_value)
      values (:key_name, :sections_id, :description, :key_value)
      ON CONFLICT(key_name, sections_id) DO UPDATE SET description = excluded.description, key_value = excluded.key_value
      WHERE ((excluded.description <> keys.description) or keys.description IS NULL) or ((excluded.key_value<>keys.key_value) or keys.key_value IS NULL);
      ''';

implementation

  { TSettingsManager }

function TmsaSQLiteUserDatabase.GetSpecialPath(CSIDL: word): string;
var
  S: string;
begin
  SetLength(S, MAX_PATH);
  if not SHGetSpecialFolderPath(0, PChar(S), CSIDL, True) then
    S := GetSpecialPath(CSIDL_APPDATA);
  Result := PChar(S);
end;

  
function TmsaSQLiteUserDatabase.MakeDBFileName(const ADatabaseFileName: string): string;
var
  FileDir, FileName, LOCAL_APPDATA: string;
begin
  Result := Trim(ADatabaseFileName);
  Result := ADatabaseFileName;
  LOCAL_APPDATA := GetSpecialPath(CSIDL_APPDATA);
//  LOCAL_APPDATA := TPath.GetCachePath;
//  LOCAL_APPDATA := GetSpecialPath(CSIDL_LOCAL_APPDATA);

  FileDir := ExtractFileDir(Result);
  FileName := ExtractFileName(Result);

  if (FileDir <> '') then
  begin
    if not DirectoryExists(FileDir) then
      if not ForceDirectories(FileDir) then
        FileDir := LOCAL_APPDATA;
  end
  else
    FileDir := LOCAL_APPDATA;

  if (FileName = '') then
    FileName := 'MyOptions.dat';

  Result := IncludeTrailingPathDelimiter(FileDir) + FileName;
end;

function TmsaSQLiteUserDatabase.SectionExists(const SectionName: string): Integer;
begin
  FQuery.SQL.Text := 'SELECT id FROM sections WHERE upper(section_name) = :section_name';
  FQuery.ParamByName('section_name').AsString := UpperCase(SectionName);
  FQuery.Open;
  Result := if FQuery.FieldByName('id').IsNull then -1 else FQuery.FieldByName('id').AsInteger;
  FQuery.Close;
end;

function TmsaSQLiteUserDatabase.SectionId(const SectionName: string): Integer;
begin
  Result := SectionExists(SectionName);
end;

constructor TmsaSQLiteUserDatabase.Create(const ADatabaseFileName: string);
begin
  FDatabaseFileName := MakeDBFileName(ADatabaseFileName);

  FConnection := TFDConnection.Create(nil);
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection;
  FConnection.DriverName := 'SQLite';
  FConnection.Params.Values['Database'] := FDatabaseFileName;
  FConnection.Params.Values['OpenMode'] := 'CreateUTF8';
  FConnection.Params.Values['LockingMode'] := 'Normal';
  FConnection.LoginPrompt := False;
  FConnection.FormatOptions.MaxStringSize := 1_048_576;
  try
    FConnection.Connected := True;
  except
    on E: Exception do
    begin
      FreeAndNil(FQuery);
      FreeAndNil(FConnection);
      E.Message := E.Message + sLineBreak + Format('File name: "%s"', [FDatabaseFileName]);
      raise;
    end;
  end;

  CreateMetadata;
end;

function TmsaSQLiteUserDatabase.CreateSection(const SectionName, Description: string): Integer;
begin
  Result := SectionExists(SectionName);
  if Result > -1 then
    Exit;

  FQuery.SQL.Text := 'INSERT INTO sections(section_name, description) VALUES(:section_name, :description)';
  FQuery.ParamByName('section_name').AsString := SectionName;
  FQuery.ParamByName('description').AsString := Description;
  FQuery.ExecSQL;
  Result := Last_Insert_Rowid();
  FQuery.Close;
end;

function TmsaSQLiteUserDatabase.DeleteSection(const SectionID: Integer): Integer;
begin
  Result := 0;
//  if DeleteKeysToo then
//    FQuery.SQL.Text := 'DELETE FROM keys WHERE sections_id = :sections_id'
 // else
//    FQuery.SQL.Text := 'UPDATE keys SET sections_id = NULL WHERE sections_id = :sections_id';
 // FQuery.ParamByName('sections_id').AsInteger := SectionID;
 // FQuery.ExecSQL;
 // FQuery.Close;
  FQuery.SQL.Text := 'DELETE FROM sections WHERE id = :sections_id';
  FQuery.ParamByName('sections_id').AsInteger := SectionID;
  FQuery.ExecSQL;
  FQuery.Close;

  Result := Changes();
end;

destructor TmsaSQLiteUserDatabase.Destroy;
begin
  VACUUM;
  if Assigned(FQuery) then
    FQuery.Free;
  if Assigned(FConnection) then
    FConnection.Free;
  inherited;
end;

function TmsaSQLiteUserDatabase.Last_Insert_Rowid(): Integer;
begin
  FQuery.SQL.Text := 'SELECT last_insert_rowid() AS id';
  FQuery.Open;
  Result := FQuery.FieldByName('id').AsInteger;
  FQuery.Close;
end;

function TmsaSQLiteUserDatabase.Changes(): Integer;
begin
  FQuery.SQL.Text := 'SELECT changes() as changes';
  FQuery.Open;
  Result := FQuery.FieldByName('changes').AsInteger;
  FQuery.Close;
end;

function TmsaSQLiteUserDatabase.KeysCount(const SectionID: Integer): Integer;
begin
  FQuery.SQL.Text := 'SELECT COUNT(*) cnt FROM keys WHERE sections_id = :sections_id';
  FQuery.ParamByName('sections_id').AsInteger := SectionID;
  FQuery.Open;
  Result := FQuery.FieldByName('cnt').AsInteger;
  FQuery.Close;
end;

procedure TmsaSQLiteUserDatabase.CreateMetadata;
var
  SQL: string;
begin
  try
    SQL := SectionsTableSQL;
    FQuery.SQL.Text := SQL;
    FQuery.ExecSQL;
    FQuery.Close;

    SQL := KeysTableSQL;
    FQuery.SQL.Text := SQL;
    FQuery.ExecSQL;
    FQuery.Close;

    SQL := SectionsTriggerSQL;
    FQuery.SQL.Text := SQL;
    FQuery.ExecSQL;
    FQuery.Close;

    SQL := KeysTriggerSQL;
    FQuery.SQL.Text := SQL;
    FQuery.ExecSQL;
    FQuery.Close;

    SQL := KeysIndex1SQL;
    FQuery.SQL.Text := SQL;
    FQuery.ExecSQL;
    FQuery.Close;

    SQL := SectionsIndex1SQL;
    FQuery.SQL.Text := SQL;
    FQuery.ExecSQL;
    FQuery.Close;

    SQL := SectionsIndex2SQL;
    FQuery.SQL.Text := SQL;
    FQuery.ExecSQL;
    FQuery.Close;

  except
    on E: Exception do
    begin
      FreeAndNil(FQuery);
      FreeAndNil(FConnection);
      E.Message := E.Message + sLineBreak + Format('SQL TEXT: <<< %s >>>', [SQL]);
      raise;
    end;
  end;
end;

procedure TmsaSQLiteUserDatabase.DeleteAll;
begin
  FQuery.SQL.Text := 'DELETE FROM keys;';
  FQuery.ExecSQL;
  FQuery.SQL.Text := 'DELETE FROM sections;';
  FQuery.ExecSQL;
  FQuery.Close;
end;

function TmsaSQLiteUserDatabase.EraseSectionKeys(const SectionID: Integer): Integer;
begin
  Result := 0;
  FQuery.SQL.Text := 'DELETE FROM keys WHERE sections_id = :sections_id';
  FQuery.ParamByName('sections_id').AsInteger := SectionID;
  FQuery.ExecSQL;
  FQuery.Close;
  Result := Changes();
end;

procedure TmsaSQLiteUserDatabase.ReadKeys(const SectionID: Integer; KeysList: TList<TKeys>);
begin
  if KeysList = nil then
    Exit;
  if SectionID > 0 then
  begin
    FQuery.SQL.Text :=
      'SELECT key_name, sections_id, description, key_value, created_at, modif_at FROM keys WHERE sections_id = :sections_id';
    FQuery.ParamByName('sections_id').AsInteger := SectionID;
  end
  else
    FQuery.SQL.Text := 'SELECT key_name, sections_id, description, key_value, created_at, modif_at FROM keys';

  FQuery.Open;

  var Enumerator := FQuery.Map<TKeys>(
    function(DataSet: TDataSet): TKeys
    var
      Fld: TField;
      FT: TFieldType;
      Str: WideString;
      
    begin
      Result.key_name := DataSet.FieldByName('key_name').AsString;
      Result.sections_id := DataSet.FieldByName('sections_id').AsInteger;
      Result.description := DataSet.FieldByName('description').AsString;
      Fld := DataSet.FieldByName('key_value');
      FT := Fld.DataType;
      Str := Fld.Value;
      if Length(Str) > 100 then
        Str := '...';
      if FT = ftBlob then
        Result.key_value := '<BLOB>'
      else
        Result.key_value := Str;

      Result.created_at := DataSet.FieldByName('created_at').AsDateTime;
      Result.modif_at := DataSet.FieldByName('modif_at').AsDateTime;
    end);
  try
    while Enumerator.MoveNext do
    begin
      var Key := Enumerator.Current;
      KeysList.Add(Key);
    end;
  finally
    Enumerator.Free;
  end;
end;

procedure TmsaSQLiteUserDatabase.ReadSections(SectionsList: TList<TSections>);
var
  FldHidden: Integer;
begin
  if SectionsList = nil then
    Exit;

  FQuery.SQL.Text := 'SELECT id, parent_id, section_name, description, hidden, created_at, modif_at FROM sections';
  FQuery.Open;

  var Enumerator := FQuery.Map<TSections>(
    function(DataSet: TDataSet): TSections
    begin
      Result.id := DataSet.FieldByName('id').AsInteger;
      Result.parent_id := DataSet.FieldByName('parent_id').Value;
      Result.section_name := DataSet.FieldByName('section_name').AsString;
      Result.description := DataSet.FieldByName('description').AsString;
      FldHidden := DataSet.FieldByName('hidden').AsInteger;
      Result.hidden := (FldHidden = 1);
      Result.created_at := DataSet.FieldByName('created_at').AsDateTime;
      Result.modif_at := DataSet.FieldByName('modif_at').AsDateTime;
    end);
  try
    while Enumerator.MoveNext do
    begin
      var Section := Enumerator.Current;
      SectionsList.Add(Section);
    end;
  finally
    Enumerator.Free;
  end;
end;

procedure TmsaSQLiteUserDatabase.VACUUM;
begin
  FQuery.SQL.Text := 'VACUUM;';
  try
    FQuery.ExecSQL;
  except
  end;
  FQuery.Close;
end;

function TmsaSQLiteUserDatabase.ValueExists(const SectionID: Integer; const KeyName: string): Boolean;
begin
  FQuery.SQL.Text := 'SELECT key_name FROM keys WHERE (trim(upper(key_name)) = trim(:key_name)) and sections_id = :sections_id';
  FQuery.ParamByName('key_name').AsString := UpperCase(KeyName);
  FQuery.ParamByName('sections_id').AsInteger := SectionID;
  FQuery.Open;
  Result := FQuery.RecordCount > 0;
  FQuery.Close;
end;

procedure TmsaSQLiteUserDatabase.SetQueryCommon(const SectionID: Integer; const KeyName: string; Description: string);
begin
  FQuery.SQL.Text := WriteKeyValueSQL;
  FQuery.ParamByName('sections_id').AsInteger := SectionID;
  FQuery.ParamByName('key_name').AsString := KeyName;
  FQuery.ParamByName('description').AsString := Description;
end;

procedure TmsaSQLiteUserDatabase.WriteStream(const SectionID: Integer; const KeyName: string; Description: string;
  AStream: TStream; ACompress: Boolean = False);
begin
  if SectionID < 1 then
    Exit;
  SetQueryCommon(SectionID, KeyName, Description);
  FQuery.ParamByName('key_value').LoadFromStream(AStream, ftBlob);
  FQuery.ExecSQL;
  FQuery.Close;
end;

procedure TmsaSQLiteUserDatabase.WriteValue(const SectionID: Integer; const KeyName: string; Value: Variant; Description: string);
begin
  if SectionID < 1 then
    Exit;
  SetQueryCommon(SectionID, KeyName, Description);
  FQuery.ParamByName('key_value').Value := Value;
  FQuery.ExecSQL;
  FQuery.Close;
end;

end.

