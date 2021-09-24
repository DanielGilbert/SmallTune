(******************************************************************************
 *                                                                            *
 *  TAbout class                                                              *
 *  Class for displaying a simple about dialog message box                    *
 *  with file version, description and customized additional                  *
 *  button for navigating to a user defined URL.                              *
 *                                                                            *
 *  Copyright (c) Michael Puff  http://www.michael-puff.de                    *
 *                                                                            *
 ******************************************************************************)


    (************************************************************************
     *                                                                      *
     *                        COPYRIGHT NOTICE                              *
     *                                                                      *
     * Copyright (c) 2001-2006, Michael Puff ["copyright holder(s)"]        *
     * All rights reserved.                                                 *
     *                                                                      *
     * Redistribution and use in source and binary forms, with or without   *
     * modification, are permitted provided that the following conditions   *
     * are met:                                                             *
     *                                                                      *
     * 1. Redistributions of source code must retain the above copyright    *
     *    notice, this list of conditions and the following disclaimer.     *
     * 2. Redistributions in binary form must reproduce the above copyright *
     *    notice, this list of conditions and the following disclaimer in   *
     *    the documentation and/or other materials provided with the        *
     *    distribution.                                                     *
     * 3. The name(s) of the copyright holder(s) may not be used to endorse *
     *    or promote products derived from this software without specific   *
     *    prior written permission.                                         *
     *                                                                      *
     * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  *
     * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT    *
     * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS    *
     * FORA PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE        *
     * REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,          *
     * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, *
     * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;     *
     * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER     *
     * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT   *
     * LIABILITY, OR TORT INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY *
     * WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE          *
     * POSSIBILITY OF SUCH DAMAGE.                                          *
     *                                                                      *
     ************************************************************************)

unit MpuAboutMsgBox;

interface

uses
  Windows, ShellAPI;

type
  TAbout = class(TObject)
  private
    FHandle: THandle;
    FVersionStr: String;
    FDescription: String;
    FCustomized: Boolean;
    FIDIcon: Integer;
    function GetCustomized: Boolean;
    procedure SetCustomized(Value: Boolean);
    function GetIDIcon: Integer;
    procedure SetIDIcon(Value: Integer);
    function GetVersionAndDescription: DWORD;
    function MsgBoxEx(Text: String; Caption: String; Flags: DWORD): LRESULT;
    function MsgBoxIndirect(Text, Caption: string; Flags, IDIcon: DWORD): LRESULT;
  public
    constructor Create(Handle: THandle);
    property Customized: Boolean read GetCustomized write SetCustomized;
    property IDIcon: Integer read GetIDIcon write SetIDIcon;
    procedure Display(const AppTitle, Author, URL: String);
  end;


function MessageBoxIndirect(MsgBoxParams: PMSGBOXPARAMS): Integer; stdcall; external 'user32.dll' name 'MessageBoxIndirectA';

implementation

{ TAbout }

resourcestring
  rsClose = 'Schliessen';
  rsHP = 'Homepage';

var
  hMsgBoxHook: THandle;

function Format(fmt: string; params: array of const): string;
var
  pdw1, pdw2        : PDWORD;
  i                 : integer;
  pc                : PCHAR;
begin
  pdw1 := nil;
  if length(params) > 0 then
    GetMem(pdw1, length(params) * sizeof(Pointer));
  pdw2 := pdw1;
  for i := 0 to high(params) do
  begin
    pdw2^ := DWORD(PDWORD(@params[i])^);
    inc(pdw2);
  end;
  GetMem(pc, 1024 - 1);
  try
    ZeroMemory(pc, 1024 - 1);
    SetString(Result, pc, wvsprintf(pc, PCHAR(fmt), PCHAR(pdw1)));
  except
    Result := '';
  end;
  if (pdw1 <> nil) then
    FreeMem(pdw1);
  if (pc <> nil) then
    FreeMem(pc);
end;

function CBTProc(nCode: Integer; wP: WPARAM; lP: LPARAM): LRESULT; stdcall;
var
  Handle: THandle;
  hBtn: THandle;
begin
  if nCode < 0 then
  begin
    result := CallNextHookEx(hMsgBoxHook, nCode, wP, lP);
    exit;
  end;
  case nCode of
    HCBT_ACTIVATE:
    begin
      Handle := wP;
      hBtn := GetDlgItem(Handle, IDOK);
      SetWindowText(hBtn, PChar(rsHP));
      hBtn := GetDlgItem(Handle, IDCANCEL);
      SetWindowText(hBtn, PChar(rsClose));
      result := 0;
      exit;
    end;
  end;
  result := CallNextHookEx(hMsgBoxHook, nCode, wP, lP);
end;

