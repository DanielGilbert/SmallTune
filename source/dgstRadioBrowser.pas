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
  dgstHelper,
  dgstRadioBrowserApi;

type
  TRadioBrowser = class
  private
    hwndListView,
    hwndComboBox,
    FHandle : HWND;
    hwndFont: HFont;
    fRadioBrowserApi: TRadioBrowserApi;

    fMainWindow : HWND;
    fIsShowing: boolean;
    function GetNonClientMetrics: TNonClientMetrics;
    function InstWndProc(wnd: HWND; uMsg: UINT; wp: WPARAM; lp: LPARAM): LRESULT; stdcall;
  public
    property IsShowing : Boolean read fIsShowing;

    constructor Create(hMainWindow: HWND; _hInstance: HINST; RadioBrowserApi: TRadiobrowserApi);
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

constructor TRadioBrowser.Create(hMainWindow: HWND; _hInstance: HINST; RadioBrowserApi: TRadiobrowserApi);
var
  wc : TWndClassEx;
begin
  fMainWindow := hMainWindow;
  fRadioBrowserApi := RadioBrowserApi;
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
  UnregisterClass(radiobrowserWndClassName, hInstance);
end;

function TRadioBrowser.GetNonClientMetrics: TNonClientMetrics;
begin
  Result.cbSize := SizeOf(NONCLIENTMETRICS);
  SystemParametersInfo(SPI_GETNONCLIENTMETRICS, SizeOf(NONCLIENTMETRICS), @Result, 0);
end;

procedure TRadioBrowser.Show;
begin
  CreateWindowEx(WS_EX_ACCEPTFILES, radiobrowserWndClassName, RadiobrowserWndName,
                WS_CAPTION or WS_VISIBLE or WS_SYSMENU
                or WS_MAXIMIZEBOX or WS_SIZEBOX, 40, 10,
                RadioBrowserWindowWidth, RadioBrowserWindowHeight, fMainWindow, 0, hInstance, Self);
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
  x,y: Integer;
  NCM: TNonClientMetrics;
  i: integer;
  countries: TCountryCodes;
begin
  Result := 0;
  case uMsg of
    WM_CREATE:
      begin
        (* Center Window *)
        x := GetSystemMetrics(SM_CXSCREEN);   //Screenheight & -width
        y := GetSystemMetrics(SM_CYSCREEN);

        (* Move Window To New Position *)
        MoveWindow(Wnd, (x div 2) - (RadioBrowserWindowWidth div 2),
          (y div 2) - (RadioBrowserWindowHeight div 2),
          RadioBrowserWindowWidth, RadioBrowserWindowHeight, true);

        //Combobox
        hwndComboBox := CreateWindowEx(0, COMBOBOXCLASSNAME, nil, WS_CHILD or
          WS_VISIBLE or CBS_DROPDOWNLIST or CBS_HASSTRINGS or WS_VSCROLL,
          XCountriesComboboxOffset, YCountriesComboboxOffset, CountriesComboboxWidth, CountriesComboboxHeight, wnd, IDC_COUNTRIES_CBX, hInstance, nil);

        hwndListView := CreateWindowEx(WS_EX_CLIENTEDGE, LISTVIEW_CLASSNAME, nil, WS_CHILD
        or WS_VISIBLE or LVS_REPORT or LVS_OWNERDATA or LVS_SHOWSELALWAYS(* or LVS_SINGLESEL*), XStationsListViewOffset, YStationsListViewOffset, StationsListViewWidth, StationsListViewHeight,
        Wnd, 0, hInstance, nil);

        countries := fRadioBrowserApi.FetchAllCountries;

        for i := 0 to Length(countries) - 1 do
          SendMessage(hwndComboBox, CB_ADDSTRING, 0, INTEGER(PCHAR(String(countries[I]))));

        SendMessage(hwndComboBox, CB_SETCURSEL, 0, 0);

       // Font
        NCM := GetNonClientMetrics;
        hwndFont := CreateFontIndirect(NCM.lfStatusFont);
        if(hwndFont <> 0) then
        begin
          SendMessage(hwndComboBox, WM_SETFONT, WPARAM(hwndFont), LPARAM(true));
       end;
      end;

    WM_COMMAND:
      begin
        case hiword(wP) of

        CBN_SELCHANGE:
          case LoWord(wP) of

            IDC_LANG_CBX:
              begin
                if SendDlgItemMessage(Wnd, IDC_RADIOBROWSER_COUNTRY_CBX, CB_GETCURSEL, 0, 0) <> CB_ERR  then
                begin
                  //Translator.CurrentLanguage := Translator.AvailableLanguages.fLng[SendDlgItemMessage(hDlgWnd, IDC_LANG_CBX, CB_GETCURSEL, 0, 0)].ISO_Code
                end;
              end;

           end;
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
