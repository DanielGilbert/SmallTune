unit dgstCSVReader;

Interface

Uses
  Windows,
  dgstSysUtils;

Type
  TStringPos = Record
    spFirst: PChar;
    spLen: Integer;
  End;

  TCSVReader = Class
  private
    fBuffer, fPos, fEnd: PAnsiChar;
    fSize: Integer;
    fQuote,
    fDelimiter: AnsiChar;
    fInternalBuffer: Array of Char;
    fAtEOF, fIsEOF: Boolean;
    fColumns: Array Of TStringPos;
    fColumnCount: Integer;
    fEOLChar: Char;
    fEOLLength: Integer;
    Function GetColumnByIndex(Index: Integer): String;
    Procedure SetEOLChar(Const Value: Char);
    Procedure Initialize;
  public
// Wenn kein Delimiter angegeben wird, wird das Listentrennzeichen aus den
// internationalen Einstellungen von Windows verwendet.
    Constructor Create(csvData: String; aDelimiter: Char = #0);
    Destructor Destroy; override;
// Bewegt den internen Positionszeiger auf die erste Zeile der Datei
    Procedure First(hasHeader: boolean);
// Bewegt den internen Positionszeiger auf die n?chste Zeile der Datei
    Function Next: Boolean;
// Liefert TRUE, wenn keine Daten mehr abgerufen werden k?nnen.
    Function Eof: Boolean;
// Liefert oder setzt das Trennzeichen
    Property Delimiter: Char read fDelimiter write fDelimiter;
// Liefert oder setzt das Quote-Zeichen
    Property Quote: Char read fQuote write fQuote;
// Liefert oder setzt das EOL-Zeichen (Windows #13, UNIX #10)
    Property EOLChar: Char read fEOLChar write SetEOLChar;
// Liefert oder setzt die L?nge der EOL-Zeichen (Windows : 2 [CR+LF], UNIX: 1 [LF])
    Property EOLLength: Integer read fEOLLength write fEOLLength;
// Liefert die Anzahl der Elemente der aktuellen Zeile
    Property ColumnCount: Integer read fColumnCount;
// Liefert die einzelnen Elemente der aktuellen Zeile
    Property Columns[Index: Integer]: String read GetColumnByIndex; default;
  End;
Implementation

{ TCSVReader }

Constructor TCSVReader.Create(csvData: AnsiString; aDelimiter: Char);
Begin
  fSize := Length(csvData) + 2;
  SetLength(fInternalBuffer, fSize);
  ReallocMem(fBuffer, fSize);
  StrLCopy(fBuffer, PChar(csvData), fSize);
  fBuffer[fSize - 1] := #0;
  fBuffer[fSize - 2] := #10;
  fPos := fBuffer;
  fEOLChar := #10;
  fEOLLength := 1;
  fEnd := fBuffer + fSize - 1;
  If aDelimiter = #0 Then
    fDelimiter := ListSeparator
  Else
    fDelimiter := aDelimiter;

  fQuote := '"';
  setLength(fColumns, 100);
  Initialize;
End;

Destructor TCSVReader.Destroy;
Begin
  FreeMemory(fBuffer);
  Inherited;
End;

Function TCSVReader.Eof: Boolean;
Begin
  Result := fIsEOF;
End;

Procedure TCSVReader.First(hasHeader: boolean);
Begin
  Initialize;
  Next;
  if (hasHeader) then
  Next;
End;

Function TCSVReader.GetColumnByIndex(Index: Integer): String;
Var
  p: PChar;
  i, l: Integer;

Begin
  With fColumns[Index] Do
    If spLen = 0 Then
    Begin
      Result := '';
    End
    Else If spFirst^ = fQuote Then Begin
      setLength(Result, spLen - 2);
      p := spFirst + 1;
      l := spLen - 2;
      For i := 1 To spLen - 2 Do Begin
        Result[i] := p^;
        If (p^ = fQuote) And (p[1] = fQuote) Then Begin
          dec(l);
          inc(p, 2)
        End
        Else
          inc(p);
      End;
      SetLength(Result, l);
    End
    Else
      SetString(Result, spFirst, spLen);
End;

Procedure TCSVReader.Initialize;
Begin
  fPos := fBuffer;
  fIsEOF := False;
  fAtEOF := False;
  fColumnCount := 0;
End;

Function TCSVReader.Next: Boolean;
Var
  p: PChar;
  pPrev: PChar;

  Procedure _GetString;
  Begin
    Repeat
      inc(p);
      If p^ = fQuote Then
        If p[1] = fQuote Then
          inc(p)
        Else
          break;
    Until False;
    inc(p);
  End;

Begin
  pPrev := fPos;
  p := fPos;
  fColumnCount := 0;
  If fAtEOF Then
    If Eof Then
      Result := false
    Else Begin
      fIsEOF := True;
      Exit;
    End;
  If p^ = fQuote Then _GetString;
  While p^ <> fEOLChar Do Begin
    If p^ = fDelimiter Then Begin
      If fColumnCount = Length(fColumns) Then
        SetLength(fColumns, 2 * Length(fColumns));
      fColumns[fColumnCount].spFirst := pPrev;
      fColumns[fColumnCount].spLen := p - pPrev;
      inc(fColumnCount);
      inc(p);
      pPrev := p;
      If p^ = fQuote Then _GetString;
    End
    Else
      inc(p);
  End;
  If p <> fPos Then Begin
    If fColumnCount = Length(fColumns) Then
      SetLength(fColumns, Length(fColumns) + 1);
    fColumns[fColumnCount].spFirst := pPrev;
    fColumns[fColumnCount].spLen := p - pPrev;
    inc(fColumnCount);
  End;
  fPos := p;
  If (fPos[1] = #0) Then
  begin
    fAtEOF := True;
    fIsEOF := True;
  end
  Else
    inc(fPos, fEOLLength);

  Result := True;
End;

Procedure TCSVReader.SetEOLChar(Const Value: Char);
Begin
  If fEOLChar <> Value Then Begin
    fEOLChar := Value;
    fBuffer[fSize - 2] := fEOLChar;
  End;
End;

End.
