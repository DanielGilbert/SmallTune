{*******************************************************}
{                                                       }
{       SQLite Database Wrapper                         }
{                                                       }
{       Copyright (C) 2009 Frederic Heihoff             }
{                                                       }
{       Version 1.0                                     }
{                                                       }
{*******************************************************}

unit SQLiteDatabase;

interface

{$DEFINE NONVCL}
      
uses SQLite3dll {$IFNDEF NONVCL}, SysUtils, Classes{$ENDIF};

const
  SQLITE_FUNCTION_ERROR = 70;
  {$IFDEF UNICODE}
    SQLITE_ENCODING = SQLITE_UTF16;
  {$ELSE}
    SQLITE_ENCODING = SQLITE_UTF8;
  {$ENDIF}
  
type
{$IFDEF NONVCL}
  TSeekOrigin = (soBeginning, soCurrent,soEnd);
  TStream = class
    private     
      function GetPosition: Int64;
      procedure SetPosition(Value: Int64);
    protected
      function GetSize: Int64; virtual; abstract;
      procedure SetSize(const NewSize: Int64); virtual; abstract;
    public
      property Size: Int64 read GetSize write SetSize;
      property Position: Int64 read GetPosition write SetPosition;
      function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual; abstract;
      function Write(const Buffer; Count: Longint): Longint; virtual; abstract;
      function Read(var Buffer; Count: Longint): Longint; virtual; abstract;
  end;
{$ENDIF}
{$IFNDEF NONVCL}
  ESQLiteException = class(Exception);
{$ENDIF}

  TSQLiteDatabase = class;
  TSQLiteStatement = class;
  TSQLiteQuery = class;
  TSQLiteBlobStream = class;
  TSQLiteType = (stInteger = SQLITE_INTEGER, stDouble = SQLITE_FLOAT, stString = SQLITE3_TEXT, stBlob = SQLITE_BLOB, stNull = SQLITE_NULL);
  TSQLiteAction = (saCreateIndex = SQLITE_CREATE_INDEX, saCreateTable = SQLITE_CREATE_TABLE, saCreateTempIndex = SQLITE_CREATE_TEMP_INDEX, saCreateTempTable = SQLITE_CREATE_TEMP_TABLE,
                   saCreateTempTrigger = SQLITE_CREATE_TEMP_TRIGGER, saCreateTempView = SQLITE_CREATE_TEMP_VIEW, saDelete = SQLITE_DELETE, saDropIndex = SQLITE_DROP_INDEX,
                   saDropTable = SQLITE_DROP_TABLE, saDropTempIndex = SQLITE_DROP_TEMP_INDEX, saDropTempTable = SQLITE_DROP_TEMP_TABLE, saDropTempTrigger = SQLITE_DROP_TEMP_TRIGGER,
                   saDropTempView = SQLITE_DROP_TEMP_VIEW, saDropTrigger = SQLITE_DROP_TRIGGER, saDropView = SQLITE_DROP_VIEW, saInsert = SQLITE_INSERT, saPragma = SQLITE_PRAGMA, 
                   saRead = SQLITE_READ, saSelect = SQLITE_SELECT, saTransaction = SQLITE_TRANSACTION, saUpdate = SQLITE_UPDATE, saAttach = SQLITE_ATTACH, saDetach = SQLITE_DETACH,
                   saAlterTable = SQLITE_ALTER_TABLE, saReIndex = SQLITE_REINDEX, saAnalyze = SQLITE_ANALYZE, saCreateVTable = SQLITE_CREATE_VTABLE, saDropVTable = SQLITE_DROP_VTABLE, 
                   saFunction = SQLITE_FUNCTION, saSavePoint = SQLITE_FUNCTION_ERROR);
  TSQLiteLimit = (slFieldLength = SQLITE_LIMIT_LENGTH, slSQLLength = SQLITE_LIMIT_SQL_LENGTH, slColumnCount = SQLITE_LIMIT_COLUMN, slExpressionDepth = SQLITE_LIMIT_EXPR_DEPTH, slCompoundSelect = SQLITE_LIMIT_COMPOUND_SELECT, slVDBEOperations = SQLITE_LIMIT_VDBE_OP, slFunctionArgCount = SQLITE_LIMIT_FUNCTION_ARG, slAttchmentCount = SQLITE_LIMIT_ATTACHED, slLikePatternLength =  SQLITE_LIMIT_LIKE_PATTERN_LENGTH, slBindingNumber = SQLITE_LIMIT_VARIABLE_NUMBER);
  TSQLiteVariant = class
    private
      fValue: sqlite3_value;
      fDB: TSQLiteDatabase;
      function GetValueType: TSQLiteType;
      function GetAsString: String;
      function GetAsDouble: Double;
      function GetAsInteger: Integer;
      function GetAsInt64: Int64;
      function GetAsBoolean: Boolean;
      function GetAsBlobStream: TSQLiteBlobStream;
    public
      property AsString: String read GetAsString;
      property AsDouble: Double read GetAsDouble;
      property AsInteger: Integer read GetAsInteger;
      property AsBoolean: Boolean read GetAsBoolean;
      property AsInt64: Int64 read GetAsInt64;
      property AsBlobStream: TSQLiteBlobStream read GetAsBlobStream;
      property ValueType: TSQLiteType read GetValueType;
      constructor Create(aDB: TSQLiteDatabase; aValue: sqlite3_value);
  end;
  TSQLiteColumn = class
    private
      fQuery: TSQLiteQuery;
      fPosition: Integer;
      function GetName: String;
      function GetAsString: String;
      function GetAsDouble: Double;
      function GetAsInteger: Integer;
      function GetAsInt64: Int64;
      function GetAsVariant: TSQLiteVariant;
      function GetColumnType: TSQLiteType;
      function GetAsBoolean: Boolean;
      function GetAsBlobStream: TSQLiteBlobStream;
    public
      property Name: String read GetName;
      property AsString: String read GetAsString;
      property AsDouble: Double read GetAsDouble;
      property AsInteger: Integer read GetAsInteger;
      property AsInt64: Int64 read GetAsInt64;
      property AsBoolean: Boolean read GetAsBoolean;
      property AsVariant: TSQLiteVariant read GetAsVariant;
      property AsBlobStream: TSQLiteBlobStream read GetAsBlobStream;
      property ColumnType: TSQLiteType read GetColumnType;
      constructor Create(aQuery: TSQLiteQuery; aPosition: Integer);
  end;
  TSQLiteBlobStream = class(TStream)
    private
      fInDLL: Boolean;
      fPointer: Pointer;
      fSize: Int64;
      fOffset: Int64;
    protected
      function GetSize: Int64; override; 
      procedure SetSize(const NewSize: Int64); override; 
    public
      function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
      function Write(const Buffer; Count: Longint): Longint; override;
      function Read(var Buffer; Count: Longint): Longint; override;
      constructor Create(aPointer: Pointer; aSize: Int64; aInDLL: Boolean);
      destructor Destroy; override;
  end;
  TSQLiteBinding = class
    private
      fPosition: Integer;
      fStatement: TSQLiteStatement;
      fFreeSelf: Boolean;
      procedure SetAsString(Value: String);
      procedure SetAsInteger(Value: Integer);
      procedure SetAsInt64(Value: Int64);
      procedure SetAsDouble(Value: Double);
      procedure SetAsVariant(Value: TSQLiteVariant);
      procedure SetAsBlobStream(Value: TSQLiteBlobStream);
      procedure SetAsBoolean(Value: Boolean);
    public
      property AsString: string write SetAsString;
      property AsInteger: Integer write SetAsInteger;
      property AsInt64: Int64 write SetAsInt64;
      property AsDouble: Double write SetAsDouble;
      property AsVariant: TSQLiteVariant write SetAsVariant;
      property AsBlobStream: TSQLiteBlobStream write SetAsBlobStream;
      property AsBoolean: Boolean write SetAsBoolean;
      procedure SetToNull;
      procedure SetToZeroblob(ByteCount: Integer);
      constructor Create(aStatement: TSQLiteStatement; aPosition: Integer; aFreeSelf: Boolean);
  end;
  TSQLiteStatement = class
    private
      fStatement: sqlite3_stmt;
      fDB: TSQLiteDatabase;
      function GetBindingByName(Name: AnsiString): TSQLiteBinding;
      function GetBinding(Index: Integer): TSQLiteBinding;
      function GetBindingCount: Integer;
    public
      procedure Reset;
      constructor Create(aDB: TSQLiteDatabase; aSQL: String); virtual;
      destructor Destroy; override;
      property BindingCount: Integer read GetBindingCount;
      property Binding[Index: Integer]: TSQLiteBinding read GetBinding;
      property BindingByName[Name: AnsiString]: TSQLiteBinding read GetBindingByName;
  end;
  TSQLiteQuery = class(TSQLiteStatement)
    private
      fColumns: array of TSQLiteColumn;
      fColumnCount: Integer;
      fEOF: Boolean;
      function GetColumn(Index: Integer): TSQLiteColumn;
      function GetColumnByName(Name: String): TSQLiteColumn;
    public
      constructor Create(aDB: TSQLiteDatabase; aSQL: String); override;
      destructor Destroy; override;
      function Next: Boolean;
      property ColumnCount: Integer read fColumnCount;
      property ColumnByName[Name: String]: TSQLiteColumn read GetColumnByName;
      property Column[Index: Integer]: TSQLiteColumn read GetColumn; default;
      property EOF: Boolean read fEOF;
  end;
  TSQLiteCommand = class(TSQLiteStatement)
    private
      fChangeCount: Integer;
      fTotalChangeCount: Integer;
      fInsertID: Integer;
    public
      property ChangeCount: Integer read fChangeCount;
      property TotalChangeCount: Integer read fTotalChangeCount;
      property InsertID: Integer read fInsertID;
      procedure Execute;
  end;
  TSQLiteNativeBlobStream = class(TStream)
    private
      fBlob: sqlite3_blob;
      fDBName: AnsiString;
      fTableName: AnsiString;
      fColumnName: AnsiString;
      fRow: Int64;
      fReadOnly: Boolean;
      fDB: TSQLiteDatabase;
      fOffset: Integer;
    protected
      function GetSize: Int64; override; 
      procedure SetSize(const NewSize: Int64); override;
    public
      constructor Create(aDB: TSqliteDatabase; aDBName, aTableName, aColumName: AnsiString; aRow: Int64; aReadOnly: Boolean);
      destructor Destroy; override;
      procedure RefreshHandle;
      function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
      function Write(const Buffer; Count: Longint): Longint; override;
      function Read(var Buffer; Count: Longint): Longint; override;
  end;
  TSQLiteResult = class
    private
      fContext: sqlite3_context;
      fDB: TSQLiteDatabase;
      procedure SetAsString(Value: String);
      procedure SetAsInteger(Value: Integer);
      procedure SetAsInt64(Value: Int64);
      procedure SetAsDouble(Value: Double);
      procedure SetAsVariant(Value: TSQLiteVariant);
      procedure SetAsBlobStream(Value: TSQLiteBlobStream);
      procedure SetAsBoolean(Value: Boolean);
    public
      property AsString: string write SetAsString;
      property AsInteger: Integer write SetAsInteger;
      property AsInt64: Int64 write SetAsInt64;
      property AsDouble: Double write SetAsDouble;
      property AsVariant: TSQLiteVariant write SetAsVariant;
      property AsBlobStream: TSQLiteBlobStream write SetAsBlobStream;
      property AsBoolean: Boolean write SetAsBoolean;
      procedure SetToNull;
      procedure SetToZeroblob(ByteCount: Integer);
      procedure RaiseError(ErrorMessage: String);
      constructor Create(aDB: TSQLiteDatabase; aContext: sqlite3_context);
  end;
  TSQLiteCollationEvent = function(DB: TSQLiteDatabase; Str1, Str2: String): Integer of object;
  TSQLiteCollationCallback = function(DB: TSQLiteDatabase; Str1, Str2: String): Integer;
  PSQLiteCollation = ^TSQLiteCollation;
  TSQLiteCollation = record
    DB: TSQLiteDatabase;
    Event: TSQLiteCollationEvent;
    Callback: TSQLiteCollationCallback;
  end;
  TSQLiteAggregateData = class
  end;
  TSQLiteAggregateDataClass = class of TSQLiteAggregateData;
  TSQLiteAggregateStepEvent = procedure(DB: TSQLiteDatabase; Data: TSQLiteAggregateData; Args: array of TSQLiteVariant) of object;
  TSQLiteAggregateResultEvent = procedure(DB: TSQLiteDatabase; Data: TSQLiteAggregateData; Result: TSQLiteResult) of object;
  TSQLiteAggregateStepCallback = procedure(DB: TSQLiteDatabase; Data: TSQLiteAggregateData; Args: array of TSQLiteVariant);
  TSQLiteAggregateResultCallback = procedure(DB: TSQLiteDatabase; Data: TSQLiteAggregateData; Result: TSQLiteResult);
  PSQLiteAggregate = ^TSQLIteAggregate;
  TSQLiteAggregate = record
    Data: TSQLiteAggregateData;
    DB: TSQLiteDatabase;
    StepEvent: TSQLiteAggregateStepEvent;
    ResultEvent: TSQLiteAggregateResultEvent;
    StepCallback: TSQLiteAggregateStepCallback;
    ResultCallback: TSQLiteAggregateResultCallback;
  end;
  TSQLiteFunctionEvent = procedure(DB: TSQLiteDatabase; Result: TSQLiteResult; Args: array of TSQLiteVariant) of object;
  TSQLiteFunctionCallback = procedure(DB: TSQLiteDatabase; Result: TSQLiteResult; Args: array of TSQLiteVariant);
  PSQLiteFunction = ^TSQLiteFunction;
  TSQLiteFunction = record
    DB: TSQLiteDatabase;
    Event: TSQLiteFunctionEvent;
    Callback: TSQLiteFunctionCallback;
  end;
  TSQLiteProgressEvent = procedure(var Interrupt: Boolean) of object;
  TSQLiteAuthorization = (saAllow = 0, saIgnore = SQLITE_IGNORE, saDeny = SQLITE_Deny);
  TSQLiteAuthorizationEvent = procedure(var Allow: TSQLiteAuthorization; Action: TSQLiteAction; Info1, info2, DBName, InnerMostObject: AnsiString) of object;
  TSQLiteErrorEvent = procedure(ErrorMessage: String);
  TSQLiteDatabase = class
    private
      fDB: sqlite3;
      fDatabasePath: string;
      fConnected: Boolean;
      fProgressFrequency: Integer;
      fFunctions: array of PSQLiteFunction;
      fAggregates: array of PSQLiteAggregate;
      fCollations: array of PSQLiteCollation;
      fResultError: string;
      fMutex: sqlite3_mutex;
      fOnAuthorization: TSQLiteAuthorizationEvent;
      fOnProgress: TSQLiteProgressEvent;
      fOnError: TSQLiteErrorEvent; 
      procedure SetOnAuthorization(Value: TSQLiteAuthorizationEvent);
      procedure RaiseSqliteError;
      procedure RaiseError(Text: String);
      procedure SetProgressFrequency(Value: Integer);
      procedure SetOnProgress(Value: TSQLiteProgressEvent);
      procedure SetLimit(Index: TSQLiteLimit; Value: Integer);
    public
      procedure AddFunction(aName: String; aArgCount: Integer; aEventHandler: TSQLiteFunctionEvent); overload;
      procedure AddFunction(aName: String; aArgCount: Integer; aCallback: TSQLiteFunctionCallback); overload;
      procedure AddAggregate(aName: string; aArgCount: Integer; aDataClass: TSQLiteAggregateDataClass; aStepEvent: TSQLiteAggregateStepEvent; aResultEvent: TSQLiteAggregateResultEvent); overload;
      procedure AddAggregate(aName: string; aArgCount: Integer; aDataClass: TSQLiteAggregateDataClass; aStepCallback: TSQLiteAggregateStepCallback; aResultCallback: TSQLiteAggregateResultCallback); overload;
      procedure AddCollation(aName: string; aEventHandler: TSQLiteCollationEvent); overload;
      procedure AddCollation(aName: string; aCallback: TSQLiteCollationCallback); overload;
      function GetNativeBlobStream(aDBName, aTableName, aColumName: AnsiString; aRow: Int64; aReadOnly: Boolean): TSQLiteNativeBlobStream;
      function CreateNewBlobStream: TSQLiteBlobStream;
      function Query(SQL: String): TSQLiteQuery;
      function Command(SQL: String): TSQLiteCommand;
      procedure Execute(SQL: String);
      {$IFNDEF NONVCL}function Statement(SQL: String): TSQLiteStatement;{$ENDIF}
      procedure EnterCriticalSection;
      procedure LeaveCriticalSection;
      property FilePath: String read fDatabasePath;
      property Limit[Category: TSQLiteLimit]: Integer write SetLimit;
      property Connected: Boolean read fConnected default true;
      property OnAuthorization: TSQLiteAuthorizationEvent read fOnAuthorization write SetOnAuthorization;
      property OnProgress: TSQLiteProgressEvent read fOnProgress write SetOnProgress;       
      property OnError: TSQLiteErrorEvent read fOnError write fOnError;
      property ProgressFrequency: Integer read fProgressFrequency write SetProgressFrequency;
      procedure Connect(FilePath: String);
      procedure Disconnect;
      constructor Create; overload;
      constructor Create(FilePath: String); overload;
      destructor Destroy; override;
  end;

