unit uTreeLoader;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.IOUtils, Vcl.ExtCtrls, System.Generics.Collections, Vcl.Mask,
  FireDAC.Stan.Def, FireDAC.VCLUI.Wait, FireDAC.VCLUI.Controls, FireDAC.Stan.Intf, FireDAC.Phys, FireDAC.Phys.SQLite,
  Vcl.ComCtrls, Winapi.ShlObj, FireDAC.Comp.Client, System.StrUtils;

type
  TTreeViewSectionsLoader = class
  private
    FTreeView: TTreeView;
    FConnection: TFDConnection;
    procedure SetNodeAppearance(Node: TTreeNode; const Description: string; Hidden: Boolean);
  public
    constructor Create(ATreeView: TTreeView; AConnection: TFDConnection);
    procedure LoadSections;
    function FindNodeByID(SectionID: Integer): TTreeNode;
    function GetSelectedSectionID: Integer;
  end;

implementation

constructor TTreeViewSectionsLoader.Create(ATreeView: TTreeView; AConnection: TFDConnection);
begin
  inherited Create;
  FTreeView := ATreeView;
  FConnection := AConnection;
  FConnection.Params.Values['OpenMode'] := 'CreateUTF8';
  FConnection.Params.Values['LockingMode'] := 'Normal';
  FConnection.LoginPrompt := False;
  FConnection.FormatOptions.MaxStringSize := 1_048_576;
end;

procedure TTreeViewSectionsLoader.SetNodeAppearance(Node: TTreeNode; const Description: string; Hidden: Boolean);
begin
  if Hidden then
  begin
    Node.StateIndex := 1; // Hidden
  end
  else
  begin
    Node.StateIndex := 0; // not Hidden
  end;
end;

procedure TTreeViewSectionsLoader.LoadSections;
var
  Query: TFDQuery;
  NodesMap: TDictionary<Integer, TTreeNode>;
  Sections: TList<TPair<Integer, Integer>>; // ID, ParentID
  i: Integer;
  TreeNode, ParentNode: TTreeNode;
begin
  FTreeView.Items.BeginUpdate;
  try
    FTreeView.Items.Clear;

    Query := TFDQuery.Create(nil);
    NodesMap := TDictionary<Integer, TTreeNode>.Create;
    Sections := TList<TPair<Integer, Integer>>.Create;
    try
      Query.Connection := FConnection;
      Query.SQL.Text := 'SELECT id, parent_id, section_name, description, hidden FROM sections ORDER BY section_name';
      Query.Open;

      // Проходим по записям и создаем все узлы
      while not Query.Eof do
      begin
        var SectionID := Query.FieldByName('id').AsInteger;
        var ParentID := -1;
        if not Query.FieldByName('parent_id').IsNull then
          ParentID := Query.FieldByName('parent_id').AsInteger;

        // Создаем узел
        TreeNode := FTreeView.Items.Add(nil, Query.FieldByName('section_name').AsString);
        TreeNode.Data := Pointer(SectionID);

        // Настраиваем внешний вид
        SetNodeAppearance(TreeNode, Query.FieldByName('description').AsString, Query.FieldByName('hidden').AsInteger = 1);

        // Сохраняем для установки связей
        NodesMap.Add(SectionID, TreeNode);
        Sections.Add(TPair<Integer, Integer>.Create(SectionID, ParentID));

        Query.Next;
      end;

      // Устанавливаем родительские связи
      for i := 0 to Sections.Count - 1 do
      begin
        var SectionID := Sections[i].Key;
        var ParentID := Sections[i].Value;

        if ParentID <> -1 then
        begin
          if NodesMap.TryGetValue(SectionID, TreeNode) and NodesMap.TryGetValue(ParentID, ParentNode) then
          begin
            TreeNode.MoveTo(ParentNode, naAddChild);
          end;
        end;
      end;

    finally
      Sections.Free;
      NodesMap.Free;
      Query.Free;
    end;
  finally
    FTreeView.Items.EndUpdate;
  end;
end;

function TTreeViewSectionsLoader.FindNodeByID(SectionID: Integer): TTreeNode;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FTreeView.Items.Count - 1 do
  begin
    if Integer(FTreeView.Items[i].Data) = SectionID then
    begin
      Result := FTreeView.Items[i];
      Break;
    end;
  end;
end;

function TTreeViewSectionsLoader.GetSelectedSectionID: Integer;
begin
  Result := -1;
  if (FTreeView.Selected <> nil) then
    Result := Integer(FTreeView.Selected.Data);
end;

end.

