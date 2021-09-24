//////////////////////////////////////////////////////////////////////////////
//
//   tP's nonVCL mini GDIPlus Unit
//
//   Unit:      tPnvMiniGDIPlus.pas
//   Version:   1.06a
//   Date:      10/2008 - 02.11.2009
//
//   by tupboPASCAL (tP) aka MatthiasG.
//

unit tPnvMiniGDIPlus;

{$DEFINE AUTO_INIT_GDIPlus}
{.$DEFINE IMAGES_ONLY}

{$DEFINE USE_BITMAPS}
{$DEFINE USE_PENS}
{$DEFINE USE_BRUSHES}
{$DEFINE USE_RECTANGLES_AND_CO}
{$DEFINE USE_FONT_STRINGS}
{$DEFINE USE_PATHS}
{$DEFINE USE_MATRIX_TRANSFORM}

interface

uses
  Windows;

(**************************************************************************\
*
*   GDI+ OLE / ActiveX Fragment
*
\**************************************************************************)

type
{ OLE character and string types }

  TOleChar = WideChar;
  POleStr = PWideChar;
  PPOleStr = ^POleStr;

  POleStrList = ^TOleStrList;
  TOleStrList = array[0..65535] of POleStr;

  {$EXTERNALSYM Largeint}
  Largeint = Int64;

  {$EXTERNALSYM PROPID}
  PROPID = ULONG;
  PPropID = ^TPropID;
  TPropID = PROPID;


{ Class ID }

  PCLSID = PGUID;
  TCLSID = TGUID;  

  IStream = interface;

  PStatStg = ^TStatStg;
  {$EXTERNALSYM tagSTATSTG}
  tagSTATSTG = record
    pwcsName: POleStr;
    dwType: Longint;
    cbSize: Largeint;
    mtime: TFileTime;
    ctime: TFileTime;
    atime: TFileTime;
    grfMode: Longint;
    grfLocksSupported: Longint;
    clsid: TCLSID;
    grfStateBits: Longint;
    reserved: Longint;
  end;
  TStatStg = tagSTATSTG;
  {$EXTERNALSYM STATSTG}
  STATSTG = TStatStg;

  {$EXTERNALSYM ISequentialStream}
  ISequentialStream = interface(IUnknown)
    ['{0c733a30-2a1c-11ce-ade5-00aa0044773d}']
    function Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult;
      stdcall;
    function Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult;
      stdcall;
  end;

  {$EXTERNALSYM IStream}
  IStream = interface(ISequentialStream)
    ['{0000000C-0000-0000-C000-000000000046}']
    function Seek(dlibMove: Largeint; dwOrigin: Longint;
      out libNewPosition: Largeint): HResult; stdcall;
    function SetSize(libNewSize: Largeint): HResult; stdcall;
    function CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint;
      out cbWritten: Largeint): HResult; stdcall;
    function Commit(grfCommitFlags: Longint): HResult; stdcall;
    function Revert: HResult; stdcall;
    function LockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; stdcall;
    function UnlockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; stdcall;
    function Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult;
      stdcall;
    function Clone(out stm: IStream): HResult; stdcall;
  end;

  {$EXTERNALSYM CreateStreamOnHGlobal}
  function CreateStreamOnHGlobal(hglob: HGlobal;
    fDeleteOnRelease: BOOL; out stm: IStream): HResult;
    stdcall;  external 'ole32.dll' name 'CreateStreamOnHGlobal';

type
  {$EXTERNALSYM ImageAbort}
  ImageAbort = function: BOOL; stdcall;
  {$EXTERNALSYM DrawImageAbort}
  DrawImageAbort = ImageAbort;
  {$EXTERNALSYM GetThumbnailImageAbort}
  GetThumbnailImageAbort = ImageAbort;

//----------------------------------------------------------------------------  

const
  hLibGdiPlus = 'GDIPLUS.DLL'; // Name der DLL

type
  // GDI Sartup
  GDIPlusStartupInput = record
    GdiPlusVersion: integer;
    DebugEventCallback: integer;
    SuppressBackgroundThread: integer;
    SuppressExternalCodecs: integer;
  end;

type
  Unit_ = (
    gpUnitWorld,      // 0 -- World coordinate (non-physical unit)
    gpUnitDisplay,    // 1 -- Variable -- for PageTransform only
    gpUnitPixel,      // 2 -- Each unit is one device pixel.
    gpUnitPoint,      // 3 -- Each unit is a printer's point, or 1/72 inch.
    gpUnitInch,       // 4 -- Each unit is 1 inch.
    gpUnitDocument,   // 5 -- Each unit is 1/300 inch.
    gpUnitMillimeter  // 6 -- Each unit is 1 millimeter.
    );
  TUnit = Unit_;
  TGpUnit = TUnit;


type
  PGpPoint = ^TGpPoint;
  TGpPoint = packed record
    X : Integer;
    Y : Integer;
  end;

type
  PGpPointF = ^TGpPointF;
  TGpPointF = packed record
    X : Single;
    Y : Single;
  end;

type
  PGPRect = ^TGPRect;
  TGPRect = packed record
    X     : integer;
    Y     : integer;
    Width : integer;
    Height: integer;
  end;

type
  PGPRectF = ^TGPRectF;
  TGPRectF = packed record
    X     : Single;
    Y     : Single;
    Width : Single;
    Height: Single;
  end;

type
  TGpWrapMode = (
    WrapModeTile,        // 0
    WrapModeTileFlipX,   // 1
    WrapModeTileFlipY,   // 2
    WrapModeTileFlipXY,  // 3
    WrapModeClamp        // 4  <> WrapModeClamp <--<< bringt Fehler ?!
  );

