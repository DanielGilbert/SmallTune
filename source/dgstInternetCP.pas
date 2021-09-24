unit dgstInternetCP;
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
    Windows,
    Messages,
    dgstDataBase,
    dgstTypeDef;

  type
    TInternetStations = class
      private
        fFileName: String;
        fISGenreList : TISGenreList;
        fDB : TDataBase;

      public
        property GenreList: TISGenreList read fISGenreList;
        property FileName: String read fFileName;

        Constructor Create(var fMediaClDB: TDataBase);
        Destructor Destroy; override;

        procedure CreateISMenu(Parent: HMENU);
         procedure GetAllStations;
         
        procedure DeleteItem(idx: Integer; parent_idx: integer = -1; isParent: Boolean = true);
    end;

implementation

Constructor TInternetStations.Create(var fMediaClDB: TDataBase);
begin
  if not Assigned(fMediaClDB) then
     exit;
  fDB := fMediaClDB;
  SetLength(fISGenreList.Genres, 0);
  GetAllStations;
end;

Destructor TInternetStations.Destroy;
begin

end;

procedure TInternetStations.CreateISMenu(Parent: HMENU);
var
  MenuInf: TMenuInfo;
begin
  AppendMenu(Parent, MF_STRING or MF_POPUP, fISGenreList.MenuHandle, PChar('INet-Radio'));
  MenuInf.cbSize := SizeOf(TMenuInfo);
  MenuInf.fMask := MiM_STYLE or MIM_APPLYTOSUBMENUS;
  MenuInf.dwStyle := MNS_NOTIFYBYPOS;
  SetMenuInfo(Parent, MenuInf);
end;

Procedure TInternetStations.GetAllStations;
var
  I,N : integer;
begin
  DestroyMenu(fISGenreList.MenuHandle);
  SetLength(fISGenreList.Genres, 0);
  fISGenreList := fDB.GetAllURLsFromDB;
  fISGenreList.MenuHandle := CreatePopUpMenu;
  for I := 0 to Length(fISGenreList.Genres) - 1 do
    begin
      fIsGenreList.Genres[I].MenuHandle := CreatePopUpMenu;
      for N := 0 to Length(fISGenreList.Genres[I].Stations) - 1 do
        AppendMenu(fISGenreList.Genres[i].MenuHandle, MF_STRING, 0, PChar(fISGenreList.Genres[I].Stations[N].Name));
      AppendMenu(fISGenreList.MenuHandle, MF_STRING or MF_POPUP, fISGenreList.Genres[I].MenuHandle, PChar(fISGenreList.Genres[I].Name));
    end;
end;

procedure TInternetStations.DeleteItem(idx: Integer; parent_idx: integer; isParent: Boolean);
begin
  case isParent of

    True:
      begin
        fDB.DeleteGenreByID(parent_idx);
        GetAllStations;
      end;

    False:
      begin
        fDB.DeleteStreamByID(idx);
        GetAllStations;
      end;
      
  end;
end;

end.
