unit dgstTypeDef;
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

  uses Windows, Messages, dgstCommCtrl;

  //Makes Translating Easy
  const
    LNG_STARTING_ERROR          = 0;
    LNG_PLAYING_TNA             = 1;
    LNG_PAUSE_TNA               = 2;
    LNG_STOP_TNA                = 3;
    LNG_ADDINGFILESTODATABASE   = 4;
    LNG_PREVTRACK               = 5;
    LNG_STOPTRACK               = 6;
    LNG_PLAYPAUSE               = 7;
    LNG_NEXTTRACK               = 8;
    LNG_PLAYLIST                = 9;
    LNG_ADDFILE                 = 10;
    LNG_ADDFOLDER               = 11;
    LNG_ADDURL                  = 12;
    LNG_REPEATPLAYLIST          = 13;
    LNG_SHUFFLE                 = 14;
    LNG_HELP                    = 15;
    LNG_INFO                    = 16;
    LNG_EXIT                    = 17;
    LNG_SELECTFOLDER            = 18;
    LNG_PLAYLISTNUMBER          = 19;
    LNG_PLAYLISTTITLE           = 20;
    LNG_PLAYLISTARTIST          = 21;
    LNG_FILTER                  = 22;
    LNG_ERRORAPPALREADYRUNNING  = 23;
    LNG_TITLE                   = 24;
    LNG_ARTIST                  = 25;
    LNG_MSC                     = 26;
    LNG_URL                     = 27;
    LNG_ALLFILESADDED           = 28;
    LNG_ADDINGFILESFINISHED     = 29;
    LNG_ALREADYREAD             = 30;
    LNG_INIT                    = 31;
    LNG_READINGWAIT             = 32;
    LNG_WHERETOSAVEDB           = 33;
    LNG_WHERETOSAVEDBCAPTION    = 34;
    LNG_FILEFILTERSTRING        = 35;
    LNG_DELETEITEM              = 36;
    LNG_DELETEITEMCAPTION       = 37;
    LNG_DELETEITEMS             = 38;
    LNG_DELETEITEMSCAPTION      = 39;
    LNG_USINGWIN7               = 40;
    LNG_USINGWIN7CAPTION        = 41;
    LNG_UNKNOWN                 = 42;
    LNG_NOVALIDURL              = 43;
    LNG_TTIP_PLAY               = 44;
    LNG_TTIP_NEXT               = 45;
    LNG_TTIP_PREV               = 46;
    LNG_TTIP_PLS                = 47;
    LNG_TTIP_REPE               = 48;
    LNG_TTIP_SHUF               = 49;
    LNG_TTIP_SEARCHARTIST       = 50;
    LNG_TTIP_NOHIDE             = 51;
    LNG_URL_ADD                 = 52;
    LNG_URL_PLAY                = 53;
    LNG_URL_STATION_TITLE       = 54;
    LNG_URL_STATION_URL         = 55;
    LNG_URL_CANCEL              = 56;
    LNG_URL_URL_CUETEXT         = 57;
    LNG_URL_TITLE_CUETEXT       = 58;
    LNG_SETTINGS                = 59;
    LNG_PLBTNHINTS              = 60;
    LNG_ALT                     = 61;
    LNG_CTRL                    = 62;
    LNG_SHIFT                   = 63;
    LNG_LEFT_ARROW_KEY          = 64;
    LNG_UP_ARROW_KEY            = 65;
    LNG_RIGHT_ARROW_KEY         = 66;
    LNG_DOWN_ARROW_KEY          = 67;
    LNG_SPACE_KEY               = 68;
    LNG_HOME_KEY                = 69;
    LNG_END_KEY                 = 70;
    LNG_PAGE_UP_KEY             = 71;
    LNG_PAGE_DOWN_KEY           = 72;

    (* FXX - KEYS: 73 - 95 *)

    LNG_URL_CATNAME             = 96;
    LNG_URL_ADDCAT              = 97;
    LNG_URL_ADDURL              = 98;
    LNG_SETTINGS_AUTOSTART      = 99;
    LNG_SETTINGS_MOVEWINDOWPOS  = 100;
    LNG_SETTINGS_SAVEWINDOWPOS  = 101;
    LNG_SETTINGS_LNG_GBX        = 102;
    LNG_SETTINGS_GENERAL_GBX    = 103;
    LNG_SETTINGS_DRAGDROP_GBX   = 104;
    LNG_SETTINGS_PLAYFILEDROP   = 105;
    LNG_SETTINGS_ADDFILEDROP    = 106;
    LNG_SETTINGS_MMKEYS         = 107;
    LNG_SETTINGS_HOTKEYS        = 108;
    LNG_SETTINGS_CTRL           = 109;
    LNG_SETTINGS_ALT            = 110;
    LNG_SETTINGS_SHIFT          = 111;
    LNG_SETTINGS_BASS_FLOAT     = 112;
    LNG_SETTINGS_BASS_MONO      = 113;
    LNG_SETTINGS_BASS_NOHW      = 114;
    LNG_SETTINGS_BASS_TECH_GBX  = 115;
    LNG_SETTINGS_HOTKEYS_GBX    = 116;
    LNG_URLWND_PLAYONLY         = 117;
    LNG_URLWND_ADDTODB          = 118;
    LNG_URLWND_STATIONS         = 119;
    LNG_URLWND_ADD              = 120;
    LNG_URLWND_ADDCAT           = 121;
    LNG_URLWND_DELSEL           = 122;
    LNG_PLAYLISTALBUM           = 123;