type
  TGpFillMode = (
    FillModeAlternate,        // 0
    FillModeWinding           // 1
  );

type
  TGPGraphics = Pointer;
  TGpImage    = Pointer;
  TGpBitmap   = Pointer;
  TGpImageAttributes = Pointer;
  {$IFNDEF IMAGES_ONLY}
  TGpPen      = Pointer;
  TGpBrush    = Pointer;
  TGpFont     = Pointer;
  TGpStringFormat = Pointer;
  TGpFontCollection = Pointer;
  TGpFontFamily = Pointer;
  TGpPath     = Pointer;
  TGpMatrix   = Pointer;
  {$ENDIF IMAGES_ONLY}

type
  TQualityMode = Integer;

const
  gpQualityModeInvalid = -1;
  gpQualityModeDefault = 0;
  gpQualityModeLow     = 1;   // Best performance
  gpQualityModeHigh    = 2;   // Best rendering quality

const
  gpInterpolationModeInvalid = gpQualityModeInvalid;
  gpInterpolationModeDefault = gpQualityModeDefault;
  gpInterpolationModeLowQuality = gpQualityModeLow;
  gpInterpolationModeHighQuality = gpQualityModeHigh;
  gpInterpolationModeBilinear = gpQualityModeHigh + 1;
  gpInterpolationModeBicubic = gpQualityModeHigh + 2;
  gpInterpolationModeNearestNeighbor = gpQualityModeHigh + 3;
  gpInterpolationModeHighQualityBilinear = gpQualityModeHigh + 4;
  gpInterpolationModeHighQualityBicubic = gpQualityModeHigh + 5;

type
  TInterpolationMode = gpInterpolationModeInvalid..gpInterpolationModeHighQualityBicubic;

const
  SFA_DEFAULT                            = $00000000;
  SFA_LeftToRight                        = SFA_DEFAULT;
  SFA_RightToLeft                        = $00000001;
  SFA_DirectionVertical                  = $00000002;
  SFA_NoFitBlackBox                      = $00000004;
  SFA_DisplayFormatControl               = $00000020;
  SFA_FlagsNoFontFallback                = $00000400;
  SFA_MeasureTrailingSpaces              = $00000800;
  SFA_NoWrap                             = $00001000;
  SFA_LineLimit                          = $00002000;
  SFA_NoClip                             = $00004000;

type
  TStringFormatAttributes = SFA_DEFAULT..SFA_NoClip;

type
  TStringTrimming = (
    StringTrimmingNone              = 0,
    StringTrimmingCharacter         = 1,
    StringTrimmingWord              = 2,
    StringTrimmingEllipsisCharacter = 3,
    StringTrimmingEllipsisWord      = 4,
    StringTrimmingEllipsisPath      = 5
    );

type
  TFontStyle = (
    FS_Regular,
    FS_Bold,
    FS_Italic,
    FS_BoldItalic,
    FS_Underline,
    FS_Strikeout);

type
  TStringAlignment = (SA_Near, SA_Center, SA_Far);

type
  TGpLinearGradientMode = (
    LinearGradientModeHorizontal,        // = 0
    LinearGradientModeVertical,          // = 1
    LinearGradientModeForwardDiagonal,   // = 2
    LinearGradientModeBackwardDiagonal); // = 3

type
  TTextRenderingHint = (
    TextRenderingHintSystemDefault,             // Glyph with system default rendering hint
    TextRenderingHintSingleBitPerPixelGridFit,  // Glyph bitmap with hinting
    TextRenderingHintSingleBitPerPixel,         // Glyph bitmap without hinting
    TextRenderingHintAntiAliasGridFit,          // Glyph anti-alias bitmap with hinting
    TextRenderingHintAntiAlias,                 // Glyph anti-alias bitmap without hinting
    TextRenderingHintClearTypeGridFit           // Glyph CT bitmap with hinting
  );

type
  TGpMatrixOrder = (
    MatrixOrderPrepend, //0
    MatrixOrderAppend   //1
  );

type
  TGpStatus = (
    GDIPlus_Ok,                    // 0
    GDIPlus_GenericError,          // 1
    GDIPlus_InvalidParameter,
    GDIPlus_OutOfMemory, //*************** or GDIPlus_FileNotFound ?!
    GDIPlus_ObjectBusy,
    GDIPlus_InsufficientBuffer,
    GDIPlus_NotImplemented,
    GDIPlus_Win32Error,
    GDIPlus_WrongState,
    GDIPlus_Aborted,
    GDIPlus_FileNotFound, //*************** or GDIPlus_OutOfMemory ?!
    GDIPlus_ValueOverflow,
    GDIPlus_AccessDenied,
    GDIPlus_UnknownImageFormat,
    GDIPlus_FontFamilyNotFound,
    GDIPlus_FontStyleNotFound,
    GDIPlus_NotTrueTypeFont,
    GDIPlus_UnsupportedGdiplusVersion,
    GDIPlus_GdiplusNotInitialized,
    GDIPlus_PropertyNotFound,
    GDIPlus_PropertyNotSupported,  // 20
    GDIPlus_ProfileNotFound,       // 21
    GDIPlus_ResNotFound);

