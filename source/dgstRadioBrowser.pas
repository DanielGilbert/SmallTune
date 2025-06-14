unit dgstRadioBrowser;

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
  TRadioBrowser = class
  private
    //Playlist Window
    FHandle : HWND;
    hwndPlaylistWnd: HWND;
    hwndFont: HFont;

    fMainWindow : HWND;
    fIsShowing: boolean;
    function GetNonClientMetrics: TNonClientMetrics;
    function InstWndProc(wnd: HWND; uMsg: UINT; wp: WPARAM; lp: LPARAM): LRESULT; stdcall;
  public
    property IsShowing : Boolean read fIsShowing;

    constructor Create(hMainWindow: HWND; _hInstance: HINST);
    destructor Destroy; override;
    procedure Close;
    procedure Show;
  end;

implementation

function GetWindowByHwnd(hwnd: HWnd): TRadioBrowser;
begin
  Result := TRadioBrowser(GetWindowLong(hwnd, 0));
end;

procedure StoreWindowByHwnd(hwnd: HWND; AWindow: TRadioBrowser);
begin
  AWindow.FHandle := hwnd;
  SetWindowLong(hwnd, 0, longint(AWindow));
end;

function WndProc(hwnd: HWND; uiMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  Msg    : TMessage;
  Window : TRadioBrowser;
begin
  Msg.Msg    := uiMsg;
  Msg.WParam := wParam;
  Msg.LParam := lParam;
  Msg.Result := 0;
  if uiMsg = WM_NCCREATE then begin
    Window := TRadioBrowser(TWMNCCreate(Msg).CreateStruct.lpCreateParams);
    StoreWindowByHwnd(hwnd, Window)
  end;
  Window := GetWindowByHwnd(hwnd);
  if Window = nil then begin
    Result := DefWindowProc(hwnd, Msg.Msg, Msg.WParam, Msg.LParam);
  end else begin
    Result := Window.InstWndProc(hwnd, Msg.Msg, Msg.WParam, Msg.LParam);
  end;
end;

constructor TRadioBrowser.Create(hMainWindow: HWND; _hInstance: HINST);
var
  wc : TWndClassEx;
begin
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
    lpszClassName := radiobrowserWndClassName;
    hIconSm       := LoadIcon(hInstance, MAKEINTRESOURCE(1));
    hIcon         := LoadIcon(hInstance, MAKEINTRESOURCE(1));
    hCursor       := LoadCursor(0, IDC_ARROW);
    hbrBackground := GetSysColorBrush(COLOR_3DFACE);
  end;
  {Fenster 2 registrieren}
  RegisterClassEx(wc);
end;

destructor TRadioBrowser.Destroy;
begin
  //DestroyWindow(hwndPlaylistWnd);
  UnregisterClass(radiobrowserWndClassName, hInstance);
end;

function TRadioBrowser.GetNonClientMetrics: TNonClientMetrics;
begin
  Result.cbSize := SizeOf(NONCLIENTMETRICS);
  SystemParametersInfo(SPI_GETNONCLIENTMETRICS, SizeOf(NONCLIENTMETRICS), @Result, 0);
end;

procedure TRadioBrowser.Show;
var
  msg_ : MSG;
begin
  hwndPlaylistWnd  := CreateWindowEx(WS_EX_ACCEPTFILES, radiobrowserWndClassName, RadiobrowserWndName,
                WS_CAPTION or WS_VISIBLE or WS_SYSMENU
                or WS_MAXIMIZEBOX or WS_SIZEBOX, 40, 10,
                300, 200, fMainWindow, 0, hInstance, Self);
  fIsShowing := true;
end;

procedure TRadioBrowser.Close;
begin
  ShowWindow(FHandle, 0);       //SW_HIDE
  fIsShowing := false;
end;

(* Playlist Window Function *)
function TRadioBrowser.InstWndProc(wnd: HWND; uMsg: UINT; wp: WPARAM; lp: LPARAM): LRESULT; stdcall;
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
    WM_CREATE:
      begin
        (* Center Window *)
        x := GetSystemMetrics(SM_CXSCREEN);   //Screenheight & -width
        y := GetSystemMetrics(SM_CYSCREEN);

        (* Move Window To New Position *)
        MoveWindow(Wnd, (x div 2) - (WindowWidth2 div 2),
          (y div 2) - (WindowHeight2 div 2),
          WindowWidth2, WindowHeight2, true);

       // Font
        NCM := GetNonClientMetrics;
        hwndFont := CreateFontIndirect(NCM.lfStatusFont);
        if(hwndFont <> 0) then
        begin
          //SendMessage(hwndSearchEdt, WM_SETFONT, WPARAM(hwndFont), LPARAM(true));
          //SendMessage(hwndSearchlbl, WM_SETFONT, WPARAM(hwndFont), LPARAM(true));
          //SendMessage(hwndPLToolBar, WM_SETFONT, WPARAM(hwndFont), LPARAM(true));
       end;
      end;

    WM_SHOWWINDOW:
      begin
        SendMessage(wnd, WM_SIZE, 0, 0);
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

      end;

      WM_DESTROY:
      begin
        fIsShowing := false;
      end
    else
      Result := DefWindowProc(wnd, uMsg, wp, lp);
  end;
end;

end.
