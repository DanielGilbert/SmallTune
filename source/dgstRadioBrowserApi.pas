unit dgstRadioBrowserApi;

interface

uses
  Windows,
  dgstSysUtils,
  dgstHelper,
  WinInet,
  dgstWinDns,
  dgstRestClient,
  dgstTypeDef,
  dgstCountryCode,
  dgstCSVReader;

const
  DNS_QUERY_HOST : string = '_api._tcp.radio-browser.info';
  COUNTRY_ROUTE_CSV : string = '/csv/countries';
  STATIONSSEARCH_ROUTE_CSV : string = '/csv/stations/search';

type
  TStation = packed record
    Name: string;
    Url: string;
  end;
  TStationList = Array of TStation;

  TFetchConfiguration = packed record
    Name: string;
    Country: string;
  end;

  TRadiobrowserApi = class
  private
    fRestClient: TRestClient;
    function ConvertUTF8String(var utf8: UTF8String): AnsiString;
    function FetchHosts : TStringDynArray;
    procedure SortCountryCodes(var r :TCountryCodes; lo, up : integer );
  public
    constructor Create(restClient: TRestClient);
    function FetchAllCountries: TCountryCodes;
    procedure FetchStations(fetchConfiguration: TFetchConfiguration; var stationList: TStationList);
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

procedure TRadioBrowserApi.SortCountryCodes(var r : TCountryCodes; lo, up : integer );
     var  i, j : integer;
          tempr : TCountryCode;
     begin
        while (up > lo) do
        begin
          i := lo;
          j := up;
          tempr := r[lo];
          while i < j do
          begin
               while r[j].Name > tempr.Name do
                    j := j-1;
               r[i] := r[j];
               while (i<j) and (r[i].Name<=tempr.Name) do
                    i := i+1;
               r[j] := r[i]
               end;
          r[i] := tempr;
          {*** Sort recursively ***}
          SortCountryCodes(r,lo,i-1);
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
begin
  hosts := FetchHosts();
  i := 0;
  foundStations := false;
  while not foundStations do
  begin
    if (i > length(hosts) - 1) then
    begin
      //Looks like no endpoint is working.
      //We need to handle this.
      foundStations := true;
      Result := CountryCodes;
      Exit;
    end;
    host := hosts[i];
    Inc(i);
    intermediateContent := '';
    urlContent1 := fRestClient.SendRequest(host, COUNTRY_ROUTE_CSV, '');
    if (urlContent1 = '') then
    continue;
    urlContent := ConvertUTF8String(urlContent1);
    csvReader := TCSVReader.Create(urlContent);
    csvReader.EOLChar := #10;
    csvReader.EOLLength := 1;
    csvReader.Quote := '"';
    csvReader.First(true);
    While not csvReader.Eof Do
    begin
      SetLength(CountryCodes, Length(CountryCodes) + 1);
      CountryCodes[Length(CountryCodes) - 1].Name := csvReader.Columns[0];
      CountryCodes[Length(CountryCodes) - 1].IsoCode := csvReader.Columns[1];
      CountryCodes[Length(CountryCodes) - 1].StationCount := StrToIntDef(csvReader.Columns[2], 0);
      foundStations := true;
      csvReader.Next()
    end;
  end;
  SortCountryCodes(CountryCodes, 0, Length(CountryCodes) - 1);
  Result := CountryCodes;
end;

procedure TRadioBrowserApi.FetchStations(fetchConfiguration: TFetchConfiguration; var stationList: TStationList);
var
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
  SetLength(stationList, 0);
  hosts := FetchHosts();
  i := 0;
  foundStations := false;
  while not foundStations do
  begin
   if (i > length(hosts) - 1) then
    begin
      //Looks like no endpoint is working.
      //We need to handle this.
      Exit;
    end;
    host := hosts[i];
    Inc(i);
    intermediateContent := '';
    urlContent1 := fRestClient.SendRequest(host, STATIONSSEARCH_ROUTE_CSV + '?countrycode='+ fetchConfiguration.Country +'&order=name', '');
    if (urlContent1 = '') then
    continue;
    urlContent := ConvertUTF8String(urlContent1);
    csvReader := TCSVReader.Create(urlContent);
    csvReader.EOLChar := #10;
    csvReader.EOLLength := 1;
    csvReader.Quote := '"';
    csvReader.First(true);
    While not csvReader.Eof Do
    begin
      SetLength(stationList, Length(stationList) + 1);
      stationList[Length(stationList) - 1].Name := csvReader.Columns[3];
      stationList[Length(stationList) - 1].Url := csvReader.Columns[4];
      foundStations := true;
      csvReader.Next()
    end;
  end;
end;

end.
