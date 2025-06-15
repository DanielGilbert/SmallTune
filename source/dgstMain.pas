unit dgstMain;
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
* Version             : 0.3.1
* Date                : 12-2009
* Description         : SmallTune is a simple but powerful audioplayer for
*                       Windows
***************************************************************************}

interface

  uses
    Windows,
    WinInet,
    ShellAPI,
    Messages,
    dgstLog,
    tPnvOpenFileDlg,
    dgstTypeDef,
    dgstTranslator,
    dgstMediaClass,
    dgstCommCtrl,
    dgstHelper,
    dgstSysUtils,
    dgstInternetCP,
    dgstSettings,
    tPnvMiniGDIPlus,
    MpuAboutMsgBox,
    dynamic_bass240,
    tPstDisplay,
    dgstPlaylistWindow,
    dgstRadiobrowser,
    dgstRadiobrowserApi;

  function WinMain(_hInstance: HINST; hPrevInstance: HINST;
    lpCmdLine: PChar; nCmdShow: Integer): Integer; stdcall;

var
  OsInfo: TOSVERSIONINFO;

  //Main Window
  hwndPopUpMenu: HMenu;
  ShowWndFlag: bool;
  hwndBoldFont: HFONT;
  NCM: TNonClientMetrics;
  WinRect: TRect;
  //Tooltips
  hToolTip,
  //Trackbar
  hwndPosBar,
  //Volumebar
  hwndVolBar,
  //Toolbar
  hwndToolBar: HWND;

  Display: TDisplay;

  PlaylistWindow: TPlaylistWindow;
  RadiobrowserWindow: TRadiobrowser;
  RadiobrowserApi: TRadiobrowserApi;

  //URL Window
  hwndAddUrlWnd,
  hwndAddURlBtn,
  hwndCancelURlBtn,
  hwndURLEdt,
  hwndURLlbl: HWND;

  //Settings Window
  hwndGeneral,
  hwndAudio: HWND;

  //All Windows
  MediaCl: TMediaClass;
  
  AddingFiles : Boolean;

  gpp1, gpp2: TGpPoint;

  ItemsToAddCnt : Integer = 0;

  fISShowingSettings : Boolean = false;
  fIsShowingURLWnd    : Boolean = false;
  fIsTracking : Boolean = false;
  WindowWasMoved : Boolean = false;
  PinnWindow : Boolean = false;
  fAreHotkeysEnabled : Boolean = false;

  TimeMode : Byte = 0;

  InitialFormMousePosition,
  ScreenMouse: TPoint;
  MouseIsDown: Boolean; 

  msg : TMSG;
  aWnd : HWND;

  NID         : TNotifyIconData =
    (uID:1;
     uFlags:NIF_MESSAGE or NIF_ICON or NIF_TIP;
     uCallbackMessage:WM_TNAMSG;
     hIcon:0;
     szTip:wndClassname;);

    iccex : TInitCommonControlsEx =
    (dwSize:sizeof(TInitCommonControlsEx);
     dwICC:ICC_LISTVIEW_CLASSES or ICC_BAR_CLASSES;);

var
  WM_TASKBARCREATED : Cardinal = 0;
  lib: Cardinal;

implementation

function URLInputBoxDlgWndProc(hDlgWnd: HWND; uMsg: UINT; wp: WPARAM; lp: LPARAM): BOOL; stdcall; forward;
function SettingsDlgWndProc(hDlgWnd: HWND; uMsg: UINT; wp: WPARAM; lp: LPARAM): BOOL; stdcall; forward;

procedure SetTooltip(State: TstState);
begin
  NID.szTip := 'SmallTune';
  case State of

    stPlay:
      begin
          If (MediaCL.CurrentMediaItem.Title = '') AND (MediaCL.CurrentMediaItem.Artist = '') then
            StrCopy(NID.szTip,PChar(Translator[LNG_PLAYING_TNA] + ' ' + MediaCL.CurrentMediaItem.FileName))
          else
          begin
            If MediaCL.PlayerType = ptINetStream then
              StrCopy(NID.szTip,PChar(Translator[LNG_PLAYING_TNA] + ' ' + MediaCL.CurrentMediaItem.Title))
            else
              StrCopy(NID.szTip,PChar(Translator[LNG_PLAYING_TNA] + ' ' + MediaCL.CurrentMediaItem.Artist + ' - ' + MediaCL.CurrentMediaItem.Title))
          end;
        DestroyIcon(NID.hIcon);
        NID.hIcon := LoadImage(hInstance,MakeIntResource(ICN_TNA),IMAGE_ICON,16,16,LR_DEFAULTCOLOR);
        Shell_NotifyIcon(NIM_MODIFY,@NID);
      end;

    stPause:
      begin
          If (MediaCL.CurrentMediaItem.Title = '') AND (MediaCL.CurrentMediaItem.Artist = '') then
            StrCopy(NID.szTip,PChar(Translator[LNG_PAUSE_TNA] + ' ' + MediaCL.CurrentMediaItem.FileName))
          else
          begin
            If MediaCL.PlayerType = ptINetStream then
              StrCopy(NID.szTip,PChar(Translator[LNG_PAUSE_TNA] + ' ' + MediaCL.CurrentMediaItem.Title))
            else
              StrCopy(NID.szTip,PChar(Translator[LNG_PAUSE_TNA] + ' ' + MediaCL.CurrentMediaItem.Artist + ' - ' + MediaCL.CurrentMediaItem.Title))
          end;
        DestroyIcon(NID.hIcon);
        NID.hIcon := LoadImage(hInstance,MakeIntResource(ICN_TNA),IMAGE_ICON,16,16,LR_DEFAULTCOLOR);
        Shell_NotifyIcon(NIM_MODIFY,@NID);
      end;

    stStop:
      begin
          If (MediaCL.CurrentMediaItem.Title = '') AND (MediaCL.CurrentMediaItem.Artist = '') then
            StrCopy(NID.szTip,PChar(Translator[LNG_STOP_TNA] + ' ' + MediaCL.CurrentMediaItem.FileName))
          else
            StrCopy(NID.szTip,PChar(Translator[LNG_STOP_TNA] + ' ' + MediaCL.CurrentMediaItem.Artist + ' - ' + MediaCL.CurrentMediaItem.Title));
        DestroyIcon(NID.hIcon);
        NID.hIcon := LoadImage(hInstance,MakeIntResource(ICN_TNA),IMAGE_ICON,16,16,LR_DEFAULTCOLOR);
        Shell_NotifyIcon(NIM_MODIFY,@NID);
      end;

    stAddFolder:
      begin
        DestroyIcon(NID.hIcon);
        StrCopy(NID.szTip,PChar(Translator[LNG_ADDINGFILESTODATABASE]));
        NID.hIcon := LoadImage(hInstance,MakeIntResource(ICN_TNA),IMAGE_ICON,16,16,LR_DEFAULTCOLOR);
        Shell_NotifyIcon(NIM_MODIFY,@NID);
      end;

  end;

end;

{*procedure GetDropFiles(wP: wParam);
const
  FileMsk = '*.mp3;*.mp2;*.ogg;*.wma;*.flac;'; //'*.xm;*.it;*.mod;*.s3m';
var
  counts, size, i: integer;
  pcFilename: PChar;
  s, FExt: string;
begin
  pcFilename := nil;
  counts := DragQueryFile(wP, $FFFFFFFF, pcFilename, MAX_PATH-1);
  if counts > -1 then
  begin
    for i := 0 to counts - 1 do
    begin
      size := DragQueryFile(wP, i, nil, 0) + 1;
      pcFilename := GetMemory(size);
      try
        DragQueryFile(wP, i, pcFilename, size);
        setString(s, pcFilename, length(pcFilename));

        FExt := Ansilowercase(GetFileExtension(s)) + ';';
        if pos(FExt, FileMsk) <> 0 then
        begin
          if Settings.GetSetting('add_file_to_playlist') = '1' then
             AddMediaFile(s);
          if Settings.GetSetting('play_file_after_drop') = '1' then
          begin
            MediaCL.Load(s,-1);
            MediaCL.Play;
          end;
        end;
      finally
        FreeMem(pcFilename);
      end;
    end;
  end;
  DragFinish(wP);
end;*}

function AddMediaPL(PLEntries: TPlaylistEntries): Boolean;
begin
  Result := false;
end;

procedure SetMenuState(Enabled: Boolean);
begin
  EnableWindow(hwndToolBar, Enabled);
  if Enabled then
  begin
    EnableMenuItem(hwndPopUpMenu, IDC_PLAYLISTBTN, MF_BYCOMMAND or MF_ENABLED);
    EnableMenuItem(hwndPopUpMenu, IDM_ADDFILE, MF_BYCOMMAND or MF_ENABLED);
    EnableMenuItem(hwndPopUpMenu, IDM_ADDFOLDER, MF_BYCOMMAND or MF_ENABLED);
    EnableMenuItem(hwndPopUpMenu, IDM_REPEAT, MF_BYCOMMAND or MF_ENABLED);
    EnableMenuItem(hwndPopUpMenu, IDM_SHUFFLE, MF_BYCOMMAND or MF_ENABLED);
  end
  else
  begin
    EnableMenuItem(hwndPopUpMenu, IDC_PLAYLISTBTN, MF_BYCOMMAND or MF_DISABLED);
    EnableMenuItem(hwndPopUpMenu, IDM_ADDFILE, MF_BYCOMMAND or MF_DISABLED);
    EnableMenuItem(hwndPopUpMenu, IDM_ADDFOLDER, MF_BYCOMMAND or MF_DISABLED);
    EnableMenuItem(hwndPopUpMenu, IDM_REPEAT, MF_BYCOMMAND or MF_DISABLED);
    EnableMenuItem(hwndPopUpMenu, IDM_SHUFFLE, MF_BYCOMMAND or MF_DISABLED);
  end;
end;

procedure ToolBarUsingBitmap(wnd: HWND);
var
  ImgList : hImageList;
