//
// unit itSystem, v2022-07, copyright 2022 by Ivo Tišljar
//
// ovo je jedan od mojih standardnih unit-a koji se koriste u Delphi programima
//
// ovdje imamo skup rutina opæe namjene


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


// greška pri koverziji

type
  EItSystemError = class (Exception)
  end;

// deklaracija javnih funkcija i procedura definiranih u ovom unit-u

procedure ConvertPngToJpeg (const sPngFileName, sJpegFileName: String);

function  IfInt (const Test: boolean; const i1: integer): integer; overload;
function  IfInt (const Test: boolean; const i1, i2: integer): integer; overload;
function  IfStr (const Test: boolean; const s1: string): string; overload;
function  IfStr (const Test: boolean; const s1, s2: string): string; overload;

procedure OpenFileInDefaultBrowser (const Handle:HWND; const sFileName: string);
procedure OpenFileInEdge (const Handle:HWND; const sFileName: string);
procedure OpenFileInNotepadPlusPlus (const Handle:HWND; const sFileName: string);
//procedure OpenURLInADefaultBrowser (const URL:string);

procedure StripBOMFromUtf8File (const sFileName:string);



// deklaracija funkcije s DEFAULT vrijednostima, tj. opcionalnim parametrima

function  LeftPad (value:integer; length:integer=2; pad:char='0'): string; overload;


implementation

uses
  Vcl.Imaging.Jpeg, Vcl.Imaging.PngImage, Vcl.Graphics;


// =====================================================================================================================

//

procedure ConvertPngToJpeg (const sPngFileName, sJpegFileName: String);

var
  Png: TPngImage;
  Bmp: TBitmap;
  Jpeg: TJpegImage;

begin
  Png := TPngImage.Create;
  Bmp := TBitmap.Create;
  Jpeg := TJpegImage.Create;
  try
    Png.LoadFromFile (sPngFileName);
    Bmp.Width := Png.Width;
    Bmp.Height := Png.Height;
    Png.Draw (Bmp.Canvas, Bmp.Canvas.ClipRect);
    Jpeg.Assign (Bmp);
    Jpeg.SaveToFile (sJpegFileName);
  finally
    FreeAndNil (Jpeg);
    FreeAndNil (Bmp);
    FreeAndNil (Png);
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



// ---------------------------------------------------------------------------------------------------------------------

//

procedure OpenFileInDefaultBrowser (
  const Handle:HWND;
  const sFileName: string);

begin
  ShellExecute(Handle, 'open', PChar(sFileName), '', nil, sw_ShowNormal);
end;

// ---------------------------------------------------------------------------------------------------------------------

// pokreæe Edge i u njemu otvara fajl s diska sa zadanim imenom. Ako je fajl otvoren u Edge-u od ranije otvara još
// jednu kopiju fajla u novom tabu browsera

procedure OpenFileInEdge (
  const Handle:HWND;          // handle forme (tj. njoj pripadnoj Windows prozora) iz koje je pozvana ova rutina
  const sFileName: string);   // naziv fajla (s apsolutnom putanjom) koji otvaram u Edge-u

begin
  ShellExecute (Handle, 'open', Pchar('"shell:Appsfolder\Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge"'),
                Pchar ('"""' + sFileName + '"""'), nil, sw_ShowNormal);
end;

// ---------------------------------------------------------------------------------------------------------------------

// pokreæe Notepad++ i u njemu otvara fajl s diska sa zadanim imenom. Ako je fajl otvoren u Notepad++-u od ranije
// Notepad++ aktivira tab u kojem se nalazi fajl i ako je bilo promjena od kada je zadnji puta korisnik gledao fajl
// u Notepad++-u pita da li da ponovno uèita fajl

procedure OpenFileInNotepadPlusPlus (
  const Handle:HWND;          // handle forme (tj. njoj pripadnoj Windows prozora) iz koje je pozvana ova rutina
  const sFileName: string);   // naziv fajla (s apsolutnom putanjom) koji otvaram u Notepad++-u

begin
  ShellExecute (Handle, 'open', Pchar ('"C:\Program Files (x86)\Notepad++\notepad++.exe"'),
                Pchar ('"' + sFileName + '"'), nil, sw_ShowNormal);
end;

// ---------------------------------------------------------------------------------------------------------------------

// izbacuje iz fajla prva tri byte-a BOM header za UTF-8 BOM fajlove i pretvara if u obiène/prave UTF-8 fajlove

procedure StripBOMFromUtf8File (
  const sFileName:string);      // ime ulaznog fajla (s apsolutnom putanjom)

type
  T3ac = array [1..3] of AnsiChar;  // polje od tri ansi (1 znak = 1 byte) karaktera

const
  iBomSize = 3;                 // duljina BOM header-a u UTF-8 BOM fajlu
  aUtf8 : T3ac = #$EF#$BB#$BF;  // UTF-8 BOM header

var
  oFile,                        // (ulazni) fajl (FileStream) iz kojeg izbacujem BOM header
  oTemp: TFileStream;           // privremeni fajl (FileStream) u kojeg zapisujem sadržaj fajla iza BOM headera
  aBom : T3ac;                  // polje od 3 ansi (jednobajtna) znaka u koje uèitavam UTF-8 zaglavlje

begin  // func StripBOMFromUtf8File
  try
    oFile := TFileStream.Create (sFileName, fmOpenRead);          // otvaram ulazni fajl za èitanje
    try
      oFile.Read(aBom, 3);                                          // èitam UTF-8 BOM header fajla
      // provjeravam je li UTF-8 BOM header ispravan i ako nije dižem iznimku
      if (aBom[1] <> aUtf8[1]) Or (aBom[2] <> aUtf8[2]) Or (aBom[3] <> aUtf8[3]) then
        raise EItSystemError.Create ('Neispravan format UTF-8 BOM zaglavlja!'#13#10#13#10 +
                                     'Datoteka: ' + sFileName);
      oFile.Seek (iBomSize, soFromBeginning);                       // pomièem pointer iza BOM header-a
      oTemp := TFileStream.Create (sFileName + '.~temp', fmCreate); // kreiram pomoæni fajl za pisanje
      try
        oTemp.CopyFrom (oFile, oFile.Size - iBomSize) ;               // kopiram u pomoæni ostatak sadržaja ulaznog fajla
      finally
        oTemp.Free;             // zatvara pomoæni FileStream
      end;
    finally
      oFile.Free;               // zatvara glavni FileStream
    end;
    DeleteFile (sFileName);                                         // brišem ulazni fajl s diska
    RenameFile (sFileName + '.~temp', sFileName);                   // pomoæni fajl preimenujem u ime ulaznog fajla
  except
    on E: EItSystemError do     // ovo samo proslijedim
      raise;
    on E: Exception do          // ako je nastao bilo koji drugi problem to prijavim
      raise EItSystemError.Create ('Neuspješna konverzija UTF-8 BOM zaglavlja!'#13#10#13#10 +
                                   'Datoteka: ' + sFileName + #13#10#13#10 + E.Message);
  end;
end;  // func StripBOMFromUtf8File

// =====================================================================================================================


// example function with parameters with default values

function LeftPad (value:integer; length:integer=2; pad:char='0'): string; overload;
begin
//   result := RightStr(StringOfChar(pad,length) + IntToStr(value), length );
end;



end.