var
  isGDIPlusInit: Boolean = FALSE;

  // GDI variable
  hGDIP: Cardinal; // Library Handle
  StartUpInfo: GDIPlusStartupInput;
  GdipToken: Integer;

  GDIPlus_Status: TGpStatus = GDIPlus_GenericError;
  GDIPlus_LastStatus: TGpStatus = GDIPlus_Ok;

  GdiplusStartup: function(var token: Integer;
    var lpInput: GDIPlusStartupInput;
    lpOutput: Integer): TGpStatus; stdcall;

  GdiplusShutdown: function(var token: Integer): Integer; stdcall;

  {Graphics & DC}
  GdipCreateFromHDC: function(hDC: HDC;
    var Graphics: TGPGraphics): TGpStatus; stdcall;
  GdipReleaseDC: function(graphics: TGPGraphics; hdc: HDC): TGpStatus; stdcall;
  GdipDeleteGraphics: function(Graphics: TGPGraphics): TGpStatus; stdcall;

  GdipSetInterpolationMode: function(graphics: TGPGraphics;
    interpolationMode: TInterpolationMode): TGpStatus; stdcall;

  {Image}
  GdipLoadImageFromFile: function(const fileName: PWideChar;
    var Image: TGpImage): TGpStatus; stdcall;
  GdipLoadImageFromStream: function(stream: ISTREAM; out image: TGpImage): TGpStatus; stdcall;
  //GdipLoadImageFromStreamICM: function(stream: ISTREAM; out image: TGpImage): TGpStatus; stdcall;
  GdipDisposeImage: function(Image: TGpImage): TGpStatus; stdcall;
  GdipDrawImageRect: function(graphics: TGPGraphics; image: TGpImage; x: Single;
    y: Single; width: Single; height: Single): TGpStatus; stdcall;
  GdipDrawImageRectRectI: function(graphics: TGPGraphics; image: TGpImage;
    dstx, dsty, dstwidth, dstheight: Integer;
    srcx, srcy, srcwidth, srcheight: Integer;
    srcUnit: TGPUNIT; imageAttributes: TGpImageAttributes;
    callback: DRAWIMAGEABORT; callbackData: Pointer): TGpStatus; stdcall;
  GdipDrawImagePointsI: function(graphics: TGPGraphics; image: TGpImage;
    dstpoints: PGpPoint; count: Integer): TGpStatus; stdcall;
  GdipGetImageWidth: function(Image: TGpImage;
    var Width: UINT): TGpStatus; stdcall;
  GdipGetImageHeight: function(Image: TGpImage;
    var Height: UINT): TGpStatus; stdcall;

  {$IFNDEF IMAGES_ONLY}
  {$IFDEF USE_BITMAPS}
  // Bitmap
  GdipCreateBitmapFromFile: function(filename: PWideChar;
    out bitmap: TGPBitmap): TGpStatus; stdcall;
  GdipCreateBitmapFromResource: function(hInstance: HMODULE;
    lpBitmapName: PWCHAR; out bitmap: TGpBitmap): TGpStatus; stdcall;
  GdipCreateBitmapFromStream: function(Stream: IStream; out bitmap: TGpBitmap): TGpStatus; stdcall;
  //GdipCreateBitmapFromStreamICM: function(Stream: IStream; out bitmap: TGpBitmap): TGpStatus; stdcall;
  {$ENDIF USE_BITMAPS}

  {$IFDEF USE_PENS}
  // Pen
  GdipCreatePen1: function(color: COLORREF; width: Single; unit_: TGpUnit; out pen: TGpPen): TGpStatus; stdcall;
  GdipSetPenColor: function(pen: TGpPen; color: COLORREF): TGpStatus; stdcall;
  //todo: GdipSetPenMode: function(): TGpStatus; stdcall;
  GdipDeletePen: function(pen: TGpPen): TGpStatus; stdcall;
  {$ENDIF USE_PENS}

  {$IFDEF USE_BRUSHES}
  // Brush
  GdipCreateSolidFill: function(color: COLORREF; out brush: TGpBrush): TGpStatus; stdcall;
  GdipSetSolidFillColor: function(brush: TGpBrush; color: COLORREF): TGpStatus; stdcall;
  GdipCreateLineBrushFromRectI: function (rect: PGpRect; color1, color2: COLORREF;   { = LinearGradientBrush}
    mode: TGpLinearGradientMode; wrapMode: TGpWrapMode;
    out lineGradientBrush: TGpBrush): TGpStatus; stdcall;
  GdipSetLineColors: function (brush: TGpBrush; color1, color2: COLORREF): TGpStatus; stdcall;
  GdipDeleteBrush: function(brush: TGpBrush): TGpStatus; stdcall;
  {$ENDIF USE_BRUSHES}

  {$IFDEF USE_RECTANGLES_AND_CO}
  // Rectangle, Lines & Co
  GdipGraphicsClear: function(graphics: TGPGraphics; color: COLORREF): TGpStatus; stdcall;      
  GdipFillRectangleI: function(graphics: TGPGraphics; brush: TGpBrush; x: Integer;
    y: Integer; width: Integer; height: Integer): TGpStatus; stdcall;
  GdipDrawEllipseI: function(graphics: TGPGraphics; pen: TGpPen;
    x, y, width, height: Integer): TGpStatus; stdcall;
  GdipDrawLineI: function(graphics: TGPGraphics; pen: TGpPen;
    x, y, x2, y2: Integer): TGpStatus; stdcall;
  {$ENDIF USE_RECTANGLES_AND_CO}

  {$IFDEF USE_FONT_STRINGS}
  // Font
  GdipCreateFontFromDC: function(hdc: HDC; out font: TGpFont): TGpStatus; stdcall;
  GdipCreateFont: function(fontFamily: TGpFontFamily; emSize: Single;
    FontStyle: TFontStyle; unit_: TGpUnit; out font: TGpFont): TGpStatus; stdcall;
  GdipDeleteFont: function(font: TGpFont): TGpStatus; stdcall;

  // DrawString & Co
  GdipCreateStringFormat: function(StringFormatAttributes: TStringFormatAttributes;
    language: LANGID; out StringFormat: TGpStringFormat): TGpStatus; stdcall;
  GdipDeleteStringFormat: function(StringFormat: TGpStringFormat): TGpStatus; stdcall;
  GdipSetStringFormatLineAlign: function(StringFormat: TGpStringFormat;
    StringAlignment: TStringAlignment): TGpStatus; stdcall;
  GdipDrawString: function(graphics: TGPGraphics; wString: PWCHAR;
    length: Integer; font: TGpFont; layoutRect: PGPRectF;
    stringFormat: TGpStringFormat; brush: TGpBrush): TGpStatus; stdcall;
  GdipCreateFontFamilyFromName: function(name: PWCHAR;
    fontCollection: TGpFontCollection;
    out FontFamily: TGpFontFamily): TGpStatus; stdcall;
  GdipDeleteFontFamily: function(FontFamily: TGpFontFamily): TGpStatus; stdcall;
  GdipSetTextRenderingHint: function(graphics: TGpGraphics; mode: TTextRenderingHint): TGpStatus; stdcall;
  GdipSetStringFormatTrimming: function(stringFormat: TGpStringFormat; trimming: TStringTrimming): TGpStatus; stdcall;
  GdipMeasureString: function(graphics: TGpGraphics; wString: PWCHAR; length: Integer; font: TGpFont; layoutRect: PGpRectF;
    stringFormat: TGpStringFormat; boundingBox: PGpRectF; codepointsFitted, linesFilled: pInteger): TGpStatus; stdcall;
  {$ENDIF USE_FONT_STRINGS}

  {$IFDEF USE_Paths}
  // Path
  GdipCreatePath: function(brushMode: TGpFillMode; out path: TGpPath): TGpStatus; stdcall;
  GdipFillPath: function(graphics: TGPGraphics; brush: TGpBrush; path: TGpPath): TGpStatus; stdcall;
  GdipDrawPath: function(graphics: TGpGraphics; pen: TGpPen; path: TGpPath): TGpStatus; stdcall;
  GdipDeletePath: function(path: TGpPath): TGpStatus; stdcall;

  GdipAddPathString: function(path: TGpPath; wString: PWCHAR; length: Integer;
    FontFamily: TGpFontFamily; style: TFontStyle; emSize: single; layoutRect: PGPRectF;
    stringFormat: TGpStringFormat): TGpStatus; stdcall;
  {$ENDIF USE_Paths}

  {$IFDEF USE_MATRIX_TRANSFORM}
  {Matrix & Transform}
  GdipCreateMatrix3I: function(const GpRect: TGpRect; const GpPoint: TGpPoint; out GpMatrix: TGpMatrix): TGpStatus; stdcall;
  GdipCreateMatrix: function(out GpMatrix: TGPMatrix): TGPStatus; stdcall;
  GdipDeleteMatrix: function(GpMatrix: TGPMatrix): TGPStatus; stdcall;
  GdipSetMatrixElements: function(matrix: TGPMatrix; m11: Single; m12: Single;
    m21: Single; m22: Single; dx: Single; dy: Single): TGPStatus; stdcall;
  GdipMultiplyMatrix: function(GpMatrix1, GpMatrix2: TGPMatrix; GpMatrixOrder: TGpMatrixOrder): TGpStatus; stdcall;
  GdipTranslateMatrix: function(GpMatrix: TGPMatrix; OffsetX: Single; OffsetY: Single; GpMatrixOrder: TGpMatrixOrder): TGpStatus; stdcall;
  GdipScaleMatrix: function(GpMatrix: TGPMatrix; ScaleX, Single: Real; GpMatrixOrder: TGpMatrixOrder): TGpStatus; stdcall;
  GdipRotateMatrix: function(GpMatrix: TGPMatrix; Angle: Single; GpMatrixOrder: TGpMatrixOrder): TGpStatus; stdcall;
  GdipShearMatrix: function(GpMatrix: TGPMatrix; ShearX: Single; ShearY: Single; GpMatrixOrder: TGpMatrixOrder): TGpStatus; stdcall;

  {Additional Transformation Ops}
  GdipSetWorldTransform: function(GpGraphics: TGpGraphics; GpMatrix: TGpMatrix): TGPStatus; stdcall;
  GdipTranslateWorldTransform: function(GpGraphics: TGpGraphics; dx: Single; dy: Single; GpMatrixOrder: TGpMatrixOrder): TGpStatus; stdcall;
  GdipResetWorldTransform: function(GpGraphics: TGpGraphics): TGpStatus; stdcall;
  {$ENDIF USE_MATRIX_TRANSFORM}
  {$ENDIF IMAGES_ONLY}


  function GdipLoadImageFromResource(hInstance: THandle; ResName: PChar; out image: TGpImage): TGpStatus;
  function Gdip_GetStringSize(graphics: TGpGraphics; stringFormat: TGpStringFormat;
    font: TGpFont; txt: PWChar; out Width, Height: integer ): TGpStatus;

  procedure gpGetStatus(GDIPlusStatus: TGpStatus; const ShowErrMsg: Boolean = true);
  function MakePoint(x, y: Integer): TGpPoint;
  function MakePointF(x, y: Single): TGpPointF;
  function MakeRect(x, y, width, height: Integer): TGPRect;
  function MakeRectF(x, y, width, height: Single): TGPRectF;
  function ARGB(A, R, G, B: Byte): COLORREF;

  function InitGDIPlus: BOOL;
  function CloseGDIPlus: BOOL;

