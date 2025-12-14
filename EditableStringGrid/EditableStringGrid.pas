unit EditableStringGrid;
//Навигация стрелками

interface

uses
  System.Classes, System.Types, Vcl.Forms, System.SysUtils, Vcl.Grids, Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls, Vcl.Graphics, Winapi.Windows, Math, Messages;

const
  WM_CLOSE_EDITOR = WM_USER + 100;

type
  TGridButtonedEdit = class(TButtonedEdit)
  protected
    procedure WMKeyDown(var Msg: TWMKeyDown); message WM_KEYDOWN;
  end;

type
  TGridEdit = class(TEdit)
  private
    procedure WMKeyDown(var Msg: TWMKeyDown); message WM_KEYDOWN;
  end;

type
  TGridEditorType = (geNone, geEdit, geComboBox, geButtonedEdit, geCheckBox);

  TGetEditorEvent = procedure(Sender: TObject; ACol, ARow: Integer; var EditorType: TGridEditorType) of object;

  TGetComboItemsEvent = procedure(Sender: TObject; ACol, ARow: Integer; Items: TStrings) of object;

  TButtonClickEvent = procedure(Sender: TObject; ACol, ARow: Integer) of object;

  TSetupEditorEvent = procedure(Sender: TObject; ACol, ARow: Integer; Editor: TWinControl) of object;

  TCellHintEvent = procedure(Sender: TObject; ACol, ARow: Integer; var HintStr: string) of object;