procedure XFunc(context: sqlite3_context; argc: Integer; argv: sqlite3_values); cdecl;
procedure XStep(context: sqlite3_context; argc: Integer; argv: sqlite3_values); cdecl;
procedure XFinal(context: sqlite3_context); cdecl;
function XCompare(data: Pointer; N1: Integer; Str1: PChar; N2: Integer; Str2: PChar): Integer; cdecl;
function XAuthorize(Data: Pointer; actioncode: integer; add1,add2,add3,add4: PAnsiChar): Integer; cdecl;
function XProgress(Data: Pointer): Integer; cdecl;

implementation

{$IFDEF NONVCL}

function TStream.GetPosition: Int64;
begin
  result := Seek(0, soCurrent);
end;

procedure TStream.SetPosition(Value: Int64);
begin
  Seek(Value, soBeginning);
end;

// Copied from VCL
procedure CvtInt;
{ IN:
    EAX:  The integer value to be converted to text
    ESI:  Ptr to the right-hand side of the output buffer:  LEA ESI, StrBuf[16]
    ECX:  Base for conversion: 0 for signed decimal, 10 or 16 for unsigned
    EDX:  Precision: zero padded minimum field width
  OUT:
    ESI:  Ptr to start of converted text (not start of buffer)
    ECX:  Length of converted text
}
asm
        OR      CL,CL
        JNZ     @CvtLoop
