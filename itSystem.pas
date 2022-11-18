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


function  AppendBackslash (const DirectoryName: string): string;

procedure ConvertPngToJpeg (const PngFileName, JpegFileName: string);

function  DateIntToAnsiDateStr (Date: integer): string;

function  IfInt (const Test: boolean; const i1: integer): integer; overload;
function  IfInt (const Test: boolean; const i1, i2: integer): integer; overload;
function  IfStr (const Test: boolean; const s1: string): string; overload;
function  IfStr (const Test: boolean; const s1, s2: string): string; overload;

function  LeftPad (value:integer; length:integer=2; pad:char='0'): string; overload;

procedure OpenFileInDefaultBrowser (const Handle:HWND; const FileName: string);
procedure OpenFileInEdge (const Handle:HWND; const FileName: string);
procedure OpenFileInNotepadPlusPlus (const Handle:HWND; const FileName: string);

function  TimeIntToAnsiTimeStr (Time: integer): string;



implementation

uses
  Vcl.Imaging.Jpeg, Vcl.Imaging.PngImage, Vcl.Graphics;


function  AppendBackslash (const DirectoryName: string): string;
begin
  if (DirectoryName[Length (DirectoryName)] = '\') then
    Result := DirectoryName
  else
    Result := DirectoryName + '\';
end;


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


// converts date from date integer (yyyymmdd) to date ansi string 'yyyy-mm-dd'

function  DateIntToAnsiDateStr (Date: integer): string;
begin
  Result := LeftPad (Date Div 10000, 4) + '-' + LeftPad ((Date Div 100) Mod 100, 2) + '-' + LeftPad (Date Mod 100, 2);
end;


// returns integer when test is true, 0 if test is false

function IfInt (const Test: boolean; const i1: integer): integer;
begin
  if (Test) then
    Result := i1
  else
    Result := 0;
end;


// returns one of two integers depending on test

function IfInt (const Test: boolean; const i1, i2: integer): integer;
begin
  if (Test) then
    Result := i1
  else
    Result := i2;
end;


// returns string when test is true

function IfStr (const Test: boolean; const s1: string): string;
begin
  if (Test) then
    Result := s1
  else
    Result := '';
end;


// returns one of two strings depending on test

function IfStr (const Test: boolean; const s1, s2: string): string;
begin
  if (Test) then
    Result := s1
  else
    Result := s2;
end;


// convert int to string and pads it with leading zeros to desired length
// example function with parameters with default values

function LeftPad (value:integer; length:integer=2; pad:char='0'): string; overload;
begin
  Result := RightStr (StringOfChar (pad,length) + IntToStr (value), length);
end;


// start default browser and opens file, if file is already open in default browser creates new tab with the file

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


// converts time from time integer (hhmmss) to time ansi string 'hh:mm:ss'

function  TimeIntToAnsiTimeStr (Time: integer): string;
begin
  Result := LeftPad (Time Div 10000, 2) + ':' + LeftPad ((Time Div 100) Mod 100, 2) + ':' + LeftPad (Time Mod 100, 2);
end;


end.
