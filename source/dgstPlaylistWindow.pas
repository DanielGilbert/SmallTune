unit dgstPlaylistWindow;

interface

uses
  Windows,
  ShellAPI,
  Messages,
  dgstMediaClass,
  dgstCommCtrl,
  dgstTypeDef,
  tPnvOpenFileDlg,
  dgstSysUtils,
  dgstTranslator,
  dgstHelper;

type
  TPlaylistWindow = class
  private
    //Playlist Window
    FHandle : HWND;
    hwndPlaylistWnd,
    hwndPlayListLV,
    hwndSearchlbl,
    hwndSearchEdt,
    hwndPLToolBar: HWnd;
    hwndFont: HFont;
    fMediaCl: TMediaClass;

    fMainWindow : HWND;
    fIsShowingPlayList : Boolean;

    //procedure GetDropFiles(wP: wParam);
    procedure MakeColumns(const hLV: HWND);
    function GetNonClientMetrics: TNonClientMetrics;
    function InstWndProc(wnd: HWND; uMsg: UINT; wp: WPARAM; lp: LPARAM): LRESULT; stdcall;
    //function SearchEditWndProc(hEdit: HWND; uMsg: DWORD; wParam, lParam: integer): DWORD; stdcall;
    procedure PLToolBarUsingBitmap(wnd: HWND);
  public
    property IsShowingPlaylist : Boolean read fIsShowingPlaylist;

    constructor Create(MediaCl: TMediaClass; hMainWindow: HWND; _hInstance: HINST);
    destructor Destroy; override;
    procedure Close;
    procedure Update;
    procedure Refresh;
    procedure Show;
    function AddMediaFile(Path: String): Boolean;
  end;

implementation

function GetWindowByHwnd(hwnd: HWnd): TPlaylistWindow;
begin
  Result := TPlaylistWindow(GetWindowLong(hwnd, 0));
end;

procedure StoreWindowByHwnd(hwnd: HWND; AWindow: TPlaylistWindow);
begin
  AWindow.FHandle := hwnd;
  SetWindowLong(hwnd, 0, longint(AWindow));
end;

