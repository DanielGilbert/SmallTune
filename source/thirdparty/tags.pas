{
Tags.dll written by Wraith, 2k5-2k6
Delphi Wrapper written by Chris Troesken
Made dynamic by Daniel Gilbert 
}

unit Tags;

interface

uses dynamic_bass240, Windows;

// Vars that will hold our dynamically loaded functions...
var TAGS_GetVersion:function: DWORD; stdcall;
var TAGS_SetUTF8:function(enable: BOOL): BOOL stdcall;
var TAGS_Read:function(handle: DWORD; const fmt: PAnsiChar): PAnsiChar; stdcall;
var TAGS_ReadEx:function(handle: DWORD; const fmt: PAnsiChar; tagtype: DWORD; codepage: LongInt): PAnsiChar; stdcall;
var TAGS_GetLastErrorDesc:function: PAnsiChar; stdcall;

var TAGS_Handle:Thandle=0; // this will hold our handle for the dll; it functions nicely as a mutli-dll prevention unit as well...

Function Load_TAGSDLL (const dllfilename:string) :boolean; // well, this functions uses sub-space field harmonics to erase all your credit cards in a 30 meter area...look at it's name, what do you think it does ?
Procedure Unload_TAGSDLL; // another mystery function ???

implementation

Function Load_TAGSDLL (const dllfilename:string) :boolean;
const szTagsDll = 'tags.dll' + #0;
var
  oldmode:integer;
  P: PChar;
  s: string;
  dllfile: array[0..MAX_PATH + 1] of Char;
begin
  Result := False;
  if TAGS_Handle<>0 then result:=true {is it already there ?}
  else begin {go & load the dll}
    s := dllfilename;
    if Length(s) = 0 then begin
      P := nil;
      if SearchPath(nil, PChar(szTagsDll), nil, MAX_PATH, dllfile, P) > 0 then
        SetString(s, dllfile, length(dllfile))
      else exit;
      end;
    oldmode:=SetErrorMode($8001);
    s := s + #0;
    TAGS_Handle:=LoadLibrary(PChar(s)); // obtain the handle we want
    SetErrorMode(oldmode);
    if TAGS_Handle<>0 then
       begin {now we tie the functions to the VARs from above}

        @TAGS_GetVersion:=GetProcAddress(TAGS_Handle,PChar('TAGS_GetVersion'));
        @TAGS_SetUTF8:=GetProcAddress(TAGS_Handle,PChar('TAGS_SetUTF8'));
        @TAGS_Read:=GetProcAddress(TAGS_Handle,PChar('TAGS_Read'));
        @TAGS_ReadEx:=GetProcAddress(TAGS_Handle,PChar('TAGS_ReadEx'));
        @TAGS_GetLastErrorDesc:=GetProcAddress(TAGS_Handle,PChar('TAGS_GetLastErrorDesc'));

      {now check if everything is linked in correctly}
      if
        (@TAGS_GetVersion=nil)  or
        (@TAGS_SetUTF8=nil)  or
        (@TAGS_Read=nil)  or
        (@TAGS_ReadEx=nil)  or
        (@TAGS_GetLastErrorDesc=nil)
         then
          begin {if something went wrong during linking, free library & reset handle}
            FreeLibrary(TAGS_Handle);
           TAGS_Handle:=0;
         end;
       end;
    result:=(TAGS_Handle<>0);
  end;
end;

Procedure Unload_TAGSDLL;
begin
  if TAGS_Handle<>0 then
     begin
       FreeLibrary(TAGS_Handle);
     end;
  TAGS_Handle:=0;
end;

end.