@C1:    OR      EAX,EAX
        JNS     @C2
        NEG     EAX
        CALL    @C2
        MOV     AL,'-'
        INC     ECX
        DEC     ESI
        MOV     [ESI],AL
        RET
@C2:    MOV     ECX,10

@CvtLoop:
        PUSH    EDX
        PUSH    ESI
@D1:    XOR     EDX,EDX
        DIV     ECX
        DEC     ESI
        ADD     DL,'0'
        CMP     DL,'0'+10
        JB      @D2
        ADD     DL,('A'-'0')-10
@D2:    MOV     [ESI],DL
        OR      EAX,EAX
        JNE     @D1
        POP     ECX
        POP     EDX
        SUB     ECX,ESI
        SUB     EDX,ECX
        JBE     @D5
        ADD     ECX,EDX
        MOV     AL,'0'
        SUB     ESI,EDX
        JMP     @z
@zloop: MOV     [ESI+EDX],AL
@z:     DEC     EDX
        JNZ     @zloop
        MOV     [ESI],AL
@D5:
end;

function IntToStr(Value: Integer): string;
//  FmtStr(Result, '%d', [Value]);
asm
        PUSH    ESI
        MOV     ESI, ESP
        SUB     ESP, 16
        XOR     ECX, ECX       // base: 0 for signed decimal
        PUSH    EDX            // result ptr
        XOR     EDX, EDX       // zero filled field width: 0 for no leading zeros
        CALL    CvtInt
        MOV     EDX, ESI
        POP     EAX            // result ptr
{$IF DEFINED(Unicode)}
        CALL    System.@UStrFromPCharLen
{$ELSE}
        CALL    System.@LStrFromPCharLen
{$IFEND}
        ADD     ESP, 16
        POP     ESI
