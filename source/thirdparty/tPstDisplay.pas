//////////////////////////////////////////////////////////////////////////////
//
//   tP's small Tune Display Unit
//
//   Unit:      tPstDisplay.pas
//   Version:   1.10
//   Date:      11/2009
//
//   by tupboPASCAL (tP) aka MatthiasG.
//

unit tPstDisplay;

{$IFDEF VER140}
  {$MESSAGE HINT '!!! Include SysUtils for D6-INet-Radio Bug !!!'}
  {$DEFINE D6_DEBUG}
{$ENDIF}

interface

uses
  Windows,
  dgstTypeDef,
  dgstSysUtils,
  tPnvMiniGDIPlus,
  Dynamic_Bass240;

type
  TScrollDirection = (sdLeft, sdRight);

  TDisplay = class
  private
    SpecX, SpecY, SpecWidth, SpecHeight, SpecBands: Integer;

    FSpecWidth, FSpecBands: integer;
    FSpecBigWidth, FSpecBigBands: Integer;
    FDisplayWidth, FDisplayHeight: Integer;

    hWindow: HWND;

    xScaleFactor,
    yScaleFactor,

    xShearFactor,
    yShearFactor: Single;

    fMatrix: TGpMatrix;
    yFactor, xFactor: Real;
    hBmpDC         : HDC;
    hBmp           : HBITMAP;
    pBitmapBits    : Pointer;

    gpGraphics: TgpGraphics;

    gpBKBrush, gpFontBrush, gpBrush : TgpBrush;

    gpImage: TgpImage;

    gpStrFormat: TGpStringFormat;
    gpFontFamily: TGpFontFamily;
    gpFont: TGPFont;
    gpTimeFont: TGPFont;

    isCreated: Boolean;
    fShowReflection: Boolean;
    fShowTime: Boolean;

    FSongPosTime, FSongTitel, FSongAlbum, FSongInfo: string;
    FSongTimeColor, FSongTitelColor, FSongInfoColor, FSongIndexColor: COLORREF;
    FMaxStrWidth: integer;

    FShowSongIndex: Boolean;
    FSongsMaxCount,
    FSongsAktIdx: integer;

    FSHowSongInfo: Boolean;
    FShowSongTitel: Boolean;

    fScrollDirection : TScrollDirection;

    fCurTime,
    fLastTime: Integer;

    fXSongTitelOffset : integer;
    fYSongTitelOffset : integer;
    fXSongInfoOffset  : integer;
    fYSongInfoOffset  : integer;
    fXSongIndexOffset : integer;
    fYSongIndexOffset : integer;

    procedure Render(Channel: THandle);
    procedure CalcAndDrawSpectrumVis(Channel: THandle);
    procedure ResetScroller;

    //Setter
    procedure SetSongAlbum(Val: String);
    procedure SetSongTitel(Value: String);
    procedure SetShowTime(const Value: Boolean);
    procedure SetShowSongIndex(const Value: Boolean);

    procedure DrawSongTitel;
    procedure DrawSongInfo;
    procedure DrawSongPosTime;
    procedure DrawSongIndex;
  protected
    __Working: Boolean;
  public
    __Rendering: Boolean;
    constructor Create(WindowHandle: HWND; Width, Height: integer);
    destructor Destroy; override;

    procedure SetSpectrumParameter(X, Y, Width, Height, Bands: integer);
    procedure DrawTo(DC: HDC; X, Y: Integer; Channel: THandle);
    procedure LoadImageFromRes(ResName: string);
    procedure LoadImageFromFileName(FileName: string);
    procedure LoadImageFromResID(ResID: Integer);

    property ShowReflection: Boolean read fShowReflection write fShowReflection;

    property SongTitel: String write SetSongTitel;
    property SongInfo: String read FSongInfo write FSongInfo;
    property SongAlbum: String write SetSongAlbum;

    property SongTimeColor: COLORREF read FSongTimeColor write FSongTimeColor;
    property SongTitelColor: COLORREF read FSongTitelColor write FSongTitelColor;
    property SongInfoColor: COLORREF read FSongInfoColor write FSongInfoColor;
    property SongIndexColor: COLORREF read FSongIndexColor write FSongIndexColor;

    property SongPosTime: String read FSongPosTime write FSongPosTime;
    property SongsAktIdx: integer write FSongsAktIdx;
    property SongsMaxCount: integer write FSongsMaxCount;

    property ShowSongTitel: Boolean read FShowSongTitel write FShowSongTitel;
    property ShowSongInfo: Boolean read FShowSongInfo write FShowSongInfo;
    property ShowSongIndex: Boolean read FShowSongIndex write SetShowSongIndex;
    property ShowTime: Boolean read fShowTime write SetShowTime;

    property XSongTitelOffset : Integer read fXSongTitelOffset write fXSongTitelOffset;
    property YSongTitelOffset : integer read fYSongTitelOffset write fYSongTitelOffset;
    property XSongInfoOffset  : integer read fXSongInfoOffset write fXSongInfoOffset;
    property YSongInfoOffset  : integer read fYSongInfoOffset write fYSongInfoOffset;
    property XSongIndexOffset : integer read fXSongIndexOffset write fXSongIndexOffset;
    property YSongIndexOffset : integer read fYSongIndexOffset write fYSongIndexOffset;
  end;

  function CreateBitmap32(DC: HDC; W, H: Integer; var BitmapBits: Pointer): HBITMAP;

