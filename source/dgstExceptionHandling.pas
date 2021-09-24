unit dgstExceptionHandling;
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
    Dynamic_Bass240, Windows;

resourcestring
  LNG_BASS_OK                 = 'All is OK';    // all is OK
  LNG_BASS_ERROR_MEM          = 'Memory Error';    // memory error
  LNG_BASS_ERROR_FILEOPEN     = 'File cannot be opened';    // can't open the file
  LNG_BASS_ERROR_DRIVER       = 'No free sound driver has been found';    // can't find a free sound driver
  LNG_BASS_ERROR_BUFLOST      = 'Sample Buffer lost';    // the sample buffer was lost
  LNG_BASS_ERROR_HANDLE       = 'Invalid Handle';    // invalid handle
  LNG_BASS_ERROR_FORMAT       = 'Unsuppported sample format';    // unsupported sample format
  LNG_BASS_ERROR_POSITION     = 'invalid position';    // invalid position
  LNG_BASS_ERROR_INIT         = 'BASS_Init has not been successfully called';    // BASS_Init has not been successfully called
  LNG_BASS_ERROR_START        = 'BASS_Start has not been successfully called';    // BASS_Start has not been successfully called
  LNG_BASS_ERROR_ALREADY      = 'Operation already performed';   // already initialized/paused/whatever
  LNG_BASS_ERROR_NOCHAN       = 'Can''t get a free channel';   // can't get a free channel
  LNG_BASS_ERROR_ILLTYPE      = 'an illegal type was specified';   // an illegal type was specified
  LNG_BASS_ERROR_ILLPARAM     = 'an illegal parameter was specified';   // an illegal parameter was specified
  LNG_BASS_ERROR_NO3D         = 'no 3D support';   // no 3D support
  LNG_BASS_ERROR_NOEAX        = 'no EAX support';   // no EAX support
  LNG_BASS_ERROR_DEVICE       = 'illegal device number';   // illegal device number
  LNG_BASS_ERROR_NOPLAY       = 'not playing';   // not playing
  LNG_BASS_ERROR_FREQ         = 'illegal sample rate';   // illegal sample rate
  LNG_BASS_ERROR_NOTFILE      = 'the stream is not a file stream';   // the stream is not a file stream
  LNG_BASS_ERROR_NOHW         = 'no hardware voices available';   // no hardware voices available
  LNG_BASS_ERROR_EMPTY        = 'the MOD music has no sequence data';   // the MOD music has no sequence data
  LNG_BASS_ERROR_NONET        = 'no internet connection could be opened';   // no internet connection could be opened
  LNG_BASS_ERROR_CREATE       = 'couldn''t create the file';   // couldn't create the file
  LNG_BASS_ERROR_NOFX         = 'effects are not enabled';   // effects are not enabled
  LNG_BASS_ERROR_NOTAVAIL     = 'requested data is not available';   // requested data is not available
  LNG_BASS_ERROR_DECODE       = 'the channel is a "decoding channel"';   // the channel is a "decoding channel"
  LNG_BASS_ERROR_DX           = 'a sufficient DirectX version is not installed';   // a sufficient DirectX version is not installed
  LNG_BASS_ERROR_TIMEOUT      = 'connection timedout';   // connection timedout
  LNG_BASS_ERROR_FILEFORM     = 'unsupported file format';   // unsupported file format
  LNG_BASS_ERROR_SPEAKER      = 'unavailable speaker';   // unavailable speaker
  LNG_BASS_ERROR_VERSION      = 'invalid BASS version (used by add-ons)';   // invalid BASS version (used by add-ons)
  LNG_BASS_ERROR_CODEC        = 'codec is not available/supported';   // codec is not available/supported
  LNG_BASS_ERROR_ENDED        = 'the channel/file has ended';   // the channel/file has ended
  LNG_BASS_ERROR_UNKNOWN      = 'some other mystery problem';   // some other mystery problem

  procedure DisplayErrorMessage(Code: Integer);
  function GetBassErrorName(Code: Integer): String;

implementation

procedure DisplayErrorMessage(Code: Integer);
var
  Tmp: String;
