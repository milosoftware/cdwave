unit WDInfo;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, MMSystem;

type
  TWaveInfoForm = class(TForm)
    Button1: TButton;
    lDriverName: TStaticText;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    c1: TCheckBox;
    c2: TCheckBox;
    c4: TCheckBox;
    c8: TCheckBox;
    c16: TCheckBox;
    c32: TCheckBox;
    c64: TCheckBox;
    c128: TCheckBox;
    c256: TCheckBox;
    c512: TCheckBox;
    c1024: TCheckBox;
    c2048: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  public
    procedure ShowWaveInCapsOf(Driver: Integer);
    procedure ShowWaveInCaps(const Caps: TWaveInCaps);
  end;

//var
//  WaveInfoForm: TWaveInfoForm;

implementation

{$R *.DFM}

procedure TWaveInfoForm.ShowWaveInCapsOf(Driver: Integer);
var Caps: TWaveInCaps;
begin
  if WaveInGetDevCaps(Driver, @Caps, sizeof(Caps)) = 0
  then
    ShowWaveInCaps(Caps);
end;

procedure TWaveInfoForm.ShowWaveInCaps(const Caps: TWaveInCaps);
var Boxes: array[0..11] of TCheckBox;
var i, j: Integer;
begin
  Boxes[0] := c1;
  Boxes[1] := c2;
  Boxes[2] := c4;
  Boxes[3] := c8;
  Boxes[4] := c16;
  Boxes[5] := c32;
  Boxes[6] := c64;
  Boxes[7] := c128;
  Boxes[8] := c256;
  Boxes[9] := c512;
  Boxes[10] := c1024;
  Boxes[11] := c2048;
  lDriverName.Caption := Caps.szPname;
  j := 0;
  i := 1;
  while i <= 2048 do
  begin
    Boxes[j].Checked := (Caps.dwFormats and i) <> 0;
    i := i shl 1;
    inc(j);
  end;
end;

procedure TWaveInfoForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
