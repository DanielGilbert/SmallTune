unit dgstHelper;
{***************************************************************************
*                            |   SmallTune   |
*                            -----------------
*
* Start               : Thursday, Sep 24, 2009
* Copyright           : (C) 2009 Daniel Gilbert
* Mail                : me@smalltune.net
* Website             : http://smalltune.net
*
* The contents of this file are subject to the Mozilla Public License
* Version 1.1 (the "License"); you may not use this file except in
* compliance with the License. You may obtain a copy of the License at
* http://www.mozilla.org/MPL/
*
* Software distributed under the License is distributed on an "AS IS"
* basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
* License for the specific language governing rights and limitations
* under the License.
*
* Version             : 0.3.0
* Date                : 11-2009
* Description         : SmallTune is a simple but powerful audioplayer for
*                       Windows
***************************************************************************}
interface
  uses Windows, Messages, dgstSysUtils, dgstTypeDef;

function BoolToIntStr(Val: Boolean): String;

function Explode(const Separator: Char; S: string): TStringDynArray;

function FileExists(const Filename: string): boolean;

function GetFileExtension(const FilePath: String): String;
function GetFileName(const FilePath: String): String;
function GetFileNameWithoutExtension(const FilePath: String): String;
function ExtractFilePath(const FilePath: string): string;

function OpenFolder(Caption, DefPath: string): string;
function Like(const AString, APattern: String): Boolean;

function IntPower(const Base: Extended; const Exponent: Integer): Extended;
function Power(const Base, Exponent: Extended): Extended;
function Log10(const X : Extended) : Extended;

function IncludeTrailingPathDelimiter(Path: String): String;

procedure Delay(Milliseconds: Integer);

function GetFileVersion: String;

function LastDelimiter(const Delimiters: string; const S: string): Integer;

function DirectoryExists(const Directory: string): boolean;
function ExcludeTrailingPathDelimiter(Path: String): String;
function ForceDirectories(Dir: string): Boolean;

const
  fmOpenRead       = $0000;
  fmOpenWrite      = $0001;
  fmOpenReadWrite  = $0002;

  fmShareCompat    = $0000 platform; // DOS compatibility mode is not portable
  fmShareExclusive = $0010;
  fmShareDenyWrite = $0020;
  fmShareDenyRead  = $0030 platform; // write-only not supported on all platforms
  fmShareDenyNone  = $0040;

  shell32 = 'shell32.dll';



{****************************************}

function Utf8ToAnsi(Source: string; UnknownChar: char = ' '): AnsiString;


{ SHBrowseForFolder API }

type
{ TSHItemID -- Item ID }
  PSHItemID = ^TSHItemID;
  {$EXTERNALSYM _SHITEMID}
  _SHITEMID = record
    cb: Word;                         { Size of the ID (including cb itself) }
    abID: array[0..0] of Byte;        { The item ID (variable length) }
  end;
  TSHItemID = _SHITEMID;
  {$EXTERNALSYM SHITEMID}
  SHITEMID = _SHITEMID;


