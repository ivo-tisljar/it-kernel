//
// unit itSystem, v2022-07, copyright 2022 by Ivo Tišljar

unit itSystem;

interface

uses
  ShellApi,
  Winapi.Windows,
  System.Classes, System.StrUtils, System.SysUtils,
  VCL.Clipbrd;


const
  CrLf = #13#10;
  Tab = #9;


// conversionError

type
  EitSystemConversionError = class (Exception)
  end;


procedure ConvertPngToJpeg (const PngFileName, JpegFileName: String);

function  IfInt (const Test: boolean; const i1: integer): integer; overload;
function  IfInt (const Test: boolean; const i1, i2: integer): integer; overload;
function  IfStr (const Test: boolean; const s1: string): string; overload;
function  IfStr (const Test: boolean; const s1, s2: string): string; overload;

procedure OpenFileInDefaultBrowser (const Handle:HWND; const FileName: string);
procedure OpenFileInEdge (const Handle:HWND; const FileName: string);
procedure OpenFileInNotepadPlusPlus (const Handle:HWND; const FileName: string);

procedure StripBOMFromUtf8File (const FileName:string);


// example function with parameters with default values

function  LeftPad (value:integer; length:integer=2; pad:char='0'): string; overload;


implementation

uses
  Vcl.Imaging.Jpeg, Vcl.Imaging.PngImage, Vcl.Graphics;


procedure ConvertPngToJpeg (const PngFileName, JpegFileName: String);

var
  PngImage: TPngImage;
  BmpImage: TBitmap;
  JpegImage: TJpegImage;

begin
  PngImage := TPngImage.Create;
  BmpImage := TBitmap.Create;
  JpegImage := TJpegImage.Create;

  try
    PngImage.LoadFromFile (PngFileName);
    BmpImage.Width := PngImage.Width;
    BmpImage.Height := PngImage.Height;
    PngImage.Draw (BmpImage.Canvas, BmpImage.Canvas.ClipRect);
    JpegImage.Assign (BmpImage);
    JpegImage.SaveToFile (JpegFileName);
  finally
    FreeAndNil (JpegImage);
    FreeAndNil (BmpImage);
    FreeAndNil (PngImage);
  end;
end;


// returns integer when test is true, 0 if test is false

function IfInt (const Test: boolean; const i1: integer): integer;

begin
  if Test then
    Result := i1
  else
    Result := 0;
end;


// returns one of two integers depending on test

function IfInt (const Test: boolean; const i1, i2: integer): integer;
begin
  if Test then
    Result := i1
  else
    Result := i2;
end;


// returns string when test is true

function IfStr (const Test: boolean; const s1: string): string;
begin
  if Test then
    Result := s1
  else
    Result := '';
end;


// returns one of two strings depending on test

function IfStr (const Test: boolean; const s1, s2: string): string;
begin
  if Test then
    Result := s1
  else
    Result := s2;
end;


procedure OpenFileInDefaultBrowser (const Handle:HWND; const FileName: string);   // (window) form handle, file name (directory included)
begin
  ShellExecute (Handle, 'open', PChar (FileName), '', nil, sw_ShowNormal);
end;


// start Edge and opens file, if file is already open in Edge creates new tab with the file

procedure OpenFileInEdge (const Handle:HWND; const FileName: string);   // (window) form handle, file name (directory included)
begin
  ShellExecute (Handle, 'open', Pchar ('"shell:Appsfolder\Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge"'),
               Pchar ('"""' + FileName + '"""'), nil, sw_ShowNormal);
end;


// start Notepad++ and opens file, if file is already open in Notepad++ activate tab with a file and ask for reload if file was changed

procedure OpenFileInNotepadPlusPlus (const Handle:HWND; const FileName: string);    // (window) form handle, file name (directory included)
begin
  ShellExecute (Handle, 'open', Pchar ('"C:\Program Files (x86)\Notepad++\notepad++.exe"'),
               Pchar ('"' + FileName + '"'), nil, sw_ShowNormal);
end;


// skip BOM header and copy rest of the file, raise exception if no BOM header found

procedure SkipBOMAndCopyRestOfTheFile (var InputFile, TempFile: TFileStream; const FileName: string);
var
  FileHeader: AnsiString;
const
  Utf8BomHeader: AnsiString = #$EF#$BB#$BF;   // UTF-8 BOM header

begin
  InputFile.Read(FileHeader, 3);              // read 3 bytes

  if FileHeader <> Utf8BomHeader then
    raise EitSystemConversionError.Create('Invalid UTF-8 BOM header!' + CrLf + CrLf + 'File: ' + FileName);

  InputFile.Seek(Length(Utf8BomHeader), soFromBeginning);   // move file pointer behind BOM header
  TempFile := TFileStream.Create(FileName + '.~temp', fmCreate);
  TempFile.CopyFrom(InputFile, InputFile.Size - Length(Utf8BomHeader));
end;


// remove BOM header from UTF-8 BOM files and makes it a proper UTF-8 file

procedure StripBOMFromUtf8File (const FileName: string);          // file name (directory included)
var
  InputFile, TempFile: TFileStream;

begin
  try
    InputFile := TFileStream.Create (FileName, fmOpenRead);
    try
      SkipBOMAndCopyRestOfTheFile(InputFile, TempFile, FileName); // copy rest of original file to temp
    finally
      FreeAndNil (TempFile);
      FreeAndNil (InputFile);
    end;

    DeleteFile (FileName);                                        // delete original file
    RenameFile (FileName + '.~temp', FileName);                   // rename temp file
  except
    on E: EitSystemConversionError do
      raise;
    on E: Exception do
      raise EitSystemConversionError.Create ('UTF-8 BOM header removal failed!' + CrLf + CrLf +
                                             'File: ' + FileName + CrLf + CrLf + E.Message);
  end;
end;


// example function with parameters with default values

function LeftPad (value:integer; length:integer=2; pad:char='0'): string; overload;
begin
  Result := RightStr (StringOfChar (pad,length) + IntToStr (value), length);
end;


end.