const
  // Hotkeys
  HOTKEY_PLAY_PAUSE = 1;
  HOTKEY_ADD_FILES  = 2;
  HOTKEY_NEXT_TRK   = 3;
  HOTKEY_PREV_TRK   = 4;
  HOTKEY_SHUFFLE    = 5;
  HOTKEY_REPEAT     = 6;

  //User-Agent
  USER_AGENT = 'SmallTune/0.3';

  //Little Helper
  const
    AppName   = 'SmallTune';

    PlaylistWndName = 'Playlist';
    RadiobrowserWndName = 'Radiobrowser';
    URLWndName = 'URL:';

    wndClassName    = AppName + 'WndClass';
    wndClassName2   = AppName + 'WndClass2';
    radiobrowserWndClassName = AppName + 'Radiobrowser';

    WindowWidth2 = 490;
    WindowHeight2 = 600;
    WindowWidth3 = 350;
    WindowHeight3 = 105;
    RadioBrowserWindowWidth = 960;
    RadioBrowserWindowHeight = 540;

    WM_TNAMSG     = WM_USER + 10;
    WM_CHANGE_PLAYERTYPE = WM_USER + $0815;

    WM_SPECIALEVENT = WM_User + 1678;

    VK_MEDIA_NEXT_TRACK = $B0;
    {$EXTERNALSYM VK_MEDIA_NEXT_TRACK}
    VK_MEDIA_PREV_TRACK = $B1;
    {$EXTERNALSYM VK_MEDIA_PREV_TRACK}
    VK_MEDIA_STOP = $B2;
    {$EXTERNALSYM VK_MEDIA_STOP}
    VK_MEDIA_PLAY_PAUSE = $B3;
    {$EXTERNALSYM VK_MEDIA_PLAY_PAUSE}

    WM_APPCOMMAND       = $0319;

    // MMedia key codes
    APPCOMMAND_MEDIA_NEXTTRACK = 11;
    {$EXTERNALSYM APPCOMMAND_MEDIA_NEXTTRACK}
    APPCOMMAND_MEDIA_PREVIOUSTRACK = 12;
    {$EXTERNALSYM APPCOMMAND_MEDIA_PREVIOUSTRACK}
    APPCOMMAND_MEDIA_STOP = 13;
    {$EXTERNALSYM APPCOMMAND_MEDIA_STOP}
    APPCOMMAND_MEDIA_PLAY_PAUSE = 14;
    {$EXTERNALSYM APPCOMMAND_MEDIA_PLAY_PAUSE}

    SPECWIDTH	 = 96;
    SPECHEIGHT = 96;
    BANDS	     = 40;

    LVS_EX_FULLROWSELECT  =  $00000020; // applies to report mode only
    LVS_EX_DOUBLEBUFFER  =  $00010000;
    (* ICN RES *)

    MEDIA_PAUS          = 50;
    MEDIA_PLAY          = 60;
    MEDIA_STOP          = 70;
    MEDIA_PREV          = 100;
    MEDIA_NEXT          = 110;
    MEDIA_SEAR          = 120;
    MEDIA_SHUF          = 130;
    MEDIA_REPE          = 140;
    MEDIA_ADD           = 150;
    MEDIA_PINN          = 155;

    (* PL MEDIA BUTTONS *)

    MEDIA_PLADDFILES    = 210;
    MEDIA_PLADDDIR      = 211;
    MEDIA_PLCLEARALL    = 212;
    MEDIA_PLCLEARSEL    = 213;

    (* SEARCH ARTIST BTN *)
    MEDIA_SEARCH_ARTIST = 214;


    (* ICN RES *)

    ICN_MEDIA_PAUS      = 0;
    ICN_MEDIA_PLAY      = 1;
    ICN_MEDIA_STOP      = 2;
    ICN_MEDIA_PREV      = 3;
    ICN_MEDIA_NEXT      = 4;
    ICN_MEDIA_SEAR      = 5;
    ICN_MEDIA_SHUF      = 6;
    ICN_MEDIA_REPE      = 7;
    ICN_MEDIA_ADD       = 8;
    ICN_MEDIA_SRC       = 9;
    ICN_MEDIA_PINN      = 10;
    (* Buttons *)

    //IDC_CLOSEBTN = 10;
    IDC_STARTBTN = 20;
    IDC_STOPBTN = 30;
    IDC_NEXTBTN = 40;
    IDC_PREVBTN = 50;
    IDC_EJECTBTN = 60;
    IDC_PLAYLISTBTN = 70;
    IDC_RADIOBROWSERBTN = 71;
    IDC_SETTINGSBTN = 80;
    IDC_OFDBTN = 90;


    IDC_PATHEDIT = 110;
    IDC_TOOLBAR = 120;
    IDC_PLTOOLBAR = 122;

    IDC_SEARCHEDT = 130;

    IDC_SHUFFLEBTN = 140;
    IDC_REPEATBTN = 150;
    IDC_PINNER = 155;

    IDC_ADDURLBTN = 160;
    IDC_CANCELURLBTN = 170;

    IDC_SEARCHWEBBTN = 180;

    ICN_TNA = 200;



    (* PopUpMenu Buttons *)
    IDM_CLOSEBTN = 100;
    IDM_ADDFILE = 200;
    IDM_ADDFOLDER = 210;
    IDM_ADDURL = 215;
    IDM_REPEAT = 220;
    IDM_SHUFFLE = 230;
    IDM_HELP = 240;
    IDM_INFO = 250;

    IDM_INTERNETRADIO = 280;

    IDL_TITLE = 290;
    IDL_ARTIST = 300;
    IDL_MISC = 310;

    IDT_POSBAR = 320;

    IDG_ALBUMART = 330;

    IDC_TIMER = 340;

    IDM_LOOKATAMAZON = 350;
    IDM_LOOKATWIKI = 360;
    IDM_LOOKATMYSPACE = 370;
    IDM_LOOKATGOOGLE = 380;

    IDC_COUNTRIES_CBX = 410;

    //MainMenuItemIDs (by Position)
    MMI_PLAYLIST = 0;
    // Seperator = 1
    MMI_ADDFILE = 2;
    MMI_ADDFOLDER = 3;
    MMI_ADDURL = 4;
    // Seperator = 5
    MMI_SUBMENU = 6;
    // Seperator = 7
    MMI_REPEAT = 8;
    MMI_SHUFFLE = 9;
    // Seperator = 10;
    MMI_HELP = 11;
    MMI_INFO = 12;
    // Seperator = 13
    MMI_SETTINGS = 14;
    // Seperator = 15
    MMI_CLOSE = 16;

    MMI_DELETEALLITEMS = 30;

    MMI_DELETESELECTION = 40;

    //Dialog Consts
  const
  IDC_ADDURL_GBX = 6002;
  IDC_ADDCAT_STATIC = 6018;
  IDC_CATEGORY_GBX = 6015;

  IDC_SETTINGS_CTRL  = 10214;
  IDC_SETTINGS_ALT   = 10215;
  IDC_SETTINGS_SHIFT = 10216;

  IDC_TRV_SETTINGS = 10001;
  IDC_GENERAL_GENERAL_GBX = 10011;
  IDC_GENERAL_AUTOSTART_CHK = 10012;
  IDC_GENERAL_DRAGDROPGBX = 10015;
  IDC_GENERAL_PLAYFILEDROP_CHK = 10016;
  IDC_GENERAL_ADDFILEDROP_CHK = 10017;
  IDC_GENERAL_SAVEWINDOWPOS_CHK = 10101;
  IDC_LNG_GBX = 10102;
  IDC_LANG_CBX = 10103;
  IDC_GENERAL_MAKEMOVABLE_CHK = 10104;
  IDC_RADIOBROWSER_COUNTRY_CBX = 10105;
  IDD_DLG2_HOTKEYS = 10200;
  IDC_HKEYS_GBX = 10201;
  IDC_PLAYPAUSE_HEKY_STATIC = 10202;
  IDC_NEXT_HKEY_STATIC = 10203;
  IDC_PREV_HKEY_STATIC = 10204;
  IDC_PLAYLIST_HKEY_STATIC = 10205;
  IDC_MMKEYS_HKEY_CHK = 10206;
  IDC_HKEYS_HKEYS_CHK = 10207;
  IDC_PLAYPAUSE_HKEY_CBX = 10208;
  IDC_NEXT_HKEY_CBX = 10209;
  IDC_PREV_HKEY_CBX = 10210;
  IDC_HKEY_PLAYLIST_CBX = 10211;
  IDC_SHUFFLE_PLAYLIST_STATIC = 10212;

  IDC_REPEAT_HKEYS_STATIC = 10213;
  IDC_CTRL_HKEY_STATIC = 10214;
  IDC_ALT_HKEY_STATIC = 10215;
  IDC_SHIFT_HKEY_STATIC = 10216;

  IDC_GENERAL_PLAY_CTRL_CHK = 10217;

  IDC_HKEY_SHUFFLE_CBX = 10218;
  IDC_HKEY_REPEAT_CBX = 10219;

  IDC_GENERAL_NEXT_CTRL_CHK = 10220;
  IDC_GENERAL_PREV_CTRL_CHK = 10221;
  IDC_GENERAL_PL_CTRL_CHK = 10222;
  IDC_GENERAL_SHUF_CTRL_CHK = 10223;
  IDC_GENERAL_REP_CTRL_CHK = 10224;
  IDC_GENERAL_REP_ALT_CHK = 10225;
  IDC_GENERAL_SHUF_ALT_CHK = 10226;
  IDC_GENERAL_PL_ALT_CHK = 10227;
  IDC_GENERAL_PREV_ALT_CHK = 10228;
  IDC_GENERAL_NEXT_ALT_CHK = 10229;
  IDC_GENERAL_PLAY_ALT_CHK = 10230;
  IDC_GENERAL_REP_SHIFT_CHK = 10231;
  IDC_GENERAL_SHUF_SHIFT_CHK = 10232;
  IDC_GENERAL_PL_SHIFT_CHK = 10233;
  IDC_GENERAL_PREV_SHIFT_CHK = 10234;
  IDC_GENERAL_NEXT_SHIFT_CHK = 10235;
  IDC_GENERAL_PLAY_SHIFT_CHK = 10236;

  IDD_DLG2_BASSAUDIO = 10300;
  IDC_BASS_TECH_GBX = 10301;
  IDC_BASS_32BIT_CHK = 10302;
  IDC_BASS_MONO_CHK = 10303;
  IDC_BASS_HWACCEL_CHK = 10304;
  IDC_BASS_SPEAKERS_GBX = 10305;
  IDC_STC18 = 10306;
  IDC_SPEAKERS_CBX = 10307;

  IDC_SETTINGS_CLOSE_BTN = 10003;





  Type
    TStringDynArray = array of String;

    TFFTArray = array[0..127] of Single;

    TFileSpecs = packed record
      fFilePath: String;
      fFileExtType: String;
      fTitle: String;
      fArtist: String;
      fAlbum: String;
      fYear: String;
      fGenre: String;
      fLength: Integer;
      fTimes_Played: Integer;
      fRating: Integer;
    end;

    TstState = (stPlay, stPause, stStop, stAddFolder);

    TMediaFile = packed record
      FileName : String;
      FilePath : String;
      Title : String;
      Artist : String;
      Album : String;
      Genre : String;
      RowID : Integer;//Necessary for Random Playing
    end;

    TLVItemCache = packed record
      State: Integer;
      MediaFileItm: TMediaFile;
    end;

    TLVItemCacheArray = Array of TLVItemCache;

    TMediaFiles = Array of TMediaFile;

    TFileArray = Array of String;
    TMaskArray = Array of String;

    //Internet Streams

    TISStation = packed record
      Name: String;
      URL: String;
      ID: Integer;
    end;

    TISStationList = Array of TISStation;

    TISGenre = packed record
      Stations : TISStationList;
      Name: String;
      //Handle for the Station Menu
      MenuHandle: HMENU;
    end;

    TISGenreList = packed record
      Genres: Array of TISGenre;
      //Handle for the Genre Menu
      MenuHandle: HMENU;
    end;

    //Playlist reader
    TPlaylistEntry = packed record
      Title: String;
      FilePath: String;
      FileTime: Integer;
    end;
    TPlaylistEntries = Array of TPlaylistEntry;

    TPlaylistType = (ptUnknown, ptM3U, ptM3UExt, ptPLS, ptPLSExt);

    TSetting = packed record
      Name: String;
      Value: String;
    end;

    TSettings = Array of TSetting;
    
   var
      tbButtons      : array[0..10]of TTBButton =
    (
      //Play/Pause
     (iBitmap:ICN_MEDIA_PLAY;
      idCommand:IDC_STARTBTN;
      fsState:TBSTATE_ENABLED;
      fsStyle:BTNS_BUTTON or BTNS_AUTOSIZE;
      dwData:0;
      iString:0;),


      //Previous
      (iBitmap:ICN_MEDIA_PREV;
      idCommand:IDC_PREVBTN;
      fsState:TBSTATE_ENABLED;
      fsStyle:BTNS_BUTTON or BTNS_AUTOSIZE;
      dwData:0;
      iString:2;),

     //Next
     (iBitmap:ICN_MEDIA_NEXT;
      idCommand:IDC_NEXTBTN;
      fsState:TBSTATE_ENABLED;
      fsStyle:BTNS_BUTTON or BTNS_AUTOSIZE;
      dwData:0;
      iString:3;),

      //Seperator
     (iBitmap:0;
      idCommand:0;
      fsState:TBSTATE_ENABLED;
      fsStyle:BTNS_SEP;
      dwData:0;
      iString:-1;),

      //Shuffling
      (iBitmap:ICN_MEDIA_REPE;
      idCommand:IDC_SHUFFLEBTN;
      fsState:TBSTATE_ENABLED;
      fsStyle:BTNS_CHECK or BTNS_AUTOSIZE;
      dwData:0;
      iString:4;),

     //Repeat
     (iBitmap:ICN_MEDIA_SHUF;
      idCommand:IDC_REPEATBTN;
      fsState:TBSTATE_ENABLED;
      fsStyle:BTNS_CHECK or BTNS_AUTOSIZE;
      dwData:0;
      iString:5;),

      //Seperator
     (iBitmap:0;
      idCommand:0;
      fsState:TBSTATE_ENABLED;
      fsStyle:BTNS_SEP;
      dwData:0;
      iString:-1;),

      //Playlist
     (iBitmap:ICN_MEDIA_SEAR;
      idCommand:IDC_PLAYLISTBTN;
      fsState:TBSTATE_ENABLED;
      fsStyle:BTNS_BUTTON or BTNS_AUTOSIZE;
      dwData:0;
      iString:6;),

      //RadioBrowser
     (iBitmap:ICN_MEDIA_SEAR;
      idCommand:IDC_RADIOBROWSERBTN;
      fsState:TBSTATE_ENABLED;
      fsStyle:BTNS_BUTTON or BTNS_AUTOSIZE;
      dwData:0;
      iString:7;),

      //Seperator
     (iBitmap:0;
      idCommand:0;
      fsState:TBSTATE_ENABLED;
      fsStyle:BTNS_SEP;
      dwData:0;
      iString:-1;),

      //Pinner
     (iBitmap:ICN_MEDIA_PINN;
      idCommand:IDC_PINNER;
      fsState:TBSTATE_ENABLED;
      fsStyle:BTNS_BUTTON or BTNS_AUTOSIZE or BTNS_CHECK;
      dwData:0;
      iString:-1;)

      );

