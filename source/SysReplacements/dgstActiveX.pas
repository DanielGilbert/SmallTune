unit dgstActiveX;

interface
(**************************************************************************\
*
*   GDI+ OLE / ActiveX Fragment
*
\**************************************************************************)
uses
  Windows;

type
{ OLE character and string types }

  TOleChar = WideChar;
  POleStr = PWideChar;
  PPOleStr = ^POleStr;

  POleStrList = ^TOleStrList;
  TOleStrList = array[0..65535] of POleStr;

  {$EXTERNALSYM Largeint}
  Largeint = Int64;

  {$EXTERNALSYM PROPID}
  PROPID = ULONG;
  PPropID = ^TPropID;
  TPropID = PROPID;


{ Class ID }

  PCLSID = PGUID;
  TCLSID = TGUID;  

  IStream = interface;

  PStatStg = ^TStatStg;
  {$EXTERNALSYM tagSTATSTG}
  tagSTATSTG = record
    pwcsName: POleStr;
    dwType: Longint;
    cbSize: Largeint;
    mtime: TFileTime;
    ctime: TFileTime;
    atime: TFileTime;
    grfMode: Longint;
    grfLocksSupported: Longint;
    clsid: TCLSID;
    grfStateBits: Longint;
    reserved: Longint;
  end;
  TStatStg = tagSTATSTG;
  {$EXTERNALSYM STATSTG}
  STATSTG = TStatStg;

  {$EXTERNALSYM ISequentialStream}
  ISequentialStream = interface(IUnknown)
    ['{0c733a30-2a1c-11ce-ade5-00aa0044773d}']
    function Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult;
      stdcall;
    function Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult;
      stdcall;
  end;

  {$EXTERNALSYM IStream}
  IStream = interface(ISequentialStream)
    ['{0000000C-0000-0000-C000-000000000046}']
    function Seek(dlibMove: Largeint; dwOrigin: Longint;
      out libNewPosition: Largeint): HResult; stdcall;
    function SetSize(libNewSize: Largeint): HResult; stdcall;
    function CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint;
      out cbWritten: Largeint): HResult; stdcall;
    function Commit(grfCommitFlags: Longint): HResult; stdcall;
    function Revert: HResult; stdcall;
    function LockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; stdcall;
    function UnlockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; stdcall;
    function Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult;
      stdcall;
    function Clone(out stm: IStream): HResult; stdcall;
  end;

  {$EXTERNALSYM CreateStreamOnHGlobal}
  function CreateStreamOnHGlobal(hglob: HGlobal;
    fDeleteOnRelease: BOOL; out stm: IStream): HResult;
    stdcall;  external 'ole32.dll' name 'CreateStreamOnHGlobal';

//----------------------------------------------------------------------------

implementation

end.
