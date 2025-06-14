unit dgstMediaClass;
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
* Version             : 0.3.1
* Date                : 11-2009
* Description         : SmallTune is a simple but powerful audioplayer for
*                       Windows
***************************************************************************}
interface

uses
  Windows,
  dgstTranslator,
  dgstLog,
  dgstSysUtils,
  dgstDatabase,
  dgstHelper,
  dgstTypeDef,
  dgstFindFiles,
  dgstExceptionHandling,
  dynamic_bass240,
  dgstInternetCP,
  SpecialFolders,
  dgstSettings,
  Tags;

type
  TOnStartPlayingTrack = procedure(Artist, Title, Album: String; Duration: Integer);
  TOnAddFilesDone = procedure();
  TOnAddFiles = procedure(CurFile: Integer; Init: Boolean);
  TOnNewMeta = procedure(Title: String);

  TPlayerType = (ptNone, ptFileStream, ptINetStream, ptChiptune);

  TMediaClass = class
  private
    FF: TdgstFindFiles;

    fCurrentStream: HSTREAM;
    fChipTune: HMUSIC;

    fStatusWindow,
    fAppHandle: HWnd;

    (* Special List View Cache Handling *)
    fLVItemsCache: TLVItemCacheArray;
    fg_ItmEnd,
    fg_ItmStart: Integer;
    //Special Array is needed
    fMediaFileLst: TLVItemCacheArray;

    //fItemsInDB: Integer;
    fFilter : String;
    fSongLength: DWORD;

    fAutoNext: Boolean;
    fShuffle: Boolean;
    fListRepeat: Boolean;

    fDBFileName: String;

    fSongsAlreadyPlayed: Array of Boolean;

    fCurrentPlayListPos : Integer;

    fCurrentMediaItem: TMediaFile;

    fDoReadID3Tags: Boolean;
    fIsPlaying : Boolean;

    fDB: TDataBase;

    fCurrentVol: float;

    fOnStartPlayingTrack: TOnStartPlayingTrack;
    fOnAddFiles: TOnAddFiles;
    fOnAddFilesDone: TOnAddFilesDone;
    fOnNewMeta: TOnNewMeta;

    fInternetStations: TInternetStations;

    FOldPlayerType, FPlayerType: TPlayerType;
    FWindowHandle: HWND;

    procedure Cleanup();
    procedure DoMeta;
    //Getter
    function GetDBItemsCount: Integer;

    //Setter
    procedure SetCurrentPlayListPos(Idx: Integer);
    procedure SetShuffling(Value: Boolean);
    procedure SetFilter(Value: String);

    function IsFirstStart: Boolean;
  public
    property OnStartPlayingTrack: TOnStartPlayingTrack read fOnStartPlayingTrack write fOnStartPlayingTrack;
    property OnAddFiles: TOnAddFiles read fOnAddFiles write fOnAddFiles;
    property OnAddFilesDone: TOnAddFilesDone read FOnAddFilesDone write fOnAddFilesDone;
    property OnNewStreamMeta: TOnNewMeta read fOnNewMeta write fOnNewMeta;
    property CurrentPlayListPos: Integer read fCurrentPlayListPos write SetCurrentPlayListPos;
    property CurrentMediaItem : TMediaFile read fCurrentMediaItem;
    property ItemsInDB: Integer read GetDBItemsCount;
    property IsPlaying: Boolean read fIsPlaying;

    property PlayerType: TPlayerType read FPlayerType;

    property CurrentStream: HSTREAM read fCurrentStream;

    property AppHandle: HWnd read fAppHandle write fAppHandle;
    property StatusWindow: HWnd read fStatusWindow write fStatusWindow;
  
    property Filter : String read fFilter write SetFilter;

    property AutoNext: Boolean read fAutoNext write fAutoNext;
    property Shuffle: Boolean read fShuffle write SetShuffling;
    property ListRepeat: Boolean read fListRepeat write fListRepeat;

    property DoReadID3Tags: Boolean read fDoReadID3Tags write fDoReadID3Tags;

    property InternetStations: TInternetStations read fInternetStations;

    (* Special ListView Handling *)
    function GetItemFromCache(Idx: Integer): TLVITemCache;
    procedure LoadCache(FromRow, ToRow: Integer);

    (* FFT *)
    function GetFFTData: TFFTArray;
    
    (* Con- & Destructor *)
    constructor Create(WindowHandle: HWND);
    destructor Destroy; override;

    (* Files *)
    procedure AddFileToDatabase(FileName: String);
    procedure AddFolderToDatabase(FolderPath: String);
    procedure FindFilesDone(Files: TFileArray);
    procedure FindFilesProgress(FilesCnt: Integer);
    function Load(filename: string; idx: integer = -1): BOOL;

    (* Play Control *)
    procedure PlayNextTrack;
    procedure PlayPreviousTrack;
    procedure Play;
    procedure Pause;
    procedure Stop;
    procedure Resume;

    procedure SetNewVolume(Vol: float);
    procedure SetNewPosition(Pos: Integer);

    function GetVolume: float;

    function GetStreamDuration: Int64;
    function GetStreamPos(TimeMode: Byte): Integer;
    function GetStreamPosForTB: Int64;

    (* Internet Stream *)
    procedure RunInternetStream(StreamURL: String);
    procedure AddURL(URL, Title, Genre: String);
    procedure AddGenre(Genre: String);
    procedure RebuildINetStations;

    (* Playlist *)
    procedure RebuildPlayList;
    procedure DeleteItemByLVID(ID: Integer);
    procedure DeletePlayList;
  end;