var
    tbPLButtons      : array[0..4]of TTBButton =
    (
      //Add File(s)
     (iBitmap:0;
      idCommand: MMI_ADDFILE;
      fsState:TBSTATE_ENABLED;
      fsStyle:BTNS_BUTTON or BTNS_SHOWTEXT or BTNS_AUTOSIZE;
      dwData:0;
      iString:0;),

      //Add Dir
     (iBitmap:1;
      idCommand:MMI_ADDFOLDER;
      fsState:TBSTATE_ENABLED;
      fsStyle:BTNS_BUTTON or BTNS_SHOWTEXT or BTNS_AUTOSIZE;
      dwData:0;
      iString:1;),

      //Seperator
     (iBitmap:0;
      idCommand:0;
      fsState:TBSTATE_ENABLED;
      fsStyle:BTNS_SEP;
      dwData:0;
      iString:-1;),

      //Clear all
     (iBitmap:2;
      idCommand: MMI_DELETEALLITEMS;
      fsState:TBSTATE_ENABLED;
      fsStyle:BTNS_BUTTON or BTNS_SHOWTEXT or BTNS_AUTOSIZE;
      dwData:0;
      iString:2;),


      //Clear sel
      (iBitmap:3;
      idCommand:MMI_DELETESELECTION;
      fsState:TBSTATE_ENABLED;
      fsStyle:BTNS_BUTTON or BTNS_SHOWTEXT or BTNS_AUTOSIZE;
      dwData:0;
      iString:3;)

      );

    WindowWidth : Integer = 320;
    WindowHeight : Integer = 190;

    TrackbarX : Integer = 2;
    TrackbarY : Integer = 110;
    TrackbarWidth : Integer = 220;
    TrackbarHeight : Integer = 20;

    VolumeTrackbarX : Integer = 230;
    VolumeTrackbarY : Integer = 110;
    VolumeTrackbarWidth : Integer = 80;
    VolumeTrackbarHeight : Integer = 20;

    ToolbarX : Integer = 4;
    ToolbarY : Integer = 135;
    ToolbarWidth : Integer = 305;
    ToolbarHeight : Integer = 25;

    DisplayWidth : Integer = 310;
    DisplayHeight : Integer = 100;

    SpectrumX : Integer = 60;
    SpectrumY : Integer = 32;
    SpectrumWidth : Integer = 238;
    SpectrumHeight : Integer = 48;
    SpectrumBands : Integer = 72;

    XSongTitelOffset : integer = 5;
    YSongTitelOffset : integer = 15;
    XSongInfoOffset  : integer = 4;
    YSongInfoOffset  : integer = 1;
    XSongIndexOffset : integer = 250;
    YSongIndexOffset : integer = 4;

    XSongPosTimeOffset : integer = 0;
    YSongPosTimeOffset : integer = 85;

    //Playlist Window
    XCountriesComboboxOffset : integer = 5;
    YCountriesComboboxOffset : integer = 5;
    CountriesComboboxWidth : integer = 180;
    CountriesComboboxHeight : integer = 25;

implementation

end.
