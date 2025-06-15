unit dgstCommCtrl;

interface
  uses Windows, dgstActiveX;

const
  WM_USER             = $0400;

  {$EXTERNALSYM TV_FIRST}
  TV_FIRST                = $1100;      { TreeView messages }

  {$EXTERNALSYM TVN_FIRST}
  TVN_FIRST                = 0-400;       { treeview }
  {$EXTERNALSYM TVN_LAST}
  TVN_LAST                 = 0-499;

  cctrl = comctl32;

type
  (* TLVColumn *)
  PLVColumnA = ^TLVColumnA;
  PLVColumnW = ^TLVColumnW;
  PLVColumn = PLVColumnA;

  {$EXTERNALSYM tagLVCOLUMNA}
  tagLVCOLUMNA = packed record
    mask: UINT;
    fmt: Integer;
    cx: Integer;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iSubItem: Integer;
    iImage: Integer;
    iOrder: Integer;
  end;

  {$EXTERNALSYM tagLVCOLUMNW}
  tagLVCOLUMNW = packed record
    mask: UINT;
    fmt: Integer;
    cx: Integer;
    pszText: PWideChar;
    cchTextMax: Integer;
    iSubItem: Integer;
    iImage: Integer;
    iOrder: Integer;
  end;

  {$EXTERNALSYM tagLVCOLUMN}
  tagLVCOLUMN = tagLVCOLUMNA;
  {$EXTERNALSYM _LV_COLUMNA}
  _LV_COLUMNA = tagLVCOLUMNA;
  {$EXTERNALSYM _LV_COLUMNW}
  _LV_COLUMNW = tagLVCOLUMNW;
  {$EXTERNALSYM _LV_COLUMN}
  _LV_COLUMN = _LV_COLUMNA;
  TLVColumnA = tagLVCOLUMNA;
  TLVColumnW = tagLVCOLUMNW;
  TLVColumn = TLVColumnA;
  {$EXTERNALSYM LV_COLUMNA}
  LV_COLUMNA = tagLVCOLUMNA;
  {$EXTERNALSYM LV_COLUMNW}
  LV_COLUMNW = tagLVCOLUMNW;
  {$EXTERNALSYM LV_COLUMN}
  LV_COLUMN = LV_COLUMNA;

  PNMHdr = ^TNMHdr;
  {$EXTERNALSYM tagNMHDR}
  tagNMHDR = packed record
    hwndFrom: HWND;
    idFrom: UINT;
    code: Integer;     { NM_ code }
  end;
  TNMHdr = tagNMHDR;
  {$EXTERNALSYM NMHDR}
  NMHDR = tagNMHDR;

  PLVItemA = ^TLVItemA;
  PLVItemW = ^TLVItemW;
  PLVItem = PLVItemA;
  {$EXTERNALSYM tagLVITEMA}
  tagLVITEMA = packed record
    mask: UINT;
    iItem: Integer;
    iSubItem: Integer;
    state: UINT;
    stateMask: UINT;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iImage: Integer;
    lParam: LPARAM;
    iIndent: Integer;
  end;
  {$EXTERNALSYM tagLVITEMW}
  tagLVITEMW = packed record
    mask: UINT;
    iItem: Integer;
    iSubItem: Integer;
    state: UINT;
    stateMask: UINT;
    pszText: PWideChar;
    cchTextMax: Integer;
    iImage: Integer;
    lParam: LPARAM;
    iIndent: Integer;
  end;
  {$EXTERNALSYM tagLVITEM}
  tagLVITEM = tagLVITEMA;
  {$EXTERNALSYM _LV_ITEMA}
  _LV_ITEMA = tagLVITEMA;
  {$EXTERNALSYM _LV_ITEMW}
  _LV_ITEMW = tagLVITEMW;
  {$EXTERNALSYM _LV_ITEM}
  _LV_ITEM = _LV_ITEMA;
  TLVItemA = tagLVITEMA;
  TLVItemW = tagLVITEMW;
  TLVItem = TLVItemA;
  {$EXTERNALSYM LV_ITEMA}
  LV_ITEMA = tagLVITEMA;
  {$EXTERNALSYM LV_ITEMW}
  LV_ITEMW = tagLVITEMW;
  {$EXTERNALSYM LV_ITEM}
  LV_ITEM = LV_ITEMA;

  PLVDispInfoA = ^TLVDispInfoA;
  PLVDispInfoW = ^TLVDispInfoW;
  PLVDispInfo = PLVDispInfoA;
  {$EXTERNALSYM tagLVDISPINFO}
  tagLVDISPINFO = packed record
    hdr: TNMHDR;
    item: TLVItemA;
  end;
  {$EXTERNALSYM _LV_DISPINFO}
  _LV_DISPINFO = tagLVDISPINFO;
  {$EXTERNALSYM tagLVDISPINFOW}
  tagLVDISPINFOW = packed record
    hdr: TNMHDR;
    item: TLVItemW;
  end;
  {$EXTERNALSYM _LV_DISPINFOW}
  _LV_DISPINFOW = tagLVDISPINFOW;
  TLVDispInfoA = tagLVDISPINFO;
  TLVDispInfoW = tagLVDISPINFOW;
  TLVDispInfo = TLVDispInfoA;
  {$EXTERNALSYM LV_DISPINFOA}
  LV_DISPINFOA = tagLVDISPINFO;
  {$EXTERNALSYM LV_DISPINFOW}
  LV_DISPINFOW = tagLVDISPINFOW;
  {$EXTERNALSYM LV_DISPINFO}
  LV_DISPINFO = LV_DISPINFOA;

  {$EXTERNALSYM tagNMLVCACHEHINT}
  tagNMLVCACHEHINT = packed record
    hdr: TNMHDR;
    iFrom: Integer;
    iTo: Integer;
  end;
  PNMLVCacheHint = ^TNMLVCacheHint;
  TNMLVCacheHint = tagNMLVCACHEHINT;
  PNMCacheHint = ^TNMCacheHint;
  TNMCacheHint = tagNMLVCACHEHINT;

  tagLVKEYDOWN = packed record
    hdr: TNMHDR;
    wVKey: WORD;
    flags: UINT;
  end;

  NMLVKEYDOWN = tagLVKEYDOWN;
  TNMLVKEYDOWN = NMLVKEYDOWN;
  PNMLVKEYDOWN = ^tagLVKEYDOWN;

  tagNMLISTVIEW = packed record
    hdr: NMHDR;
    iItem: Integer;
    iSubItem: Integer;
    uNewState: UINT;
    uOldState: UINT;
    uChanged: UINT;
    ptAction: TPoint;
    lParam: LPARAM;
  end;
  NMLISTVIEW = tagNMLISTVIEW;
  PNMLISTVIEW = ^tagNMLISTVIEW;

  {$EXTERNALSYM tagINITCOMMONCONTROLSEX}
  tagINITCOMMONCONTROLSEX = packed record
    dwSize: DWORD;             // size of this structure
    dwICC: DWORD;              // flags indicating which classes to be initialized
  end;
  PInitCommonControlsEx = ^TInitCommonControlsEx;
  TInitCommonControlsEx = tagINITCOMMONCONTROLSEX;

{ ====== IMAGE LIST =========================================== }

const
  {$EXTERNALSYM CLR_NONE}
  CLR_NONE                = $FFFFFFFF;
  {$EXTERNALSYM CLR_DEFAULT}
  CLR_DEFAULT             = $FF000000;

type
  {$EXTERNALSYM HIMAGELIST}
  HIMAGELIST = THandle;

  {$EXTERNALSYM _IMAGELISTDRAWPARAMS}
  _IMAGELISTDRAWPARAMS = packed record
    cbSize: DWORD;
    himl: HIMAGELIST;
    i: Integer;
    hdcDst: HDC;
    x: Integer;
    y: Integer;
    cx: Integer;
    cy: Integer;
    xBitmap: Integer;        // x offest from the upperleft of bitmap
    yBitmap: Integer;        // y offset from the upperleft of bitmap
    rgbBk: COLORREF;
    rgbFg: COLORREF;
    fStyle: UINT;
    dwRop: DWORD;
  end;
  PImageListDrawParams = ^TImageListDrawParams;
  TImageListDrawParams = _IMAGELISTDRAWPARAMS;

const
  {$EXTERNALSYM ILC_MASK}
  ILC_MASK                = $0001;
  {$EXTERNALSYM ILC_COLOR}
  ILC_COLOR               = $0000;
  {$EXTERNALSYM ILC_COLORDDB}
  ILC_COLORDDB            = $00FE;
  {$EXTERNALSYM ILC_COLOR4}
  ILC_COLOR4              = $0004;
  {$EXTERNALSYM ILC_COLOR8}
  ILC_COLOR8              = $0008;
  {$EXTERNALSYM ILC_COLOR16}
  ILC_COLOR16             = $0010;
  {$EXTERNALSYM ILC_COLOR24}
  ILC_COLOR24             = $0018;
  {$EXTERNALSYM ILC_COLOR32}
  ILC_COLOR32             = $0020;
  {$EXTERNALSYM ILC_PALETTE}
  ILC_PALETTE             = $0800;

{$EXTERNALSYM ImageList_Create}
function ImageList_Create(CX, CY: Integer; Flags: UINT;
  Initial, Grow: Integer): HIMAGELIST; stdcall;
{$EXTERNALSYM ImageList_Destroy}
function ImageList_Destroy(ImageList: HIMAGELIST): Bool; stdcall;
{$EXTERNALSYM ImageList_GetImageCount}
function ImageList_GetImageCount(ImageList: HIMAGELIST): Integer; stdcall;
{$EXTERNALSYM ImageList_SetImageCount}
function ImageList_SetImageCount(himl: HIMAGELIST; uNewCount: UINT): Integer; stdcall;
{$EXTERNALSYM ImageList_Add}
function ImageList_Add(ImageList: HIMAGELIST; Image, Mask: HBitmap): Integer; stdcall;
{$EXTERNALSYM ImageList_ReplaceIcon}
function ImageList_ReplaceIcon(ImageList: HIMAGELIST; Index: Integer;
  Icon: HIcon): Integer; stdcall;
{$EXTERNALSYM ImageList_SetBkColor}
function ImageList_SetBkColor(ImageList: HIMAGELIST; ClrBk: TColorRef): TColorRef; stdcall;
{$EXTERNALSYM ImageList_GetBkColor}
function ImageList_GetBkColor(ImageList: HIMAGELIST): TColorRef; stdcall;
{$EXTERNALSYM ImageList_SetOverlayImage}
function ImageList_SetOverlayImage(ImageList: HIMAGELIST; Image: Integer;
  Overlay: Integer): Bool; stdcall;

{$EXTERNALSYM ImageList_AddIcon}
function ImageList_AddIcon(ImageList: HIMAGELIST; Icon: HIcon): Integer; //inline;

const
  {$EXTERNALSYM ILD_NORMAL}
  ILD_NORMAL              = $0000;
  {$EXTERNALSYM ILD_TRANSPARENT}
  ILD_TRANSPARENT         = $0001;
  {$EXTERNALSYM ILD_MASK}
  ILD_MASK                = $0010;
  {$EXTERNALSYM ILD_IMAGE}
  ILD_IMAGE               = $0020;
  {$EXTERNALSYM ILD_ROP}
  ILD_ROP                 = $0040;
  {$EXTERNALSYM ILD_BLEND25}
  ILD_BLEND25             = $0002;
  {$EXTERNALSYM ILD_BLEND50}
  ILD_BLEND50             = $0004;
  {$EXTERNALSYM ILD_OVERLAYMASK}
  ILD_OVERLAYMASK         = $0F00;

{$EXTERNALSYM IndexToOverlayMask}
function IndexToOverlayMask(Index: Integer): Integer; //inline;

const
  {$EXTERNALSYM ILD_SELECTED}
  ILD_SELECTED            = ILD_BLEND50;
  {$EXTERNALSYM ILD_FOCUS}
  ILD_FOCUS               = ILD_BLEND25;
  {$EXTERNALSYM ILD_BLEND}
  ILD_BLEND               = ILD_BLEND50;
  {$EXTERNALSYM CLR_HILIGHT}
  CLR_HILIGHT             = CLR_DEFAULT;

{$EXTERNALSYM ImageList_Draw}
function ImageList_Draw(ImageList: HIMAGELIST; Index: Integer;
  Dest: HDC; X, Y: Integer; Style: UINT): Bool; stdcall;

{$EXTERNALSYM ImageList_Replace}
function ImageList_Replace(ImageList: HIMAGELIST; Index: Integer;
  Image, Mask: HBitmap): Bool; stdcall;
{$EXTERNALSYM ImageList_AddMasked}
function ImageList_AddMasked(ImageList: HIMAGELIST; Image: HBitmap;
  Mask: TColorRef): Integer; stdcall;
{$EXTERNALSYM ImageList_DrawEx}
function ImageList_DrawEx(ImageList: HIMAGELIST; Index: Integer;
  Dest: HDC; X, Y, DX, DY: Integer; Bk, Fg: TColorRef; Style: Cardinal): Bool; stdcall;
{$EXTERNALSYM ImageList_DrawIndirect}
function ImageList_DrawIndirect(pimldp: PImageListDrawParams): Integer; stdcall;
{$EXTERNALSYM ImageList_Remove}
function ImageList_Remove(ImageList: HIMAGELIST; Index: Integer): Bool; stdcall;
{$EXTERNALSYM ImageList_GetIcon}
function ImageList_GetIcon(ImageList: HIMAGELIST; Index: Integer;
  Flags: Cardinal): HIcon; stdcall;
{$EXTERNALSYM ImageList_LoadImage}
function ImageList_LoadImage(Instance: THandle; Bmp: PChar; CX, Grow: Integer;
  Mask: TColorRef; pType, Flags: Cardinal): HIMAGELIST; stdcall;
{$EXTERNALSYM ImageList_LoadImageA}
function ImageList_LoadImageA(Instance: THandle; Bmp: PAnsiChar; CX, Grow: Integer;
  Mask: TColorRef; pType, Flags: Cardinal): HIMAGELIST; stdcall;
{$EXTERNALSYM ImageList_LoadImageW}
function ImageList_LoadImageW(Instance: THandle; Bmp: PWideChar; CX, Grow: Integer;
  Mask: TColorRef; pType, Flags: Cardinal): HIMAGELIST; stdcall;

const
  {$EXTERNALSYM ILCF_MOVE}
  ILCF_MOVE   = $00000000;
  {$EXTERNALSYM ILCF_SWAP}
  ILCF_SWAP   = $00000001;

