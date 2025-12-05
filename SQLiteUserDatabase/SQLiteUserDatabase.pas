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
  FireDAC.Stan.Def, FireDAC.DApt, System.IOUtils, FireDAC.Stan.Param, Data.DB, System.Generics.Collections,
  DataSetEnumerator, System.Variants, System.DateUtils;

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
    procedure SetQueryCommonParams(const SectionID: Integer; const KeyName: string);
    function GetSpecialPath(CSIDL: word): string;
    function MakeDBFileName(const ADatabaseFileName: string): string;
  public
    constructor Create(const ADatabaseFileName: string);
    destructor Destroy; override;
    property DatabaseFileName: string read FDatabaseFileName;
    function SectionExists(const SectionName: string): Integer;
    function CreateSection(const SectionName, Description: string): Integer;
    function Last_Insert_Rowid(): Integer;
    function SectionId(const SectionName: string): Integer;
    function KeysCount(const SectionID: Integer): Integer;
    function DeleteSection(const SectionID: Integer): Integer;
    function Changes(): Integer;
    function DeleteAll: Integer;
    function DeleteKey(const SectionID: Integer; const KeyName: string): Integer;
    function EraseSectionKeys(const SectionID: Integer): Integer;
    procedure ReadKeys(const SectionID: Integer; KeysList: TList<TKeys>);
    procedure ReadSections(SectionsList: TList<TSections>);
    function ValueExists(const SectionID: Integer; const KeyName: string): Boolean;
    procedure Vacuum;
    procedure WriteValue(const SectionID: Integer; const KeyName: string; Value: string);
    procedure WriteDescription(const SectionID: Integer; const KeyName: string; Description: string);
    procedure WriteStream(const SectionID: Integer; const KeyName: string; AStream: TStream; var ASize: Int64; ACompress:
      Boolean = False);
    procedure ReadStream(const SectionID: Integer; const KeyName: string; AStream: TStream);
    function ReadValue(const SectionID: Integer; const KeyName: string): string;
    function ReadInteger(const SectionID: Integer; const KeyName: string): Int64;
    function ReadFloat(const SectionID: Integer; const KeyName: string): Extended;
    function ReadDateTime(const SectionID: Integer; const KeyName: string): TDateTime;
    function ReadDate(const SectionID: Integer; const KeyName: string): TDate;
    function ReadTime(const SectionID: Integer; const KeyName: string): TTime;
    function ReadBool(const SectionID: Integer; const KeyName: string): Boolean;
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
    key_name            TEXT     NOT NULL,
    sections_id         INTEGER  REFERENCES sections (id) ON DELETE CASCADE
                                                          ON UPDATE NO ACTION
                                 NOT NULL,
    description         TEXT,
    key_value           ANY,
    key_blob            BLOB,
    key_blob_compressed INTEGER  NOT NULL
                                 DEFAULT (0)
                                 CHECK (key_blob_compressed IN (0, 1)),
    created_at          DATETIME NOT NULL
                                 DEFAULT (datetime('now', 'localtime')),
    modif_at            DATETIME NOT NULL
                                 DEFAULT (datetime('now', 'localtime')),
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
      insert into keys(key_name, sections_id, key_value)
      values (:key_name, :sections_id, :key_value)
      ON CONFLICT(key_name, sections_id) DO UPDATE SET key_value = excluded.key_value
      WHERE (excluded.key_value <> keys.key_value) or keys.key_value IS NULL;
      ''';
  WriteKeyBlobSQL = '''
      insert into keys(key_name, sections_id, key_blob, key_blob_compressed)
      values (:key_name, :sections_id, :key_blob, :key_blob_compressed)
      ON CONFLICT(key_name, sections_id) DO UPDATE SET key_blob = excluded.key_blob, key_blob_compressed = excluded.key_blob_compressed
      ''';
  WriteKeyDescriptionSQL = '''
      insert into keys(key_name, sections_id, description)
      values (:key_name, :sections_id, :description)
      ON CONFLICT(key_name, sections_id) DO UPDATE SET description = excluded.description
      WHERE ((excluded.description <> keys.description) or keys.description IS NULL);
      ''';

implementation

  { TSettingsManager }

uses
  uCommon;

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
  FConnection.DriverName := 'SQLite';
  FConnection.Params.Values['Database'] := FDatabaseFileName;
  FConnection.Params.Values['OpenMode'] := 'CreateUTF8';
  FConnection.Params.Values['LockingMode'] := 'Normal';
  FConnection.LoginPrompt := False;
  FConnection.FormatOptions.MaxStringSize := 1_048_576;
  FQuery.Connection := FConnection;

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
  FQuery.SQL.Text := 'DELETE FROM sections WHERE id = :sections_id';
  FQuery.ParamByName('sections_id').AsInteger := SectionID;
  FQuery.ExecSQL;
  FQuery.Close;
  Result := Changes();
end;

destructor TmsaSQLiteUserDatabase.Destroy;
begin
//  Vacuum;
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

function TmsaSQLiteUserDatabase.DeleteAll;
begin
  FQuery.SQL.Text := 'DELETE FROM keys;';
  FQuery.ExecSQL;
  FQuery.SQL.Text := 'DELETE FROM sections;';
  FQuery.ExecSQL;
  FQuery.Close;
  Result := Changes();
end;

function TmsaSQLiteUserDatabase.DeleteKey(const SectionID: Integer; const KeyName: string): Integer;
begin
  FQuery.SQL.Text := 'DELETE FROM keys WHERE trim(upper(key_name)) = trim(upper(:key_name)) and sections_id = :sections_id';
  SetQueryCommonParams(SectionID, KeyName);
  FQuery.ExecSQL;
  FQuery.Close;
  Result := Changes();
end;

function TmsaSQLiteUserDatabase.EraseSectionKeys(const SectionID: Integer): Integer;
begin
  FQuery.SQL.Text := 'DELETE FROM keys WHERE sections_id = :sections_id';
  FQuery.ParamByName('sections_id').AsInteger := SectionID;
  FQuery.ExecSQL;
  FQuery.Close;
  Result := Changes();
end;

procedure TmsaSQLiteUserDatabase.ReadKeys(const SectionID: Integer; KeysList: TList<TKeys>);
var
  SQL: string;
begin
  if KeysList = nil then
    Exit;
  SQL := '''
