{*******************************************************}
{                                                       }
{       SQLite Header Translation                       }
{                                                       }
{       Copyright (C) 2009 Frederic Heihoff             }
{                                                       }
{       Version 1.0                                     }
{                                                       }
{*******************************************************}

unit sqlite3dll;

interface

//Headertranslation for SQL Version
const
  SQLITE_VERSION = '3.6.18';
  SQLITE_VERSION_NUMBER = 3006018;

//Objects
type
  sqlite3 = Pointer;
  sqlite3_blob = Pointer;
  sqlite3_context = Pointer;
  sqlite3_int64 = Int64;
  sqlite3_mutex = Pointer;
  sqlite3_stmt = Pointer;
  sqlite3_destructor_type = Pointer;
  sqlite3_value = Pointer;
  sqlite3_values = Pointer;

//Callbacks
type
  TSQLiteFreeCallback = procedure(Data: Pointer); cdecl;
  TSQLiteBusyHandlerCallback = function(Data: Pointer; TimesExecuted: Integer): Integer; cdecl;
  TSQLiteCollationNeededCallback = procedure(Data: Pointer; db: sqlite3; eTextRep: Integer; collation: PAnsiChar); cdecl;
  TSQLiteCollationNeeded16Callback = procedure(Data: Pointer; db: sqlite3; eTextRep: Integer; collation: PWideChar); cdecl;
  TSQLiteExecCallback = function(data: Pointer; num_cols: integer; value: PAnsiChar; columnname: PansiChar): Integer;  cdecl;
  TSQLiteProgressCallback = procedure(Data: Pointer); cdecl;
  TSQLiteHookCallback = procedure(Data: Pointer); cdecl;
  TSQLiteAuthorizerCallback = function(Data: Pointer; actioncode: integer; add1,add2,add3,add4: PAnsiChar): Integer; cdecl;
  TSQLitexFuncCallback = procedure(context: sqlite3_context; argc: Integer; argv: sqlite3_values); cdecl;
  TSQLitexStepCallback = procedure(context: sqlite3_context; argc: Integer; argv: sqlite3_values); cdecl;
  TSQLitexCompareCallback = function(data: Pointer; N1: Integer; Str1: PChar; N2: Integer; Str2: PChar): Integer; cdecl;
  TSQLitexDestroyCallback = procedure(data: Pointer);  cdecl;
  TSQLitexProgressCallback = function(data: Pointer): integer;  cdecl;
  TSQLitexFinalCallback = procedure(context: sqlite3_context); cdecl;

const
  sqlitedll = 'libs/sqlite3.dll';

//Result Codes
const
	SQLITE_OK = 0;
	SQLITE_ERROR = 1;
	SQLITE_INTERNAL = 2;
	SQLITE_PERM = 3;
	SQLITE_ABORT = 4;
	SQLITE_BUSY = 5;
	SQLITE_LOCKED = 6;
	SQLITE_NOMEM = 7;
	SQLITE_READONLY = 8;
	SQLITE_INTERRUPT = 9;
	SQLITE_IOERR = 10;
	SQLITE_CORRUPT = 11;
	SQLITE_NOTFOUND = 12;
	SQLITE_FULL = 13;
	SQLITE_CANTOPEN = 14;
	SQLITE_PROTOCOL = 15;
	SQLITE_EMPTY = 16;
	SQLITE_SCHEMA = 17;
	SQLITE_TOOBIG = 18;
	SQLITE_CONSTRAINT = 19;
	SQLITE_MISMATCH = 20;
	SQLITE_MISUSE = 21;
	SQLITE_NOLFS = 22;
	SQLITE_AUTH = 23;
	SQLITE_FORMAT = 24;
	SQLITE_RANGE = 25;
	SQLITE_NOTADB = 26;
	SQLITE_ROW = 100;
	SQLITE_DONE = 101;

