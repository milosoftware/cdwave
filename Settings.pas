unit Settings;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, MMsystem, MMUtil, NumericUpDown;

const
  CDWAVRegKey = 'SOFTWARE\MiLo\CDWAV';

type
  TSettingsDialog = class(TForm)
    PerfBoost: TRadioGroup;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    btnHelp: TBitBtn;
    gbColors: TGroupBox;
    gbLayout: TGroupBox;
    cbFlat: TCheckBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    ColorDialog1: TColorDialog;
    gbRecording: TGroupBox;
    tbRecMode: TTrackBar;
    lCompatibility: TLabel;
    lPerformance: TLabel;
    Label1: TLabel;
    gbConfirm: TGroupBox;
    cbConfChanges: TCheckBox;
    gbPlayback: TGroupBox;
    cbOutDevice: TComboBox;
    Label2: TLabel;
    btnAssociations: TBitBtn;
    cbRewindOnStop: TCheckBox;
    cbFollowPlayback: TCheckBox;
    cbSplitAtMarker: TCheckBox;
    Label3: TLabel;
    udRefreshRate: TNumericUpDown;
    Label4: TLabel;
    procedure btnHelpClick(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAssociationsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses Registry, FileAssociations;

{$R *.DFM}

{function GetNiceColor(index: Integer): Integer;
begin
  index := (index mod 7) + 1;
  Result :=
   (index and 4) shl 5 or
   (index and 2) shl 14 or
   (index and 1) shl 23;
end;}

procedure TSettingsDialog.btnHelpClick(Sender: TObject);
begin
  Application.HelpContext(3001);
end;

procedure TSettingsDialog.Panel1Click(Sender: TObject);
begin
  with ColorDialog1 do
  begin
    Color := TPanel(Sender).Color;
    if Execute then
      TPanel(Sender).Color := Color;
  end;
end;

procedure TSettingsDialog.FormCreate(Sender: TObject);
var Reg: TRegistry;
    Clr: Array[0..7] of Integer;
    DriverName: string;
    i: Integer;
procedure GetDrivers;
var i: Integer;
begin
  cbOutDevice.Items.Clear;
  for i := -1 to waveOutGetNumDevs - 1 do
  begin
    cbOutDevice.Items.Add(GetWaveOutName(i));
  end;
  cbOutDevice.ItemIndex := 0;
end;
begin
  GetDrivers;
  Reg := TRegistry.Create;
  with Reg do
  try
    if OpenKey(CDWAVRegKey, False) then
       try
         PerfBoost.ItemIndex := ReadInteger('PerfBoost');
         cbFlat.Checked := ReadBool('Flat');
         ReadBinaryData('Color', Clr, sizeof(clr));
         Panel1.Color := Clr[0];
         Panel2.Color := Clr[1];
         Panel3.Color := Clr[2];
         Panel4.Color := Clr[3];
         Panel5.Color := Clr[4];
         Panel6.Color := Clr[5];
         Panel7.Color := Clr[6];
         Panel8.Color := Clr[7];
         tbRecMode.Position := ReadInteger('RecThdMode');
         cbConfChanges.Checked := ReadBool('ConfChanges');
         DriverName := ReadString('OutputDevice');
         i := cbOutDevice.Items.IndexOf(DriverName);
         if i >= 0 then
           cbOutDevice.ItemIndex := i;
         cbFollowPlayback.Checked := ReadBool('FollowPlayback');
         cbRewindOnStop.Checked := ReadBool('RewindOnStop');
         cbSplitAtMarker.Checked := ReadBool('SplitOnMarker');
         udRefreshRate.Value := ReadInteger('PlaybackRefresh');
       except
       end;
  finally
    Reg.Free;
  end;
end;

procedure TSettingsDialog.btnOKClick(Sender: TObject);
var Reg: TRegistry;
    Clr: Array[0..7] of Integer;
begin
  Reg := TRegistry.Create;
  with Reg do
  try
    if OpenKey(CDWAVRegKey, True) then
    begin
         WriteInteger('PerfBoost', PerfBoost.ItemIndex);
         WriteBool('Flat', cbFlat.Checked);
         Clr[0] := Panel1.Color;
         Clr[1] := Panel2.Color;
         Clr[2] := Panel3.Color;
         Clr[3] := Panel4.Color;
         Clr[4] := Panel5.Color;
         Clr[5] := Panel6.Color;
         Clr[6] := Panel7.Color;
         Clr[7] := Panel8.Color;
         WriteBinaryData('Color', Clr, sizeof(clr));
         WriteInteger('RecThdMode', tbRecMode.Position);
         WriteBool('ConfChanges', cbConfChanges.Checked);
         WriteString('OutputDevice', cbOutDevice.Text);
         WriteBool('FollowPlayback', cbFollowPlayback.Checked);
         WriteBool('RewindOnStop', cbRewindOnStop.Checked);
         WriteBool('SplitOnMarker', cbSplitAtMarker.Checked);
         WriteInteger('PlaybackRefresh', udRefreshRate.Value);
    end;
  finally
    Reg.Free;
  end;
end;

procedure TSettingsDialog.btnAssociationsClick(Sender: TObject);
begin
  with TFileAssociationDlg.Create(self) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

end.

