unit dgstPlaylistReader;

interface
  uses Windows, Messages, dgstSysUtils, dgstHelper, dgstTypeDef;

  Type
    TdgstPlaylistReader = class
      private
        fPlaylistFile: String;
        fPlaylistType: TPlaylistType;
        fPlaylistEntries : TPlaylistEntries;
      public
        property PlaylistFile: String read fPlaylistFile;
        property PlaylistType: TPlaylistType read fPlaylistType;
        property PlaylistEntries : TPlaylistEntries read fPlaylistEntries;

        Constructor Create(fFileName, fFileExt: String);
        Destructor Destroy; override;

        procedure ReadPlaylist;
    end;

implementation

  Constructor TdgstPlaylistReader.Create(fFileName, fFileExt: String);
  begin
    fPlaylistType := ptUnknown;
    if AnsiLowerCase(fFileExt) = 'm3u' then
      fPlaylistType := ptM3U;
    if AnsiLowerCase(fFileExt) = 'pls' then
      fPlaylistType := ptPLS;
    fPlaylistFile := fFileName;
    SetLength(fPlaylistEntries, 0);
  end;

  Destructor TdgstPlaylistReader.Destroy;
  begin

  end;

  procedure TdgstPlaylistReader.ReadPlaylist;
  var
    fFile : Textfile;
    tmp, tmp2 : String;
  begin
    if FileExists(fPlaylistFile) then
    begin
      SetLength(fPlaylistEntries, 0);
      fPlaylistFile := fPlaylistFile;
      FileMode := fmOpenRead;
      AssignFile(fFile, fPlaylistFile);
      try
        Reset(fFile);
        case fPlaylistType of

          ptM3U:
            begin
              ReadLN(fFile, tmp);
              (* Check wether the M3U contains xtended info or not *)
              if tmp = '#EXTM3U' then
              begin
                fPlaylistType := ptM3UExt;
                while not eof(fFile) do
                begin
                ReadLN(fFile, tmp);
                  tmp2 := copy(trim(tmp), 1, 8);
                  if tmp2 = '#EXTINF:' then
                    SetLength(fPlaylistEntries, Length(fPlaylistEntries)+1);
                  Delete(tmp, 1, 8);
                  tmp2 := copy(tmp, 1, Pos(',', tmp) - 1);
                  if tmp2 <> '' then
                   fPlaylistEntries[Length(fPlaylistEntries) - 1].FileTime := StrToIntDef(tmp2, 0);
                  Delete(tmp, 1, Length(tmp2)+1);
                  if tmp <> '' then
                    fPlaylistEntries[Length(fPlaylistEntries) - 1].Title := tmp;
                  ReadLN(fFile, tmp);
                  fPlaylistEntries[Length(fPlaylistEntries) - 1].FilePath := tmp;
                end;
              end;

            end;

          ptPLS:
            begin

            end;

          ptUnknown:
            begin

            end;

        end;
      finally
        CloseFile(fFile);
      end;
    end;
  end;
  (*
    if FileExists(fFileName) then
  begin
    AssignFile(fFile, fFileName);
    FileMode := fmOpenRead;
    i := 0;
    n := 0;
    try
      Reset(fFile);
      fISGenreList.MenuHandle := CreatePopUpMenu;
      while not EOF(fFile) do
      begin
        ReadLn(fFile, Expr);
        if Expr[1] = '[' then
        begin
          n := 0;
          Inc(i);
          SetLength(fISGenreList.Genres, i);
          tmp := copy(Expr, 2, Pos(']', Expr) - 2);
          fISGenreList.Genres[i - 1].Name := tmp;
          fISGenreList.Genres[i - 1].MenuHandle := CreatePopUpMenu;
        end
        else
        begin
          Inc(n);
          SetLength(fISGenreList.Genres[i-1].Stations, n);
          tmp := copy(Expr, 1, Pos('=', Expr) - 1);
          fISGenreList.Genres[i - 1].Stations[n-1].Name := tmp;
          tmp := copy(Expr, Pos('=', Expr) + 1, Length(Expr));
          fISGenreList.Genres[i - 1].Stations[n-1].URL := tmp;
          AppendMenu(fISGenreList.Genres[i - 1].MenuHandle, MF_STRING, 0, PChar(fISGenreList.Genres[i - 1].Stations[n-1].Name));
        end;
      end;
      for m := 1 to i do
        AppendMenu(fISGenreList.MenuHandle, MF_STRING or MF_POPUP, fISGenreList.Genres[m - 1].MenuHandle, PChar(fISGenreList.Genres[m - 1].Name));
    finally
      CloseFile(fFile);
    end;
  end;*)
end.
