unit dgstFindFiles;
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
  uses Windows, dgstTypeDef, dgstHelper, dgstSysUtils;

  Type
    TOnFilesDone = procedure(Files: TFileArray) of object;
    TOnProgress = procedure(Progr: Integer) of object;
    TdgstFindFiles = class
      private
        fFiles: TFileArray;
        fThreadID: Cardinal;
        fThread: THandle;

        fRootFolder: String;
        fMask: TMaskArray;

        fRecursive: Boolean;

        fOnFilesDone: TOnFilesDone;
        fOnProgress: TOnProgress;

        function ThreadCallBack: Integer;
      public
        property Files : TFileArray read fFiles write fFiles;

        property OnFilesDone : TOnFilesDone read fOnFilesDone write fOnFilesDone;
        property OnProgress : TOnProgress read fOnProgress write fOnProgress;

        procedure StartSearch;

        Constructor Create(RootFolder: String; Mask: TMaskArray; Recursive : Boolean = false);
        Destructor Destroy; override;
    end;

implementation

  Constructor TdgstFindFiles.Create(RootFolder: String; Mask: TMaskArray; Recursive : Boolean = false);
  begin
    fRootFolder := RootFolder;
    fMask := Mask;
    fRecursive := Recursive;
    fThread := BeginThread(nil, 0, @TdgstFindFiles.ThreadCallBack, Self, CREATE_SUSPENDED, fThreadID);
  end;

  Destructor TdgstFindFiles.Destroy;
  begin
    EndThread(0);
  end;

  procedure TdgstFindFiles.StartSearch;
  begin
    ResumeThread(fThread);
  end;

  function TdgstFindFiles.ThreadCallBack: Integer;
    procedure LFindAllFiles(AParentFolder: String);
    var
      W32FD: TWin32FindData;
      hFile: THandle;
      i: Integer;
      Tmp : String;
    begin
      hFile := FindFirstFile(PChar(AParentFolder + '*'), W32FD);
      if hFile <> INVALID_HANDLE_VALUE then
      begin
        repeat
          if (String(W32FD.cFileName) <> '.') and (String(W32FD.cFileName) <> '..') then
            if (W32FD.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY then
            begin
              If fRecursive then
                 LFindAllFiles(AParentFolder + String(W32FD.cFileName) + '\');
            end
            else
              for I := 0 to Length(fMask) - 1 do
              begin
                Tmp := AnsiLowerCase(String(W32FD.cFileName));
                If Like(Tmp, fMask[i]) then
                begin
                  SetLength(fFiles, Length(fFiles) + 1);
                  fFiles[Length(fFiles) - 1] := AParentFolder + String(W32FD.cFileName);
                  If Assigned(OnProgress) then
                    OnProgress(Length(fFiles));
                end;
              end;

        until not FindNextFile(hFile, W32FD);
        FindClose(hFile);
      end;
    end;
  var
    i: integer;
  begin
    Result := 0;
    begin
      for I := 0 to Length(fMask) - 1 do
        fMask[i] := AnsiLowerCase(fMask[i]);
      If fRootFolder <> '' then
      begin
      If fRootFolder[Length(fRootFolder)] <> '\' then
        fRootFolder := fRootFolder + '\';
        LFindAllFiles(fRootFolder);
        if Assigned(OnFilesDone) then
          OnFilesDone(fFiles);
      end
    end;
  end;



end.
