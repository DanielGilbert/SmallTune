program smalltune;
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
* Version             : 0.4.0
* Date                : 06-2025
* Description         : SmallTune is a simple but powerful audioplayer for
*                       Windows
***************************************************************************}
{$R 'res\resources.res' 'res\resources.rc'}

uses
  dgstTranslator in 'source\dgstTranslator.pas',
  dgstMain in 'source\dgstMain.pas',
  dynamic_bass240 in 'source\thirdparty\dynamic_bass240.pas',
  dgstDataBase in 'source\dgstDataBase.pas',
  dgstFindFiles in 'source\dgstFindFiles.pas',
  dgstHelper in 'source\dgstHelper.pas',
  dgstMediaClass in 'source\dgstMediaClass.pas',
  dgstTypeDef in 'source\dgstTypeDef.pas',
  sqlite3dll in 'source\thirdparty\sqlite\sqlite3dll.pas',
  SQLiteDatabase in 'source\thirdparty\sqlite\SQLiteDatabase.pas',
  dgstCommCtrl in 'source\SysReplacements\dgstCommCtrl.pas',
  dgstShlObj in 'source\SysReplacements\dgstShlObj.pas',
  dgstSysUtils in 'source\SysReplacements\dgstSysUtils.pas',
  dgstActiveX in 'source\SysReplacements\dgstActiveX.pas',
  dgstInternetCP in 'source\dgstInternetCP.pas',
  SpecialFolders in 'source\thirdparty\SpecialFolders.pas',
  MpuAboutMsgBox in 'source\thirdparty\MpuAboutMsgBox.pas',
  dgstExceptionHandling in 'source\dgstExceptionHandling.pas',
  tPnvMiniGDIPlus in 'source\thirdparty\tPnvMiniGDIPlus.pas',
  tPnvOpenFileDlg in 'source\thirdparty\tPnvOpenFileDlg.pas',
  tPstDisplay in 'source\thirdparty\tPstDisplay.pas',
  dgstLog in 'source\dgstLog.pas',
  languagecodes in 'source\thirdparty\languagecodes.pas',
  dgstSettings in 'source\dgstSettings.pas',
  Tags in 'source\thirdparty\tags.pas';

begin

  if Paramstr(1) = '-debug' then
    Lg.LogMode := lmNormal;

  if Paramstr(1) = '-xdebug' then
    lg.LogMode := lmExtended;

  //Debug
  Lg.WriteLog('Initializing...', 'smalltune.dpr', ltInformation, lmNormal);

  WinMain(SysInit.hInstance, System.hPrevInst, System.CmdLine, System.CmdShow);
end.