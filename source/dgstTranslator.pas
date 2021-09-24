unit dgstTranslator;
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
* Version             : 0.3.0
* Date                : 11-2009
* Description         : SmallTune is a simple but powerful audioplayer for
*                       Windows
***************************************************************************}
interface

  uses
    Windows, Messages, dgstTypeDef, dgstSysUtils, dgstHelper, languagecodes;

  const
    WM_LANGUAGEHASCHANGED = WM_User + 1986;

  type
    TTranslationParserState = ( tpsNewLine,
                                tpsComment,
                                tpsIndex,
                                tpsTextBegin,
                                tpsTextEnd,
                                tpsCtrlCommand,
                                tpsTextReading,
                                tpsFailure);

    TLanguage = packed record
      ISO_Code: String[5];
      ClearName: String;
    end;

    TLanguages = Packed record
      fLng: Array of TLanguage;
    end;

    TdgstTranslator = class
      private
        fTranslations: TStringDynArray;
        fAvailableLanguages: TLanguages;
        fState: TTranslationParserState;
        fLanguage: String;
        fMainWnd: HWND;

        function ParseFile(Filename: String): Boolean;

        procedure GetAllAvailableLanguages;
        //Setter
        procedure SetLanguage(const Value: String);
        procedure SetDefaultItems;
        //Getter
        function GetTranslation(index: integer): String;
      public
        Constructor Create;
        Destructor Destroy; override;

        property AvailableLanguages: TLanguages read fAvailableLanguages;
        property CurrentLanguage: String read fLanguage write SetLanguage;
        property Translation[index: integer]: String read GetTranslation; default;
        property MainWnd: HWND read fMainWnd write fMainWnd;
    end;

var
  Translator: TdgstTranslator;

implementation

{ TdgstTranslator }

////////////////////////////////////////////////////////////////////////////////
// Procedure : GetOSLanguageStr
// Comment   : Returns the language ID-String
function GetOSLanguageIDStr: string;
var
  Buffer            : array[0..MAX_PATH] of char;
  len               : Integer;
begin
  ZeroMemory(@Buffer, sizeof(Buffer));
  len := GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SISO639LANGNAME, Buffer,
    sizeof(Buffer));
  SetString(result, Buffer, len - 1);
end;

constructor TdgstTranslator.Create;
begin
  SetDefaultItems;
  GetAllAvailableLanguages;
  SetLanguage(GetOSLanguageIDStr);
end;

destructor TdgstTranslator.Destroy;
begin
  inherited;
end;

procedure TdgstTranslator.GetAllAvailableLanguages;
var
  SR: TWin32FindData;
  hFile: THandle;
  NameWOExt: String;
begin
  (* Init AvailableLanguages *)
  SetLength(fAvailableLanguages.fLng, 0);
  hFile := FindFirstFile(PChar(IncludeTrailingPathDelimiter(ExtractFilePath(paramstr(0))) + 'lng\*.lng'), SR);
  if hFile <> INVALID_HANDLE_VALUE then
  begin
    repeat
      if (String(SR.cFileName) <> '.') AND (String(SR.cFileName) <> '..') then
      begin
        NameWOExt := GetFileNameWithoutExtension(String(SR.cFileName));
        SetLength(fAvailableLanguages.fLng, Length(fAvailableLanguages.fLng) + 1);
        fAvailableLanguages.fLng[Length(AvailableLanguages.fLng) - 1].ISO_Code := NameWOExt;
        fAvailableLanguages.fLng[Length(AvailableLanguages.fLng) - 1].ClearName := GetLanguageName(NameWOExt);
        
      end;
    until not FindNextFile(hFile, SR);
  end;
end;

function TdgstTranslator.GetTranslation(index: integer): String;
begin
  if (index >= 0) and (index <= Length(fTranslations)) then
    Result := fTranslations[index];
end;

function TdgstTranslator.ParseFile(Filename: String): Boolean;
var
  TranslationFile: TextFile;
  i: integer;
  tmp, tmp2: String;
