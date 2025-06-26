unit dgstCountryCode;

interface

type
  TCountryCode = class
  private
    fName: String;
    fIsoCode: String;
    fStationCount: Integer;
  public
    property Name: String read fName;
    property IsoCode: String read fIsoCode;
    property StationCount: Integer read fStationCount;

    //rawCSV should contain the string with the all the rawData from the CSV
    Constructor Create(rawCSV: String);
  end;
  TCountryCodes = Array of string;

implementation

Constructor TCountryCode.Create(rawCSV: String);
begin

end;

end.