implementation

// Error Handling

procedure gpGetStatus(GDIPlusStatus: TGpStatus; const ShowErrMsg: Boolean = TRUE);
var
  msg: String;
begin
  GDIPlus_LastStatus := GDIPlus_Status;
  GDIPlus_Status := GDIPlusStatus;

  if (ShowErrMsg) and (GDIPlus_Status <> GDIPlus_OK) then
  begin
    case GDIPlus_Status of
      GDIPlus_GenericError: msg := 'Generic Error';
      GDIPlus_InvalidParameter: msg := 'Invalid Parameter';
      GDIPlus_OutOfMemory: msg := 'Out Of Memory or File not found';
      GDIPlus_ObjectBusy: msg := 'Object Busy';
      GDIPlus_FileNotFound: msg := 'File not found or Out Of Memory';
      GDIPlus_Win32Error: msg := 'Win32 Error';
      GDIPlus_AccessDenied: msg := 'Access Denied';
      GDIPlus_UnsupportedGdiplusVersion: msg := 'Unsupported Gdiplus Version';
      GDIPlus_GdiplusNotInitialized: msg := 'Gdiplus not initialized';
      GDIPlus_UnknownImageFormat: msg := 'Unknown Image format';
      GDIPlus_FontFamilyNotFound: msg := 'Font Family not found';
      GDIPlus_FontStyleNotFound: msg := 'Font Style not found';
      GDIPlus_NotTrueTypeFont: msg := 'Not TrueType Font';
      GDIPlus_InsufficientBuffer: msg := 'Insufficient Puffer';
      GDIPlus_ValueOverflow: msg := 'Value Overflow';
      GDIPlus_PropertyNotFound: msg := 'Property not found';
      GDIPlus_PropertyNotSupported: msg := 'Property not Supported';
      GDIPlus_ProfileNotFound: msg := 'Profile not found';
      GDIPlus_ResNotFound: msg := 'Resource not found';
      else
        msg := 'Undef. GDI-Error !';
    end;

    MessageBox(0, PCHAR(msg), 'GDIPlus-Error:',
      MB_SETFOREGROUND or MB_APPLMODAL or MB_ICONERROR or MB_OK);

    halt;
  end;