begin
  ImgList := IMAGELIST_Create(16, 16, ILC_COLOR32, 12, 0);

  if ImgList <> INVALID_HANDLE_VALUE then
  begin
    IMAGELIST_AddIcon(ImgList, LoadIcon(hInstance, MAKEINTRESOURCE(MEDIA_PAUS)));
    IMAGELIST_AddIcon(ImgList, LoadIcon(hInstance, MAKEINTRESOURCE(MEDIA_PLAY)));
    IMAGELIST_AddIcon(ImgList, LoadIcon(hInstance, MAKEINTRESOURCE(MEDIA_STOP)));
    IMAGELIST_AddIcon(ImgList, LoadIcon(hInstance, MAKEINTRESOURCE(MEDIA_PREV)));
    IMAGELIST_AddIcon(ImgList, LoadIcon(hInstance, MAKEINTRESOURCE(MEDIA_NEXT)));
    IMAGELIST_AddIcon(ImgList, LoadIcon(hInstance, MAKEINTRESOURCE(MEDIA_SEAR)));
    IMAGELIST_AddIcon(ImgList, LoadIcon(hInstance, MAKEINTRESOURCE(MEDIA_SHUF)));
    IMAGELIST_AddIcon(ImgList, LoadIcon(hInstance, MAKEINTRESOURCE(MEDIA_REPE)));
    IMAGELIST_AddIcon(ImgList, LoadIcon(hInstance, MAKEINTRESOURCE(MEDIA_ADD)));
    IMAGELIST_AddIcon(ImgList, LoadIcon(hInstance, MAKEINTRESOURCE(MEDIA_SEARCH_ARTIST)));
    IMAGELIST_AddIcon(ImgList, LoadIcon(hInstance, MAKEINTRESOURCE(MEDIA_PINN)));

    SendMessage(hwndToolBar, TB_BUTTONSTRUCTSIZE, sizeof(TTBBUTTON), 0);
    SendMessage(hwndToolBar, TB_ADDBUTTONS, length(tbButtons), LPARAM(@tbButtons));

    SendMessage(hwndToolbar, TB_SETIMAGELIST, 0, ImgList);
  end;
end;

function GetClientArea: TRect;
begin
  SystemParametersInfo(SPI_GETWORKAREA, 0, @Result, 0);
end;

procedure SetWindowPosition(wnd: HWND);
const
  PADDINGX = 0;
  PADDINGY = 0;
var
  TaskBarRct: TRect;
  X: Integer;
  Y: Integer;
  abd: TAppBarData;
begin
  GetWindowRect(wnd, WinRect);
  X := WinRect.TopLeft.X;
  Y := WinRect.TopLeft.Y;
  if (wnd <> INVALID_HANDLE_VALUE) AND not WindowWasMoved then
  begin
    FillChar(abd, SizeOf(TAppBarData), 0);
    abd.cbSize := SizeOf(TAppBarData);
    SHAppBarMessage(ABM_GETTASKBARPOS, abd);
    TaskBarRct := abd.rc;
    case abd.uEdge of

      ABE_TOP:
        begin
          X := TaskBarRct.BottomRight.X - PADDINGX - WindowWidth;
          Y := TaskBarRct.BottomRight.Y + PADDINGY;
          lg.WriteLog('Taskbar located on top', 'dgstMain', ltInformation, lmExtended);
        end;

      ABE_RIGHT:
        begin
          X := TaskBarRct.TopLeft.X - PADDINGX - WindowWidth;
          Y := TaskBarRct.BottomRight.Y - PADDINGY - WindowHeight;
          lg.WriteLog('Taskbar located on the right side', 'dgstMain', ltInformation, lmExtended);
        end;

      ABE_LEFT:
        begin
          X := TaskBarRct.BottomRight.X + PADDINGX;
          Y := TaskBarRct.BottomRight.Y - PADDINGY - WindowHeight;
          lg.WriteLog('Taskbar located on the left side', 'dgstMain', ltInformation, lmExtended);
        end;

      ABE_BOTTOM:
        begin
          X := TaskBarRct.BottomRight.X - PADDINGX - WindowWidth;
          Y := TaskbarRct.TopLeft.Y - PADDINGY - WindowHeight;
          lg.WriteLog('Taskbar located on bottom', 'dgstMain', ltInformation, lmExtended);
        end;
    end;
    //Logging
    lg.WriteLog('Window X: ' + IntToStr(X), 'dgstMain', ltInformation, lmNormal);
    lg.WriteLog('Window Y: ' + IntToStr(Y), 'dgstMain', ltInformation, lmNormal);
    lg.WriteLog('TaskBarRct.BottomRight.X: ' + IntToStr(TaskBarRct.BottomRight.X), 'dgstMain', ltInformation, lmNormal);
    lg.WriteLog('TaskBarRct.BottomRight.Y: ' + IntToStr(TaskBarRct.BottomRight.Y), 'dgstMain', ltInformation, lmNormal);
    lg.WriteLog('TaskBarRct.TopLeft.X: ' + IntToStr(TaskBarRct.TopLeft.X), 'dgstMain', ltInformation, lmNormal);
    lg.WriteLog('TaskBarRct.TopLeft.Y: ' + IntToStr(TaskBarRct.TopLeft.Y), 'dgstMain', ltInformation, lmNormal);
  end;
  MoveWindow(Wnd, X, Y, WindowWidth, WindowHeight, true);
end;

procedure OnAddFilesDone;
begin
  Display.SongTitel := Translator[LNG_ALLFILESADDED];
  Display.SongInfo := Translator[LNG_ADDINGFILESFINISHED];
  SetMenuState(true);
  AddingFiles := false;
  MediaCL.RebuildPlaylist;
  PlaylistWindow.Refresh();
  ItemsToAddCnt := 0;
end;

procedure OnAddFiles(CurFile: Integer; Init: Boolean);
begin
  if Init then
  begin
    AddingFiles := true;
    Display.SongTitel := Translator[LNG_INIT] + IntToStr(CurFile) ;
    Display.SongInfo := Translator[LNG_READINGWAIT];
    ItemsToAddCnt := CurFile;
  end
  else
  begin
    AddingFiles := true;
    Display.SongTitel := Translator[LNG_ALREADYREAD] + IntToStr(CurFile) + ' / ' + IntToStr(ItemsToAddCnt) ;
    Display.SongInfo := Translator[LNG_READINGWAIT];
  end;
end;

procedure OnStartPlayingTrack(Artist, Title, Album: String; Duration: Integer);
begin
  SendMessage(hwndPosBar, TBM_SETRANGE, wParam(true), MAKELONG(0, MediaCL.GetStreamDuration));
  If (Title = '') AND (Artist = '') then
  begin
    //StrCopy(NID.szTip,PChar(Translator[LNG_PLAYING_TNA] + ' ' + MediaCL.CurrentMediaItem.FileName));
    Display.SongTitel := MediaCL.CurrentMediaItem.FileName;
    Display.SongAlbum := Translator[LNG_UNKNOWN];
    Display.SongInfo := Translator[LNG_UNKNOWN];
    MediaCL.GetStreamDuration
  end
  else
  begin
    //StrCopy(NID.szTip,PChar(Translator[LNG_PLAYING_TNA] + ' ' + Artist + ' - ' + Title));
    Display.SongTitel := Title;
    Display.SongInfo := Artist;
    Display.SongAlbum := Album;
  end;
  SetTooltip(stPlay);
  Display.SongsAktIdx := MediaCL.CurrentMediaItem.RowID;
  Display.SongsMaxCount := MediaCL.ItemsInDB;
end;

procedure OnNewMeta(Title: String);
begin
  Display.SongTitel := Title;
  SetTooltip(stPlay);
end;

procedure ProcessMessages(hWnd: Cardinal);
var
  _msg: TMsg;
begin
  while PeekMessage(_msg, hWnd, 0, 0, PM_REMOVE) do
  begin
    TranslateMessage(_msg);
    DispatchMessage(_msg);
  end;
end;

procedure FadeWindow(Wnd: HWND; const dwTime: DWORD = 100);
var
  AlphaValue: integer;
begin
  // todo: zeitberechnung - dwTime
  ShowWndFlag := true;
  SetLayeredWindowAttributes(Wnd, 0, 0, LWA_ALPHA);
  ShowWindow(wnd, SW_SHOW);
  AlphaValue := 0;
  while (AlphaValue < 255) or (not IsWindowVisible(wnd)) do
  begin
    if AlphaValue <= 255 then
      SetLayeredWindowAttributes(Wnd, 0, AlphaValue, LWA_ALPHA);
    AlphaValue := AlphaValue + 25;
    ProcessMessages(Wnd);
    sleep(5);
  end;
  SetLayeredWindowAttributes(Wnd, 0, 255, LWA_ALPHA);
  ShowWndFlag := false;
end;

procedure AddToolTip(wnd: HWND; hInst: longword; lpText: pchar; ID: Integer);
var
  ti : TToolInfo;
  r  : TRect;
begin
  if(wnd <> 0) and (GetClientRect(wnd,r)) then
    begin
      fillchar(ti,sizeof(TToolInfo),0);

      ti.cbSize   := sizeof(TToolInfo);
      ti.uFlags   := TTF_SUBCLASS;
      ti.hwnd     := wnd;
      ti.uId      := ID;
      ti.Rect     := r;
      ti.hInst    := hInst;
      ti.lpszText := lpText;

      SendMessage(hToolTip,TTM_ADDTOOL,0,LPARAM(@ti));
    end;
end;

procedure UpdateToolTip(wnd: HWND; hInst: longword; lpText: pchar; ID: Integer);
var
  ti : TToolInfo;
begin
  if(wnd <> 0) then
    begin
      fillchar(ti,sizeof(TToolInfo),0);

      ti.cbSize   := sizeof(TToolInfo);
      ti.hwnd     := wnd;
      ti.uId      := ID;
      ti.hInst    := hInst;
      ti.lpszText := lpText;

      SendMessage(hToolTip,TTM_UPDATETIPTEXT,0,LPARAM(@ti));
    end;
end;

const
  FAPPCOMMAND_MASK  = $F000;

function GET_APPCOMMAND_LPARAM(LParamHi: Integer): Word;
begin
    Result := HiWord(lParamHi) and not FAPPCOMMAND_MASK;
end;


procedure  ModifyThePopUpMenu(hwndPopUpMenu: HMENU);
begin
  (* Update Menu *)
  ModifyMenu(hwndPopUpMenu, MMI_PLAYLIST, MF_BYPOSITION, MF_STRING, PChar(Translator[LNG_PLAYLIST]));
  ModifyMenu(hwndPopUpMenu, MMI_ADDFILE, MF_BYPOSITION, MF_STRING, PChar(Translator[LNG_ADDFILE]));
  ModifyMenu(hwndPopUpMenu, MMI_ADDFOLDER, MF_BYPOSITION, MF_STRING, PChar(Translator[LNG_ADDFOLDER]));
  ModifyMenu(hwndPopUpMenu, MMI_ADDURL, MF_BYPOSITION, MF_STRING, PChar(Translator[LNG_ADDURL]));
  ModifyMenu(hwndPopUpMenu, MMI_REPEAT , MF_BYPOSITION, MF_STRING, PChar(Translator[LNG_REPEATPLAYLIST]));
  ModifyMenu(hwndPopUpMenu, MMI_SHUFFLE, MF_BYPOSITION, MF_STRING, PChar(Translator[LNG_SHUFFLE]));
  ModifyMenu(hwndPopUpMenu, MMI_HELP, MF_BYPOSITION, MF_STRING, PChar(Translator[LNG_HELP]));
  ModifyMenu(hwndPopUpMenu, MMI_INFO, MF_BYPOSITION, MF_STRING, PChar(Translator[LNG_INFO]));
  ModifyMenu(hwndPopUpMenu, MMI_SETTINGS, MF_BYPOSITION, MF_STRING, PChar(Translator[LNG_SETTINGS]));
  ModifyMenu(hwndPopUpMenu, MMI_CLOSE, MF_BYPOSITION, MF_STRING, PChar(Translator[LNG_EXIT]));
