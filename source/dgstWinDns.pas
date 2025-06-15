unit dgstWinDns;

interface

const
  windns = 'windns.dll';

type
  PDnsRecord = ^TDnsRecord;
  TDnsRecord = packed record
  end;

{$EXTERNALSYM DnsQuery_A}
function DnsQuery_A(pszName: PAnsiChar; wType: Word; Options: LongWord; pExtra: Pointer; ppQueryResults: PDnsRecord; pReserved: Pointer): LongInt; stdcall;

function DnsQuery_A; external windns name 'DnsQuery_A';

implementation

end.