begin
  Result := false;
  (* Initialize *)
  SetLength(fTranslations, 0);
  FileMode := fmOpenRead;
  tmp := '';
  tmp2 := '';
  (* Open File *)
  AssignFile(TranslationFile, FileName);
  try
    (* Reset File *)
    Reset(TranslationFile);
    while not EOF(TranslationFile) do
    begin
      (* Read the next line *)
      ReadLN(TranslationFile, tmp);
      fState := tpsNewLine;
      if Length(tmp) > 0 then
        for I := 1 to Length(tmp) do
          case fState of

            (* New Line Started *)
            tpsNewLine:
              begin
                case tmp[I] of

                  '/':
                  begin
                    (* This line is a comment *)
                    fState := tpsComment;
                    Break;
                  end;

                  else
                  begin
                    (* ReInit tmp2 *)
                    tmp2 := '';
                    tmp2 := tmp[I];
                    fState := tpsIndex;
                  end;
                end;
              end;

            (* Line with comment started, can be ignored *)
            tpsComment:
              begin
                fState := tpsNewLine;
                Break;
              end;

            (* Index found *)
            tpsIndex:
              begin
                case tmp[I] of

                  ':':
                    begin
                      (* Index ended, Text will start *)
                      SetLength(fTranslations, Length(fTranslations) + 1);
                      If not (StrToIntDef(tmp2, 0) = Length(fTranslations) - 1) then
                      begin
                        fState := tpsFailure;
                        Break;
                      end
                      else
                        fState := tpsTextBegin;
                    end;

                  else
                    begin
                      tmp2 := tmp2 + tmp[I];
                    end;
                end;
              end;

            (* New Text Begins *)
            tpsTextBegin:
              begin
                case tmp[I] of
                  '''':
                    begin
                      fState := tpsTextReading;
                      tmp2 := '';
                    end;
                end;
              end;

            (* Beginning was found, reading the current string *)
            tpsTextReading:
              begin
                case tmp[I] of
                  '\': fState := tpsCtrlCommand;
                  '''': fState := tpsTextEnd;
                  else
                    tmp2 := tmp2 + tmp[I];
                end;
              end;

            (* Text has ended *)
            tpsTextEnd:
              begin
                case tmp[i] of
                  ';':
                    begin
                      fTranslations[Length(fTranslations) - 1] := tmp2;
                      fState := tpsNewLine;
                    end;
                end;
              end;

            (* The control character has been found *)
            tpsCtrlCommand:
              begin
                case tmp[i] of
                  'n': tmp2 := tmp2 + #13#10;
                  '''': tmp2 := tmp2 + '''';
                  '\': tmp2 := tmp2 + '\';
                  '0': tmp2 := tmp2+#0; 
                end;
                fState := tpsTextReading;
              end;
      end;
    end;
  finally
    CloseFile(TranslationFile);
  end;
end;