end;

function MakePoint(x, y: Integer): TGpPoint;
begin
  Result.X      := x;
  Result.Y      := y;
end;

function MakePointF(x, y: Single): TGpPointF;
begin
  Result.X      := x;
  Result.Y      := y;
end;

function MakeRect(x, y, width, height: Integer): TGpRect;
begin
  Result.X      := x;
  Result.Y      := y;
  Result.Width  := width;
  Result.Height := height;
end;

function MakeRectF(x, y, width, height: Single): TGpRectF;
begin
  Result.X      := x;
  Result.Y      := y;
  Result.Width  := width;
  Result.Height := height;
end;

function ARGB(A, R, G, B: Byte): COLORREF;
begin
  Result := (DWORD(b) or
            (DWORD(g) shl 8) or
            (DWORD(r) shl 16) or
            (DWORD(a) shl 24));
end;


function GdipLoadImageFromResource(hInstance: THandle; ResName: PChar;
  out image: TGpImage): TGpStatus;
var
  hResInfo, hResGlobal: THandle;
  dwResSize: DWord;
  pResData: Pointer;
  hMem: THandle;
  pData: Pointer;
  hRslt: HResult;
  pStream: IStream;
begin
  Result := GDIPlus_GenericError;
  if @GdipLoadImageFromStream <> nil then
  begin

    hResInfo := FindResource(hInstance, PCHAR(ResName), RT_RCDATA);
    if hResInfo <> 0 then
    begin

      hResGlobal := LoadResource(hInstance, hResInfo);
      if hResGlobal <> 0 then
      begin

        hMem := 0;

        try
          pResData := LockResource(hResGlobal);
          if Assigned(pResData) then
          begin
            dwResSize := SizeofResource(hInstance, hResInfo);
            if dwResSize <> 0 then
            begin
              hMem := GlobalAlloc(GMEM_MOVEABLE or GMEM_NODISCARD, dwResSize);
              if hMem <> 0 then
              begin
                pData := GlobalLock(hMem);
                if Assigned(pData) then
                begin
                  //Move(pResData^, pData^, dwResSize);
                  CopyMemory(pData, pResData, dwResSize);
                  GlobalUnlock(hMem);

                  pStream := nil;
                  hRslt := CreateStreamOnHGlobal(hMem, false, pStream);

                  if not FAILED(hRslt) or (pStream <> nil) then
                    Result := GdipLoadImageFromStream(pStream, image);
                    //Result := GdipCreateBitmapFromStream(pStream, image);
                end;
              end;
            end;
          end;
        finally
          pStream := nil;
          if hMem <> 0 then GlobalFree(hMem);
          if hResGlobal <> 0 then FreeResource(hResGlobal);
        end;

      end;
    end;
  end else
   Result := GDIPlus_GdiplusNotInitialized;
end;

function Gdip_GetStringSize(graphics: TGpGraphics; stringFormat: TGpStringFormat;
  font: TGpFont; txt: PWChar; out Width, Height: integer ): TGpStatus;
var
  layoutRect: TGpRectF;
  boundingBox: TGpRectF;
  codepointsFitted, linesFilled: integer;