end;

{$ENDIF}
          
function XProgress(Data: Pointer): Integer; cdecl;
var Interrupt: Boolean;
begin
Interrupt := False;
TSQLiteDatabase(Data).OnProgress(Interrupt);
if Interrupt then
  Result := -1
else
  Result := 0;
end;

procedure XFunc(context: sqlite3_context; argc: Integer; argv: sqlite3_values); cdecl;
var Func: PSQLiteFunction;
    Args: array of TSQLiteVariant;
    Result: TSQLiteResult;
    I: Integer;
begin
Func := sqlite3_user_data(context);
SetLength(Args, argc);
for I := 0 to argc - 1 do
  begin
    Args[I] := TSQLiteVariant.Create(Func.DB, Pointer(Pointer(Cardinal(argv)+Cardinal(I)*4)^));
  end;

Result := TSQLiteResult.Create(Func.DB, context);

if Assigned(Func.Event) then
  Func.Event(Func.DB, Result, Args)
else
  Func.Callback(Func.DB, Result, Args);
Result.Free;

for I := 0 to argc - 1 do
  begin
    Args[I].Free;
  end;


end;

procedure XStep(context: sqlite3_context; argc: Integer; argv: sqlite3_values); cdecl;
var Agg: PSQLiteAggregate;
    Args: array of TSQLiteVariant;
    I: Integer;
begin
Agg := sqlite3_user_data(context);
SetLength(Args, argc);
for I := 0 to argc - 1 do
  begin
    Args[I] := TSQLiteVariant.Create(Agg.DB, Pointer(Pointer(Cardinal(argv)+Cardinal(I)*4)^));
  end;

if Assigned(Agg.StepEvent) then
  Agg.StepEvent(Agg.DB, Agg.Data, Args)
else
  Agg.StepCallback(Agg.DB, Agg.Data, Args);


for I := 0 to argc - 1 do
  begin
    Args[I].Free;
  end;
end;

function XAuthorize(Data: Pointer; actioncode: integer; add1,add2,add3,add4: PAnsiChar): Integer; cdecl;
var s1,s2,s3,s4: ansistring;
    allow: TSQLiteAuthorization;
begin
if add1 <> nil then
  s1 := add1;
if add2 <> nil then
  s2 := add2;
if add3 <> nil then
  s3 := add3;
if add4 <> nil then
  s4 := add4;

allow := saAllow;
TSQLiteDatabase(Data).fOnAuthorization(allow, TSQLiteAction(actioncode), s1, s2, s3, s4);

result := Integer(allow);
end;

procedure XFinal(context: sqlite3_context); cdecl;
var Agg: PSQLiteAggregate;
    Result: TSQLiteResult;
    DataClass: TSQLiteAggregateDataClass;
begin
Agg := sqlite3_user_data(context);

Result := TSQLiteResult.Create(Agg.DB, context);

if Assigned(Agg.ResultEvent) then
  Agg.ResultEvent(Agg.DB, Agg.Data, Result)
else
  Agg.ResultCallback(Agg.DB, Agg.Data, Result);
  
Result.Free;

DataClass := TSQLiteAggregateDataClass(Agg.Data.ClassType);
Agg.Data.Free;
Agg.Data := DataClass.Create;

end;

function XCompare(data: Pointer; N1: Integer; Str1: PChar; N2: Integer; Str2: PChar): Integer; cdecl;
var Col: PSQLiteCollation;
begin
Col := PSQLiteCollation(data);

if Assigned(Col.Event) then
  result := Col.Event(Col.DB, Str1, Str2)
else
  result := Col.Callback(Col.DB, Str1, Str2);

end;

function TSQLiteVariant.GetValueType: TSQLiteType;
begin
Result := TSQLiteType(sqlite3_value_type(fValue));
end;

function TSQLiteVariant.GetAsBoolean: Boolean;
begin
Result := GetAsInteger <> 0;
end;

function TSQLiteVariant.GetAsString: String;
begin
Result := {$IFDEF UNICODE}sqlite3_value_text16{$ELSE}sqlite3_value_text{$ENDIF}(fValue);
end;

function TSQLiteVariant.GetAsDouble: Double;
begin
Result := sqlite3_value_double(fValue);
end;

function TSQLiteVariant.GetAsInteger: Integer;
begin
Result := sqlite3_value_int(fValue);
end;

function TSQLiteVariant.GetAsInt64: Int64;
begin
Result := sqlite3_value_int64(fValue);
end;

function TSQLiteVariant.GetAsBlobStream: TSQLiteBlobStream;
begin
result := TSQLiteBlobStream.Create(sqlite3_value_blob(fValue), sqlite3_value_bytes(fValue), True);
end;

constructor TSQLiteVariant.Create(aDB: TSQLiteDatabase; aValue: sqlite3_value);
begin
  fValue := aValue;
  fDB := aDB;
end;

constructor TSQLiteColumn.Create(aQuery: TSQLiteQuery; aPosition: Integer);
begin
  inherited Create;
  fQuery := aQuery;
  fPosition := aPosition;
end;

function TSQLiteColumn.GetAsString: String;
begin
  result := {$IFDEF UNICODE}sqlite3_column_text16{$ELSE}sqlite3_column_text{$ENDIF}(fQuery.fStatement, fPosition);
end;

function TSQLiteColumn.GetAsDouble: Double;
begin
  result := sqlite3_column_double(fQuery.fStatement, fPosition);
end;