//Extended Result Codes
const
	SQLITE_IOERR_READ = (SQLITE_IOERR or (1 shl 8));
	SQLITE_IOERR_SHORT_READ = (SQLITE_IOERR or (2 shl 8));
	SQLITE_IOERR_WRITE = (SQLITE_IOERR or (3 shl 8));
	SQLITE_IOERR_FSYNC = (SQLITE_IOERR or (4 shl 8));
	SQLITE_IOERR_DIR_FSYNC = (SQLITE_IOERR or (5 shl 8));
	SQLITE_IOERR_TRUNCATE = (SQLITE_IOERR or (6 shl 8));
	SQLITE_IOERR_FSTAT = (SQLITE_IOERR or (7 shl 8));
	SQLITE_IOERR_UNLOCK = (SQLITE_IOERR or (8 shl 8));
	SQLITE_IOERR_RDLOCK = (SQLITE_IOERR or (9 shl 8));
	SQLITE_IOERR_DELETE = (SQLITE_IOERR or (10 shl 8));
	SQLITE_IOERR_BLOCKED = (SQLITE_IOERR or (11 shl 8));
	SQLITE_IOERR_NOMEM = (SQLITE_IOERR or (12 shl 8));
	SQLITE_IOERR_ACCESS = (SQLITE_IOERR or (13 shl 8));
	SQLITE_IOERR_CHECKRESERVEDLOCK = (SQLITE_IOERR or (14 shl 8));
	SQLITE_IOERR_LOCK = (SQLITE_IOERR or (15 shl 8));
	SQLITE_IOERR_CLOSE = (SQLITE_IOERR or (16 shl 8));
	SQLITE_IOERR_DIR_CLOSE = (SQLITE_IOERR or (17 shl 8));
	SQLITE_LOCKED_SHAREDCACHE = (SQLITE_LOCKED or (1 shl 8));

//Device Characteristics
const
	SQLITE_IOCAP_ATOMIC = $00000001;
	SQLITE_IOCAP_ATOMIC512 = $00000002;
	SQLITE_IOCAP_ATOMIC1K = $00000004;
	SQLITE_IOCAP_ATOMIC2K = $00000008;
	SQLITE_IOCAP_ATOMIC4K = $00000010;
	SQLITE_IOCAP_ATOMIC8K = $00000020;
	SQLITE_IOCAP_ATOMIC16K = $00000040;
	SQLITE_IOCAP_ATOMIC32K = $00000080;
	SQLITE_IOCAP_ATOMIC64K = $00000100;
	SQLITE_IOCAP_SAFE_APPEND = $00000200;
	SQLITE_IOCAP_SEQUENTIAL = $00000400;

//Flags for the xAccess VFS method
const
	SQLITE_ACCESS_EXISTS = 0;
	SQLITE_ACCESS_READWRITE = 1;
	SQLITE_ACCESS_READ = 2;

//Authorizer Action Codes
const
	SQLITE_CREATE_INDEX = 1;
	SQLITE_CREATE_TABLE = 2;
	SQLITE_CREATE_TEMP_INDEX = 3;
	SQLITE_CREATE_TEMP_TABLE = 4;
	SQLITE_CREATE_TEMP_TRIGGER = 5;
	SQLITE_CREATE_TEMP_VIEW = 6;
	SQLITE_CREATE_TRIGGER = 7;
	SQLITE_CREATE_VIEW = 8;
	SQLITE_DELETE = 9;
	SQLITE_DROP_INDEX = 10;
	SQLITE_DROP_TABLE = 11;
	SQLITE_DROP_TEMP_INDEX = 12;
	SQLITE_DROP_TEMP_TABLE = 13;
	SQLITE_DROP_TEMP_TRIGGER = 14;
	SQLITE_DROP_TEMP_VIEW = 15;
	SQLITE_DROP_TRIGGER = 16;
	SQLITE_DROP_VIEW = 17;
	SQLITE_INSERT = 18;
	SQLITE_PRAGMA = 19;
	SQLITE_READ = 20;
	SQLITE_SELECT = 21;
	SQLITE_TRANSACTION = 22;
	SQLITE_UPDATE = 23;
	SQLITE_ATTACH = 24;
	SQLITE_DETACH = 25;
	SQLITE_ALTER_TABLE = 26;
	SQLITE_REINDEX = 27;
	SQLITE_ANALYZE = 28;
	SQLITE_CREATE_VTABLE = 29;
	SQLITE_DROP_VTABLE = 30;
	SQLITE_FUNCTION = 31;
	SQLITE_SAVEPOINT = 32;
	SQLITE_COPY = 0; //No longer used

//Authorizer Return Codes
const
	SQLITE_DENY = 1;
	SQLITE_IGNORE = 2;

