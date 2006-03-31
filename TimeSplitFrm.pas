unit TimeSplitFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Buttons, ExtCtrls;

type
  TTimeSplitForm = class(TForm)
    GroupBox1: TGroupBox;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    btnHelp: TBitBtn;
    btnApply: TBitBtn;
    Label1: TLabel;
    eMinutes: TEdit;
    udMinutes: TUpDown;
    eSeconds: TEdit;
    udSeconds: TUpDown;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    cbFuzzy: TCheckBox;
    eSilence: TEdit;
    udSilence: TUpDown;
    Label4: TLabel;
    cbAtMarker: TCheckBox;
    Label5: TLabel;
    procedure btnApplyClick(Sender: TObject);
    procedure cbFuzzyClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses Main, Registry;
{$R *.DFM}

resourcestring
  SplitStr = 'Split interval must be more than zero.';
  SplitSmallFuzzStr = '"Within" must be smaller than half the split interval';
  AtMarkerStr = 'Start at the marker position (%s)';

procedure TTimeSplitForm.btnApplyClick(Sender: TObject);
var Every, fuzz, at: Cardinal;
begin
  if cbAtMarker.Checked then
    at := TMainForm(Owner).MarkerPos
  else
    at := 0;
  Every :=
    (StrToInt(eMinutes.Text) * 60) + StrToInt(eSeconds.Text);
  if Every = 0 then
    raise Exception.Create(SplitStr);
  if cbFuzzy.Checked then
  begin
    fuzz := StrToInt(eSilence.Text);
    if fuzz >= (Every div 2) then
      raise Exception.Create(SplitSmallFuzzStr);
    TMainForm(Owner).TimeSplitFuzzy(at, Every, fuzz);
  end else
    TMainForm(Owner).TimeSplit(at, Every);
end;

procedure TTimeSplitForm.cbFuzzyClick(Sender: TObject);
begin
  udSilence.Enabled := cbFuzzy.Checked;
  eSilence.Enabled := cbFuzzy.Checked;
end;

procedure TTimeSplitForm.FormShow(Sender: TObject);
var at: Cardinal;
begin
  at := TMainForm(Owner).MarkerPos;
  cbAtMarker.Caption :=
    Format(AtMarkerStr, [TMainForm(Owner).MakeTime(at)]);
  if (at <> 0) then cbAtMarker.Checked := False;
  cbAtMarker.Enabled := at <> 0;
end;

procedure TTimeSplitForm.FormCreate(Sender: TObject);
var Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  with Reg do
  try
    if OpenKey('SOFTWARE', False) and
       OpenKey('MiLo', False) and
       OpenKey('CDWAV', False)
    then
    try
        udMinutes.Position := (ReadInteger('TimeSplitMinutes'));
        udSeconds.Position := (ReadInteger('TimeSplitSeconds'));
        cbFuzzy.Checked := ReadBool('TimeSplitFuzzy');
        udSilence.Position := (ReadInteger('TimeSplitSilence'));
        cbFuzzyClick(nil);
    except
    end;
  finally
    Reg.Free;
    inherited;
  end;
end;

procedure TTimeSplitForm.FormDestroy(Sender: TObject);
var Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  with Reg do
  try
    if OpenKey('SOFTWARE', True) and
       OpenKey('MiLo', True) and
       OpenKey('CDWAV', True) then
    with Reg do begin
        WriteInteger('TimeSplitMinutes', StrToInt(eMinutes.Text));
        WriteInteger('TimeSplitSeconds', StrToInt(eSeconds.Text));
        WriteInteger('TimeSplitSilence', StrToInt(eSilence.Text));
        WriteBool('TimeSplitFuzzy', cbFuzzy.Checked);
    end;
  finally
    Reg.Free;
    inherited;
  end;
end;

end.