{$EXTERNALSYM ImageList_Copy}
function ImageList_Copy(himlDst: HIMAGELIST; iDst: Integer; himlSrc: HIMAGELIST;
  Src: Integer; uFlags: UINT): Integer; stdcall;

{$EXTERNALSYM ImageList_BeginDrag}
function ImageList_BeginDrag(ImageList: HIMAGELIST; Track: Integer;
  XHotSpot, YHotSpot: Integer): Bool; stdcall;
{$EXTERNALSYM ImageList_EndDrag}
function ImageList_EndDrag: Bool; stdcall;
{$EXTERNALSYM ImageList_DragEnter}
function ImageList_DragEnter(LockWnd: HWnd; X, Y: Integer): Bool; stdcall;
{$EXTERNALSYM ImageList_DragLeave}
function ImageList_DragLeave(LockWnd: HWnd): Bool; stdcall;
{$EXTERNALSYM ImageList_DragMove}
function ImageList_DragMove(X, Y: Integer): Bool; stdcall;
{$EXTERNALSYM ImageList_SetDragCursorImage}
function ImageList_SetDragCursorImage(ImageList: HIMAGELIST; Drag: Integer;
  XHotSpot, YHotSpot: Integer): Bool; stdcall;
{$EXTERNALSYM ImageList_DragShowNolock}
function ImageList_DragShowNolock(Show: Bool): Bool; stdcall;
{$EXTERNALSYM ImageList_GetDragImage}
function ImageList_GetDragImage(Point, HotSpot: PPoint): HIMAGELIST; stdcall;

{ macros }
{$EXTERNALSYM ImageList_RemoveAll}
procedure ImageList_RemoveAll(ImageList: HIMAGELIST); //inline;
{$EXTERNALSYM ImageList_ExtractIcon}
function ImageList_ExtractIcon(Instance: THandle; ImageList: HIMAGELIST;
  Image: Integer): HIcon; //inline;
{$EXTERNALSYM ImageList_LoadBitmap}
function ImageList_LoadBitmap(Instance: THandle; Bmp: PChar;
  CX, Grow: Integer; MasK: TColorRef): HIMAGELIST;
{$EXTERNALSYM ImageList_LoadBitmapA}
function ImageList_LoadBitmapA(Instance: THandle; Bmp: PAnsiChar;
  CX, Grow: Integer; MasK: TColorRef): HIMAGELIST;
{$EXTERNALSYM ImageList_LoadBitmapW}
function ImageList_LoadBitmapW(Instance: THandle; Bmp: PWideChar;
  CX, Grow: Integer; MasK: TColorRef): HIMAGELIST;

{$EXTERNALSYM ImageList_Read}
function ImageList_Read(Stream: IStream): HIMAGELIST; stdcall;
{$EXTERNALSYM ImageList_Write}
function ImageList_Write(ImageList: HIMAGELIST; Stream: IStream): BOOL; stdcall;

type
  PImageInfo = ^TImageInfo;
  {$EXTERNALSYM _IMAGEINFO}
  _IMAGEINFO = packed record
    hbmImage: HBitmap;
    hbmMask: HBitmap;
    Unused1: Integer;
    Unused2: Integer;
    rcImage: TRect;
  end;
  TImageInfo = _IMAGEINFO;
  {$EXTERNALSYM IMAGEINFO}
  IMAGEINFO = _IMAGEINFO;

{$EXTERNALSYM ImageList_GetIconSize}
function ImageList_GetIconSize(ImageList: HIMAGELIST; var CX, CY: Integer): Bool; stdcall;
{$EXTERNALSYM ImageList_SetIconSize}
function ImageList_SetIconSize(ImageList: HIMAGELIST; CX, CY: Integer): Bool; stdcall;
{$EXTERNALSYM ImageList_GetImageInfo}
function ImageList_GetImageInfo(ImageList: HIMAGELIST; Index: Integer;
  var ImageInfo: TImageInfo): Bool; stdcall;
{$EXTERNALSYM ImageList_Merge}
function ImageList_Merge(ImageList1: HIMAGELIST; Index1: Integer;
  ImageList2: HIMAGELIST; Index2: Integer; DX, DY: Integer): HIMAGELIST; stdcall;
{$EXTERNALSYM ImageList_Duplicate}
function ImageList_Duplicate(himl: HIMAGELIST): HIMAGELIST; stdcall;

{ ====== COMBOBOX CONTROL ================ }

const
  {$EXTERNALSYM COMBOBOXCLASSNAME}
  COMBOBOXCLASSNAME = 'ComboBox';


{ ====== TOOLBAR CONTROL =================== }

const
  {$EXTERNALSYM TOOLBARCLASSNAME}
  TOOLBARCLASSNAME = 'ToolbarWindow32';

type
  PTBButton = ^TTBButton;
  {$EXTERNALSYM _TBBUTTON}
  _TBBUTTON = packed record
    iBitmap: Integer;
    idCommand: Integer;
    fsState: Byte;
    fsStyle: Byte;
    bReserved: array[1..2] of Byte;
    dwData: Longint;
    iString: Integer;
  end;
  TTBButton = _TBBUTTON;

  PColorMap = ^TColorMap;
  {$EXTERNALSYM _COLORMAP}
  _COLORMAP = packed record
    cFrom: TColorRef;
    cTo: TColorRef;
  end;
  TColorMap = _COLORMAP;
  {$EXTERNALSYM COLORMAP}
  COLORMAP = _COLORMAP;

const

  {$EXTERNALSYM CMB_MASKED}
  CMB_MASKED              = $02;

  {$EXTERNALSYM TBSTATE_CHECKED}
  TBSTATE_CHECKED         = $01;
  {$EXTERNALSYM TBSTATE_PRESSED}
  TBSTATE_PRESSED         = $02;
  {$EXTERNALSYM TBSTATE_ENABLED}
  TBSTATE_ENABLED         = $04;
  {$EXTERNALSYM TBSTATE_HIDDEN}
  TBSTATE_HIDDEN          = $08;
  {$EXTERNALSYM TBSTATE_INDETERMINATE}
  TBSTATE_INDETERMINATE   = $10;
  {$EXTERNALSYM TBSTATE_WRAP}
  TBSTATE_WRAP            = $20;
  {$EXTERNALSYM TBSTATE_ELLIPSES}
  TBSTATE_ELLIPSES        = $40;
  {$EXTERNALSYM TBSTATE_MARKED}
  TBSTATE_MARKED          = $80;

  {$EXTERNALSYM TBSTYLE_BUTTON}
  TBSTYLE_BUTTON          = $00;
  {$EXTERNALSYM TBSTYLE_SEP}
  TBSTYLE_SEP             = $01;
  {$EXTERNALSYM TBSTYLE_CHECK}
  TBSTYLE_CHECK           = $02;
  {$EXTERNALSYM TBSTYLE_GROUP}
  TBSTYLE_GROUP           = $04;
  {$EXTERNALSYM TBSTYLE_CHECKGROUP}
  TBSTYLE_CHECKGROUP      = TBSTYLE_GROUP or TBSTYLE_CHECK;
  {$EXTERNALSYM TBSTYLE_DROPDOWN}
  TBSTYLE_DROPDOWN        = $08;
  {$EXTERNALSYM TBSTYLE_AUTOSIZE}
  TBSTYLE_AUTOSIZE        = $0010; // automatically calculate the cx of the button
  {$EXTERNALSYM TBSTYLE_NOPREFIX}
  TBSTYLE_NOPREFIX        = $0020; // if this button should not have accel prefix

  {$EXTERNALSYM TBSTYLE_TOOLTIPS}
  TBSTYLE_TOOLTIPS        = $0100;
  {$EXTERNALSYM TBSTYLE_WRAPABLE}
  TBSTYLE_WRAPABLE        = $0200;
  {$EXTERNALSYM TBSTYLE_ALTDRAG}
  TBSTYLE_ALTDRAG         = $0400;
  {$EXTERNALSYM TBSTYLE_FLAT}
  TBSTYLE_FLAT            = $0800;
  {$EXTERNALSYM TBSTYLE_LIST}
  TBSTYLE_LIST            = $1000;
  {$EXTERNALSYM TBSTYLE_CUSTOMERASE}
  TBSTYLE_CUSTOMERASE     = $2000;
  {$EXTERNALSYM TBSTYLE_REGISTERDROP}
  TBSTYLE_REGISTERDROP    = $4000;
  {$EXTERNALSYM TBSTYLE_TRANSPARENT}
  TBSTYLE_TRANSPARENT     = $8000;
  {$EXTERNALSYM TBSTYLE_EX_DRAWDDARROWS}
  TBSTYLE_EX_DRAWDDARROWS = $00000001;

  { For IE >= 0x0500 }
  {$EXTERNALSYM BTNS_BUTTON}
  BTNS_BUTTON             = TBSTYLE_BUTTON;
  {$EXTERNALSYM BTNS_SEP}
  BTNS_SEP                = TBSTYLE_SEP;
  {$EXTERNALSYM BTNS_CHECK}
  BTNS_CHECK              = TBSTYLE_CHECK;
  {$EXTERNALSYM BTNS_GROUP}
  BTNS_GROUP              = TBSTYLE_GROUP;
  {$EXTERNALSYM BTNS_CHECKGROUP}
  BTNS_CHECKGROUP         = TBSTYLE_CHECKGROUP;
  {$EXTERNALSYM BTNS_DROPDOWN}
  BTNS_DROPDOWN           = TBSTYLE_DROPDOWN;
  {$EXTERNALSYM BTNS_AUTOSIZE}
  BTNS_AUTOSIZE           = TBSTYLE_AUTOSIZE;
  {$EXTERNALSYM BTNS_NOPREFIX}
  BTNS_NOPREFIX           = TBSTYLE_NOPREFIX;
  { For IE >= 0x0501 }
  {$EXTERNALSYM BTNS_SHOWTEXT}
  BTNS_SHOWTEXT           = $0040;  // ignored unless TBSTYLE_EX_MIXEDBUTTONS is set

  { For IE >= 0x0500 }
  {$EXTERNALSYM BTNS_WHOLEDROPDOWN}
  BTNS_WHOLEDROPDOWN      = $0080;  // draw drop-down arrow, but without split arrow section

  { For IE >= 0x0501 }
  {$EXTERNALSYM TBSTYLE_EX_MIXEDBUTTONS}
  TBSTYLE_EX_MIXEDBUTTONS = $00000008;
  {$EXTERNALSYM TBSTYLE_EX_HIDECLIPPEDBUTTONS}
  TBSTYLE_EX_HIDECLIPPEDBUTTONS = $00000010;  // don't show partially obscured buttons

  { For Windows >= XP }
  {$EXTERNALSYM TBSTYLE_EX_DOUBLEBUFFER}
  TBSTYLE_EX_DOUBLEBUFFER = $00000080; // Double Buffer the toolbar