//Fundamental Datatypes
const
  SQLITE_INTEGER = 1;
  SQLITE_FLOAT = 2;
  SQLITE_BLOB = 4;
  SQLITE_NULL = 5;
  SQLITE_TEXT = 3;
  SQLITE3_TEXT = 3;

//Standard File Control Opcodes
const
	SQLITE_FCNTL_LOCKSTATE = 1;
	SQLITE_GET_LOCKPROXYFILE = 2;
	SQLITE_SET_LOCKPROXYFILE = 3;
	SQLITE_LAST_ERRNO = 4;

//Run-Time Limit Categories
const
	SQLITE_LIMIT_LENGTH = 0;
	SQLITE_LIMIT_SQL_LENGTH = 1;
	SQLITE_LIMIT_COLUMN = 2;
	SQLITE_LIMIT_EXPR_DEPTH = 3;
	SQLITE_LIMIT_COMPOUND_SELECT = 4;
	SQLITE_LIMIT_VDBE_OP = 5;
	SQLITE_LIMIT_FUNCTION_ARG = 6;
	SQLITE_LIMIT_ATTACHED = 7;
	SQLITE_LIMIT_LIKE_PATTERN_LENGTH = 8;
	SQLITE_LIMIT_VARIABLE_NUMBER = 9;

//File Locking Levels
const
  SQLITE_LOCK_NONE = 0;
  SQLITE_LOCK_SHARED = 1;
  SQLITE_LOCK_RESERVED = 2;
  SQLITE_LOCK_PENDING = 3;
  SQLITE_LOCK_EXCLUSIVE = 4;

//Mutex Types
const
	SQLITE_MUTEX_FAST = 0;
	SQLITE_MUTEX_RECURSIVE = 1;
	SQLITE_MUTEX_STATIC_MASTER = 2;
	SQLITE_MUTEX_STATIC_MEM = 3;
	SQLITE_MUTEX_STATIC_MEM2 = 4; // NOT USED
	SQLITE_MUTEX_STATIC_OPEN = 4;
	SQLITE_MUTEX_STATIC_PRNG = 5;
	SQLITE_MUTEX_STATIC_LRU = 6;
	SQLITE_MUTEX_STATIC_LRU2 = 7;

//Flags For File Open Operations
const
	SQLITE_OPEN_READONLY = $00000001;
	SQLITE_OPEN_READWRITE = $00000002;
	SQLITE_OPEN_CREATE = $00000004;
	SQLITE_OPEN_DELETEONCLOSE = $00000008;
	SQLITE_OPEN_EXCLUSIVE = $00000010;
	SQLITE_OPEN_MAIN_DB = $00000100;
	SQLITE_OPEN_TEMP_DB = $00000200;
	SQLITE_OPEN_TRANSIENT_DB = $00000400;
	SQLITE_OPEN_MAIN_JOURNAL = $00000800;
	SQLITE_OPEN_TEMP_JOURNAL = $00001000;
	SQLITE_OPEN_SUBJOURNAL = $00002000;
	SQLITE_OPEN_MASTER_JOURNAL = $00004000;
	SQLITE_OPEN_NOMUTEX = $00008000;
	SQLITE_OPEN_FULLMUTEX = $00010000;

//Constants Defining Special Destructor Behavior
const
  SQLITE_STATIC = sqlite3_destructor_type(0);
  SQLITE_TRANSIENT = sqlite3_destructor_type(-1);

//Synchronization Type Flags
const
	SQLITE_SYNC_NORMAL = $00002;
	SQLITE_SYNC_FULL = $00003;
	SQLITE_SYNC_DATAONLY = $00010;

//Text Encodings
const
	SQLITE_UTF8 = 1;
	SQLITE_UTF16LE = 2;
	SQLITE_UTF16BE = 3;
	SQLITE_UTF16 = 4;
	SQLITE_ANY = 5;
	SQLITE_UTF16_ALIGNED = 8;

type
  TPAnsiCharArray = array[0..(MaxLongint div sizeOf(PAnsiChar)) - 1] of PAnsiChar;
  PPAnsiCharArray = ^TPAnsiCharArray;

function sqlite3_auto_extension(xEntryPoint: Pointer): Integer; cdecl; external sqlitedll;
procedure sqlite3_reset_auto_extension;  cdecl; external sqlitedll;

