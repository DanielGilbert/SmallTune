unit dgstDataBase;
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
  uses SQLiteDatabase, dgstTypeDef, dgstHelper, dgstSysUtils, dgstLog;

  Type
    TDatabase = class
      private
        fFileName: String;
        fDB: TSQLiteDatabase;
      public
        property FileName: String read fFileName;

        procedure AddFile(FileSpecs: TFileSpecs);
        procedure DeleteByID(ID: Integer);

        procedure EmptyDatabase;
        (* Transaction *)
        procedure StartTransaction(Val: Boolean = true);
        (* Get all Items from DB (excl. INet-Streams) *)
        function GetFilesFromDB(Filter: String = ''; FromRow : Integer = -1; ToRow : Integer = -1): TLVItemCacheArray;
        function GetFileFromDB(Filter: String = ''; Row : Integer = -1): TLVItemCache;
        (* INetStreams - Funcs *)
        (* Add *)
        function AddUrlToGenre(URL, Genre, Name: String): Boolean;
        function AddGenreToDB(Genre: String): Boolean;
        (* Delete *)
        function RemoveUrlFromDB(URL, Genre: String): Boolean;
        function DeleteGenreByID(GenreID: Integer): Boolean;
        function DeleteStreamByID(StreamID: Integer): Boolean;
        (* Retrieve *)
        function GetAllURLsFromDB: TISGenreList;
        (* Initializing *)
        procedure CreateTables;
        (* Stats *)
        function GetDBItemsCount(Filter: String): Integer;
        (* Settings *)
        procedure SetSettings(Sets: TSettings);
        function GetSettings: TSettings;


        Constructor Create(DBFile: String);
        Destructor Destroy; override;
    end;