SELECT key_name, sections_id,
case
 when length(ifnull(description, '')) > 30 then substr(ifnull(description, ''), 1, 30)||'...'
 else  ifnull(description, '')
end description,
case
 when length(ifnull(key_value, '')) > 30 then substr(ifnull(key_value, ''), 1, 30)||'...'
 else  ifnull(key_value, '')
end key_value,
case
 when key_blob is not null then 'BLOB ' || octet_length(key_blob) || ' bytes'
 else 'NULL'
end key_blob,
key_blob_compressed,
created_at, modif_at FROM keys
''';

  if SectionID > 0 then
  begin
    FQuery.SQL.Text := SQL + ' WHERE sections_id = :sections_id';
    FQuery.ParamByName('sections_id').AsInteger := SectionID;
  end
  else
    FQuery.SQL.Text := SQL;

  FQuery.Open;

  var Enumerator := FQuery.Map<TKeys>(
    function(DataSet: TDataSet): TKeys
    begin
      Result.key_name := DataSet.FieldByName('key_name').AsString;
      Result.sections_id := DataSet.FieldByName('sections_id').AsInteger;
      Result.description := DataSet.FieldByName('description').AsString;
      Result.key_value := DataSet.FieldByName('key_value').AsString;
      Result.key_blob := DataSet.FieldByName('key_blob').AsString;
      Result.key_blob_compressed := DataSet.FieldByName('key_blob_compressed').AsInteger = 1;
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
      Result.hidden := (DataSet.FieldByName('hidden').AsInteger = 1);
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
  FQuery.SQL.Text :=
    'SELECT key_name FROM keys WHERE trim(upper(key_name)) = trim(upper(:key_name)) and sections_id = :sections_id';
  SetQueryCommonParams(SectionID, KeyName);
  FQuery.Open;
  Result := FQuery.RecordCount > 0;
  FQuery.Close;
end;

procedure TmsaSQLiteUserDatabase.SetQueryCommonParams(const SectionID: Integer; const KeyName: string);
begin
  FQuery.ParamByName('sections_id').AsInteger := SectionID;
  FQuery.ParamByName('key_name').AsString := KeyName;
end;

procedure TmsaSQLiteUserDatabase.WriteStream(const SectionID: Integer; const KeyName: string; AStream: TStream; var
  ASize: Int64; ACompress: Boolean = False);
var
  CompressedStream: TMemoryStream;
begin
  if SectionID < 1 then
    Exit;
  ASize := AStream.Size;
  FQuery.SQL.Text := WriteKeyBlobSQL;
  SetQueryCommonParams(SectionID, KeyName);

  if ACompress then
  begin
    CompressedStream := TMemoryStream.Create;
    try
      CompressStream(AStream, CompressedStream);
      FQuery.ParamByName('key_blob').LoadFromStream(CompressedStream, ftBlob);
      FQuery.ParamByName('key_blob_compressed').AsInteger := 1;
      ASize := CompressedStream.Size;
    finally
      CompressedStream.Free;
    end;
  end
  else
  begin
    FQuery.ParamByName('key_blob').LoadFromStream(AStream, ftBlob);
    FQuery.ParamByName('key_blob_compressed').AsInteger := 0;
  end;
  FQuery.ExecSQL;
  FQuery.Close;
end;

procedure TmsaSQLiteUserDatabase.WriteValue(const SectionID: Integer; const KeyName: string; Value: string);
begin
  if SectionID < 1 then
    Exit;
  FQuery.SQL.Text := WriteKeyValueSQL;
  SetQueryCommonParams(SectionID, KeyName);
  FQuery.ParamByName('key_value').AsString := Value;

  FQuery.ExecSQL;

  FQuery.Close;
end;

procedure TmsaSQLiteUserDatabase.WriteDescription(const SectionID: Integer; const KeyName: string; Description: string);
begin
  if SectionID < 1 then
    Exit;
  FQuery.SQL.Text := WriteKeyDescriptionSQL;
  SetQueryCommonParams(SectionID, KeyName);
  FQuery.ParamByName('description').AsString := Description;
  FQuery.ExecSQL;
  FQuery.Close;
end;

procedure TmsaSQLiteUserDatabase.ReadStream(const SectionID: Integer; const KeyName: string; AStream: TStream);
var
  IsCompressed: Boolean;
  BS: TStream;
  BlobFld: TField;
begin
  if SectionID < 1 then
    Exit;
  if AStream = nil then
    Exit;

  FQuery.SQL.Text :=
    'SELECT key_blob, key_blob_compressed FROM keys WHERE (trim(upper(key_name)) = trim(upper(:key_name))) and sections_id = :sections_id';
  FQuery.ParamByName('key_name').AsString := KeyName;
  FQuery.ParamByName('sections_id').AsInteger := SectionID;
  FQuery.Open;
  IsCompressed := FQuery.FieldByName('key_blob_compressed').AsInteger = 1;
  BlobFld := FQuery.FieldByName('key_blob');
  if FQuery.RecordCount = 0 then
    Exit;
  if BlobFld.IsNull then
    Exit;
  BS := FQuery.CreateBlobStream(BlobFld, Tblobstreammode.bmRead);
  try
    if IsCompressed then
      DecompressStream(BS, AStream)
    else
      AStream.CopyFrom(BS);

    AStream.Position := 0;
  finally
    BS.Free;
  end;
  FQuery.Close;
end;

function TmsaSQLiteUserDatabase.ReadValue(const SectionID: Integer; const KeyName: string): string;
begin
  Result := '';
  if SectionID < 1 then
    Exit;
  FQuery.SQL.Text :=
    'SELECT key_value FROM keys WHERE (trim(upper(key_name)) = trim(upper(:key_name))) and sections_id = :sections_id';
  SetQueryCommonParams(SectionID, KeyName);
  FQuery.Open;
  Result := FQuery.FieldByName('key_value').AsString;
end;

function TmsaSQLiteUserDatabase.ReadFloat(const SectionID: Integer; const KeyName: string): Extended;
var
  S: string;
  DS: Char;
begin
  S := trim(ReadValue(SectionID, KeyName));
  S := S.Replace(',', '.');
  DS := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
  Result := StrToFloatDef(S, 0.0);
  FormatSettings.DecimalSeparator := DS;
end;

function TmsaSQLiteUserDatabase.ReadInteger(const SectionID: Integer; const KeyName: string): Int64;
var
  S: string;
  P: Integer;
begin
  S := trim(ReadValue(SectionID, KeyName));
  S := S.Replace(',', '.');
  P := Pos('.', S);
  if P > 0 then
    S := S.Substring(0, P - 1);
  Result := StrToInt64Def(S, 0);
end;

function TmsaSQLiteUserDatabase.ReadDateTime(const SectionID: Integer; const KeyName: string): TDateTime;
var
  S: string;
begin
  S := trim(ReadValue(SectionID, KeyName));
  Result := StrToDateTimeDef(S, 0);
end;

function TmsaSQLiteUserDatabase.ReadDate(const SectionID: Integer; const KeyName: string): TDate;
var
  S: string;
begin
  S := Trim(ReadValue(SectionID, KeyName));
  Result := DateOf(StrToDateTimeDef(S, 0));
end;

function TmsaSQLiteUserDatabase.ReadTime(const SectionID: Integer; const KeyName: string): TTime;
var
  S: string;
begin
  S := Trim(ReadValue(SectionID, KeyName));
  Result := TimeOf(StrToDateTimeDef(S, 0));
end;

function TmsaSQLiteUserDatabase.ReadBool(const SectionID: Integer; const KeyName: string): Boolean;
var
  S: string;
begin
  S := AnsiUpperCase(Trim((ReadValue(SectionID, KeyName))));
  Result := (S = 'TRUE') or (S = '1') or (S = 'YES') or (S = 'ÄÀ');
end;

end.