const
  // Toolbar custom draw return flags
  {$EXTERNALSYM TBCDRF_NOEDGES}
  TBCDRF_NOEDGES              = $00010000;  // Don't draw button edges
  {$EXTERNALSYM TBCDRF_HILITEHOTTRACK}
  TBCDRF_HILITEHOTTRACK       = $00020000;  // Use color of the button bk when hottracked
  {$EXTERNALSYM TBCDRF_NOOFFSET}
  TBCDRF_NOOFFSET             = $00040000;  // Don't offset button if pressed
  {$EXTERNALSYM TBCDRF_NOMARK}
  TBCDRF_NOMARK               = $00080000;  // Don't draw default highlight of image/text for TBSTATE_MARKED
  {$EXTERNALSYM TBCDRF_NOETCHEDEFFECT}
  TBCDRF_NOETCHEDEFFECT       = $00100000;  // Don't draw etched effect for disabled items

  {$EXTERNALSYM TB_ENABLEBUTTON}
  TB_ENABLEBUTTON         = WM_USER + 1;
  {$EXTERNALSYM TB_CHECKBUTTON}
  TB_CHECKBUTTON          = WM_USER + 2;
  {$EXTERNALSYM TB_PRESSBUTTON}
  TB_PRESSBUTTON          = WM_USER + 3;
  {$EXTERNALSYM TB_HIDEBUTTON}
  TB_HIDEBUTTON           = WM_USER + 4;
  {$EXTERNALSYM TB_INDETERMINATE}
  TB_INDETERMINATE        = WM_USER + 5;
  {$EXTERNALSYM TB_MARKBUTTON}
  TB_MARKBUTTON           = WM_USER + 6;
  {$EXTERNALSYM TB_ISBUTTONENABLED}
  TB_ISBUTTONENABLED      = WM_USER + 9;
  {$EXTERNALSYM TB_ISBUTTONCHECKED}
  TB_ISBUTTONCHECKED      = WM_USER + 10;
  {$EXTERNALSYM TB_ISBUTTONPRESSED}
  TB_ISBUTTONPRESSED      = WM_USER + 11;
  {$EXTERNALSYM TB_ISBUTTONHIDDEN}
  TB_ISBUTTONHIDDEN       = WM_USER + 12;
  {$EXTERNALSYM TB_ISBUTTONINDETERMINATE}
  TB_ISBUTTONINDETERMINATE = WM_USER + 13;
  {$EXTERNALSYM TB_ISBUTTONHIGHLIGHTED}
  TB_ISBUTTONHIGHLIGHTED   = WM_USER + 14;
  {$EXTERNALSYM TB_SETSTATE}
  TB_SETSTATE             = WM_USER + 17;
  {$EXTERNALSYM TB_GETSTATE}
  TB_GETSTATE             = WM_USER + 18;
  {$EXTERNALSYM TB_ADDBITMAP}
  TB_ADDBITMAP            = WM_USER + 19;

  {$EXTERNALSYM TB_ADDBUTTONSA}
  TB_ADDBUTTONSA          = WM_USER + 20;
  {$EXTERNALSYM TB_ADDBUTTONS}
  TB_ADDBUTTONS           = TB_ADDBUTTONSA;
  {$EXTERNALSYM TB_BUTTONSTRUCTSIZE}
  TB_BUTTONSTRUCTSIZE     = WM_USER + 30;
  {$EXTERNALSYM TB_SETIMAGELIST}
  TB_SETIMAGELIST         = WM_USER + 48;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  {$EXTERNALSYM TB_CUSTOMIZE}
  TB_CUSTOMIZE            = WM_USER + 27;
  {$EXTERNALSYM TB_GETITEMRECT}
  TB_GETITEMRECT          = WM_USER + 29;
  {$EXTERNALSYM TB_SETBUTTONSIZE}
  TB_SETBUTTONSIZE        = WM_USER + 31;
  {$EXTERNALSYM TB_SETBITMAPSIZE}
  TB_SETBITMAPSIZE        = WM_USER + 32;
  {$EXTERNALSYM TB_AUTOSIZE}
  TB_AUTOSIZE             = WM_USER + 33;
  {$EXTERNALSYM TB_GETTOOLTIPS}
  TB_GETTOOLTIPS          = WM_USER + 35;
  {$EXTERNALSYM TB_SETTOOLTIPS}
  TB_SETTOOLTIPS          = WM_USER + 36;
  {$EXTERNALSYM TB_SETPARENT}
  TB_SETPARENT            = WM_USER + 37;
  {$EXTERNALSYM TB_SETROWS}
  TB_SETROWS              = WM_USER + 39;
  {$EXTERNALSYM TB_GETROWS}
  TB_GETROWS              = WM_USER + 40;
  {$EXTERNALSYM TB_SETCMDID}
  TB_SETCMDID             = WM_USER + 42;
  {$EXTERNALSYM TB_CHANGEBITMAP}
  TB_CHANGEBITMAP         = WM_USER + 43;
  {$EXTERNALSYM TB_GETBITMAP}
  TB_GETBITMAP            = WM_USER + 44;
  {$EXTERNALSYM TB_REPLACEBITMAP}
  TB_REPLACEBITMAP        = WM_USER + 46;
  {$EXTERNALSYM TB_SETINDENT}
  TB_SETINDENT            = WM_USER + 47;
  {$EXTERNALSYM TB_GETIMAGELIST}
  TB_GETIMAGELIST         = WM_USER + 49;
  {$EXTERNALSYM TB_LOADIMAGES}
  TB_LOADIMAGES           = WM_USER + 50;
  {$EXTERNALSYM TB_GETRECT}
  TB_GETRECT              = WM_USER + 51; { wParam is the Cmd instead of index }
  {$EXTERNALSYM TB_SETHOTIMAGELIST}
  TB_SETHOTIMAGELIST      = WM_USER + 52;
  {$EXTERNALSYM TB_GETHOTIMAGELIST}
  TB_GETHOTIMAGELIST      = WM_USER + 53;
  {$EXTERNALSYM TB_SETDISABLEDIMAGELIST}
  TB_SETDISABLEDIMAGELIST = WM_USER + 54;
  {$EXTERNALSYM TB_GETDISABLEDIMAGELIST}
  TB_GETDISABLEDIMAGELIST = WM_USER + 55;
  {$EXTERNALSYM TB_SETSTYLE}
  TB_SETSTYLE             = WM_USER + 56;
  {$EXTERNALSYM TB_GETSTYLE}
  TB_GETSTYLE             = WM_USER + 57;
  {$EXTERNALSYM TB_GETBUTTONSIZE}
  TB_GETBUTTONSIZE        = WM_USER + 58;
  {$EXTERNALSYM TB_SETBUTTONWIDTH}
  TB_SETBUTTONWIDTH       = WM_USER + 59;
  {$EXTERNALSYM TB_SETMAXTEXTROWS}
  TB_SETMAXTEXTROWS       = WM_USER + 60;
  {$EXTERNALSYM TB_GETTEXTROWS}
  TB_GETTEXTROWS          = WM_USER + 61;

  {$EXTERNALSYM TB_GETOBJECT}
  TB_GETOBJECT            = WM_USER + 62;  // wParam == IID, lParam void **ppv
  {$EXTERNALSYM TB_GETHOTITEM}
  TB_GETHOTITEM           = WM_USER + 71;
  {$EXTERNALSYM TB_SETHOTITEM}
  TB_SETHOTITEM           = WM_USER + 72;  // wParam == iHotItem
  {$EXTERNALSYM TB_SETANCHORHIGHLIGHT}
  TB_SETANCHORHIGHLIGHT   = WM_USER + 73;  // wParam == TRUE/FALSE
  {$EXTERNALSYM TB_GETANCHORHIGHLIGHT}
  TB_GETANCHORHIGHLIGHT   = WM_USER + 74;
  {$EXTERNALSYM TB_MAPACCELERATORA}
  TB_MAPACCELERATORA      = WM_USER + 78;  // wParam == ch, lParam int * pidBtn

  {$EXTERNALSYM TB_ADDSTRINGA}
  TB_ADDSTRINGA            = WM_USER + 28;
  {$EXTERNALSYM TB_ADDSTRING}
  TB_ADDSTRING            = TB_ADDSTRINGA;

Type
  {$EXTERNALSYM tagNMTOOLBARA}
  tagNMTOOLBARA = packed record
    hdr: TNMHdr;
    iItem: Integer;
    tbButton: TTBButton;
    cchText: Integer;
    pszText: PAnsiChar;
  end;
  {$EXTERNALSYM tagNMTOOLBARW}
  tagNMTOOLBARW = packed record
    hdr: TNMHdr;
    iItem: Integer;
    tbButton: TTBButton;
    cchText: Integer;
    pszText: PWideChar;
  end;
  {$EXTERNALSYM tagNMTOOLBAR}
  tagNMTOOLBAR = tagNMTOOLBARA;
  PNMToolBarA = ^TNMToolBarA;
  PNMToolBarW = ^TNMToolBarW;
  PNMToolBar = PNMToolBarA;
  TNMToolBarA = tagNMTOOLBARA;
  TNMToolBarW = tagNMTOOLBARW;
  TNMToolBar = TNMToolBarA;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


{ ====== TRACKBAR CONTROL =================== }
const

  {$EXTERNALSYM TRACKBAR_CLASS}
  TRACKBAR_CLASS = 'msctls_trackbar32';

const
  // Return codes for TBN_DROPDOWN
  {$EXTERNALSYM TBDDRET_DEFAULT}
  TBDDRET_DEFAULT         = 0;
  {$EXTERNALSYM TBDDRET_NODEFAULT}
  TBDDRET_NODEFAULT       = 1;
  {$EXTERNALSYM TBDDRET_TREATPRESSED}
  TBDDRET_TREATPRESSED    = 2;       // Treat as a standard press button

  {$EXTERNALSYM TBN_FIRST}
  TBN_FIRST                = 0-700;       { toolbar }
  {$EXTERNALSYM TBN_LAST}
  TBN_LAST                 = 0-720;

  {$EXTERNALSYM TBS_AUTOTICKS}
  TBS_AUTOTICKS           = $0001;
  {$EXTERNALSYM TBS_VERT}
  TBS_VERT                = $0002;
  {$EXTERNALSYM TBS_HORZ}
  TBS_HORZ                = $0000;
  {$EXTERNALSYM TBS_TOP}
  TBS_TOP                 = $0004;
  {$EXTERNALSYM TBS_BOTTOM}
  TBS_BOTTOM              = $0000;
  {$EXTERNALSYM TBS_LEFT}
  TBS_LEFT                = $0004;
  {$EXTERNALSYM TBS_RIGHT}
  TBS_RIGHT               = $0000;
  {$EXTERNALSYM TBS_BOTH}
  TBS_BOTH                = $0008;
  {$EXTERNALSYM TBS_NOTICKS}
  TBS_NOTICKS             = $0010;
  {$EXTERNALSYM TBS_ENABLESELRANGE}
  TBS_ENABLESELRANGE      = $0020;
  {$EXTERNALSYM TBS_FIXEDLENGTH}
  TBS_FIXEDLENGTH         = $0040;
  {$EXTERNALSYM TBS_NOTHUMB}
  TBS_NOTHUMB             = $0080;
  {$EXTERNALSYM TBS_TOOLTIPS}
  TBS_TOOLTIPS            = $0100;

  {$EXTERNALSYM TBM_GETPOS}
  TBM_GETPOS              = WM_USER;
  {$EXTERNALSYM TBM_GETRANGEMIN}
  TBM_GETRANGEMIN         = WM_USER+1;
  {$EXTERNALSYM TBM_GETRANGEMAX}
  TBM_GETRANGEMAX         = WM_USER+2;
  {$EXTERNALSYM TBM_GETTIC}
  TBM_GETTIC              = WM_USER+3;
  {$EXTERNALSYM TBM_SETTIC}
  TBM_SETTIC              = WM_USER+4;
  {$EXTERNALSYM TBM_SETPOS}
  TBM_SETPOS              = WM_USER+5;
  {$EXTERNALSYM TBM_SETRANGE}
  TBM_SETRANGE            = WM_USER+6;
  {$EXTERNALSYM TBM_SETRANGEMIN}
  TBM_SETRANGEMIN         = WM_USER+7;
  {$EXTERNALSYM TBM_SETRANGEMAX}
  TBM_SETRANGEMAX         = WM_USER+8;
  {$EXTERNALSYM TBM_CLEARTICS}
  TBM_CLEARTICS           = WM_USER+9;
  {$EXTERNALSYM TBM_SETSEL}
  TBM_SETSEL              = WM_USER+10;
  {$EXTERNALSYM TBM_SETSELSTART}
  TBM_SETSELSTART         = WM_USER+11;
  {$EXTERNALSYM TBM_SETSELEND}
  TBM_SETSELEND           = WM_USER+12;
  {$EXTERNALSYM TBM_GETPTICS}
  TBM_GETPTICS            = WM_USER+14;
  {$EXTERNALSYM TBM_GETTICPOS}
  TBM_GETTICPOS           = WM_USER+15;
  {$EXTERNALSYM TBM_GETNUMTICS}
  TBM_GETNUMTICS          = WM_USER+16;
  {$EXTERNALSYM TBM_GETSELSTART}
  TBM_GETSELSTART         = WM_USER+17;
  {$EXTERNALSYM TBM_GETSELEND}
  TBM_GETSELEND           = WM_USER+18;
  {$EXTERNALSYM TBM_CLEARSEL}
  TBM_CLEARSEL            = WM_USER+19;
  {$EXTERNALSYM TBM_SETTICFREQ}
  TBM_SETTICFREQ          = WM_USER+20;
  {$EXTERNALSYM TBM_SETPAGESIZE}
  TBM_SETPAGESIZE         = WM_USER+21;
  {$EXTERNALSYM TBM_GETPAGESIZE}
  TBM_GETPAGESIZE         = WM_USER+22;
  {$EXTERNALSYM TBM_SETLINESIZE}
  TBM_SETLINESIZE         = WM_USER+23;
  {$EXTERNALSYM TBM_GETLINESIZE}
  TBM_GETLINESIZE         = WM_USER+24;
  {$EXTERNALSYM TBM_GETTHUMBRECT}
  TBM_GETTHUMBRECT        = WM_USER+25;
  {$EXTERNALSYM TBM_GETCHANNELRECT}
  TBM_GETCHANNELRECT      = WM_USER+26;
  {$EXTERNALSYM TBM_SETTHUMBLENGTH}
  TBM_SETTHUMBLENGTH      = WM_USER+27;
  {$EXTERNALSYM TBM_GETTHUMBLENGTH}
  TBM_GETTHUMBLENGTH      = WM_USER+28;
  {$EXTERNALSYM TBM_SETTOOLTIPS}
  TBM_SETTOOLTIPS         = WM_USER+29;
  {$EXTERNALSYM TBM_GETTOOLTIPS}
  TBM_GETTOOLTIPS         = WM_USER+30;
  {$EXTERNALSYM TBM_SETTIPSIDE}
  TBM_SETTIPSIDE          = WM_USER+31;

  {$EXTERNALSYM TBN_DROPDOWN}
  TBN_DROPDOWN            = TBN_FIRST-10;

{$EXTERNALSYM TB_LINEUP}
  TB_LINEUP               = 0;
  {$EXTERNALSYM TB_LINEDOWN}
  TB_LINEDOWN             = 1;
  {$EXTERNALSYM TB_PAGEUP}
  TB_PAGEUP               = 2;
  {$EXTERNALSYM TB_PAGEDOWN}
  TB_PAGEDOWN             = 3;
  {$EXTERNALSYM TB_THUMBPOSITION}
  TB_THUMBPOSITION        = 4;
  {$EXTERNALSYM TB_THUMBTRACK}
  TB_THUMBTRACK           = 5;
  {$EXTERNALSYM TB_TOP}
  TB_TOP                  = 6;
  {$EXTERNALSYM TB_BOTTOM}
  TB_BOTTOM               = 7;
  {$EXTERNALSYM TB_ENDTRACK}
  TB_ENDTRACK             = 8;


{ ====== COMMON CONTROL STYLES ================ }

const
  {$EXTERNALSYM CCS_TOP}
  CCS_TOP                 = $00000001;
  {$EXTERNALSYM CCS_NOMOVEY}
  CCS_NOMOVEY             = $00000002;
  {$EXTERNALSYM CCS_BOTTOM}
  CCS_BOTTOM              = $00000003;
  {$EXTERNALSYM CCS_NORESIZE}
  CCS_NORESIZE            = $00000004;
  {$EXTERNALSYM CCS_NOPARENTALIGN}
  CCS_NOPARENTALIGN       = $00000008;
  {$EXTERNALSYM CCS_ADJUSTABLE}
  CCS_ADJUSTABLE          = $00000020;
  {$EXTERNALSYM CCS_NODIVIDER}
  CCS_NODIVIDER           = $00000040;
  {$EXTERNALSYM CCS_VERT}
  CCS_VERT                = $00000080;
  {$EXTERNALSYM CCS_LEFT}
  CCS_LEFT                = (CCS_VERT or CCS_TOP);
  {$EXTERNALSYM CCS_RIGHT}
  CCS_RIGHT               = (CCS_VERT or CCS_BOTTOM);
  {$EXTERNALSYM CCS_NOMOVEX}
  CCS_NOMOVEX             = (CCS_VERT or CCS_NOMOVEY);



type
  PTBAddBitmap = ^TTBAddBitmap;
  {$EXTERNALSYM tagTBADDBITMAP}
  tagTBADDBITMAP = packed record
    hInst: THandle;
    nID: UINT;
  end;
  TTBAddBitmap = tagTBADDBITMAP;
  {$EXTERNALSYM TBADDBITMAP}
  TBADDBITMAP = tagTBADDBITMAP;

const