implementation

{$IFDEF D6_DEBUG}
  // nichtauffindbare AccessViolation 216 nur bei INet-Radio ohne SysUtils bei Delphi 6
  uses SysUtils;
{$ENDIF D6_DEBUG}

//--- Tools ------------------------------------------------------------------


function StrToPWChar(const s: AnsiString): PWideChar;
var
  len: integer;
begin
  if s <> '' then
  begin
    len := length(s);
    GetMem(Result, (Len * 2) + 1);
    MultiByteToWideChar(CP_ACP, 0, PAnsiChar(s + #0), -1, Result, Len);
    lStrCatW(Result, #0);
  end else
    Result := #0;
end;

procedure FreePWChar(ws: PWideChar);
begin
  if ws <> nil then FreeMem(ws);
end;

function IntPower(const Base: Extended; const Exponent: Integer): Extended;
asm
        mov     ecx, eax
        cdq
        fld1                      { Result := 1 }
        xor     eax, edx
        sub     eax, edx          { eax := Abs(Exponent) }
        jz      @@3
        fld     Base
        jmp     @@2
  @@1:  fmul    ST, ST            { X := Base * Base }
  @@2:  shr     eax,1
        jnc     @@1
        fmul    ST(1),ST          { Result := Result * X }
        jnz     @@1
        fstp    st                { pop X from FPU stack }
        cmp     ecx, 0
        jge     @@3
        fld1
        fdivrp                    { Result := 1 / Result }
  @@3:
        fwait
end;

function Power(const Base, Exponent: Extended): Extended;
begin
  if Exponent = 0.0 then
    Result := 1.0               { n**0 = 1 }
  else if (Base = 0.0) and (Exponent > 0.0) then
    Result := 0.0               { 0**n = 0, n > 0 }
  else if (Frac(Exponent) = 0.0) and (Abs(Exponent) <= MaxInt) then
    Result := IntPower(Base, Integer(Trunc(Exponent)))
  else
    Result := Exp(Exponent * Ln(Base))
end;

// Log.10(X) := Log.2(X) * Log.10(2)
function Log10(const X : Extended) : Extended;
asm
	FLDLG2     { Log base ten of 2 }
	FLD	X
	FYL2X
	FWAIT
end;

function CreateBitmap32(DC: HDC; W, H: Integer; var BitmapBits: Pointer): HBITMAP;
var
  bi: BITMAPINFO;
begin
  ZeroMemory(@bi, sizeof(BITMAPINFO));
  with bi.bmiHeader do
  begin
    biSize := sizeof(BITMAPINFOHEADER);
    biWidth := W;
    biHeight := -H; // ( wichtig für Textausrichtung )
    biCompression := BI_RGB;
    biBitCount := 32;
    biPlanes := 1;
    biXPelsPerMeter := 0;
    biYPelsPerMeter := 0;
    biClrUsed := 0;
    biClrImportant := 0;
  end;
  Result := CreateDIBSection(DC, bi, DIB_RGB_COLORS, BitmapBits, 0, 0);
end;

//--- TDisplay ---------------------------------------------------------------

constructor TDisplay.Create;
begin
  isCreated := False;

  hWindow := WindowHandle;

  xScaleFactor := 1.30;
  yScaleFactor := 0.75;

  xShearFactor := 0.10;
  yShearFactor := 0.10;

  FDisplayWidth  := Width;
  FDisplayHeight := Height;

  FScrollDirection := sdLeft;

  FSongPosTime := '--:--';
  FSongTitel   := '< not loaded >';
  FSongInfo    := '';
  FSongAlbum    := '';
  FShowTime := true;
  FShowSongInfo := true;
  FShowSongTitel := true;

  FSongTimeColor := $FFFFFFFF;
  FSongTitelColor := FSongTimeColor;
  FSongInfoColor := FSongTimeColor;
  FSongIndexColor := $FF646464;

  FMaxStrWidth := FDisplayWidth - XSongTitelOffset - 3;

  fShowReflection := true;

  yFactor := 0.34;
  xFactor := -23.8;

  hBmpDC := CreateCompatibleDC(0);
  if hBmpDC <> 0 then
  begin
    hBmp := CreateBitmap32(hBmpDC, FDisplayWidth, FDisplayHeight, pBitmapBits);
    if hBmp <> 0 then
    begin
      SelectObject(hBmpDC, hBmp);
      isCreated := True;
    end;
  end;

  if isCreated and isGDIPlusInit then
  begin
    GdipCreateFromHDC(hBmpDC, gpGraphics);

    GdipCreateSolidFill($FF000000, gpBKBrush);
    GdipCreateSolidFill($FFFFFFFF, gpFontBrush);

    GdipCreateStringFormat(SFA_NoWrap, LANG_NEUTRAL, gpStrFormat);
    GdipSetStringFormatTrimming(gpStrFormat, StringTrimmingEllipsisCharacter);
    GdipSetStringFormatLineAlign(gpStrFormat, SA_Far);
    GdipCreateFontFamilyFromName('arial', nil, gpFontFamily);
    GdipCreateFont(gpFontFamily, 11, FS_BOLD, gpUnitPixel, gpFont);
    GdipCreateFont(gpFontFamily, 18, FS_BOLD, gpUnitPixel, gpTimeFont);
  end else
  begin
    __Rendering := False;
    __Working := False;

    MessageBox(WindowHandle, 'TDisplay, GDI Plus not Initialized!', PAnsiChar(AppName), MB_ICONERROR);
    exit;
  end;

  fCurTime := 0;
  fLastTime := GetTickCount;

  __Rendering := True;
end;

destructor TDisplay.Destroy;
begin
  if isGDIPlusInit then
  begin
    if gpFont <> nil then GdipDeleteFont(gpFont);
    if gpTimeFont <> nil then GdipDeleteFont(gpTimeFont);
    if gpFontFamily <> nil then GdipDeleteFontFamily(gpFontFamily);
    if gpStrFormat <> nil then GdipDeleteStringFormat(gpStrFormat);

    if gpFontBrush <> nil then GdipDeleteBrush(gpFontBrush);
    if gpBKBrush <> nil then GdipDeleteBrush(gpBKBrush);
    if gpBrush <> nil then GdipDeleteBrush(gpBrush);
    
    if gpGraphics <> nil then GdipDeleteGraphics(gpGraphics);
    if gpImage <> nil then GdipDisposeImage(gpImage);
  end;

  DeleteObject(hBmpDC);
  DeleteObject(hBmp);

  inherited Destroy;
end;

procedure TDisplay.SetSpectrumParameter(X, Y, Width, Height, Bands: integer);
var
  gpr: TGpRect;
begin
  SpecX      := X;
  SpecY      := Y;
  SpecWidth  := Width;
  SpecHeight := Height;
  SpecBands  := Bands;

  FSpecWidth := Width;
  FSpecBands := Bands;

  FSpecBigWidth := FSpecWidth + 52;
  FSpecBigBands := Bands + 14;

  if gpBrush <> nil then GdipDeleteBrush(gpBrush);
  gpr := MakeRect(SpecX, SpecY, SpecWidth, SpecHeight); // +2 ?!?
  GdipCreateLineBrushFromRectI(@gpr, $FF808080, $FF000000, LinearGradientModeVertical, WrapModeTile, gpBrush);
end;

procedure TDisplay.DrawSongTitel;
var
  tw, th: integer;
  rectF: TGpRectF;
  pw: PWideChar;
begin
  if FSongTitel <> '' then
  begin
    pw := StrToPWChar(FSongTitel);

    Gdip_GetStringSize(gpGraphics, gpStrFormat, gpFont, pw, tw, th);
    GdipSetSolidFillColor(gpFontBrush, FSongTitelColor);
    rectF := MakeRectF(XSongTitelOffset, YSongTitelOffset, tw + 2, 18);
    GdipDrawString(gpGraphics, pw, length(FSongTitel), gpFont, @rectF, gpStrFormat, gpFontBrush);

    FreePWChar(pw);

    if tw > FMaxStrWidth then
    begin
      if fCurTime = 0 then
        fLastTime := GetTickCount + 2000;
      fCurTime := GetTickCount;
      if fCurTime - fLastTime > 25 then
      begin
        case fScrollDirection of

          sdLeft :
            begin
              Dec(fXSongTitelOffset);
              if XSongTitelOffset + tw <= FDisplayWidth then
              begin
                fScrollDirection := sdRight;
                fCurTime := GetTickCount + 1000;
              end;
            end;

          sdRight :
            begin
              Inc(fXSongTitelOffset);
              if XSongTitelOffset >= 75 then
              begin
                fScrollDirection := sdLeft;
                fCurTime := GetTickCount + 1000;
              end;
            end;

        end;
        fLastTime := fCurTime;
      end;
    end;
  end;
end;

procedure TDisplay.DrawSongInfo;
var
  tw, th: integer;
  rectF: TGpRectF;
  pw: PWideChar;
begin
  if FSongInfo <> '' then
  begin
    pw := StrToPWChar(FSongInfo);

    Gdip_GetStringSize(gpGraphics, gpStrFormat, gpFont, pw, tw, th);
    GdipSetSolidFillColor(gpFontBrush, FSongInfoColor);
    rectF := MakeRectF(XSongInfoOffset, YSongInfoOffset, FMaxStrWidth, 18);
    GdipDrawString(gpGraphics, pw, length(FSongInfo), gpFont, @rectF, gpStrFormat, gpFontBrush);

    FreePWChar(pw);
  end;
end;

procedure TDisplay.DrawSongPosTime;
var
  rectF: TGpRectF;
  gpr: TGpRect;
  pw: PWideChar;
  gpMirrorBrush: TgpBrush;
begin
  if (FSongPosTime <> '') then
  begin
    pw := StrToPWChar(FSongPosTime);

    GdipSetSolidFillColor(gpFontBrush, FSongTimeColor);
    rectF := MakeRectF(175, 74, 0, 0);
    GdipDrawString(gpGraphics, pw, length(FSongPosTime), gpTimeFont, @rectF, gpStrFormat, gpFontBrush);
    rectF := MakeRectF(174, -64, 0, 0);

    GdipCreateMatrix(fMatrix);
    GdipSetMatrixElements(fMatrix, 1, 0, 0, -1, 1, 1);
    GdipSetWorldTransform(gpGraphics, fMatrix);

    gpr := MakeRect(174, -64, 85, 26);
    GdipCreateLineBrushFromRectI(@gpr,$FF000000, $80808080, LinearGradientModeVertical, WrapModeTile, gpMirrorBrush);
    GdipDrawString(gpGraphics, pw, length(FSongPosTime), gpTimeFont, @rectF, gpStrFormat, gpMirrorBrush);
    GdipResetWorldTransform(gpGraphics);
    GdipDeleteMatrix(fMatrix);
    if gpMirrorBrush <> nil then GdipDeleteBrush(gpMirrorBrush);

    FreePWChar(pw);
  end;
end;

procedure TDisplay.DrawSongIndex;
var
  rectF: TGpRectF;
  pw: PWideChar;
begin
  // SongsAktIdx & SongsMaxCount
  pw := StrToPWChar(format('%3.3d/%3.3d', [FSongsAktIdx, FSongsMaxCount])+ #0);

  rectF := MakeRectF(XSongIndexOffset, YSongIndexOffset, 58, 12);   
  GdipSetSolidFillColor(gpFontBrush, FSongIndexColor);
  GdipDrawString(gpGraphics, pw, -1, gpFont, @rectF, gpStrFormat, gpFontBrush);

  FreePWChar(pw);
end;

procedure TDisplay.Render(Channel: THandle);
var
  gpr: TGpRect;
  gpMirrorBrush: TgpBrush;
begin
  __Working := True;

  GdipSetLineColors( gpBrush, $FF808080, $FF010101);
  GdipFillRectangleI(gpGraphics, gpBKBrush, 0, 0, FDisplayWidth, FDisplayHeight);

  if FShowSongTitel then DrawSongTitel;
  if FShowSongInfo then DrawSongInfo;
  if FShowSongIndex then DrawSongIndex;
  if FShowTime then DrawSongPosTime;

  GdipFillRectangleI(gpGraphics, gpBKBrush, 0, 0, 75, 42);

  if gpImage <> nil then
  begin
    GdipDrawImageRect(gpGraphics, gpImage, 5, 5, 64, 64);
    if fShowReflection then
    begin
      GdipCreateMatrix(fMatrix);
      GdipSetMatrixElements(fMatrix, 1, 0, 0, -1, 1, 1);
      GdipSetWorldTransform(gpGraphics, fMatrix);
      GdipDrawImageRect(gpGraphics, gpImage, 5, -128, 64, 63);
      GdipResetWorldTransform(gpGraphics);
      GdipDeleteMatrix(fMatrix);

      gpr := MakeRect(0, 0, 64, 30);
      GdipCreateLineBrushFromRectI(@gpr, $0A000000, $FF000000, LinearGradientModeVertical, WrapModeTile, gpMirrorBrush);
      GdipFillRectangleI(gpGraphics, gpMirrorBrush, 5, 70, 64, 29);
      if gpMirrorBrush <> nil then GdipDeleteBrush(gpMirrorBrush);

      gpr := MakeRect(0, 0, 64, 38);
      GdipCreateLineBrushFromRectI(@gpr, $FF000000, $FF000000, LinearGradientModeVertical, WrapModeTile, gpMirrorBrush);
      GdipFillRectangleI(gpGraphics, gpMirrorBrush, 5, 85, 64, 38);
      if gpMirrorBrush <> nil then GdipDeleteBrush(gpMirrorBrush);
    end;
  end;   

  CalcAndDrawSpectrumVis(Channel);

  __Working := False;
end;

procedure TDisplay.DrawTo(DC: HDC; X, Y: Integer; Channel: THandle);
begin
  if not __Rendering then exit;
  if not __Working then Render(Channel);

  bitblt(DC, X, Y, FDisplayWidth, FDisplayHeight, hBmpDC, 0, 0, SRCCOPY);
end;

procedure TDisplay.CalcAndDrawSpectrumVis;
var
  X, Y,
  I, J, sc	: Integer;
  Sum		: Single;
  fft		: array[0..1023] of Single; // get the FFT data
  r,mr: trect;
  bw: integer;

  procedure EmptyVis;
  var n: integer;
  begin
    y := 1;
    for n := 0 to SpecBands - 1 do
    begin
      bw := SPECWIDTH div SpecBands;

      GdipSetLineColors( gpBrush, $A0999999, $02999999);
      setrect(mr, SpecX + n * bw, SpecY + SPECHEIGHT + 1, SpecX + n * bw + bw-1, SpecY + SPECHEIGHT + y + 1);
      GdipFillRectangleI(gpGraphics, gpBrush, mr.Left, mr.Top, mr.Right-mr.Left, mr.Bottom-mr.Top);

      GdipSetLineColors( gpBrush, $FF000000, $FFFFFFFF);
      setrect(r, SpecX + n * bw, SpecY + SPECHEIGHT - y, SpecX + n * bw + bw-1, SpecY + SPECHEIGHT);
      GdipFillRectangleI(gpGraphics, gpBrush, r.Left, r.Top, r.Right-r.Left, r.Bottom-r.Top);
    end;
  end;

begin
  if Channel <> 0 then
  begin
    case BASS_ChannelIsActive(Channel) of
      BASS_ACTIVE_PLAYING:
        begin
          BASS_ChannelGetData(Channel, @fft, BASS_DATA_FFT2048);
          I := 0;

          for X := 0 to SpecBands - 1 do
          begin
            Sum := 0;
            J  := trunc(Power(2, X * 10.0 / (SpecBands - 1)));
            if J > 1023 then
              J := 1023;
            if J <= I then
              J := I + 1; // make sure it uses at least 1 FFT bin
            sc := 10 + J - I;

            while I < J do
            begin
              Sum := Sum + fft[0 + I];
              inc(I);
            end;

            Y := trunc((sqrt(Sum / log10(sc)) * 1.7 * SPECHEIGHT)); // scale it

            if Y > SPECHEIGHT - 2  then Y := SPECHEIGHT - 2; // cap it

            bw := SPECWIDTH div SpecBands;

            (*Draw Mirror*)
            GdipSetLineColors( gpBrush, $80808080, $FF000000);
            setrect(mr, SpecX + X * bw, SpecY + SPECHEIGHT+1, SpecX + X * bw + bw-1, SpecY + SPECHEIGHT + y + 2);
            GdipFillRectangleI(gpGraphics, gpBrush, mr.Left, mr.Top, mr.Right-mr.Left, mr.Bottom-mr.Top);

            GdipSetLineColors( gpBrush, $FF000000, $FFFFFFFF);
            setrect(r, SpecX + X * bw, SpecY + SPECHEIGHT - y - 1, SpecX + X * bw + bw-1, SpecY + SPECHEIGHT);
            GdipFillRectangleI(gpGraphics, gpBrush, r.Left, r.Top, r.Right-r.Left, r.Bottom-r.Top);
          end;
        end;
      BASS_ACTIVE_STOPPED:
        EmptyVis;
    end;
  end else
    EmptyVis;
end;

procedure TDisplay.LoadImageFromRes(ResName: string);
begin
  if gpImage <> nil then
    GdipDisposeImage(gpImage);

  GdipLoadImageFromResource(hInstance, PCHAR(ResName), gpImage);
end;

procedure TDisplay.LoadImageFromFileName(FileName: string);
var
  pw: PWideChar;
begin
  if gpImage <> nil then
    GdipDisposeImage(gpImage);

  pw := StrToPWChar(FileName);

  if GdipLoadImageFromFile(pw, gpImage) <> GDIPlus_OK then
    MessageBox(hWindow, 'Fehler beim laden des Images', '!', MB_ICONERROR);

  FreePWChar(pw);
end;

procedure TDisplay.LoadImageFromResID(ResID: Integer);
begin
  if gpImage <> nil then
    GdipDisposeImage(gpImage);

  GdipLoadImageFromResource(hInstance, MAKEINTRESOURCE(ResID), gpImage);
end;

procedure TDisplay.SetSongTitel(Value: String);
begin
  FSongTitel := Value + #32;
end;

procedure TDisplay.ResetScroller;
begin
  XSongTitelOffset := 75;
  fCurTime := 0;
  fScrollDirection := sdLeft;
end;

procedure TDisplay.SetShowTime(const Value: Boolean);
begin
  fShowTime := Value;
  if fShowTime then
    begin
      SpecWidth := FSpecWidth;
      SpecBands := FSpecBands;
    end
  else
    begin
      SpecWidth := FSpecBigWidth;
      SpecBands := FSpecBigBands;
    end;
end;

procedure TDisplay.SetShowSongIndex(const Value: Boolean);
begin
  if Value <> FShowSongIndex then
    FShowSongIndex := Value;
end;

procedure TDisplay.SetSongAlbum(Val: string);
begin
  fSongAlbum := Val;
  if Val <> '' then
    fSongTitel := fSongTitel + ' / ' + fSongAlbum;
  ResetScroller;
end;

end.
