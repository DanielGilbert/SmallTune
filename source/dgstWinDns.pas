unit dgstWinDns;

interface

const
  windns = 'Dnsapi.dll';
  winsock = 'Ws2_32.dll';

type
  DWORD = LongWord;


//
//  IP Address
//
  IP4_ADDRESS = DWORD;
  {$EXTERNALSYM IP4_ADDRESS}
  PIP4_ADDRESS = ^IP4_ADDRESS;
  {$EXTERNALSYM PIP4_ADDRESS}
  TIP4Address = IP4_ADDRESS;
  PIP4Address = PIP4_ADDRESS;

  DNS_STATUS = Longint;
  {$EXTERNALSYM DNS_STATUS}
  PDNS_STATUS = ^DNS_STATUS;
  {$EXTERNALSYM PDNS_STATUS}
  TDnsStatus = DNS_STATUS;
  PDnsStatus = PDNS_STATUS;

//
//  Record \ RR set structure
//
//  Note:  The dwReserved flag serves to insure that the substructures
//  start on 64-bit boundaries.  Do NOT pack this structure, as the
//  substructures may contain pointers or int64 values which are
//  properly aligned unpacked.
//

const

  ATM_ADDR_SIZE = 20;
  {$EXTERNALSYM ATM_ADDR_SIZE}
  DNS_ATMA_MAX_ADDR_LENGTH = ATM_ADDR_SIZE;
  {$EXTERNALSYM DNS_ATMA_MAX_ADDR_LENGTH}

  //  RFC 1034/1035
  DNS_TYPE_A     = $0001; // 1
  {$EXTERNALSYM DNS_TYPE_A}

  DNS_TYPE_SRV     = $0021; // 0x21
  {$EXTERNALSYM DNS_TYPE_A}

    DNS_QUERY_STANDARD                  = $00000000;
  {$EXTERNALSYM DNS_QUERY_STANDARD}
  DNS_QUERY_ACCEPT_TRUNCATED_RESPONSE = $00000001;
  {$EXTERNALSYM DNS_QUERY_ACCEPT_TRUNCATED_RESPONSE}
  DNS_QUERY_USE_TCP_ONLY              = $00000002;
  {$EXTERNALSYM DNS_QUERY_USE_TCP_ONLY}
  DNS_QUERY_NO_RECURSION              = $00000004;
  {$EXTERNALSYM DNS_QUERY_NO_RECURSION}
  DNS_QUERY_BYPASS_CACHE              = $00000008;
  {$EXTERNALSYM DNS_QUERY_BYPASS_CACHE}

//
//  IPv6 Address
//
type
  PIP6_ADDRESS = ^IP6_ADDRESS;
  {$EXTERNALSYM PIP6_ADDRESS}
  IP6_ADDRESS = record
    case Integer of
      0: (IP6Qword: array [0..1] of Int64);
      1: (IP6Dword: array [0..3] of DWORD);
      2: (IP6Word: array [0..7] of WORD);
      3: (IP6Byte: array [0..15] of BYTE);
      4: (In6: Pointer);
  end;
  {$EXTERNALSYM IP6_ADDRESS}
  TIp6Address = IP6_ADDRESS;
  PIp6Address = PIP6_ADDRESS;