begin
  case code of
    BASS_OK                 : Tmp := LNG_BASS_OK;    // all is OK
    BASS_ERROR_MEM          : Tmp := LNG_BASS_ERROR_FILEOPEN;    // memory error
    BASS_ERROR_FILEOPEN     : Tmp := LNG_BASS_ERROR_FILEOPEN;    // can't open the file
    BASS_ERROR_DRIVER       : Tmp := LNG_BASS_ERROR_DRIVER;    // can't find a free sound driver
    BASS_ERROR_BUFLOST      : Tmp := LNG_BASS_ERROR_BUFLOST;    // the sample buffer was lost
    BASS_ERROR_HANDLE       : Tmp := LNG_BASS_ERROR_HANDLE;    // invalid handle
    BASS_ERROR_FORMAT       : Tmp := LNG_BASS_ERROR_FORMAT;    // unsupported sample format
    BASS_ERROR_POSITION     : Tmp := LNG_BASS_ERROR_POSITION;    // invalid position
    BASS_ERROR_INIT         : Tmp := LNG_BASS_ERROR_INIT;    // BASS_Init has not been successfully called
    BASS_ERROR_START        : Tmp := LNG_BASS_ERROR_START;    // BASS_Start has not been successfully called
    BASS_ERROR_ALREADY      : Tmp := LNG_BASS_ERROR_ALREADY;   // already initialized/paused/whatever
    BASS_ERROR_NOCHAN       : Tmp := LNG_BASS_ERROR_NOCHAN;   // can't get a free channel
    BASS_ERROR_ILLTYPE      : Tmp := LNG_BASS_ERROR_ILLTYPE;   // an illegal type was specified
    BASS_ERROR_ILLPARAM     : Tmp := LNG_BASS_ERROR_ILLPARAM;   // an illegal parameter was specified
    BASS_ERROR_NO3D         : Tmp := LNG_BASS_ERROR_NO3D;   // no 3D support
    BASS_ERROR_NOEAX        : Tmp := LNG_BASS_ERROR_NOEAX;   // no EAX support
    BASS_ERROR_DEVICE       : Tmp := LNG_BASS_ERROR_DEVICE;   // illegal device number
    BASS_ERROR_NOPLAY       : Tmp := LNG_BASS_ERROR_NOPLAY;   // not playing
    BASS_ERROR_FREQ         : Tmp := LNG_BASS_ERROR_FREQ;   // illegal sample rate
    BASS_ERROR_NOTFILE      : Tmp := LNG_BASS_ERROR_NOTFILE;   // the stream is not a file stream
    BASS_ERROR_NOHW         : Tmp := LNG_BASS_ERROR_NOHW;   // no hardware voices available
    BASS_ERROR_EMPTY        : Tmp := LNG_BASS_ERROR_EMPTY;   // the MOD music has no sequence data
    BASS_ERROR_NONET        : Tmp := LNG_BASS_ERROR_NONET;   // no internet connection could be opened
    BASS_ERROR_CREATE       : Tmp := LNG_BASS_ERROR_CREATE;   // couldn't create the file
    BASS_ERROR_NOFX         : Tmp := LNG_BASS_ERROR_NOFX;   // effects are not enabled
    BASS_ERROR_NOTAVAIL     : Tmp := LNG_BASS_ERROR_NOTAVAIL;   // requested data is not available
    BASS_ERROR_DECODE       : Tmp := LNG_BASS_ERROR_DECODE;   // the channel is a "decoding channel"
    BASS_ERROR_DX           : Tmp := LNG_BASS_ERROR_DX;   // a sufficient DirectX version is not installed
    BASS_ERROR_TIMEOUT      : Tmp := LNG_BASS_ERROR_TIMEOUT;   // connection timedout
    BASS_ERROR_FILEFORM     : Tmp := LNG_BASS_ERROR_FILEFORM;   // unsupported file format
    BASS_ERROR_SPEAKER      : Tmp := LNG_BASS_ERROR_SPEAKER;   // unavailable speaker
    BASS_ERROR_VERSION      : Tmp := LNG_BASS_ERROR_VERSION;   // invalid BASS version (used by add-ons)
    BASS_ERROR_CODEC        : Tmp := LNG_BASS_ERROR_CODEC;   // codec is not available/supported
    BASS_ERROR_ENDED        : Tmp := LNG_BASS_ERROR_ENDED;   // the channel/file has ended
    BASS_ERROR_UNKNOWN      : Tmp := LNG_BASS_ERROR_UNKNOWN;   // some other mystery problem
  end;

  MessageBox(0, PChar(Tmp), 'BASS-Error!', MB_OK or MB_ICONERROR);

end;

function GetBassErrorName(Code: Integer): String;
var
  Tmp: String;
