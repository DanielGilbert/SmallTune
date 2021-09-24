//////////////////////////////////////////////////////////////////////////////
//
//   tP's nonVCL OpenFileDialog Unit
//
//   Unit:      nvTOpenFileDlg.pas
//   Version:   1.00
//   Date:      20.10.2009
//
//   by tupboPASCAL (tP) aka MatthiasG.
//

unit tPnvOpenFileDlg;

interface

uses
  Windows;

const
  COMDLG32 = 'comdlg32.dll';

type
  POpenFilenameA = ^TOpenFilenameA;

  {$EXTERNALSYM tagOFNA}
  tagOFNA = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hInstance: HINST;
    lpstrFilter: PAnsiChar;
    lpstrCustomFilter: PAnsiChar;
    nMaxCustFilter: DWORD;
    nFilterIndex: DWORD;
    lpstrFile: PAnsiChar;
    nMaxFile: DWORD;
    lpstrFileTitle: PAnsiChar;
    nMaxFileTitle: DWORD;
    lpstrInitialDir: PAnsiChar;
    lpstrTitle: PAnsiChar;
    Flags: DWORD;
    nFileOffset: Word;
    nFileExtension: Word;
    lpstrDefExt: PAnsiChar;
    lCustData: LPARAM;
    lpfnHook: function(Wnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpTemplateName: PAnsiChar;
    pvReserved: pointer;
    dwReserved: dword;
    FlagsEx: dword;
  end;

  {$EXTERNALSYM tagOFN}
  tagOFN = tagOFNA;
  TOpenFilenameA = tagOFNA;

  {$EXTERNALSYM OPENFILENAMEA}
  OPENFILENAMEA = tagOFNA;

const
  {$EXTERNALSYM OPENFILENAME_SIZE_VERSION_400A}
  OPENFILENAME_SIZE_VERSION_400A = sizeof(TOpenFileNameA) - sizeof(pointer) - (2 * sizeof(dword));

const
  {$EXTERNALSYM OFN_DONTADDTORECENT}
  OFN_DONTADDTORECENT  = $02000000;
  {$EXTERNALSYM OFN_FORCESHOWHIDDEN}
  OFN_FORCESHOWHIDDEN  = $10000000;    // Show All files including System and hidden files
  {$EXTERNALSYM OFN_EX_NOPLACESBAR}
  OFN_EX_NOPLACESBAR   = $00000001;
  OFN_EXPLORER         = $00080000;
  OFN_LONGNAMES        = $00200000;
  OFN_FILEMUSTEXIST    = $1000;
  OFN_PATHMUSTEXIST    = $0800;
  OFN_HIDEREADONLY     = $04;
  OFN_READONLY         = $01;
  OFN_OVERWRITEPROMPT  = $02;
  OFN_ALLOWMULTISELECT = $0200;

const
  _MAX_FILE_FILTER     = 512;
  _MAX_FILE_TITLE      = 128;
  _MAX_FILES_SPACE     = _MAX_FILE_TITLE * MAX_PATH;
  _MAX_FILES           = _MAX_FILES_SPACE div _MAX_FILE_TITLE;

type
  TFileNames = array of string;

  function GetOpenFileNameA(var OpenFile: TOpenFilenameA): Bool; stdcall; {$EXTERNALSYM GetOpenFileNameA}

type
  TOpenFileDlg = class
  private
    ofn: TOpenFilenameA;
    //FNames: PChar;
    FNames: array[0.._MAX_FILES_SPACE] of Char;
    FFilter: array[0.._MAX_FILE_FILTER] of Char;

    FCaption: string;
    FFileFilter: string;
    FInitialDir: string;
    FMultiselect: Boolean;
    FFileName: string;
    FFiles: TFileNames;
    procedure SetMultiselect(Value: Boolean);
    procedure SetCaption(Value: String);
    procedure SetFileFilter(Value: String);
    procedure SetInitialDir(Value: String);
    function IsNT5OrHigher: Boolean;
  public
    constructor Create(ParentWnd: HWND);
    destructor Destroy; override;
    function Execute: Boolean;
    property Caption: String read FCaption write SetCaption;
    property FileFilter: String read FFileFilter write SetFileFilter;
    property InitialDir: String read FInitialDir write SetInitialDir;
    property Multiselect: Boolean read FMultiselect write SetMultiselect;
    property Filename: string read FFileName;
    property Files: TFileNames read FFiles;
  end;

implementation

function GetOpenFileNameA; external COMDLG32 name 'GetOpenFileNameA';

constructor TOpenFileDlg.Create(ParentWnd: HWND);
begin
  //GetMem(FNames, _MAX_FILES_SPACE);

  ZeroMemory(@FNames, sizeof(FNames));
  ZeroMemory(@ofn, sizeof(TOpenFilenameA));
  if IsNt5OrHigher
    then ofn.lStructSize := sizeof(TOpenFilenameA)
    else ofn.lStructSize := OPENFILENAME_SIZE_VERSION_400A;
  ofn.hWndOwner := ParentWnd;
  ofn.hInstance := SysInit.hInstance;
  ofn.lpstrFile := @FNames[0];
  ofn.nMaxFile := _MAX_FILES_SPACE - 1;
  ofn.Flags := OFN_EXPLORER or OFN_PATHMUSTEXIST or OFN_HIDEREADONLY;
  if Multiselect then ofn.Flags := ofn.Flags or OFN_ALLOWMULTISELECT;

  SetFileFilter('');
end;

destructor TOpenFileDlg.Destroy;
begin
  // FreeMem(FFNames)
  inherited Destroy;
end;

function TOpenFileDlg.Execute: Boolean;
var
  n, i: integer;
  Dir: string;
begin
  Result := False;

  if GetOpenFileNameA(ofn) then
  begin
    Result := True;

    if not Multiselect then
    begin
      SetLength(FFiles, 1);
      SetString(FFiles[0], FNames, length(FNames));
    end else
    begin
      n := 0;
      for i := 0 to length(FNames) do
      begin
        setlength(FFiles, length(FFiles) + 1);
        while FNames[n] <> #0 do
        begin
          FFiles[i] := FFiles[i] + FNames[n];
          inc(n);
        end;
        if FNames[n + 1] <> #0 then inc(n) else break;
      end;

      if length(FFiles)-1 > 0 then
      begin
        Dir := FFiles[0] + '\';
        for i := 1 to length(FFiles) - 1 do
          FFiles[i-1] := Dir + FFiles[i];
        FFiles[length(FFiles)-1] := '';
        setlength(FFiles, length(FFiles)-1);
      end;
    end;
    FFileName := FFiles[0];
  end;
end;

procedure TOpenFileDlg.SetMultiselect(Value: Boolean);
begin
  if FMultiSelect <> Value then
  begin
    FMultiSelect := Value;

    if (FMultiSelect) and not (ofn.Flags and OFN_ALLOWMULTISELECT = OFN_ALLOWMULTISELECT) then
    begin
      ofn.Flags := ofn.Flags or OFN_ALLOWMULTISELECT;
    end else
    if (ofn.Flags and OFN_ALLOWMULTISELECT = OFN_ALLOWMULTISELECT) then
      ofn.Flags := ofn.Flags and not OFN_ALLOWMULTISELECT;
  end;
end;

procedure TOpenFileDlg.SetCaption(Value: String);
begin
  FCaption := Value;
  ofn.lpstrTitle := PCHAR(FCaption);
end;

procedure TOpenFileDlg.SetFileFilter(Value: String);
var
  i: integer;
begin
  FFileFilter := Value;
  ZeroMemory(@FFilter, sizeof(FFilter));

  if FFileFilter = '' then
  begin
     FFilter := 'All files (*.*)'#0'*.*'#0#0;
  end else
  begin
    for i := 0 to length(FFileFilter)-3 do
      if FFileFilter[i+1] = '|' then FFilter[i] := #0
        else FFilter[i] := FFileFilter[i+1];
  end;
  ofn.lpstrFilter := @FFilter[0];
end;

procedure TOpenFileDlg.SetInitialDir(Value: String);
begin
  if FInitialDir <> Value then
  begin
    FInitialDir := Value;
    ofn.lpstrInitialDir := PCHAR(FInitialDir);
  end;
end;

function TOpenFileDlg.IsNT5OrHigher: Boolean;
var
  ovi: TOSVERSIONINFO;
begin
  ZeroMemory(@ovi, sizeof(TOSVERSIONINFO));
  ovi.dwOSVersionInfoSize := SizeOf(TOSVERSIONINFO);
  GetVersionEx(ovi);
  if (ovi.dwPlatformId = VER_PLATFORM_WIN32_NT) and (ovi.dwMajorVersion >= 5)
    then result := TRUE
    else result := FALSE;
end;

end.