function TSQLiteColumn.GetAsInteger: Integer;
begin
  result := sqlite3_column_int(fQuery.fStatement, fPosition);
end;

function TSQLiteColumn.GetAsInt64: Int64;
begin
  result := sqlite3_column_int64(fQuery.fStatement, fPosition);
end;

function TSQLiteColumn.GetAsBoolean: Boolean;
begin
  Result := GetAsInteger <> 0;
end;

function TSQLiteColumn.GetAsBlobStream: TSQLiteBlobStream;
begin
  result := TSQLiteBlobStream.Create(sqlite3_column_blob(fQuery.fStatement, fPosition), sqlite3_column_bytes(fQuery.fStatement, fPosition), true);
end;

function TSQLiteColumn.GetColumnType: TSQLiteType;
begin
  Result := TSQLiteType(sqlite3_column_type(fQuery.fStatement, fPosition));
end;

function TSQLiteColumn.GetAsVariant: TSQLiteVariant;
begin
  Result := TSQLiteVariant.Create(fQuery.fDB, sqlite3_column_value(fQuery.fStatement, fPosition));
end;

function TSQLiteColumn.GetName: String;
begin
  result := {$IFDEF UNICODE}sqlite3_column_name16{$ELSE}sqlite3_column_name{$ENDIF}(fQuery.fStatement, fPosition);
end;

constructor TSQLiteBinding.Create(aStatement: TSQLiteStatement; aPosition: Integer; aFreeSelf: Boolean);
begin
fStatement := aStatement;
fPosition := aPosition;
fFreeSelf := aFreeSelf;
end;

procedure TSQLiteBinding.SetAsString(Value: String);
begin
  if {$IFDEF UNICODE}sqlite3_bind_text16{$ELSE}sqlite3_bind_text{$ENDIF}( fStatement.fStatement, fPosition, PChar(Value), -1, SQLITE_TRANSIENT) <> SQLITE_OK then
    fStatement.fDB.RaiseSqliteError;
  if fFreeSelf then self.Free;
end;

procedure TSQLiteBinding.SetAsInt64(Value: Int64);
begin
  if sqlite3_bind_int64( fStatement.fStatement, fPosition, Value) <> SQLITE_OK then
    fStatement.fDB.RaiseSqliteError;
  if fFreeSelf then self.Free;
end;

procedure TSQLiteBinding.SetAsVariant(Value: TSQLiteVariant);
begin
  if sqlite3_bind_value( fStatement.fStatement, fPosition, Value.fValue) <> SQLITE_OK then
    fStatement.fDB.RaiseSqliteError;
  if fFreeSelf then self.Free;
end;

procedure TSQLiteBinding.SetAsDouble(Value: Double);
begin
  if sqlite3_bind_double(fStatement.fStatement, fPosition, Value) <> SQLITE_OK then
    fStatement.fDB.RaiseSqliteError;
  if fFreeSelf then self.Free;
end;

procedure TSQLiteBinding.SetAsInteger(Value: Integer);
begin
  if sqlite3_bind_int(fStatement.fStatement, fPosition, Value) <> SQLITE_OK then
    fStatement.fDB.RaiseSqliteError;
  if fFreeSelf then self.Free;
end;

procedure TSQLiteBinding.SetToNull;
begin
  if sqlite3_bind_null(fStatement.fStatement, fPosition) <> SQLITE_OK then
    fStatement.fDB.RaiseSqliteError;
  if fFreeSelf then self.Free;
end;

procedure TSQLiteBinding.SetAsBoolean(Value: Boolean);
begin
  if Value then
    SetAsInteger(1)
  else
    SetAsInteger(0);
end;

procedure TSQLiteBinding.SetAsBlobStream(Value: TSQLiteBlobStream);
begin
  if sqlite3_bind_blob(fStatement.fStatement, fPosition, Value.fPointer, Value.fSize, SQLITE_TRANSIENT) <> SQLITE_OK then
    fStatement.fDB.RaiseSQLiteError;
  if fFreeSelf then self.Free;
end;

procedure TSQLiteBinding.SetToZeroblob(ByteCount: Integer);
begin
  if sqlite3_bind_zeroblob(fStatement.fStatement, fPosition, ByteCount) <> SQLITE_OK then
    fStatement.fDB.RaiseSqliteError;
  if fFreeSelf then self.Free;
end;

constructor TSQLiteBlobStream.Create(aPointer: Pointer; aSize: Int64; aInDLL: Boolean);
begin
  inherited Create;

  fSize := aSize;
  fPointer := aPointer;
  fInDLL := aInDLL;

  if fPointer = nil then
    New(fPointer);
end;

destructor TSQLiteBlobStream.Destroy;
begin
  if not fInDLL then
    FreeMem(fPointer, fSize);

  inherited Destroy;
end;

function TSQLiteBlobStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  case Origin of
    soBeginning: fOffset := Offset;
    soCurrent: fOffset := fOffset + Offset;
    soEnd: fOffset := fSize - Offset;
  end;
  if fOffset > fSize then
    fOffset := fSize;
  result := fOffset;
end;

function TSQLiteBlobStream.Write(const Buffer; Count: Longint): Longint;
var RealPointer: Pointer;
begin
  if (fOffset + Count) > fSize then
    Size := (fOffset + Count);

  RealPointer := Pointer(Cardinal(fPointer) + fOffset);
  Move(Buffer, RealPointer^, Count);

  result := Count;
  
  Seek(Count, soCurrent);
end;

function TSQLiteBlobStream.Read(var Buffer; Count: Longint): Longint;
var RealCount: Integer;
    RealPointer: Pointer;
begin
  RealCount := Count;
  if (fOffset + Count) > fSize then
    RealCount := 0;

  RealPointer := Pointer(Cardinal(fPointer) + fOffset);
  Move(RealPointer^, Buffer, RealCount);

  result := RealCount;

  Seek(Count, soCurrent);
end;

function TSQLiteBlobStream.GetSize: Int64;
begin
  result := fSize;
end;

procedure TSQLiteBlobStream.SetSize(const NewSize: Int64);
begin
  if not fInDLL then
    ReallocMem(fPointer, NewSize)
  else
    sqlite3_realloc(fPointer, NewSize);
  fSize := NewSize;
end;

constructor TSQLiteStatement.Create(aDB: TSQLiteDatabase; aSQL: String);
var IgnoreNextStmt: PChar;
begin
  inherited Create;
  fDB := aDB;

  if {$IFDEF UNICODE}sqlite3_prepare16{$ELSE}sqlite3_prepare{$ENDIF}(aDB.fDB, PChar(aSQL), -1, fStatement, IgnoreNextStmt) <> SQLITE_OK then
    fDB.RaiseSqliteError;
