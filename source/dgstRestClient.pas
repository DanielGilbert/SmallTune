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
  end;

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
  NetHandle := InternetOpen('Delphi 5.x', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  {*if not Assigned(NetHandle) then
    raise Exception.Create('Unable to initialize Wininet');*}
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

{*function request(const Host, AUrl, AData: AnsiString; blnSSL: Boolean = True): AnsiString;
var
  aBuffer     : Array[0..4096] of Char;
  Header      : String;
  BufStream   : Array[0..4096] of Byte;
  TargetBuffer: Array of Byte;
  sMethod     : AnsiString;
  BytesRead   : Cardinal;
  pSession    : HINTERNET;
  pConnection : HINTERNET;
  pRequest    : HINTERNET;
  parsedURL   : String;
  port        : Integer;
  flags       : DWord;
begin
  ParsedUrl := AUrl;

  Result := '';

  pSession := InternetOpen('SmallTune/1.0', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);

  if Assigned(pSession) then
  try
    if blnSSL then
      Port := INTERNET_DEFAULT_HTTPS_PORT
    else
      Port := INTERNET_DEFAULT_HTTP_PORT;
    pConnection := InternetConnect(pSession, PChar(Host), port, nil, nil, INTERNET_SERVICE_HTTP, 0, 0);

    if Assigned(pConnection) then
    try
      if (AData = '') then
        sMethod := 'GET'
      else
        sMethod := 'POST';

      if blnSSL then
        flags := INTERNET_FLAG_SECURE or INTERNET_FLAG_KEEP_CONNECTION
      else
        flags := INTERNET_SERVICE_HTTP;

      pRequest := HTTPOpenRequest(pConnection, PChar(sMethod), PChar(AUrl), nil, nil, nil, flags, 0);

      if Assigned(pRequest) then
      try

        try
          Header := Header + 'Host: ' + Host + sLineBreak;
          Header := Header + 'User-Agent: SmallTune/1.0'+SLineBreak;
          Header := Header + 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'+SLineBreak;
          Header := Header + 'Accept-Language: en-us,en;q=0.5' + SLineBreak;
          Header := Header + 'Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7'+SLineBreak;
          Header := Header + 'Keep-Alive: 300'+ SLineBreak;
          Header := Header + 'Connection: keep-alive'+ SlineBreak+SLineBreak;
          HttpAddRequestHeaders(pRequest, PChar(Header), Length(Header), HTTP_ADDREQ_FLAG_ADD);

          if HTTPSendRequest(pRequest, nil, 0, Pointer(AData), Length(AData)) then
          begin
            //BufStream := TMemoryStream.Create;
            try
              while InternetReadFile(pRequest, @aBuffer, SizeOf(aBuffer), BytesRead) do
              begin
                if (BytesRead = 0) then Break;
                SetLength(TargetBuffer, BytesRead);
                BufStream.Write(aBuffer, BytesRead);
              end;

              aBuffer[0] := #0;
              BufStream.Write(aBuffer, 1);
              Result := PChar(BufStream.Memory);
            finally
              BufStream.Free;
            end;
          end;
        finally
          Header.Free;
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
end;*}

end.
