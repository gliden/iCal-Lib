unit iCalLib;

interface

uses
  System.Classes, System.Generics.Collections;

type
  TiCalPublishClass = (Private, Public);

  TiCalEvent = class(TObject)
  private
    FUId: String;
    FLocation: String;
    FSummary: String;
    FPublishClass: TiCalPublishClass;
    FStartTime: TDateTime;
    FEndTime: TDateTime;
    FCreatedAt: TDateTime;
  public
    constructor Create;

    property UId: String read FUId write FUId;
    property Location: String read FLocation write FLocation;
    property Summary: String read FSummary write FSummary;
    property PublishClass: TiCalPublishClass read FPublishClass write FPublishClass;
    property StartTime: TDateTime read FStartTime write FStartTime;
    property EndTime: TDateTime read FEndTime write FEndTime;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
  end;

  TiCalEventReader = class(TObject)
  private
    function ParseDateTime(s: String): TDateTime;
    function StrEscapedToString(s: String): String;
    procedure SplitEventRow(s: String; out name, value: String);
  public
    procedure AssignToEvent(data: TStrings; event: TiCalEvent);
  end;


  TiCalFile = class(TObject)
  private
    fFile: TStringList;
    FEvents: TObjectList<TiCalEvent>;
    FEventReader: TiCalEventReader;
  public
    constructor Create;
    destructor Destroy;override;
    procedure LoadFromFile(filename: String);

    property Events: TObjectList<TiCalEvent> read FEvents write FEvents;
  end;

implementation

uses
  System.SysUtils, System.DateUtils, System.TimeSpan;

{ TiCalEvent }

constructor TiCalEvent.Create;
var
  guid: TGUID;
begin
  guid := TGuid.NewGuid;
  fuid := guid.ToString;

  FCreatedAt := Now;
end;

{ TiCalFile }

constructor TiCalFile.Create;
begin
  fFile := TStringList.Create;
  fEvents := TObjectList<TiCalEvent>.Create;

  FEventReader := TiCalEventReader.Create;
end;

destructor TiCalFile.Destroy;
begin
  FEventReader.Free;
  FEvents.Free;
  fFile.Free;
  inherited;
end;

procedure TiCalFile.LoadFromFile(filename: String);
var
  i: Integer;
  eventList: TStringList;
  doAddToList: Boolean;
  event: TiCalEvent;
begin
  FEvents.Clear;
  fFile.Clear;
  fFile.LoadFromFile(filename, TEncoding.UTF8);

  eventList := TStringList.Create;
  try
    doAddToList := false;
    for i := 0 to fFile.Count-1 do
    begin
      if fFile[i].StartsWith('BEGIN:VEVENT', true) then
      begin
        doAddToList := true;
      end;

      if doAddToList then eventList.Add(fFile[i]);

      if fFile[i].StartsWith('END:VEVENT', true) then
      begin
        event := TiCalEvent.Create;
        FEventReader.AssignToEvent(eventList, event);
        fEvents.add(event);
        eventList.Clear;
        doAddToList := false;
      end;
    end;
  finally
    eventList.Free;
  end;
end;

{ TiCalEventReader }

procedure TiCalEventReader.AssignToEvent(data: TStrings;
  event: TiCalEvent);
var
  i: Integer;
  name: string;
  value: string;
begin
  for i := 0 to data.Count-1 do
  begin
    SplitEventRow(data[i], name, value);
    if SameText(name, 'UID') then event.UId := value else
    if SameText(name, 'Location') then event.Location := value else
    if SameText(name, 'Summary') then event.Summary := value else
//    if data[i].StartsWith('CLASS', true) then event.PublishClass := value else
    if SameText(name, 'DTStart') then event.StartTime := ParseDateTime(value) else
    if SameText(name, 'DTEnd') then event.EndTime := ParseDateTime(value) else
    if SameText(name, 'DTStamp') then event.CreatedAt := ParseDateTime(value);
  end;
end;

function TiCalEventReader.ParseDateTime(s: String): TDateTime;
var
  yearFrac: String;
  monthFrac: String;
  dayFrac: String;
  minuteFrac: String;
  hourFrac: String;
  secondFrac: String;
  isUTC: Boolean;
  tzLocal: TTimeZone;
  utcMinuteOffset: Int64;
begin
  yearFrac := s.Substring(0, 4);
  monthFrac := s.Substring(4, 2);
  dayFrac := s.Substring(6, 2);

  hourFrac := s.Substring(9,2);
  minuteFrac := s.Substring(11,2);
  secondFrac := s.Substring(13,2);

  isUTC := s.EndsWith('Z', true);

  Result := EncodeDateTime(yearFrac.ToInteger, monthFrac.ToInteger, dayFrac.ToInteger,
    hourFrac.ToInteger, minuteFrac.ToInteger, secondFrac.ToInteger, 0);

  if isUTC then
  begin
    tzLocal := TTimeZone.Local;
    utcMinuteOffset := Trunc(tzLocal.GetUtcOffset(Result).TotalMinutes);
    Result := IncMinute(Result, utcMinuteOffset);
  end;
end;

procedure TiCalEventReader.SplitEventRow(s: String; out name, value: String);
var
  i: Integer;
begin
  name := s;
  i := s.IndexOf(':');
  if i>=0 then
  begin
    name := s.Substring(0, i);
    value := s.Substring(i+1);
    value := StrEscapedToString(value);
  end;
end;

function TiCalEventReader.StrEscapedToString(s: String): String;
begin
  Result := s;
  Result := StringReplace(Result, '\\', '\', [rfReplaceAll]);
  Result := StringReplace(Result, '\,', ',', [rfReplaceAll]);
  Result := StringReplace(Result, '\;', ';', [rfReplaceAll]);
  Result := StringReplace(Result, '\n', #13#10, [rfReplaceAll]);
end;

end.
