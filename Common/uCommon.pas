unit uCommon;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, System.TypInfo, System.NetEncoding, System.Zip, System.ZLib;

const
  MaxSet = 255;
  BitsPerByte = 8;
  ByteBoundaryMask =not  ( BitsPerByte - 1);
  WhiteSpace =[ #0.. ' '];
  Alphabetic =[ 'a'.. 'z',  'A'.. 'Z',  '_'];
  Digits =[ '0'.. '9'];
  HexDigits =[ 'a'.. 'f',  'A'.. 'F'] + Digits;
  CharBegin =[ '#',  ''''];
  AsciiChars =[ ' '.. '~']; // Printable ASCII characters.
  AlphaNumeric = Alphabetic + Digits;
 // DBMS_IDs: array of string = ['MSSQL', 'FB'];
 // DBMS_Names: array of string = ['MS SQL Server', 'Firebird'];

type
  TSet = set of 0..MaxSet;

type
  TDBConnectionParams = record
    DriverName: string;
    Server: string;
    Database: string;
    UserName: string;
    Password: string;
    OSAuth: Boolean;
    Encrypt: Boolean;
  end;

procedure MsgError(const AMsg: string);

procedure MsgWarning(const AMsg: string);

procedure MsgInformation(const AMsg: string);

function MsgConfirmation(const AMsg: string): Boolean;

function MsgConfirmation_YNC(const AMsg: string): Byte;

function MsgConfirmation_YNCAN(const AMsg: string): Integer;

{  Label1.Caption := OrdToString(TypeInfo(T_DBMS), 0);}

function OrdToString(Info: PTypeInfo; Value: Integer): string;

{  Label1.Caption := SetToString(TypeInfo(T_DBMS), FF, ', ', '[', ']');}

function SetToString(Info: PTypeInfo; const Value; const Separator, Prefix, Suffix: string): string;

procedure StringToCharSet(const Str: string; CompData: PTypeData; var Value: TSet);

procedure StringToEnumSet(const Str: string; CompInfo: PTypeInfo; CompData: PTypeData; var Value: TSet);

procedure SkipWhiteSpace(const Str: string; var I: Integer);

procedure StringToStream(const AString: string; AStream: TStream);

function StringFromStream(AStream: TStream): string;

function StreamToBase64String(AStream: TStream): string;

procedure Base64StringToStream(Base64String: string; AStream: TStream);

procedure SaveStreamAsZip(SourceStream: TStream; const ZipFileName: string; const InternalFileName: string = 'data.bin');

function QuickCompressString(const Data: string): TBytes;
procedure DecompressStream(CompressedStream, OutputStream: TStream);

resourcestring
  sNotASet = 'SetToString: argument must be a set type; %s not allowed';
  sCvtError = 'OrdToString: type kind must be ordinal, not %s';
  sInvalidSetString = 'StringToSet: %s not a valid literal for the set type';
  sOutOfRange = 'StringToSet: %0:d is out of range [%1:d..%2:d]';
  sNotAChar = 'StringToSet: Not a valid character (%.10s)';
  sCharOutOfRange = 'StringToSet: Character #%0:d is out of range [#%1:d..#%2:d]';

implementation

procedure DecompressStream(CompressedStream, OutputStream: TStream);
var
  DecompressionStream: TZDecompressionStream;
  Buffer: array[0..4095] of Byte;
  BytesRead: Integer;
begin
  CompressedStream.Position := 0;
  OutputStream.Position := 0;

  DecompressionStream := TZDecompressionStream.Create(CompressedStream);
  try
    repeat
      BytesRead := DecompressionStream.Read(Buffer, SizeOf(Buffer));
      if BytesRead > 0 then
        OutputStream.WriteBuffer(Buffer, BytesRead);
    until BytesRead = 0;
  finally
    DecompressionStream.Free;
  end;

  OutputStream.Position := 0;
end;

function QuickCompressString(const Data: string): TBytes;
var
  InputStream, OutputStream: TMemoryStream;
  CompressionStream: TZCompressionStream;
begin
  InputStream := TMemoryStream.Create;
  OutputStream := TMemoryStream.Create;
  try
    InputStream.WriteBuffer(PChar(Data)^, Length(Data) * SizeOf(Char));
    InputStream.Position := 0;
    CompressionStream := TZCompressionStream.Create(clFastest, OutputStream);
    try
      CompressionStream.CopyFrom(InputStream, 0);
    finally
      CompressionStream.Free;
    end;
    SetLength(Result, OutputStream.Size);
    OutputStream.Position := 0;
    OutputStream.ReadBuffer(Result[0], OutputStream.Size);
  finally
    InputStream.Free;
    OutputStream.Free;
  end;
end;

procedure SaveStreamAsZip(SourceStream: TStream; const ZipFileName: string; const InternalFileName: string = 'data.bin');
var
  ZipFile: TZipFile;
begin
  ZipFile := TZipFile.Create;
  try
    ZipFile.Open(ZipFileName, zmWrite);
    SourceStream.Position := 0;
    ZipFile.Add(SourceStream, InternalFileName, TZipCompression.zcDeflate);

    ZipFile.Close;
  finally
    ZipFile.Free;
  end;
end;

procedure StringToStream(const AString: string; AStream: TStream);
var
  Writer: TStreamWriter;
  Str: string;
begin
  AStream.Position := 0;
  Writer := TStreamWriter.Create(AStream);
  try
    Writer.Write(AString);
  finally
    Writer.Free;
  end;
  AStream.Position := 0;
end;

function StringFromStream(AStream: TStream): string;
var
  Reader: TStreamReader;
begin
  AStream.Position := 0;
  Reader := TStreamReader.Create(AStream);
  try
    Result := Reader.ReadToEnd;
  finally
    Reader.Free;
  end;
end;

function StreamToBase64String(AStream: TStream): string;
var
  Bytes: TBytes;
begin
  Result := '';
  if not Assigned(AStream) then
    Exit;
  if AStream.Size = 0 then
    Exit;

  AStream.Position := 0;
  SetLength(Bytes, AStream.Size);
  AStream.ReadBuffer(Bytes, AStream.Size);

  Result := TNetEncoding.Base64.EncodeBytesToString(Bytes);
end;

procedure Base64StringToStream(Base64String: string; AStream: TStream);
var
  Bytes: TBytes;
begin
  if Base64String = '' then
    Exit;
  Bytes := TNetEncoding.Base64.DecodeStringToBytes(Base64String);
  AStream.WriteBuffer(Bytes[0], Length(Bytes));
  AStream.Position := 0;
end;

function SetToString(Info: PTypeInfo; const Value; const Separator, Prefix, Suffix: string): string;
var
  CompInfo: PTypeInfo;
  CompData: PTypeData;
  SetValue: TSet absolute Value;
  Element: 0..MaxSet;
  MinElement: 0..MaxSet;
begin
  if Info.Kind <> tkSet then
    raise EConvertError.CreateFmt(sNotASet, [GetEnumName(TypeInfo(TTypeKind), Ord(Info.Kind))]);
  CompInfo := GetTypeData(Info)^.CompType^;
  CompData := GetTypeData(CompInfo);
  Result := '';
  MinElement := CompData.MinValue and ByteBoundaryMask;
  for Element := CompData.MinValue to CompData.MaxValue do
  begin
    if (Element - MinElement) in SetValue then
      if Result = '' then
        Result := Prefix + OrdToString(CompInfo, Element)
      else
        Result := Result + Separator + OrdToString(CompInfo, Element);
  end;
  if Result = '' then
    Result := Prefix + Suffix
  else
    Result := Result + Suffix;
end;

function OrdToString(Info: PTypeInfo; Value: Integer): string;
const
  AsciiChars =[ 32.. 127]; // Printable ASCII characters.
begin
  case Info.Kind of
    tkInteger:
      Result := IntToStr(Value);
    tkChar, tkWChar:
      if Value in AsciiChars then
        Result := '''' + Chr(Value) + ''''
      else
        Result := Format('#%d', [Value]);
    tkEnumeration:
      Result := GetEnumName(Info, Value);
  else
    raise EConvertError.CreateFmt(sCvtError, [GetEnumName(TypeInfo(TTypeKind), Ord(Info.Kind))]);
  end;
end;

procedure SkipWhiteSpace(const Str: string; var I: Integer);
begin
  while (I <= Length(Str)) and CharInSet(Str[I], WhiteSpace) do
    Inc(I);
end;

procedure StringToEnumSet(const Str: string; CompInfo: PTypeInfo; CompData: PTypeData; var Value: TSet);
var
  ElementName: string;
  Element: Integer;
  MinElement: Integer;
  Start: Integer;
  I: Integer;
begin
  MinElement := CompData.MinValue and ByteBoundaryMask;
  I := 1;
  while I <= Length(Str) do
  begin
    SkipWhiteSpace(Str, I);
    if (I <= Length(Str)) and not (Str[I] in AlphaNumeric) then
      Inc(I);
    SkipWhiteSpace(Str, I);
    Start := I;
    while (I <= Length(Str)) and (Str[I] in AlphaNumeric) do
      Inc(I);
    if I = Start then
      Continue;
    ElementName := Copy(Str, Start, I - Start);
    Element := GetEnumValue(CompInfo, ElementName);
    if Element < 0 then
      raise EConvertError.CreateFmt(sInvalidSetString, [AnsiQuotedStr(ElementName, '''')]);
    if (Element < CompData.MinValue) or (Element > CompData.MaxValue) then
      raise EConvertError.CreateFmt(sOutOfRange, [Element, CompData.MinValue, CompData.MaxValue]);
    Include(Value, Element - MinElement);
  end;
end;

procedure StringToSet(const Str: string; Info: PTypeInfo; var Value);
var
  CompInfo: PTypeInfo;
  CompData: PTypeData;
  SetValue: TSet absolute Value;
  MinValue, MaxValue: Integer;
begin
  if Info.Kind <> tkSet then
    raise EConvertError.CreateFmt(sNotASet, [GetEnumName(TypeInfo(TTypeKind), Ord(Info.Kind))]);
  CompInfo := GetTypeData(Info)^.CompType^;
  CompData := GetTypeData(CompInfo);
  MinValue := CompData.MinValue and ByteBoundaryMask;
  MaxValue := (CompData.MaxValue + BitsPerByte - 1) and ByteBoundaryMask;
  FillChar(SetValue, (MaxValue - MinValue) div BitsPerByte, 0);
  if CompInfo.Kind in [tkChar, tkWChar] then
    StringToCharSet(Str, CompData, SetValue)
  else
    StringToEnumSet(Str, CompInfo, CompData, SetValue);
end;

procedure StringToCharSet(const Str: string; CompData: PTypeData; var Value: TSet);
var
  ElementName: string;
  Element: Integer;
  MinElement: Integer;
  Start: Integer;
  I: Integer;
begin
  MinElement := CompData.MinValue and ByteBoundaryMask;
  I := 1;
  while I <= Length(Str) do
  begin
    SkipWhiteSpace(Str, I);
    // Skip over one character, which might be the prefix,
    // a separator, or suffix.
    if (I <= Length(Str)) and not (Str[I] in CharBegin) then
      Inc(I);
    SkipWhiteSpace(Str, I);
    if I > Length(Str) then
      Break;
    case Str[I] of
      '#':
        begin
          // Character is specified by ordinal value,
          // e.g. #31 or #$A2.
          Inc(I);
          Start := I;
          if (I < Length(Str)) and (Str[I] = '$') then
          begin
            Inc(I);
            while (I <= Length(Str)) and (Str[I] in HexDigits) do
              Inc(I);
          end
          else
          begin
            while (I <= Length(Str)) and (Str[I] in Digits) do
              Inc(I);
          end;
          ElementName := Copy(Str, Start, I - Start);
          Element := StrToInt(ElementName);
        end;
      '''':
        begin
          // Character is enclosed in quotes, e.g. 'A'.
          Start := I; // Save position for error messages.
          Inc(I);
          if (I <= Length(Str)) then
          begin
            Element := Ord(Str[I]);
            if Str[I] = '''' then
              // Skip over a repeated quote character.
              Inc(I);
            // Skip to the closing quote.
            Inc(I);
          end;
          if (I <= Length(Str)) and (Str[I] = '''') then
            Inc(I)
          else
            raise EConvertError.CreateFmt(sNotAChar, [Copy(Str, Start, I - Start)]);
        end;
    else
        // The unknown character might be the suffix. Try
         // skipping it and subsequent white space. Save the
        // original index in case the suffix-test fails.
      Start := I;
      Inc(I);
      SkipWhiteSpace(Str, I);
      if I <= Length(Str) then
        raise EConvertError.CreateFmt(sNotAChar, [Copy(Str, Start, I - Start)])
      else
        Exit;
    end;
    if (Element < CompData.MinValue) or (Element > CompData.MaxValue) then
      raise EConvertError.CreateFmt(sCharOutOfRange, [Element, CompData.MinValue, CompData.MaxValue]);
    Include(Value, Element - MinElement);
  end;
end;

procedure MsgError(const AMsg: string);
begin
  Application.MessageBox(PChar(AMsg), 'Ошибка', MB_OK + MB_ICONERROR);
end;

procedure MsgWarning(const AMsg: string);
begin
  Application.MessageBox(PChar(AMsg), 'Предупреждение', MB_OK + MB_ICONWARNING);
end;

procedure MsgInformation(const AMsg: string);
begin
  Application.MessageBox(PChar(AMsg), 'Информация', MB_OK + MB_ICONINFORMATION);
end;

function MsgConfirmation(const AMsg: string): Boolean;
begin
  result := False;
  if Application.MessageBox(PChar(AMsg), 'Подтвердите', MB_YESNO + MB_ICONQUESTION) = ID_YES then
    result := True;
end;

function MsgConfirmation_YNC(const AMsg: string): Byte;
begin
  // 0=ID_CANCEL
  // 1=ID_YES
  // 2=ID_NO
  case Application.MessageBox(PChar(AMsg), 'Подтвердите', MB_YESNOCANCEL + MB_ICONQUESTION) of
    ID_CANCEL:
      result := 0;
    ID_YES:
      result := 1;
    ID_NO:
      result := 2;
  else
    result := 0;
  end;
end;

function MsgConfirmation_YNCAN(const AMsg: string): Integer;
begin
  result := MessageDlg(PChar(AMsg), mtConfirmation, [mbYes, mbYesToAll, mbNo, mbNoToAll, mbCancel, mbNoToAll], 0)
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.

