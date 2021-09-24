unit dgstCommDlg;

interface

uses Windows, Messages, dgstShlObj;

type
  POpenFilenameA = ^TOpenFilenameA;
  POpenFilenameW = ^TOpenFilenameW;
  POpenFilename = POpenFilenameA;
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
    pvReserved: Pointer;
    dwReserved: DWORD;
    FlagsEx: DWORD;
  end;
  {$EXTERNALSYM tagOFNW}
  tagOFNW = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hInstance: HINST;
    lpstrFilter: PWideChar;
    lpstrCustomFilter: PWideChar;
    nMaxCustFilter: DWORD;
    nFilterIndex: DWORD;
    lpstrFile: PWideChar;
    nMaxFile: DWORD;
    lpstrFileTitle: PWideChar;
    nMaxFileTitle: DWORD;
    lpstrInitialDir: PWideChar;
    lpstrTitle: PWideChar;
    Flags: DWORD;
    nFileOffset: Word;
    nFileExtension: Word;
    lpstrDefExt: PWideChar;
    lCustData: LPARAM;
    lpfnHook: function(Wnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpTemplateName: PWideChar;
    pvReserved: Pointer;
    dwReserved: DWORD;
    FlagsEx: DWORD;
  end;
  {$EXTERNALSYM tagOFN}
  tagOFN = tagOFNA;
  TOpenFilenameA = tagOFNA;
  TOpenFilenameW = tagOFNW;
  TOpenFilename = TOpenFilenameA;
  {$EXTERNALSYM OPENFILENAMEA}
  OPENFILENAMEA = tagOFNA;
  {$EXTERNALSYM OPENFILENAMEW}
  OPENFILENAMEW = tagOFNW;
  {$EXTERNALSYM OPENFILENAME}
  OPENFILENAME = OPENFILENAMEA;

{$EXTERNALSYM GetOpenFileName}
function GetOpenFileName(var OpenFile: TOpenFilename): Bool; stdcall;
{$EXTERNALSYM GetOpenFileNameA}
function GetOpenFileNameA(var OpenFile: TOpenFilenameA): Bool; stdcall;
{$EXTERNALSYM GetOpenFileNameW}
function GetOpenFileNameW(var OpenFile: TOpenFilenameW): Bool; stdcall;
{$EXTERNALSYM GetSaveFileName}
function GetSaveFileName(var OpenFile: TOpenFilename): Bool; stdcall;
{$EXTERNALSYM GetSaveFileNameA}
function GetSaveFileNameA(var OpenFile: TOpenFilenameA): Bool; stdcall;
{$EXTERNALSYM GetSaveFileNameW}
function GetSaveFileNameW(var OpenFile: TOpenFilenameW): Bool; stdcall;
{$EXTERNALSYM GetFileTitle}
function GetFileTitle(FileName: PChar; Title: PChar; TitleSize: Word): Smallint; stdcall;
{$EXTERNALSYM GetFileTitleA}
function GetFileTitleA(FileName: PAnsiChar; Title: PAnsiChar; TitleSize: Word): Smallint; stdcall;
{$EXTERNALSYM GetFileTitleW}
function GetFileTitleW(FileName: PWideChar; Title: PWideChar; TitleSize: Word): Smallint; stdcall;

const
  {$EXTERNALSYM OFN_READONLY}
  OFN_READONLY = $00000001;
  {$EXTERNALSYM OFN_OVERWRITEPROMPT}
  OFN_OVERWRITEPROMPT = $00000002;
  {$EXTERNALSYM OFN_HIDEREADONLY}
  OFN_HIDEREADONLY = $00000004;
  {$EXTERNALSYM OFN_NOCHANGEDIR}
  OFN_NOCHANGEDIR = $00000008;
  {$EXTERNALSYM OFN_SHOWHELP}
  OFN_SHOWHELP = $00000010;
  {$EXTERNALSYM OFN_ENABLEHOOK}
  OFN_ENABLEHOOK = $00000020;
  {$EXTERNALSYM OFN_ENABLETEMPLATE}
  OFN_ENABLETEMPLATE = $00000040;
  {$EXTERNALSYM OFN_ENABLETEMPLATEHANDLE}
  OFN_ENABLETEMPLATEHANDLE = $00000080;
  {$EXTERNALSYM OFN_NOVALIDATE}
  OFN_NOVALIDATE = $00000100;
  {$EXTERNALSYM OFN_ALLOWMULTISELECT}
  OFN_ALLOWMULTISELECT = $00000200;
  {$EXTERNALSYM OFN_EXTENSIONDIFFERENT}
  OFN_EXTENSIONDIFFERENT = $00000400;
  {$EXTERNALSYM OFN_PATHMUSTEXIST}
  OFN_PATHMUSTEXIST = $00000800;
  {$EXTERNALSYM OFN_FILEMUSTEXIST}
  OFN_FILEMUSTEXIST = $00001000;
  {$EXTERNALSYM OFN_CREATEPROMPT}
  OFN_CREATEPROMPT = $00002000;
  {$EXTERNALSYM OFN_SHAREAWARE}
  OFN_SHAREAWARE = $00004000;
  {$EXTERNALSYM OFN_NOREADONLYRETURN}
  OFN_NOREADONLYRETURN = $00008000;
  {$EXTERNALSYM OFN_NOTESTFILECREATE}
  OFN_NOTESTFILECREATE = $00010000;
  {$EXTERNALSYM OFN_NONETWORKBUTTON}
  OFN_NONETWORKBUTTON = $00020000;
  {$EXTERNALSYM OFN_NOLONGNAMES}
  OFN_NOLONGNAMES = $00040000;
  {$EXTERNALSYM OFN_EXPLORER}
  OFN_EXPLORER = $00080000;
  {$EXTERNALSYM OFN_NODEREFERENCELINKS}
  OFN_NODEREFERENCELINKS = $00100000;
  {$EXTERNALSYM OFN_LONGNAMES}
  OFN_LONGNAMES = $00200000;
  {$EXTERNALSYM OFN_ENABLEINCLUDENOTIFY}
  OFN_ENABLEINCLUDENOTIFY = $00400000;
  {$EXTERNALSYM OFN_ENABLESIZING}
  OFN_ENABLESIZING = $00800000;
  { #if (_WIN32_WINNT >= 0x0500) }
  {$EXTERNALSYM OFN_DONTADDTORECENT}
  OFN_DONTADDTORECENT = $02000000;
  {$EXTERNALSYM OFN_FORCESHOWHIDDEN}
  OFN_FORCESHOWHIDDEN = $10000000;    // Show All files including System and hidden files
  { #endif // (_WIN32_WINNT >= 0x0500) }

  { FlagsEx Values }
  { #if (_WIN32_WINNT >= 0x0500) }
  {$EXTERNALSYM OFN_EX_NOPLACESBAR}
  OFN_EX_NOPLACESBAR = $00000001;
  { #endif // (_WIN32_WINNT >= 0x0500) }

{ Return values for the registered message sent to the hook function
  when a sharing violation occurs.  OFN_SHAREFALLTHROUGH allows the
  filename to be accepted, OFN_SHARENOWARN rejects the name but puts
  up no warning (returned when the app has already put up a warning
  message), and OFN_SHAREWARN puts up the default warning message
  for sharing violations.

  Note:  Undefined return values map to OFN_SHAREWARN, but are
         reserved for future use. }

  {$EXTERNALSYM OFN_SHAREFALLTHROUGH}
  OFN_SHAREFALLTHROUGH = 2;
  {$EXTERNALSYM OFN_SHARENOWARN}
  OFN_SHARENOWARN = 1;
  {$EXTERNALSYM OFN_SHAREWARN}
  OFN_SHAREWARN = 0;

type
  POFNotifyA = ^TOFNotifyA;
  POFNotifyW = ^TOFNotifyW;
  POFNotify = POFNotifyA;
  {$EXTERNALSYM _OFNOTIFYA}
  _OFNOTIFYA = packed record
    hdr: TNMHdr;
    lpOFN: POpenFilenameA;
    pszFile: PAnsiChar;
  end;
  {$EXTERNALSYM _OFNOTIFYW}
  _OFNOTIFYW = packed record
    hdr: TNMHdr;
    lpOFN: POpenFilenameW;
    pszFile: PWideChar;
  end;
  {$EXTERNALSYM _OFNOTIFY}
  _OFNOTIFY = _OFNOTIFYA;
  TOFNotifyA = _OFNOTIFYA;
  TOFNotifyW = _OFNOTIFYW;
  TOFNotify = TOFNotifyA;
  {$EXTERNALSYM OFNOTIFYA}
  OFNOTIFYA = _OFNOTIFYA;
  {$EXTERNALSYM OFNOTIFYW}
  OFNOTIFYW = _OFNOTIFYW;
  {$EXTERNALSYM OFNOTIFY}
  OFNOTIFY = OFNOTIFYA;


  POFNotifyExA = ^TOFNotifyExA;
  POFNotifyExW = ^TOFNotifyExW;
  POFNotifyEx = POFNotifyExA;
  {$EXTERNALSYM _OFNOTIFYEXA}
  _OFNOTIFYEXA = packed record
    hdr: TNMHdr;
    lpOFN: POpenFilenameA;
    psf: IShellFolder;
    pidl: Pointer;
  end;
  {$EXTERNALSYM _OFNOTIFYEXW}
  _OFNOTIFYEXW = packed record
    hdr: TNMHdr;
    lpOFN: POpenFilenameW;
    psf: IShellFolder;
    pidl: Pointer;
  end;
  {$EXTERNALSYM _OFNOTIFYEX}
  _OFNOTIFYEX = _OFNOTIFYEXA;
  TOFNotifyExA = _OFNOTIFYEXA;
  TOFNotifyExW = _OFNOTIFYEXW;
  TOFNotifyEx = TOFNotifyExA;
  {$EXTERNALSYM OFNOTIFYEXA}
  OFNOTIFYEXA = _OFNOTIFYEXA;
  {$EXTERNALSYM OFNOTIFYEXW}
  OFNOTIFYEXW = _OFNOTIFYEXW;
  {$EXTERNALSYM OFNOTIFYEX}
  OFNOTIFYEX = OFNOTIFYEXA;

const
  {$EXTERNALSYM CDN_FIRST}
  CDN_FIRST = -601;
  {$EXTERNALSYM CDN_LAST}
  CDN_LAST = -699;

{ Notifications when Open or Save dialog status changes }

  {$EXTERNALSYM CDN_INITDONE}
  CDN_INITDONE = CDN_FIRST - 0;
  {$EXTERNALSYM CDN_SELCHANGE}
  CDN_SELCHANGE = CDN_FIRST - 1;
  {$EXTERNALSYM CDN_FOLDERCHANGE}
  CDN_FOLDERCHANGE = CDN_FIRST - 2;
  {$EXTERNALSYM CDN_SHAREVIOLATION}
  CDN_SHAREVIOLATION = CDN_FIRST - 3;
  {$EXTERNALSYM CDN_HELP}
  CDN_HELP = CDN_FIRST - 4;
  {$EXTERNALSYM CDN_FILEOK}
  CDN_FILEOK = CDN_FIRST - 5;
  {$EXTERNALSYM CDN_TYPECHANGE}
  CDN_TYPECHANGE = CDN_FIRST - 6;
  {$EXTERNALSYM CDN_INCLUDEITEM}
  CDN_INCLUDEITEM = CDN_FIRST - 7;

  {$EXTERNALSYM CDM_FIRST}
  CDM_FIRST = WM_USER + 100;
  {$EXTERNALSYM CDM_LAST}
  CDM_LAST = WM_USER + 200;

{ Messages to query information from the Open or Save dialogs }

{ lParam = pointer to text buffer that gets filled in
  wParam = max number of characters of the text buffer (including NULL)
  return = < 0 if error; number of characters needed (including NULL) }

  {$EXTERNALSYM CDM_GETSPEC}
  CDM_GETSPEC = CDM_FIRST + 0;

{ lParam = pointer to text buffer that gets filled in
  wParam = max number of characters of the text buffer (including NULL)
  return = < 0 if error; number of characters needed (including NULL) }

  {$EXTERNALSYM CDM_GETFILEPATH}
  CDM_GETFILEPATH = CDM_FIRST + 1;

{ lParam = pointer to text buffer that gets filled in
  wParam = max number of characters of the text buffer (including NULL)
  return = < 0 if error; number of characters needed (including NULL) }

  {$EXTERNALSYM CDM_GETFOLDERPATH}
  CDM_GETFOLDERPATH = CDM_FIRST + 2;

{ lParam = pointer to ITEMIDLIST buffer that gets filled in
  wParam = size of the ITEMIDLIST buffer
  return = < 0 if error; length of buffer needed }

  {$EXTERNALSYM CDM_GETFOLDERIDLIST}
  CDM_GETFOLDERIDLIST = CDM_FIRST + 3;

{ lParam = pointer to a string
  wParam = ID of control to change
  return = not used }

  {$EXTERNALSYM CDM_SETCONTROLTEXT}
  CDM_SETCONTROLTEXT = CDM_FIRST + 4;

{ lParam = not used
  wParam = ID of control to change
  return = not used }

  {$EXTERNALSYM CDM_HIDECONTROL}
  CDM_HIDECONTROL = CDM_FIRST + 5;

{ lParam = pointer to default extension (no dot)
  wParam = not used
  return = not used }

  {$EXTERNALSYM CDM_SETDEFEXT}
  CDM_SETDEFEXT = CDM_FIRST + 6;

implementation

const
{$IFDEF MSWINDOWS}
  commdlg32 = 'comdlg32.dll';
{$ENDIF}
{$IFDEF LINUX}
{$IFDEF WINE}
  commdlg32 = 'libcomdlg32.borland.so';
{$ELSE}
  commdlg32 = 'libcommdlg.so';
{$ENDIF}
{$ENDIF}

function GetOpenFileName;      external commdlg32  name 'GetOpenFileNameA';
function GetOpenFileNameA;      external commdlg32  name 'GetOpenFileNameA';
function GetOpenFileNameW;      external commdlg32  name 'GetOpenFileNameW';
function GetSaveFileName;   external commdlg32  name 'GetSaveFileNameA';
function GetSaveFileNameA;   external commdlg32  name 'GetSaveFileNameA';
function GetSaveFileNameW;   external commdlg32  name 'GetSaveFileNameW';
function GetFileTitle;      external commdlg32  name 'GetFileTitleA';
function GetFileTitleA;      external commdlg32  name 'GetFileTitleA';
function GetFileTitleW;      external commdlg32  name 'GetFileTitleW';
end.

