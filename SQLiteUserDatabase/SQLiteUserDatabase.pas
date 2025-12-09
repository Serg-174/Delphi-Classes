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
  System.SysUtils, System.Classes, Winapi.Windows, System.Types, Winapi.ShlObj, System.StrUtils, FireDAC.Comp.Client,
  FireDAC.Phys.SQLite, FireDAC.Stan.Def, FireDAC.DApt, System.IOUtils, FireDAC.Stan.Param, Data.DB,
  System.Generics.Collections, DataSetEnumerator, System.Variants, System.DateUtils, FireDAC.UI.Intf, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Intf, FireDAC.Comp.UI, FireDAC.Stan.Async, uCommon, msaClassHelpers;

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

type
  TSections = record
    id: integer;
    parent_id: Variant;
    section_name: string;
    description: string;
    hidden: Boolean;
    created_at: TDateTime;
    modif_at: TDateTime;
    orderby: Real;
    path: string;
    level: Integer;
    keys_count: Integer;
  end;

type
  TCreatedModified = record
    Created_at: string;
    Modif_at: string;
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
    function SectionExists(const ParentID: Integer; const SectionName: string): Integer;
    function CreateSection(const ParentID: Integer; const SectionName, Description: string): Integer;
    procedure RenameSection(const SectionID: Integer; SectionName: string);
    procedure ChangeSectionSortOrder(const SectionID: Integer; OrderBy: Extended);
    procedure ChangeKeySortOrder(const SectionID: Integer; const KeyName: string; OrderBy: Extended);
    procedure WriteSectionDescription(const SectionID: Integer; Description: string);
    function Last_Insert_Rowid(): Integer;
    function KeysCount(const SectionID: Integer): Integer;
    function DeleteSection(const SectionID: Integer): Integer;
    function Changes(): Integer;
    function DeleteAll: Integer;
    function DeleteKey(const SectionID: Integer; const KeyName: string): Integer;
    function EraseSectionKeys(const SectionID: Integer): Integer;
    procedure ReadKeys(const SectionID: Integer; KeysList: TList<TKeys>);
    procedure ReadSections(const SectionID: Integer; SectionsList: TList<TSections>);
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
    function GetSectionCreatedModified(const SectionID: Integer): TCreatedModified;
    function GetKeyCreatedModified(const SectionID: Integer; const KeyName: string): TCreatedModified;
    function GetSectionFullPath(const SectionID: Integer): string;
    function ReadKey(const SectionID: Integer; const KeyName: string): TKeys;
    function ReadSection(const SectionID: Integer): TSections;
    function ForceSections(const Path: string; Delimiter: Char = '\'): Integer;
    procedure ChangeSectionParent(const SectionID: Integer; ANewParent: Variant);

  end;

const
  SectionsTableSQL = '''
    CREATE TABLE IF NOT EXISTS sections (
    id           INTEGER  PRIMARY KEY
                          UNIQUE
                          NOT NULL,
    parent_id    INTEGER  REFERENCES sections (id) ON DELETE CASCADE
                                                   ON UPDATE NO ACTION,
    orderby      REAL     NOT NULL
                          DEFAULT (0.0),
    section_name TEXT     NOT NULL,
    description  TEXT,
    hidden       INTEGER  NOT NULL
                          DEFAULT (0)
                          CHECK (hidden IN (0, 1) ),
    created_at   DATETIME NOT NULL
                          DEFAULT (datetime('now', 'localtime') ),
    modif_at     DATETIME NOT NULL
                          DEFAULT (datetime('now', 'localtime') ));
   ''';
  KeysTableSQL = '''
    CREATE TABLE IF NOT EXISTS keys (
    key_name            TEXT     NOT NULL,
    sections_id         INTEGER  REFERENCES sections (id) ON DELETE CASCADE
                                                          ON UPDATE NO ACTION
                                 NOT NULL,
    orderby      REAL     NOT NULL
                          DEFAULT (0.0),
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
    ON CONFLICT FAIL);
    ''';
  SectionsTriggerSQL0 = '''
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
  KeysTriggerSQL0 = '''
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
  ViewSectionsTreeSQL = '''
    CREATE VIEW IF NOT EXISTS v_sections_tree AS
     WITH RECURSIVE subtree AS (
       SELECT s.id,
              s.parent_id,
              0 AS lvl,
              ifnull(s.section_name, 'null') AS path
          FROM sections s
         WHERE s.parent_id IS NULL
        UNION ALL
        SELECT s.id,
               s.parent_id,
               st.lvl + 1,
               st.path || '\' || ifnull(s.section_name,'null')
          FROM sections s
               JOIN
               subtree st ON s.parent_id = st.id
                )
     SELECT st.id, st.parent_id, st.lvl, st.path FROM subtree st
     INNER JOIN sections s ON s.id = st.id
    ''';
  KeysIndex1SQL = '''
   CREATE INDEX IF NOT EXISTS keys_fk_idx ON keys (sections_id);
   ''';
  KeysIndex2SQL = '''
   CREATE INDEX IF NOT EXISTS keys_orderby_idx ON keys (orderby, key_name);
   ''';
  SectionsIndex1SQL = '''
   CREATE INDEX IF NOT EXISTS sections_fk_idx ON sections (parent_id);
   ''';
  SectionsIndex2SQL = '''
    CREATE UNIQUE INDEX IF NOT EXISTS sections_name_parent_idx ON sections (
    ifnull(parent_id, -1),
    section_name COLLATE NOCASE );
   ''';
  SectionsIndex3SQL = '''
    CREATE INDEX IF NOT EXISTS sections_orderby_idx ON sections (
    orderby, section_name);
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
  SectionsTriggerSQL1 = '''
    CREATE TRIGGER IF NOT EXISTS prevent_circular_insert
        BEFORE INSERT
            ON sections
          WHEN NEW.parent_id IS NOT NULL
    BEGIN
    SELECT RAISE(ABORT, [Cannot reference itself]) 
     WHERE NEW.parent_id = NEW.id;
    SELECT RAISE(ABORT, [Circular reference can not be created]) 
     WHERE EXISTS (
           WITH RECURSIVE parent_chain (
                   id,
                   parent_id,
                   depth
               )
               AS (
                   SELECT id,
                          parent_id,
                          1
                     FROM sections
                    WHERE id = NEW.parent_id
                   UNION ALL
                   SELECT s.id,
                          s.parent_id,
                          pc.depth + 1
                     FROM sections s
                          JOIN
                          parent_chain pc ON s.id = pc.parent_id
                    WHERE pc.depth < 100 AND s.parent_id IS NOT NULL
               )
               SELECT 1
                 FROM parent_chain
                WHERE id = NEW.id
                LIMIT 1
           );
    END;

    ''';
  SectionsTriggerSQL2 = '''
    CREATE TRIGGER IF NOT EXISTS prevent_circular_update
        BEFORE UPDATE
            ON sections
          WHEN NEW.parent_id IS NOT NULL AND
               (NEW.parent_id != OLD.parent_id OR
                OLD.parent_id IS NULL OR
                NEW.id != OLD.id) 
    BEGIN
    SELECT RAISE(ABORT, [Cannot reference itself]) 
     WHERE NEW.parent_id = NEW.id;
    SELECT RAISE(ABORT, [Circular reference can not be created]) 
     WHERE (NEW.parent_id != OLD.parent_id OR
            OLD.parent_id IS NULL) AND
           EXISTS (
           WITH RECURSIVE descendant_chain (
                   id,
                   parent_id,
                   depth
               )
               AS (
                   SELECT id,
                          parent_id,
                          1
                     FROM sections
                    WHERE parent_id = NEW.id AND
                          id != NEW.id
                   UNION ALL
                   SELECT s.id,
                          s.parent_id,
                          dc.depth + 1
                     FROM sections s
                          JOIN
                          descendant_chain dc ON s.parent_id = dc.id
                    WHERE dc.depth < 100
               )
               SELECT 1
                 FROM descendant_chain
                WHERE id = NEW.parent_id
                LIMIT 1
           );
    END;
    ''';

implementation

  { TSettingsManager }

function TmsaSQLiteUserDatabase.GetKeyCreatedModified(const SectionID: Integer; const KeyName: string): TCreatedModified;
begin
  if SectionID = -1 then
    Exit;
  FQuery.SQL.Text := 'select created_at, modif_at FROM keys WHERE key_name = :key_name and sections_id = :sections_id LIMIT 1';
  FQuery.PInt('sections_id', SectionID);
  FQuery.PStr('key_name', KeyName);
  try
    FQuery.Open;
    if FQuery.IsEmpty then
      Exit;
    Result.Created_at := FQuery.FStr('created_at');
    Result.Modif_at := FQuery.FStr('modif_at');
  finally
    FQuery.Close;
  end;
end;

function TmsaSQLiteUserDatabase.GetSectionCreatedModified(const SectionID: Integer): TCreatedModified;
begin
  if SectionID = -1 then
    Exit;
  FQuery.SQL.Text := 'select created_at, modif_at FROM sections WHERE id = :sections_id';
  FQuery.PInt('sections_id', SectionID);
  try
    FQuery.Open;
    if FQuery.IsEmpty then
      Exit;
    Result.Created_at := FQuery.FStr('created_at');
    Result.Modif_at := FQuery.FStr('modif_at');
  finally
    FQuery.Close;
  end;
end;

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

function TmsaSQLiteUserDatabase.SectionExists(const ParentID: Integer; const SectionName: string): Integer;
begin
  FQuery.SQL.Text := '''
   SELECT id FROM sections WHERE trim(upper(section_name)) = :section_name and ifnull(parent_id, -1) = :parent_id
  ''';
  FQuery.ParamByName('section_name').AsString := Trim(UpperCase(SectionName));
  FQuery.ParamByName('parent_id').AsInteger := ParentID;
  FQuery.Open;
  Result := if FQuery.FieldByName('id').IsNull then -1 else FQuery.FieldByName('id').AsInteger;
  FQuery.Close;
end;

procedure TmsaSQLiteUserDatabase.ChangeSectionParent(const SectionID: Integer; ANewParent: Variant);
var
  SQL: string;
  Param: string;
begin
  if SectionID = -1 then
    Exit;

  if ANewParent = null then
    Param := 'NULL'
  else
    Param := IntToStr(ANewParent);

  SQL := 'UPDATE sections SET parent_id = %s WHERE id = %s';
  SQL := format(SQL, [Param, IntToStr(SectionID)]);
  FQuery.SQL.Text := SQL;
  FQuery.ExecSQL;
  FQuery.Close;
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

function TmsaSQLiteUserDatabase.CreateSection(const ParentID: Integer; const SectionName, Description: string): Integer;
begin
  Result := SectionExists(ParentID, SectionName);
  if Result > -1 then
    Exit;

  FQuery.SQL.Text := 'INSERT INTO sections(parent_id, section_name, description) VALUES(:parent_id, :section_name, :description)';

  FQuery.ParamByName('section_name').AsString := SectionName;
  FQuery.ParamByName('description').AsString := Description;

  if ParentID = -1 then
    FQuery.ParamByName('parent_id').Value := null
  else
    FQuery.ParamByName('parent_id').AsInteger := ParentID;

  FQuery.ExecSQL;
  Result := Last_Insert_Rowid();
  FQuery.Close;
end;

function TmsaSQLiteUserDatabase.DeleteSection(const SectionID: Integer): Integer;
begin
  Result := 0;
  if SectionID = -1 then
    Exit;
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

    SQL := SectionsTriggerSQL0;
    FQuery.SQL.Text := SQL;
    FQuery.ExecSQL;
    FQuery.Close;

    SQL := SectionsTriggerSQL1;
    FQuery.SQL.Text := SQL;
    FQuery.ExecSQL;
    FQuery.Close;

    SQL := SectionsTriggerSQL2;
    FQuery.SQL.Text := SQL;
    FQuery.ExecSQL;
    FQuery.Close;

    SQL := KeysTriggerSQL0;
    FQuery.SQL.Text := SQL;
    FQuery.ExecSQL;
    FQuery.Close;

    SQL := KeysIndex1SQL;
    FQuery.SQL.Text := SQL;
    FQuery.ExecSQL;
    FQuery.Close;

    SQL := KeysIndex2SQL;
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

    SQL := SectionsIndex3SQL;
    FQuery.SQL.Text := SQL;
    FQuery.ExecSQL;
    FQuery.Close;

    SQL := ViewSectionsTreeSQL;
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

procedure TmsaSQLiteUserDatabase.RenameSection(const SectionID: Integer; SectionName: string);
begin
  FQuery.SQL.Text := 'UPDATE sections SET section_name = :section_name where id = :sections_id';
  FQuery.ParamByName('sections_id').AsInteger := SectionID;
  FQuery.ParamByName('section_name').AsString := SectionName;
  FQuery.ExecSQL;
  FQuery.Close;
end;

procedure TmsaSQLiteUserDatabase.WriteSectionDescription(const SectionID: Integer; Description: string);
begin
  FQuery.SQL.Text := 'UPDATE sections SET description = :description where id = :sections_id';
  FQuery.ParamByName('sections_id').AsInteger := SectionID;
  FQuery.ParamByName('description').AsString := Description;
  FQuery.ExecSQL;
  FQuery.Close;
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

function TmsaSQLiteUserDatabase.ReadKey(const SectionID: Integer; const KeyName: string): TKeys;
begin
  if SectionID < 1 then
    Exit;

  FQuery.SQL.Text := '''
  SELECT
   key_name,
   sections_id,
   description,
   key_value,
   key_blob_compressed,
   created_at,
   modif_at
  FROM keys
  WHERE trim(upper(key_name)) = trim(upper(:key_name)) and sections_id = :sections_id
 ''';
  SetQueryCommonParams(SectionID, KeyName);
  FQuery.Open;
  Result.key_name := FQuery.FieldByName('key_name').AsString;
  Result.sections_id := FQuery.FieldByName('sections_id').AsInteger;
  Result.description := FQuery.FieldByName('description').AsString;
  Result.key_value := FQuery.FieldByName('key_value').AsString;
  Result.key_blob_compressed := FQuery.FieldByName('key_blob_compressed').AsInteger = 1;
  Result.created_at := FQuery.FieldByName('created_at').AsDateTime;
  Result.modif_at := FQuery.FieldByName('modif_at').AsDateTime;
  FQuery.Close;
end;

procedure TmsaSQLiteUserDatabase.ReadKeys(const SectionID: Integer; KeysList: TList<TKeys>);
var
  SQL, WhereSQL: string;
const
  ReadKeysSQL0 = '''
 WITH RECURSIVE subsections AS (
     SELECT
       s.id,
       s.parent_id,
       s.section_name,
       s.description,
       s.hidden,
       s.created_at,
       s.modif_at,
       s.section_name AS path,
       0 AS lvl,
       s.orderby
     FROM sections s
 ''';
  ReadKeysSQL10 = '''
   WHERE s.id = %d
  ''';
  ReadKeysSQL11 = '''
   WHERE s.parent_id is null
  ''';
  ReadKeysSQL2 = '''
     UNION ALL
     SELECT
       s.id,
       s.parent_id,
       s.section_name,
       s.description,
       s.hidden,
       s.created_at,
       s.modif_at,
       ss.path || '\' || s.section_name path,
       ss.lvl + 1,
       s.orderby
     FROM sections s
          JOIN subsections ss ON s.parent_id = ss.id),
 subsections_keys AS(
SELECT
  key_name,
  sections_id,
  case
    when length(ifnull(description, '')) > 30 then substr(ifnull(description, ''), 1, 30) || '...'
    else ifnull(description, '')
  end description,
  case
    when length(ifnull(key_value, '')) > 30 then substr(ifnull(key_value, ''), 1, 30) || '...'
    else ifnull(key_value, '')
  end key_value,
  case
    when key_blob is not null then 'BLOB ' || length(key_blob) || ' bytes'
    else 'NULL'
  end key_blob,
  key_blob_compressed,
  created_at,
  modif_at,
  orderby
FROM keys)
    SELECT
       ssk.key_name
      ,ssk.key_value
      ,ssk.sections_id
      ,ssk.description
      ,ssk.key_blob
      ,ssk.key_blob_compressed
      ,ssk.created_at
      ,ssk.modif_at
      ,ssk.orderby
      ,s.section_name
      ,s.path section_path
      ,s.hidden section_hidden
      ,s.lvl section_level
      ,s.orderby section_orderby
    FROM subsections s
    inner join subsections_keys AS ssk on ssk.sections_id = s.id
''';
  ReadKeysSQL_Where = '''
    WHERE 1 = 1
   ''';
  ReadKeysSQL_OrderBy = '''
   order by s.lvl, s.orderby, s.section_name, ssk.orderby, ssk.key_name
  ''';
begin
  if KeysList = nil then
    Exit;
  if SectionID = -1 then
    WhereSQL := ReadKeysSQL11
  else
    WhereSQL := format(ReadKeysSQL10, [SectionID]);
  SQL := ReadKeysSQL0 + WhereSQL + ReadKeysSQL2 + ReadKeysSQL_Where + ReadKeysSQL_OrderBy;

  FQuery.SQL.Text := SQL;
  FQuery.Open;

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
      Result.orderby := DataSet.FieldByName('orderby').AsFloat;
      Result.section_name := DataSet.FieldByName('section_name').AsString;
      Result.section_path := DataSet.FieldByName('section_path').AsString;
      Result.section_hidden := DataSet.FieldByName('section_hidden').AsInteger = 1;
      Result.section_level := DataSet.FieldByName('section_level').AsInteger;
      Result.section_orderby := DataSet.FieldByName('section_orderby').AsFloat;
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

function TmsaSQLiteUserDatabase.ReadSection(const SectionID: Integer): TSections;
begin
  if SectionID < 1 then
    Exit;

  FQuery.SQL.Text := '''
  SELECT
       s.id
      ,s.parent_id
      ,s.section_name
      ,s.description
      ,s.hidden
      ,s.created_at
      ,s.modif_at
      ,(SELECT COUNT(k.key_name) FROM keys k WHERE k.sections_id = s.id) AS keys_count
  FROM sections s
  WHERE id = :sections_id
 ''';
  FQuery.ParamByName('sections_id').AsInteger := SectionID;
  FQuery.Open;
  Result.id := FQuery.FieldByName('id').AsInteger;
  Result.parent_id := FQuery.FieldByName('parent_id').Value;
  Result.section_name := FQuery.FieldByName('section_name').AsString;
  Result.description := FQuery.FieldByName('description').AsString;
  Result.hidden := FQuery.FieldByName('hidden').AsInteger = 1;
  Result.created_at := FQuery.FieldByName('created_at').AsDateTime;
  Result.modif_at := FQuery.FieldByName('modif_at').AsDateTime;
  Result.keys_count := FQuery.FieldByName('keys_count').AsInteger;
  FQuery.Close;
end;

procedure TmsaSQLiteUserDatabase.ReadSections(const SectionID: Integer; SectionsList: TList<TSections>);
var
  SQL, WhereSQL: string;
const
  ReadSectionsSQL0 = '''
  WITH RECURSIVE subsections AS (
     SELECT
       s.id,
       s.parent_id,
       s.section_name,
       s.description,
       s.hidden,
       s.created_at,
       s.modif_at,
        CAST (s.section_name AS TEXT) AS path,
       0 AS level,
       s.orderby
     FROM sections s
 ''';
  ReadSectionsSQL10 = '''
   WHERE s.parent_id = %d
  ''';
  ReadSectionsSQL11 = '''
   WHERE s.parent_id is null
  ''';
  ReadSectionsSQL2 = '''
 UNION ALL
     SELECT
       s.id,
       s.parent_id,
       s.section_name,
       s.description,
       s.hidden,
       s.created_at,
       s.modif_at,
       ss.path || '\' || s.section_name,
       ss.level + 1 level,
       s.orderby
     FROM sections s
          JOIN subsections ss ON s.parent_id = ss.id)
    SELECT
       s.id
      ,s.parent_id
      ,s.section_name
      ,s.description
      ,s.hidden
      ,s.orderby
      ,s.created_at
      ,s.modif_at
      ,s.path
      ,s.level
      ,(SELECT COUNT(k.key_name) FROM keys k WHERE k.sections_id = s.id) AS keys_count
    FROM subsections s
''';
  ReadSectionsSQL_Where = '''
    WHERE 1 = 1
   ''';
  ReadSectionsSQL_OrderBy = '''
   order by s.level, s.orderby, s.section_name
  ''';
begin
  if SectionsList = nil then
    Exit;

  if SectionID = -1 then
    WhereSQL := ReadSectionsSQL11
  else
    WhereSQL := format(ReadSectionsSQL10, [SectionID]);
  SQL := ReadSectionsSQL0 + WhereSQL + ReadSectionsSQL2 + ReadSectionsSQL_Where + ReadSectionsSQL_OrderBy;
  FQuery.SQL.Text := SQL;
  FQuery.Open;

  var Enumerator := FQuery.Map<TSections>(
    function(DataSet: TDataSet): TSections
    begin
      Result.id := DataSet.FieldByName('id').AsInteger;
      Result.parent_id := DataSet.FieldByName('parent_id').Value;
      Result.section_name := DataSet.FieldByName('section_name').AsString;
      Result.description := DataSet.FieldByName('description').AsString;
      Result.hidden := (DataSet.FieldByName('hidden').AsInteger = 1);
      Result.orderby := DataSet.FieldByName('orderby').AsFloat;
      Result.created_at := DataSet.FieldByName('created_at').AsDateTime;
      Result.modif_at := DataSet.FieldByName('modif_at').AsDateTime;
      Result.path := DataSet.FieldByName('path').AsString;
      Result.level := DataSet.FieldByName('level').AsInteger;
      Result.keys_count := DataSet.FieldByName('keys_count').AsInteger;
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
  if SectionID = -1 then
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

function TmsaSQLiteUserDatabase.GetSectionFullPath(const SectionID: Integer): string;
begin
  Result := '';
  if SectionID < 1 then
    Exit;
  FQuery.SQL.Text := '''
   WITH RECURSIVE section_path AS (
    SELECT
        id,
        parent_id,
        ifnull(section_name, 'null') AS path
    FROM sections
    WHERE id = :section_id
    UNION ALL
    SELECT
        s.id,
        s.parent_id,
        ifnull(s.section_name, 'null') || '\' || sp.path
    FROM sections s
    INNER JOIN section_path sp ON s.id = sp.parent_id
     )
   SELECT path FROM section_path
   WHERE parent_id IS NULL
  ''';
  FQuery.PInt('section_id', SectionID);
  FQuery.Open;
  Result := FQuery.FStr('path');
end;

function TmsaSQLiteUserDatabase.ForceSections(const Path: string; Delimiter: Char = '\'): Integer;
var
  CountOfSections: Integer;
  CurrentSectionName: string;
  I: Integer;
begin
  Result := -1;
  CountOfSections := CountOfWords(Path, Delimiter, False);
  if CountOfSections = 0 then
    Exit;
  for I := 1 to CountOfSections do
  begin
    CurrentSectionName := GetWordNum(Path, Delimiter, I, False);
    Result := CreateSection(Result, CurrentSectionName, '');
  end;
end;

procedure TmsaSQLiteUserDatabase.ChangeSectionSortOrder(const SectionID: Integer; OrderBy: Extended);
var
  SQL: string;
begin
  if SectionID < 1 then
    Exit;
  SQL := 'UPDATE sections SET orderby = %s where id = %s';
  SQL := format(SQL, [OrderBy.ToString.Replace(',', '.'), SectionID.ToString]);

  FQuery.SQL.Text := SQL;
  FQuery.ExecSQL;
  FQuery.Close;
end;

procedure TmsaSQLiteUserDatabase.ChangeKeySortOrder(const SectionID: Integer; const KeyName: string; OrderBy: Extended);
var
  SQL: string;
begin
  if SectionID < 1 then
    Exit;
  SQL := 'UPDATE keys SET orderby = %s where  (trim(upper(key_name)) = trim(upper(%s))) AND sections_id = %s';
  SQL := format(SQL, [OrderBy.ToString.Replace(',', '.'), QuotedStr(KeyName), SectionID.ToString]);

  FQuery.SQL.Text := SQL;
  FQuery.ExecSQL;
  FQuery.Close;
end;

end.

