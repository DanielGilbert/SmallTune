unit dgstRadioBrowserApi;

interface

uses
  Windows,
  dgstSysUtils,
  WinInet,
  dgstWinDns;

type
  TCountryCodes = Array of string;

  TRadiobrowserApi = class
  private
  public
    constructor Create;
    function FetchAllCountries: TCountryCodes; 
  end;

implementation

constructor TRadioBrowserApi.Create;
begin

end;

function TRadioBrowserApi.FetchAllCountries;
var
  CountryCodes: TCountryCodes;
  I: integer;
begin
  SetLength(CountryCodes, 2);
  for I := 0 to Length(CountryCodes) - 1 do
  begin
    CountryCodes[I] := 'Test' + IntToStr(I);
  end;
  Result := CountryCodes;
end;

end.
