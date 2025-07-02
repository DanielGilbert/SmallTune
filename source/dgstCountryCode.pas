unit dgstCountryCode;

interface

type
  TCountryCode = packed record
    Name: string;
    IsoCode: string;
    StationCount: Integer;
  end;
  TCountryCodes = Array of TCountryCode;

Implementation

end.