(* ListView *)

  {$EXTERNALSYM NM_FIRST}
  NM_FIRST                 = 0-  0;       { generic to all controls }
  {$EXTERNALSYM NM_LAST}
  NM_LAST                  = 0- 99;
  {$EXTERNALSYM LVM_FIRST}
  LVM_FIRST               = $1000;      { ListView messages }
  {$EXTERNALSYM LVN_FIRST}
  LVN_FIRST                = 0-100;       { listview }
  {$EXTERNALSYM LVN_LAST}
  LVN_LAST                 = 0-199;
  {$EXTERNALSYM LVCF_FMT}
  LVCF_FMT                = $0001;
  {$EXTERNALSYM LVCF_WIDTH}
  LVCF_WIDTH              = $0002;
  {$EXTERNALSYM LVCF_TEXT}
  LVCF_TEXT               = $0004;
  {$EXTERNALSYM LVCF_SUBITEM}
  LVCF_SUBITEM            = $0008;
  {$EXTERNALSYM LVCF_IMAGE}
  LVCF_IMAGE              = $0010;
  {$EXTERNALSYM LVCF_ORDER}
  LVCF_ORDER              = $0020;

  {$EXTERNALSYM LVCFMT_LEFT}
  LVCFMT_LEFT             = $0000; 
  {$EXTERNALSYM LVCFMT_RIGHT}
  LVCFMT_RIGHT            = $0001;
  {$EXTERNALSYM LVCFMT_CENTER}
  LVCFMT_CENTER           = $0002; 
  {$EXTERNALSYM LVCFMT_JUSTIFYMASK}
  LVCFMT_JUSTIFYMASK      = $0003;
  {$EXTERNALSYM LVCFMT_IMAGE}
  LVCFMT_IMAGE            = $0800;
  {$EXTERNALSYM LVCFMT_BITMAP_ON_RIGHT}
  LVCFMT_BITMAP_ON_RIGHT  = $1000;
  {$EXTERNALSYM LVCFMT_COL_HAS_IMAGES}
  LVCFMT_COL_HAS_IMAGES   = $8000;

  {$EXTERNALSYM LVM_GETCOLUMNA}
  LVM_GETCOLUMNA          = LVM_FIRST + 25;
  {$EXTERNALSYM LVM_GETCOLUMNW}
  LVM_GETCOLUMNW          = LVM_FIRST + 95;
  {$EXTERNALSYM LVM_GETCOLUMN}
  LVM_GETCOLUMN           = LVM_GETCOLUMNA;

  {$EXTERNALSYM LVM_INSERTCOLUMNA}
  LVM_INSERTCOLUMNA        = LVM_FIRST + 27;
  {$EXTERNALSYM LVM_INSERTCOLUMNW}
  LVM_INSERTCOLUMNW        = LVM_FIRST + 97;
  {$EXTERNALSYM LVM_INSERTCOLUMN}
  LVM_INSERTCOLUMN        = LVM_INSERTCOLUMNA;

  { List View Styles }
  {$EXTERNALSYM LVS_ICON}
  LVS_ICON                = $0000;
  {$EXTERNALSYM LVS_REPORT}
  LVS_REPORT              = $0001;
  {$EXTERNALSYM LVS_SMALLICON}
  LVS_SMALLICON           = $0002;
  {$EXTERNALSYM LVS_LIST}
  LVS_LIST                = $0003;
  {$EXTERNALSYM LVS_TYPEMASK}
  LVS_TYPEMASK            = $0003;
  {$EXTERNALSYM LVS_SINGLESEL}
  LVS_SINGLESEL           = $0004;
  {$EXTERNALSYM LVS_SHOWSELALWAYS}
  LVS_SHOWSELALWAYS       = $0008;
  {$EXTERNALSYM LVS_SORTASCENDING}
  LVS_SORTASCENDING       = $0010;
  {$EXTERNALSYM LVS_SORTDESCENDING}
  LVS_SORTDESCENDING      = $0020;
  {$EXTERNALSYM LVS_SHAREIMAGELISTS}
  LVS_SHAREIMAGELISTS     = $0040;
  {$EXTERNALSYM LVS_NOLABELWRAP}
  LVS_NOLABELWRAP         = $0080;
  {$EXTERNALSYM LVS_AUTOARRANGE}
  LVS_AUTOARRANGE         = $0100;
  {$EXTERNALSYM LVS_EDITLABELS}
  LVS_EDITLABELS          = $0200;
  {$EXTERNALSYM LVS_OWNERDATA}
  LVS_OWNERDATA           = $1000; 
  {$EXTERNALSYM LVS_NOSCROLL}
  LVS_NOSCROLL            = $2000;

  {$EXTERNALSYM LVS_TYPESTYLEMASK}
  LVS_TYPESTYLEMASK       = $FC00;

  {$EXTERNALSYM LVS_ALIGNTOP}
  LVS_ALIGNTOP            = $0000;
  {$EXTERNALSYM LVS_ALIGNLEFT}
  LVS_ALIGNLEFT           = $0800;
  {$EXTERNALSYM LVS_ALIGNMASK}
  LVS_ALIGNMASK           = $0c00;

  {$EXTERNALSYM LVS_OWNERDRAWFIXED}
  LVS_OWNERDRAWFIXED      = $0400;
  {$EXTERNALSYM LVS_NOCOLUMNHEADER}
  LVS_NOCOLUMNHEADER      = $4000;
  {$EXTERNALSYM LVS_NOSORTHEADER}
  LVS_NOSORTHEADER        = $8000;

  { List View Extended Styles }
  {$EXTERNALSYM LVS_EX_GRIDLINES}
  LVS_EX_GRIDLINES        = $00000001;
  {$EXTERNALSYM LVS_EX_SUBITEMIMAGES}
  LVS_EX_SUBITEMIMAGES    = $00000002;
  {$EXTERNALSYM LVS_EX_CHECKBOXES}
  LVS_EX_CHECKBOXES       = $00000004;
  {$EXTERNALSYM LVS_EX_TRACKSELECT}
  LVS_EX_TRACKSELECT      = $00000008;
  {$EXTERNALSYM LVS_EX_HEADERDRAGDROP}
  LVS_EX_HEADERDRAGDROP   = $00000010;
  {$EXTERNALSYM LVS_EX_FULLROWSELECT}
  LVS_EX_FULLROWSELECT    = $00000020; // applies to report mode only
  {$EXTERNALSYM LVS_EX_ONECLICKACTIVATE}
  LVS_EX_ONECLICKACTIVATE = $00000040;
  {$EXTERNALSYM LVS_EX_TWOCLICKACTIVATE}
  LVS_EX_TWOCLICKACTIVATE = $00000080;
  {$EXTERNALSYM LVS_EX_FLATSB}
  LVS_EX_FLATSB           = $00000100;
  {$EXTERNALSYM LVS_EX_REGIONAL}
  LVS_EX_REGIONAL         = $00000200;
  {$EXTERNALSYM LVS_EX_INFOTIP}
  LVS_EX_INFOTIP          = $00000400; // listview does InfoTips for you
  {$EXTERNALSYM LVS_EX_UNDERLINEHOT}
  LVS_EX_UNDERLINEHOT     = $00000800;
  {$EXTERNALSYM LVS_EX_UNDERLINECOLD}
  LVS_EX_UNDERLINECOLD    = $00001000;
  {$EXTERNALSYM LVS_EX_MULTIWORKAREAS}
  LVS_EX_MULTIWORKAREAS   = $00002000;

  {$EXTERNALSYM LVM_SETEXTENDEDLISTVIEWSTYLE}
  LVM_SETEXTENDEDLISTVIEWSTYLE = LVM_FIRST + 54;

  {$EXTERNALSYM LVM_SETITEMCOUNT}
  LVM_SETITEMCOUNT        = LVM_FIRST + 47;

  {$EXTERNALSYM LVM_GETNEXTITEM}
  LVM_GETNEXTITEM         = LVM_FIRST + 12;

  {$EXTERNALSYM LVM_GETITEMA}
  LVM_GETITEMA            = LVM_FIRST + 5;
  {$EXTERNALSYM LVM_SETITEMA}
  LVM_SETITEMA            = LVM_FIRST + 6;
  {$EXTERNALSYM LVM_INSERTITEMA}
  LVM_INSERTITEMA         = LVM_FIRST + 7;

  {$EXTERNALSYM LVM_GETITEMW}
  LVM_GETITEMW            = LVM_FIRST + 75;
  {$EXTERNALSYM LVM_SETITEMW}
  LVM_SETITEMW            = LVM_FIRST + 76;
  {$EXTERNALSYM LVM_INSERTITEMW}
  LVM_INSERTITEMW         = LVM_FIRST + 77;

  {$EXTERNALSYM LVM_GETITEM}
  LVM_GETITEM            = LVM_GETITEMA;
  {$EXTERNALSYM LVM_SETITEM}
  LVM_SETITEM            = LVM_SETITEMA;
  {$EXTERNALSYM LVM_INSERTITEM}
  LVM_INSERTITEM         = LVM_INSERTITEMA;


  {$EXTERNALSYM LVM_DELETEITEM}
  LVM_DELETEITEM          = LVM_FIRST + 8;
  {$EXTERNALSYM LVM_DELETEALLITEMS}
  LVM_DELETEALLITEMS      = LVM_FIRST + 9;
  {$EXTERNALSYM LVM_GETCALLBACKMASK}
  LVM_GETCALLBACKMASK     = LVM_FIRST + 10;
  {$EXTERNALSYM LVM_SETCALLBACKMASK}
  LVM_SETCALLBACKMASK     = LVM_FIRST + 11;

  {$EXTERNALSYM LVM_ENSUREVISIBLE}
  LVM_ENSUREVISIBLE       = LVM_FIRST + 19;

  {$EXTERNALSYM LVM_SETITEMSTATE}
  LVM_SETITEMSTATE        = LVM_FIRST + 43;

  const
  {$EXTERNALSYM LVM_SETSELECTIONMARK}
  LVM_SETSELECTIONMARK    = LVM_FIRST + 67;
  {$EXTERNALSYM LVM_GETSELECTIONMARK}
  LVM_GETSELECTIONMARK    = LVM_FIRST + 66;

  {$EXTERNALSYM LVN_ITEMCHANGING}
  LVN_ITEMCHANGING        = LVN_FIRST-0;
  {$EXTERNALSYM LVN_ITEMCHANGED}
  LVN_ITEMCHANGED         = LVN_FIRST-1;
  {$EXTERNALSYM LVN_INSERTITEM}
  LVN_INSERTITEM          = LVN_FIRST-2;
  {$EXTERNALSYM LVN_DELETEITEM}
  LVN_DELETEITEM          = LVN_FIRST-3;
  {$EXTERNALSYM LVN_DELETEALLITEMS}
  LVN_DELETEALLITEMS      = LVN_FIRST-4;
  {$EXTERNALSYM LVN_COLUMNCLICK}
  LVN_COLUMNCLICK         = LVN_FIRST-8;
  {$EXTERNALSYM LVN_BEGINDRAG}
  LVN_BEGINDRAG           = LVN_FIRST-9;
  {$EXTERNALSYM LVN_BEGINRDRAG}
  LVN_BEGINRDRAG          = LVN_FIRST-11;

  {$EXTERNALSYM LVN_ODCACHEHINT}
  LVN_ODCACHEHINT         = LVN_FIRST-13;
  {$EXTERNALSYM LVN_ODFINDITEMA}
  LVN_ODFINDITEMA         = LVN_FIRST-52;
  {$EXTERNALSYM LVN_ODFINDITEMW}
  LVN_ODFINDITEMW         = LVN_FIRST-79;

  {$EXTERNALSYM LVN_ITEMACTIVATE}
  LVN_ITEMACTIVATE        = LVN_FIRST-14;
  {$EXTERNALSYM LVN_ODSTATECHANGED}
  LVN_ODSTATECHANGED      = LVN_FIRST-15;
  {$EXTERNALSYM LVN_KEYDOWN}
  LVN_KEYDOWN             = LVN_FIRST-55;

  {$EXTERNALSYM NM_OUTOFMEMORY}
  NM_OUTOFMEMORY           = NM_FIRST-1;
  {$EXTERNALSYM NM_CLICK}
  NM_CLICK                 = NM_FIRST-2;
  {$EXTERNALSYM NM_DBLCLK}
  NM_DBLCLK                = NM_FIRST-3;
  {$EXTERNALSYM NM_RETURN}
  NM_RETURN                = NM_FIRST-4;
  {$EXTERNALSYM NM_RCLICK}
  NM_RCLICK                = NM_FIRST-5;
  {$EXTERNALSYM NM_RDBLCLK}
  NM_RDBLCLK               = NM_FIRST-6;
  {$EXTERNALSYM NM_SETFOCUS}
  NM_SETFOCUS              = NM_FIRST-7;
  {$EXTERNALSYM NM_KILLFOCUS}
  NM_KILLFOCUS             = NM_FIRST-8;
  {$EXTERNALSYM NM_CUSTOMDRAW}
  NM_CUSTOMDRAW            = NM_FIRST-12;
  {$EXTERNALSYM NM_HOVER}
  NM_HOVER                 = NM_FIRST-13;
  {$EXTERNALSYM NM_NCHITTEST}
  NM_NCHITTEST             = NM_FIRST-14;   // uses NMMOUSE struct
  {$EXTERNALSYM NM_KEYDOWN}
  NM_KEYDOWN               = NM_FIRST-15;   // uses NMKEY struct
  {$EXTERNALSYM NM_RELEASEDCAPTURE}
  NM_RELEASEDCAPTURE       = NM_FIRST-16;
  {$EXTERNALSYM NM_SETCURSOR}
  NM_SETCURSOR             = NM_FIRST-17;   // uses NMMOUSE struct
  {$EXTERNALSYM NM_CHAR}
  NM_CHAR                  = NM_FIRST-18;   // uses NMCHAR struct

  {$EXTERNALSYM LVM_GETSELECTEDCOUNT}
  LVM_GETSELECTEDCOUNT    = LVM_FIRST + 50;

  {$EXTERNALSYM LVN_GETDISPINFOA}
  LVN_GETDISPINFOA        = LVN_FIRST-50;
  {$EXTERNALSYM LVN_SETDISPINFOA}
  LVN_SETDISPINFOA        = LVN_FIRST-51;
  {$EXTERNALSYM LVN_GETDISPINFOW}
  LVN_GETDISPINFOW        = LVN_FIRST-77;
  {$EXTERNALSYM LVN_SETDISPINFOW}
  LVN_SETDISPINFOW        = LVN_FIRST-78;
  {$EXTERNALSYM LVN_GETDISPINFO}
  LVN_GETDISPINFO        = LVN_GETDISPINFOA;
  {$EXTERNALSYM LVN_SETDISPINFO}
  LVN_SETDISPINFO        = LVN_SETDISPINFOA;

  {$EXTERNALSYM LVNI_ALL}
  LVNI_ALL                = $0000;
  {$EXTERNALSYM LVNI_FOCUSED}
  LVNI_FOCUSED            = $0001;
  {$EXTERNALSYM LVNI_SELECTED}
  LVNI_SELECTED           = $0002;
  {$EXTERNALSYM LVNI_CUT}
  LVNI_CUT                = $0004;
  {$EXTERNALSYM LVNI_DROPHILITED}
  LVNI_DROPHILITED        = $0008;

  {$EXTERNALSYM LVNI_ABOVE}
  LVNI_ABOVE              = $0100;
  {$EXTERNALSYM LVNI_BELOW}
  LVNI_BELOW              = $0200;
  {$EXTERNALSYM LVNI_TOLEFT}
  LVNI_TOLEFT             = $0400;
  {$EXTERNALSYM LVNI_TORIGHT}
  LVNI_TORIGHT            = $0800;

  {$EXTERNALSYM LVIF_TEXT}
  LVIF_TEXT               = $0001;
  {$EXTERNALSYM LVIF_IMAGE}
  LVIF_IMAGE              = $0002;
  {$EXTERNALSYM LVIF_PARAM}
  LVIF_PARAM              = $0004;
  {$EXTERNALSYM LVIF_STATE}
  LVIF_STATE              = $0008;
  {$EXTERNALSYM LVIF_INDENT}
  LVIF_INDENT             = $0010;
  {$EXTERNALSYM LVIF_NORECOMPUTE}
  LVIF_NORECOMPUTE        = $0800;

  {$EXTERNALSYM LVIS_FOCUSED}
  LVIS_FOCUSED            = $0001;
  {$EXTERNALSYM LVIS_SELECTED}
  LVIS_SELECTED           = $0002;
  {$EXTERNALSYM LVIS_CUT}
  LVIS_CUT                = $0004;
  {$EXTERNALSYM LVIS_DROPHILITED}
  LVIS_DROPHILITED        = $0008;
  {$EXTERNALSYM LVIS_ACTIVATING}
  LVIS_ACTIVATING         = $0020;

  {$EXTERNALSYM LVIS_OVERLAYMASK}
  LVIS_OVERLAYMASK        = $0F00;
  {$EXTERNALSYM LVIS_STATEIMAGEMASK}
  LVIS_STATEIMAGEMASK     = $F000;

  {$EXTERNALSYM ICC_LISTVIEW_CLASSES}
  ICC_LISTVIEW_CLASSES   = $00000001; // listview, header

  {$EXTERNALSYM ICC_BAR_CLASSES}
  ICC_BAR_CLASSES        = $00000004; // toolbar, statusbar, trackbar, tooltips