{ TItemIDList -- List if item IDs (combined with 0-terminator) }
  PItemIDList = ^TItemIDList;
  {$EXTERNALSYM _ITEMIDLIST}
  _ITEMIDLIST = record
     mkid: TSHItemID;
   end;
  TItemIDList = _ITEMIDLIST;
  {$EXTERNALSYM ITEMIDLIST}
  ITEMIDLIST = _ITEMIDLIST;



  {$EXTERNALSYM BFFCALLBACK}
  BFFCALLBACK = function(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
  TFNBFFCallBack = type BFFCALLBACK;

  PBrowseInfoA = ^TBrowseInfoA;
  PBrowseInfoW = ^TBrowseInfoW;
  PBrowseInfo = PBrowseInfoA;
  {$EXTERNALSYM _browseinfoA}
  _browseinfoA = record
    hwndOwner: HWND;
    pidlRoot: PItemIDList;
    pszDisplayName: PAnsiChar;  { Return display name of item selected. }
    lpszTitle: PAnsiChar;      { text to go in the banner over the tree. }
    ulFlags: UINT;           { Flags that control the return stuff }
    lpfn: TFNBFFCallBack;
    lParam: LPARAM;          { extra info that's passed back in callbacks }
    iImage: Integer;         { output var: where to return the Image index. }
  end;
  {$EXTERNALSYM _browseinfoW}
  _browseinfoW = record
    hwndOwner: HWND;
    pidlRoot: PItemIDList;
    pszDisplayName: PWideChar;  { Return display name of item selected. }
    lpszTitle: PWideChar;      { text to go in the banner over the tree. }
    ulFlags: UINT;           { Flags that control the return stuff }
    lpfn: TFNBFFCallBack;
    lParam: LPARAM;          { extra info that's passed back in callbacks }
    iImage: Integer;         { output var: where to return the Image index. }
  end;
  {$EXTERNALSYM _browseinfo}
  _browseinfo = _browseinfoA;
  TBrowseInfoA = _browseinfoA;
  TBrowseInfoW = _browseinfoW;
  TBrowseInfo = TBrowseInfoA;
  {$EXTERNALSYM BROWSEINFOA}
  BROWSEINFOA = _browseinfoA;
  {$EXTERNALSYM BROWSEINFOW}
  BROWSEINFOW = _browseinfoW;
  {$EXTERNALSYM BROWSEINFO}
  BROWSEINFO = BROWSEINFOA;

const
{ Browsing for directory. }

  {$EXTERNALSYM CSIDL_DRIVES}
  CSIDL_DRIVES                        = $0011;

  {$EXTERNALSYM BIF_RETURNONLYFSDIRS}
  BIF_RETURNONLYFSDIRS   = $0001;  { For finding a folder to start document searching }
  {$EXTERNALSYM BIF_DONTGOBELOWDOMAIN}
  BIF_DONTGOBELOWDOMAIN  = $0002;  { For starting the Find Computer }
  {$EXTERNALSYM BIF_STATUSTEXT}
  BIF_STATUSTEXT         = $0004;
  {$EXTERNALSYM BIF_RETURNFSANCESTORS}
  BIF_RETURNFSANCESTORS  = $0008;
  {$EXTERNALSYM BIF_EDITBOX}
  BIF_EDITBOX            = $0010;
  {$EXTERNALSYM BIF_VALIDATE}
  BIF_VALIDATE           = $0020;  { insist on valid result (or CANCEL) }
  {$EXTERNALSYM BIF_NEWDIALOGSTYLE}
  BIF_NEWDIALOGSTYLE     = $0040;
  {$EXTERNALSYM BIF_USENEWUI}
  BIF_USENEWUI = BIF_NEWDIALOGSTYLE or BIF_EDITBOX;

  {$EXTERNALSYM BIF_BROWSEINCLUDEURLS}
  BIF_BROWSEINCLUDEURLS  = $0080;
  {$EXTERNALSYM BIF_UAHINT}
  BIF_UAHINT = $100;   // Add a UA hint to the dialog, in place of the edit box. May not be combined with BIF_EDITBOX
  {$EXTERNALSYM BIF_NONEWFOLDERBUTTON}
  BIF_NONEWFOLDERBUTTON = $200;   // Do not add the "New Folder" button to the dialog.  Only applicable with BIF_NEWDIALOGSTYLE.
  {$EXTERNALSYM BIF_NOTRANSLATETARGETS}
  BIF_NOTRANSLATETARGETS = $400;   // don't traverse target as shortcut

  {$EXTERNALSYM BIF_BROWSEFORCOMPUTER}
  BIF_BROWSEFORCOMPUTER  = $1000;  { Browsing for Computers. }
  {$EXTERNALSYM BIF_BROWSEFORPRINTER}
  BIF_BROWSEFORPRINTER   = $2000;  { Browsing for Printers }
  {$EXTERNALSYM BIF_BROWSEINCLUDEFILES}
  BIF_BROWSEINCLUDEFILES = $4000;  { Browsing for Everything }
  {$EXTERNALSYM BIF_SHAREABLE}
  BIF_SHAREABLE          = $8000;

{ message from browser }

  {$EXTERNALSYM BFFM_INITIALIZED}
  BFFM_INITIALIZED       = 1;
  {$EXTERNALSYM BFFM_SELCHANGED}
  BFFM_SELCHANGED        = 2;
  {$EXTERNALSYM BFFM_VALIDATEFAILEDA}
  BFFM_VALIDATEFAILEDA   = 3;   { lParam:szPath ret:1(cont),0(EndDialog) }
  {$EXTERNALSYM BFFM_VALIDATEFAILEDW}
  BFFM_VALIDATEFAILEDW   = 4;   { lParam:wzPath ret:1(cont),0(EndDialog) }

{ messages to browser }

  {$EXTERNALSYM BFFM_SETSTATUSTEXTA}
  BFFM_SETSTATUSTEXTA         = WM_USER + 100;
  {$EXTERNALSYM BFFM_ENABLEOK}
  BFFM_ENABLEOK               = WM_USER + 101;
  {$EXTERNALSYM BFFM_SETSELECTIONA}
  BFFM_SETSELECTIONA          = WM_USER + 102;
  {$EXTERNALSYM BFFM_SETSELECTIONW}
  BFFM_SETSELECTIONW          = WM_USER + 103;
  {$EXTERNALSYM BFFM_SETSTATUSTEXTW}
  BFFM_SETSTATUSTEXTW         = WM_USER + 104;

  {$EXTERNALSYM BFFM_VALIDATEFAILED}
  BFFM_VALIDATEFAILED     = BFFM_VALIDATEFAILEDA;
  {$EXTERNALSYM BFFM_SETSTATUSTEXT}
  BFFM_SETSTATUSTEXT      = BFFM_SETSTATUSTEXTA;
  {$EXTERNALSYM BFFM_SETSELECTION}
  BFFM_SETSELECTION       = BFFM_SETSELECTIONA;

{$EXTERNALSYM SHBrowseForFolder}
function SHBrowseForFolder(var lpbi: TBrowseInfo): PItemIDList; stdcall;
{$EXTERNALSYM SHBrowseForFolderA}
function SHBrowseForFolderA(var lpbi: TBrowseInfoA): PItemIDList; stdcall;
{$EXTERNALSYM SHBrowseForFolderW}
function SHBrowseForFolderW(var lpbi: TBrowseInfoW): PItemIDList; stdcall;

{$EXTERNALSYM SHGetPathFromIDList}
function SHGetPathFromIDList(pidl: PItemIDList; pszPath: PChar): BOOL; stdcall;
{$EXTERNALSYM SHGetPathFromIDListA}
function SHGetPathFromIDListA(pidl: PItemIDList; pszPath: PAnsiChar): BOOL; stdcall;
{$EXTERNALSYM SHGetPathFromIDListW}
function SHGetPathFromIDListW(pidl: PItemIDList; pszPath: PWideChar): BOOL; stdcall;

{$EXTERNALSYM SHGetSpecialFolderLocation}
function SHGetSpecialFolderLocation(hwndOwner: HWND; nFolder: Integer;
  var ppidl: PItemIDList): HResult; stdcall;

function SHGetPathFromIDList;        external shell32 name 'SHGetPathFromIDListA';
function SHGetPathFromIDListA;        external shell32 name 'SHGetPathFromIDListA';
function SHGetPathFromIDListW;        external shell32 name 'SHGetPathFromIDListW';
function SHGetSpecialFolderLocation;    external shell32 name 'SHGetSpecialFolderLocation';
function SHBrowseForFolder;          external shell32 name 'SHBrowseForFolderA';
function SHBrowseForFolderA;          external shell32 name 'SHBrowseForFolderA';
function SHBrowseForFolderW;          external shell32 name 'SHBrowseForFolderW';


implementation

function BoolToIntStr(Val: Boolean): String;
begin
  case Val of
    True: Result := '1';
    False: Result := '0';
  end;
end;

// Explode trennt S in die durch Separator getrennten Elemente auf. Wenn Limit
// > 0 ist, so werden max. Limit Elemente getrennt, wobei im letzen Element
// die Restzeichenkette steht.

function Explode(const Separator: Char; S: string): TStringDynArray;
var
  n,i: integer;
  Len: Integer;
begin
  SetLength(Result, 0);
  Len := Length(S);
  if Len > 0 then
  begin
    SetLength(Result, 1);
    for n := 1 to Len do
    begin
      if S[n] = Separator  then
        SetLength(Result, Length(Result) + 1)
      else
        begin
          i := High(Result);
          Result[i] := Result[i] + S[n];
        end;
    end;
  end;
end;


function DirectoryExists(const Directory: string): boolean;
var
  Handle   : THandle;
  FindData : TWin32FindData;
begin
  Handle   := FindFirstFile(pchar(Directory),FindData);
  Result   := (Handle <> INVALID_HANDLE_VALUE) and
    (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY <> 0);

  if(Handle <> INVALID_HANDLE_VALUE) then
    Windows.FindClose(Handle);
end;


function ExcludeTrailingPathDelimiter(Path: String): String;
begin
  If Path[Length(Path)] = '\' then
    SetLength(Path, Length(Path) - 1);
  Result := Path;
end;

function ForceDirectories(Dir: string): Boolean;
begin
  Result := True;
  Dir := ExcludeTrailingPathDelimiter(Dir);

  if (Length(Dir) < 3) or DirectoryExists(Dir)
    or (ExtractFilePath(Dir) = Dir) then Exit;

  Result := ForceDirectories(ExtractFilePath(Dir)) and CreateDirectory(PChar(Dir), nil);
end;

function IncludeTrailingPathDelimiter(Path: String): String;
begin
  If Path[Length(Path)-1] = '\' then
    Result := Path
  else
    Result := Path + '\';
end;

function IntPower(const Base: Extended; const Exponent: Integer): Extended;
asm
        mov     ecx, eax
        cdq
        fld1                      { Result := 1 }
        xor     eax, edx
        sub     eax, edx          { eax := Abs(Exponent) }
        jz      @@3
        fld     Base
        jmp     @@2
@@1:    fmul    ST, ST            { X := Base * Base }
@@2:    shr     eax,1
        jnc     @@1
        fmul    ST(1),ST          { Result := Result * X }
        jnz     @@1
        fstp    st                { pop X from FPU stack }
        cmp     ecx, 0
        jge     @@3
        fld1
        fdivrp                    { Result := 1 / Result }
@@3:
        fwait
end;

function Power(const Base, Exponent: Extended): Extended;
begin
  if Exponent = 0.0 then
    Result := 1.0               { n**0 = 1 }
  else if (Base = 0.0) and (Exponent > 0.0) then
    Result := 0.0               { 0**n = 0, n > 0 }
  else if (Frac(Exponent) = 0.0) and (Abs(Exponent) <= MaxInt) then
    Result := IntPower(Base, Integer(Trunc(Exponent)))
  else
    Result := Exp(Exponent * Ln(Base))
end;

//---------------------------------------------------------
// Log.10(X) := Log.2(X) * Log.10(2)

function Log10(const X : Extended) : Extended;
asm
	FLDLG2     { Log base ten of 2 }
	FLD	X
	FYL2X
	FWAIT
end;

function LastDelimiter(const Delimiters: string; const S: string): Integer;
var
  i: integer;
begin
  Result := -1;
  for I := Length(S) downto 1 do
    begin
      if Delimiters[1] = S[I] then
        Result := I;
    end;
end;

function GetFileVersion: String;
  Var i, W: LongWord;
    P: Pointer;
    FI: PVSFixedFileInfo;

  Begin
    Result := 'NoVersionInfo';
    i := GetFileVersionInfoSize(PChar(ParamStr(0)), W);
    If i = 0 Then Exit;
    GetMem(P, i);
    Try
      If not GetFileVersionInfo(PChar(ParamStr(0)), W, i, P)
        or not VerQueryValue(P, '\', Pointer(FI), W) Then Exit;
      Result := IntToStr(FI^.dwFileVersionMS shr 16)
        + '.' + IntToStr(FI^.dwFileVersionMS and $FFFF)
        + '.' + IntToStr(FI^.dwFileVersionLS shr 16)
        + '.' + IntToStr(FI^.dwFileVersionLS and $FFFF);
      If FI^.dwFileFlags and VS_FF_DEBUG        <> 0 Then Result := Result + ' debug';
      If FI^.dwFileFlags and VS_FF_PRERELEASE   <> 0 Then Result := Result + ' beta';
      If FI^.dwFileFlags and VS_FF_PRIVATEBUILD <> 0 Then Result := Result + ' private';
      If FI^.dwFileFlags and VS_FF_SPECIALBUILD <> 0 Then Result := Result + ' special'; 
    Finally
      FreeMem(P);
    End;
  End;

procedure Delay(Milliseconds: Integer);
var
  Tick: DWord;
  Event: THandle;
begin
  Event := CreateEvent(nil, False, False, nil);
  try
    Tick := GetTickCount + DWord(Milliseconds);
    while (Milliseconds > 0) and
          (MsgWaitForMultipleObjects(1, Event, False, Milliseconds, QS_ALLINPUT) <> WAIT_TIMEOUT) do
    begin
      Milliseconds := Tick - GetTickcount;
    end;
  finally
    CloseHandle(Event);
  end;
end;

{ Like prüft die Übereinstimmung eines Strings mit einem Muster. 
  So liefert Like('Delphi', 'D*p?i') true. 
  Der Vergleich berücksichtigt Klein- und Großschreibung. 
  Ist das nicht gewünscht, muss statt dessen 
  Like(AnsiUpperCase(AString), AnsiUpperCase(APattern)) benutzt werden: }

function Like(const AString, APattern: String): Boolean;
var
  StringPtr, PatternPtr: PChar;
  StringRes, PatternRes: PChar;
begin
  Result:=false;
  StringPtr:=PChar(AString);
  PatternPtr:=PChar(APattern);
  StringRes:=nil;
  PatternRes:=nil;
  repeat
    repeat // ohne vorangegangenes "*"
      case PatternPtr^ of
        #0: begin
          Result:=StringPtr^=#0;
          if Result or (StringRes=nil) or (PatternRes=nil) then
            Exit;
          StringPtr:=StringRes;
          PatternPtr:=PatternRes;
          Break;
        end;
        '*': begin
          inc(PatternPtr);
          PatternRes:=PatternPtr;
          Break;
        end;
        '?': begin
          if StringPtr^=#0 then
            Exit;
          inc(StringPtr);
          inc(PatternPtr);
        end;
        else begin
          if StringPtr^=#0 then
            Exit;
          if StringPtr^<>PatternPtr^ then begin
            if (StringRes=nil) or (PatternRes=nil) then
              Exit;
            StringPtr:=StringRes;
            PatternPtr:=PatternRes;
            Break;
          end
          else begin
            inc(StringPtr);
            inc(PatternPtr);
          end;
        end;
      end;
    until false;
    repeat // mit vorangegangenem "*"
      case PatternPtr^ of
        #0: begin
          Result:=true;
          Exit;
        end;
        '*': begin
          inc(PatternPtr);
          PatternRes:=PatternPtr;
        end;
        '?': begin
          if StringPtr^=#0 then
            Exit;
          inc(StringPtr);
          inc(PatternPtr);
        end;
        else begin
          repeat
            if StringPtr^=#0 then
              Exit;
            if StringPtr^=PatternPtr^ then
              Break;
            inc(StringPtr);
          until false;
          inc(StringPtr);
          StringRes:=StringPtr;
          inc(PatternPtr);
          Break;
        end;
      end;
    until false;
  until false;
end; {Michael Winter}

//  Erweiterte Verzeichnis-Öffnen-Dialog-Funktion
//  Caption: Optionaler Subtitel
//  DefPath: Vorauswahl des Verzeichnises
//  Result: Verzeichnis als String
function OpenFolder(Caption, DefPath: string): string;
var
  bi: TBrowseInfo;
  lpBuffer: PChar;
  pidlPrograms, pidlBrowse: PItemIDList;

  function BrowseCallbackProc(hwnd: HWND; uMsg: UINT; lParam: Cardinal;
    lpData: Cardinal): Integer; stdcall;
  var
    PathName: array[0..MAX_PATH] of Char;
  begin
    case uMsg of
      BFFM_INITIALIZED:
        SendMessage(Hwnd, BFFM_SETSELECTION, Ord(True), Integer(lpData));
      BFFM_SELCHANGED:
        begin
          SHGetPathFromIDList(PItemIDList(lParam), @PathName);
          SendMessage(hwnd, BFFM_SETSTATUSTEXT, 0, Longint(PChar(@PathName)));
        end;
    end;
    Result := 0;
  end;

begin
  Result := '';
  if (not SUCCEEDED(SHGetSpecialFolderLocation(GetActiveWindow, CSIDL_DRIVES,
    pidlPrograms))) then exit;

  GetMem(lpBuffer, MAX_PATH);

  FillChar(BI, SizeOf(BrowseInfo), 0);
  bi.hwndOwner := GetActiveWindow;
  //bi.pidlRoot := pidlPrograms;
  bi.pszDisplayName := lpBuffer;
  bi.lpszTitle := PChar(Caption);
  bi.ulFlags := BIF_NEWDIALOGSTYLE;
  bi.lpfn := @BrowseCallbackProc;
  //bi.lParam := Integer(PChar(DefPath));

  pidlBrowse := SHBrowseForFolder(bi);
  if (pidlBrowse <> nil) then
    if SHGetPathFromIDList(pidlBrowse, lpBuffer) then
      Result := String(lpBuffer);

  if (lpBuffer <> nil) then FreeMem(lpBuffer);
end;


function Utf8ToAnsi(Source: string; UnknownChar: char = ' '): AnsiString;
     (* Converts the given UTF-8 String to Windows ANSI (Win-1252).
      If a character can not be converted, the "UnknownChar" is inserted. *)
var
  SourceLen: INTEGER; // Length of Source string
  I: INTEGER;
  A: BYTE; // Current ANSI character value
  Len: INTEGER; // Current real length of "Result" string
begin
  SourceLen := Length(Source);
  SetLength(Result, SourceLen); // Enough room to live
  Len := 0;
  I := 1;
  while I <= SourceLen do begin
    A := ORD(Source[I]);
    if (A < $FE) AND (A > $1F) then begin // Range $001F..$00FF
      INC(Len);
      Result[Len] := Source[I];
      INC(I);
    end
    else
      INC(I);
  end;
  SetLength(Result, Len);
end;

function FileExists(const Filename: string): boolean;
var
  Handle   : THandle;
  FindData : TWin32FindData;
begin
  Handle   := FindFirstFile(pchar(Filename),FindData);
  Result   := (Handle <> INVALID_HANDLE_VALUE);

  if(Result) then Windows.FindClose(Handle);
end;

function GetFileExtension(const FilePath: String): String;
var
  i : integer;
begin
  i := length(FilePath);
  while(i > 0) do
  begin
    if(FilePath[i] = '.') then
      break;
    dec(i);
  end;

  if(i = 0) then
    Result := FilePath
  else
    Result := copy(FilePath,i+1,Length(Filepath)-1);
end;

function GetFileName(const FilePath: String): String;
var
  i : integer;
begin
  i := length(FilePath);
  while(i > 0) do
  begin
    if(FilePath[i] = '\') then
      break;
    dec(i);
  end;

  if(i = 0) then
    Result := FilePath
  else
    Result := copy(FilePath,i+1,Length(Filepath)-1);
end;

function GetFileNameWithoutExtension(const FilePath: String): String;
var
  i : integer;
begin
  i := length(FilePath);
  while(i > 0) do
  begin
    if(FilePath[i] = '.') then
      break;
    dec(i);
  end;

  if(i = 0) then
    Result := GetFileName(FilePath)
  else
    Result := GetFileName(copy(FilePath,0,Length(Filepath)-1 - i));
end;

function ExtractFilePath(const FilePath: string): string;
var
  i : integer;
begin
  Result := '';
  i      := length(FilePath);
  while(i > 0) do
  begin
    if(FilePath[i] = ':') or
      (FilePath[i] = '\') then
    begin
      Result := copy(FilePath,1,i);
      break;
    end;

    dec(i);
  end;
end;

{**********************************************************
***********************************************************}

{* Classes Fragment *}


end.
