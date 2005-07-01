unit SetSpeedMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, WaveIO, MMSystem, WaveUtil;

type
  TForm1 = class(TForm)
    btnPick: TButton;
    Label1: TLabel;
    lOldRate: TLabel;
    eNewRate: TEdit;
    Label3: TLabel;
    btnChange: TButton;
    Label4: TLabel;
    eFileName: TEdit;
    OpenDlg: TOpenDialog;
    procedure btnPickClick(Sender: TObject);
    procedure btnChangeClick(Sender: TObject);
  private
    { Private declarations }
    FWaveFile: HMMIO;
    ckInRIFF, ckIn: TMMCKInfo;
    FPCMWaveFormat: TWAVEFORMATEXTENSIBLE;
    FFormatPos: Integer;
  public
    { Public declarations }
    procedure Closefile;
    procedure OpenFile(filename: string);
    destructor Destroy; override;
  end;

var
  Form1: TForm1;

implementation

resourcestring
  NoRiffStr2 = 'Cannot open RIFF chunk, file is not a valid WAVE file';
  NoDescrStr = 'No fmt descriptor.';
  LengthStr = 'Bad fmt length.';
  TruncStr = 'Truncated file.';
  NoAscStr = 'Cannot ascend out fmt.';
  OnlyPCMStr = 'Bad format - only PCM format supported.';


{$R *.dfm}

procedure TForm1.btnPickClick(Sender: TObject);
begin
  if OpenDlg.Execute then
  begin
    CloseFile;
    Openfile(Opendlg.FileName);
  end;
end;

procedure TForm1.Closefile;
begin
  if FWaveFile <> 0 then
  begin
    mmioClose(FWaveFile, 0);
    lOldRate.Caption := '(No file)';
    eNewRate.Text := '(No file)';
    eNewRate.Enabled := false;
    btnChange.Enabled := false;
    eFileName.Text := '(No file)';
  end;
end;

destructor TForm1.Destroy;
begin
  CloseFile;
  inherited;
end;

procedure TForm1.OpenFile(filename: string);
var
  res: MMRESULT;
  Size: Cardinal;
begin
  FWaveFile := mmioOpen(PChar(filename), nil, MMIO_READWRITE);
  if FWaveFile = 0 then
    raise Exception.Create('Unable to open file');
  ckInRIFF.fccType := mmioStringToFOURCC('WAVE', 0);
  ckInRIFF.ckSize := 1024;
  ckInRIFF.dwFlags := 0;
  res := mmioDescend(FWaveFile, @ckInRIFF, nil, MMIO_FINDRIFF);
  if (res <> 0) and (res <> MMIOERR_INVALIDFILE) then
    raise Exception.Create(NoRiffStr2);
  if res = MMIOERR_INVALIDFILE then
  begin
      mmioSeek(FWaveFile, ckInRIFF.dwDataOffset + 4, SEEK_SET);
  end;
  FillChar(FPCMWaveFormat, SizeOf(FPCMWaveFormat), 0);
  ckIn.ckid := mmioStringToFOURCC('fmt ',0);
  if (ckInRIFF.cksize > $7FFFFFFF) then
  begin
      // Workaround 'invalid parameter' problems...
      Size := ckInRIFF.cksize;
      ckInRIFF.cksize := $10000;
      res := mmioDescend(FWaveFile, @ckIn, @ckInRIFF, MMIO_FINDCHUNK);
      ckInRIFF.cksize := Size;
  end else
      res := mmioDescend(FWaveFile, @ckIn, @ckInRIFF, MMIO_FINDCHUNK);
  if res <> 0 then
      raise Exception.Create(NoDescrStr);
  if ckIn.ckSize < sizeof(TWaveFormat) then
      raise Exception.Create(LengthStr);
  if ckIn.ckSize > sizeof(FPCMWaveFormat) then
        Size := sizeof(FPCMWaveFormat)
  else
        Size := ckIn.cksize;
  FFormatPos := mmioSeek(FWaveFile, 0, SEEK_CUR);
  if mmioRead(FWaveFile, @FPCMWaveFormat, Size) <> integer(Size) then
      raise Exception.Create(TruncStr);
  if not IsPCM(@FPCMWaveFormat.Format) then
      raise Exception.Create(OnlyPCMStr);

  lOldRate.Caption := IntToStr(FPCMWaveFormat.Format.nSamplesPerSec);
  eNewRate.Text := IntToStr(FPCMWaveFormat.Format.nSamplesPerSec);
  eNewRate.Enabled := true;
  btnChange.Enabled := true;
  eFileName.Text := filename;
end;

procedure TForm1.btnChangeClick(Sender: TObject);
var NewRate: Cardinal;
begin
  NewRate := StrToInt(eNewRate.Text);
  if FWaveFile = 0 then
    raise Exception.Create('No file is open');
  if FFormatPos < 0 then
    raise Exception.Create('Was unable to determine format location in file');
  if mmioSeek(FWaveFile, FFormatPos, SEEK_SET) < 0 then
    raise Exception.Create('Was unable to seek to format location in file');
  FPCMWaveformat.Format.nSamplesPerSec := NewRate;
  FPCMWaveformat.Format.nAvgBytesPerSec := NewRate * FPCMWaveformat.Format.nBlockAlign;
  if mmioWrite(FWavefile, @FPCMWaveFormat, sizeof(FPCMWaveFormat.Format) - 2) < 1 then
    raise Exception.Create('Failed to write changes to file');
  Closefile;
end;

end.
