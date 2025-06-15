unit dgstRadioBrowserApi;

interface

uses
  Windows,
  dgstSysUtils,
  WinInet,
  dgstWinDns,
  dgstRestClient;

type
  TCountryCodes = Array of string;

  TRadiobrowserApi = class
  private
    fRestClient: TRestClient;
    function FetchRandomHost : string;
    function ConvertDWordToIp4String(ipAddress: LongWord): String;
  public
    constructor Create(restClient: TRestClient);
    function FetchAllCountries: TCountryCodes; 
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

function TRadioBrowserApi.FetchRandomHost : string;
var
  status: DNS_STATUS;
  QueryResult: PPDNS_RECORD;
  SingleRecord: PDNS_RECORD;
  randomResult: Integer;
  testIndex: Int64;
  hosts: array of string;
begin
  status := DnsQuery_A('all.api.radio-browser.info', DNS_TYPE_A, DNS_QUERY_BYPASS_CACHE, nil, QueryResult, nil);
  SingleRecord := QueryResult^;
  while (SingleRecord <> nil) do
  begin
    if SingleRecord.wType = DNS_TYPE_A then
    begin
      SetLength(hosts, Length(hosts) + 1);
      hosts[Length(hosts) - 1] := ConvertDWordToIp4String(SingleRecord.Data.A.IpAddress);
    end;
    SingleRecord := SingleRecord.pNext;
  end;
  //randomResult := RandomGenerator(0, 2, GetTickCount());
  Result := hosts[0];
end;

function TRadioBrowserApi.ConvertDWordToIp4String(ipAddress: LongWord): String;
var
  Addr: TInAddr;
begin
  Addr.S_addr := ipAddress;
  result := inet_ntoa(Addr);
end;

function TRadioBrowserApi.FetchAllCountries;
var
  CountryCodes: TCountryCodes;
  I: integer;
  host: string;
  urlContent: string;
begin
  host := FetchRandomHost();
  urlContent := fRestClient.GetUrlContent('http://' + host + '/csv/countries');
  SetLength(CountryCodes, 3);
  for I := 0 to Length(CountryCodes) - 1 do
  begin
    CountryCodes[I] := 'Test' + IntToStr(I);
  end;
  CountryCodes[2] := urlContent;
  Result := CountryCodes;
end;

end.
