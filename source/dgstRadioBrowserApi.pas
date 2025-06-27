unit dgstRadioBrowserApi;

interface

uses
  Windows,
  dgstSysUtils,
  WinInet,
  dgstWinDns,
  dgstRestClient,
  dgstHelper,
  dgstTypeDef,
  dgstCountryCode,
  dgstCSVReader;

const
  DNS_QUERY_HOST : string = '_api._tcp.radio-browser.info';
  COUNTRY_ROUTE_CSV : string = '/csv/countries';
  STATIONSBYCOUNTRY_ROUTE_CSV : string = '/csv/stations/search';

type
  TStation = String;
  TStationList = Array of string;

  TFetchConfiguration = record
    Name: string;
    Country: string;
  end;

  TRadiobrowserApi = class
  private
    fRestClient: TRestClient;
    function ConvertUTF8String(var utf8: UTF8String): AnsiString;
    function FetchHosts : TStringDynArray;
    procedure Sort(var r : array of string; lo, up : integer);
  public
    constructor Create(restClient: TRestClient);
    function FetchAllCountries: TCountryCodes;
    function FetchStations(fetchConfiguration: TFetchConfiguration): TStationList;
  end;

implementation

{*Function for generating Uniform Random Numbers *}
Function Uniform(seed : integer) : Double;
{*Uniform is a random n11mher between zero and one*}
const
A = 314159269 ;
C = 453806245 ;
M = 2147483647;
begin
Seed := A * Seed + C;
Seed := Seed MOD M ;
Result := Seed/M;
end; 
function RandomGenerator(Min: Integer; Max: Integer; Seed: Integer): Integer;
var
  IntermediateResult: Integer;
begin
   IntermediateResult := Min + Trunc((Max - Min + 1.0) * Uniform(Seed));
   if IntermediateResult <= Min then
     IntermediateResult := Min;

   Result := IntermediateResult;
end;

constructor TRadioBrowserApi.Create(restClient: TRestClient);
begin
  fRestClient := restClient;
end;

function TRadioBrowserApi.FetchHosts : TStringDynArray;
var
  status: DNS_STATUS;
  QueryResult: PPDNS_RECORD;
  SingleRecord: PDNS_RECORD;
  hosts: TStringDynArray;
begin
  status := DnsQuery_A(PAnsiChar(DNS_QUERY_HOST), DNS_TYPE_SRV, DNS_QUERY_BYPASS_CACHE, nil, QueryResult, nil);
  SingleRecord := QueryResult^;
  while (SingleRecord <> nil) do
  begin
    if SingleRecord.wType = DNS_TYPE_SRV then
    begin
      SetLength(hosts, Length(hosts) + 1);
      hosts[Length(hosts) - 1] := SingleRecord.Data.SRV.pNameTarget;
    end;
    SingleRecord := SingleRecord.pNext;
  end;
  Result := hosts;
end;

function TRadioBrowserApi.ConvertUTF8String(var utf8: UTF8String): AnsiString;
var
  latin1: AnsiString;
  ws: WideString;
  len: Integer;
begin
  len := MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(utf8), Length(utf8), nil, 0);
  SetLength(ws, len);
  MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(utf8), Length(utf8), PWideChar(ws), len);
  len := WideCharToMultiByte(28591, 0, PWideChar(ws), Length(ws), nil, 0, nil, nil);
  SetLength(latin1, len);
  WideCharToMultiByte(28591, 0, PWideChar(ws), Length(ws), PAnsiChar(latin1), len, nil, nil);
  Result := latin1;
end;

procedure TRadioBrowserApi.Sort(var r : array of string; lo, up : integer );
     var  i, j : integer;
          tempr : string;
     begin
        while (up > lo) do
        begin
          i := lo;
          j := up;
          tempr := r[lo];
          while i < j do
          begin
               while r[j] > tempr do
                    j := j-1;
               r[i] := r[j];
               while (i<j) and (r[i]<=tempr) do
                    i := i+1;
               r[j] := r[i]
               end;
          r[i] := tempr;
          {*** Sort recursively ***}
          Sort(r,lo,i-1);
          lo := i+1
          end
     end;

function TRadioBrowserApi.FetchAllCountries: TCountryCodes;
var
  CountryCodes: TCountryCodes;
  hosts: TStringDynArray;
  host: string;
  i: integer;
  foundStations: boolean;
  urlContent1: UTF8String;
  urlContent: string;
  intermediateContent : string;
  csvReader: TCSVReader;
  test: String;
begin
  hosts := FetchHosts();
  i := 0;
  foundStations := false;
  while not foundStations do
  begin
    host := hosts[i];
    Inc(i);
    intermediateContent := '';
    urlContent1 := fRestClient.SendRequest(host, COUNTRY_ROUTE_CSV, '');
    urlContent := ConvertUTF8String(urlContent1);
    csvReader := TCSVReader.Create(urlContent);
    csvReader.EOLChar := #10;
    csvReader.EOLLength := 1;
    csvReader.Quote := '"';
    csvReader.First(true);
    While not csvReader.Eof Do
    begin
      SetLength(CountryCodes, Length(CountryCodes) + 1);
      test := csvReader.Columns[0] + ' (' + csvReader.Columns[2] + ')';
      CountryCodes[Length(CountryCodes) - 1] := test;
      foundStations := true;
      csvReader.Next()
    end;
  end;
  Sort(CountryCodes, 0, Length(CountryCodes) - 1);
  Result := CountryCodes;
end;

function TRadioBrowserApi.FetchStations(fetchConfiguration: TFetchConfiguration): TStationList;
var
  urlParameters: string;
begin
if (fetchConfiguration.Name <> '') then
begin
  
end;
end;

end.
