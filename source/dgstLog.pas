unit dgstLog;
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
  uses Windows, dgstSysUtils;

  Type
    TLogMode = (lmNone, lmNormal, lmExtended);
    TLogType = (ltInformation, ltWarning, ltError);

    TdgstLog = class
      private
        fLogMode: TLogMode;

        fLogFilePath: String;

        //Setter
        procedure SetLogMode(Val: TLogMode);
      public
        property LogMode : TLogMode read fLogMode write SetLogMode;

        constructor Create;
        destructor Destroy; override;

        procedure WriteLog( Msg: String;
                            Unitname: String = '';
                            MsgType : TLogType = ltInformation;
                            LgMode: TlogMode = lmNormal);
    end;

var
  Lg: TdgstLog;

implementation

  constructor TdgstLog.Create;
  begin
    fLogMode := lmNone;
    fLogFilePath := '';
  end;

  destructor TdgstLog.Destroy;
  begin
    FreeConsole;
  end;

  procedure TdgstLog.SetLogMode(Val: TLogMode);
  begin
    case Val of
      lmNormal: AllocConsole;
      lmExtended: AllocConsole;
    end;
    fLogMode := Val;
  end;

  procedure TdgstLog.WriteLog(Msg: string;
                              Unitname: string = '';
                              MsgType: TLogType = ltInformation;
                              LgMode: TlogMode = lmNormal);
  var
    tmp: String;
  begin
    if fLogMode <> lmNone then
    begin
      if (fLogMode = lmExtended) or (LgMode <> lmExtended) then
      begin
        tmp := '';
        case MsgType of
          ltWarning: tmp := '[Warning]';
          ltError: tmp := '[Error]';
        end;
        WriteLn(Format('%s [%s]: "%s"', [tmp, Unitname, Msg]));
      end;
    end;
  end;

initialization
  Lg := TdgstLog.Create;

finalization
  Lg.Free;

end.