end;

function TSQLiteStatement.GetBindingCount: Integer;
begin
Result := sqlite3_bind_parameter_count(self.fStatement);
end;

function TSQLiteStatement.GetBinding(Index: Integer): TSQLiteBinding;
begin
  if (Index <= 0) or (Index > BindingCount) then
    begin
    fDB.RaiseError('Bindingindex('+IntToStr(Index)+') out of bounds');
    end;
  result := TSQLiteBinding.Create(self, Index, true);
end;

function TSQLiteStatement.GetBindingByName(Name: AnsiString): TSQLiteBinding;
var Index: Integer;
begin
  Index := sqlite3_bind_parameter_index(fStatement, PAnsiChar(Name));
  if (Index = 0) then
    fDB.RaiseError('Binding "'+String(Name)+'" not found');
  result := TSQLiteBinding.Create(self, Index, true);
end;

procedure TSQLiteStatement.Reset;
begin
  if sqlite3_reset(fStatement) <> SQLITE_OK then
    fDB.RaiseSqliteError;
end;

destructor TSQLiteStatement.Destroy;
begin
  if sqlite3_finalize(fStatement) <> SQLITE_OK then
    fDB.RaiseSqliteError;
end;

constructor TSQLiteQuery.Create(aDB: TSQLiteDatabase; aSQL: String);
var I: Integer;
begin
  inherited Create(aDB, aSQL);

  fColumnCount := sqlite3_column_count(fStatement);
  SetLength(fColumns, fColumnCount);
  for I := 0 to fColumnCount - 1 do
    fColumns[I] := TSQLiteColumn.Create(self, I);
end;

function TSQLiteQuery.GetColumn(Index: Integer): TSQLiteColumn;
begin
  if High(fColumns) >= Index then
    result := fColumns[Index]
  else
    result := nil;
end;

function TSQLiteQuery.GetColumnByName(Name: String): TSQLiteColumn;
var I: Integer;
begin
  Result := nil;
  for I := 0 to Length(fColumns) - 1 do
    begin
      if fColumns[I].Name = Name then
        begin
          Result := fColumns[I];
          break;
        end;
    end;
end;

function TSQLiteQuery.Next: Boolean;
var stepresult: Integer;
begin
  stepresult := sqlite3_step(fStatement);
  if (stepresult <> 0) and (stepresult < 100) then
    fDB.RaiseSqliteError;

  fEOF := stepresult = SQLITE_DONE;
  result := not fEOF;
end;

destructor TSQLiteQuery.Destroy;
var I: Integer;
begin
  for I := 0 to High(fColumns) do
    fColumns[I].Free;

  inherited Destroy;
end;

procedure TSQLiteCommand.Execute;
var execresult: Integer;
begin
  execresult := sqlite3_step(fStatement);
  if (execresult <> SQLITE_OK) and (execresult < 100) then
    fDB.RaiseSqliteError;
  fChangeCount := sqlite3_changes(fDB.fDB);
  fTotalChangeCount := sqlite3_total_changes(fDB.fDB);
  fInsertID := sqlite3_last_insert_rowid(fDB.fDB);
end;

constructor TSQLiteNativeBlobStream.Create(aDB: TSqliteDatabase; aDBName, aTableName, aColumName: AnsiString; aRow: Int64; aReadOnly: Boolean);
begin
  inherited Create();

  fDB := aDB;
  fDBName := aDBName;
  fTableName := aTableName;
  fColumnName := aColumName;
  fRow := aRow;
  fReadOnly := aReadOnly;

  RefreshHandle;
end;

function TSQLiteNativeBlobStream.GetSize: Int64;
begin
  result := sqlite3_blob_bytes(fBlob);
end;

procedure TSQLiteNativeBlobStream.SetSize(const NewSize: Int64);
var Diff: LongInt;
    IgnoreText: PAnsiChar;
begin
  Diff := NewSize - Size;
  if Diff > 0 then
    begin
      sqlite3_exec(fDB.fDB, PAnsiChar(AnsiString('UPDATE '+fDBName+'.'+fTableName+' SET '+fColumnName+' = '+fColumnName+' || ZEROBLOB('+AnsiString(IntToStr(Diff))+') WHERE ROWID = '+AnsiString(IntToStr(fRow))+';')), nil, nil, IgnoreText)
    end;                                                                                        
  if Diff < 0 then
    begin
      sqlite3_exec(fDB.fDB, PAnsiChar(AnsiString('UPDATE '+fDBName+'.'+fTableName+' SET '+fColumnName+' = SUBSTR('+fColumnName+',0,'+AnsiString(IntToStr(Diff+Size))+') WHERE ROWID = '+AnsiString(IntToStr(fRow))+';')), nil, nil, IgnoreText);
    end;
  RefreshHandle;
end;

function TSQLiteNativeBlobStream.Write(const Buffer; Count: Longint): Longint;
var RealCount: Integer;
begin
  RealCount := Count;

  case sqlite3_blob_write(fBlob, @Buffer, Count, Position) of
    SQLITE_ERROR: RealCount := 0;
    SQLITE_ABORT:
      begin
        RefreshHandle;
        sqlite3_blob_write(fBlob, @Buffer, Count, Position)
      end;
    SQLITE_READONLY: fDB.RaiseError('Blob is opened readonly');
  end;

  Seek(RealCount, soCurrent);
  result := RealCount;
end;

function TSQLiteNativeBlobStream.Read(var Buffer; Count: Longint): Longint;
var RealCount: Integer;
begin
  RealCount := Count;

  case sqlite3_blob_read(fBlob, @Buffer, Count, Position) of
    SQLITE_ERROR: RealCount := 0;
    SQLITE_ABORT:
      begin
        RefreshHandle;
        sqlite3_blob_read(fBlob, @Buffer, Count, Position)
      end;
  end;

  Seek(RealCount, soCurrent);
  result := RealCount;
end;

procedure TSQLiteNativeBlobStream.RefreshHandle;
var iReadOnly: Integer;
begin
  if fReadOnly then iReadOnly := 0 else iReadOnly := 1;

  if fBlob <> nil then
    begin
    if sqlite3_blob_close(fBlob) <> SQLITE_OK then
      fDB.RaiseSqliteError;
    end;

  if sqlite3_blob_open(fDB.fDB, PAnsiChar(fDBName), PAnsiChar(fTableName), PAnsiChar(fColumnName), fRow, iReadOnly, addr(fBlob)) <> SQLITE_OK then
      fDB.RaiseSqliteError;
