library st_hook;

{ Wichtiger Hinweis zur DLL-Speicherverwaltung: ShareMem muss sich in der
  ersten Unit der unit-Klausel der Bibliothek und des Projekts befinden (Projekt-
  Quelltext anzeigen), falls die DLL Prozeduren oder Funktionen exportiert, die
  Strings als Parameter oder Funktionsergebnisse ¸bergeben. Das gilt f¸r alle
  Strings, die von oder an die DLL ¸bergeben werden -- sogar f¸r diejenigen, die
  sich in Records und Klassen befinden. Sharemem ist die Schnittstellen-Unit zur
  Verwaltungs-DLL f¸r gemeinsame Speicherzugriffe, BORLNDMM.DLL.
  Um die Verwendung von BORLNDMM.DLL zu vermeiden, kˆnnen Sie String-
  Informationen als PChar- oder ShortString-Parameter ¸bergeben. }

  (* Code by Assarbad *)

uses
  Windows,
  Messages,
  Types;

const
  WM_SpecialEvent = WM_User + 1678;

  APPCOMMAND_MEDIA_NEXTTRACK = 11;
  {$EXTERNALSYM APPCOMMAND_MEDIA_NEXTTRACK}
  APPCOMMAND_MEDIA_PREVIOUSTRACK = 12;
  {$EXTERNALSYM APPCOMMAND_MEDIA_PREVIOUSTRACK}
  APPCOMMAND_MEDIA_STOP = 13;
  {$EXTERNALSYM APPCOMMAND_MEDIA_STOP}
  APPCOMMAND_MEDIA_PLAY_PAUSE = 14;
  {$EXTERNALSYM APPCOMMAND_MEDIA_PLAY_PAUSE}

  VK_MEDIA_NEXT_TRACK = $B0;
  {$EXTERNALSYM VK_MEDIA_NEXT_TRACK}
  VK_MEDIA_PREV_TRACK = $B1;
  {$EXTERNALSYM VK_MEDIA_PREV_TRACK}
  VK_MEDIA_STOP = $B2;
  {$EXTERNALSYM VK_MEDIA_STOP}
  VK_MEDIA_PLAY_PAUSE = $B3;
  {$EXTERNALSYM VK_MEDIA_PLAY_PAUSE}

  FAPPCOMMAND_MASK  = $F000;

var
  KeyBdHookHandle: Cardinal = 0;
  ShlHookHandle : Cardinal = 0;
  WindowHandle: Cardinal = 0;


type
THookRec = record
   hKbdHook: HHOOK;
   hShlHook: HHOOK;
   Wnd: HWND;
end;

var
hMap: DWord;
buf: ^THookRec;


function KeyboardHookProc(nCode: Integer; wp: wParam; lp: lParam): LongInt; stdcall;
begin
//it's possible to call CallNextHookEx conditional only.
  if nCode >= HC_ACTION then
  begin
    case wP of
    VK_MEDIA_NEXT_TRACK,
    VK_MEDIA_PREV_TRACK,
    VK_MEDIA_STOP,
    VK_MEDIA_PLAY_PAUSE:
      begin
        SendMessage(buf^.Wnd,WM_SPECIALEVENT,wP,lP);
        Result := 1;
      end;
    else
      Result := CallNextHookEx(KeyBdHookHandle, nCode, wP, lP);
    end;
  end
  else
    Result := CallNextHookEx(KeyBdHookHandle, nCode, wP, lP);
end;

function GET_APPCOMMAND_LPARAM(LParamHi: Integer): Word;
begin
    Result := HiWord(lParamHi) and not FAPPCOMMAND_MASK;
end;

function ShellHookProc(nCode: Integer; wP: WPARAM; lP: LPARAM): LRESULT; stdcall;
var
  AppCommand : DWord;
begin
  if nCode = HSHELL_APPCOMMAND then
  begin
      AppCommand := GET_APPCOMMAND_LPARAM(lP);
      case AppCommand of
			  APPCOMMAND_MEDIA_NEXTTRACK,
			  APPCOMMAND_MEDIA_PLAY_PAUSE,
			  APPCOMMAND_MEDIA_PREVIOUSTRACK,
			  APPCOMMAND_MEDIA_STOP:
        begin
          SendMessage(buf^.Wnd,WM_APPCOMMAND,wP,lP);
          Result := 1;
        end;
        else
          Result := CallNextHookEx(ShlHookHandle, nCode, wP, lP);
      end;
  end
    else
      Result := CallNextHookEx(ShlHookHandle, nCode, wP, lP);
end;

// sets up hook
function SetHook(ProgHandle, OtherApp : integer): Boolean; stdcall; export;
begin
try
   Result := false;
   if (not assigned(buf)) then
   begin
     hMap := CreateFileMapping(DWord(-1), nil, PAGE_READWRITE, 0, SizeOf(THookRec), 'SmallTuneHookRecMemBlock');
     buf := MapViewOfFile(hMap, FILE_MAP_ALL_ACCESS, 0, 0, 0);
     
     buf^.hKbdHook := SetWindowsHookEx(WH_KEYBOARD, @KeyboardHookProc, hInstance, GetWindowThreadProcessId(OtherApp,nil)); // OtherApp=0 heiﬂt dann: globaler Hook
     buf^.hShlHook := SetWindowsHookEx(WH_SHELL, @ShellHookProc, hInstance, GetWindowThreadProcessId(OtherApp,nil));
     buf^.Wnd := HWND(ProgHandle);
     Result := true;
   end;
except
   Result := false;
   MessageBox(0, 'error in SetHook', 'error', MB_OK);
end;
end;

// removes hook
function RemoveHook: Boolean; stdcall; export;
begin
Result := false;
if (assigned(buf)) then
begin                 
   UnhookWindowsHookEx(buf^.hKbdHook);
   UnhookWindowsHookEx(buf^.hShlHook);
   buf^.hKbdHook := 0;
   buf^.hShlHook := 0;
   UnmapViewOfFile(buf);
   buf := nil;
   CloseHandle(hMap);
   hMap := 0;
   Result := true;
end;
end;

// DLL entry point
procedure DllEntry(dwReason: DWord);
begin
  Case dwReason of
    DLL_PROCESS_ATTACH:
    begin
      if (not assigned(buf)) then
      begin
        hMap := OpenFileMapping(FILE_MAP_ALL_ACCESS, false, 'SmallTuneHookRecMemBlock');
        buf := MapViewOfFile(hMap, FILE_MAP_ALL_ACCESS, 0, 0, 0);
        CloseHandle(hMap);
        hMap := 0;
      end;
    end;
    DLL_PROCESS_DETACH:
    begin
      if (not assigned(buf)) then
      begin
        UnmapViewOfFile(buf);
        buf := nil;
      end;
    end;
  end; { of case }
end;

exports
  SetHook,
  RemoveHook;

begin  // ‰hnlich dem initialization-Bereich bei Units
  DllProc := @DLLEntry;
  DllEntry(DLL_PROCESS_ATTACH);  // bewirkt: initiales Memery-Mappen
end.