{$EXTERNALSYM InitCommonControlsEx}
function InitCommonControlsEx(var ICC: TInitCommonControlsEx): Bool; { Re-defined below }


{$EXTERNALSYM ListView_InsertColumn}
function ListView_InsertColumn(hwnd: HWND; iCol: Integer;
  const pcol: TLVColumn): Integer; //inline;
{$EXTERNALSYM ListView_InsertColumnA}
function ListView_InsertColumnA(hwnd: HWND; iCol: Integer;
  const pcol: TLVColumnA): Integer; //inline;
{$EXTERNALSYM ListView_InsertColumnW}
function ListView_InsertColumnW(hwnd: HWND; iCol: Integer;
  const pcol: TLVColumnW): Integer; //inline;

{$EXTERNALSYM ListView_SetItemCountEx}
procedure ListView_SetItemCountEx(hwndLV: HWND; cItems: Integer; dwFlags: DWORD); //inline;

{$EXTERNALSYM ListView_GetNextItem}
function ListView_GetNextItem(hWnd: HWND; iStart: Integer; Flags: UINT): Integer;

{$EXTERNALSYM ListView_DeleteAllItems}
function ListView_DeleteAllItems(hWnd: HWND): Bool;

{$EXTERNALSYM ListView_EnsureVisible}
function ListView_EnsureVisible(hwndLV: HWND; i: Integer; fPartialOK: Bool): Bool;

{$EXTERNALSYM ListView_SetItemState}
function ListView_SetItemState(hwndLV: HWND; i: Integer; data, mask: UINT): Bool;

{ ====== TOOLTIPS CONTROL ========================== }

const
  {$EXTERNALSYM TOOLTIPS_CLASS}
  TOOLTIPS_CLASS = 'tooltips_class32';
  {$EXTERNALSYM TTN_FIRST}
  TTN_FIRST                = 0-520;       { tooltips }
  {$EXTERNALSYM TTN_LAST}
  TTN_LAST                 = 0-549;

type
  PToolInfoA = ^TToolInfoA;
  PToolInfoW = ^TToolInfoW;
  PToolInfo = PToolInfoA;
  {$EXTERNALSYM tagTOOLINFOA}
  tagTOOLINFOA = packed record
    cbSize: UINT;
    uFlags: UINT;
    hwnd: HWND;
    uId: UINT;
    Rect: TRect;
    hInst: THandle;
    lpszText: PAnsiChar;
    lParam: LPARAM;
  end;
  {$EXTERNALSYM tagTOOLINFOW}
  tagTOOLINFOW = packed record
    cbSize: UINT;
    uFlags: UINT;
    hwnd: HWND;
    uId: UINT;
    Rect: TRect;
    hInst: THandle;
    lpszText: PWideChar;
    lParam: LPARAM;
  end;
  {$EXTERNALSYM tagTOOLINFO}
  tagTOOLINFO = tagTOOLINFOA;
  TToolInfoA = tagTOOLINFOA;
  TToolInfoW = tagTOOLINFOW;
  TToolInfo = TToolInfoA;
  {$EXTERNALSYM TOOLINFOA}
  TOOLINFOA = tagTOOLINFOA;
  {$EXTERNALSYM TOOLINFOW}
  TOOLINFOW = tagTOOLINFOW;
  {$EXTERNALSYM TOOLINFO}
  TOOLINFO = TOOLINFOA;

const
  {$EXTERNALSYM TTS_ALWAYSTIP}
  TTS_ALWAYSTIP           = $01;
  {$EXTERNALSYM TTS_NOPREFIX}
  TTS_NOPREFIX            = $02;

  {$EXTERNALSYM TTF_IDISHWND}
  TTF_IDISHWND            = $0001;

  // Use this to center around trackpoint in trackmode
  // -OR- to center around tool in normal mode.
  // Use TTF_ABSOLUTE to place the tip exactly at the track coords when
  // in tracking mode.  TTF_ABSOLUTE can be used in conjunction with TTF_CENTERTIP
  // to center the tip absolutely about the track point.

  {$EXTERNALSYM TTF_CENTERTIP}
  TTF_CENTERTIP           = $0002;
  {$EXTERNALSYM TTF_RTLREADING}
  TTF_RTLREADING          = $0004;
  {$EXTERNALSYM TTF_SUBCLASS}
  TTF_SUBCLASS            = $0010;
  {$EXTERNALSYM TTF_TRACK}
  TTF_TRACK               = $0020;
  {$EXTERNALSYM TTF_ABSOLUTE}
  TTF_ABSOLUTE            = $0080;
  {$EXTERNALSYM TTF_TRANSPARENT}
  TTF_TRANSPARENT         = $0100;
  {$EXTERNALSYM TTF_DI_SETITEM}
  TTF_DI_SETITEM          = $8000;       // valid only on the TTN_NEEDTEXT callback

  {$EXTERNALSYM TTDT_AUTOMATIC}
  TTDT_AUTOMATIC          = 0;
  {$EXTERNALSYM TTDT_RESHOW}
  TTDT_RESHOW             = 1;
  {$EXTERNALSYM TTDT_AUTOPOP}
  TTDT_AUTOPOP            = 2;
  {$EXTERNALSYM TTDT_INITIAL}
  TTDT_INITIAL            = 3;

  {$EXTERNALSYM TTM_ACTIVATE}
  TTM_ACTIVATE            = WM_USER + 1;
  {$EXTERNALSYM TTM_SETDELAYTIME}
  TTM_SETDELAYTIME        = WM_USER + 3;

  {$EXTERNALSYM TTM_ADDTOOLA}
  TTM_ADDTOOLA             = WM_USER + 4;
  {$EXTERNALSYM TTM_DELTOOLA}
  TTM_DELTOOLA             = WM_USER + 5;
  {$EXTERNALSYM TTM_NEWTOOLRECTA}
  TTM_NEWTOOLRECTA         = WM_USER + 6;
  {$EXTERNALSYM TTM_GETTOOLINFOA}
  TTM_GETTOOLINFOA         = WM_USER + 8;
  {$EXTERNALSYM TTM_SETTOOLINFOA}
  TTM_SETTOOLINFOA         = WM_USER + 9;
  {$EXTERNALSYM TTM_HITTESTA}
  TTM_HITTESTA             = WM_USER + 10;
  {$EXTERNALSYM TTM_GETTEXTA}
  TTM_GETTEXTA             = WM_USER + 11;
  {$EXTERNALSYM TTM_UPDATETIPTEXTA}
  TTM_UPDATETIPTEXTA       = WM_USER + 12;
  {$EXTERNALSYM TTM_ENUMTOOLSA}
  TTM_ENUMTOOLSA           = WM_USER + 14;
  {$EXTERNALSYM TTM_GETCURRENTTOOLA}
  TTM_GETCURRENTTOOLA      = WM_USER + 15;

  {$EXTERNALSYM TTM_ADDTOOLW}
  TTM_ADDTOOLW             = WM_USER + 50;
  {$EXTERNALSYM TTM_DELTOOLW}
  TTM_DELTOOLW             = WM_USER + 51;
  {$EXTERNALSYM TTM_NEWTOOLRECTW}
  TTM_NEWTOOLRECTW         = WM_USER + 52;
  {$EXTERNALSYM TTM_GETTOOLINFOW}
  TTM_GETTOOLINFOW         = WM_USER + 53;
  {$EXTERNALSYM TTM_SETTOOLINFOW}
  TTM_SETTOOLINFOW         = WM_USER + 54;
  {$EXTERNALSYM TTM_HITTESTW}
  TTM_HITTESTW             = WM_USER + 55;
  {$EXTERNALSYM TTM_GETTEXTW}
  TTM_GETTEXTW             = WM_USER + 56;
  {$EXTERNALSYM TTM_UPDATETIPTEXTW}
  TTM_UPDATETIPTEXTW       = WM_USER + 57;
  {$EXTERNALSYM TTM_ENUMTOOLSW}
  TTM_ENUMTOOLSW           = WM_USER + 58;
  {$EXTERNALSYM TTM_GETCURRENTTOOLW}
  TTM_GETCURRENTTOOLW      = WM_USER + 59;
  {$EXTERNALSYM TTM_WINDOWFROMPOINT}
  TTM_WINDOWFROMPOINT      = WM_USER + 16;
  {$EXTERNALSYM TTM_TRACKACTIVATE}
  TTM_TRACKACTIVATE        = WM_USER + 17;  // wParam = TRUE/FALSE start end  lparam = LPTOOLINFO
  {$EXTERNALSYM TTM_TRACKPOSITION}
  TTM_TRACKPOSITION        = WM_USER + 18;  // lParam = dwPos
  {$EXTERNALSYM TTM_SETTIPBKCOLOR}
  TTM_SETTIPBKCOLOR        = WM_USER + 19;
  {$EXTERNALSYM TTM_SETTIPTEXTCOLOR}
  TTM_SETTIPTEXTCOLOR      = WM_USER + 20;
  {$EXTERNALSYM TTM_GETDELAYTIME}
  TTM_GETDELAYTIME         = WM_USER + 21;
  {$EXTERNALSYM TTM_GETTIPBKCOLOR}
  TTM_GETTIPBKCOLOR        = WM_USER + 22;
  {$EXTERNALSYM TTM_GETTIPTEXTCOLOR}
  TTM_GETTIPTEXTCOLOR      = WM_USER + 23;
  {$EXTERNALSYM TTM_SETMAXTIPWIDTH}
  TTM_SETMAXTIPWIDTH       = WM_USER + 24;
  {$EXTERNALSYM TTM_GETMAXTIPWIDTH}
  TTM_GETMAXTIPWIDTH       = WM_USER + 25;
  {$EXTERNALSYM TTM_SETMARGIN}
  TTM_SETMARGIN            = WM_USER + 26;  // lParam = lprc
  {$EXTERNALSYM TTM_GETMARGIN}
  TTM_GETMARGIN            = WM_USER + 27;  // lParam = lprc
  {$EXTERNALSYM TTM_POP}
  TTM_POP                  = WM_USER + 28;
  {$EXTERNALSYM TTM_UPDATE}
  TTM_UPDATE               = WM_USER + 29;
  {$EXTERNALSYM TTM_ADDTOOL}
  TTM_ADDTOOL             = TTM_ADDTOOLA;
  {$EXTERNALSYM TTM_DELTOOL}
  TTM_DELTOOL             = TTM_DELTOOLA;
  {$EXTERNALSYM TTM_NEWTOOLRECT}
  TTM_NEWTOOLRECT         = TTM_NEWTOOLRECTA;
  {$EXTERNALSYM TTM_GETTOOLINFO}
  TTM_GETTOOLINFO         = TTM_GETTOOLINFOA;
  {$EXTERNALSYM TTM_SETTOOLINFO}
  TTM_SETTOOLINFO         = TTM_SETTOOLINFOA;
  {$EXTERNALSYM TTM_HITTEST}
  TTM_HITTEST             = TTM_HITTESTA;
  {$EXTERNALSYM TTM_GETTEXT}
  TTM_GETTEXT             = TTM_GETTEXTA;
  {$EXTERNALSYM TTM_UPDATETIPTEXT}
  TTM_UPDATETIPTEXT       = TTM_UPDATETIPTEXTA;
  {$EXTERNALSYM TTM_ENUMTOOLS}
  TTM_ENUMTOOLS           = TTM_ENUMTOOLSA;
  {$EXTERNALSYM TTM_GETCURRENTTOOL}
  TTM_GETCURRENTTOOL      = TTM_GETCURRENTTOOLA;


  {$EXTERNALSYM TTM_RELAYEVENT}
  TTM_RELAYEVENT          = WM_USER + 7;
  {$EXTERNALSYM TTM_GETTOOLCOUNT}
  TTM_GETTOOLCOUNT        = WM_USER +13;