function TAbout.MsgBoxEx(Text: String; Caption: String; Flags: DWORD): LRESULT;
begin
  hMsgBoxHook := SetWindowsHookEx(WH_CBT, @CBTProc, 0, GetCurrentThreadId);
  if FIDIcon > -1 then
    result := MsgBoxIndirect(Text, Caption, Flags, FIDIcon)
  else
    result := MessageBox(FHandle, PChar(Text), PChar(Caption), Flags or MB_ICONINFORMATION);
  UnhookWindowsHookEx(hMsgBoxHook);
end;

function TAbout.MsgBoxIndirect(Text, Caption: string; Flags, IDIcon: DWORD): LRESULT;
var
  MsgInfo           : TMsgBoxParams;
begin
  ZeroMemory(@MsgInfo, sizeof(TMsgBoxParams));
  MsgInfo.cbSize := SizeOf(TMsgBoxParams);
  MsgInfo.hwndOwner := FHandle;
  MsgInfo.hInstance := GetWindowLong(FHandle, GWL_HINSTANCE);
  MsgInfo.lpszText := @Text[1];
  MsgInfo.lpszCaption := @Caption[1];
  MsgInfo.dwStyle := MB_USERICON or Flags;
  MsgInfo.lpszIcon := MAKEINTRESOURCE(IDICON);
  result := MessageBoxIndirect(@MsgInfo);
end;

function TAbout.GetVersionAndDescription: DWORD;
type
  PDWORDArr = ^DWORDArr;
  DWORDArr = array[0..0] of DWORD;
var
  VerInfoSize       : DWORD;
  VerInfo           : Pointer;
  VerValueSize      : DWORD;
  VerValue          : PVSFixedFileInfo;
  LangInfo          : PDWORDArr;
  LangID            : DWORD;
  Desc              : PChar;
  i                 : Integer;
begin
  result := 0;
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), LangID);
  if VerInfoSize <> 0 then
  begin
    VerInfo := Pointer(GlobalAlloc(GPTR, VerInfoSize));
    if Assigned(VerInfo) then
    try
      if GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo) then
      begin
        if VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize) then
        begin
          with VerValue^ do
          begin
            FVersionStr := Format('%d.%d.%d.%d', [dwFileVersionMS shr 16, dwFileVersionMS and $FFFF,
              dwFileVersionLS shr 16, dwFileVersionLS and $FFFF]);
          end;
        end
        else
          FVersionStr := '';
        // Description
        if VerQueryValue(VerInfo, '\VarFileInfo\Translation', Pointer(LangInfo), VerValueSize) then
        begin
          if (VerValueSize > 0) then
          begin
            // Divide by element size since this is an array
            VerValueSize := VerValueSize div sizeof(DWORD);
            // Number of language identifiers in the table
           (********************************************************************)
            for i := 0 to VerValueSize - 1 do
            begin
              // Swap words of this DWORD
              LangID := (LoWord(LangInfo[i]) shl 16) or HiWord(LangInfo[i]);
              // Query value ...
              if VerQueryValue(VerInfo, @Format('\StringFileInfo\%8.8x\FileDescription', [LangID])[1], Pointer(Desc),
                VerValueSize) then
                FDescription := Desc;
            end;
            (********************************************************************)
          end;
        end
        else
          FDescription := '';
      end;
    finally
      GlobalFree(THandle(VerInfo));
    end
    else // GlobalAlloc
      result := GetLastError;
  end
  else // GetFileVersionInfoSize
    result := GetLastError;
end;

procedure TAbout.Display(const AppTitle, Author, URL: String);
var
  s: String;
begin
  s := Format('%s %s' + #13#10 + '%s' + #13#10#13#10 + 'Copyright: %s' + #13#10+ '%s', [AppTitle, FVersionStr, FDescription, Author, URL]);
  if FCustomized then
  case MsgBoxEx(s, AppTitle, MB_OKCANCEL or MB_DEFBUTTON2) of
    IDOK: ShellExecute(FHandle, 'open', PChar(URL), nil, nil, SW_NORMAL);
  end
  else
  begin
    if FIDIcon > -1 then
      MsgBoxIndirect(s, AppTitle, 0, 1)
    else
      MessageBox(FHandle, PChar(s), PChar(AppTitle), MB_ICONINFORMATION);
  end;
end;

constructor TAbout.Create(Handle: THandle);
begin
  inherited Create;
  FHandle := Handle;
  FCustomized := False;
  FIDIcon := -1;
  GetVersionAndDescription;
end;

function TAbout.GetCustomized: Boolean;
begin
  result := FCustomized;
end;

procedure TAbout.SetCustomized(Value: Boolean);
begin
  FCustomized := Value;
end;

function TAbout.GetIDIcon: Integer;
begin
  result := FIDIcon;
end;

procedure TAbout.SetIDIcon(Value: Integer);
begin
  FIDIcon := Value;
end;

end.