//  Backward compatibility

  DNS_IP6_ADDRESS = IP6_ADDRESS;
  {$EXTERNALSYM DNS_IP6_ADDRESS}
  PDNS_IP6_ADDRESS = ^IP6_ADDRESS;
  {$EXTERNALSYM PDNS_IP6_ADDRESS}
  TDnsIp6Address = DNS_IP6_ADDRESS;
  PDnsIp6Address = PDNS_IP6_ADDRESS;


  PDNS_A_DATA = ^DNS_A_DATA;
  {$EXTERNALSYM PDNS_A_DATA}
  DNS_A_DATA = record
    IpAddress: IP4_ADDRESS;
  end;
  {$EXTERNALSYM DNS_A_DATA}
  TDnsAData = DNS_A_DATA;
  PDnsAData = PDNS_A_DATA;

  PDNS_PTR_DATA = ^DNS_PTR_DATA;
  {$EXTERNALSYM PDNS_PTR_DATA}
  DNS_PTR_DATA = record
    pNameHost: PAnsiChar;
  end;
  {$EXTERNALSYM DNS_PTR_DATA}
  TDnsPtrData = DNS_PTR_DATA;
  PDnsPtrData = PDNS_PTR_DATA;

  PDNS_SOA_DATA = ^DNS_SOA_DATA;
  {$EXTERNALSYM PDNS_SOA_DATA}
  DNS_SOA_DATA = record
    pNamePrimaryServer: PAnsiChar;
    pNameAdministrator: PAnsiChar;
    dwSerialNo: DWORD;
    dwRefresh: DWORD;
    dwRetry: DWORD;
    dwExpire: DWORD;
    dwDefaultTtl: DWORD;
  end;
  {$EXTERNALSYM DNS_SOA_DATA}
  TDnsSoaData = DNS_SOA_DATA;
  PDnsSoaData = PDNS_SOA_DATA;

  PDNS_MINFO_DATA = ^DNS_MINFO_DATA;
  {$EXTERNALSYM PDNS_MINFO_DATA}
  DNS_MINFO_DATA = record
    pNameMailbox: PAnsiChar;
    pNameErrorsMailbox: PAnsiChar;
  end;
  {$EXTERNALSYM DNS_MINFO_DATA}
  TDnsMinfoData = DNS_MINFO_DATA;
  PDnsMinfoData = PDNS_MINFO_DATA;

  PDNS_MX_DATA = ^DNS_MX_DATA;
  {$EXTERNALSYM PDNS_MX_DATA}
  DNS_MX_DATA = record
    pNameExchange: PAnsiChar;
    wPreference: WORD;
    Pad: WORD;
  end;
  {$EXTERNALSYM DNS_MX_DATA}
  TDnsMxData = DNS_MX_DATA;
  PDnsMxData = PDNS_MX_DATA;

  PDNS_TXT_DATA = ^DNS_TXT_DATA;
  {$EXTERNALSYM PDNS_TXT_DATA}
  DNS_TXT_DATA = record
    dwStringCount: DWORD;
    pStringArray: array [0..0] of PAnsiChar;
  end;
  {$EXTERNALSYM DNS_TXT_DATA}
  TDnsTxtData = DNS_TXT_DATA;
  PDnsTxtData = PDNS_TXT_DATA;

  PDNS_NULL_DATA = ^DNS_NULL_DATA;
  {$EXTERNALSYM PDNS_NULL_DATA}
  DNS_NULL_DATA = record
    dwByteCount: DWORD;
    Data: array [0..0] of BYTE;
  end;
  {$EXTERNALSYM DNS_NULL_DATA}
  TDnsNullData = DNS_NULL_DATA;
  PDnsNullData = PDNS_NULL_DATA;

  PDNS_WKS_DATA = ^DNS_WKS_DATA;
  {$EXTERNALSYM PDNS_WKS_DATA}
  DNS_WKS_DATA = record
    IpAddress: IP4_ADDRESS;
    chProtocol: Byte;
    BitMask: array [0..0] of BYTE;
  end;
  {$EXTERNALSYM DNS_WKS_DATA}
  TDnsWksData = DNS_WKS_DATA;
  PDnsWksData = PDNS_WKS_DATA;

  PDNS_AAAA_DATA = ^DNS_AAAA_DATA;
  {$EXTERNALSYM PDNS_AAAA_DATA}
  DNS_AAAA_DATA = record
    Ip6Address: DNS_IP6_ADDRESS;
  end;
  {$EXTERNALSYM DNS_AAAA_DATA}
  TDnsAaaaData = DNS_AAAA_DATA;
  PDnsAaaaData = PDNS_AAAA_DATA;

  PDNS_SIG_DATA = ^DNS_SIG_DATA;
  {$EXTERNALSYM PDNS_SIG_DATA}
  DNS_SIG_DATA = record
    pNameSigner: PAnsiChar;
    wTypeCovered: WORD;
    chAlgorithm: BYTE;
    chLabelCount: BYTE;
    dwOriginalTtl: DWORD;
    dwExpiration: DWORD;
    dwTimeSigned: DWORD;
    wKeyTag: WORD;
    Pad: WORD; // keep byte field aligned
    Signature: array [0..0] of BYTE;
  end;
  {$EXTERNALSYM DNS_SIG_DATA}
  TDnsSigData = DNS_SIG_DATA;
  PDnsSigData = PDNS_SIG_DATA;

  PDNS_KEY_DATA = ^DNS_KEY_DATA;
  {$EXTERNALSYM PDNS_KEY_DATA}
  DNS_KEY_DATA = record
    wFlags: WORD;
    chProtocol: BYTE;
    chAlgorithm: BYTE;
    Key: array [0..1 - 1] of BYTE;
  end;
  {$EXTERNALSYM DNS_KEY_DATA}
  TDnsKeyData = DNS_KEY_DATA;
  PDnsKeyData = PDNS_KEY_DATA;

  PDNS_LOC_DATA = ^DNS_LOC_DATA;
  {$EXTERNALSYM PDNS_LOC_DATA}
  DNS_LOC_DATA = record
    wVersion: WORD;
    wSize: WORD;
    wHorPrec: WORD;
    wVerPrec: WORD;
    dwLatitude: DWORD;
    dwLongitude: DWORD;
    dwAltitude: DWORD;
  end;
  {$EXTERNALSYM DNS_LOC_DATA}
  TDnsLocData = DNS_LOC_DATA;
  PDnsLocData = PDNS_LOC_DATA;

  PDNS_NXT_DATA = ^DNS_NXT_DATA;
  {$EXTERNALSYM PDNS_NXT_DATA}
  DNS_NXT_DATA = record
    pNameNext: PAnsiChar;
    wNumTypes: WORD;
    wTypes: array [0..0] of WORD;
  end;
  {$EXTERNALSYM DNS_NXT_DATA}
  TDnsNxtData = DNS_NXT_DATA;
  PDnsNxtData = PDNS_NXT_DATA;

  PDNS_SRV_DATA = ^DNS_SRV_DATA;
  {$EXTERNALSYM PDNS_SRV_DATA}
  DNS_SRV_DATA = record
    pNameTarget: PAnsiChar;
    wPriority: WORD;
    wWeight: WORD;
    wPort: WORD;
    Pad: WORD; // keep ptrs DWORD aligned
  end;
  {$EXTERNALSYM DNS_SRV_DATA}
  TDnsSrvData = DNS_SRV_DATA;
  PDnsSrvData = PDNS_SRV_DATA;

  PDNS_ATMA_DATA = ^DNS_ATMA_DATA;
  {$EXTERNALSYM PDNS_ATMA_DATA}
  DNS_ATMA_DATA = record
    AddressType: BYTE;
    Address: array [0..DNS_ATMA_MAX_ADDR_LENGTH - 1] of BYTE;
    //  E164 -- Null terminated string of less than
    //      DNS_ATMA_MAX_ADDR_LENGTH
    //
    //  For NSAP (AESA) BCD encoding of exactly
    //      DNS_ATMA_AESA_ADDR_LENGTH
  end;
  {$EXTERNALSYM DNS_ATMA_DATA}
  TDnsAtmaData = DNS_ATMA_DATA;
  PDnsAtmaData = PDNS_ATMA_DATA;

  PDNS_TKEY_DATA = ^DNS_TKEY_DATA;
  {$EXTERNALSYM PDNS_TKEY_DATA}
  DNS_TKEY_DATA = record
    pNameAlgorithm: PAnsiChar;
    pAlgorithmPacket: PBYTE;
    pKey: PBYTE;
    pOtherData: PBYTE;
    dwCreateTime: DWORD;
    dwExpireTime: DWORD;
    wMode: WORD;
    wError: WORD;
    wKeyLength: WORD;
    wOtherLength: WORD;
    cAlgNameLength: Byte;
    bPacketPointers: LongBool
  end;
  {$EXTERNALSYM DNS_TKEY_DATA}
  TDnsTkeyData = DNS_TKEY_DATA;
  PDnsTkeyData = PDNS_TKEY_DATA;

  PDNS_TSIG_DATA = ^DNS_TSIG_DATA;
  {$EXTERNALSYM PDNS_TSIG_DATA}
  DNS_TSIG_DATA = record
    pNameAlgorithm: PAnsiChar;
    pAlgorithmPacket: PBYTE;
    pSignature: PBYTE;
    pOtherData: PBYTE;
    i64CreateTime: Int64;
    wFudgeTime: WORD;
    wOriginalXid: WORD;
    wError: WORD;
    wSigLength: WORD;
    wOtherLength: WORD;
    cAlgNameLength: Byte;
    bPacketPointers: LongBool;
  end;
  {$EXTERNALSYM DNS_TSIG_DATA}
  TDnsTsigData = DNS_TSIG_DATA;
  PDnsTsigData = PDNS_TSIG_DATA;

