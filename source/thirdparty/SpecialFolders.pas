unit SpecialFolders;

{ Copyright © Michael Puff }

interface

uses windows;

const 
  SHGFP_TYPE_CURRENT = 0; 

const 
  CSIDL_FLAG_CREATE = $8000; 
  CSIDL_ADMINTOOLS  = $0030; 
  CSIDL_ALTSTARTUP  = $001D; 
  CSIDL_APPDATA     = $001A; 
  CSIDL_BITBUCKET   = $000A; 
  CSIDL_CDBURN_AREA = $003B; 
  CSIDL_COMMON_ADMINTOOLS = $002F; 
  CSIDL_COMMON_ALTSTARTUP = $001E; 
  CSIDL_COMMON_APPDATA = $0023; 
  CSIDL_COMMON_DESKTOPDIRECTORY = $0019; 
  CSIDL_COMMON_DOCUMENTS = $002E; 
  CSIDL_COMMON_FAVORITES = $001F; 
  CSIDL_COMMON_MUSIC = $0035; 
  CSIDL_COMMON_PICTURES = $0036; 
  CSIDL_COMMON_PROGRAMS = $0017; 
  CSIDL_COMMON_STARTMENU = $0016; 
  CSIDL_COMMON_STARTUP = $0018; 
  CSIDL_COMMON_TEMPLATES = $002D; 
  CSIDL_COMMON_VIDEO = $0037; 
  CSIDL_CONTROLS    = $0003; 
  CSIDL_COOKIES     = $0021; 
  CSIDL_DESKTOP     = $0000; 
  CSIDL_DESKTOPDIRECTORY = $0010; 
  CSIDL_DRIVES      = $0011; 
  CSIDL_FAVORITES   = $0006; 
  CSIDL_FONTS       = $0014; 
  CSIDL_HISTORY     = $0022; 
  CSIDL_INTERNET    = $0001; 
  CSIDL_INTERNET_CACHE = $0020; 
  CSIDL_LOCAL_APPDATA = $001C; 
  CSIDL_MYDOCUMENTS = $000C; 
  CSIDL_MYMUSIC     = $000D; 
  CSIDL_MYPICTURES  = $0027; 
  CSIDL_MYVIDEO     = $000E; 
  CSIDL_NETHOOD     = $0013; 
  CSIDL_NETWORK     = $0012; 
  CSIDL_PERSONAL    = $0005; 
  CSIDL_PRINTERS    = $0004; 
  CSIDL_PRINTHOOD   = $001B; 
  CSIDL_PROFILE     = $0028; 
  CSIDL_PROFILES    = $003E; 
  CSIDL_PROGRAM_FILES = $0026; 
  CSIDL_PROGRAM_FILES_COMMON = $002B; 
  CSIDL_PROGRAMS    = $0002; 
  CSIDL_RECENT      = $0008; 
  CSIDL_SENDTO      = $0009; 
  CSIDL_STARTMENU   = $000B; 
  CSIDL_STARTUP     = $0007; 
  CSIDL_SYSTEM      = $0025; 
  CSIDL_TEMPLATES   = $0015; 
  CSIDL_WINDOWS     = $0024; 

function GetSpecialFolder(HandleOwner: THandle; Folder: Integer): WideString;

implementation

  function SHGetFolderPathW(hwndOwner: HWND; nFolder: Integer; hToken: THandle; dwFlags: DWORD; pszPath: LPWSTR): 
  HRESULT; stdcall; external 'shell32.dll' name 'SHGetFolderPathW';



function GetSpecialFolder(HandleOwner: THandle; Folder: Integer): WideString;
var
  Res               : HRESULT;
  Buffer            : array[0..MAX_PATH - 1] of WCHAR;
begin
  Result := '';
  Res := SHGetFolderPathW(HandleOwner, Folder, 0, SHGFP_TYPE_CURRENT, Buffer);
  if Res = S_OK then
  begin
    Result := WideString(Buffer);
  end;
end;

end.