type
  PTTHitTestInfoA = ^TTTHitTestInfoA;
  PTTHitTestInfoW = ^TTTHitTestInfoW;
  PTTHitTestInfo = PTTHitTestInfoA;
  {$EXTERNALSYM _TT_HITTESTINFOA}
  _TT_HITTESTINFOA = packed record
    hwnd: HWND;
    pt: TPoint;
    ti: TToolInfoA;
  end;
  {$EXTERNALSYM _TT_HITTESTINFOW}
  _TT_HITTESTINFOW = packed record
    hwnd: HWND;
    pt: TPoint;
    ti: TToolInfoW;
  end;
  {$EXTERNALSYM _TT_HITTESTINFO}
  _TT_HITTESTINFO = _TT_HITTESTINFOA;
  TTTHitTestInfoA = _TT_HITTESTINFOA;
  TTTHitTestInfoW = _TT_HITTESTINFOW;
  TTTHitTestInfo = TTTHitTestInfoA;
  {$EXTERNALSYM TTHITTESTINFOA}
  TTHITTESTINFOA = _TT_HITTESTINFOA;
  {$EXTERNALSYM TTHITTESTINFOW}
  TTHITTESTINFOW = _TT_HITTESTINFOW;
  {$EXTERNALSYM TTHITTESTINFO}
  TTHITTESTINFO = TTHITTESTINFOA;


const
  {$EXTERNALSYM TTN_NEEDTEXTA}
  TTN_NEEDTEXTA            = TTN_FIRST - 0;
  {$EXTERNALSYM TTN_NEEDTEXTW}
  TTN_NEEDTEXTW            = TTN_FIRST - 10;
  {$EXTERNALSYM TTN_NEEDTEXT}
  TTN_NEEDTEXT            = TTN_NEEDTEXTA;
  {$EXTERNALSYM TTN_SHOW}
  TTN_SHOW                = TTN_FIRST - 1;
  {$EXTERNALSYM TTN_POP}
  TTN_POP                 = TTN_FIRST - 2;

type
  tagNMTTDISPINFOA = packed record
    hdr: TNMHdr;
    lpszText: PAnsiChar;
    szText: array[0..79] of AnsiChar;
    hinst: HINST;
    uFlags: UINT;
    lParam: LPARAM;
  end;
//  {$EXTERNALSYM tagNMTTDISPINFOA}
  tagNMTTDISPINFOW = packed record
    hdr: TNMHdr;
    lpszText: PWideChar;
    szText: array[0..79] of WideChar;
    hinst: HINST;
    uFlags: UINT;
    lParam: LPARAM;
  end;
//  {$EXTERNALSYM tagNMTTDISPINFOW}
  tagNMTTDISPINFO = tagNMTTDISPINFOA;
  PNMTTDispInfoA = ^TNMTTDispInfoA;
  PNMTTDispInfoW = ^TNMTTDispInfoW;
  PNMTTDispInfo = PNMTTDispInfoA;
  TNMTTDispInfoA = tagNMTTDISPINFOA;
  TNMTTDispInfoW = tagNMTTDISPINFOW;
  TNMTTDispInfo = TNMTTDispInfoA;

  {$EXTERNALSYM tagTOOLTIPTEXTA}
  tagTOOLTIPTEXTA = tagNMTTDISPINFOA;
  {$EXTERNALSYM tagTOOLTIPTEXTW}
  tagTOOLTIPTEXTW = tagNMTTDISPINFOW;
  {$EXTERNALSYM tagTOOLTIPTEXT}
  tagTOOLTIPTEXT = tagTOOLTIPTEXTA;
  {$EXTERNALSYM TOOLTIPTEXTA}
  TOOLTIPTEXTA = tagNMTTDISPINFOA;
  {$EXTERNALSYM TOOLTIPTEXTW}
  TOOLTIPTEXTW = tagNMTTDISPINFOW;
  {$EXTERNALSYM TOOLTIPTEXT}
  TOOLTIPTEXT = TOOLTIPTEXTA;
  TToolTipTextA = tagNMTTDISPINFOA;
  TToolTipTextW = tagNMTTDISPINFOW;
  TToolTipText = TToolTipTextA;
  PToolTipTextA = ^TToolTipTextA;
  PToolTipTextW = ^TToolTipTextW;
  PToolTipText = PToolTipTextA;

{ ====== TREEVIEW CONTROL =================== }

const
  {$EXTERNALSYM WC_TREEVIEW}
  WC_TREEVIEW = 'SysTreeView32';

const
  {$EXTERNALSYM TVS_HASBUTTONS}
  TVS_HASBUTTONS          = $0001;
  {$EXTERNALSYM TVS_HASLINES}
  TVS_HASLINES            = $0002;
  {$EXTERNALSYM TVS_LINESATROOT}
  TVS_LINESATROOT         = $0004;
  {$EXTERNALSYM TVS_EDITLABELS}
  TVS_EDITLABELS          = $0008;
  {$EXTERNALSYM TVS_DISABLEDRAGDROP}
  TVS_DISABLEDRAGDROP     = $0010;
  {$EXTERNALSYM TVS_SHOWSELALWAYS}
  TVS_SHOWSELALWAYS       = $0020;
  {$EXTERNALSYM TVS_RTLREADING}
  TVS_RTLREADING          = $0040;
  {$EXTERNALSYM TVS_NOTOOLTIPS}
  TVS_NOTOOLTIPS          = $0080;
  {$EXTERNALSYM TVS_CHECKBOXES}
  TVS_CHECKBOXES          = $0100;
  {$EXTERNALSYM TVS_TRACKSELECT}
  TVS_TRACKSELECT         = $0200;
  {$EXTERNALSYM TVS_SINGLEEXPAND}
  TVS_SINGLEEXPAND        = $0400;
  {$EXTERNALSYM TVS_INFOTIP}
  TVS_INFOTIP             = $0800;
  {$EXTERNALSYM TVS_FULLROWSELECT}
  TVS_FULLROWSELECT       = $1000;
  {$EXTERNALSYM TVS_NOSCROLL}
  TVS_NOSCROLL            = $2000;
  {$EXTERNALSYM TVS_NONEVENHEIGHT}
  TVS_NONEVENHEIGHT       = $4000;

type
  {$EXTERNALSYM HTREEITEM}
  HTREEITEM = ^_TREEITEM;
  {$EXTERNALSYM _TREEITEM}
  _TREEITEM = packed record
  end;

const
  {$EXTERNALSYM TVIF_TEXT}
  TVIF_TEXT               = $0001;
  {$EXTERNALSYM TVIF_IMAGE}
  TVIF_IMAGE              = $0002;
  {$EXTERNALSYM TVIF_PARAM}
  TVIF_PARAM              = $0004;
  {$EXTERNALSYM TVIF_STATE}
  TVIF_STATE              = $0008;
  {$EXTERNALSYM TVIF_HANDLE}
  TVIF_HANDLE             = $0010;
  {$EXTERNALSYM TVIF_SELECTEDIMAGE}
  TVIF_SELECTEDIMAGE      = $0020;
  {$EXTERNALSYM TVIF_CHILDREN}
  TVIF_CHILDREN           = $0040;
  {$EXTERNALSYM TVIF_INTEGRAL}
  TVIF_INTEGRAL           = $0080;

  {$EXTERNALSYM TVIS_FOCUSED}
  TVIS_FOCUSED            = $0001;
  {$EXTERNALSYM TVIS_SELECTED}
  TVIS_SELECTED           = $0002;
  {$EXTERNALSYM TVIS_CUT}
  TVIS_CUT                = $0004;
  {$EXTERNALSYM TVIS_DROPHILITED}
  TVIS_DROPHILITED        = $0008;
  {$EXTERNALSYM TVIS_BOLD}
  TVIS_BOLD               = $0010;
  {$EXTERNALSYM TVIS_EXPANDED}
  TVIS_EXPANDED           = $0020;
  {$EXTERNALSYM TVIS_EXPANDEDONCE}
  TVIS_EXPANDEDONCE       = $0040;
  {$EXTERNALSYM TVIS_EXPANDPARTIAL}
  TVIS_EXPANDPARTIAL      = $0080;

  {$EXTERNALSYM TVIS_OVERLAYMASK}
  TVIS_OVERLAYMASK        = $0F00;
  {$EXTERNALSYM TVIS_STATEIMAGEMASK}
  TVIS_STATEIMAGEMASK     = $F000;
  {$EXTERNALSYM TVIS_USERMASK}
  TVIS_USERMASK           = $F000;


const
  {$EXTERNALSYM I_CHILDRENCALLBACK}
  I_CHILDRENCALLBACK  = -1;

type
  PTVItemA = ^TTVItemA;
  PTVItemW = ^TTVItemW;
  PTVItem = PTVItemA;
  {$EXTERNALSYM tagTVITEMA}
  tagTVITEMA = packed record
    mask: UINT;
    hItem: HTreeItem;
    state: UINT;
    stateMask: UINT;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iImage: Integer;
    iSelectedImage: Integer;
    cChildren: Integer;
    lParam: LPARAM;
  end;
  {$EXTERNALSYM tagTVITEMW}
  tagTVITEMW = packed record
    mask: UINT;
    hItem: HTreeItem;
    state: UINT;
    stateMask: UINT;
    pszText: PWideChar;
    cchTextMax: Integer;
    iImage: Integer;
    iSelectedImage: Integer;
    cChildren: Integer;
    lParam: LPARAM;
  end;
  {$EXTERNALSYM tagTVITEM}
  tagTVITEM = tagTVITEMA;
  {$EXTERNALSYM _TV_ITEMA}
  _TV_ITEMA = tagTVITEMA;
  {$EXTERNALSYM _TV_ITEMW}
  _TV_ITEMW = tagTVITEMW;
  {$EXTERNALSYM _TV_ITEM}
  _TV_ITEM = _TV_ITEMA;
  TTVItemA = tagTVITEMA;
  TTVItemW = tagTVITEMW;
  TTVItem = TTVItemA;
  {$EXTERNALSYM TV_ITEMA}
  TV_ITEMA = tagTVITEMA;
  {$EXTERNALSYM TV_ITEMW}
  TV_ITEMW = tagTVITEMW;
  {$EXTERNALSYM TV_ITEM}
  TV_ITEM = TV_ITEMA;

  // only used for Get and Set messages.  no notifies
  {$EXTERNALSYM tagTVITEMEXA}
  tagTVITEMEXA = packed record
    mask: UINT;
    hItem: HTREEITEM;
    state: UINT;
    stateMask: UINT;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iImage: Integer;
    iSelectedImage: Integer;
    cChildren: Integer;
    lParam: LPARAM;
    iIntegral: Integer;
  end;
  {$EXTERNALSYM tagTVITEMEXW}
  tagTVITEMEXW = packed record
    mask: UINT;
    hItem: HTREEITEM;
    state: UINT;
    stateMask: UINT;
    pszText: PWideChar;
    cchTextMax: Integer;
    iImage: Integer;
    iSelectedImage: Integer;
    cChildren: Integer;
    lParam: LPARAM;
    iIntegral: Integer;
  end;
  {$EXTERNALSYM tagTVITEMEX}
  tagTVITEMEX = tagTVITEMEXA;
  PTVItemExA = ^TTVItemExA;
  PTVItemExW = ^TTVItemExW;
  PTVItemEx = PTVItemExA;
  TTVItemExA = tagTVITEMEXA;
  TTVItemExW = tagTVITEMEXW;
  TTVItemEx = TTVItemExA;

const
  {$EXTERNALSYM TVI_ROOT}
  TVI_ROOT                = HTreeItem($FFFF0000);
  {$EXTERNALSYM TVI_FIRST}
  TVI_FIRST               = HTreeItem($FFFF0001);
  {$EXTERNALSYM TVI_LAST}
  TVI_LAST                = HTreeItem($FFFF0002);
  {$EXTERNALSYM TVI_SORT}
  TVI_SORT                = HTreeItem($FFFF0003);

type
  PTVInsertStructA = ^TTVInsertStructA;
  PTVInsertStructW = ^TTVInsertStructW;
  PTVInsertStruct = PTVInsertStructA;
  {$EXTERNALSYM tagTVINSERTSTRUCTA}
  tagTVINSERTSTRUCTA = packed record
    hParent: HTreeItem;
    hInsertAfter: HTreeItem;
    case Integer of
      0: (itemex: TTVItemExA);
      1: (item: TTVItemA);
  end;
  {$EXTERNALSYM tagTVINSERTSTRUCTW}
  tagTVINSERTSTRUCTW = packed record
    hParent: HTreeItem;
    hInsertAfter: HTreeItem;
    case Integer of
      0: (itemex: TTVItemExW);
      1: (item: TTVItemW);
  end;
  {$EXTERNALSYM tagTVINSERTSTRUCT}
  tagTVINSERTSTRUCT = tagTVINSERTSTRUCTA;
  {$EXTERNALSYM _TV_INSERTSTRUCTA}
  _TV_INSERTSTRUCTA = tagTVINSERTSTRUCTA;
  {$EXTERNALSYM _TV_INSERTSTRUCTW}
  _TV_INSERTSTRUCTW = tagTVINSERTSTRUCTW;
  {$EXTERNALSYM _TV_INSERTSTRUCT}
  _TV_INSERTSTRUCT = _TV_INSERTSTRUCTA;
  TTVInsertStructA = tagTVINSERTSTRUCTA;
  TTVInsertStructW = tagTVINSERTSTRUCTW;
  TTVInsertStruct = TTVInsertStructA;
  {$EXTERNALSYM TV_INSERTSTRUCTA}
  TV_INSERTSTRUCTA = tagTVINSERTSTRUCTA;
  {$EXTERNALSYM TV_INSERTSTRUCTW}
  TV_INSERTSTRUCTW = tagTVINSERTSTRUCTW;
  {$EXTERNALSYM TV_INSERTSTRUCT}
  TV_INSERTSTRUCT = TV_INSERTSTRUCTA;

