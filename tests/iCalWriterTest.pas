unit iCalWriterTest;

interface
uses
  DUnitX.TestFramework, iCalLib;

type

  [TestFixture]
  TiCalWriterTest = class(TObject)
  private
    fiCalFile: TiCalFile;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    [TestCase('Write Events', '..\..\referenceFiles\testWriterSingleEvent.ics, 1')]
    [TestCase('Write Events', '..\..\referenceFiles\testWriterThreeEvents.ics, 3')]
    procedure TestWrite(referenceFile: String; eventCount: Integer);
  end;

implementation

uses
  System.SysUtils, System.IOUtils, System.DateUtils;

procedure TiCalWriterTest.Setup;
begin
  fiCalFile := TiCalFile.Create;
end;

procedure TiCalWriterTest.TearDown;
begin
  fiCalFile.Free;
end;

procedure TiCalWriterTest.TestWrite(referenceFile: String; eventCount: Integer);
var
  event: TiCalEvent;
  acutalText: string;
  expectedText: string;
  i: Integer;
begin
  event := TiCalEvent.Create;
  event.Summary := 'Neujahr';
  event.UId := 'eigeneId';
  event.StartTime := StrToDateTime('01.01.2017');
  event.EndTime := StrToDateTime('01.01.2017');
  event.CreatedAt := StrToDateTime('05.01.2016');
  fiCalFile.Events.Add(event);

  for i := 1 to eventCount-1 do
  begin
    event := TiCalEvent.Create;
    event.Summary := 'Termin '+IntToStr(i);
    event.UId := 'eigeneId'+IntToStr(i);
    event.StartTime := StrToDateTime('01.01.2017 08:00');
    event.EndTime := StrToDateTime('01.01.2017 10:00');
    event.CreatedAt := StrToDateTime('05.01.2016');
    event.StartTime := IncHour(event.StartTime, i);
    event.EndTime := IncHour(event.EndTime, i);
    fiCalFile.Events.Add(event);
  end;

  fiCalFile.SaveToFile('..\..\test.ics');

  acutalText := TFile.ReadAllText('..\..\test.ics');
  expectedText := TFile.ReadAllText(referenceFile);
  Assert.AreEqual(expectedText, acutalText, true);
end;

initialization
  TDUnitX.RegisterTestFixture(TiCalWriterTest);
end.