type
  TRoundedHintWindow = class(THintWindow)
  private
    FCornerRadius: Integer;
    FLeftMargin: Integer;
    FRightMargin: Integer;
    FExtraMargin: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ActivateHint(Rect: TRect; const AHint: string); reintroduce;
  protected
    procedure Paint; override;
  end;

  TEditableStringGrid = class(TStringGrid)
  private
    FEditor: TWinControl;
    FEditCol: Integer;
    FEditRow: Integer;
    FHoverCell: TPoint;

    FOriginalValue: string;
    FEditing: Boolean;

    FAutoColWidth: Boolean;
    FMaxColWidth: Integer;
    FMinColWidth: Integer;

    FColEditors: array of TGridEditorType;

    FMemoRowHeight: Integer;

    FOnGetEditor: TGetEditorEvent;
    FOnGetComboItems: TGetComboItemsEvent;
    FOnButtonClick: TButtonClickEvent;
    FOnSetupEditor: TSetupEditorEvent;
    FOnCellHint: TCellHintEvent;

    FHintWindow: TRoundedHintWindow;
    FLastHintCell: TPoint;
    FPendingHintCell: TPoint;
    FHintTimer: TTimer;
    FCellHintDelay: Integer;
    FAllowGrayed: Boolean;
    FTrueValue: string;
    FFalseValue: string;
    FNullValue: string;

    FSmoothOffsetY: Integer;
    FSmoothScrollStep: Integer;

    function GetEditorType(ACol, ARow: Integer): TGridEditorType;
    function GetCheckState(const S: string): Integer;
    function NextCheckState(State: Integer): Integer;
    function CheckStateToStr(State: Integer): string;
    procedure ButtonClick(Sender: TObject);
    procedure GridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);

    procedure ShowEditor(ACol, ARow: Integer; EditorType: TGridEditorType);
    procedure HideEditor;

    procedure SetAutoColWidth(const Value: Boolean);
    procedure WMAdjustCols(var Msg: TMessage); message WM_USER + 1;
    procedure HintTimerProc(Sender: TObject);
    procedure AcceptEdit;
    procedure CancelEdit;
    procedure WMCloseEditor(var Msg: TMessage); message WM_CLOSE_EDITOR;
    procedure ComboBoxCloseUp(Sender: TObject);
    procedure EditorExit(Sender: TObject);
    procedure WMVScroll(var Msg: TWMVScroll); message WM_VSCROLL;
  protected
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure DrawCell(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure WMMouseWheel(var Msg: TWMMouseWheel); message WM_MOUSEWHEEL;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure BeginEditCell(ACol, ARow: Integer);
    procedure AdjustColWidth(ACol: Integer);
    procedure AdjustAllCols;

    procedure SetCellText(ACol, ARow: Integer; const Value: string);
    procedure SetColEditor(ACol: Integer; EditorType: TGridEditorType);

    function GetActiveEditor(ACol, ARow: Integer): TWinControl;

    property MemoRowHeight: Integer read FMemoRowHeight write FMemoRowHeight;

    property OnGetEditor: TGetEditorEvent read FOnGetEditor write FOnGetEditor;
    property OnGetComboItems: TGetComboItemsEvent read FOnGetComboItems write FOnGetComboItems;
    property OnButtonClick: TButtonClickEvent read FOnButtonClick write FOnButtonClick;
    property OnSetupEditor: TSetupEditorEvent read FOnSetupEditor write FOnSetupEditor;
    property OnCellHint: TCellHintEvent read FOnCellHint write FOnCellHint;

  published
    property AutoColWidth: Boolean read FAutoColWidth write SetAutoColWidth default False;
    property MaxColWidth: Integer read FMaxColWidth write FMaxColWidth default 500;
    property MinColWidth: Integer read FMinColWidth write FMinColWidth default 20;
    property CellHintDelay: Integer read FCellHintDelay write FCellHintDelay default 500;
    property AllowGrayed: Boolean read FAllowGrayed write FAllowGrayed default False;
    property TrueValue: string read FTrueValue write FTrueValue;
    property FalseValue: string read FFalseValue write FFalseValue;
    property NullValue: string read FNullValue write FNullValue;
  end;

implementation

{ TRoundedHintWindow }

constructor TRoundedHintWindow.Create(AOwner: TComponent);
begin
  inherited;
  FCornerRadius := 10;
  FLeftMargin := 6;
  FRightMargin := 3;
  FExtraMargin := 1;
end;

procedure TRoundedHintWindow.ActivateHint(Rect: TRect; const AHint: string);
var
  TextSize: TSize;
  W, H: Integer;
begin
  Canvas.Font := Self.Font;
  GetTextExtentPoint32(Canvas.Handle, PChar(AHint), Length(AHint), TextSize);

  W := TextSize.cx + FLeftMargin + FRightMargin + 4 + 2 * FExtraMargin;
  H := TextSize.cy + 4;

  W := Min(W, Screen.Width - Rect.Left - 10);
  Rect.Right := Rect.Left + W;
  Rect.Bottom := Rect.Top + H;

  inherited ActivateHint(Rect, AHint);
end;

procedure TRoundedHintWindow.Paint;
var
  R: TRect;
  Rgn: HRGN;
begin
  R := ClientRect;

  Rgn := CreateRoundRectRgn(R.Left, R.Top, R.Right + FExtraMargin, R.Bottom + FExtraMargin, FCornerRadius, FCornerRadius);
  SetWindowRgn(Self.Handle, Rgn, True);

  Canvas.Brush.Color := clInfoBk;
  Canvas.FillRect(R);

  Canvas.Pen.Color := clBlack;
  Canvas.RoundRect(R.Left, R.Top, R.Right - 1, R.Bottom - 1, FCornerRadius, FCornerRadius);

  R.Left := R.Left + FLeftMargin;
  R.Right := R.Right - FRightMargin;
  DrawText(Canvas.Handle, PChar(Caption), Length(Caption), R, DT_SINGLELINE or DT_LEFT or DT_VCENTER or DT_NOPREFIX);
end;

{ TEditableStringGrid }

constructor TEditableStringGrid.Create(AOwner: TComponent);
begin
  inherited;
  Options := Options - [goEditing, goRangeSelect];
  DefaultDrawing := True;

  FEditor := nil;
  FAutoColWidth := False;
  FMaxColWidth := 500;
  FMinColWidth := 20;
  FMemoRowHeight := 20;
  DefaultRowHeight := FMemoRowHeight;

  OnSelectCell := GridSelectCell;
  ShowHint := True;

  FHintWindow := TRoundedHintWindow.Create(Self);
  FLastHintCell := Point(-1, -1);
  FPendingHintCell := Point(-1, -1);

  FCellHintDelay := 500;
  FHintTimer := TTimer.Create(Self);
  FHintTimer.Enabled := False;
  FHintTimer.Interval := FCellHintDelay;
  FHintTimer.OnTimer := HintTimerProc;

  DefaultDrawing := True;
  DoubleBuffered := True;
  Options := Options - [goEditing];
  FHoverCell := Point(-1, -1);
  FSmoothOffsetY := 0;
  FSmoothScrollStep := 20;
end;

destructor TEditableStringGrid.Destroy;
begin
  FHintTimer.Free;
  FHintWindow.Free;
  HideEditor;
  inherited;
end;

procedure TEditableStringGrid.HintTimerProc(Sender: TObject);
var
  HintStr: string;
  R, HintRect: TRect;
begin
  FHintTimer.Enabled := False;

  if Assigned(FOnCellHint) then
  begin
    HintStr := '';
    FOnCellHint(Self, FPendingHintCell.X, FPendingHintCell.Y, HintStr);

    if HintStr <> '' then
    begin
      R := CellRect(FPendingHintCell.X, FPendingHintCell.Y);
      HintRect := Rect(R.Right + 2, R.Top, R.Right + 2, R.Top); // ширина автоматически подбирается
      HintRect := ClientToScreen(HintRect);
      FHintWindow.ActivateHint(HintRect, HintStr);
    end
    else
      FHintWindow.ReleaseHandle;
  end;
end;

function TEditableStringGrid.CheckStateToStr(State: Integer): string;
begin
  case State of
    1:
      Result := FTrueValue;   // Проверено
    0:
      Result := FFalseValue;  // Не проверено
    2:
      Result := FNullValue;   // Полузаполнено
  else
    Result := ''; // Для недопустимых значений
  end;
end;

procedure TEditableStringGrid.BeginEditCell(ACol, ARow: Integer);
var
  EditorType: TGridEditorType;
begin
  if (ACol < FixedCols) or (ARow < FixedRows) then
    Exit;

  FEditCol := ACol;
  FEditRow := ARow;

  FOriginalValue := Cells[ACol, ARow];
  FEditing := True;

  if (Length(FColEditors) > ACol) and (FColEditors[ACol] <> geNone) then
    EditorType := FColEditors[ACol]
  else
    EditorType := geEdit;

  if Assigned(FOnGetEditor) then
    FOnGetEditor(Self, ACol, ARow, EditorType);

  ShowEditor(ACol, ARow, EditorType);
end;

procedure TEditableStringGrid.ShowEditor(ACol, ARow: Integer; EditorType: TGridEditorType);
var
  R: TRect;
  Edit: TEdit;
  Combo: TComboBox;
  BtnEdit: TButtonedEdit;
begin
  HideEditor;
  if EditorType = geNone then
    Exit;

  R := CellRect(ACol, ARow);

  case EditorType of
    geEdit:
      begin
        Edit := TGridEdit.Create(Self);
        Edit.Parent := Self;
        Edit.SetBounds(R.Left + 1, R.Top + 1, R.Width - 2, R.Height - 2);
        Edit.Text := Cells[ACol, ARow];
        Edit.OnExit := EditorExit;
        FEditor := Edit;

        if Assigned(FOnSetupEditor) then
          FOnSetupEditor(Self, ACol, ARow, FEditor);

        Edit.SetFocus;
        Edit.SelectAll;
      end;

    geComboBox:
      begin
        Combo := TComboBox.Create(Self);
        Combo.Parent := Self;
        Combo.Style := csDropDownList;
        Combo.SetBounds(R.Left + 1, R.Top + 1, R.Width - 2, R.Height - 2);

        if Assigned(FOnGetComboItems) then
          FOnGetComboItems(Self, ACol, ARow, Combo.Items);

        Combo.ItemIndex := Combo.Items.IndexOf(Cells[ACol, ARow]);

        Combo.OnCloseUp := ComboBoxCloseUp;
        Combo.OnExit := EditorExit;
        FEditor := Combo;

        if Assigned(FOnSetupEditor) then
          FOnSetupEditor(Self, ACol, ARow, FEditor);

        Combo.SetFocus
      end;

    geButtonedEdit:
      begin
        BtnEdit := TGridButtonedEdit.Create(Self);
        BtnEdit.Parent := Self;
        BtnEdit.SetBounds(R.Left + 1, R.Top + 1, R.Width - 2, R.Height - 2);
        BtnEdit.Text := Cells[ACol, ARow];
        BtnEdit.RightButton.Visible := True;
        BtnEdit.OnExit := EditorExit;
        BtnEdit.OnRightButtonClick := ButtonClick;
        FEditor := BtnEdit;

        if Assigned(FOnSetupEditor) then
          FOnSetupEditor(Self, ACol, ARow, FEditor);

        BtnEdit.SetFocus;
        BtnEdit.SelectAll;
      end;

  end;
end;

procedure TEditableStringGrid.HideEditor;
var
  Editor: TWinControl;
begin
  Editor := FEditor;
  FEditor := nil;

  if Assigned(Editor) then
    Editor.Free;
end;

procedure TEditableStringGrid.ButtonClick(Sender: TObject);
begin
  if Assigned(FOnButtonClick) then
    FOnButtonClick(Self, FEditCol, FEditRow);
end;

procedure TEditableStringGrid.GridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  if GetEditorType(ACol, ARow) <> geCheckBox then
    BeginEditCell(ACol, ARow);
end;

procedure TEditableStringGrid.AdjustColWidth(ACol: Integer);
var
  MaxW, i, W: Integer;
begin
  if not FAutoColWidth then
    Exit;

  MaxW := 0;
  for i := 0 to RowCount - 1 do
  begin
    W := Canvas.TextWidth(Cells[ACol, i]) + 10;
    if W > MaxW then
      MaxW := W;
  end;

  if FMaxColWidth > 0 then
    MaxW := Min(MaxW, FMaxColWidth);
  if FMinColWidth > 0 then
    MaxW := Max(MaxW, FMinColWidth);

  ColWidths[ACol] := MaxW;
end;

procedure TEditableStringGrid.AdjustAllCols;
var
  c: Integer;
begin
  if not FAutoColWidth then
    Exit;
  for c := 0 to ColCount - 1 do
    AdjustColWidth(c);
end;

procedure TEditableStringGrid.SetCellText(ACol, ARow: Integer; const Value: string);
begin
  Cells[ACol, ARow] := Value;
  if FAutoColWidth then
    AdjustColWidth(ACol);
end;

procedure TEditableStringGrid.SetColEditor(ACol: Integer; EditorType: TGridEditorType);
begin
  if Length(FColEditors) <= ACol then
    SetLength(FColEditors, ACol + 1);
  FColEditors[ACol] := EditorType;
end;

function TEditableStringGrid.GetActiveEditor(ACol, ARow: Integer): TWinControl;
begin
  if Assigned(FEditor) and (ACol = FEditCol) and (ARow = FEditRow) then
    Result := FEditor
  else
    Result := nil;
end;

function TEditableStringGrid.GetCheckState(const S: string): Integer;
begin
  if SameText(S, FTrueValue) then
    Result := 1
  else if SameText(S, FFalseValue) then
    Result := 0
  else if SameText(S, FNullValue) then
    Result := 2
  else
    Result := -1; // Для недопустимых значений
end;

function TEditableStringGrid.GetEditorType(ACol, ARow: Integer): TGridEditorType;
begin
  Result := geEdit;
  if Length(FColEditors) > ACol then
    Result := FColEditors[ACol];
  if Assigned(FOnGetEditor) then
    FOnGetEditor(Self, ACol, ARow, Result);
end;

procedure TEditableStringGrid.SetAutoColWidth(const Value: Boolean);
begin
  if FAutoColWidth <> Value then
  begin
    FAutoColWidth := Value;
    if FAutoColWidth then
      PostMessage(Self.Handle, WM_USER + 1, 0, 0);
  end;
end;

procedure TEditableStringGrid.WMAdjustCols(var Msg: TMessage);
begin
  AdjustAllCols;
end;

procedure TEditableStringGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LCol, LRow: Longint;
begin
  inherited;
  MouseToCell(X, Y, LCol, LRow);

  if (LCol < FixedCols) or (LRow < FixedRows) or (LCol >= ColCount) or (LRow >= RowCount) or not PtInRect(CellRect(LCol,
    LRow), Point(X, Y)) then
  begin
    FHintTimer.Enabled := False;
    FHintWindow.ReleaseHandle;
    Exit;
  end;

  if (LCol = FLastHintCell.X) and (LRow = FLastHintCell.Y) then
    Exit;

  FLastHintCell := Point(LCol, LRow);
  FHintWindow.ReleaseHandle;

  FPendingHintCell := FLastHintCell;

  if Assigned(FOnCellHint) then
  begin
    FHintTimer.Interval := FCellHintDelay;
    FHintTimer.Enabled := True;
  end;

  if (LCol <> FHoverCell.X) or (LRow <> FHoverCell.Y) then
  begin
    InvalidateCell(FHoverCell.X, FHoverCell.Y);
    FHoverCell := Point(LCol, LRow);
    InvalidateCell(LCol, LRow);
  end;
end;

function TEditableStringGrid.NextCheckState(State: Integer): Integer;
begin
  case State of
    0:
      Result := 1;
    1:
      if FAllowGrayed then
        Result := 2
      else
        Result := 0;
    2:
      Result := 0;
  else
    Result := 0;
  end;
end;

procedure TEditableStringGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Col, Row: Longint;
  EditorType: TGridEditorType;
  State: Integer;
begin
  FSmoothOffsetY := 0;
  inherited;

  MouseToCell(X, Y, Col, Row);
  if (Col < FixedCols) or (Row < FixedRows) then
    Exit;

  EditorType := geEdit;
  if (Length(FColEditors) > Col) then
    EditorType := FColEditors[Col];

  if Assigned(FOnGetEditor) then
    FOnGetEditor(Self, Col, Row, EditorType);

  if GetEditorType(Col, Row) = geCheckBox then
  begin
    State := GetCheckState(Cells[Col, Row]);
    if State < 0 then
      State := 0;

    Cells[Col, Row] := CheckStateToStr(NextCheckState(State));
    InvalidateCell(Col, Row);
    Exit;
  end;

end;

procedure TEditableStringGrid.DrawCell(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState);
var
  State: Integer;
  CheckRect: TRect;
  Flags: UINT;
begin
  if (ACol < FixedCols) or (ARow < FixedRows) then
  begin
    inherited;
    Exit;
  end;

  if GetEditorType(ACol, ARow) <> geCheckBox then
  begin
    inherited;
    Exit;
  end;
  // Фон
  if gdSelected in AState then
    Canvas.Brush.Color := clHighlight
  else if (ACol = FHoverCell.X) and (ARow = FHoverCell.Y) then
    Canvas.Brush.Color := $00FFE8D0
  else
    Canvas.Brush.Color := Color;

  Canvas.FillRect(ARect);

  State := GetCheckState(Cells[ACol, ARow]);
  if State < 0 then
    State := 0;

  CheckRect := ARect;
  InflateRect(CheckRect, -4, -4);
  CheckRect.Left := CheckRect.Left + (CheckRect.Width - 16) div 2;
  CheckRect.Top := CheckRect.Top + (CheckRect.Height - 16) div 2;
  CheckRect.Right := CheckRect.Left + 16;
  CheckRect.Bottom := CheckRect.Top + 16;

  Flags := DFCS_BUTTONCHECK;
  case State of
    1:
      Flags := Flags or DFCS_CHECKED;
    2:
      if FAllowGrayed then
        Flags := Flags or DFCS_BUTTON3STATE or DFCS_CHECKED;
  end;

  DrawFrameControl(Canvas.Handle, CheckRect, DFC_BUTTON, Flags);
end;

procedure TEditableStringGrid.KeyDown(var Key: Word; Shift: TShiftState);
var
  State: Integer;
begin
  if GetEditorType(Col, Row) = geCheckBox then
  begin
    if Key in [VK_SPACE, VK_RETURN] then
    begin
      State := GetCheckState(Cells[Col, Row]);
      if State < 0 then
        State := 0;

      Cells[Col, Row] := CheckStateToStr(NextCheckState(State));
      InvalidateCell(Col, Row);
      Key := 0;
      Exit;
    end;
  end
  else
  begin
    if (Key >= 32) and (Key <= 255) then
      BeginEditCell(Col, Row);
  end;
  FSmoothOffsetY := 0;
  inherited;
end;

procedure TEditableStringGrid.AcceptEdit;
begin
  if not FEditing then
    Exit;

  if FEditor is TEdit then
    Cells[FEditCol, FEditRow] := TEdit(FEditor).Text
  else if FEditor is TComboBox then
    Cells[FEditCol, FEditRow] := TComboBox(FEditor).Text
  else if FEditor is TMemo then
    Cells[FEditCol, FEditRow] := TMemo(FEditor).Lines.Text;

  FEditing := False;
  PostMessage(Handle, WM_CLOSE_EDITOR, 0, 0);
  if FAutoColWidth then
    AdjustColWidth(FEditCol);
end;

procedure TEditableStringGrid.CancelEdit;
begin
  if not FEditing then
    Exit;

  Cells[FEditCol, FEditRow] := FOriginalValue;
  FEditing := False;
  PostMessage(Handle, WM_CLOSE_EDITOR, 0, 0);
end;

procedure TEditableStringGrid.WMCloseEditor(var Msg: TMessage);
begin
  HideEditor;
end;

procedure TGridButtonedEdit.WMKeyDown(var Msg: TWMKeyDown);
begin
  if Msg.CharCode = VK_RETURN then
  begin
    Msg.Result := 0;
    (Owner as TEditableStringGrid).AcceptEdit;
  end
  else if Msg.CharCode = VK_ESCAPE then
  begin
    Msg.Result := 0;
    (Owner as TEditableStringGrid).CancelEdit;
  end
  else
    inherited;
end;

procedure TEditableStringGrid.EditorExit(Sender: TObject);
begin
  if Sender is TComboBox then
  begin
    if TComboBox(Sender).Text <> '' then
      Cells[FEditCol, FEditRow] := TComboBox(Sender).Text
    else
      Cells[FEditCol, FEditRow] := FOriginalValue;
  end
  else if Sender is TGridEdit then
  begin
    Cells[FEditCol, FEditRow] := TGridEdit(Sender).Text;
  end
  else if Sender is TGridButtonedEdit then
  begin
    Cells[FEditCol, FEditRow] := TGridButtonedEdit(Sender).Text;
  end;
  AcceptEdit;
  HideEditor;
end;

{ TGridEdit }

procedure TGridEdit.WMKeyDown(var Msg: TWMKeyDown);
begin
  if Msg.CharCode = VK_RETURN then
  begin
    Msg.Result := 0;
    (Owner as TEditableStringGrid).AcceptEdit;
  end
  else if Msg.CharCode = VK_ESCAPE then
  begin
    Msg.Result := 0;
    (Owner as TEditableStringGrid).CancelEdit;
  end
  else
    inherited;
end;

procedure TEditableStringGrid.ComboBoxCloseUp(Sender: TObject);
begin
  if Sender is TComboBox then
  begin
     if TComboBox(Sender).ItemIndex >= 0 then
      Cells[FEditCol, FEditRow] := TComboBox(Sender).Text
    else
      Cells[FEditCol, FEditRow] := '';

     HideEditor;
  end;
end;

procedure TEditableStringGrid.WMMouseWheel(var Msg: TWMMouseWheel);
var
  Delta: Integer;
begin
  Delta := Msg.WheelDelta div WHEEL_DELTA;
  FSmoothOffsetY := FSmoothOffsetY + Delta * FSmoothScrollStep;
  while Abs(FSmoothOffsetY) >= DefaultRowHeight do
  begin
    if FSmoothOffsetY > 0 then
    begin
      if TopRow > FixedRows then
        TopRow := TopRow - 1;
      FSmoothOffsetY := FSmoothOffsetY - DefaultRowHeight;
    end
    else
    begin
      if TopRow < RowCount - VisibleRowCount then
        TopRow := TopRow + 1;
      FSmoothOffsetY := FSmoothOffsetY + DefaultRowHeight;
    end;
  end;
  ScrollWindowEx(Handle, 0, FSmoothOffsetY, nil, nil, 0, nil, SW_INVALIDATE or SW_ERASE);

  Msg.Result := 1;
end;

procedure TEditableStringGrid.WMVScroll(var Msg: TWMVScroll);
begin
  FSmoothOffsetY := 0;
  inherited;
end;

end.