begin
  Width := 0;
  Height := 0;

  if assigned(GdipMeasureString) then
  begin
    layoutRect := MakeRectF(0,0,0,0);
    codepointsFitted := 0;
    linesFilled := 0;

    Result := GdipMeasureString(graphics, txt, length(txt), font, @layoutRect,
      stringFormat, @boundingBox, @codepointsFitted, @linesFilled);

    Width := round(boundingBox.Width);
    Height := round(boundingBox.Height);
  end else
    Result := GDIPlus_GdiplusNotInitialized;
end;

// GDIPLUS entladen

function CloseGDIPlus: BOOL;
begin
  if Assigned(GdiplusShutdown) then
    GdiplusShutdown(GdipToken);

  GdiplusShutdown := nil;
  
  {Graphics & DC}
  GdipCreateFromHDC := nil;
  GdipReleaseDC := nil;
  GdipDeleteGraphics := nil;

  GdipSetInterpolationMode := nil;

  {Image}
  GdipLoadImageFromFile := nil;
  GdipLoadImageFromStream := nil;
  //GdipLoadImageFromStreamICM := nil;
  GdipDisposeImage := nil;
  GdipDrawImageRect := nil;
  GdipDrawImageRectRectI := nil;
  GdipDrawImagePointsI := nil;
  GdipGetImageWidth := nil;
  GdipGetImageHeight := nil;

  {$IFNDEF IMAGES_ONLY}
  {Bitmap}
  {$IFDEF USE_BITMAPS}
  GdipCreateBitmapFromFile := nil;
  GdipCreateBitmapFromResource := nil;
  GdipCreateBitmapFromStream := nil;
  //GdipCreateBitmapFromStreamICM := nil;
  {$ENDIF USE_BITMAPS}

  {Pen}
  {$IFDEF USE_PENS}
  GdipCreatePen1 := nil;
  GdipSetPenColor := nil;
  GdipDeletePen := nil;
  {$ENDIF USE_PENS}

  {Brush}
  {$IFDEF USE_BRUSHES}
  GdipCreateSolidFill := nil;
  GdipSetSolidFillColor := nil;
  GdipCreateLineBrushFromRectI := nil;
  GdipSetLineColors  := nil;
  GdipDeleteBrush := nil;
  {$ENDIF USE_BRUSHES}

  {Rectangle, Lines & Co}
  GdipGraphicsClear := nil;
  GdipFillRectangleI := nil;
  GdipDrawEllipseI := nil;
  GdipDrawLineI := nil;

  {Font}
  {$IFDEF USE_FONT_STRINGS}
  GdipCreateFontFromDC := nil;
  GdipCreateFont := nil;
  GdipDeleteFont := nil;

  {DrawString & Co}
  GdipCreateStringFormat := nil;
  GdipDeleteStringFormat := nil;
  GdipSetStringFormatLineAlign := nil;
  GdipDrawString := nil;
  GdipCreateFontFamilyFromName := nil;
  GdipDeleteFontFamily := nil;
  GdipSetTextRenderingHint := nil;
  GdipSetStringFormatTrimming := nil;
  GdipMeasureString := nil;
  {$ENDIF USE_FONT_STRINGS}

  {Path}
  {$IFDEF USE_Paths}
  GdipCreatePath := nil;
  GdipFillPath := nil;
  GdipDrawPath := nil;
  GdipDeletePath := nil;
  GdipAddPathString := nil;
  {$ENDIF USE_Paths}

  {Matrix & Transform}
  {$IFDEF USE_MATRIX_TRANSFORM}
  {Matrix}
  GdipCreateMatrix := nil;
  GdipCreateMatrix3I := nil;
  GdipDeleteMatrix := nil;
  GdipSetMatrixElements := nil;
  GdipMultiplyMatrix := nil;
  GdipTranslateMatrix := nil;
  GdipScaleMatrix := nil;
  GdipRotateMatrix := nil;
  GdipShearMatrix := nil;

  {Additional Transformation Ops}
  GdipSetWorldTransform := nil;
  GdipTranslateWorldTransform := nil;
  GdipResetWorldTransform := nil;
  {$ENDIF USE_MATRIX_TRANSFORM}
  {$ENDIF IMAGES_ONLY}

  Result := FreeLibrary(hGDIP);

  isGDIPlusInit := FALSE;
end;

// GDIPLUS laden