const
  {$EXTERNALSYM TVM_INSERTITEMA}
  TVM_INSERTITEMA          = TV_FIRST + 0;
  {$EXTERNALSYM TVM_INSERTITEMW}
  TVM_INSERTITEMW          = TV_FIRST + 50;
  {$EXTERNALSYM TVM_INSERTITEM}
  TVM_INSERTITEM          = TVM_INSERTITEMA;
  {$EXTERNALSYM TVM_DELETEITEM}
  TVM_DELETEITEM          = TV_FIRST + 1;
  {$EXTERNALSYM TVM_EXPAND}
  TVM_EXPAND              = TV_FIRST + 2;
  {$EXTERNALSYM TVE_COLLAPSE}
  TVE_COLLAPSE            = $0001;
  {$EXTERNALSYM TVE_EXPAND}
  TVE_EXPAND              = $0002;
  {$EXTERNALSYM TVE_TOGGLE}
  TVE_TOGGLE              = $0003;
  {$EXTERNALSYM TVE_EXPANDPARTIAL}
  TVE_EXPANDPARTIAL       = $4000;
  {$EXTERNALSYM TVE_COLLAPSERESET}
  TVE_COLLAPSERESET       = $8000;
  {$EXTERNALSYM TVM_GETITEMRECT}
  TVM_GETITEMRECT         = TV_FIRST + 4;
  {$EXTERNALSYM TVM_GETCOUNT}
  TVM_GETCOUNT            = TV_FIRST + 5;
  {$EXTERNALSYM TVM_GETINDENT}
  TVM_GETINDENT           = TV_FIRST + 6;
  {$EXTERNALSYM TVM_SETINDENT}
  TVM_SETINDENT           = TV_FIRST + 7;
  {$EXTERNALSYM TVM_GETIMAGELIST}
  TVM_GETIMAGELIST        = TV_FIRST + 8;
  {$EXTERNALSYM TVSIL_NORMAL}
  TVSIL_NORMAL            = 0;
  {$EXTERNALSYM TVSIL_STATE}
  TVSIL_STATE             = 2;
  {$EXTERNALSYM TVM_SETIMAGELIST}
  TVM_SETIMAGELIST        = TV_FIRST + 9;
  {$EXTERNALSYM TVM_GETNEXTITEM}
  TVM_GETNEXTITEM         = TV_FIRST + 10;
  {$EXTERNALSYM TVGN_ROOT}
  TVGN_ROOT               = $0000;
  {$EXTERNALSYM TVGN_NEXT}
  TVGN_NEXT               = $0001;
  {$EXTERNALSYM TVGN_PREVIOUS}
  TVGN_PREVIOUS           = $0002;
  {$EXTERNALSYM TVGN_PARENT}
  TVGN_PARENT             = $0003;
  {$EXTERNALSYM TVGN_CHILD}
  TVGN_CHILD              = $0004;
  {$EXTERNALSYM TVGN_FIRSTVISIBLE}
  TVGN_FIRSTVISIBLE       = $0005;
  {$EXTERNALSYM TVGN_NEXTVISIBLE}
  TVGN_NEXTVISIBLE        = $0006;
  {$EXTERNALSYM TVGN_PREVIOUSVISIBLE}
  TVGN_PREVIOUSVISIBLE    = $0007;
  {$EXTERNALSYM TVGN_DROPHILITE}
  TVGN_DROPHILITE         = $0008;
  {$EXTERNALSYM TVGN_CARET}
  TVGN_CARET              = $0009;
  {$EXTERNALSYM TVGN_LASTVISIBLE}
  TVGN_LASTVISIBLE        = $000A;


const
  {$EXTERNALSYM TVM_SELECTITEM}
  TVM_SELECTITEM          = TV_FIRST + 11;
  {$EXTERNALSYM TVM_GETITEMA}
  TVM_GETITEMA             = TV_FIRST + 12;
  {$EXTERNALSYM TVM_GETITEMW}
  TVM_GETITEMW             = TV_FIRST + 62;
  {$EXTERNALSYM TVM_GETITEM}
  TVM_GETITEM             = TVM_GETITEMA;
  {$EXTERNALSYM TVM_SETITEMA}
  TVM_SETITEMA             = TV_FIRST + 13;
  {$EXTERNALSYM TVM_SETITEMW}
  TVM_SETITEMW             = TV_FIRST + 63;
  {$EXTERNALSYM TVM_SETITEM}
  TVM_SETITEM             = TVM_SETITEMA;
  {$EXTERNALSYM TVM_EDITLABELA}
  TVM_EDITLABELA           = TV_FIRST + 14;
  {$EXTERNALSYM TVM_EDITLABELW}
  TVM_EDITLABELW           = TV_FIRST + 65;
  {$EXTERNALSYM TVM_EDITLABEL}
  TVM_EDITLABEL           = TVM_EDITLABELA;
  {$EXTERNALSYM TVM_GETEDITCONTROL}
  TVM_GETEDITCONTROL      = TV_FIRST + 15;
  {$EXTERNALSYM TVM_GETVISIBLECOUNT}
  TVM_GETVISIBLECOUNT     = TV_FIRST + 16;
  {$EXTERNALSYM TVM_HITTEST}
  TVM_HITTEST             = TV_FIRST + 17;

type
  PTVHitTestInfo = ^TTVHitTestInfo;
  {$EXTERNALSYM tagTVHITTESTINFO}
  tagTVHITTESTINFO = packed record
    pt: TPoint;
    flags: UINT;
    hItem: HTreeItem;
  end;
  {$EXTERNALSYM _TV_HITTESTINFO}
  _TV_HITTESTINFO = tagTVHITTESTINFO;
  TTVHitTestInfo = tagTVHITTESTINFO;
  {$EXTERNALSYM TV_HITTESTINFO}
  TV_HITTESTINFO = tagTVHITTESTINFO;

const
  {$EXTERNALSYM TVHT_NOWHERE}
  TVHT_NOWHERE            = $0001;
  {$EXTERNALSYM TVHT_ONITEMICON}
  TVHT_ONITEMICON         = $0002;
  {$EXTERNALSYM TVHT_ONITEMLABEL}
  TVHT_ONITEMLABEL        = $0004;
  {$EXTERNALSYM TVHT_ONITEMINDENT}
  TVHT_ONITEMINDENT       = $0008;
  {$EXTERNALSYM TVHT_ONITEMBUTTON}
  TVHT_ONITEMBUTTON       = $0010;
  {$EXTERNALSYM TVHT_ONITEMRIGHT}
  TVHT_ONITEMRIGHT        = $0020;
  {$EXTERNALSYM TVHT_ONITEMSTATEICON}
  TVHT_ONITEMSTATEICON    = $0040;

  {$EXTERNALSYM TVHT_ONITEM}
  TVHT_ONITEM             = TVHT_ONITEMICON or TVHT_ONITEMLABEL or
			      TVHT_ONITEMSTATEICON;

  {$EXTERNALSYM TVHT_ABOVE}
  TVHT_ABOVE              = $0100;
  {$EXTERNALSYM TVHT_BELOW}
  TVHT_BELOW              = $0200;
  {$EXTERNALSYM TVHT_TORIGHT}
  TVHT_TORIGHT            = $0400;
  {$EXTERNALSYM TVHT_TOLEFT}
  TVHT_TOLEFT             = $0800;

const
  {$EXTERNALSYM TVM_CREATEDRAGIMAGE}
  TVM_CREATEDRAGIMAGE     = TV_FIRST + 18;
  {$EXTERNALSYM TVM_SORTCHILDREN}
  TVM_SORTCHILDREN        = TV_FIRST + 19;
  {$EXTERNALSYM TVM_ENSUREVISIBLE}
  TVM_ENSUREVISIBLE       = TV_FIRST + 20;

const
  {$EXTERNALSYM TVM_SORTCHILDRENCB}
  TVM_SORTCHILDRENCB      = TV_FIRST + 21;

type
  {$EXTERNALSYM PFNTVCOMPARE}
  PFNTVCOMPARE = function(lParam1, lParam2, lParamSort: Longint): Integer stdcall;
  TTVCompare = PFNTVCOMPARE;

type
  {$EXTERNALSYM tagTVSORTCB}
  tagTVSORTCB = packed record
    hParent: HTreeItem;
    lpfnCompare: TTVCompare;
    lParam: LPARAM;
  end;
  {$EXTERNALSYM _TV_SORTCB}
  _TV_SORTCB = tagTVSORTCB;
  TTVSortCB = tagTVSORTCB;
  {$EXTERNALSYM TV_SORTCB}
  TV_SORTCB = tagTVSORTCB;

const
  {$EXTERNALSYM TVM_ENDEDITLABELNOW}
  TVM_ENDEDITLABELNOW     = TV_FIRST + 22;
  {$EXTERNALSYM TVM_GETISEARCHSTRINGA}
  TVM_GETISEARCHSTRINGA    = TV_FIRST + 23;
  {$EXTERNALSYM TVM_GETISEARCHSTRINGW}
  TVM_GETISEARCHSTRINGW    = TV_FIRST + 64;
  {$EXTERNALSYM TVM_GETISEARCHSTRING}
  TVM_GETISEARCHSTRING    = TVM_GETISEARCHSTRINGA;

const
  {$EXTERNALSYM TVM_SETTOOLTIPS}
  TVM_SETTOOLTIPS         = TV_FIRST + 24;
  {$EXTERNALSYM TVM_GETTOOLTIPS}
  TVM_GETTOOLTIPS         = TV_FIRST + 25;

const
  {$EXTERNALSYM TVM_SETINSERTMARK}
  TVM_SETINSERTMARK       = TV_FIRST + 26;
  {$EXTERNALSYM TVM_SETITEMHEIGHT}
  TVM_SETITEMHEIGHT         = TV_FIRST + 27;
  {$EXTERNALSYM TVM_GETITEMHEIGHT}
  TVM_GETITEMHEIGHT         = TV_FIRST + 28;
  {$EXTERNALSYM TVM_SETBKCOLOR}
  TVM_SETBKCOLOR              = TV_FIRST + 29;
  {$EXTERNALSYM TVM_SETTEXTCOLOR}
  TVM_SETTEXTCOLOR              = TV_FIRST + 30;
  {$EXTERNALSYM TVM_GETBKCOLOR}
  TVM_GETBKCOLOR              = TV_FIRST + 31;
  {$EXTERNALSYM TVM_GETTEXTCOLOR}
  TVM_GETTEXTCOLOR              = TV_FIRST + 32;
  {$EXTERNALSYM TVM_SETSCROLLTIME}
  TVM_SETSCROLLTIME              = TV_FIRST + 33;
  {$EXTERNALSYM TVM_GETSCROLLTIME}
  TVM_GETSCROLLTIME              = TV_FIRST + 34;
  {$EXTERNALSYM TVM_SETINSERTMARKCOLOR}
  TVM_SETINSERTMARKCOLOR         = TV_FIRST + 37;
  {$EXTERNALSYM TVM_GETINSERTMARKCOLOR}
  TVM_GETINSERTMARKCOLOR         = TV_FIRST + 38;

type
  PNMTreeViewA = ^TNMTreeViewA;
  PNMTreeViewW = ^TNMTreeViewW;
  PNMTreeView = PNMTreeViewA;
  {$EXTERNALSYM tagNMTREEVIEWA}
  tagNMTREEVIEWA = packed record
    hdr: TNMHDR;
    action: UINT;
    itemOld: TTVItemA;
    itemNew: TTVItemA;
    ptDrag: TPoint;
  end;
  {$EXTERNALSYM tagNMTREEVIEWW}
  tagNMTREEVIEWW = packed record
    hdr: TNMHDR;
    action: UINT;
    itemOld: TTVItemW;
    itemNew: TTVItemW;
    ptDrag: TPoint;
  end;
  {$EXTERNALSYM tagNMTREEVIEW}
  tagNMTREEVIEW = tagNMTREEVIEWA;
  {$EXTERNALSYM _NM_TREEVIEWA}
  _NM_TREEVIEWA = tagNMTREEVIEWA;
  {$EXTERNALSYM _NM_TREEVIEWW}
  _NM_TREEVIEWW = tagNMTREEVIEWW;
  {$EXTERNALSYM _NM_TREEVIEW}
  _NM_TREEVIEW = _NM_TREEVIEWA;
  TNMTreeViewA  = tagNMTREEVIEWA;
  TNMTreeViewW  = tagNMTREEVIEWW;
  TNMTreeView = TNMTreeViewA;
  {$EXTERNALSYM NM_TREEVIEWA}
  NM_TREEVIEWA  = tagNMTREEVIEWA;
  {$EXTERNALSYM NM_TREEVIEWW}
  NM_TREEVIEWW  = tagNMTREEVIEWW;
  {$EXTERNALSYM NM_TREEVIEW}
  NM_TREEVIEW = NM_TREEVIEWA;

const
  {$EXTERNALSYM TVN_SELCHANGINGA}
  TVN_SELCHANGINGA         = TVN_FIRST-1;
  {$EXTERNALSYM TVN_SELCHANGEDA}
  TVN_SELCHANGEDA          = TVN_FIRST-2;
  {$EXTERNALSYM TVN_SELCHANGINGW}
  TVN_SELCHANGINGW         = TVN_FIRST-50;
  {$EXTERNALSYM TVN_SELCHANGEDW}
  TVN_SELCHANGEDW          = TVN_FIRST-51;
  {$EXTERNALSYM TVN_SELCHANGING}
  TVN_SELCHANGING         = TVN_SELCHANGINGA;
  {$EXTERNALSYM TVN_SELCHANGED}
  TVN_SELCHANGED          = TVN_SELCHANGEDA;
  {$EXTERNALSYM TVC_UNKNOWN}
  TVC_UNKNOWN             = $0000;
  {$EXTERNALSYM TVC_BYMOUSE}
  TVC_BYMOUSE             = $0001;
  {$EXTERNALSYM TVC_BYKEYBOARD}
  TVC_BYKEYBOARD          = $0002;
  {$EXTERNALSYM TVN_GETDISPINFOA}
  TVN_GETDISPINFOA         = TVN_FIRST-3;
  {$EXTERNALSYM TVN_SETDISPINFOA}
  TVN_SETDISPINFOA         = TVN_FIRST-4;
  {$EXTERNALSYM TVN_GETDISPINFOW}
  TVN_GETDISPINFOW         = TVN_FIRST-52;
  {$EXTERNALSYM TVN_SETDISPINFOW}
  TVN_SETDISPINFOW         = TVN_FIRST-53;
  {$EXTERNALSYM TVN_GETDISPINFO}
  TVN_GETDISPINFO         = TVN_GETDISPINFOA;
  {$EXTERNALSYM TVN_SETDISPINFO}
  TVN_SETDISPINFO         = TVN_SETDISPINFOA;

  {$EXTERNALSYM TVIF_DI_SETITEM}
  TVIF_DI_SETITEM         = $1000;