function sqlite3_bind_blob(stmt: sqlite3_stmt; paramindex: Integer; value: sqlite3_blob; N: Integer; freeProc: TSQLiteFreeCallback): Integer;  cdecl; external sqlitedll;
function sqlite3_bind_double(stmt: sqlite3_stmt; paramindex: Integer; value: Double): Integer;  cdecl; external sqlitedll;
function sqlite3_bind_int(stmt: sqlite3_stmt; paramindex: Integer; value: Integer): Integer;  cdecl; external sqlitedll;
function sqlite3_bind_int64(stmt: sqlite3_stmt; paramindex: Integer; value: sqlite3_int64): Integer;  cdecl; external sqlitedll;
function sqlite3_bind_null(stmt: sqlite3_stmt; paramindex: Integer): Integer;  cdecl; external sqlitedll;
function sqlite3_bind_text(stmt: sqlite3_stmt; paramindex: Integer; value: PAnsiChar; N: Integer; freeProc: TSQLiteFreeCallback): Integer;  cdecl; external sqlitedll;
function sqlite3_bind_text16(stmt: sqlite3_stmt; paramindex: Integer; value: PWideChar; N: Integer; freeProc: TSQLiteFreeCallback): Integer;  cdecl; external sqlitedll;
function sqlite3_bind_zeroblob(stmt: sqlite3_stmt; paramindex: Integer; N: Integer): Integer; cdecl; external sqlitedll;
function sqlite3_bind_value(stmt: sqlite3_stmt; paramindex: Integer; value: sqlite3_value): Integer; cdecl; external sqlitedll;

function sqlite3_bind_parameter_count(stmt: sqlite3_stmt): Integer; cdecl; external sqlitedll;
function sqlite3_bind_parameter_index(stmt: sqlite3_stmt; name: PAnsiChar): Integer; cdecl; external sqlitedll;
function sqlite3_bind_parameter_name(stmt: sqlite3_stmt; index: integer): PAnsiChar; cdecl; external sqlitedll;

function sqlite3_blob_bytes(blob: sqlite3_blob): Integer; cdecl; external sqlitedll;
function sqlite3_blob_close(blob: sqlite3_blob): Integer; cdecl; external sqlitedll;
function sqlite3_blob_open(db: sqlite3; zDB: PAnsiChar; zTable: PAnsiChar; zColumn: PAnsiChar; iRow: sqlite3_int64; flags: Integer; blob: sqlite3_blob): Integer; cdecl; external sqlitedll;
function sqlite3_blob_read(blob: sqlite3_blob; Z: Pointer; N: Integer; iOffset: Integer): Integer; cdecl; external sqlitedll;
function sqlite3_blob_write(blob: sqlite3_blob; const Z: Pointer; N: Integer; iOffset: Integer): Integer; cdecl; external sqlitedll;

function sqlite3_busy_handler(db: sqlite3; handler: TSQLiteBusyHandlerCallback; data: Pointer): integer; cdecl; external sqlitedll;
function sqlite3_busy_timeout(db: sqlite3; timems: Integer): integer; cdecl; external sqlitedll;

function sqlite3_changes(db: sqlite3): Integer; cdecl; external sqlitedll;
function sqlite3_total_changes(db: sqlite3): Integer; cdecl; external sqlitedll;

function sqlite3_clear_bindings(db: sqlite3): Integer; cdecl; external sqlitedll;

function sqlite3_close(db: sqlite3): integer; cdecl; external sqlitedll;

{function sqlite3_collation_needed(db: sqlite3; data: Pointer; callback: CollationNeededCallback): integer; cdecl; external sqlitedll;
function sqlite3_collation_needed16(db: sqlite3; data: Pointer; callback: CollationNeeded16Callback): integer; cdecl; external sqlitedll;
 }

function sqlite3_create_collation(db: sqlite3; zName: PAnsiChar; eTextRep: Integer; data: Pointer; Callback: TSQLitexCompareCallback): Integer; cdecl; external sqlitedll;
function sqlite3_create_collation16(db: sqlite3; zName: PWideChar; eTextRep: Integer; data: Pointer; Callback: TSQLitexCompareCallback): Integer; cdecl; external sqlitedll;
function sqlite3_create_collation_v2(db: sqlite3; zName: PAnsiChar; eTextRep: Integer; data: Pointer; Callback: TSQLitexCompareCallback; DestroyCallback: TSQLitexDestroyCallback): Integer; cdecl; external sqlitedll;