end;

function TSQLiteNativeBlobStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  case Origin of
    soBeginning: fOffset :=  Offset;
    soCurrent: fOffset := fOffset + Offset;
    soEnd: fOffset := Size - Offset;
  end;
  if fOffset > Size then
   fOffset := Size;
  result := fOffset;
end;

destructor TSQLiteNativeBlobStream.Destroy;
begin
  if sqlite3_blob_close(fBlob) <> SQLITE_OK then
    fDB.RaiseSqliteError;

  inherited Destroy;
end;

constructor TSQLiteResult.Create(aDB: TSQLiteDatabase; aContext: sqlite3_context);
begin
  fDB := aDB;
  fContext := aContext;
end;

procedure TSQLiteResult.SetAsBoolean(Value: Boolean);
begin
  if Value then
    SetAsInteger(1)
  else
    SetAsInteger(0);
end;

procedure TSQLiteResult.SetAsString(Value: String);
begin
  {$IFDEF UNICODE}sqlite3_result_text16{$ELSE}sqlite3_result_text{$ENDIF}(fContext, PChar(Value), -1, SQLITE_TRANSIENT);
end;

procedure TSQLiteResult.SetAsInteger(Value: Integer);
begin
  sqlite3_result_int(fContext, Value);
end;

procedure TSQLiteResult.SetAsInt64(Value: Int64);
begin
  sqlite3_result_int64(fContext, Value);
end;

procedure TSQLiteResult.SetAsDouble(Value: Double);
begin
  sqlite3_result_double(fContext, Value);
end;

procedure TSQLiteResult.SetAsVariant(Value: TSQLiteVariant);
begin
  sqlite3_result_value(fContext, Value.fValue);
end;

procedure TSQLiteResult.SetAsBlobStream(Value: TSQLiteBlobStream);
begin
  sqlite3_result_blob(fContext, Value.fPointer, Value.fSize, SQLITE_TRANSIENT);
end;

procedure TSQLiteResult.SetToNull;
begin
  sqlite3_result_null(fContext);
end;

procedure TSQLiteResult.SetToZeroblob(ByteCount: Integer);
begin
  sqlite3_result_zeroblob(fContext, ByteCount);
end;

procedure TSQLiteResult.RaiseError(ErrorMessage: String);
begin
  {$IFDEF UNICODE}sqlite3_result_error16{$ELSE}sqlite3_result_error{$ENDIF}(fContext, PChar(ErrorMessage), -1);
  sqlite3_result_error_code(fCOntext, SQLITE_FUNCTION_ERROR);
  fDB.fResultError := ErrorMessage;
end;

procedure TSQLiteDatabase.Connect(FilePath: String);
begin
  if fConnected then
    Disconnect;

  fDatabasePath := FilePath;

  if {$IFDEF UNICODE}sqlite3_open16{$ELSE}sqlite3_open{$ENDIF}(PChar(FilePath), fDB) <> SQLITE_OK then
    RaiseSqliteError;

  fMutex := sqlite3_db_mutex(fDB);
    
  fConnected := True;
end;

procedure TSQLiteDatabase.Disconnect;
var I: Integer;
begin
  if sqlite3_close(fDB) <> SQLITE_OK then

  for I := 0 to length(fAggregates) - 1 do
    begin
      if fAggregates[I].Data <> nil then fAggregates[I].Data.Free;
      FreeMem(fAggregates[I], sizeOf(TSQLiteAggregate));
    end;
  SetLength(fAggregates, 0);
  for I := 0 to length(fFunctions) - 1 do
    FreeMem(fFunctions[I], sizeOf(TSQLiteFunction));
  SetLength(fFunctions, 0);
  for I := 0 to Length(fCollations) - 1 do
    FreeMem(fCollations[I], SizeOf(TSQLiteCollation));
  SetLength(fCollations, 0);
  fProgressFrequency := 10;

  fDatabasePath := '';
  fOnAuthorization := nil;
  fOnProgress := nil;

  fConnected := False;
end;

constructor TSQLiteDatabase.Create;
begin
  inherited Create;
end;

constructor TSQLiteDatabase.Create(FilePath: String);
begin
  Self.Create;
end;

function TSQLiteDatabase.GetNativeBlobStream(aDBName, aTableName, aColumName: AnsiString; aRow: Int64; aReadOnly: Boolean): TSQLiteNativeBlobStream;
begin
  result := TSQLiteNativeBlobStream.Create(self, aDBName, aTableName, aColumName, aRow, aReadOnly);
end;

procedure TSQLiteDatabase.RaiseSqliteError;
begin
  if fResultError = '' then
    RaiseError({$IFDEF UNICODE}sqlite3_errmsg16{$ELSE}sqlite3_errmsg{$ENDIF}(fDB))
  else
    begin
    RaiseError(fResultError);
    fResultError := '';
    end;
end;

function TSQLiteDatabase.Query(SQL: String): TSQLiteQuery;
begin
  result := TSQLiteQuery.Create(self, SQL);
end;

function TSQLiteDatabase.Command(SQL: String): TSQLiteCommand;
begin
  result := TSQLiteCommand.Create(self, SQL);
end;

procedure TSQLiteDatabase.Execute(SQL: String);
var Command: TSQLiteCommand;
begin
  Command := self.Command(SQL);
  Command.Execute;
  Command.Free;
end;

{$IFNDEF NONVCL}

function TSQLiteDatabase.Statement(SQL: String): TSQLiteStatement;
var tuSQL: String;
begin
tuSQL := copy(UpperCase(Trim(SQL)),0,6);
if (tuSQL = 'SELECT') or (tuSQL = 'PRAGMA') then
  Result := Query(SQL)
else
  Result := Command(SQL);
end;

{$ENDIF}

function TSQLiteDatabase.CreateNewBlobStream: TSQLiteBlobStream;
begin
  result := TSQLiteBlobStream.Create(nil, 0, false);
end;

procedure TSQLiteDatabase.AddFunction(aName: String; aArgCount: Integer; aEventHandler: TSQLiteFunctionEvent);
var P: PSQLiteFunction;
begin
GetMem(P, SizeOf(TSQLiteFunction));
P.DB := Self;
P.Event := aEventHandler;
P.Callback := nil;
if {$IFDEF UNICODE}sqlite3_create_function16{$ELSE}sqlite3_create_function{$ENDIF}(fDB, PChar(aName), aArgCount, SQLITE_ENCODING, P, @xFunc, nil, nil) <> SQLITE_OK then
  Self.RaiseSqliteError;