procedure TdgstTranslator.SetDefaultItems;
begin
  SetLength(fTranslations, 0);
  SetLength(fTranslations, 123);
  //Windows XP or NT 4.0 needed!
  fTranslations[0] := 'Windows XP or NT 4.0 needed!';
  //[Playing]
  fTranslations[1] := '[Playing]';
  //[Pause]
  fTranslations[2] := '[Pause]';
  //[Stop]
  fTranslations[3] := '[Stop]';
  //Adding files... please wait...
  fTranslations[4] := 'Adding files... please wait...';
  //Previous track
  fTranslations[5] := 'Previous track';
  //Stop
  fTranslations[6] := 'Stop';
  //Play/Pause
  fTranslations[7] := 'Play/Pause';
  //Next Track
  fTranslations[8] := 'Next Track';
  //Playlist...
  fTranslations[9] := 'Playlist...';
  //Add file(s)...
  fTranslations[10] := 'Add file(s)...';
  //Add folder...
  fTranslations[11] := 'Add folder...';
  //Add URL...
  fTranslations[12] := 'URL Management...';
  //Repeat Playlist
  fTranslations[13] := 'Repeat Playlist';
  //Shuffle
  fTranslations[14] := 'Shuffle';
  //Help...
  fTranslations[15] := 'Help...';
  //Info...
  fTranslations[16] := 'Info...';
  //Close
  fTranslations[17] := 'Close';
  //Choose a folder...
  fTranslations[18] := 'Choose a folder...';
  //#
  fTranslations[19] := '#';
  //Title
  fTranslations[20] := 'Title';
  //Artist
  fTranslations[21] := 'Artist';
  //Filter by
  fTranslations[22] := 'Filter by';
  //SmallTune is already running.
  fTranslations[23] := 'SmallTune is already running.';
  //No Title...
  fTranslations[24] := 'No Title...';
  //No Artist...
  fTranslations[25] := 'No Artist...';
  //No Album...
  fTranslations[26] := 'No Album...';
  //Please enter a valid URL
  fTranslations[27] := 'Please enter a valid URL';
  //All files added!
  fTranslations[28] := 'All files added!';
  //Finished!
  fTranslations[29] := 'Finished!';
  //Read:
  fTranslations[30] := 'Read: ';
  //Initializaing:
  fTranslations[31] := 'Initializaing: ';
  //Please wait...
  fTranslations[32] := 'Please wait...';
  //Would you like to use SmallTune on an USB-Stick, SD-Card or similiar ?\n\n (Otherwise, the database will be saved in the current User''s application folder [recommended for Vista & 7])
  fTranslations[33] := 'Would you like to use SmallTune on an USB-Stick, SD-Card or similiar ?\n\n (Otherwise, the database will be saved in the current User''s application folder [recommended for Vista & 7])';
  //Where to save?
  fTranslations[34] := 'Where to save?';
  //supported files (*.mp3,*.mp2,*.wma,*.flac,*.ogg)|*.mp3;*.mp2;*.wma;*.flac;*.ogg|MP3 (*.mp3)|*.mp3|WMA (*.wma)|*.wma|FLAC (*.flac)|*.flac|OGG (*.ogg)|*.ogg
  fTranslations[35] := 'supported files (*.mp3,*.mp2,*.wma,*.flac,*.ogg)|*.mp3;*.mp2;*.wma;*.flac;*.ogg|MP3 (*.mp3)|*.mp3|WMA (*.wma)|*.wma|FLAC (*.flac)|*.flac|OGG (*.ogg)|*.ogg';
  //Do you want to delete the selected item(s)?
  fTranslations[36] := 'Do you want to delete the selected item(s)?';
  //Confirmation needed
  fTranslations[37] := 'Confirmation needed';
  //Do you want to clear the playlist?
  fTranslations[38] := 'Do you want to clear the playlist?';
  //Confirmation needed
  fTranslations[39] := 'Confirmation needed';
  //When using Windows 7, please keep in mind that you have to set the Notification Icon in the Taskbar to be permanently visible.
  fTranslations[40] := 'When using Windows 7, please keep in mind that you have to set the Notification Icon in the Taskbar to be permanently visible.';
  //Information
  fTranslations[41] := 'Information';
  //Unknown
  fTranslations[42] := 'Unknown';
  //URL could not be resolved
  fTranslations[43] := 'URL could not be resolved';
  //Play/Pause
  fTranslations[44] := 'Play/Pause';
  //Next
  fTranslations[45] := 'Next';
  //Previous
  fTranslations[46] := 'Previous';
  //Playlist
  fTranslations[47] := 'Playlist';
  //Repeat
  fTranslations[48] := 'Repeat';
  //Shuffle
  fTranslations[49] := 'Shuffle';
  //Look for artist at...
  fTranslations[50] := 'Look for artist at...';
  //Autohide
  fTranslations[51] := 'Autohide';
  //Add
  fTranslations[52] := 'Add';
  //Play
  fTranslations[53] := 'Play';
  //Station Title
  fTranslations[54] := 'Station Title';
  //Station URL
  fTranslations[55] := 'Station URL';
  //Cancel
  fTranslations[56] := 'Cancel';
  //Please enter the url here...
  fTranslations[57] := 'Please enter the url here...';
  //Please enter the title here...
  fTranslations[58] := 'Please enter the title here...';
  //Settings
  fTranslations[59] := 'Settings...';
  //Toolbuttons
  fTranslations[60] := 'Add file(s)'#0'Add folder'#0'Clear all'#0'Remove selection'#0#0;
  //ALT Key
  fTranslations[61] := 'ALT';
  //CTRL Key
  fTranslations[62] := 'CTRL';
  //SHIFT Key
  fTranslations[63] := 'SHIFT';
  //Left Arrow Key
  fTranslations[64] := 'Left Arrow';
  //Up Arrow Key
  fTranslations[65] := 'Up Arrow';
  //Right Arrow Key
  fTranslations[66] := 'Right Arrow';
  //Down Arrow Key
  fTranslations[67] := 'Down Arrow';
  //Space Key
  fTranslations[68] := 'Space';
  //Home Key
  fTranslations[69] := 'Home';
  //End Key
  fTranslations[70] := 'End';
  //Page Up Key
  fTranslations[71] := 'Page Up';
  //Page Down
  fTranslations[72] := 'Page Down';
  //F1
  fTranslations[73] := 'F1';
  //F2
  fTranslations[74] := 'F2';
  //F3
  fTranslations[75] := 'F3';
  //F4
  fTranslations[76] := 'F4';
  //F5
  fTranslations[77] := 'F5';
  //F6
  fTranslations[78] := 'F6';
  //F7
  fTranslations[79] := 'F7';
  //F8
  fTranslations[80] := 'F8';
  //F9
  fTranslations[81] := 'F9';
  //F10
  fTranslations[82] := 'F10';
  //F11
  fTranslations[83] := 'F11';
  //F13
  fTranslations[84] := 'F13';
  //F14
  fTranslations[85] := 'F14';
  //F15
  fTranslations[86] := 'F15';
  //F16
  fTranslations[87] := 'F16';
  //F17
  fTranslations[88] := 'F17';
  //F18
  fTranslations[89] := 'F18';
  //F19
  fTranslations[90] := 'F19';
  //F20
  fTranslations[91] := 'F20';
  //F21
  fTranslations[92] := 'F21';
  //F22
  fTranslations[93] := 'F22';
  //F23
  fTranslations[94] := 'F23';
  //F24
  fTranslations[95] := 'F24';
  //Category Name
  fTranslations[96] := 'Category Name';
  //Add Category
  fTranslations[97] := 'Add Category';
  //Add URL
  fTranslations[98] := 'Add URL';
  //Start with Windows
  fTranslations[99] := 'Start with Windows';
  //Make window movable
  fTranslations[100] := 'Make window movable';
  //Save window position
  fTranslations[101] := 'Save window position';
  //Language
  fTranslations[102] := 'Language';
  //General
  fTranslations[103] := 'General';
  //Drag'n'Drop
  fTranslations[104] := 'Drag''n''Drop';
  //Play file after being dropped
  fTranslations[105] := 'Play file after being dropped';
  //Add File To Playlist
  fTranslations[106] := 'Add file to playlist';
  //Activate Multimedia Keys
  fTranslations[107] := 'Activate Multimedia Keys';
  //Activate Hotkeys
  fTranslations[108] := 'Activate Hotkeys';
  //Ctrl
  fTranslations[109] := 'Ctrl';
  //Alt
  fTranslations[110] := 'Alt';
  //Shift
  fTranslations[111] := 'Shift';
  //Use 32bit Floating Data
  fTranslations[112] := 'Use 32bit Floating Data';
  //Play as Mono
  fTranslations[113] := 'Play as Mono';
  //Don't Use Hardware Acceleration
  fTranslations[114] := 'Don''t use Hardware Acceleration';
  //Technical
  fTranslations[115] := 'Technical';
  //Hotkeys
  fTranslations[116] := 'Hotkeys';
  //play only
  fTranslations[117] := 'Play only';
  //add to database
  fTranslations[118] := 'Add to database';
  //stations
  fTranslations[119] := 'Stations';
  //add
  fTranslations[120] := 'Add';
  //add category
  fTranslations[121] := 'Category';
  //delete selected
  fTranslations[122] := 'Delete selected';
end;

procedure TdgstTranslator.SetLanguage(const Value: String);
var
  FileName: String;
begin
  (* Create Filename *)
  Trim(Value);
  FileName := IncludeTrailingPathDelimiter(ExtractFilePath(paramstr(0))) + 'lng\' + Value + '.lng';
  If FileExists(FileName) then
  begin
    ParseFile(FileName);
    fLanguage := Value;
    SendMessage(fMainWnd, WM_LANGUAGEHASCHANGED, 0, 0);
  end
  else
  begin
    SetDefaultItems;
    fLanguage := 'en';
    SendMessage(fMainWnd, WM_LANGUAGEHASCHANGED, 0, 0);
  end;
end;

initialization
  Translator := TdgstTranslator.Create;

finalization
  Translator.Free;

end.