type
  PTVDispInfoA = ^TTVDispInfoA;
  PTVDispInfoW = ^TTVDispInfoW;
  PTVDispInfo = PTVDispInfoA;
  {$EXTERNALSYM tagTVDISPINFOA}
  tagTVDISPINFOA = packed record
    hdr: TNMHDR;
    item: TTVItemA;
  end;
  {$EXTERNALSYM tagTVDISPINFOW}
  tagTVDISPINFOW = packed record
    hdr: TNMHDR;
    item: TTVItemW;
  end;
  {$EXTERNALSYM tagTVDISPINFO}
  tagTVDISPINFO = tagTVDISPINFOA;
  {$EXTERNALSYM _TV_DISPINFOA}
  _TV_DISPINFOA = tagTVDISPINFOA;
  {$EXTERNALSYM _TV_DISPINFOW}
  _TV_DISPINFOW = tagTVDISPINFOW;
  {$EXTERNALSYM _TV_DISPINFO}
  _TV_DISPINFO = _TV_DISPINFOA;
  TTVDispInfoA = tagTVDISPINFOA;
  TTVDispInfoW = tagTVDISPINFOW;
  TTVDispInfo = TTVDispInfoA;
  {$EXTERNALSYM TV_DISPINFOA}
  TV_DISPINFOA = tagTVDISPINFOA;
  {$EXTERNALSYM TV_DISPINFOW}
  TV_DISPINFOW = tagTVDISPINFOW;
  {$EXTERNALSYM TV_DISPINFO}
  TV_DISPINFO = TV_DISPINFOA;

const
  {$EXTERNALSYM TVN_ITEMEXPANDINGA}
  TVN_ITEMEXPANDINGA       = TVN_FIRST-5;
  {$EXTERNALSYM TVN_ITEMEXPANDEDA}
  TVN_ITEMEXPANDEDA        = TVN_FIRST-6;
  {$EXTERNALSYM TVN_BEGINDRAGA}
  TVN_BEGINDRAGA           = TVN_FIRST-7;
  {$EXTERNALSYM TVN_BEGINRDRAGA}
  TVN_BEGINRDRAGA          = TVN_FIRST-8;
  {$EXTERNALSYM TVN_DELETEITEMA}
  TVN_DELETEITEMA          = TVN_FIRST-9;
  {$EXTERNALSYM TVN_BEGINLABELEDITA}
  TVN_BEGINLABELEDITA      = TVN_FIRST-10;
  {$EXTERNALSYM TVN_ENDLABELEDITA}
  TVN_ENDLABELEDITA        = TVN_FIRST-11;
  {$EXTERNALSYM TVN_GETINFOTIPA}
  TVN_GETINFOTIPA          = TVN_FIRST-13;
  {$EXTERNALSYM TVN_ITEMEXPANDINGW}
  TVN_ITEMEXPANDINGW       = TVN_FIRST-54;
  {$EXTERNALSYM TVN_ITEMEXPANDEDW}
  TVN_ITEMEXPANDEDW        = TVN_FIRST-55;
  {$EXTERNALSYM TVN_BEGINDRAGW}
  TVN_BEGINDRAGW           = TVN_FIRST-56;
  {$EXTERNALSYM TVN_BEGINRDRAGW}
  TVN_BEGINRDRAGW          = TVN_FIRST-57;
  {$EXTERNALSYM TVN_DELETEITEMW}
  TVN_DELETEITEMW          = TVN_FIRST-58;
  {$EXTERNALSYM TVN_BEGINLABELEDITW}
  TVN_BEGINLABELEDITW      = TVN_FIRST-59;
  {$EXTERNALSYM TVN_ENDLABELEDITW}
  TVN_ENDLABELEDITW        = TVN_FIRST-60;
  {$EXTERNALSYM TVN_GETINFOTIPW}
  TVN_GETINFOTIPW          = TVN_FIRST-14;
  {$EXTERNALSYM TVN_ITEMEXPANDING}
  TVN_ITEMEXPANDING       = TVN_ITEMEXPANDINGA;
  {$EXTERNALSYM TVN_ITEMEXPANDED}
  TVN_ITEMEXPANDED        = TVN_ITEMEXPANDEDA;
  {$EXTERNALSYM TVN_BEGINDRAG}
  TVN_BEGINDRAG           = TVN_BEGINDRAGA;
  {$EXTERNALSYM TVN_BEGINRDRAG}
  TVN_BEGINRDRAG          = TVN_BEGINRDRAGA;
  {$EXTERNALSYM TVN_DELETEITEM}
  TVN_DELETEITEM          = TVN_DELETEITEMA;
  {$EXTERNALSYM TVN_BEGINLABELEDIT}
  TVN_BEGINLABELEDIT      = TVN_BEGINLABELEDITA;
  {$EXTERNALSYM TVN_ENDLABELEDIT}
  TVN_ENDLABELEDIT        = TVN_ENDLABELEDITA;
  {$EXTERNALSYM TVN_GETINFOTIP}
  TVN_GETINFOTIP         = TVN_GETINFOTIPA;
  {$EXTERNALSYM TVN_KEYDOWN}
  TVN_KEYDOWN             = TVN_FIRST-12;
  {$EXTERNALSYM TVN_SINGLEEXPAND}
  TVN_SINGLEEXPAND        = TVN_FIRST-15;

type
  {$EXTERNALSYM tagTVKEYDOWN}
  tagTVKEYDOWN = packed record
    hdr: TNMHDR;
    wVKey: Word;
    flags: UINT;
  end;
  {$EXTERNALSYM _TV_KEYDOWN}
  _TV_KEYDOWN = tagTVKEYDOWN;
  TTVKeyDown = tagTVKEYDOWN;
  {$EXTERNALSYM TV_KEYDOWN}
  TV_KEYDOWN = tagTVKEYDOWN;

  // for tooltips
  {$EXTERNALSYM tagNMTVGETINFOTIPA}
  tagNMTVGETINFOTIPA = packed record
    hdr: TNMHdr;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    hItem: HTREEITEM;
    lParam: LPARAM;
  end;
  {$EXTERNALSYM tagNMTVGETINFOTIPW}
  tagNMTVGETINFOTIPW = packed record
    hdr: TNMHdr;
    pszText: PWideChar;
    cchTextMax: Integer;
    hItem: HTREEITEM;
    lParam: LPARAM;
  end;
  {$EXTERNALSYM tagNMTVGETINFOTIP}
  tagNMTVGETINFOTIP = tagNMTVGETINFOTIPA;
  PNMTVGetInfoTipA = ^TNMTVGetInfoTipA;
  PNMTVGetInfoTipW = ^TNMTVGetInfoTipW;
  PNMTVGetInfoTip = PNMTVGetInfoTipA;
  TNMTVGetInfoTipA = tagNMTVGETINFOTIPA;
  TNMTVGetInfoTipW = tagNMTVGETINFOTIPW;
  TNMTVGetInfoTip = TNMTVGetInfoTipA;

const
  // treeview's customdraw return meaning don't draw images.  valid on CDRF_NOTIFYITEMPREPAINT
  {$EXTERNALSYM TVCDRF_NOIMAGES}
  TVCDRF_NOIMAGES         = $00010000;

function TreeView_GetNextItem(hwnd: HWND; hitem: HTreeItem;
  code: Integer): HTreeItem;
function TreeView_GetSelection(hwnd: HWND): HTreeItem;

{ Image List }
function ImageList_Create; external cctrl name 'ImageList_Create';
function ImageList_Destroy; external cctrl name 'ImageList_Destroy';
function ImageList_GetImageCount; external cctrl name 'ImageList_GetImageCount';
function ImageList_SetImageCount; external cctrl name 'ImageList_SetImageCount';
function ImageList_Add; external cctrl name 'ImageList_Add';
function ImageList_ReplaceIcon; external cctrl name 'ImageList_ReplaceIcon';
function ImageList_SetBkColor; external cctrl name 'ImageList_SetBkColor';
function ImageList_GetBkColor; external cctrl name 'ImageList_GetBkColor';
function ImageList_SetOverlayImage; external cctrl name 'ImageList_SetOverlayImage';



function ImageList_Draw; external cctrl name 'ImageList_Draw';

function ImageList_Replace; external cctrl name 'ImageList_Replace';
function ImageList_AddMasked; external cctrl name 'ImageList_AddMasked';
function ImageList_DrawEx; external cctrl name 'ImageList_DrawEx';
function ImageList_DrawIndirect; external cctrl name 'ImageList_DrawIndirect';
function ImageList_Remove; external cctrl name 'ImageList_Remove';
function ImageList_GetIcon; external cctrl name 'ImageList_GetIcon';
function ImageList_LoadImage; external cctrl name 'ImageList_LoadImageA';
function ImageList_LoadImageA; external cctrl name 'ImageList_LoadImageA';
function ImageList_LoadImageW; external cctrl name 'ImageList_LoadImageW';
function ImageList_Copy; external cctrl name 'ImageList_Copy';
function ImageList_BeginDrag; external cctrl name 'ImageList_BeginDrag';
function ImageList_EndDrag; external cctrl name 'ImageList_EndDrag';
function ImageList_DragEnter; external cctrl name 'ImageList_DragEnter';
function ImageList_DragLeave; external cctrl name 'ImageList_DragLeave';
function ImageList_DragMove; external cctrl name 'ImageList_DragMove';
function ImageList_SetDragCursorImage; external cctrl name 'ImageList_SetDragCursorImage';
function ImageList_DragShowNolock; external cctrl name 'ImageList_DragShowNolock';
function ImageList_GetDragImage; external cctrl name 'ImageList_GetDragImage';

{ macros }

function ImageList_Read; external cctrl name 'ImageList_Read';
function ImageList_Write; external cctrl name 'ImageList_Write';

function ImageList_GetIconSize; external cctrl name 'ImageList_GetIconSize';
function ImageList_SetIconSize; external cctrl name 'ImageList_SetIconSize';
function ImageList_GetImageInfo; external cctrl name 'ImageList_GetImageInfo';
function ImageList_Merge; external cctrl name 'ImageList_Merge';
function ImageList_Duplicate(himl: HIMAGELIST): HIMAGELIST; stdcall; external cctrl name 'ImageList_Duplicate';


var
  ComCtl32DLL: THandle;
  _InitCommonControlsEx: function(var ICC: TInitCommonControlsEx): Bool stdcall;

implementation


function ImageList_AddIcon(ImageList: HIMAGELIST; Icon: HIcon): Integer;
begin
  Result := ImageList_ReplaceIcon(ImageList, -1, Icon);
end;

function IndexToOverlayMask(Index: Integer): Integer;
begin
  Result := Index shl 8;
end;

procedure ImageList_RemoveAll(ImageList: HIMAGELIST);
begin
  ImageList_Remove(ImageList, -1);
end;

function ImageList_ExtractIcon(Instance: THandle; ImageList: HIMAGELIST;
  Image: Integer): HIcon;
begin
  Result := ImageList_GetIcon(ImageList, Image, 0);
end;

function ImageList_LoadBitmap(Instance: THandle; Bmp: PChar;
  CX, Grow: Integer; Mask: TColorRef): HIMAGELIST;
begin
  Result := ImageList_LoadImage(Instance, Bmp, CX, Grow, Mask,
    IMAGE_BITMAP, 0);
end;
function ImageList_LoadBitmapA(Instance: THandle; Bmp: PAnsiChar;
  CX, Grow: Integer; Mask: TColorRef): HIMAGELIST;
begin
  Result := ImageList_LoadImageA(Instance, Bmp, CX, Grow, Mask,
    IMAGE_BITMAP, 0);
end;
function ImageList_LoadBitmapW(Instance: THandle; Bmp: PWideChar;
  CX, Grow: Integer; Mask: TColorRef): HIMAGELIST;
begin
  Result := ImageList_LoadImageW(Instance, Bmp, CX, Grow, Mask,
    IMAGE_BITMAP, 0);
end;

function ListView_InsertColumn(hwnd: HWND; iCol: Integer; const pcol: TLVColumn): Integer;
begin
  Result := SendMessage(hWnd, LVM_INSERTCOLUMN, iCol, Longint(@pcol));
end;
function ListView_InsertColumnA(hwnd: HWND; iCol: Integer; const pcol: TLVColumnA): Integer;
begin
  Result := SendMessageA(hWnd, LVM_INSERTCOLUMNA, iCol, Longint(@pcol));
end;
function ListView_InsertColumnW(hwnd: HWND; iCol: Integer; const pcol: TLVColumnW): Integer;
begin
  Result := SendMessageW(hWnd, LVM_INSERTCOLUMNW, iCol, Longint(@pcol));
end;

procedure ListView_SetItemCountEx(hwndLV: HWND; cItems: Integer; dwFlags: DWORD);
begin
  SendMessage(hwndLV, LVM_SETITEMCOUNT, cItems, dwFlags);
end;

function ListView_GetNextItem(hWnd: HWND; iStart: Integer; Flags: UINT): Integer;
begin
  Result := SendMessage(hWnd, LVM_GETNEXTITEM, iStart, MakeLong(Flags, 0));
end;

function ListView_DeleteAllItems(hWnd: HWND): Bool;
begin
  Result := Bool( SendMessage(hWnd, LVM_DELETEALLITEMS, 0, 0) );
end;

function ListView_EnsureVisible(hwndLV: HWND; i: Integer; fPartialOK: Bool): Bool;
begin
  Result := SendMessage(hwndLV, LVM_ENSUREVISIBLE, i,
    MakeLong(Integer(fPartialOK), 0)) <> 0;
end;

function ListView_SetItemState(hwndLV: HWND; i: Integer; data, mask: UINT): Bool;
var
  Item: TLVItem;
begin
  Item.stateMask := mask;
  Item.state := data;
  Result := Bool( SendMessage(hwndLV, LVM_SETITEMSTATE, i, Longint(@Item)) );
end;

function TreeView_GetNextItem(hwnd: HWND; hitem: HTreeItem;
  code: Integer): HTreeItem;
begin
  Result := HTreeItem( SendMessage(hwnd, TVM_GETNEXTITEM, code,
    Longint(hitem)) );
end;

function TreeView_GetSelection(hwnd: HWND): HTreeItem;
begin
  Result := TreeView_GetNextItem(hwnd, nil, TVGN_CARET);
end;

procedure InitComCtl;
begin
  if ComCtl32DLL = 0 then
  begin
    ComCtl32DLL := GetModuleHandle(cctrl);
    if ComCtl32DLL <> 0 then
      @_InitCommonControlsEx := GetProcAddress(ComCtl32DLL, 'InitCommonControlsEx');
  end;
end;


function InitCommonControlsEx(var ICC: TInitCommonControlsEx): Bool;
begin
  if ComCtl32DLL = 0 then InitComCtl;
  Result := Assigned(_InitCommonControlsEx) and _InitCommonControlsEx(ICC);
end;


end.