function sqlite3_column_blob(stmt: sqlite3_stmt; col: integer): pointer; cdecl; external sqlitedll;
function sqlite3_column_double(stmt: sqlite3_stmt; col: integer): double; cdecl; external sqlitedll;
function sqlite3_column_int(stmt: sqlite3_stmt; col: integer): integer; cdecl; external sqlitedll;
function sqlite3_column_int64(stmt: sqlite3_stmt; col: integer): sqlite3_int64; cdecl; external sqlitedll;
function sqlite3_column_text(stmt: sqlite3_stmt; col: integer): PAnsiChar; cdecl; external sqlitedll;
function sqlite3_column_text16(stmt: sqlite3_stmt; col: integer): PWideChar; cdecl; external sqlitedll;
function sqlite3_column_value(stmt: sqlite3_stmt; col: integer): sqlite3_value; cdecl; external sqlitedll;

function sqlite3_column_name(stmt: sqlite3_stmt; ColNum: integer): PAnsiChar; cdecl; external sqlitedll;
function sqlite3_column_name16(stmt: sqlite3_stmt; ColNum: integer): PWideChar; cdecl; external sqlitedll;

function sqlite3_column_count(stmt: sqlite3_stmt): integer; cdecl; external sqlitedll;

function sqlite3_column_bytes(stmt: sqlite3_stmt; col: integer): integer; cdecl; external sqlitedll;
function sqlite3_column_bytes16(stmt: sqlite3_stmt; col: integer): integer; cdecl; external sqlitedll;

function sqlite3_column_type(stmt: sqlite3_stmt; col: integer): integer; cdecl; external sqlitedll;

function sqlite3_column_database_name(stmt: sqlite3_stmt; col: integer): PAnsiChar; cdecl; external sqlitedll;
function sqlite3_column_database_name16(stmt: sqlite3_stmt; col: integer): PWideChar; cdecl; external sqlitedll;

function sqlite3_column_table_name(stmt: sqlite3_stmt; col: integer): PAnsiChar; cdecl; external sqlitedll;
function sqlite3_column_table_name16(stmt: sqlite3_stmt; col: integer): PWideChar; cdecl; external sqlitedll;

function sqlite3_column_origin_name(stmt: sqlite3_stmt; col: integer): PAnsiChar; cdecl; external sqlitedll;
function sqlite3_column_origin_name16(stmt: sqlite3_stmt; col: integer): PWideChar; cdecl; external sqlitedll;

function sqlite3_column_decltype(stmt: sqlite3_stmt; col: integer): PAnsiChar; cdecl; external sqlitedll;
function sqlite3_column_decltype16(stmt: sqlite3_stmt; col: integer): PWideChar; cdecl; external sqlitedll;

function sqlite3_complete(SQL: PAnsiChar): PAnsiChar; cdecl; external sqlitedll;
function sqlite3_complete16(SQL: PWideChar): PWideChar; cdecl; external sqlitedll;

function sqlite3_context_db_handle(context: sqlite3_context): sqlite3; cdecl; external sqlitedll;

function sqlite3_create_function(db: sqlite3; zFunctionName: PAnsiChar; nArg: Integer; nTextRep: Integer; pApp: Pointer; xFunc: TSQLitexFuncCallback; xStep: TSQLitexStepCallback; xFinal: TSQLitexFinalCallback): Integer; cdecl; external sqlitedll;
function sqlite3_create_function16(db: sqlite3; zFunctionName: PWideChar; nArg: Integer; nTextRep: Integer; pApp: Pointer; xFunc: TSQLitexFuncCallback; xStep: TSQLitexStepCallback; xFinal: TSQLitexFinalCallback): Integer; cdecl; external sqlitedll;

function sqlite3_data_count(stmt: sqlite3_stmt): Integer; cdecl; external sqlitedll;

function sqlite3_db_handle(stmt: sqlite3_stmt): sqlite3; cdecl; external sqlitedll;

function sqlite3_db_mutex(db: sqlite3): sqlite3_mutex; cdecl; external sqlitedll;

function sqlite3_enable_load_extension(db: sqlite3; onoff: integer): integer; cdecl; external sqlitedll;

function sqlite3_enable_shared_cache(onoff: integer): integer; cdecl; external sqlitedll;

