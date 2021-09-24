unit dgstSettings;
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
* Date                : 12-2009
* Description         : SmallTune is a simple but powerful audioplayer for
*                       Windows
***************************************************************************}
interface
  uses Windows, dgstTypeDef, dgstDatabase;

  Type
    TdgstSettingsClass = class
      private
        fSettings : TSettings;
        fDB : TDatabase;
      public
        property DB : TDatabase read fDB write fDB;

        constructor Create;
        destructor Destroy; override;

        procedure LoadSettings;
        procedure SaveSettings;

        function GetSetting(Name: String): String;
        procedure WriteSetting(Name, Value: String);
    end;

var
  Settings : TdgstSettingsClass;

implementation

{ TdgstSettingsClass }

constructor TdgstSettingsClass.Create;
begin
  SetLength(fSettings, 0);
end;

destructor TdgstSettingsClass.Destroy;
begin
  inherited;
end;

function TdgstSettingsClass.GetSetting(Name: String): String;
var
  i: integer;
begin
  Result := 'N/A';
  for I := 0 to Length(fSettings) - 1 do
    if fSettings[i].Name = Name then
      Result := fSettings[i].Value;
end;

procedure TdgstSettingsClass.LoadSettings;
begin
  if Assigned(fDB) then
    fSettings := fDB.GetSettings;
  if fSettings = nil then
  begin
      MessageBox(0,
                      PChar('Unable to load Settings. Maybe incorrect Database-Version? Please delete the database.' +#13#10+' File can be found at:' + #13#10 + #13#10 + fDB.FileName),
                      PChar('Settings-Error!'),
                      MB_OK or MB_ICONERROR
                      );
      Exit;
  end;
end;

procedure TdgstSettingsClass.SaveSettings;
begin
  if Assigned(fDB) then
    fDB.SetSettings(fSettings);
end;

procedure TdgstSettingsClass.WriteSetting(Name, Value: String);
var
  i: integer;
begin
  for I := 0 to Length(fSettings) - 1 do
    if fSettings[i].Name = Name then
    begin
      fSettings[i].Value := Value;
      break;
    end;
  //Settings wasn't found, create new one
  SetLength(fSettings, Length(fSettings) + 1);
  fSettings[Length(fSettings) - 1].Name := Name;
  fSettings[Length(fSettings) - 1].Value := Value;
end;

initialization
Settings := TdgstSettingsClass.Create;

finalization
Settings.Free;

end.