begin
  tmp := 'unknown';
  case code of
    BASS_OK                 : Tmp := LNG_BASS_OK;    // all is OK
    BASS_ERROR_MEM          : Tmp := LNG_BASS_ERROR_FILEOPEN;    // memory error
    BASS_ERROR_FILEOPEN     : Tmp := LNG_BASS_ERROR_FILEOPEN;    // can't open the file
    BASS_ERROR_DRIVER       : Tmp := LNG_BASS_ERROR_DRIVER;    // can't find a free sound driver
    BASS_ERROR_BUFLOST      : Tmp := LNG_BASS_ERROR_BUFLOST;    // the sample buffer was lost
    BASS_ERROR_HANDLE       : Tmp := LNG_BASS_ERROR_HANDLE;    // invalid handle
    BASS_ERROR_FORMAT       : Tmp := LNG_BASS_ERROR_FORMAT;    // unsupported sample format
    BASS_ERROR_POSITION     : Tmp := LNG_BASS_ERROR_POSITION;    // invalid position
    BASS_ERROR_INIT         : Tmp := LNG_BASS_ERROR_INIT;    // BASS_Init has not been successfully called
    BASS_ERROR_START        : Tmp := LNG_BASS_ERROR_START;    // BASS_Start has not been successfully called
    BASS_ERROR_ALREADY      : Tmp := LNG_BASS_ERROR_ALREADY;   // already initialized/paused/whatever
    BASS_ERROR_NOCHAN       : Tmp := LNG_BASS_ERROR_NOCHAN;   // can't get a free channel
    BASS_ERROR_ILLTYPE      : Tmp := LNG_BASS_ERROR_ILLTYPE;   // an illegal type was specified
    BASS_ERROR_ILLPARAM     : Tmp := LNG_BASS_ERROR_ILLPARAM;   // an illegal parameter was specified
    BASS_ERROR_NO3D         : Tmp := LNG_BASS_ERROR_NO3D;   // no 3D support
    BASS_ERROR_NOEAX        : Tmp := LNG_BASS_ERROR_NOEAX;   // no EAX support
    BASS_ERROR_DEVICE       : Tmp := LNG_BASS_ERROR_DEVICE;   // illegal device number
    BASS_ERROR_NOPLAY       : Tmp := LNG_BASS_ERROR_NOPLAY;   // not playing
    BASS_ERROR_FREQ         : Tmp := LNG_BASS_ERROR_FREQ;   // illegal sample rate
    BASS_ERROR_NOTFILE      : Tmp := LNG_BASS_ERROR_NOTFILE;   // the stream is not a file stream
    BASS_ERROR_NOHW         : Tmp := LNG_BASS_ERROR_NOHW;   // no hardware voices available
    BASS_ERROR_EMPTY        : Tmp := LNG_BASS_ERROR_EMPTY;   // the MOD music has no sequence data
    BASS_ERROR_NONET        : Tmp := LNG_BASS_ERROR_NONET;   // no internet connection could be opened
    BASS_ERROR_CREATE       : Tmp := LNG_BASS_ERROR_CREATE;   // couldn't create the file
    BASS_ERROR_NOFX         : Tmp := LNG_BASS_ERROR_NOFX;   // effects are not enabled
    BASS_ERROR_NOTAVAIL     : Tmp := LNG_BASS_ERROR_NOTAVAIL;   // requested data is not available
    BASS_ERROR_DECODE       : Tmp := LNG_BASS_ERROR_DECODE;   // the channel is a "decoding channel"
    BASS_ERROR_DX           : Tmp := LNG_BASS_ERROR_DX;   // a sufficient DirectX version is not installed
    BASS_ERROR_TIMEOUT      : Tmp := LNG_BASS_ERROR_TIMEOUT;   // connection timedout
    BASS_ERROR_FILEFORM     : Tmp := LNG_BASS_ERROR_FILEFORM;   // unsupported file format
    BASS_ERROR_SPEAKER      : Tmp := LNG_BASS_ERROR_SPEAKER;   // unavailable speaker
    BASS_ERROR_VERSION      : Tmp := LNG_BASS_ERROR_VERSION;   // invalid BASS version (used by add-ons)
    BASS_ERROR_CODEC        : Tmp := LNG_BASS_ERROR_CODEC;   // codec is not available/supported
    BASS_ERROR_ENDED        : Tmp := LNG_BASS_ERROR_ENDED;   // the channel/file has ended
    BASS_ERROR_UNKNOWN      : Tmp := LNG_BASS_ERROR_UNKNOWN;   // some other mystery problem
  end;
  Result := tmp;
end;

end.