function sqlite3_errcode(db: sqlite3): integer; cdecl; external sqlitedll;
function sqlite3_extended_errcode(db: sqlite3): integer; cdecl; external sqlitedll;
function sqlite3_errmsg(db: sqlite3): PAnsiChar; cdecl; external sqlitedll;
function sqlite3_errmsg16(db: sqlite3): PWideChar; cdecl; external sqlitedll;

function sqlite3_exec(db: sqlite3; const sql: PAnsiChar; callback: TSQLiteExecCallback; userdata: PAnsiChar; var errmsg: PAnsiChar): integer; cdecl; external sqlitedll;

function sqlite3_extended_result_codes(db: sqlite3; onoff: Integer): Integer; cdecl; external sqlitedll;

function sqlite3_finalize(stmt: sqlite3_stmt): integer; cdecl; external sqlitedll;

function sqlite3_malloc(N: integer): Pointer; cdecl; external sqlitedll;
function sqlite3_realloc(P: Pointer; N: integer): Pointer; cdecl; external sqlitedll;
procedure sqlite3_free(P: Pointer); cdecl; external sqlitedll;

function sqlite3_get_table(db: sqlite3; sql: PAnsiChar; var result: PPAnsiCharArray; var RowCount: Cardinal; var ColCount: Cardinal; var errmsg: PAnsiChar): integer; cdecl; external sqlitedll;
procedure sqlite3_free_table(table: PPAnsiCharArray); cdecl; external sqlitedll;

procedure sqlite3_interrupt(db: sqlite3); cdecl; external sqlitedll;

function sqlite3_last_insert_rowid(db: sqlite3): int64; cdecl; external sqlitedll;

function sqlite3_libversion: PAnsiChar; cdecl; external sqlitedll;
function sqlite3_libversion_number: Integer; cdecl; external sqlitedll;

function sqlite3_limit(db: sqlite3; id: integer; newVal: integer): integer; cdecl; external sqlitedll;

function sqlite3_next_stmt(db: sqlite3; stmt: sqlite3_stmt): sqlite3_stmt; cdecl; external sqlitedll;

function sqlite3_memory_used: sqlite3_int64; cdecl; external sqlitedll;
function sqlite3_memory_highwater(resetFlag: integer): sqlite3_int64; cdecl; external sqlitedll;

function sqlite3_mutex_alloc(kind: Integer): sqlite3_mutex; cdecl; external sqlitedll;
procedure sqlite3_mutex_free(mutex: sqlite3_mutex); cdecl; external sqlitedll;
procedure sqlite3_mutex_enter(mutex: sqlite3_mutex); cdecl; external sqlitedll;
function sqlite3_mutex_try(mutex: sqlite3_mutex): Integer; cdecl; external sqlitedll;
procedure sqlite3_mutex_leave(mutex: sqlite3_mutex); cdecl; external sqlitedll;

function sqlite3_open(filename: PAnsiChar; var db: sqlite3): integer; cdecl; external sqlitedll;
function sqlite3_open16(filename: PWideChar; var db: sqlite3): integer; cdecl; external sqlitedll;
function sqlite3_open16_v2(filename: PAnsiChar; var db: sqlite3; flags: integer; zVfs: PAnsiChar): integer; cdecl; external sqlitedll;

function sqlite3_prepare(db: sqlite3; sql: PAnsiChar; N: integer; var stmt: sqlite3_stmt; var ztail: PAnsiChar): integer; cdecl; external sqlitedll;
function sqlite3_prepare_v2(db: sqlite3; sql: PAnsiChar; N: integer; var stmt: sqlite3_stmt; var ztail: PAnsiChar): integer; cdecl; external sqlitedll;
function sqlite3_prepare16(db: sqlite3; sql: PWideChar; N: integer; var stmt: sqlite3_stmt; var ztail: PWideChar): integer; cdecl; external sqlitedll;
function sqlite3_prepare16_v2(db: sqlite3; sql: PWideChar; N: integer; var stmt: sqlite3_stmt; var ztail: PWideChar): integer; cdecl; external sqlitedll;

function sqlite3_progress_handler(db: sqlite3; interval: integer; callback: TSQLiteProgressCallback; data: Pointer): integer; cdecl; external sqlitedll;

procedure sqlite3_randomness(N: Integer; P: Pointer); cdecl; external sqlitedll;

function sqlite3_release_memory(N: Integer): Integer; cdecl; external sqlitedll;

function sqlite3_reset(stmt: sqlite3_stmt): integer; cdecl; external sqlitedll;