//
//  MS only types -- only hit the wire in MS-MS zone transfer
//

  PDNS_WINS_DATA = ^DNS_WINS_DATA;
  {$EXTERNALSYM PDNS_WINS_DATA}
  DNS_WINS_DATA = record
    dwMappingFlag: DWORD;
    dwLookupTimeout: DWORD;
    dwCacheTimeout: DWORD;
    cWinsServerCount: DWORD;
    WinsServers: array [0..0] of IP4_ADDRESS;
  end;
  {$EXTERNALSYM DNS_WINS_DATA}
  TDnsWinsData = DNS_WINS_DATA;
  PDnsWinsData = PDNS_WINS_DATA;

  PDNS_WINSR_DATA = ^DNS_WINSR_DATA;
  {$EXTERNALSYM PDNS_WINSR_DATA}
  DNS_WINSR_DATA = record
    dwMappingFlag: DWORD;
    dwLookupTimeout: DWORD;
    dwCacheTimeout: DWORD;
    pNameResultDomain: PAnsiChar;
  end;
  {$EXTERNALSYM DNS_WINSR_DATA}
  TDnsWinsrData = DNS_WINSR_DATA;
  PDnsWinsrData = PDNS_WINSR_DATA;


  _DnsRecordFlags = record
    //DWORD   Section     : 2;
    //DWORD   Delete      : 1;
    //DWORD   CharSet     : 2;
    //DWORD   Unused      : 3;
    //DWORD   Reserved    : 24;
    Flags: DWORD;
  end;
  {$EXTERNALSYM _DnsRecordFlags}
  DNS_RECORD_FLAGS = _DnsRecordFlags;
  {$EXTERNALSYM DNS_RECORD_FLAGS}
  TDnsRecordFlags = DNS_RECORD_FLAGS;
  PDnsRecordFlags = ^DNS_RECORD_FLAGS;

  PDNS_RECORD = ^DNS_RECORD;
  {$EXTERNALSYM PDNS_RECORD}
  _DnsRecord = record
    pNext: PDNS_RECORD;
    pName: PAnsiChar;
    wType: WORD;
    wDataLength: WORD; // Not referenced for DNS record types defined above.
    Flags: record
    case Integer of
      0: (DW: LongWord);             // flags as DWORD
      1: (S: DNS_RECORD_FLAGS);   // flags as structure
    end;
    dwTtl: DWORD;
    dwReserved: DWORD;

    //  Record Data

    Data: record
    case Integer of
       0: (A: DNS_A_DATA);
       1: (SOA, Soa_: DNS_SOA_DATA);
       2: (PTR, Ptr_,
           NS, Ns_,
           CNAME, Cname_,
           MB, Mb_,
           MD, Md_,
           MF, Mf_,
           MG, Mg_,
           MR, Mr_: DNS_PTR_DATA);
       3: (MINFO, Minfo_,
           RP, Rp_: DNS_MINFO_DATA);
       4: (MX, Mx_,
           AFSDB, Afsdb_,
           RT, Rt_: DNS_MX_DATA);
       5: (HINFO, Hinfo_,
           ISDN, Isdn_,
           TXT, Txt_,
           X25: DNS_TXT_DATA);
       6: (Null: DNS_NULL_DATA);
       7: (WKS, Wks_: DNS_WKS_DATA);
       8: (AAAA: DNS_AAAA_DATA);
       9: (KEY, Key_: DNS_KEY_DATA);
      10: (SIG, Sig_: DNS_SIG_DATA);
      11: (ATMA, Atma_: DNS_ATMA_DATA);
      12: (NXT, Nxt_: DNS_NXT_DATA);
      13: (SRV, Srv_: DNS_SRV_DATA);
      14: (TKEY, Tkey_: DNS_TKEY_DATA);
      15: (TSIG, Tsig_: DNS_TSIG_DATA);
      16: (WINS, Wins_: DNS_WINS_DATA);
      17: (WINSR, WinsR_, NBSTAT, Nbstat_: DNS_WINSR_DATA);
    end;
   end;
  {$EXTERNALSYM _DnsRecord}
  DNS_RECORD = _DnsRecord;
  {$EXTERNALSYM DNS_RECORD}
  PPDNS_RECORD = ^PDNS_RECORD;
  {$NODEFINE PPDNS_RECORD}
  TDnsRecord = DNS_RECORD;
  PDnsRecord = PDNS_RECORD;