SetLength(fFunctions, length(fFunctions) + 1);
fFunctions[High(fFunctions)] := P;
end;

procedure TSQLiteDatabase.AddFunction(aName: String; aArgCount: Integer; aCallback: TSQLiteFunctionCallback);
var P: PSQLiteFunction;
begin
GetMem(P, SizeOf(TSQLiteFunction));
P.DB := Self;
P.Event := nil;
P.Callback := aCallback;
if {$IFDEF UNICODE}sqlite3_create_function16{$ELSE}sqlite3_create_function{$ENDIF}(fDB, PChar(aName), aArgCount, SQLITE_ENCODING, P, @xFunc, nil, nil) <> SQLITE_OK then
  Self.RaiseSqliteError;

SetLength(fFunctions, length(fFunctions) + 1);
fFunctions[High(fFunctions)] := P;
end;

procedure TSQLiteDatabase.AddAggregate(aName: string; aArgCount: Integer; aDataClass: TSQLiteAggregateDataClass; aStepEvent: TSQLiteAggregateStepEvent; aResultEvent: TSQLiteAggregateResultEvent);
var P: PSQLiteAggregate;
begin
GetMem(P, sizeOf(TSQLiteAggregate));
P.DB := Self;
if aDataClass <> nil then
  P.Data := aDataClass.Create
else
  P.Data := nil;
P.StepEvent := aStepEvent;
P.ResultEvent := aResultEvent;
P.StepCallback := nil;
P.ResultCallback := nil;
if {$IFDEF UNICODE}sqlite3_create_function16{$ELSE}sqlite3_create_function{$ENDIF}(fDB, PChar(aName), aArgCount, SQLITE_ENCODING, P, nil, @xStep, @xFinal) <> SQLITE_OK then
  Self.RaiseSqliteError;

SetLength(fAggregates, length(fAggregates) + 1);
fAggregates[High(fAggregates)] := P;
end;

procedure TSQLiteDatabase.AddAggregate(aName: string; aArgCount: Integer; aDataClass: TSQLiteAggregateDataClass; aStepCallback: TSQLiteAggregateStepCallback; aResultCallback: TSQLiteAggregateResultCallback);
var P: PSQLiteAggregate;
begin
GetMem(P, sizeOf(TSQLiteAggregate));
P.DB := Self;
if aDataClass <> nil then
  P.Data := aDataClass.Create
else
  P.Data := nil;
P.DB := Self;
if aDataClass <> nil then
  P.Data := aDataClass.Create
else
  P.Data := nil;
P.StepCallback := aStepCallback;
P.ResultCallback := aResultCallback;
P.StepEvent := nil;
P.ResultEvent := nil;
if {$IFDEF UNICODE}sqlite3_create_function16{$ELSE}sqlite3_create_function{$ENDIF}(fDB, PChar(aName), aArgCount, SQLITE_ENCODING, P, nil, @xStep, @xFinal) <> SQLITE_OK then
  Self.RaiseSqliteError;

SetLength(fAggregates, length(fAggregates) + 1);
fAggregates[High(fAggregates)] := P;
end;

procedure TSQLiteDatabase.AddCollation(aName: string; aEventHandler: TSQLiteCollationEvent);
var P: PSQLiteCollation;
begin
GetMem(P, sizeOf(TSQLiteCollation));
P.DB := Self;
P.Event := aEventHandler;
P.Callback := nil;
if {$IFDEF UNICODE}sqlite3_create_collation16{$ELSE}sqlite3_create_collation{$ENDIF}(fDB, PChar(aName), SQLITE_ENCODING, P, xCompare) <> SQLITE_OK then
  Self.RaiseSqliteError;

SetLength(fCollations, length(fCollations) + 1);
fCollations[High(fCollations)] := P;
end;

procedure TSQLiteDatabase.AddCollation(aName: string; aCallback: TSQLiteCollationCallback);
var P: PSQLiteCollation;
begin
GetMem(P, sizeOf(TSQLiteCollation));
P.DB := Self;
P.Event := nil;
P.Callback := aCallback;
if {$IFDEF UNICODE}sqlite3_create_collation16{$ELSE}sqlite3_create_collation{$ENDIF}(fDB, PChar(aName), SQLITE_ENCODING, P, xCompare) <> SQLITE_OK then
  Self.RaiseSqliteError;

SetLength(fCollations, length(fCollations) + 1);
fCollations[High(fCollations)] := P;
end;

procedure TSQLiteDatabase.EnterCriticalSection;
begin
  sqlite3_mutex_enter(fMutex);
end;

procedure TSQLiteDatabase.LeaveCriticalSection;
begin
  sqlite3_mutex_leave(fMutex);
end;

procedure TSQLiteDatabase.RaiseError(Text: String);
begin
  {$IFNDEF NONVCL}raise ESQLiteException.Create(Text);{$ENDIF}
  if Assigned(fOnError) then
    fOnError(Text);
end;

procedure TSQLiteDatabase.SetOnAuthorization(Value: TSQLiteAuthorizationEvent);
begin
if not assigned(Value) then
  sqlite3_set_authorizer(fDB, nil, nil)
else
  sqlite3_set_authorizer(fDB, xAuthorize, self);

self.fOnAuthorization := Value;
end;

procedure TSQLiteDatabase.SetOnProgress(Value: TSQLiteProgressEvent);
begin
if assigned(Value) then
  sqlite3_progress_handler(fDB, fProgressFrequency, @xProgress, self)
else
  sqlite3_progress_handler(fDB, -1, nil, nil);
                                            
self.fOnProgress := Value;
end;

procedure TSQLiteDatabase.SetProgressFrequency(Value: Integer);
begin
fProgressFrequency := Value;
SetOnProgress(fOnProgress);
end;

procedure TSQLiteDatabase.SetLimit(Index: TSQLiteLimit; Value: Integer);
begin
  sqlite3_limit(fDB, Integer(Index), Value);
end;

destructor TSQLiteDatabase.Destroy;
var I: Integer;
    Stmt: sqlite3_stmt;
begin
  Stmt := nil;
  repeat
    Stmt := sqlite3_next_stmt(fDB, Stmt);
    if (Stmt <> nil) and (Cardinal(Stmt) <> $FEEEFEEE) then sqlite3_finalize(Stmt);
  until (Stmt = nil) or (Cardinal(Stmt) = $FEEEFEEE);

  if fConnected then
    self.Disconnect;

  for I := Low(fAggregates) to High(fAggregates) do
    if fAggregates[I].Data <> nil then fAggregates[I].Data.Free;

  inherited Destroy;
end;

end.