procedure sqlite3_result_blob(context: sqlite3_context; value: Pointer; N: Integer; freeProc: TSQLiteFreeCallback); cdecl; external sqlitedll;
procedure sqlite3_result_double(context: sqlite3_context; value: Double); cdecl; external sqlitedll;
procedure sqlite3_result_text(context: sqlite3_context; value: PAnsiChar; N: Integer; freeProc: TSQLiteFreeCallback); cdecl; external sqlitedll;
procedure sqlite3_result_text16(context: sqlite3_context; value: PWideChar; N: Integer; freeProc: TSQLiteFreeCallback); cdecl; external sqlitedll;
procedure sqlite3_result_text16le(context: sqlite3_context; value: PWideChar; N: Integer; freeProc: TSQLiteFreeCallback); cdecl; external sqlitedll;
procedure sqlite3_result_text16be(context: sqlite3_context; value: PWideChar; N: Integer; freeProc: TSQLiteFreeCallback); cdecl; external sqlitedll;
procedure sqlite3_result_error(context: sqlite3_context; value: PAnsiChar; N: Integer); cdecl; external sqlitedll;
procedure sqlite3_result_error16(context: sqlite3_context; value: PWideChar; N: Integer); cdecl; external sqlitedll;
procedure sqlite3_result_error_toobig(context: sqlite3_context); cdecl; external sqlitedll;
procedure sqlite3_result_error_nomem(context: sqlite3_context); cdecl; external sqlitedll;
procedure sqlite3_result_error_code(context: sqlite3_context; errorcode: integer); cdecl; external sqlitedll;
procedure sqlite3_result_int(context: sqlite3_context; value: integer); cdecl; external sqlitedll;
procedure sqlite3_result_int64(context: sqlite3_context; value: sqlite3_int64); cdecl; external sqlitedll;
procedure sqlite3_result_null(context: sqlite3_context); cdecl; external sqlitedll;
procedure sqlite3_result_zeroblob(context: sqlite3_context; N: Integer); cdecl; external sqlitedll;
procedure sqlite3_result_value(context: sqlite3_context; value: sqlite3_value); cdecl; external sqlitedll;

procedure sqlite3_commit_hook(db: sqlite3; callback: TSQLiteHookCallback; data: Pointer); cdecl; external sqlitedll;
procedure sqlite3_rollback_hook(db: sqlite3; callback: TSQLiteHookCallback; data: Pointer); cdecl; external sqlitedll;

function sqlite3_set_authorizer(db: sqlite3; callback: TSQLiteAuthorizerCallback; data: Pointer): integer; cdecl; external sqlitedll;

function sqlite3_sleep(ms: integer): integer; cdecl; external sqlitedll;

procedure sqlite3_soft_heap_limit(limit: integer); cdecl; external sqlitedll;

function sqlite3_sql(stmt: sqlite3_stmt): PAnsiChar; cdecl; external sqlitedll;

function sqlite3_step(stmt: sqlite3_stmt): integer; cdecl; external sqlitedll;

function sqlite3_value_blob(value: sqlite3_value): pointer; cdecl; external sqlitedll;
function sqlite3_value_double(value: sqlite3_value): double; cdecl; external sqlitedll;
function sqlite3_value_int(value: sqlite3_value): integer; cdecl; external sqlitedll;
function sqlite3_value_int64(value: sqlite3_value): sqlite3_int64; cdecl; external sqlitedll;
function sqlite3_value_text(value: sqlite3_value): PAnsiChar; cdecl; external sqlitedll;
function sqlite3_value_text16(value: sqlite3_value): PWideChar; cdecl; external sqlitedll;
function sqlite3_value_text16le(value: sqlite3_value): PWideChar; cdecl; external sqlitedll;
function sqlite3_value_text16be(value: sqlite3_value): PWideChar; cdecl; external sqlitedll;

function sqlite3_value_bytes(value: sqlite3_value): integer; cdecl; external sqlitedll;
function sqlite3_value_bytes16(value: sqlite3_value): integer; cdecl; external sqlitedll;

function sqlite3_value_type(value: sqlite3_value): integer; cdecl; external sqlitedll;
function sqlite3_value_numeric_type(value: sqlite3_value): integer; cdecl; external sqlitedll;

function sqlite3_user_data(context: sqlite3_context): Pointer; cdecl; external sqlitedll;

implementation

end.