//
//  IP Address Array type
//

type
   SunB = packed record
    s_b1, s_b2, s_b3, s_b4: Byte;
  end;
  {$EXTERNALSYM SunB}

  SunC = packed record
    s_c1, s_c2, s_c3, s_c4: Char;
  end;
  {$NODEFINE SunC}

  SunW = packed record
    s_w1, s_w2: Word;
  end;
  {$EXTERNALSYM SunW}

    in_addr = record
    case Integer of
      0: (S_un_b: SunB);
      1: (S_un_c: SunC);
      2: (S_un_w: SunW);
      3: (S_addr: LongWord);
    // #define s_addr  S_un.S_addr // can be used for most tcp & ip code
    // #define s_host  S_un.S_un_b.s_b2 // host on imp
    // #define s_net   S_un.S_un_b.s_b1  // netword
    // #define s_imp   S_un.S_un_w.s_w2 // imp
    // #define s_impno S_un.S_un_b.s_b4 // imp #
    // #define s_lh    S_un.S_un_b.s_b3 // logical host
  end;
  {$EXTERNALSYM in_addr}
  TInAddr = in_addr;
  PInAddr = ^in_addr;

function DnsQuery_A(pszName: PAnsiChar; wType: Word; Options: DWORD; aipServers: Pointer; ppQueryResults: PPDNS_RECORD; pReserved: Pointer): DNS_STATUS; stdcall;
{$EXTERNALSYM DnsQuery_A}

function inet_ntoa(inaddr: in_addr): PChar; stdcall;
{$EXTERNALSYM inet_ntoa}


function DnsQuery_A; external windns name 'DnsQuery_A';
function inet_ntoa; external winsock name 'inet_ntoa';

implementation

end.
