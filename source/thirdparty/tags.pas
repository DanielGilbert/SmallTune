{
Tags.dll written by Wraith, 2k5-2k6
Delphi Wrapper written by Chris Troesken 
}

unit Tags;

interface

{$IFDEF MSWINDOWS}
uses dynamic_bass240, Windows;
{$ELSE}
uses dynamic_bass240;
{$ENDIF}

const
{$IFDEF MSWINDOWS}
  tagsdll = 'libs\tags.dll';
{$ENDIF}

function TAGS_GetVersion: DWORD; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}; external tagsdll;
function TAGS_SetUTF8(enable: BOOL): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}; external tagsdll;
function TAGS_Read(handle: DWORD; const fmt: PAnsiChar): PAnsiChar; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}; external tagsdll;
function TAGS_ReadEx(handle: DWORD; const fmt: PAnsiChar; tagtype: DWORD; codepage: LongInt): PAnsiChar; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}; external tagsdll;
function TAGS_GetLastErrorDesc: PAnsiChar; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF}; external tagsdll;

implementation
end.
