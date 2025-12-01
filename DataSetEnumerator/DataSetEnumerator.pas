unit DataSetEnumerator;

interface

uses
  Data.DB, System.SysUtils, System.Generics.Collections;

type
  TDataSetEnumerator = class
  private
    FDataSet: TDataSet;
    FStarted: Boolean;
  public
    constructor Create(ADataSet: TDataSet);
    function GetCurrent: TDataSet;
    function MoveNext: Boolean;
    property Current: TDataSet read GetCurrent;

    function GetEnumerator: TDataSetEnumerator;
  end;

  TGenericDataSetEnumerator<T> = class
  private
    FDataSet: TDataSet;
    FTransformFunc: TFunc<TDataSet, T>;
    FCurrent: T;
    FEnumerator: TDataSetEnumerator;
  public
    constructor Create(ADataSet: TDataSet; ATransformFunc: TFunc<TDataSet, T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    property Current: T read GetCurrent;

    function GetEnumerator: TGenericDataSetEnumerator<T>;
  end;

  TBatchDataSetEnumerator = class
  private
    FDataSet: TDataSet;
    FBatchSize: Integer;
    FCurrentBatch: TList<TDataSet>;
    FEnumerator: TDataSetEnumerator;
  public
    constructor Create(ADataSet: TDataSet; ABatchSize: Integer);
    destructor Destroy; override;
    function GetCurrent: TList<TDataSet>;
    function MoveNext: Boolean;
    property Current: TList<TDataSet> read GetCurrent;

    function GetEnumerator: TBatchDataSetEnumerator;
  end;

  TDataSetEnumeratorHelper = class helper for TDataSet
  public
    function GetEnumerator: TDataSetEnumerator;
    function Map<T>(ATransformFunc: TFunc<TDataSet, T>): TGenericDataSetEnumerator<T>;
    function Batch(ABatchSize: Integer): TBatchDataSetEnumerator;
  end;

implementation

{ TDataSetEnumerator }

constructor TDataSetEnumerator.Create(ADataSet: TDataSet);
begin
  inherited Create;
  FDataSet := ADataSet;
  FStarted := False;
end;

function TDataSetEnumerator.GetCurrent: TDataSet;
begin
  Result := FDataSet;
end;

function TDataSetEnumerator.MoveNext: Boolean;
begin
  if not FStarted then
  begin
    // Первый вызов - начинаем итерацию
    FStarted := True;
    FDataSet.First;
  end
  else
  begin
    // Последующие вызовы - следующая запись
    FDataSet.Next;
  end;

  Result := not FDataSet.EOF;
end;

function TDataSetEnumerator.GetEnumerator: TDataSetEnumerator;
begin
  Result := Self;
end;

{ TGenericDataSetEnumerator<T> }

constructor TGenericDataSetEnumerator<T>.Create(ADataSet: TDataSet;
  ATransformFunc: TFunc<TDataSet, T>);
begin
  inherited Create;
  FDataSet := ADataSet;
  FTransformFunc := ATransformFunc;
  FEnumerator := TDataSetEnumerator.Create(FDataSet);
end;

destructor TGenericDataSetEnumerator<T>.Destroy;
begin
  FEnumerator.Free;
  inherited;
end;

function TGenericDataSetEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TGenericDataSetEnumerator<T>.MoveNext: Boolean;
begin
  Result := FEnumerator.MoveNext;
  if Result then
    FCurrent := FTransformFunc(FDataSet);
end;

function TGenericDataSetEnumerator<T>.GetEnumerator: TGenericDataSetEnumerator<T>;
begin
  Result := Self;
end;

{ TBatchDataSetEnumerator }

constructor TBatchDataSetEnumerator.Create(ADataSet: TDataSet; ABatchSize: Integer);
begin
  inherited Create;
  FDataSet := ADataSet;
  FBatchSize := ABatchSize;
  FCurrentBatch := TList<TDataSet>.Create;
  FEnumerator := TDataSetEnumerator.Create(FDataSet);
end;

destructor TBatchDataSetEnumerator.Destroy;
begin
  FCurrentBatch.Free;
  FEnumerator.Free;
  inherited;
end;

function TBatchDataSetEnumerator.GetCurrent: TList<TDataSet>;
begin
  Result := FCurrentBatch;
end;

function TBatchDataSetEnumerator.MoveNext: Boolean;
var
  I: Integer;
begin
  FCurrentBatch.Clear;
  I := 0;

  while (I < FBatchSize) and FEnumerator.MoveNext do
  begin
    FCurrentBatch.Add(FDataSet);
    Inc(I);
  end;

  Result := FCurrentBatch.Count > 0;
end;

function TBatchDataSetEnumerator.GetEnumerator: TBatchDataSetEnumerator;
begin
  Result := Self;
end;

{ TDataSetEnumeratorHelper }

function TDataSetEnumeratorHelper.GetEnumerator: TDataSetEnumerator;
begin
  Result := TDataSetEnumerator.Create(Self);
end;

function TDataSetEnumeratorHelper.Map<T>(ATransformFunc: TFunc<TDataSet, T>): TGenericDataSetEnumerator<T>;
begin
  Result := TGenericDataSetEnumerator<T>.Create(Self, ATransformFunc);
end;

function TDataSetEnumeratorHelper.Batch(ABatchSize: Integer): TBatchDataSetEnumerator;
begin
  Result := TBatchDataSetEnumerator.Create(Self, ABatchSize);
end;

end.