function InitGDIPlus: BOOL;
begin
  hGDIP := LoadLibrary(hLibGdiPlus);
  if hGDIP <> 0 then
  begin
    GdiplusStartup := GetProcAddress(hGDIP, 'GdiplusStartup');
    if Assigned(GdiplusStartup) then
    begin
      ZeroMemory(@StartUpInfo, SizeOf(StartUpInfo));
      StartUpInfo.GdiPlusVersion := 1;
      GDIPlus_Status := GdiplusStartup(GdipToken, StartUpInfo, 0);

      GdiplusShutdown := GetProcAddress(hGDIP, 'GdiplusShutdown');

      {Graphics & DC}
      GdipCreateFromHDC := GetProcAddress(hGDIP, 'GdipCreateFromHDC');
      GdipReleaseDC := GetProcAddress(hGDIP, 'GdipReleaseDC');
      GdipDeleteGraphics := GetProcAddress(hGDIP, 'GdipDeleteGraphics');

      GdipSetInterpolationMode := GetProcAddress(hGDIP, 'GdipSetInterpolationMode');

      {Image}
      GdipLoadImageFromFile := GetProcAddress(hGDIP, 'GdipLoadImageFromFile');
      GdipLoadImageFromStream := GetProcAddress(hGDIP, 'GdipLoadImageFromStream');
      //GdipLoadImageFromStreamICM := GetProcAddress(hGDIP, 'GdipLoadImageFromStreamICM');
      GdipDisposeImage := GetProcAddress(hGDIP, 'GdipDisposeImage');
      GdipDrawImageRect := GetProcAddress(hGDIP, 'GdipDrawImageRect');
      GdipDrawImageRectRectI := GetProcAddress(hGDIP, 'GdipDrawImageRectRectI');
      GdipDrawImagePointsI := GetProcAddress(hGDIP, 'GdipDrawImagePointsI');
      GdipGetImageWidth := GetProcAddress(hGDIP, 'GdipGetImageWidth');
      GdipGetImageHeight := GetProcAddress(hGDIP, 'GdipGetImageHeight');

      {$IFNDEF IMAGES_ONLY}
      {Bitmap}
      {$IFDEF USE_BITMAPS}
      GdipCreateBitmapFromFile := GetProcAddress(hGDIP, 'GdipCreateBitmapFromFile');
      GdipCreateBitmapFromResource := GetProcAddress(hGDIP, 'GdipCreateBitmapFromResource');
      GdipCreateBitmapFromStream := GetProcAddress(hGDIP, 'GdipCreateBitmapFromStream');
      //GdipCreateBitmapFromStreamICM := GetProcAddress(hGDIP, 'GdipCreateBitmapFromStreamICM');
      {$ENDIF USE_BITMAPS}

      {Pen}
      {$IFDEF USE_PENS}
      GdipCreatePen1 := GetProcAddress(hGDIP, 'GdipCreatePen1');
      GdipSetPenColor := GetProcAddress(hGDIP, 'GdipSetPenColor');
      GdipDeletePen := GetProcAddress(hGDIP, 'GdipDeletePen');
      {$ENDIF USE_PENS}

      {Brush}
      {$IFDEF USE_BRUSHES}
      GdipCreateSolidFill := GetProcAddress(hGDIP, 'GdipCreateSolidFill');
      GdipSetSolidFillColor := GetProcAddress(hGDIP, 'GdipSetSolidFillColor');
      GdipCreateLineBrushFromRectI := GetProcAddress(hGDIP, 'GdipCreateLineBrushFromRectI');
      GdipSetLineColors := GetProcAddress(hGDIP, 'GdipSetLineColors');
      GdipDeleteBrush := GetProcAddress(hGDIP, 'GdipDeleteBrush');
      {$ENDIF USE_BRUSHES}

      {Rectangle, Lines & Co}
      GdipGraphicsClear := GetProcAddress(hGDIP, 'GdipGraphicsClear');
      GdipFillRectangleI := GetProcAddress(hGDIP, 'GdipFillRectangleI');
      GdipDrawEllipseI := GetProcAddress(hGDIP, 'GdipDrawEllipseI');
      GdipDrawLineI := GetProcAddress(hGDIP, 'GdipDrawLineI');

      {Font}
      {$IFDEF USE_FONT_STRINGS}
      GdipCreateFontFromDC := GetProcAddress(hGDIP, 'GdipCreateFontFromDC');
      GdipCreateFont := GetProcAddress(hGDIP, 'GdipCreateFont');
      GdipDeleteFont := GetProcAddress(hGDIP, 'GdipDeleteFont');

      {DrawString & Co}
      GdipCreateStringFormat := GetProcAddress(hGDIP, 'GdipCreateStringFormat');
      GdipDeleteStringFormat := GetProcAddress(hGDIP, 'GdipDeleteStringFormat');
      GdipSetStringFormatLineAlign := GetProcAddress(hGDIP, 'GdipSetStringFormatLineAlign');
      GdipDrawString := GetProcAddress(hGDIP, 'GdipDrawString');
      GdipCreateFontFamilyFromName := GetProcAddress(hGDIP, 'GdipCreateFontFamilyFromName');
      GdipDeleteFontFamily := GetProcAddress(hGDIP, 'GdipDeleteFontFamily');
      GdipSetTextRenderingHint := GetProcAddress(hGDIP, 'GdipSetTextRenderingHint');
      GdipSetStringFormatTrimming := GetProcAddress(hGDIP, 'GdipSetStringFormatTrimming');
      GdipMeasureString := GetProcAddress(hGDIP, 'GdipMeasureString');
      {$ENDIF USE_FONT_STRINGS}

      {Path}
      {$IFDEF USE_Paths}
      GdipCreatePath := GetProcAddress(hGDIP, 'GdipCreatePath');
      GdipFillPath := GetProcAddress(hGDIP, 'GdipFillPath');
      GdipDrawPath := GetProcAddress(hGDIP, 'GdipDrawPath');
      GdipDeletePath := GetProcAddress(hGDIP, 'GdipDeletePath');
      GdipAddPathString := GetProcAddress(hGDIP, 'GdipAddPathString');
      {$ENDIF USE_Paths}

      {Matrix & Transform}
      {$IFDEF USE_MATRIX_TRANSFORM}
      {Matrix}
      GdipCreateMatrix3I := GetProcAddress(hGDIP, 'GdipCreateMatrix3I');
      GdipCreateMatrix := GetProcAddress(hGDIP, 'GdipCreateMatrix');
      GdipDeleteMatrix := GetProcAddress(hGDIP, 'GdipDeleteMatrix');
      GdipSetMatrixElements := GetProcAddress(hGDIP, 'GdipSetMatrixElements');
      GdipMultiplyMatrix := GetProcAddress(hGDIP, 'GdipMultiplyMatrix');
      GdipTranslateMatrix :=  GetProcAddress(hGDIP, 'GdipTranslateMatrix');
      GdipScaleMatrix :=  GetProcAddress(hGDIP, 'GdipScaleMatrix');
      GdipRotateMatrix := GetProcAddress(hGDIP, 'GdipRotateMatrix');
      GdipShearMatrix := GetProcAddress(hGDIP, 'GdipShearMatrix');

      {Additional Transformation Ops}
      GdipSetWorldTransform := GetProcAddress(hGDIP, 'GdipSetWorldTransform');
      GdipTranslateWorldTransform := GetProcAddress(hGDIP, 'GdipTranslateWorldTransform');
      GdipResetWorldTransform := GetProcAddress(hGDIP, 'GdipResetWorldTransform');
      {$ENDIF USE_MATRIX_TRANSFORM}
      {$ENDIF IMAGES_ONLY}

    end else
      CloseGDIPlus;
  end;

  Result := (hGDIP <> 0) and
    (@GdiplusShutdown <> nil);

    {Graphics & DC}
    Result := Result and
    (@GdipCreateFromHDC <> nil) and
    (@GdipReleaseDC <> nil) and
    (@GdipDeleteGraphics <> nil) and
    (@GdipSetInterpolationMode <> nil);

    {Image}
    Result := Result and
    (@GdipLoadImageFromFile <> nil) and
    (@GdipLoadImageFromStream <> nil) and
    //(@GdipLoadImageFromStreamICM <> nil) and
    (@GdipDisposeImage <> nil) and
    (@GdipDrawImageRect <> nil) and
    (@GdipDrawImageRectRectI <> nil) and
    (@GdipDrawImagePointsI <> nil) and
    (@GdipGetImageWidth <> nil) and
    (@GdipGetImageHeight <> nil);

    {$IFNDEF IMAGES_ONLY}
    {Bitmap}
    {$IFDEF USE_BITMAPS}
    Result := Result and
    (@GdipCreateBitmapFromFile <> nil) and
    (@GdipCreateBitmapFromResource <> nil) and
    (@GdipCreateBitmapFromStream <> nil);
    //(@GdipCreateBitmapFromStreamICM <> nil) and
    {$ENDIF USE_BITMAPS}

    {Pen}
    {$IFDEF USE_PENS}
    Result := Result and
    (@GdipCreatePen1 <> nil) and
    (@GdipSetPenColor <> nil) and
    (@GdipDeletePen <> nil);
    {$ENDIF USE_PENS}

    {Brush}
    {$IFDEF USE_BRUSHES}
    Result := Result and
    (@GdipCreateSolidFill <> nil) and
    (@GdipSetSolidFillColor <> nil) and
    (@GdipCreateLineBrushFromRectI <> nil) and
    (@GdipSetLineColors <> nil) and
    (@GdipDeleteBrush <> nil);
    {$ENDIF USE_BRUSHES}

    {Rectangle, Lines & Co}
    Result := Result and
    (@GdipGraphicsClear <> nil) and
    (@GdipFillRectangleI <> nil) and
    (@GdipDrawEllipseI <> nil) and
    (@GdipDrawLineI <> nil);

    {Font}
    {$IFDEF USE_FONT_STRINGS}
    Result := Result and
    (@GdipCreateFontFromDC <> nil) and
    (@GdipCreateFont <> nil) and
    (@GdipDeleteFont <> nil);

    {DrawString & Co}
    Result := Result and
    (@GdipCreateStringFormat <> nil) and
    (@GdipDeleteStringFormat <> nil) and
    (@GdipSetStringFormatLineAlign <> nil) and
    (@GdipDrawString <> nil) and
    (@GdipCreateFontFamilyFromName <> nil) and
    (@GdipDeleteFontFamily <> nil) and
    (@GdipSetTextRenderingHint <> nil) and
    (@GdipSetStringFormatTrimming <> nil) and
    (@GdipMeasureString <> nil);
    {$ENDIF USE_FONT_STRINGS}

    {Path}
    {$IFDEF USE_Paths}
    Result := Result and
    (@GdipCreatePath <> nil) and
    (@GdipFillPath <> nil) and
    (@GdipDrawPath <> nil) and
    (@GdipDeletePath <> nil) and
    (@GdipAddPathString <> nil);
    {$ENDIF USE_Paths}

    {Matrix & Transform}
    {$IFDEF USE_MATRIX_TRANSFORM}
    {Matrix}
    Result := Result and
    (@GdipCreateMatrix3I <> nil) and
    (@GdipCreateMatrix <> nil) and
    (@GdipDeleteMatrix <> nil) and
    (@GdipSetMatrixElements <> nil) and
    (@GdipMultiplyMatrix <> nil) and
    (@GdipTranslateMatrix <> nil) and
    (@GdipScaleMatrix <> nil) and
    (@GdipRotateMatrix <> nil) and
    (@GdipShearMatrix <> nil);

    {Additional Transformation Ops}
    Result := Result and
    (@GdipSetWorldTransform <> nil) and
    (@GdipTranslateWorldTransform <> nil) and
    (@GdipResetWorldTransform <> nil);    
    {$ENDIF USE_MATRIX_TRANSFORM}
    {$ENDIF IMAGES_ONLY}

  isGDIPlusInit := Result;
end;

{$IFDEF AUTO_INIT_GDIPlus}
initialization
  InitGDIPlus;

finalization
  CloseGDIPlus;
{$ENDIF AUTO_INIT_GDIPlus}

end.