implementation

  Constructor TDatabase.Create(DBFile: String);
  begin
    if DBFile <> '' then
    begin
      fFileName := DBFile;
      fDB := TSQLiteDatabase.Create(fFileName);
      if Assigned(fDB) then
      begin
        lg.WriteLog('SQLiteDatabase-object created', 'dgstDatabase', ltInformation, lmNormal);
        with fDB do
        begin
          if not FileExists(fFileName) then
          begin
            Connect(fFileName);
            CreateTables;
          end
          else
          begin
            Connect(fFileName);
          end;
        end;
      end
      else
      begin
        lg.WriteLog('SQLiteDatabase-object creation failed!', 'dgstDatabase', ltError, lmNormal);
        Halt;
      end;
    end;
  end;

  Destructor TDatabase.Destroy;
  begin
    fDB.Free;
  end;

  procedure TDatabase.CreateTables;
  begin
    fDB.Execute('CREATE TABLE FILES (FILE_PATH TEXT,' +
                                        'FILE_EXT TEXT, ' +
                                        'FILE_NAME TEXT, ' +
                                        'FILE_TITLE TEXT,' +
                                        'FILE_ARTIST TEXT,' +
                                        'FILE_ALBUM TEXT,' +
                                        'FILE_YEAR TEXT, ' +
                                        'FILE_GENRE TEXT, ' +
                                        'FILE_LENGTH INTEGER,' +
                                        'FILE_TIMES_PLAYED INTEGER,' +
                                        'FILE_RATING INTEGER );');

    fDB.Execute('CREATE TABLE INETSTREAMS ( STREAM_ID INTEGER PRIMARY KEY AUTOINCREMENT,' +
                                        'STREAM_URL TEXT,' +
                                        'STREAM_NAME TEXT);');

    fDB.Execute('CREATE TABLE INETSTREAM_GENRES ( STREAM_GENRE TEXT , ' +
                                        'INETSTREAMS_IDS TEXT );');

    fDB.Execute('CREATE TABLE OPTIONS (OPTION_NAME TEXT,' +
                                        'OPTION_VALUE TEXT);');

    StartTransaction;
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("version","0.3")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("start_with_windows","0")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("play_file_after_drop","1")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("add_file_to_playlist","1")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("main_window_pinned","0")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("main_window_x","0")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("main_window_y","0")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("save_main_window_pos","0")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("main_window_movable","0")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("hotkeys_activated","0")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("multimedia_keys_activated","0")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("play_hotkey","1|0|1|30")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("prev_hotkey","1|0|1|26")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("next_hotkey","1|0|1|28")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("playlist_hotkey","1|0|1|9")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("shuffle_hotkey","1|0|1|18")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("repeat_hotkey","1|0|1|17")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("use_32_bit","0")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("play_mono","0")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("no_hardware","0")');
    fDB.Execute('INSERT INTO OPTIONS (OPTION_NAME , OPTION_VALUE) VALUES ("speakers_count","2")');
    StartTransaction(False);

    lg.WriteLog('First start tables created', 'dgstDatabase');
  end;

  procedure TDatabase.DeleteByID(ID: Integer);
  begin
    fDB.Execute('DELETE FROM FILES WHERE ROWID = "' + IntToStr(ID) + '" ;');
    fDB.Execute('VACUUM');
  end;
  
  function TDatabase.DeleteGenreByID(GenreID: Integer): Boolean;
  begin
    fDB.Execute('DELETE FROM INETSTREAM_GENRES WHERE ROWID = "' + IntToStr(GenreID) + '" ;');
    fDB.Execute('VACUUM');
    Result := True;
  end;

  function TDatabase.DeleteStreamByID(StreamID: Integer): Boolean;
  begin
    fDB.Execute('DELETE FROM INETSTREAMS WHERE STREAM_ID = "' + IntToStr(StreamID) + '" ;');
    fDB.Execute('VACUUM');
    Result := True;
  end;

  procedure TDatabase.SetSettings(Sets: TSettings);
  var
    fInsertCmd: TSQLiteCommand;
    i : integer;
  begin
    StartTransaction;
    for I := 0 to Length(Sets) - 1 do
      begin
        fInsertCmd := fDB.Command('UPDATE OPTIONS SET OPTION_VALUE = :opt_val WHERE OPTION_NAME = :opt_name ;');
        fInsertCmd.BindingByName[':opt_val'].AsString := Sets[i].Value;
        fInsertCmd.BindingByName[':opt_name'].AsString := Sets[i].Name;
        fInsertCmd.Execute;
        if fInsertCmd.ChangeCount = 0 then
        begin
          fInsertCmd := fDB.Command('INSERT INTO OPTIONS (OPTION_VALUE, OPTION_NAME) VALUES ( :opt_val, :opt_name ) ;');
          fInsertCmd.BindingByName[':opt_val'].AsString := Sets[i].Value;
          fInsertCmd.BindingByName[':opt_name'].AsString := Sets[i].Name;
          fInsertCmd.Execute;
        end;
        fInsertCmd.Free;
      end;
    StartTransaction(false);
  end;

  procedure TDatabase.StartTransaction(Val: Boolean = true);
  begin
    if Val then
      fDB.Execute('BEGIN TRANSACTION')
    else
      fDB.Execute('END TRANSACTION'); 
  end;
  
  procedure TDatabase.AddFile(FileSpecs: TFileSpecs);
  var
    fInsertCmd: TSQLiteCommand;
  begin
    fInsertCmd := fDB.Command('INSERT INTO FILES (FILE_PATH, FILE_EXT, FILE_NAME, FILE_TITLE, FILE_ARTIST, FILE_ALBUM, FILE_YEAR, FILE_GENRE, FILE_LENGTH, FILE_TIMES_PLAYED, FILE_RATING) ' +
                        'VALUES ( ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ?);');
    fInsertCmd.Binding[1].AsString := FileSpecs.fFilePath;
    fInsertCmd.Binding[2].AsString := FileSpecs.fFileExtType;
    fInsertCmd.Binding[3].AsString := GetFileName(FileSpecs.fFilePath);
    fInsertCmd.Binding[4].AsString := FileSpecs.fTitle;
    fInsertCmd.Binding[5].AsString := FileSpecs.fArtist;
    fInsertCmd.Binding[6].AsString := FileSpecs.fAlbum;
    fInsertCmd.Binding[7].AsString := FileSpecs.fYear;
    fInsertCmd.Binding[8].AsString := FileSpecs.fGenre;
    fInsertCmd.Binding[9].AsInteger := FileSpecs.fLength;
    fInsertCmd.Binding[10].AsInteger := FileSpecs.fTimes_Played;
    fInsertCmd.Binding[11].AsInteger := FileSpecs.fRating;
    fInsertCmd.Execute;
    fInsertCmd.Free;
  end;

  function TDatabase.GetFilesFromDB(Filter: String = ''; FromRow : Integer = -1; ToRow : Integer = -1): TLVItemCacheArray;
  var
    Query: TSQLiteQuery;
    I: Integer;
    FromRowStr,
    ToRowStr: String;
  begin
  if Filter = '' then
  begin
    if (FromRow <> -1) AND (ToRow <> -1) then
    begin
      Str(FromRow+1, FromRowStr);
      Str(ToRow+1, ToRowStr);
      Query := fDB.Query('SELECT ROWID,* FROM FILES WHERE ROWID BETWEEN '+ FromRowStr +' AND '+ ToRowStr +'  ;');
    end
    else
      Query := fDB.Query('SELECT ROWID,* FROM FILES;');
  end
  else
  begin
    if (FromRow <> -1) AND (ToRow <> -1) then
    begin
      Str(FromRow+1, FromRowStr);
      Str(ToRow+1, ToRowStr);
      Query := fDB.Query('SELECT ROWID,* FROM FILES WHERE ROWID BETWEEN '+ FromRowStr +' AND '+ ToRowStr +' AND FILE_NAME LIKE "%' + Filter + '%" OR FILE_TITLE LIKE "%' + Filter + '%" OR FILE_ARTIST LIKE "%' + Filter + '%" OR FILE_ALBUM  LIKE "%' + Filter + '%"  ;');
    end
    else
      Query := fDB.Query('SELECT ROWID,* FROM FILES WHERE FILE_NAME LIKE "%' + Filter + '%" OR FILE_TITLE LIKE "%' + Filter + '%" OR FILE_ARTIST LIKE "%' + Filter + '%" OR FILE_ALBUM  LIKE "%' + Filter + '%"  ;');
  end;
  while Query.Next do
    begin
      I := Length(Result);
      SetLength(Result, Length(Result) + 1);
      Result[I].MediaFileItm.FilePath := Query[1].AsString;
      Result[I].MediaFileItm.FileName := Query[3].AsString;
      Result[I].MediaFileItm.Title := Query[4].AsString;
      REsult[I].MediaFileItm.Artist := Query[5].AsString;
      Result[I].MediaFileItm.Album := Query[6].AsString;
      Result[I].MediaFileItm.Genre := Query[7].AsString;
      Result[I].MediaFileItm.RowID := Query[0].AsInteger;;
      Result[I].State := 0;
    end;
    Query.Free;
  end;

  function TDatabase.GetSettings: TSettings;
  var
    Query: TSQLiteQuery;
  begin
    Result := nil;
    Query := fDB.Query('SELECT * FROM OPTIONS;');
    while Query.Next do
    begin
      SetLength(Result, Length(Result) + 1);
      Result[Length(Result)-1].Name := Query[0].AsString;
      Result[Length(Result)-1].Value := Query[1].AsString;
    end;
    Query.Free;
  end;


  function TDatabase.GetFileFromDB(Filter: String = ''; Row : Integer = -1): TLVItemCache;
  var
    Query: TSQLiteQuery;
    RowIdStr : String;
  begin
    Str(Row+1, RowIdStr);
    Query := fDB.Query('SELECT ROWID,* FROM FILES WHERE ROWID = '+ RowIdStr +';');

    while Query.Next do
    begin
      Result.MediaFileItm.FilePath := Query[1].AsString;
      Result.MediaFileItm.FileName := Query[3].AsString;
      Result.MediaFileItm.Title := Query[4].AsString;
      Result.MediaFileItm.Artist := Query[5].AsString;
      Result.MediaFileItm.Album := Query[6].AsString;
      Result.MediaFileItm.Genre := Query[7].AsString;
      Result.MediaFileItm.RowID := Query[0].AsInteger;;
      Result.State := 0;
    end;
    Query.Free;
  end;

  function TDatabase.GetDBItemsCount(Filter: String): Integer;
  var
    Query : TSQLiteQuery;
  begin
    if Filter = '' then
      Query := fDB.Query('SELECT ROWID FROM FILES ORDER BY ROWID DESC;')
    else
      Query := fDB.Query('SELECT COUNT(*) FROM FILES WHERE FILE_NAME LIKE "%' + Filter + '%" OR FILE_TITLE LIKE "%' + Filter + '%" OR FILE_ARTIST LIKE "%' + Filter + '%" OR FILE_ALBUM  LIKE "%' + Filter + '%" ;');
    Query.Next;
    Result:= Query[0].AsInteger;
    Query.Free;
  end;

  function TDatabase.AddGenreToDB(Genre: String): Boolean;
  var
    fInsertCmd: TSQLiteCommand;
  begin
    Result := False;
    if Genre <> '' then
    begin
      fInsertCmd := fDB.Command('INSERT INTO INETSTREAM_GENRES (STREAM_GENRE, INETSTREAMS_IDS) VALUES ( ?  , ? );');
      fInsertCmd.Binding[1].AsString := Genre;
      fInsertCmd.Binding[2].AsString := '';
      fInsertCmd.Execute;
      fInsertCmd.Free;
      Result := True;
    end;
  end;

  function TDatabase.AddUrlToGenre(URL, Genre, Name: String): Boolean;
  var
    fInsertCmd: TSQLiteCommand;
    fQuery: TSQliteQuery;
    n : Integer;
    streams, streamname: String;
  begin
    Result := False;
    if (URL <> '') and (Genre <> '') and (Name <> '') then
    begin
      (* Add the URL to the corresponding table *)
      fInsertCmd := fDB.Command('INSERT INTO INETSTREAMS (STREAM_URL, STREAM_NAME) ' +
                        'VALUES ( ? , ? );');
      fInsertCmd.Binding[1].AsString := URL;
      fInsertCmd.Binding[2].AsString := Name;
      fInsertCmd.Execute;
      fInsertCmd.Free;
      StartTransaction;
      (* Get the new ID of the stream *)
      n := fInsertCmd.InsertID;
      lg.WriteLog('DB Add URL: ID: ' + IntToStr(n), 'dgstDataBase', ltInformation, lmExtended);

      (* Get the selected genre *)
      fQuery := fDB.Query('SELECT * FROM INETSTREAM_GENRES WHERE STREAM_GENRE = "' + Genre + '";');

      (* Check, if there are already Ids saved *)
      if fQuery.Next then
      begin
        streamname := fQuery[0].AsString;
        lg.WriteLog('DB Add URL: Genre: ' + streamname, 'dgstDataBase', ltInformation, lmExtended);
        if streamname <> '' then
        begin
          streams := fQuery[1].AsString;

          lg.WriteLog('DB Add URL: Old RAW Streams: ' + streams, 'dgstDataBase', ltInformation, lmExtended);

          if streams = '' then
            streams := IntToStr(n)
          else
            streams := streams + ',' + IntToStr(n);

          lg.WriteLog('DB Add URL: New RAW Streams: ' + streams, 'dgstDataBase', ltInformation, lmExtended);

        end;
      end;

      (* Finally, add the new ID/URL to the Genre *)
      fInsertCmd := fDB.Command('UPDATE INETSTREAM_GENRES SET INETSTREAMS_IDS = :ids WHERE STREAM_GENRE = :genre ;');
      fInsertCmd.BindingByName[':ids'].AsString := streams;
      fInsertCmd.BindingByName[':genre'].AsString := streamname;
      fInsertCmd.Execute;
      fInsertCmd.Free;
      StartTransaction(False);

      Result := True;
    end;
  end;

  function TDatabase.RemoveUrlFromDB(URL, Genre: String): Boolean;
  begin
    Result := false;
  end;

  function TDatabase.GetAllURLsFromDB: TISGenreList;
  var
    Query: TSQLiteQuery;
    SubQuery: TSQLiteQuery;
    i,n,m: Integer;
    streams: String;
    DynArray: TStringDynArray;
  begin
    i := 0;

    DynArray := nil;

    Query := fDB.Query('SELECT * FROM INETSTREAM_GENRES;');
    try
      while Query.Next do
      begin
        m := -1;
        SetLength(Result.Genres, Length(Result.Genres) + 1);
        Result.MenuHandle := 0;
        Result.Genres[i].Name := Query.ColumnByName['STREAM_GENRE'].AsString;

        lg.WriteLog('DB Streams Name:' + Result.Genres[i].Name, 'dgstDataBase', ltInformation, lmExtended);

        streams := Query.ColumnByName['INETSTREAMS_IDS'].AsString;
        DynArray := nil;
        if streams <> '' then
          DynArray := Explode(',', streams);

        lg.WriteLog('DB Raw Streams:' + Streams, 'dgstDataBase', ltInformation, lmExtended);

        for n := 0 to Length(DynArray) - 1 do
        begin
          SubQuery := fDB.Query('SELECT STREAM_ID,* FROM INETSTREAMS WHERE STREAM_ID = ' + DynArray[n] + ' LIMIT 1;');
          try
            if SubQuery.Next then
            begin
              SetLength(Result.Genres[i].Stations, Length(Result.Genres[i].Stations) + 1);
              inc(m);
              Result.Genres[i].Stations[m].URL := SubQuery.ColumnByName['STREAM_URL'].AsString;
              lg.WriteLog('DB Stations URL:' + Result.Genres[i].Stations[m].URL, 'dgstDataBase', ltInformation, lmExtended);
              Result.Genres[i].Stations[m].ID := SubQuery.ColumnByName['STREAM_ID'].AsInteger;
              Result.Genres[i].Stations[m].Name := SubQuery.ColumnByName['STREAM_NAME'].AsString;
              lg.WriteLog('DB Stations Name: ' + Result.Genres[i].Stations[m].Name, 'dgstDataBase', ltInformation, lmExtended);

            end;
          finally
            SubQuery.Free;
          end;
        end;
        inc(i);
      end;
    finally
      Query.Free;
    end;
  end;

  procedure TDatabase.EmptyDatabase;
  begin
    fDB.Execute('DELETE FROM FILES;');
    fDB.Execute('VACUUM');
  end;

end.