function WndProc(hwnd: HWND; uiMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  Msg    : TMessage;
  Window : TPlaylistWindow;
begin
  Msg.Msg    := uiMsg;
  Msg.WParam := wParam;
  Msg.LParam := lParam;
  Msg.Result := 0;
  if uiMsg = WM_NCCREATE then begin
    Window := TPlaylistWindow(TWMNCCreate(Msg).CreateStruct.lpCreateParams);
    StoreWindowByHwnd(hwnd, Window)
  end;
  Window := GetWindowByHwnd(hwnd);
  if Window = nil then begin
    Result := DefWindowProc(hwnd, Msg.Msg, Msg.WParam, Msg.LParam);
  end else begin
    Result := Window.InstWndProc(hwnd, Msg.Msg, Msg.WParam, Msg.LParam);
  end;
end;

constructor TPlaylistWindow.Create(MediaCl: TMediaClass; hMainWindow: HWND; _hInstance: HINST);
var
  wc : TWndClassEx;
begin
  fMediaCl := MediaCl;
  fMainWindow := hMainWindow;

  ZeroMemory(@wc, sizeof(TWndClassEx));
  With wc do
  begin
    cbSize        := SizeOf(TWndClassEx);
    Style         := CS_HREDRAW or CS_VREDRAW;
    lpfnWndProc   := @WndProc;
    cbClsExtra    := 0;
    cbWndExtra    := integer(Self);
    hInstance     := _hInstance;
    lpszMenuName  := nil;
    lpszClassName := wndClassName2;
    hIconSm       := LoadIcon(hInstance, MAKEINTRESOURCE(1));
    hIcon         := LoadIcon(hInstance, MAKEINTRESOURCE(1));
    hCursor       := LoadCursor(0, IDC_ARROW);
    hbrBackground := GetSysColorBrush(COLOR_3DFACE);
  end;
  {Fenster 2 registrieren}
  RegisterClassEx(wc);
end;

destructor TPlaylistWindow.Destroy;
begin
  //DestroyWindow(hwndPlaylistWnd);
  UnregisterClass(wndClassName2, hInstance);
end;

procedure TPlaylistWindow.Update;
begin
  ListView_SetItemCountEx(hwndPlayListLV, fMediaCL.ItemsInDB, 0);
end;

procedure TPlaylistWindow.PLToolBarUsingBitmap(wnd: HWND);
var
  ImgList : hImageList;
begin
  ImgList := IMAGELIST_Create(16, 16, ILC_COLOR32, 12, 0);

  if ImgList <> INVALID_HANDLE_VALUE then
  begin
    IMAGELIST_AddIcon(ImgList, LoadIcon(hInstance, MAKEINTRESOURCE(MEDIA_PLADDFILES)));
    IMAGELIST_AddIcon(ImgList, LoadIcon(hInstance, MAKEINTRESOURCE(MEDIA_PLADDDIR)));
    IMAGELIST_AddIcon(ImgList, LoadIcon(hInstance, MAKEINTRESOURCE(MEDIA_PLCLEARALL)));
    IMAGELIST_AddIcon(ImgList, LoadIcon(hInstance, MAKEINTRESOURCE(MEDIA_PLCLEARSEL)));
    
    SendMessage(hwndPLToolBar, TB_BUTTONSTRUCTSIZE, sizeof(TTBBUTTON), 0);
    SendMessage(hwndPLToolBar, TB_SETBITMAPSIZE, 0, MAKELONG(16, 16));
    SendMessage(hwndPLToolBar, TB_ADDBUTTONS, length(tbPLButtons), LPARAM(@tbPLButtons));
    SendMessage(hwndPLToolBar, TB_ADDSTRING, 0, LPARAM(PChar(Translator[LNG_PLBTNHINTS])));

    SendMessage(hwndPLToolBar, TB_SETIMAGELIST, 0, ImgList);
  end;
end;

function TPlaylistWindow.GetNonClientMetrics: TNonClientMetrics;
begin
  Result.cbSize := SizeOf(NONCLIENTMETRICS);
  SystemParametersInfo(SPI_GETNONCLIENTMETRICS, SizeOf(NONCLIENTMETRICS), @Result, 0);
end;

procedure TPlaylistWindow.Show;
var
  msg_ : MSG;
begin
  hwndPlaylistWnd  := CreateWindowEx(WS_EX_ACCEPTFILES, wndClassName2, PlaylistWndName,
                WS_CAPTION or WS_VISIBLE or WS_SYSMENU
                or WS_MAXIMIZEBOX or WS_SIZEBOX, 40, 10,
                300, 200, fMainWindow, 0, hInstance, Self);
  fIsShowingPlayList := true;
end;

procedure TPlaylistWindow.Close;
begin
  ShowWindow(FHandle, 0);       //SW_HIDE
  fIsShowingPlayList := false;
end;

(* Create Columns for Playlist *)
procedure TPlaylistWindow.MakeColumns(const hLV: HWND);
var
  lvc        : TLVColumn;
begin
  lvc.mask    := LVCF_TEXT or LVCF_WIDTH;
  lvc.pszText := PChar(Translator[LNG_PLAYLISTNUMBER]);
  lvc.cx      := 45;
  ListView_InsertColumn(hLV,0,lvc);

  lvc.mask    := LVCF_TEXT or LVCF_WIDTH;
  lvc.pszText := Pchar(Translator[LNG_PLAYLISTTITLE]);
  lvc.cx      := 150;
  ListView_InsertColumn(hLV,1,lvc);

  lvc.mask    := LVCF_TEXT or LVCF_WIDTH;
  lvc.pszText := PChar(Translator[LNG_PLAYLISTARTIST]);
  lvc.cx      := 120;
  ListView_InsertColumn(hLV,2,lvc);

  lvc.mask    := LVCF_TEXT or LVCF_WIDTH;
  lvc.pszText := PChar(Translator[LNG_PLAYLISTALBUM]);
  lvc.cx      := 120;
  ListView_InsertColumn(hLV,3,lvc);
end;

function TPlaylistWindow.AddMediaFile(Path: String): Boolean;
begin
  Result := False;
  if (Path <> '') AND FileExists(Path) then
  begin
    fMediaCL.AddFileToDatabase(Path);
    fMediaCL.RebuildPlaylist;
    Refresh();
  end;
end;

procedure TPlaylistWindow.Refresh;
begin
    ListView_SetItemCountEx(hwndPlayListLV, fMediaCL.ItemsInDB, 0);
end;

{*
procedure TPlaylistWindow.GetDropFiles(wP: wParam);   
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
            fMediaCL.Load(s,-1);
            fMediaCL.Play;
          end;
        end;
      finally
        FreeMem(pcFilename);
      end;
    end;
  end;
  DragFinish(wP);
end;
 *}
(* Playlist Window Function *)
function TPlaylistWindow.InstWndProc(wnd: HWND; uMsg: UINT; wp: WPARAM; lp: LPARAM): LRESULT; stdcall;
var
  x,y, iStart: Integer;
  rc, tbrc: TRect;
  NCM: TNonClientMetrics;
  MediaFle: TLVItemCache;
  Filterbuf: Array[0..255] of Char;
  i: integer;
  dir: String;
begin
  Result := 0;
  case uMsg of
    WM_CHAR:
    case Byte(wp) of
        VK_RETURN:
          begin
            fMediaCl.CurrentPlayListPos := ListView_GetNextItem(hwndPlayListLV,-1,LVNI_SELECTED);
            if fMediaCl.CurrentPlayListPos <> -1 then
              if fMediaCl.Load(fMediaCl.CurrentMediaItem.FilePath, fMediaCl.CurrentPlayListPos) then
              begin
                fMediaCl.Play;
                //SetTooltip(stPlay);
                //DestroyWindow(hwndPlaylistWnd);
              end;
          end;
    end;

    WM_CREATE:
      begin
        (* Center Window *)
        x := GetSystemMetrics(SM_CXSCREEN);   //Screenheight & -width
        y := GetSystemMetrics(SM_CYSCREEN);

        (* Move Window To New Position *)
        MoveWindow(Wnd, (x div 2) - (WindowWidth2 div 2),
          (y div 2) - (WindowHeight2 div 2),
          WindowWidth2, WindowHeight2, true);

        hwndPlayListLV := CreateWindowEx(WS_EX_CLIENTEDGE, LISTVIEW_CLASSNAME, nil, WS_CHILD
        or WS_VISIBLE or LVS_REPORT or LVS_OWNERDATA or LVS_SHOWSELALWAYS(* or LVS_SINGLESEL*), 10, 10, 200, 230,
        Wnd, 0, hInstance, nil);

        SendMessage( hwndPlayListLV,LVM_SETEXTENDEDLISTVIEWSTYLE,0,
          LVS_EX_DOUBLEBUFFER or LVS_EX_FULLROWSELECT);

        hwndSearchEdt := CreateWindowEx(WS_EX_CLIENTEDGE,'EDIT','',
          WS_VISIBLE or WS_CHILD,130,100,55,19,wnd,IDC_SEARCHEDT,
          hInstance,nil);

        //Implement own WindowProc for the Edit
        //OldWndProc := Pointer(SetWindowLong(hwndSearchEdt, GWL_WNDPROC, Integer(@TPlaylistWindow.SearchEditWndProc)));

        hwndSearchlbl := CreateWindowEx(0,'STATIC', PChar(Translator[LNG_FILTER] + ':'),
          WS_VISIBLE or WS_CHILD,8,80,275,16,wnd,0,hInstance,
          nil);

        // die toolbarbuttons
        hwndPLToolBar := CreateWindowEx(0, TOOLBARCLASSNAME, nil, WS_CHILD or
          WS_VISIBLE or CCS_BOTTOM  or TBSTYLE_FLAT or TBSTYLE_TOOLTIPS or TBSTYLE_TRANSPARENT,
          0, 0, 200, 25, wnd, IDC_PLTOOLBAR, hInstance, nil);

        PLToolBarUsingBitmap(wnd);

       // Font
        NCM := GetNonClientMetrics;
        hwndFont := CreateFontIndirect(NCM.lfStatusFont);
        if(hwndFont <> 0) then
        begin
          SendMessage(hwndSearchEdt, WM_SETFONT, WPARAM(hwndFont), LPARAM(true));
          SendMessage(hwndSearchlbl, WM_SETFONT, WPARAM(hwndFont), LPARAM(true));
          SendMessage(hwndPLToolBar, WM_SETFONT, WPARAM(hwndFont), LPARAM(true));
       end;

        MakeColumns(hwndPlayListLV);
        ListView_SetItemCountEx(hwndPlayListLV, fMediaCL.ItemsInDB, 0);

      end;

    WM_SHOWWINDOW:
      begin
        SendMessage(wnd, WM_SIZE, 0, 0);
        SetFocus(hwndPlayListLV);
        //Do selection only if necessary
        if fMediaCL.CurrentMediaItem.RowID >= 0 then
        begin
          ListView_EnsureVisible(hwndPlayListLV, fMediaCL.CurrentMediaItem.RowID - 1, false);
          ListView_SetItemState(hwndPlayListLV, fMediaCL.CurrentMediaItem.RowID - 1, LVIS_SELECTED or LVIS_FOCUSED, LVIS_SELECTED or LVIS_FOCUSED);
        end;
        SetFocus(hwndSearchEdt);
      end;

    WM_KEYUP:
      begin
        Case wp of
          VK_ESCAPE:
            begin
              CloseWindow(wnd);
            end;
        End;
      end;

    WM_NOTIFY:
      begin
         if PNMHdr(lp)^.hwndFrom = hwndPlayListLV then
          case PNMHdr(lp)^.code of
            NM_DBLCLK:
            begin
              fMediaCL.CurrentPlayListPos := ListView_GetNextItem(hwndPlayListLV,-1,LVNI_SELECTED);;
              if fMediaCL.CurrentPlayListPos <> -1 then
               if fMediaCL.Load(fMediaCL.CurrentMediaItem.FilePath, fMediaCL.CurrentPlayListPos) then
               begin
                fMediaCL.Play;
                //SetTooltip(stPlay);
                //DestroyWindow(hwndPlaylistWnd);
               end;
            end;

            LVN_DELETEALLITEMS:
            begin
              Result := 1;
              fMediaCL.DeletePlayList;
            end;

            LVN_GETDISPINFO:
            begin
              if PLVDispInfo(lP).item.iItem > -1 then
              begin
              MediaFle := fMediaCL.GetItemFromCache(PLVDispInfo(lP).item.iItem);

              //Set Text
              If (PLVDispInfo(lP).item.mask AND LVIF_TEXT) = LVIF_TEXT then
                case PLVDispInfo(lP).item.iSubItem of
                  0: StrPLCopy(PLVDispInfo(lP).item.pszText, IntToStr(MediaFle.MediaFileItm.RowID), PLVDispInfo(lP).item.cchTextMax - 1);
                  1:
                  begin
                    If (MediaFle.MediaFileItm.Title = '') AND (MediaFle.MediaFileItm.Artist = '') then
                      StrPLCopy(PLVDispInfo(lP).item.pszText, MediaFle.MediaFileItm.FileName, PLVDispInfo(lP).item.cchTextMax - 1)
                    else
                      StrPLCopy(PLVDispInfo(lP).item.pszText, MediaFle.MediaFileItm.Title, PLVDispInfo(lP).item.cchTextMax - 1);
                  end;
                  2: StrPLCopy(PLVDispInfo(lP).item.pszText, MediaFle.MediaFileItm.Artist, PLVDispInfo(lP).item.cchTextMax - 1);
                  3: StrPLCopy(PLVDispInfo(lP).item.pszText, MediaFle.MediaFileItm.Album, PLVDispInfo(lP).item.cchTextMax - 1);
                end;
              end;

            end;

            LVN_ODCACHEHINT:
            begin
              fMediaCL.LoadCache(PNMLVCacheHint(lP).iFrom, PNMLVCacheHint(lP).iTo);
            end;

            LVN_DELETEITEM:
            begin
              fMediaCL.DeleteItemByLVID(PNMLISTVIEW(lp)^.iItem);
              ListView_SetItemCountEx(hwndPlayListLV, fMediaCL.ItemsInDB, 0);
            end;

            LVN_KEYDOWN:
            begin
              case PNMLVKEYDOWN(lp)^.wVKey of
                VK_DELETE:
                begin
                  case MessageBox(0,
                      PChar(Translator[LNG_DELETEITEM]),
                      PChar(Translator[LNG_DELETEITEMCAPTION]),
                      MB_YESNO or MB_ICONINFORMATION
                      ) of
                    IDYES:
                    begin
                      SendMessage(hwndPlayListLV, LVM_DELETEITEM, SendMessage(hwndPlayListLV, LVM_GETSELECTIONMARK, 0, 0), 0);
                    end;
                  end;
                end;

                VK_RETURN:
                begin
                  fMediaCL.CurrentPlayListPos := ListView_GetNextItem(hwndPlayListLV,-1,LVNI_SELECTED);;
                  if fMediaCL.CurrentPlayListPos <> -1 then
                    if fMediaCL.Load(fMediaCL.CurrentMediaItem.FilePath, fMediaCL.CurrentPlayListPos) then
                    begin
                      fMediaCL.Play;
                      //SetTooltip(stPlay);
                      //DestroyWindow(hwndPlaylistWnd);
                    end;
                end;

              end;
            end;
        end;
      end;

      WM_DESTROY:
      begin
        fMediaCL.Filter := '';
        fIsShowingPlayList := false;
      end;

      WM_SIZE:
      begin
        if(wp <> SIZE_MINIMIZED) then
        begin
          // get client rect,
          GetClientRect(wnd, rc);
          // resize & move Tree-View
          MoveWindow(hwndSearchlbl, 8, 8, rc.Right - 16, 16, true);
          // resize & move Edit
          MoveWindow(hwndSearchEdt, 8, 24, rc.Right - 16, 22, true);
          // resize & move List-View
          GetWindowRect(hwndPLToolBar, tbrc);
          // platz schaffen für BtnToolbar
          MoveWindow(hwndPlayListLV, 8, 48, rc.Right - 16, rc.Bottom - (tbrc.Bottom - tbrc.Top)-56, true);
          // PlaylistToolbar
          MoveWindow(hwndPLToolBar, 8, rc.Bottom - 32, rc.Right - 16, rc.Bottom , true);
        end;
      end;

    WM_DROPFILES:
    begin
      //GetDropFiles(wP);
    end;

    WM_COMMAND:
      begin

        if wp = IDCANCEL then
            DestroyWindow(wnd);

        case HIWORD(wp) of



          EN_CHANGE:
            case LOWORD(wp) of
               IDC_SEARCHEDT:
                begin
                  ZeroMemory(@filterbuf, Length(filterbuf));
                  GetWindowText(hwndSearchEdt, filterbuf, 256);
                  fMediaCL.Filter := String(filterbuf);
                  if fMediaCL.Filter <> '' then
                     ListView_SetItemState(hwndPlayListLV, 0, LVIS_SELECTED or LVIS_FOCUSED, LVIS_SELECTED or LVIS_FOCUSED);
                  ListView_SetItemCountEx(hwndPlayListLV, fMediaCL.ItemsInDB, 0);
                end;
            end;

          BN_CLICKED:
            case loword(wp) of

            MMI_ADDFILE :
            begin
              with TOpenFileDlg.Create(fMainWindow) do
              try
                FileFilter := Translator[LNG_FILEFILTERSTRING];
                Multiselect := true;
                if Execute then
                begin
                  for i := 0 to Length(Files) - 1 do
                  AddMediaFile(Files[i]);
                end;
              finally
                Free;
              end;
            end;

            MMI_ADDFOLDER :
            begin
              dir := OpenFolder(Translator[LNG_SELECTFOLDER],'');
              fMediaCL.Stop;
              if dir <> '' then
              begin
                //SetMenuState(False);
                fMediaCL.AddFolderToDatabase(dir);
              end;
            end;

            MMI_DELETEALLITEMS :
            begin
              case MessageBox(0,
                    PChar(Translator[LNG_DELETEITEMS]),
                    PChar(Translator[LNG_DELETEITEMSCAPTION]),
                    MB_YESNO or MB_ICONINFORMATION
                    ) of
                    IDYES:
                    begin
                      ListView_DeleteAllItems(hwndPlayListLV)
                    end;
              end;
            end;

            MMI_DELETESELECTION :
            begin
              iStart := SendMessage(hwndPlayListLV, LVM_GETSELECTIONMARK, 0, 0);
              if iStart <> -1 then
                case MessageBox(0,
                    PChar(Translator[LNG_DELETEITEM]),
                    PChar(Translator[LNG_DELETEITEMCAPTION]),
                    MB_YESNO or MB_ICONINFORMATION
                    ) of
                    IDYES:
                    begin
                      for I := 0 to SendMessage(hwndPlayListLV, LVM_GETSELECTEDCOUNT, 0, 0) - 1 do
                      begin
                        SendMessage(hwndPlayListLV, LVM_DELETEITEM,  ListView_GetNextItem(hwndPlayListLV, iStart-1, LVNI_ALL), 0);
                      end;
                    end;
                end;
            end;
          end;
        end;
      end
    else
      Result := DefWindowProc(wnd, uMsg, wp, lp);
  end;
end;

end.
