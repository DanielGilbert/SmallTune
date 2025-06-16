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
  status := DnsQuery_A('_api._tcp.radio-browser.info', DNS_TYPE_SRV, DNS_QUERY_BYPASS_CACHE, nil, QueryResult, nil);
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
  M, I, N: integer;
  host: string;
  urlContent: string;
  intermediateContent : string;
  skipIndicator: boolean;
begin
  host := FetchRandomHost();
  intermediateContent := '';
  urlContent := fRestClient.GetUrlContent('https://' + host + '/csv/countries');
  n := 0;
  skipIndicator := true;
  for M := 0 to Length(urlContent) - 1 do
  begin
    case urlContent[M] of
    #0:
      begin
        continue;
      end;
    #10,
    #13:
      begin
        intermediateContent := '';
        skipIndicator := false;
      end;
    ',':
      begin
        if skipIndicator <> true then
        begin
        SetLength(CountryCodes, Length(CountryCodes) + 1);
        CountryCodes[N] := intermediateContent;
        intermediateContent := '';
        Inc(N);
        skipIndicator := true;
        end;
      end;
    else
      intermediateContent := intermediateContent + urlContent[M];
    end;
  end;
  Result := CountryCodes;
end;

end.