implementation

  function TMediaClass.IsFirstStart: Boolean;
  begin
    //First, try the ExePath
    if not FileExists(IncludeTrailingPathDelimiter(ExtractFilePath(paramstr(0))) + 'main.db') then
      //Second, try Local Appdata
      if not FileExists(IncludeTrailingPathDelimiter(GetSpecialFolder(0,  CSIDL_APPDATA)) + 'SmallTune\' + 'main.db') then
        Result := true
      else
      begin
        fDBFileName := IncludeTrailingPathDelimiter(GetSpecialFolder(0,  CSIDL_APPDATA)) + 'SmallTune\' + 'main.db';
        Result := false;
        lg.WriteLog('DB-FilePath: ' + fDBFileName, 'dgstMediaClass', ltInformation, lmExtended);
      end
    else
    begin
      fDBFileName := IncludeTrailingPathDelimiter(ExtractFilePath(paramstr(0))) + 'main.db';
      Result := false;
      lg.WriteLog('DB-FilePath: ' + fDBFileName, 'dgstMediaClass', ltInformation, lmExtended);
    end;
  end;

constructor TMediaClass.Create;
begin
  Load_BASSDLL(ExtractFilePath(paramstr(0)) + 'libs\bass.dll');
  Load_TAGSDLL(ExtractFilePath(paramstr(0)) + 'libs\tags.dll');

  lg.WriteLog('BASS: ' + GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltInformation, lmExtended);
  if (HIWORD(BASS_GetVersion) <> BASSVERSION) then
	begin
    lg.WriteLog('BASS: An incorrect version of BASS.DLL was loaded', 'dgstMediaClass', ltError);
		MessageBox(0, 'An incorrect version of BASS.DLL was loaded', nil, MB_ICONERROR);
		Halt;
	end;

  fCurrentVol := 1.0;
  fFilter := '';

  (* Initialize Database and Audio *)

  if IsFirstStart then
  begin
      case MessageBox(0,
                      PChar(Translator[LNG_WHERETOSAVEDB]),
                      PChar(Translator[LNG_WHERETOSAVEDBCAPTION]),
                      MB_YESNO or MB_ICONINFORMATION
                      ) of
          IDYES:
            begin
              fDBFileName := IncludeTrailingPathDelimiter(ExtractFilePath(paramstr(0))) + 'main.db';
            end;

          IDNO:
            begin
              fDBFileName := IncludeTrailingPathDelimiter(GetSpecialFolder(0,  CSIDL_APPDATA)) + 'SmallTune\main.db';
            end;
      end;
      lg.WriteLog('DB-FilePath on First Start: ' + fDBFileName, 'dgstMediaClass', ltInformation, lmExtended);
      ForceDirectories(ExtractFilePath(fDBFileName));

      //Show special Windows 7 Message
      MessageBox(0,
                      PChar(Translator[LNG_USINGWIN7]),
                      PChar(Translator[LNG_USINGWIN7CAPTION]),
                      MB_OK or MB_ICONINFORMATION
                      );

      fDB := TDataBase.Create(fDBFileName);

      //Add First Streams
      fDB.StartTransaction();
      fDB.AddGenreToDB('Rock');
      fDB.AddGenreToDB('Pop');
      fDB.AddGenreToDB('Techno/Dance');
      fDB.StartTransaction(false);
      fDB.AddUrlToGenre('http://www.181.fm/winamp.pls?station=181-buzz&style=mp3&description=The%20Buzz%20(Alt.%20Rock)','Rock','181.FM - The Buzz (Alt. Rock)');
      fDB.AddUrlToGenre('http://www.181.fm/winamp.pls?station=181-eagle&style=&description=The%20Eagle%20(Classic)','Rock','181.FM - The Eagle (Classic)');
      fDB.AddUrlToGenre('http://www.181.fm/winamp.pls?station=181-punk&style=mp3&description=Punk%20|%20Hardcore','Rock','181.FM - Punk | Hardcore');
      fDB.AddUrlToGenre('http://www.181.fm/winamp.pls?station=181-office&style=&description=The%20Office','Pop','181.FM - The Office');
      fDB.AddUrlToGenre('http://www.181.fm/winamp.pls?station=181-themix&style=&description=The%20Mix','Pop','181.FM - The Mix');
      fDB.AddUrlToGenre('http://www.181.fm/winamp.pls?station=181-energy98&style=mp3&description=Energy%2098','Techno/Dance','181.FM - Energy 98');
      fDB.AddUrlToGenre('http://www.181.fm/winamp.pls?station=181-energy93&style=&description=Energy%2093%20(Euro%20Dance)','Techno/Dance','181.FM - Energy 93 (EuroDance)');
  end
  else
    fDB := TDataBase.Create(fDBFileName);

  // Initialize Settings
  Settings.DB := fDB;
  Settings.LoadSettings;

  (* Set Global Vars *)
  fDoReadID3Tags := true;
  fCurrentPlayListPos := -1;

  (* Set Cache Control *)
  fMediaFileLst := fDB.GetFilesFromDB;
  lg.WriteLog('Length of FileList: ' + IntToStr(Length(fMediaFileLst)), 'dgstMediaClass', ltInformation, lmExtended);
  SetLength(fLVItemsCache, 0);
  fg_ItmEnd := 0;
  fg_ItmStart := 0;

  (* Initialize Mediafile Struct *)
  fCurrentMediaItem.FileName := '';
  fCurrentMediaItem.FilePath := '';
  fCurrentMediaItem.Title := '';
  fCurrentMediaItem.Artist := '';
  fCurrentMediaItem.Album := '';
  fCurrentMediaItem.Genre := '';
  fCurrentMediaItem.RowID := -1;

  (* Initialize Shuffle Array *)
  if fShuffle then
    SetLength(fSongsAlreadyPlayed, Length(fMediaFileLst));

  lg.WriteLog('Length of Shuffle-Array: ' + IntToStr(Length(fSongsAlreadyPlayed)), 'dgstMediaClass', ltInformation, lmExtended);

  (* Init Bass *)
  BASS_Init(-1, 44100, 0, fAppHandle, nil);
  lg.WriteLog('BASS: ' + GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltInformation, lmExtended);

  (* Set User Agent *)
  BASS_SetConfigPtr(BASS_CONFIG_NET_AGENT, PChar(USER_AGENT));

  if Settings.GetSetting('use_32_bit') <> '0' then
    Settings.WriteSetting('use_32_bit', IntToStr(BASS_SAMPLE_FLOAT));

  if Settings.GetSetting('play_mono') <> '0' then
    Settings.WriteSetting('play_mono', IntToStr(BASS_SAMPLE_MONO));

  if Settings.GetSetting('no_hardware') <> '0' then
    Settings.WriteSetting('no_hardware', IntToStr(BASS_SAMPLE_SOFTWARE));

  (* Load Plugins, do nothing on failure *)
  if BASS_PluginLoad(PChar(ExtractFilePath(paramstr(0)) + 'libs\bassflac.dll'), 0) = 0 then
    lg.WriteLog('BASS: ' + GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltError, lmNormal);

  if BASS_PluginLoad(PChar(ExtractFilePath(paramstr(0)) + 'libs\basswma.dll'), 0) = 0 then
    lg.WriteLog('BASS: ' + GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltError, lmNormal);

  fSongLength := 0;
  fIsPlaying := false;

  if not BASS_SetConfig(BASS_CONFIG_NET_PLAYLIST, 1) then
    lg.WriteLog(GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltError, lmNormal);

  (* Initialize InternetStreams *)
  fInternetStations := TInternetStations.Create(fDB);

  FPlayerType := ptFileStream;
  FOldPlayerType := ptNone;
  FWindowHandle := WindowHandle;
end;

destructor TMediaClass.Destroy;
begin
  Cleanup;
  fDB.Free;
  fInternetStations.Free;
end;

function TMediaClass.GetFFTData: TFFTArray;
var
  fft		: TFFTArray; // get the FFT data
  i: Integer;
const
  BANDS		= 28;
  SPECHEIGHT = 25;
  SPECWIDTH = 100;
begin
  if BASS_ChannelIsActive(fCurrentStream) <> BASS_ACTIVE_STOPPED then
  begin
    BASS_ChannelGetData(fCurrentStream, @fft, BASS_DATA_FFT256);
    Result := fft;
  end
  else
    for I := 0 to Length(fft) - 1 do
      fft[i] := 0.1;
end;

function TMediaClass.GetStreamPos(TimeMode: Byte): Integer;
begin
  if (fCurrentStream <> 0) and (FPlayerType = ptFileStream) then
  begin
    Result := round(BASS_ChannelBytes2Seconds(fCurrentStream, BASS_ChannelGetPosition(fCurrentStream, BASS_POS_BYTE)));
    case TimeMode of
      1: Result := -(fSongLength - round(BASS_ChannelBytes2Seconds(fCurrentStream, BASS_ChannelGetPosition(fCurrentStream, BASS_POS_BYTE))));
      2: Result := fSongLength;
    end;
  end else
    Result := 0;
end;

procedure TMediaClass.DoMeta;
var
  p: Integer;
  meta: PChar;
begin
  meta := BASS_ChannelGetTags(fCurrentStream, BASS_TAG_META);
  if (meta <> nil) then
  begin
    p := Pos('StreamTitle=', meta);
    if (p = 0) then
      Exit;
    p := p + 13;
    fCurrentMediaItem.Title := String(Pchar(Copy(meta, p, Pos(';', meta) - p - 1)));
    lg.WriteLog('BASS: New Stream Title: ' + fCurrentMediaItem.Title, 'dgstMediaClass', ltInformation, lmExtended);
    if Assigned(fOnNewMeta) then
      fOnNewMeta(fCurrentMediaItem.Title);
  end
    else
      lg.WriteLog('BASS: No Meta received', 'dgstMediaClass', ltInformation, lmExtended);
end;

procedure TrackEnd(handle: HSYNC; channel, data, user: DWORD); stdcall;
begin
  TMediaClass(user).PlayNextTrack;
  lg.WriteLog('BASS: End of Track', 'dgstMediaClass', ltInformation, lmExtended);
end;

procedure InternetStreamMeta(handle: HSYNC; channel, data, user: DWORD); stdcall;
begin
  lg.WriteLog('BASS: Handling new Meta Data', 'dgstMediaClass', ltInformation, lmNormal);
  TMediaClass(user).DoMeta;
end;

procedure TMediaClass.RunInternetStream(StreamURL: String);
var
  icy: Pchar;
begin
  if StreamURL <> '' then
  begin
    if fCurrentStream <> 0 then
      BASS_StreamFree(fCurrentStream);
    lg.WriteLog('BASS: ' + GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltInformation, lmExtended);

    FPlayerType := ptINetStream;
    if FOldPlayerType <> FPlayerType then
    begin
      FOldPlayerType := FPlayerType;
      SendMessage(FWindowHandle, WM_CHANGE_PLAYERTYPE, 0, 0);
    end;

    fCurrentStream := BASS_StreamCreateURL( PChar(StreamURL),
                                            0,
                                            BASS_STREAM_BLOCK or
                                            BASS_STREAM_AUTOFREE or
                                            StrToIntDef(Settings.GetSetting('speakers_count'), 0) or
                                            StrToIntDef(Settings.GetSetting('use_32_bit'), 0) or
                                            StrToIntDef(Settings.GetSetting('play_mono'), 0) or
                                            StrToIntDef(Settings.GetSetting('no_hardware'), 0),
                                            nil,
                                            nil);

    lg.WriteLog('BASS: ' + GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltInformation, lmExtended);
    fCurrentMediaItem.Artist := '';
    fCurrentMediaItem.FileName := StreamURL;
    fCurrentMediaItem.Title := StreamURL;
    fCurrentMediaItem.Album := '';
    fCurrentMediaItem.Genre := '';
    fCurrentMediaItem.RowID := -1;
    fCurrentMediaItem.FilePath := StreamURL;

    // get the broadcast name and bitrate
    icy := BASS_ChannelGetTags(fCurrentStream, BASS_TAG_ICY);
    lg.WriteLog('BASS: ' + GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltInformation, lmExtended);
    if (icy = nil) then
      icy := BASS_ChannelGetTags(fCurrentStream, BASS_TAG_HTTP); // no ICY tags, try HTTP
    if (icy <> nil) then
      while (icy^ <> #0) do
      begin
        if (Copy(icy, 1, 9) = 'icy-name:') then
          fCurrentMediaItem.Artist := String(PChar(Copy(icy, 10, MaxInt)))
        else if (Copy(icy, 1, 7) = 'icy-br:') then
          fCurrentMediaItem.Artist := fCurrentMediaItem.Artist + ' [' + String(PChar('bitrate: ' + Copy(icy, 8, MaxInt))) + ']';
        icy := icy + Length(icy) + 1;
      end;
    lg.WriteLog('BASS: ' + GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltInformation, lmExtended);

    BASS_ChannelSetSync(fCurrentStream, BASS_SYNC_META, 0, @InternetStreamMeta, Pointer(Self));
    lg.WriteLog('BASS: ' + GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltInformation, lmExtended);

    DoMeta;
    Play;
  end;

end;

function TMediaClass.GetDBItemsCount;
begin
  Result := Length(fMediaFileLst);
end;

procedure TMediaClass.SetFilter(Value: String);
begin
  fMediaFileLst := fDB.GetFilesFromDB(Value);
  fFilter := Value;
end;

procedure TMediaClass.SetCurrentPlayListPos(Idx: Integer);
var
  Tmp: TLVItemCache;
begin
  if Idx <> -1 then
  begin
    fCurrentPlayListPos := Idx;
    Tmp := fMediaFileLst[fCurrentPlayListPos];
    fCurrentMediaItem := Tmp.MediaFileItm;
  end;
end;

procedure TMediaClass.SetShuffling(Value: Boolean);
var
  i: integer;
begin
  if Value then
  begin
    SetLength(fSongsAlreadyPlayed, ItemsInDB);
    for i := 0 to Length(fSongsAlreadyPlayed) - 1 do
      fSongsAlreadyPlayed[i] := false;
  end
  else
    SetLength(fSongsAlreadyPlayed, 0);
  fShuffle := Value;
end;

procedure TMediaClass.FindFilesDone(Files: TFileArray);
var
  I: Integer;
begin
  //Initialize new transaction
  fDb.StartTransaction();
  for I := 0 to Length(Files) - 1 do
    begin
      if Assigned(fOnAddFiles) then
      begin
        fOnAddFiles(I, false);
      end;
      AddFileToDatabase(Files[I]);
    end;
  //End new transaction
  fDb.StartTransaction(False);
  //Get files from db
  fMediaFileLst := fDB.GetFilesFromDB;
  fOnAddFilesDone;
  FF.Free;
  fFilter := '';
end;

procedure TMediaClass.FindFilesProgress(FilesCnt: Integer);
begin
  fOnAddFiles(FilesCnt, True);
end;

procedure TMediaClass.AddFolderToDatabase(FolderPath: String);
var
  Msk: TMaskArray;
begin
  SetLength(Msk, 4);
  Msk[0] := '*.mp3';
  Msk[1] := '*.ogg';
  Msk[2] := '*.wma';
  Msk[3] := '*.flac';
  FF := TdgstFindFiles.Create(FolderPath, msk, true);
  FF.OnFilesDone := FindFilesDone;
  FF.OnProgress := FindfilesProgress;
  FF.StartSearch;
end;

var
  Channel: HStream;

function TMediaClass.Load(filename: string; idx: integer = -1): BOOL;
var
  Specs: TFileSpecs;
begin
  Result := False;
  if FileExists(filename) then
  begin
    if idx = -1 then
    begin
          Specs.fFilePath := FileName;
      Specs.fFileExtType := GetFileExtension(FileName);
      Channel := Bass_StreamCreateFile(false, PChar(Specs.fFilePath), 0, 0, Bass_Stream_Decode);
      Specs.fTitle := Utf8ToAnsi(TAGS_Read(Channel, '%TITL'));
      Specs.fArtist := Utf8ToAnsi(TAGS_Read(Channel, '%ARTI'));
      Specs.fAlbum := Utf8ToAnsi(TAGS_Read(Channel, '%ALBM'));
      Specs.fYear := Utf8ToAnsi(TAGS_Read(Channel, '%YEAR'));
      Specs.fGenre := Utf8ToAnsi(TAGS_Read(Channel, '%GNRE'));

    fCurrentMediaItem.Title := Specs.fTitle;
    fCurrentMediaItem.Artist := Specs.fArtist;
    fCurrentMediaItem.Album := Specs.fAlbum;

    end;

    if fCurrentStream <> 0 then
      BASS_StreamFree(fCurrentStream);

    if fChiptune <> 0 then
      BASS_MusicFree(fChipTune);

    if (fShuffle) AND (idx <> -1) then
      fSongsAlreadyPlayed[idx] := true;


        fCurrentStream := BASS_StreamCreateFile(  False,
                                              PChar(filename),
                                              0,
                                              0,
                                              BASS_STREAM_PRESCAN or
                                              StrToIntDef(Settings.GetSetting('speakers_count'), 0) or
                                              StrToIntDef(Settings.GetSetting('use_32_bit'), 0) or
                                              StrToIntDef(Settings.GetSetting('play_mono'), 0) or
                                              StrToIntDef(Settings.GetSetting('no_hardware'), 0));



    lg.WriteLog('BASS: ' + GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltInformation, lmExtended);
    fSongLength := round(BASS_ChannelBytes2Seconds(fCurrentStream, BASS_ChannelGetLength(fCurrentStream, BASS_POS_BYTE)));
    lg.WriteLog('BASS: ' + GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltInformation, lmExtended);
    FPlayerType := ptFileStream;

    if FOldPlayerType <> FPlayerType then
    begin
      FOldPlayerType := FPlayerType;
      SendMessage(FWindowHandle, WM_CHANGE_PLAYERTYPE, 0, 0);
    end;

    Result := True;
  end;
end;

procedure TMediaClass.Cleanup();
begin
  UnLoad_BASSDLL;
  lg.WriteLog('BASS: ' + GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltInformation, lmExtended);
end;

procedure TMediaClass.PlayNextTrack;
var
  LVItm : TLVItemCache;
  Pos : Integer;
  i: integer;
begin
  i := 0;
  if fShuffle then
  begin
      repeat
        Pos := random(GetDBItemsCount - 1) + 1;
        inc(i);
      until (i >= Length(fMediaFileLst)) or not (fSongsAlreadyPlayed[Pos - 1]);;
      LVItm := fDB.GetFileFromDB('', Pos);
      fCurrentMediaItem := LVItm.MediaFileItm;
      if Load(fCurrentMediaItem.FilePath, fCurrentMediaItem.RowID) then
        Play;
  end
  else
  begin
    if fCurrentMediaItem.RowID <> Length(fMediaFileLst) then
    begin
      LVItm := fDB.GetFileFromDB('', fCurrentMediaItem.RowID);
      fCurrentMediaItem := LVItm.MediaFileItm;
      if Load(fCurrentMediaItem.FilePath, fCurrentMediaItem.RowID) then
        Play;
    end
    else
    begin
      if fListRepeat then
      begin
        LVItm := fDB.GetFileFromDB('', 0);
        fCurrentMediaItem := LVItm.MediaFileItm;
        if Load(fCurrentMediaItem.FilePath, fCurrentMediaItem.RowID) then
          Play;
      end;
    end;
  end;
end;

procedure TMediaClass.PlayPreviousTrack;
var
  LVItm : TLVItemCache;
begin
  if fCurrentMediaItem.RowID >= 1  then
  begin
    LVItm := fDB.GetFileFromDB('', fCurrentMediaItem.RowID - 2);
    fCurrentMediaItem := LVItm.MediaFileItm;
    if Load(fCurrentMediaItem.FilePath, fCurrentMediaItem.RowID) then
      Play;
  end;
end;

procedure TMediaClass.Play();
begin
  BASS_ChannelPlay(fCurrentStream, False);

  lg.WriteLog('BASS: ' + GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltInformation, lmExtended);
  if Assigned(fOnStartPlayingTrack) then
    fOnStartPlayingTrack(fCurrentMediaItem.Artist, fCurrentMediaItem.Title, fCurrentMediaItem.Album, 0);

  BASS_ChannelSetSync(fCurrentStream, BASS_SYNC_END, 0, @TrackEnd, Pointer(Self));
  lg.WriteLog('BASS: ' + GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltInformation, lmExtended);

  SetNewVolume(fCurrentVol);

  fIsPlaying := true;
end;

procedure TMediaClass.Pause();
begin
  if fCurrentStream <> 0 then
  begin
    BASS_ChannelPause(fCurrentStream);
    fIsPlaying := false;
  end;
  if fChipTune <> 0 then
  begin
    BASS_ChannelPause(fChipTune);
    fIsPlaying := false;
  end;
end;

procedure TMediaClass.Stop();
begin
  if fCurrentStream <> 0 then
  begin
    BASS_ChannelStop(fCurrentStream);
    lg.WriteLog('BASS: ' + GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltInformation, lmExtended);
    fIsPlaying := false;
  end;
end;

procedure TMediaClass.Resume;
begin
  if fCurrentStream <> 0 then
  begin
    BASS_ChannelPlay(fCurrentStream, False);
    lg.WriteLog('BASS: ' + GetBassErrorName(BASS_ErrorGetCode), 'dgstMediaClass', ltInformation, lmExtended);
    fIsPlaying := true;
  end;
end;



(* Files *)
procedure TMediaClass.AddFileToDatabase(FileName: string);
var
  Specs: TFileSpecs;
begin
  If FileName <> '' then
  begin
      Specs.fFilePath := FileName;
      Specs.fFileExtType := GetFileExtension(FileName);
      Channel := Bass_StreamCreateFile(false, PChar(Specs.fFilePath), 0, 0, Bass_Stream_Decode);
      Specs.fTitle := Utf8ToAnsi(TAGS_Read(Channel, '%TITL'));
      Specs.fArtist := Utf8ToAnsi(TAGS_Read(Channel, '%ARTI'));
      Specs.fAlbum := Utf8ToAnsi(TAGS_Read(Channel, '%ALBM'));
      Specs.fYear := Utf8ToAnsi(TAGS_Read(Channel, '%YEAR'));
      Specs.fGenre := Utf8ToAnsi(TAGS_Read(Channel, '%GNRE'));
      fDB.AddFile(Specs);
  end;
end;

(* ListView Cache Ops *)
function TMediaClass.GetItemFromCache(Idx: Integer): TLVITemCache;
begin
  if (Idx > fg_ItmStart) AND (Idx < fg_ItmEnd) then
    Result := fLVItemsCache[Idx - fg_ItmStart]
  else
    Result := fMediaFileLst[Idx];
  //lg.WriteLog('Item Cached: ' + IntToStr(idx), 'dgstMediaClass', ltInformation, lmExtended);
end;

procedure TMediaClass.LoadCache(FromRow, ToRow: Integer);
var
  i, j: integer;
begin
  If (FromRow >= fg_ItmStart) AND (ToRow <= fg_ItmStart) then
    exit;

  i := FromRow;

  SetLength(fLVItemsCache, 0);
  SetLength(fLVItemsCache, ToRow - FromRow + 1);

  for j := 0 to ToRow - FromRow do
    begin
      fLVItemsCache[j] := fMediaFileLst[i];
      inc(i);
    end;

  fg_ItmStart := FromRow;
  fg_ItmEnd := ToRow;

   lg.WriteLog('Items Cached: From ' + IntToStr(FromRow) + ' To: ' + IntToStr(ToRow), 'dgstMediaClass', ltInformation, lmExtended);
end;

function TMediaClass.GetStreamPosForTB: Int64;
begin
  result := 0;

  if (fCurrentStream <> 0) then
    case FPlayerType of
      ptFileStream,
      ptChiptune:
        result := round(BASS_ChannelBytes2Seconds(fCurrentStream, BASS_ChannelGetPosition(fCurrentStream, BASS_POS_BYTE)));

      ptINetStream:
        result := 0;
    end;
end;

function TMediaClass.GetStreamDuration: Int64;
begin
  result := 0;

  if (fCurrentStream <> 0) then
    case FPlayerType of
      ptFileStream,
      ptChiptune:
        result := round(BASS_ChannelBytes2Seconds(fCurrentStream, BASS_ChannelGetLength(fCurrentStream, BASS_POS_BYTE)));

      ptINetStream:
        result := 0;
    end;
end;

procedure TMediaClass.RebuildPlayList;
begin
  SetLength(fMediaFileLst, 0);
  fMediaFileLst := fDB.GetFilesFromDB;
  lg.WriteLog('Length of List after rebuild: ' + IntToStr(Length(fMediaFileLst)), 'dgstMediaClass', ltInformation, lmNormal);
  SetLength(fLVItemsCache, 0);
  fg_ItmEnd := 0;
  fg_ItmStart := 0;
end;

procedure TMediaClass.SetNewPosition(Pos: Integer);
begin
  if (fCurrentStream <> 0) and (FPlayerType = ptFileStream) then
   BASS_ChannelSetPosition(fCurrentStream, BASS_ChannelSeconds2Bytes(fCurrentStream,Pos), BASS_POS_BYTE);
end;

procedure TMediaClass.SetNewVolume(vol: float);
begin
  if (fCurrentStream <> 0) then
   BASS_ChannelSetAttribute(fCurrentStream, BASS_ATTRIB_VOL, vol);
end;

function TMediaClass.GetVolume: float;
var
  vol: float;
begin
  vol := 1.0;
  if (fCurrentStream <> 0) then
   BASS_ChannelGetAttribute(fCurrentStream, BASS_ATTRIB_VOL, vol);

  result := vol;
end;

procedure TMediaClass.DeleteItemByLVID(ID: Integer);
begin
  if ID <> -1 then
  begin
    fDB.DeleteByID(fMediaFileLst[ID].MediaFileItm.RowID);
    RebuildPlayList;
  end;
end;

procedure TMediaClass.DeletePlayList;
begin
  fDB.EmptyDatabase;
  RebuildPlayList;
end;

procedure TMediaClass.AddURL(URL, Title, Genre: String);
begin
  if (URL <> '') AND (Title <> '') AND (Genre <> '') then
    fDB.AddUrlToGenre(URL, Genre, Title);
end;

procedure TMediaClass.AddGenre(Genre: String);
begin
  if Genre <> '' then
    fDB.AddGenreToDB(Genre);
end;

procedure TMediaClass.RebuildINetStations;
begin

end;

end.