end;

(* Main Window Function *)
function WndProc(wnd: HWND; uMsg: UINT; wp: WPARAM; lp: LPARAM): LRESULT;
  stdcall;
var
  pt: TPoint;
  lng, dir: String;
  PS: PaintStruct;
  i, n, pos, vol: Integer;
begin
  Result := 0;

  //Check, if the taskbar has crashed
  if uMsg = WM_TASKBARCREATED then
  begin
    NID.wnd         := wnd;
    NID.hIcon       := LoadImage(hInstance,MakeIntResource(ICN_TNA),IMAGE_ICON,16,16,LR_DEFAULTCOLOR);
    NID.szTip       := 'SmallTune';

    Shell_NotifyIcon(NIM_ADD,@NID);
    DestroyIcon(NID.hIcon);

    Lg.WriteLog('Taskbar crashed, reinit', 'dgstMain', ltWarning);
  end;

  case uMsg of
    WM_CREATE:
      begin
        //Init vars
        AddingFiles := false;
        Translator.MainWnd := wnd;
        WindowWasMoved := false;
        MouseIsDown := false;

        //Register message
        WM_TASKBARCREATED := RegisterWindowMessage('TaskbarCreated');

        //Create Trackbar
       hwndPosBar := CreateWindowEx(0, TRACKBAR_CLASS, 'PosBar',
          WS_CHILD or WS_VISIBLE or TBS_NOTICKS, TrackbarX, TrackbarY, TrackbarWidth, TrackbarHeight, wnd,
          IDT_POSBAR, hInstance, nil);

       //Create Volume bar
       hwndVolBar := CreateWindowEx(0, TRACKBAR_CLASS, 'VolBar',
          WS_CHILD or WS_VISIBLE or TBS_NOTICKS, VolumeTrackbarX, VolumeTrackbarY, VolumeTrackbarWidth, VolumeTrackbarHeight, wnd,
          IDT_POSBAR, hInstance, nil);

        //Toolbar
        hwndToolBar := CreateWindowEx(0, TOOLBARCLASSNAME, nil, WS_CHILD or
          WS_VISIBLE or CCS_NOPARENTALIGN or CCS_NORESIZE or TBSTYLE_FLAT or TBSTYLE_TOOLTIPS or TBSTYLE_TRANSPARENT,
          ToolbarX, ToolbarY, ToolbarWidth, ToolbarHeight, wnd, IDC_TOOLBAR, hInstance, nil);

        // Create tooltip windows
        hToolTip := CreateWindowEx(WS_EX_TOPMOST, TOOLTIPS_CLASS, nil,
          TTS_ALWAYSTIP or TTS_NOPREFIX or WS_POPUP,
          integer(CW_USEDEFAULT), integer(CW_USEDEFAULT), integer(CW_USEDEFAULT),
          integer(CW_USEDEFAULT), wnd, 0, hInstance, nil);

        if(hToolTip <> 0) then
          begin
            // Define tooltip as topmost
            SetWindowPos(hToolTip, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or
              SWP_NOSIZE or SWP_NOACTIVATE);

            // Set tooltips
            AddToolTip(hwndToolBar,hInstance,PChar(Translator[LNG_TTIP_PLAY]),IDC_STARTBTN);
            AddToolTip(hwndToolBar,hInstance,PChar(Translator[LNG_TTIP_NEXT]),IDC_NEXTBTN);
            AddToolTip(hwndToolBar,hInstance,PChar(Translator[LNG_TTIP_PREV]),IDC_PREVBTN);
            AddToolTip(hwndToolBar,hInstance,PChar(Translator[LNG_TTIP_PLS]),IDC_PLAYLISTBTN);
            AddToolTip(hwndToolBar,hInstance,PChar(Translator[LNG_TTIP_REPE]),IDC_REPEATBTN);
            AddToolTip(hwndToolBar,hInstance,PChar(Translator[LNG_TTIP_SHUF]),IDC_SHUFFLEBTN);
            AddToolTip(hwndToolBar,hInstance,PChar(Translator[LNG_TTIP_NOHIDE]),IDC_PINNER);

            SendMessage(hwndToolBar, TB_SETTOOLTIPS, hToolTip, 0);

            lg.WriteLog('Tooltips set', 'dgstMain', ltInformation, lmExtended);
          end;

        //Create Toolbarbuttons
        ToolBarUsingBitmap(wnd);

        // setup MediaClass
        MediaCL := TMediaClass.Create(wnd);
        try
          MediaCL.AppHandle := wnd;
          MediaCL.OnStartPlayingTrack := OnStartPlayingTrack;
          MediaCL.OnAddFiles := OnAddFiles;
          MediaCL.OnAddFilesDone := OnAddFilesDone;
          MediaCL.OnNewStreamMeta := OnNewMeta;
          MediaCL.Shuffle := false;
          MediaCL.ListRepeat := false;
          lg.WriteLog('MediaClass created', 'dgstMain', ltInformation, lmNormal);
        except
          lg.WriteLog('MediaClass creation failed', 'dgstMain', ltError);
          DestroyWindow(wnd);
        end;

        // setup Display
        Display := TDisplay.Create(wnd, DisplayWidth, DisplayHeight);
        try
          Display.SetSpectrumParameter(SpectrumX, SpectrumY, SpectrumWidth, SpectrumHeight, SpectrumBands);
          //Display.LoadImageFromResID(400);
          Display.SongTimeColor := $FFFFFFFF;
          Display.SongInfoColor := $FFD8D8D8;
          Display.SongIndexColor := $F0646464;
          Display.XSongTitelOffset := XSongTitelOffset;
          Display.XSongInfoOffset := XSongInfoOffset;
          Display.XSongIndexOffset := XSongIndexOffset;
          Display.YSongTitelOffset := YSongTitelOffset;
          Display.YSongInfoOffset := YSongInfoOffset;
          Display.YSongIndexOffset := YSongIndexOffset;
          Display.XSongPosTimeOffset := XSongPosTimeOffset;
          Display.YSongPosTimeOffset := YSongPosTimeOffset;
          Display.ShowReflection := false;
          lg.WriteLog('DisplayClass created', 'dgstMain');
        except
          lg.WriteLog('DisplayClass creation failed', 'dgstMain', ltError);
          DestroyWindow(Wnd);
        end;

        (* Notification Area *)

        NID.wnd         := wnd;
        NID.hIcon       := LoadImage(hInstance,MakeIntResource(ICN_TNA),IMAGE_ICON,16,16,LR_DEFAULTCOLOR);
        NID.szTip       := 'SmallTune';

        Shell_NotifyIcon(NIM_ADD,@NID);
        DestroyIcon(NID.hIcon);

        (* PopUp Menu *)
        hwndPopUpMenu := CreatePopupMenu;

        AppendMenu(hwndPopUpMenu, MF_STRING, IDC_PLAYLISTBTN, PChar(Translator[LNG_PLAYLIST]));
        AppendMenu(hwndPopUpMenu, MF_SEPARATOR, 0, nil);
        AppendMenu(hwndPopUpMenu, MF_STRING, IDM_ADDFILE, PChar(Translator[LNG_ADDFILE]));
        AppendMenu(hwndPopUpMenu, MF_STRING, IDM_ADDFOLDER, PChar(Translator[LNG_ADDFOLDER]));
        AppendMenu(hwndPopUpMenu, MF_STRING, IDM_ADDURL, PChar(Translator[LNG_ADDURL]));
        AppendMenu(hwndPopUpMenu, MF_SEPARATOR, 0, nil);
        MediaCL.InternetStations.CreateISMenu(hwndPopUpMenu);
        AppendMenu(hwndPopUpMenu, MF_SEPARATOR, 0, nil);
        AppendMenu(hwndPopUpMenu, MF_STRING, IDM_REPEAT, PChar(Translator[LNG_REPEATPLAYLIST]));
        AppendMenu(hwndPopUpMenu, MF_STRING, IDM_SHUFFLE, PChar(Translator[LNG_SHUFFLE]));
        AppendMenu(hwndPopUpMenu, MF_SEPARATOR, 0, nil);
        AppendMenu(hwndPopUpMenu, MF_STRING, IDM_HELP, PChar(Translator[LNG_HELP]));
        AppendMenu(hwndPopUpMenu, MF_STRING, IDM_INFO, PChar(Translator[LNG_INFO]));
        AppendMenu(hwndPopUpMenu, MF_SEPARATOR, 0, nil);
        AppendMenu(hwndPopUpMenu, MF_STRING, 0, PChar(Translator[LNG_SETTINGS]));
        AppendMenu(hwndPopUpMenu, MF_SEPARATOR, 0, nil);
        AppendMenu(hwndPopUpMenu, MF_STRING, IDM_CLOSEBTN, PChar(Translator[LNG_EXIT]));

        if Settings.GetSetting('main_window_pinned') = '1' then
        begin
          PinnWindow := True;
          SendMessage(hwndToolBar, TB_SETSTATE, IDC_PINNER, MAKELONG(TBSTATE_ENABLED or TBSTATE_CHECKED, 0));
        end
        else
          PinnWindow := False;

        if Settings.GetSetting('main_window_movable') = '1' then
          if Settings.GetSetting('save_main_window_pos') = '1' then
            begin
              MoveWindow(Wnd, StrToIntDef(Settings.GetSetting('main_window_x') , 0), StrToIntDef(Settings.GetSetting('main_window_y') , 0), WindowWidth, WindowHeight, true);
              WindowWasMoved := True;
            end;


        SendMessage(hwndVolBar, TBM_SETPOS, wParam(true), 100);

        //Finally, activate the timer
        SetTimer(Wnd, IDC_TIMER, 50, nil);

        lng := Settings.GetSetting('lng_sel');
        if (lng <> '') AND (lng <> 'N/A') then
          Translator.CurrentLanguage := lng;

      end;

  WM_DROPFILES:
    begin
      //GetDropFiles(wP);
    end;

   WM_ACTIVATEAPP:
      if not Boolean(wP) then
       begin
        MouseIsDown := false;
        if not PinnWindow then
          ShowWindow(aWnd, SW_HIDE);
       end;

    WM_SHOWWINDOW:
      begin
        if BOOL(wp) then
        begin
          SetWindowPosition(wnd);
          if not ShowWndFlag then FadeWindow(aWnd, 100);
        end;
        result := 0;
      end;

    WM_SPECIALEVENT:
      begin
        case wp of
          VK_MEDIA_NEXT_TRACK:
              SendMessage(wnd, WM_COMMAND, WPARAM(HiWord(BN_CLICKED) or LoWord(IDC_NEXTBTN)), 0);
          VK_MEDIA_PREV_TRACK:
              SendMessage(wnd, WM_COMMAND, WPARAM(HiWord(BN_CLICKED) or LoWord(IDC_PREVBTN)), 0);
          VK_MEDIA_PLAY_PAUSE:
              SendMessage(wnd, WM_COMMAND, WPARAM(HiWord(BN_CLICKED) or LoWord(IDC_STARTBTN)), 0);
        end;
      end;

    WM_LANGUAGEHASCHANGED:
      begin

        ModifyThePopUpMenu(hwndPopUpMenu);
        
        (* Update Tooltips *)
        UpdateToolTip(hwndToolBar,hInstance,PChar(Translator[LNG_TTIP_PLAY]),IDC_STARTBTN);
        UpdateToolTip(hwndToolBar,hInstance,PChar(Translator[LNG_TTIP_NEXT]),IDC_NEXTBTN);
        UpdateToolTip(hwndToolBar,hInstance,PChar(Translator[LNG_TTIP_PREV]),IDC_PREVBTN);
        UpdateToolTip(hwndToolBar,hInstance,PChar(Translator[LNG_TTIP_PLS]),IDC_PLAYLISTBTN);
        UpdateToolTip(hwndToolBar,hInstance,PChar(Translator[LNG_TTIP_REPE]),IDC_REPEATBTN);
        UpdateToolTip(hwndToolBar,hInstance,PChar(Translator[LNG_TTIP_SHUF]),IDC_SHUFFLEBTN);
        UpdateToolTip(hwndToolBar,hInstance,PChar(Translator[LNG_TTIP_SEARCHARTIST]),IDC_SEARCHWEBBTN);
        UpdateToolTip(hwndToolBar,hInstance,PChar(Translator[LNG_TTIP_NOHIDE]),IDC_PINNER);
        (* Update Tooltip *)
        (* Settings Wnd *)
        SetDlgItemText(hwndGeneral, IDC_GENERAL_AUTOSTART_CHK, PChar(Translator[LNG_SETTINGS_AUTOSTART]));
        SetDlgItemText(hwndGeneral, IDC_GENERAL_MAKEMOVABLE_CHK, PChar(Translator[LNG_SETTINGS_MOVEWINDOWPOS]));
        SetDlgItemText(hwndGeneral, IDC_GENERAL_SAVEWINDOWPOS_CHK, PChar(Translator[LNG_SETTINGS_SAVEWINDOWPOS]));
        SetDlgItemText(hwndGeneral, IDC_LNG_GBX, PChar(Translator[LNG_SETTINGS_LNG_GBX]));
        SetDlgItemText(hwndGeneral, IDC_GENERAL_GENERAL_GBX, PChar(Translator[LNG_SETTINGS_GENERAL_GBX]));
        SetDlgItemText(hwndGeneral, IDC_GENERAL_DRAGDROPGBX, PChar(Translator[LNG_SETTINGS_DRAGDROP_GBX]));
        SetDlgItemText(hwndGeneral, IDC_GENERAL_PLAYFILEDROP_CHK, PChar(Translator[LNG_SETTINGS_PLAYFILEDROP]));
        SetDlgItemText(hwndGeneral, IDC_GENERAL_ADDFILEDROP_CHK, PChar(Translator[LNG_SETTINGS_ADDFILEDROP]));

        SetDlgItemText(hwndAudio, IDC_BASS_32BIT_CHK, PChar(Translator[LNG_SETTINGS_BASS_FLOAT]));
        SetDlgItemText(hwndAudio, IDC_BASS_MONO_CHK, PChar(Translator[LNG_SETTINGS_BASS_MONO]));
        SetDlgItemText(hwndAudio, IDC_BASS_HWACCEL_CHK, PChar(Translator[LNG_SETTINGS_BASS_NOHW]));
        SetDlgItemText(hwndAudio, IDC_BASS_TECH_GBX, PChar(Translator[LNG_SETTINGS_BASS_TECH_GBX]));

        Settings.WriteSetting('lng_sel', Translator.CurrentLanguage);
      end;

    WM_CHANGE_PLAYERTYPE:
      begin
        Display.__Rendering := False;
        if ASSIGNED(MediaCL) and ASSIGNED(Display) then
        begin
          case MediaCL.PlayerType of
            ptFileStream:
              begin
                //Display.LoadImageFromResID(400);
                Display.ShowTime := True;
                Display.ShowSongIndex := true;
                EnableWindow(hwndPosBar, True);
              end;
            ptINetStream:
              begin
                //Display.LoadImageFromResID(401);
                Display.ShowTime := False;
                Display.ShowSongIndex := False;
                EnableWindow(hwndPosBar, False);
              end;
            ptChipTune:
              begin
                //Display.LoadImageFromResID(402);
                Display.ShowTime := True;
                Display.ShowSongIndex := true;
                EnableWindow(hwndPosBar, True);
              end;
          end;
        end;
        Display.__Rendering := True;
      end;

    WM_APPCOMMAND: // Multimedia keys ( >= Windows XP Sp1 )
    begin
      
      case GET_APPCOMMAND_LPARAM(lP) of
        APPCOMMAND_MEDIA_STOP:
        begin
          lg.WriteLog('AppCommand received: [Stop]', 'dgstMain');
          PostMessage(wnd, WM_COMMAND, WPARAM(HiWord(BN_CLICKED) or LoWord(IDC_STOPBTN)), 0);
          Result := 1;
        end;

        APPCOMMAND_MEDIA_PLAY_PAUSE:
        begin
          lg.WriteLog('AppCommand received: [Play/Pause]', 'dgstMain');
          PostMessage(wnd, WM_COMMAND, WPARAM(HiWord(BN_CLICKED) or LoWord(IDC_STARTBTN)), 0);
          Result := 1;
        end;

        APPCOMMAND_MEDIA_NEXTTRACK:
        begin
          lg.WriteLog('AppCommand received: [Next]', 'dgstMain');
          PostMessage(wnd, WM_COMMAND, WPARAM(HiWord(BN_CLICKED) or LoWord(IDC_NEXTBTN)), 0);
          Result := 1;
        end;

        APPCOMMAND_MEDIA_PREVIOUSTRACK:
        begin
          lg.WriteLog('AppCommand received: [Prev]', 'dgstMain');
          PostMessage(wnd, WM_COMMAND, WPARAM(HiWord(BN_CLICKED) or LoWord(IDC_PREVBTN)), 0);
          Result := 1;
        end;
      end;
    end;

    WM_RBUTTONUP: TimeMode := (TimeMode + 1) mod 3; // swap Time mode;

    WM_LBUTTONDOWN:
    begin
      with InitialFormMousePosition do
      begin
        X := Word( lP );
        Y := Word( lP shr 16 );
      end;
      MouseIsDown := True;
    end;

    WM_LBUTTONUP:
    begin
      MouseIsDown := False;
    end;

    WM_TNAMSG:
      case lp of

        WM_RBUTTONUP:
          begin
            GetCursorPos(pt);
            SetForegroundWindow(wnd);
            TrackPopupMenu(hwndPopUpMenu,TPM_RIGHTALIGN,pt.X,pt.Y,0,wnd,nil);
          end;

        WM_LBUTTONUP:
          begin
            SetForegroundWindow(wnd);
            ShowWindow(wnd, SW_SHOW);
          end;

        WM_MBUTTONUP:
          begin
            SetForegroundWindow(wnd);
            SendMessage(wnd, WM_COMMAND, WPARAM(HiWord(BN_CLICKED) or LoWord(IDC_PLAYLISTBTN)), 0);
          end;
      end;

    WM_HSCROLL:  // Broadcasted by changing the slider position
    begin
      case LoWord(wP) of  // LoWord contains the corresponding codes
        TB_THUMBTRACK,  // drag the "Slider"
        TB_PAGEDOWN,  // Page down and clicked
        TB_PAGEUP:  // Page up and clicked
        begin
          if GetCapture = hwndPosBar then
          begin
            if MediaCL.IsPlaying then
            begin
              pos := SendMessage(hwndPosBar, TBM_GETPOS, 0, 0);
              Display.SongPosTime := Format('%3.2d:%2.2d', [pos div 60, abs(pos mod 60)]);
              MediaCL.SetNewPosition(pos);
            end;
          end;
          if GetCapture = hwndVolBar then
          begin
            vol := SendMessage(hwndVolBar, TBM_GETPOS, 0, 0);
            //Display.SongPosTime := Format('%3.2d:%2.2d', [pos div 60, abs(pos mod 60)]);
            MediaCL.SetNewVolume(vol / 100.0);
          end;
        end;
      end;
    End;


    WM_TIMER:
      begin
        InvalidateRect(wnd, nil, false);
        if not AddingFiles then
          if GetCapture <> hwndPosBar then
          begin
            pos := MediaCL.GetStreamPos(TimeMode);
            Display.SongPosTime := Format('%3.2d:%2.2d', [pos div 60, abs(pos mod 60)]);
            SendMessage(hwndPosBar, TBM_SETPOS, wParam(true), MediaCL.GetStreamPosForTB);
          end;

      end;

    WM_CLOSE:
      begin
        DestroyWindow(wnd);
      end;

    WM_DESTROY:
      begin
        //Save Settings
        if WindowWasMoved then
        begin
          GetWindowRect(wnd, WinRect);
          Settings.WriteSetting('main_window_x',IntToStr(WinRect.TopLeft.X));
          Settings.WriteSetting('main_window_y',IntToStr(WinRect.TopLeft.Y));
        end;
        Settings.SaveSettings;
        KillTimer(wnd, IDC_TIMER);
        Display.Free;
        MediaCL.Free;
        Shell_NotifyIcon(NIM_DELETE,@NID);
        DestroyMenu(hwndPopUpMenu);

        PostQuitMessage(0);
      end;

    WM_PAINT :
      begin
        BeginPaint(Wnd, Ps);
        Display.DrawTo(Ps.hdc, 2, 2, MediaCL.CurrentStream);
        EndPaint(Wnd, Ps);
      end;

    WM_NCHITTEST:
      begin
        Result := HTCLIENT;
      end;

    WM_MENUCOMMAND:
    begin
      if DWORD(lp) <> hwndPopUpMenu then
      begin
        for n := 0 to Length(MediaCL.InternetStations.GenreList.Genres) - 1 do
        begin
          if MediaCL.InternetStations.GenreList.Genres[n].MenuHandle = DWORD(lp) then
          begin
            if MediaCL.InternetStations.GenreList.Genres[n].Stations[wp].URL <> '' then
              MediaCL.RunInternetStream(MediaCL.InternetStations.GenreList.Genres[n].Stations[wp].URL);
          end;
        end;
      end
      else
      begin
        case wp of

          MMI_PLAYLIST :
          begin
            if not PlaylistWindow.IsShowingPlaylist then
            begin
              PlaylistWindow.Show();
            end;
          end;

          MMI_ADDFILE :
          begin
            with TOpenFileDlg.Create(wnd) do
            try
              FileFilter := Translator[LNG_FILEFILTERSTRING];
              Multiselect := true;
              if Execute then
              begin
                for i := 0 to Length(Files) - 1 do
                PlaylistWindow.AddMediaFile(Files[i]);
              end;
            finally
              Free;
            end;
          end;

          MMI_ADDFOLDER :
          begin
            dir := OpenFolder(Translator[LNG_SELECTFOLDER],'');
            if dir <> '' then
            begin
              SetMenuState(False);
              MediaCL.Stop;
              MediaCL.AddFolderToDatabase(dir);
            end;
          end;

          MMI_ADDURL :
            begin
              if not fIsShowingUrlWnd then
              begin
                fIsShowingUrlWnd := true;
                if DialogBox(hInstance, MAKEINTRESOURCE(6000), wnd, @URLInputBoxDlgWndProc) = IDOK then
                begin
                end;
              end;
            end;

          MMI_REPEAT :
          begin
            if GetMenuState(hwndPopUpMenu, MMI_REPEAT, MF_BYPOSITION) <> MF_CHECKED then
            begin
              CheckMenuItem(hwndPopUpMenu, MMI_REPEAT, MF_BYPOSITION or MF_CHECKED);
              SendMessage(hwndToolBar, TB_SETSTATE, IDC_REPEATBTN, TBSTATE_CHECKED or TBSTATE_ENABLED);
              MediaCL.ListRepeat := true;
            end
            else
            begin
              CheckMenuItem(hwndPopUpMenu, MMI_REPEAT, MF_BYPOSITION or MF_UNCHECKED);
              SendMessage(hwndToolBar, TB_SETSTATE, IDC_REPEATBTN, TBSTATE_ENABLED);
              MediaCL.ListRepeat := false;
            end;
          end;

          MMI_SHUFFLE :
          begin
            if GetMenuState(hwndPopUpMenu, MMI_SHUFFLE, MF_BYPOSITION) <> MF_CHECKED then
            begin
              CheckMenuItem(hwndPopUpMenu, MMI_SHUFFLE, MF_BYPOSITION or MF_CHECKED);
              SendMessage(hwndToolBar, TB_SETSTATE, IDC_SHUFFLEBTN, TBSTATE_CHECKED or TBSTATE_ENABLED);
              MediaCl.Shuffle := true;
            end
            else
            begin
              CheckMenuItem(hwndPopUpMenu, MMI_SHUFFLE, MF_BYPOSITION or MF_UNCHECKED);
              SendMessage(hwndToolBar, TB_SETSTATE, IDC_SHUFFLEBTN, TBSTATE_ENABLED);
              MediaCl.Shuffle := false;
            end;
          end;

          MMI_HELP :
          begin
            ShellExecute(wnd, 'open', PChar('http://smalltune.net/docs'), nil, nil, SW_SHOW);
          end;

          MMI_INFO :
          begin
            with TAbout.Create(wnd) do
            try
              Customized := True;
              IDIcon := 1;
              Display(APPNAME, '© 2009 - 2025, Daniel Gilbert' + #10#13 + #10#13 + 'Special Thanks to turboPASCAL ' + #10#13 + #10#13 + 'Thanks to HalloDu, Ibccaleb, Michael Puff (†)', 'http://smalltune.net');
            finally
              Free;
            end;
          end;

          MMI_CLOSE :
          begin
            SendMessage(wnd, WM_CLOSE, 0, 0);
          end;

          MMI_SETTINGS :
          begin
            if not fIsShowingSettings then
            begin
              fIsShowingSettings := true;
              DialogBox(hInstance, MAKEINTRESOURCE(10000), wnd, @SettingsDlgWndProc);
            end;
          end;
    
        end;
      end;
    end;

    WM_COMMAND:
      begin
        case HIWORD(wp) of
          BN_CLICKED:
            case loword(wp) of

              IDC_STARTBTN:
              begin
                if MediaCL.IsPlaying then
                begin
                  MediaCL.Pause
                end
                else
                begin
                  if MediaCL.CurrentPlayListPos = -1 then
                  begin
                    MediaCL.CurrentPlayListPos := 0;
                    MediaCL.Load(MediaCL.CurrentMediaItem.FilePath, MediaCL.CurrentPlayListPos);
                  end;
                  MediaCL.Play;
                end;
              end;

              IDC_STOPBTN:
              begin
                MediaCL.Stop;
                SetTooltip(stStop);
              end;

              IDC_NEXTBTN:
              begin
                MediaCl.PlayNextTrack;
                SetTooltip(stPlay);
              end;

              IDC_PREVBTN:
              begin
                MediaCl.PlayPreviousTrack;
                SetTooltip(stPlay);
              end;

              IDC_PLAYLISTBTN:
              begin
                if not PlaylistWindow.IsShowingPlaylist then
                begin
                  PlaylistWindow.Show();
                end;
              end;

              IDC_SETTINGSBTN:
              begin

              end;

              IDC_SHUFFLEBTN:
              begin
                if SendMessage(hwndToolBar, TB_ISBUTTONCHECKED, IDC_SHUFFLEBTN, 0) <> 0 then
                begin
                  CheckMenuItem(hwndPopUpMenu, MMI_SHUFFLE, MF_BYPOSITION or MF_CHECKED);
                  MediaCl.Shuffle := true;
                end
                else
                begin
                  CheckMenuItem(hwndPopUpMenu, MMI_SHUFFLE, MF_BYPOSITION or MF_UNCHECKED);
                  MediaCl.Shuffle := false;
                end;
              end;

              IDC_RADIOBROWSERBTN:
              begin
                if not RadiobrowserWindow.IsShowing then
                begin
                  RadiobrowserWindow.Show();
                end;
              end;

              IDC_REPEATBTN:
              begin
                if SendMessage(hwndToolBar, TB_ISBUTTONCHECKED, IDC_REPEATBTN, 0) <> 0 then
                begin
                  CheckMenuItem(hwndPopUpMenu, MMI_REPEAT, MF_BYPOSITION or MF_CHECKED);
                  MediaCl.ListRepeat := true;
                end
                else
                begin
                  CheckMenuItem(hwndPopUpMenu, MMI_REPEAT, MF_BYPOSITION or MF_UNCHECKED);
                  MediaCl.ListRepeat := false;
                end;
              end;

              IDC_PINNER:
              begin
                PinnWindow := not PinnWindow;
                case PinnWindow of
                  TRUE: Settings.WriteSetting('main_window_pinned','1');
                  FALSE: Settings.WriteSetting('main_window_pinned','0');
                end;
              end;
            end;
        end;
      end
    else
      Result := DefWindowProc(wnd, uMsg, wp, lp);
  end;
end;

(* URL Window Function *)
type
  hInternet = Pointer;

const
  WININETDLL = 'wininet.dll';

  INTERNET_OPEN_TYPE_PRECONFIG_WITH_NO_AUTOPROXY  = 4;
  INTERNET_FLAG_EXISTING_CONNECT                  = $20000000;
  HTTP_QUERY_STATUS_CODE                          = 19;

  function InternetOpen(lpszAgent: PChar; dwAccessType: DWORD; lpszProxy: PChar;
    lpszProxyBypass: PChar; dwFlags: DWORD): HINTERNET; stdcall;
    external WININETDLL name 'InternetOpenA';

  function InternetOpenUrl(hInet: HINTERNET; lpszUrl: PChar; lpszHeaders: PChar;
    dwHeadersLength: DWORD; dwFlags: DWORD; dwContext: DWORD): HINTERNET; stdcall;
    external WININETDLL name 'InternetOpenUrlA';

  function HttpQueryInfo(hRequest: HINTERNET; dwInfoLevel: DWORD; lpvBuffer: Pointer;
    var lpdwBufferLength: DWORD; var lpdwIndex: DWORD): BOOL; stdcall;
    external WININETDLL name 'HttpQueryInfoA';

  function InternetCloseHandle(hInet: HINTERNET): BOOL; stdcall;
    external WININETDLL name 'InternetCloseHandle';

function CheckUrl(url: string; const AutoAddHTMLID: Boolean = True): boolean;
var
  hInet: HINTERNET;
  hConnect: HINTERNET;
  infoBuffer: array [0..512] of char;
  d, bufLen: DWORD;
begin
  Result := False;
  if url <> '' then
  begin
    if AutoAddHTMLID then
      if pos('http://', AnsiLowerCase(url)) = 0 then url := 'http://' + url;

    hInet := InternetOpen(nil, INTERNET_OPEN_TYPE_PRECONFIG_WITH_NO_AUTOPROXY, nil, nil, 0);
    if ASSIGNED(hInet) then
    begin
      hConnect := InternetOpenUrl(hInet, PChar(url), nil, 0, INTERNET_FLAG_EXISTING_CONNECT, 0);
      if ASSIGNED(hConnect) then
      begin
        d := 0;
        bufLen := length(infoBuffer);
        ZeroMemory(@infoBuffer, length(infoBuffer));
        if HttpQueryInfo(hConnect,HTTP_QUERY_STATUS_CODE, @infoBuffer[0], bufLen, d) then
        begin
          if infoBuffer = '200' then Result := True // File exists
          { Val(infoBuffer, nInfo, d); // genauere Auswertung
          if d = 0 then
          begin
            case nInfo of
              401: not authorised, page exists
              404: no file
              500: Internal server error.
              else unbekannter fehler
            end;
          end else Fehler bei nInfo  }
        end;
        InternetCloseHandle(hConnect);
      end;
    end;
    InternetCloseHandle(hInet);
  end;
end;

const
  IDD_DLG1 = 6000;
  IDC_CBO1 = 6012;
  IDC_EDT1 = 6007;
  IDC_STC1 = 6008;
  IDC_IMG1 = 6011;
  IDC_RBN1 = 6005;
  IDC_RBN2 = 6006;
  IDC_EDT2 = 6009;
  IDC_STC2 = 6010;
  IDC_TRV1 = 6001;
  IDC_BTN3 = 6013;
  IDC_BTN2 = 6017;
  IDC_EDT3 = 6019;

  IS_PARENT = 128;
  IS_CHILD = 256;

const
  EM_SETCUEBANNER = $1501;

procedure Edit_SetCueBannerText(hDlgWnd: HWND; IDDglItem: Integer; lpwText: PWideChar);
begin
  if (OsInfo.dwMajorVersion >= 5) then
    SendDlgItemMessage(hDlgWnd, IDDglItem, EM_SETCUEBANNER, WPARAM(True), LPARAM(lpwText));
end;

(* TreeView Funcs *)
procedure FillTreeView(hDlgWnd: Hwnd; ItmID: Cardinal);
var
  tmptv : HTREEITEM;
  tvi: TTVInsertStruct;
  i: integer;
  n: integer;
begin
  SendDlgItemMessage(hDlgWnd, ItmID, TVM_DELETEITEM, 0, LPARAM(HTREEITEM(TVI_ROOT)));
  for I := 0 to Length(MediaCL.InternetStations.GenreList.Genres) - 1 do
  begin
    tvi.hParent := nil;
    tvi.hInsertAfter := TVI_LAST;
    tvi.item.mask := TVIF_TEXT or TVIF_PARAM or TVIF_CHILDREN;
    tvi.item.cChildren := 1;
    tvi.item.cchTextMax := SizeOf(MediaCL.InternetStations.GenreList.Genres[I].Name);
    tvi.item.pszText := PChar( MediaCL.InternetStations.GenreList.Genres[I].Name + #0);
    tvi.item.lParam := I;
    if ItmID <> 0 then
    begin
      tmptv := HTREEITEM( SendDlgItemMessage(hDlgWnd, ItmID, TVM_INSERTITEM, 0, Longint(@tvi)) );
      if tmptv <> nil then
      for n := 0 to Length(MediaCL.InternetStations.GenreList.Genres[i].Stations) - 1 do
      begin
        tvi.hParent := tmptv;
        tvi.hInsertAfter := TVI_LAST;
        tvi.item.mask := TVIF_TEXT or TVIF_PARAM or TVIF_CHILDREN;
        tvi.item.cchTextMax := SizeOf(MediaCL.InternetStations.GenreList.Genres[i].Stations[n].Name);
        tvi.item.pszText := PChar( MediaCL.InternetStations.GenreList.Genres[i].Stations[n].Name + #0);
        tvi.item.cChildren := 0;
        tvi.item.lParam := MediaCL.InternetStations.GenreList.Genres[i].Stations[n].ID;
        SendDlgItemMessage(hDlgWnd, ItmID, TVM_INSERTITEM, 0, Longint(@tvi));
      end;
    end;
  end;
end;

(* TreeView Funcs *)
procedure FillSettingsTreeView(hDlgWnd: Hwnd; ItmID: Cardinal);
var
  tvi: TTVInsertStruct;
begin
  SendDlgItemMessage(hDlgWnd, ItmID, TVM_DELETEITEM, 0, LPARAM(HTREEITEM(TVI_ROOT)));
  //Initialize structure for Root Item
  tvi.hParent := nil;
  tvi.hInsertAfter := TVI_LAST;
  tvi.item.mask := TVIF_TEXT or TVIF_PARAM or TVIF_CHILDREN;
  tvi.item.cChildren := 0;
  tvi.item.lParam := 1;
  tvi.item.cchTextMax := SizeOf(PChar( 'General' + #0));
  tvi.item.pszText := PChar( 'General' + #0);
  //Create Root Item
  SendDlgItemMessage(hDlgWnd, ItmID, TVM_INSERTITEM, 0, Longint(@tvi));
  //Initialize structure for Root Item
  tvi.hParent := nil;
  tvi.hInsertAfter := TVI_LAST;
  tvi.item.mask := TVIF_TEXT or TVIF_PARAM;
  tvi.item.lParam := 3;
  tvi.item.cchTextMax := SizeOf(PChar( 'Audio' + #0));
  tvi.item.pszText := PChar( 'Audio' + #0);
  SendDlgItemMessage(hDlgWnd, ItmID, TVM_INSERTITEM, 0, Longint(@tvi));
end;

procedure FillHotkeyCbxs(hDlgWnd: HWND; ID: Integer);
var
  i: integer;
begin
    for i := 65 to 90 do
      SendDlgItemMessage(hDlgWnd, ID, CB_ADDSTRING, 0, INTEGER(PCHAR(String(CHR(I)))));

      SendDlgItemMessage(hDlgWnd, ID, CB_ADDSTRING, 0, INTEGER(PCHAR(String(Translator[LNG_LEFT_ARROW_KEY]))));
      SendDlgItemMessage(hDlgWnd, ID, CB_ADDSTRING, 0, INTEGER(PCHAR(String(Translator[LNG_UP_ARROW_KEY]))));
      SendDlgItemMessage(hDlgWnd, ID, CB_ADDSTRING, 0, INTEGER(PCHAR(String(Translator[LNG_RIGHT_ARROW_KEY]))));
      SendDlgItemMessage(hDlgWnd, ID, CB_ADDSTRING, 0, INTEGER(PCHAR(String(Translator[LNG_DOWN_ARROW_KEY]))));
      SendDlgItemMessage(hDlgWnd, ID, CB_ADDSTRING, 0, INTEGER(PCHAR(String(Translator[LNG_SPACE_KEY]))));
      SendDlgItemMessage(hDlgWnd, ID, CB_ADDSTRING, 0, INTEGER(PCHAR(String(Translator[LNG_HOME_KEY]))));
      SendDlgItemMessage(hDlgWnd, ID, CB_ADDSTRING, 0, INTEGER(PCHAR(String(Translator[LNG_END_KEY]))));
      SendDlgItemMessage(hDlgWnd, ID, CB_ADDSTRING, 0, INTEGER(PCHAR(String(Translator[LNG_PAGE_UP_KEY]))));
      SendDlgItemMessage(hDlgWnd, ID, CB_ADDSTRING, 0, INTEGER(PCHAR(String(Translator[LNG_PAGE_DOWN_KEY]))));

    for I := 48 to 57 do
      SendDlgItemMessage(hDlgWnd, ID, CB_ADDSTRING, 0, INTEGER(PCHAR(String(CHR(I)))));

    for I := 73 to 95 do
      SendDlgItemMessage(hDlgWnd, ID, CB_ADDSTRING, 0, INTEGER(PCHAR(String(Translator[i]))));
end;

function SettingsTabsDlgWndProc(hDlgWnd: HWND; uMsg: UINT; wp: WPARAM; lp: LPARAM): BOOL; stdcall;
var
  CBChecked: Boolean;
  i: Integer;
begin
  result := true;
  case uMsg of
    WM_INITDIALOG:
      begin
        //Fill Language Cbx
        for i := 0 to Length(Translator.AvailableLanguages.fLng) - 1 do
          SendDlgItemMessage(hDlgWnd, IDC_LANG_CBX, CB_ADDSTRING, 0, INTEGER(PCHAR(String(Translator.AvailableLanguages.fLng[i].ClearName))));

        //Set current Language
        for i := 0 to Length(Translator.AvailableLanguages.fLng) - 1 do
          if Translator.CurrentLanguage = Translator.AvailableLanguages.fLng[i].ISO_Code then
            SendDlgItemMessage(hDlgWnd, IDC_LANG_CBX, CB_SETCURSEL, i, 0);

        //Disable "Start with Windows"
         EnableWindow(GetDlgItem(hDlgWnd, IDC_GENERAL_AUTOSTART_CHK), false);

        //KEYS
        FillHotkeyCbxs(hDlgWnd,IDC_PLAYPAUSE_HKEY_CBX);
        FillHotkeyCbxs(hDlgWnd,IDC_NEXT_HKEY_CBX);
        FillHotkeyCbxs(hDlgWnd,IDC_PREV_HKEY_CBX);
        FillHotkeyCbxs(hDlgWnd,IDC_HKEY_PLAYLIST_CBX);
        FillHotkeyCbxs(hDlgWnd,IDC_HKEY_SHUFFLE_CBX);
        FillHotkeyCbxs(hDlgWnd,IDC_HKEY_REPEAT_CBX);

        //Checkboxes
        if Settings.GetSetting('main_window_movable') = '1' then
        begin
          SendDlgItemMessage(hDlgWnd, IDC_GENERAL_MAKEMOVABLE_CHK ,BM_SETCHECK,BST_CHECKED,0);
          EnableWindow(GetDlgItem(hDlgWnd, IDC_GENERAL_SAVEWINDOWPOS_CHK), true);
        end;

        if Settings.GetSetting('save_main_window_pos') = '1' then
          SendDlgItemMessage(hDlgWnd, IDC_GENERAL_SAVEWINDOWPOS_CHK ,BM_SETCHECK,BST_CHECKED,0);

        if Settings.GetSetting('multimedia_keys_activated') = '1' then
          SendDlgItemMessage(hDlgWnd, IDC_MMKEYS_HKEY_CHK ,BM_SETCHECK,BST_CHECKED,0);

        if Settings.GetSetting('start_with_windows') = '1' then
          SendDlgItemMessage(hDlgWnd, IDC_GENERAL_AUTOSTART_CHK ,BM_SETCHECK,BST_CHECKED,0);

        if Settings.GetSetting('play_file_after_drop') = '1' then
          SendDlgItemMessage(hDlgWnd, IDC_GENERAL_PLAYFILEDROP_CHK ,BM_SETCHECK,BST_CHECKED,0);

        if Settings.GetSetting('add_file_to_playlist') = '1' then
          SendDlgItemMessage(hDlgWnd, IDC_GENERAL_ADDFILEDROP_CHK ,BM_SETCHECK,BST_CHECKED,0);

        if Settings.GetSetting('use_32_bit') <> '0' then
          SendDlgItemMessage(hDlgWnd, IDC_BASS_32BIT_CHK ,BM_SETCHECK,BST_CHECKED,0);

        if Settings.GetSetting('play_mono') <> '0' then
          SendDlgItemMessage(hDlgWnd, IDC_BASS_MONO_CHK ,BM_SETCHECK,BST_CHECKED,0);

        if Settings.GetSetting('no_hardware') <> '0' then
          SendDlgItemMessage(hDlgWnd, IDC_BASS_HWACCEL_CHK ,BM_SETCHECK,BST_CHECKED,0);

      end;

    WM_DESTROY:
      Settings.SaveSettings;

    WM_COMMAND:
      begin
        case hiword(wP) of

        CBN_SELCHANGE:
          case LoWord(wP) of

            IDC_LANG_CBX:
              begin
                if SendDlgItemMessage(hDlgWnd, IDC_LANG_CBX, CB_GETCURSEL, 0, 0) <> CB_ERR  then
                begin
                  Translator.CurrentLanguage := Translator.AvailableLanguages.fLng[SendDlgItemMessage(hDlgWnd, IDC_LANG_CBX, CB_GETCURSEL, 0, 0)].ISO_Code
                end;
              end;

           end;

        BN_CLICKED:
        begin
          case loword(wP) of

            IDC_GENERAL_MAKEMOVABLE_CHK:
              begin
                CBChecked := (SendDlgItemMessage(hDlgWnd, IDC_GENERAL_MAKEMOVABLE_CHK ,BM_GETCHECK,0,0) = BST_CHECKED);
                case CBChecked of
                  True:
                    begin
                      Settings.WriteSetting('main_window_movable','1');
                      EnableWindow(GetDlgItem(hDlgWnd, IDC_GENERAL_SAVEWINDOWPOS_CHK), true);
                    end;

                  False:
                    begin
                      Settings.WriteSetting('main_window_movable','0');
                      EnableWindow(GetDlgItem(hDlgWnd, IDC_GENERAL_SAVEWINDOWPOS_CHK), false);
                    end;
                end;
              end;

            IDC_GENERAL_SAVEWINDOWPOS_CHK:
              begin
                CBChecked := (SendDlgItemMessage(hDlgWnd, IDC_GENERAL_SAVEWINDOWPOS_CHK ,BM_GETCHECK,0,0) = BST_CHECKED);
                case CBChecked of
                  True: Settings.WriteSetting('save_main_window_pos','1');
                  False: Settings.WriteSetting('save_main_window_pos','0');
                end;
              end;

            IDC_MMKEYS_HKEY_CHK:
              begin
                CBChecked := (SendDlgItemMessage(hDlgWnd, IDC_MMKEYS_HKEY_CHK ,BM_GETCHECK,0,0) = BST_CHECKED);
                case CBChecked of
                  True:
                    begin
                      Settings.WriteSetting('multimedia_keys_activated','1');
                    end;
                  False:
                    begin
                      Settings.WriteSetting('multimedia_keys_activated','0');
                    end;
                end;
              end;

            IDC_GENERAL_AUTOSTART_CHK:
              begin
                CBChecked := (SendDlgItemMessage(hDlgWnd, IDC_GENERAL_AUTOSTART_CHK ,BM_GETCHECK,0,0) = BST_CHECKED);
                case CBChecked of
                  True:
                    begin
                      Settings.WriteSetting('start_with_windows','1');
                    end;
                  False:
                    begin
                      Settings.WriteSetting('start_with_windows','0');
                    end;
                end;
              end;

            IDC_GENERAL_PLAYFILEDROP_CHK:
              begin
                CBChecked := (SendDlgItemMessage(hDlgWnd, IDC_GENERAL_PLAYFILEDROP_CHK ,BM_GETCHECK,0,0) = BST_CHECKED);
                case CBChecked of
                  True:
                    begin
                      Settings.WriteSetting('play_file_after_drop','1');
                    end;
                  False:
                    begin
                      Settings.WriteSetting('play_file_after_drop','0');
                    end;
                end;
              end;

            IDC_GENERAL_ADDFILEDROP_CHK:
              begin
                CBChecked := (SendDlgItemMessage(hDlgWnd, IDC_GENERAL_ADDFILEDROP_CHK ,BM_GETCHECK,0,0) = BST_CHECKED);
                case CBChecked of
                  True:
                    begin
                      Settings.WriteSetting('add_file_to_playlist','1');
                    end;
                  False:
                    begin
                      Settings.WriteSetting('add_file_to_playlist','0');
                    end;
                end;
              end;


            IDC_BASS_32BIT_CHK:
              begin
                CBChecked := (SendDlgItemMessage(hDlgWnd, IDC_BASS_32BIT_CHK ,BM_GETCHECK,0,0) = BST_CHECKED);
                case CBChecked of
                  True:
                    begin
                      Settings.WriteSetting('use_32_bit', IntToStr(BASS_SAMPLE_SOFTWARE));
                    end;
                  False:
                    begin
                      Settings.WriteSetting('use_32_bit', '0');
                    end;
                end;
              end;

            IDC_BASS_MONO_CHK:
              begin
                CBChecked := (SendDlgItemMessage(hDlgWnd, IDC_BASS_MONO_CHK ,BM_GETCHECK,0,0) = BST_CHECKED);
                case CBChecked of
                  True:
                    begin
                      Settings.WriteSetting('play_mono', IntToStr(BASS_SAMPLE_MONO));
                    end;
                  False:
                    begin
                      Settings.WriteSetting('play_mono', '0');
                    end;
                end;
              end;

            IDC_BASS_HWACCEL_CHK:
              begin
                CBChecked := (SendDlgItemMessage(hDlgWnd, IDC_BASS_HWACCEL_CHK ,BM_GETCHECK,0,0) = BST_CHECKED);
                case CBChecked of
                  True:
                    begin
                      Settings.WriteSetting('no_hardware', IntToStr(BASS_SAMPLE_FLOAT));
                    end;
                  False:
                    begin
                      Settings.WriteSetting('no_hardware', '0');
                    end;
                end;
              end;
          end;
        end;
        end;
      end;
  else
    result := false;
  end;
end;

function SettingsDlgWndProc(hDlgWnd: HWND; uMsg: UINT; wp: WPARAM; lp: LPARAM): BOOL; stdcall;
begin
  Result := True;
  case uMsg of

    WM_INITDIALOG:
      begin
        SetWindowText(hDlgWnd, PChar(Translator[LNG_SETTINGS]));
        FillSettingsTreeView(hDlgWnd, IDC_TRV_SETTINGS);
        //Load Dialogs
        hwndGeneral := CreateDialog(hInstance, MAKEINTRESOURCE(10100), hDlgWnd, @SettingsTabsDlgWndProc);
        hwndAudio := CreateDialog(hInstance, MAKEINTRESOURCE(10300), hDlgWnd, @SettingsTabsDlgWndProc);

        SendMessage(aWnd, WM_LANGUAGEHASCHANGED, 0, 0);

        //Set ItemText
        SetDlgItemText(hDlgWnd, IDC_STC2, PChar(Translator[LNG_URL_STATION_TITLE] + ':'));
        SetDlgItemText(hDlgWnd, IDC_ADDCAT_STATIC, PChar(Translator[LNG_URL_ADDCAT]));
        SetDlgItemText(hDlgWnd, IDC_ADDURL_GBX, PChar(Translator[LNG_URL_ADDURL]));
        SetDlgItemText(hDlgWnd, IDOK, PChar(Translator[LNG_URL_PLAY]));
        SetDlgItemText(hDlgWnd, IDCANCEL, PChar(Translator[LNG_EXIT]));

        //Set Initial Dialog Pos
        SetWindowPos(hwndGeneral, 0, 180, 5, 240, 210, SWP_NOSIZE or SWP_NOZORDER or SWP_SHOWWINDOW);
        SetWindowPos(hwndAudio, 0, 180, 5, 240, 210, SWP_NOSIZE or SWP_NOZORDER or SWP_SHOWWINDOW);
      end;

      WM_COMMAND:
        case wP of
          IDCANCEL: EndDialog(hDlgWnd, IDCANCEL);
        end;

      WM_NOTIFY:
      begin
        case pnmHDR(lp)^.code of
          TVN_SELCHANGED:
            begin
              case PNMTREEVIEW(lp)^.itemNew.lParam of

                1:
                  begin
                    ShowWindow(hwndGeneral, SW_SHOW);
                    ShowWindow(hwndAudio, SW_HIDE);
                  end;

                2:
                  begin
                    ShowWindow(hwndGeneral, SW_HIDE);
                    ShowWindow(hwndAudio, SW_HIDE);
                  end;

                3:
                  begin
                    ShowWindow(hwndGeneral, SW_HIDE);
                    ShowWindow(hwndAudio, SW_SHOW);
                  end;

              end;
            end;

        end;
      end;

    WM_DESTROY:
      fIsShowingSettings := false;

    WM_SYSCOMMAND: // für das X-lein in der Titelleite
      begin
        case wP of
          SC_CLOSE: EndDialog(hDlgWnd, IDCANCEL);
          else Result := False;
        end;
      end;
      else
        Result := False;
  end;
end;

(* URL Window Function *)
function URLInputBoxDlgWndProc(hDlgWnd: HWND; uMsg: UINT; wp: WPARAM; lp: LPARAM): BOOL; stdcall;
var
  urlbuf: Array[0..256] of Char;
  titlebuf: Array[0..256] of Char;
  genrebuf: Array[0..256] of Char;
  i: integer;
  pwchr: PWideChar;
  CurItem, ParentItem: HTREEITEM;
  tvi,tvi2: TTVItem;
begin
  Result := True;

  case uMsg of
    WM_INITDIALOG:
      begin
        SetWindowText(hDlgWnd, PChar(Translator[LNG_ADDURL]));
        
        SetDlgItemText(hDlgWnd, IDC_STC1, PChar(Translator[LNG_URL_STATION_URL] + ':'));
        SetDlgItemText(hDlgWnd, IDC_STC2, PChar(Translator[LNG_URL_STATION_TITLE] + ':'));
        SetDlgItemText(hDlgWnd, IDC_ADDCAT_STATIC, PChar(Translator[LNG_URL_ADDCAT] + ':'));
        SetDlgItemText(hDlgWnd, IDC_ADDURL_GBX, PChar(Translator[LNG_URL_ADDURL]));
        SetDlgItemText(hDlgWnd, IDOK, PChar(Translator[LNG_URL_PLAY]));
        SetDlgItemText(hDlgWnd, IDCANCEL, PChar(Translator[LNG_URL_CANCEL]));

        SetDlgItemText(hDlgWnd, IDC_RBN2, PChar(Translator[LNG_URLWND_PLAYONLY]));
        SetDlgItemText(hDlgWnd, IDC_RBN1, PChar(Translator[LNG_URLWND_ADDTODB]));
        SetDlgItemText(hDlgWnd, 6014, PChar(Translator[LNG_URLWND_STATIONS]));
        SetDlgItemText(hDlgWnd, IDC_BTN3, PChar(Translator[LNG_URLWND_DELSEL]));
        SetDlgItemText(hDlgWnd, IDC_CATEGORY_GBX, PChar(Translator[LNG_URLWND_ADDCAT]));
        SetDlgItemText(hDlgWnd, IDC_BTN2, PChar(Translator[LNG_URLWND_ADD]));
        
        SendMessage(hDlgWnd, WM_SETICON, ICON_SMALL	,
        LoadImage(hInstance, MAKEINTRESOURCE(1), IMAGE_ICON,
        GetSystemMetrics(SM_CXSMICON), GetSystemMetrics(SM_CYSMICON), 0));

        // nur 255 Zeichen im Edit zulassen
        SendDlgItemMessage(hDlgWnd, IDC_EDT1, EM_LIMITTEXT, 255, 0); // einen weniger wegen #0 als aller letztes zeichen im Puffer !

        // Combobox befüllen
        for I := 0 to Length(MediaCL.InternetStations.GenreList.Genres) - 1 do
           SendDlgItemMessage(hDlgWnd, IDC_CBO1, CB_ADDSTRING, 0, INTEGER(PCHAR(MediaCL.InternetStations.GenreList.Genres[I].Name)));

        getmem(pwchr, 512);
        try
          pwchr := StringToWideChar(Translator[LNG_URL_URL_CUETEXT], pwchr, 255);
          Edit_SetCueBannerText(hDlgWnd, IDC_EDT1, pwchr);
          pwchr := StringToWideChar(Translator[LNG_URL_TITLE_CUETEXT], pwchr, 255);
          Edit_SetCueBannerText(hDlgWnd, IDC_EDT2, pwchr);
        finally
          freemem(pwchr);
        end;

        // ersten Eintrag selectieren / setzen
        SendDlgItemMessage(hDlgWnd, IDC_CBO1, CB_SETCURSEL, 0, 0);

        // die Combobox und Titel (Edit & Label) erst mal disablen
        EnableWindow(GetDlgItem(hDlgWnd, IDC_CBO1), false);
        EnableWindow(GetDlgItem(hDlgWnd, IDC_STC2), false);
        EnableWindow(GetDlgItem(hDlgWnd, IDC_EDT2), false);
        // Radiobutton vorselectieren
        SendDlgItemMessage(hDlgWnd, IDC_RBN2, BM_SETCHECK, BST_CHECKED, 0);
        FillTreeView(hDlgWnd, IDC_TRV1);
        SetDlgItemText(hDlgWnd, IDCANCEL, PChar(Translator[LNG_EXIT]));
      end;

    WM_COMMAND:
      begin
        case HIWORD(wp) of
          BN_CLICKED:
            case loword(wp) of
              IDOK:
                begin
                  EndDialog(hDlgWnd, IDOK);
                  
                  ZeroMemory(@urlbuf, Length(urlbuf));
                  ZeroMemory(@titlebuf, Length(titlebuf));
                  GetDlgItemText(hDlgWnd, IDC_EDT1, urlbuf, 256);
                  GetDlgItemText(hDlgWnd, IDC_EDT2, titlebuf, 256);
                  if urlbuf <> '' then
                  begin
                    if CheckUrl(urlbuf) then
                    begin
                      // add to database ?
                      if SendDlgItemMessage(hDlgWnd, IDC_RBN1, BM_GETCHECK, 0, 0) = BST_CHECKED then
                      begin
                        // Was für eine Musike ist es denn ?

                        MediaCL.AddURL(String(urlbuf),
                                       String(titlebuf),
                                       MediaCL.InternetStations.GenreList.Genres[SendMessage(GetDlgItem(hDlgWnd, IDC_CBO1), CB_GETCURSEL, 0, 0)].Name);

                        MediaCL.RunInternetStream(String(urlbuf));
                        MediaCl.InternetStations.GetAllStations;
                        FillTreeView(hDlgWnd, IDC_TRV1);
                        ModifyMenu(hwndPopUpMenu, MMI_SUBMENU, MF_BYPOSITION or MF_POPUP or MF_STRING, MediaCL.InternetStations.GenreList.MenuHandle, Pchar('INet-Radio'));
                        DrawMenuBar(aWnd);
                      end else
                      begin
                        // nur abspielen
                        MediaCL.RunInternetStream(String(urlbuf));
                      end;
                      // EndDialog(hDlgWnd, IDOK); ? oder hier hin ?
                    end
                    else
                      MessageBox(hDlgWnd, PCHAR(Translator[LNG_NOVALIDURL]), '!', MB_ICONINFORMATION);
                    end;
                end;
              IDCANCEL:
                  EndDialog(hDlgWnd, IDCANCEL);

              IDC_RBN1:
                begin
                  SetDlgItemText(hDlgWnd, IDOK, PChar(Translator[LNG_URL_ADD]));
                  EnableWindow(GetDlgItem(hDlgWnd, IDC_CBO1), true);
                  EnableWindow(GetDlgItem(hDlgWnd, IDC_STC2), true);
                  EnableWindow(GetDlgItem(hDlgWnd, IDC_EDT2), true);
                end;

              IDC_RBN2:
                begin
                  SetDlgItemText(hDlgWnd, IDOK, PChar(Translator[LNG_URL_PLAY]));
                  EnableWindow(GetDlgItem(hDlgWnd, IDC_CBO1), false);
                  EnableWindow(GetDlgItem(hDlgWnd, IDC_STC2), false);
                  EnableWindow(GetDlgItem(hDlgWnd, IDC_EDT2), false);
                end;

              IDC_BTN3:
                begin
                  CurItem := HTREEITEM(SendDlgItemMessage(hDlgWnd, IDC_TRV1, TVM_GETNEXTITEM, TVGN_CARET, Longint(HTreeItem(nil))));
                  ParentItem := HTREEITEM(SendDlgItemMessage(hDlgWnd, IDC_TRV1, TVM_GETNEXTITEM, TVGN_PARENT, LPARAM(CurItem)));
                  If ParentItem = nil then
                  begin
                    tvi.mask := TVIF_PARAM;
                    tvi.hItem := CurItem;
                    if SendDlgItemMessage(hDlgWnd, IDC_TRV1, TVM_GETITEM, 0, LPARAM(@tvi)) <> 0 then
                      MediaCL.InternetStations.DeleteItem(-1, tvi.lParam + 1, true);
                  end
                  else
                  begin
                    tvi.mask := TVIF_PARAM;
                    tvi.hItem := ParentItem;
                    tvi2.mask := TVIF_PARAM;
                    tvi2.hItem :=  CurItem;
                    if SendDlgItemMessage(hDlgWnd, IDC_TRV1, TVM_GETITEM, 0, LPARAM(@tvi2)) <> 0 then
                      MediaCL.InternetStations.DeleteItem(tvi2.lParam, tvi.lParam + 1, false);
                  end;
                  SendDlgItemMessage(hDlgWnd, IDC_TRV1, TVM_DELETEITEM, 0, LPARAM(HTREEITEM(CurItem)));
                  ModifyMenu(hwndPopUpMenu, MMI_SUBMENU, MF_BYPOSITION or MF_POPUP or MF_STRING, MediaCL.InternetStations.GenreList.MenuHandle, Pchar('INet-Radio'));
                  DrawMenuBar(aWnd);
                end;

              IDC_BTN2:
                begin
                  ZeroMemory(@genrebuf, Length(genrebuf));
                  GetDlgItemText(hDlgWnd, IDC_EDT3, genrebuf, 256);
                  if genrebuf <> '' then
                    MediaCL.AddGenre(genrebuf);
                  MediaCl.InternetStations.GetAllStations;
                  FillTreeView(hDlgWnd, IDC_TRV1);
                  ModifyMenu(hwndPopUpMenu, MMI_SUBMENU, MF_BYPOSITION or MF_POPUP or MF_STRING, MediaCL.InternetStations.GenreList.MenuHandle, Pchar('INet-Radio'));
                  DrawMenuBar(aWnd);
                end;

            end;
        end;
      end;

    WM_DESTROY:
      fIsShowingUrlWnd := false;

    WM_NOTIFY:
      begin
        with PNMTreeView(lp)^ do
          case hdr.code of
            TVN_SELCHANGED:
            begin
              EnableWindow(GetDlgItem(hDlgWnd, IDC_BTN3), true);
            end;

            TVN_DELETEITEM:
            begin

            end;
        end;
      end;

    WM_SYSCOMMAND: // für das X-lein in der Titelleite
      begin
        case wP of
          SC_CLOSE: EndDialog(hDlgWnd, IDCANCEL);
          else Result := False;
        end;
      end;

    else
      Result := False;
  end;
end;

(* Main Run Function *)
function WinMain(_hInstance: HINST; hPrevInstance: HINST;
  lpCmdLine: PChar; nCmdShow: Integer): Integer; stdcall;
var
  wc : TWndClassEx;
  Mutex : THandle;
  WndExFlags,
  WndFlags: DWORD;
  Wnd: HWND;
begin
  Result := 0;

  OsInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(OsInfo);

  // für Windows kleiner als NT 4.0 oder kleiner als XP? Läuft leider nichts...
  if (OsInfo.dwMajorVersion < 5) or (OsInfo.dwMajorVersion = 5) and (OsInfo.dwMinorVersion = 0) then
  begin
    MessageBox(0, PChar(Translator[LNG_STARTING_ERROR]), '!', MB_ICONINFORMATION);
    Lg.WriteLog('Running on a Windows older then XP', 'dgstMain', ltError, lmNormal);
    exit;
  end;

  WndExFlags :=  WS_EX_TOOLWINDOW or WS_EX_LAYERED or WS_EX_ACCEPTFILES;
  WndFlags   :=  WS_BORDER or WS_SYSMENU;

  // wenn XP läuft dann einfachen Style setzen
  if (OsInfo.dwMajorVersion = 5) then
  begin
    WindowHeight := WindowHeight - 14;
    WindowWidth := WindowWidth - 12;

    WndExFlags :=  WS_EX_TOOLWINDOW or WS_EX_LAYERED or WS_EX_ACCEPTFILES;
    WndFlags   :=  WS_BORDER or WS_SYSMENU;
  end;

  //Debug
  Lg.WriteLog('WindowHeight: ' + IntToStr(WindowHeight), 'dgstMain');
  Lg.WriteLog('WindowWidth: ' + IntToStr(WindowWidth), 'dgstMain');

  randomize;

  InitCommonControlsEx(iccex);

  Mutex := CreateMutex(nil, false, wndClassname);
  if(GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    Wnd := FindWindow(wndClassName, AppName);
    if Wnd <> 0 then
    begin
      MessageBeep(MB_ICONINFORMATION);
      ShowWindow(Wnd, SW_SHOW);     // me kanns ja auch einfach machen ;-)
      SetForegroundWindow(Wnd);
    end;
    CloseHandle(Mutex);
    Halt;
  end;

  ZeroMemory(@wc, sizeof(TWndClassEx));
  With wc do
  begin
    cbSize        := SizeOf(TWndClassEx);
    Style         := CS_HREDRAW or CS_VREDRAW;
    lpfnWndProc   := @WndProc;
    cbClsExtra    := 0;
    cbWndExtra    := 0;
    hInstance     := _hInstance;
    lpszMenuName  := nil;
    lpszClassName := wndClassName;
    hIconSm       := LoadIcon(hInstance, MAKEINTRESOURCE(1));
    hIcon         := LoadIcon(hInstance, MAKEINTRESOURCE(1));
    hCursor       := LoadCursor(0, IDC_ARROW);
    hbrBackground := GetSysColorBrush(COLOR_3DFACE);
  end;

  // Fensterklasse registrieren
  if(RegisterClassEx(wc) = 0) then exit;

  // Fensterklasse erzeugen ( und ggf. anzeigen )
  aWnd := CreateWindowEx(WndExFlags, wndClassname, AppName,
    WndFlags, integer(CW_USEDEFAULT), integer(CW_USEDEFAULT),
    WindowWidth, WindowHeight, 0,0 , hInstance, nil);

  //Create Playlist Window
  PlaylistWindow := TPlaylistWindow.Create(MediaCl, awnd, _hInstance);
  RadiobrowserApi := TRadiobrowserApi.Create;
  RadiobrowserWindow := TRadiobrowser.Create(awnd, _hInstance, RadiobrowserApi);

  if(aWnd = 0) then exit;
  SetForegroundWindow(awnd);
  ShowWindow(awnd, SW_Show);



  // Nachrichtenschleife
  while(GetMessage(msg, 0, 0, 0)) do
  begin
    TranslateMessage(msg);
    DispatchMessage(msg);
  end;

  // Fensterklasse(n) deregistrieren
  UnregisterClass(wndClassName, hInstance);

  PlaylistWindow.Destroy();

  CloseHandle(Mutex);

  Result := msg.wParam;
end;

end.
