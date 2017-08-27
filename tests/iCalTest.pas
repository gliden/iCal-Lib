unit iCalTest;

interface
uses
  DUnitX.TestFramework, iCalLib;

type
  [TestFixture]
  TiCalTest = class(TObject)
  private
    fiCalFile: TiCalFile;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestSubject;
    [Test]
    procedure TestLocation;
    [Test]
    procedure TestTime;
  end;

implementation

uses
  System.DateUtils, System.SysUtils;

procedure TiCalTest.Setup;
begin
  fiCalFile := TiCalFile.Create;
  fiCalFile.LoadFromFile('..\..\testfile.ics');
end;

procedure TiCalTest.TearDown;
begin
  fiCalFile.Free;
end;


procedure TiCalTest.TestTime;
begin
  Assert.AreEqual(StrToDateTime('26.08.2017 17:30:00'), fiCalFile.Events.First.StartTime, 'StartTime');
  Assert.AreEqual(StrToDateTime('26.08.2017 23:00:00'), fiCalFile.Events.First.EndTime, 'EndTime');
  Assert.AreEqual(StrToDateTime('12.08.2017 12:59:00'), fiCalFile.Events.First.CreatedAt, 'TimeStamp');
end;

procedure TiCalTest.TestLocation;
begin
  Assert.AreEqual('Oderbruchstraﬂe 24, 10369 Berlin', fiCalFile.Events.First.Location, true);
end;

procedure TiCalTest.TestSubject;
begin
  Assert.AreEqual('Something', fiCalFile.Events.First.Summary, true);
end;

initialization
  TDUnitX.RegisterTestFixture(TiCalTest);
end.
