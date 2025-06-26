unit dgstRestClient;

interface

uses
  Windows,
  WinInet;

type
  TRestClient = class
  private
    fHInternet: HINTERNET;
  public
    function GetUrlContent(const Url: string): string;
    function SendRequest(Const AServer, AUrl, AData: String; UseSSL: boolean = true): string;
  end;

const
  SMALLTUNE_HEADER = 'SmallTune/1.x';

implementation

function TRestClient.GetUrlContent(const Url: string): string;
var
  NetHandle: HINTERNET;
  UrlHandle: HINTERNET;
  Buffer: array[0..1024] of AnsiChar;
  BytesRead: DWORD;
  Size: Integer;
  IntermediateBuffer: Array of AnsiChar;
begin
  Result := '';
  NetHandle := InternetOpen(SMALLTUNE_HEADER, INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if not Assigned(NetHandle) then
    Result := '';
    //raise Exception.Create('Unable to initialize Wininet');*}
  try
    UrlHandle := InternetOpenUrl(NetHandle, PChar(Url), nil, 0, INTERNET_FLAG_RELOAD, 0);
    {*if not Assigned(UrlHandle) then
      raise Exception.CreateFmt('Cannot open URL %s', [Url]); *}
    try
      { Proceed with download }
      Size := 0;
      repeat
        {*if not InternetReadFile(UrlHandle, @Buffer, SizeOf(Buffer), BytesRead) then
          raise Exception.CreateFmt('Cannot download from URL %s', [Url]);*}
        InternetReadFile(UrlHandle, @Buffer, SizeOf(Buffer), BytesRead);
        if BytesRead = 0 then Break;
        SetLength(Result, Size + BytesRead);
        Move(Buffer, Result[Size + 1], BytesRead);
        Inc(Size, BytesRead);
      until False;
    finally
      InternetCloseHandle(UrlHandle);
    end;
  finally
    InternetCloseHandle(NetHandle);
  end;
end;

function TRestClient.SendRequest(Const AServer, AUrl, AData: String; UseSSL: boolean = true): string;
var
aBuffer     : Array[0..2048] of AnsiChar;
Header      : String;
BufStream   : Array of AnsiChar;
TempBuffer  : Array of AnsiChar;
sMethod     : AnsiString;
test        : WideChar;
BytesRead   : Cardinal;
pSession    : HINTERNET;
pConnection : HINTERNET;
pRequest    : HINTERNET;
Size: Integer;
begin
Result := '';
 
 pSession := InternetOpen(nil, INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
 
 if Assigned(pSession) then
   try
 
     case UseSSL of
       True  :  pConnection := InternetConnect(pSession, PChar(AServer), INTERNET_DEFAULT_HTTPS_PORT, nil, nil, INTERNET_SERVICE_HTTP, 0, 0);
       False :  pConnection := InternetConnect(pSession, PChar(AServer), INTERNET_DEFAULT_HTTP_PORT, nil, nil, INTERNET_SERVICE_HTTP, 0, 0);
     end;
 
  if Assigned(pConnection) then
    try
 
      if (AData = '') then
        sMethod := 'GET'
      else
        sMethod := 'POST';
 
     case UseSSL of
       True  : pRequest := HTTPOpenRequest(pConnection, PChar(sMethod), PChar(AURL), nil, nil, nil, INTERNET_FLAG_SECURE  or INTERNET_FLAG_KEEP_CONNECTION, 0);
       False : pRequest := HTTPOpenRequest(pConnection, PChar(sMethod), PChar(AURL), nil, nil, nil, INTERNET_SERVICE_HTTP, 0);
     end;
 
  if Assigned(pRequest) then
    try

      Header := Header + 'Host: ' + AServer + sLineBreak;
      Header := Header + SMALLTUNE_HEADER + sLineBreak;
      Header := Header + 'Accept: text/csv,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' + sLineBreak;
      Header := Header + 'Accept-Language: en-us,en;q=0.5' + sLineBreak;
      Header := Header + 'Accept-Charset: ISO-8859-1,q=0.7,*;q=0.7'+ sLineBreak;
      Header := Header + 'Keep-Alive: 300' + sLineBreak;
      Header := Header + 'Connection: keep-alive' + sLineBreak + sLineBreak;

      HttpAddRequestHeaders(pRequest, PChar(Header), Length(Header), HTTP_ADDREQ_FLAG_ADD);


  if HTTPSendRequest(pRequest, nil, 0, Pointer(AData), Length(AData)) then
    begin
     try
      Size := 0;
       while InternetReadFile(pRequest, @aBuffer, SizeOf(aBuffer), BytesRead) do
       begin
        if (BytesRead = 0) then Break;
        SetLength(TempBuffer, Size + BytesRead);
        Move(aBuffer, TempBuffer[Size], BytesRead);
        Inc(Size, BytesRead);
       end;
       Result := String(TempBuffer);
     finally
       
     end;
    end;
 
    finally
      InternetCloseHandle(pRequest);
    end;
 
    finally
      InternetCloseHandle(pConnection);
    end;
 
    finally
      InternetCloseHandle(pSession);
    end;
end;

end.
