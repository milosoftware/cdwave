unit working;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, ComCtrls,
  Buttons, ExtCtrls, MMSystem, msacm, WaveUtil, WaveIO, WaveWriters,
  lame_enc, vorbis, FLAC, APE,
  FLAC_Enc, AKRip32, MyAspi32{,
  ACS_procs};

const
{$IFDEF DISP}
  ReadBufferMult  = 75;
{$ELSE}
  ReadBufferMult  = 256;
{$ENDIF}

type
  TLoadingDlg = class(TForm)
    btnAbort: TBitBtn;
    GroupBox1: TGroupBox;
    lDescription: TLabel;
    Gauge: TProgressBar;
    procedure btnAbortClick(Sender: TObject);
  private
    { Private declarations }
    Canceled: Boolean;
  public
    { Public declarations }
    procedure LoadFile(
        WaveFile: TWaveFile;
        WaveSize: Cardinal;
        StatsList: PSectorStatsList;
        StatsSize: Cardinal;
        SectorSize: Cardinal;
        BitsPerSample: Word);
    procedure SaveTracks(
        Tracks: TListItems;
        WaveFile: TWaveFile;
        Directory: String;
        Format: PWaveFormatEx;
        ConvertToFormat: PWaveFormatEx);
    procedure DAE(
        CDHandle: HCDROM;
        FileName: string;
        JitterCorrect: boolean;
        out StatsHandle: HGLOBAL;
        out SectorStatsSize: Cardinal;
        out DataSize: Cardinal;
        TrackList: TList);
  end;



implementation

uses SelectDirFrm
{$IFDEF DISP}
         ,DisplayFormTest
{$ENDIF}
;


// -----

resourcestring
  CancelStr = 'Cancelled by user.';
  WriteStr = 'Writing tracks';
  NoSeekInStr = 'Seek failed on input file.';
  WritingStr = 'Writing: ';
  NoReadStr2 = 'Unable to read source file.';
  ZeroBytesStr = 'Reported 0 bytes written, cannot continue.';
  DAEErr = 'Error during audio extraction';
  DAEStr = 'Digital Audio Extraction';

{-----------------------------------------------------------------------------}


{$R *.DFM}
procedure TLoadingDlg.LoadFile;
var
   i, Carry, NumRead, NumToRead: Cardinal;
   Sector: PChar;
   BufferSize: Cardinal;
begin
  Canceled := False;
  Gauge.Min := 0;
  Gauge.Position := 0;
  Gauge.Max := StatsSize;
  Carry := 0;
  lDescription.Caption := ReadStr;
{$IFDEF DISP}
  DisplayForm.InitFile((StatsSize * SectorSize) shr 2);
{$ENDIF}
  BufferSize := SectorSize * ReadBufferMult;
  Sector := PChar(GlobalAlloc(GMEM_FIXED, BufferSize)); //  GetMem(Sector, BufferSize);
  if Sector = nil then
    raise Exception.Create(NoAllocMemStr);
  try
    Show;
    EnableWindow(TForm(Owner).Handle, False);
    i := 0;
    while i < StatsSize do
    begin
      if WaveSize < BufferSize then
         NumToRead := WaveSize
      else
         NumToRead := BufferSize;
      NumRead := WaveFile.Read(Sector, NumToRead);
      if NumRead = 0 then break;
      dec(WaveSize, NumRead);
      inc(i, FillSectorStats(
        StatsList, i, Carry,
        Sector, NumRead,  SectorSize, BitsPerSample));
{$IFDEF DISP}
      DisplayForm.Analyze(Sector, NumRead shr 2);
{$ENDIF}
//      if (i and $7F)=0 then
      begin
        Gauge.Position := i;
        Application.ProcessMessages;
        if Canceled then raise Exception.Create(CancelStr);
      end;
    end;
  finally
    GlobalFree(Cardinal(Sector)); // FreeMem(Sector, BufferSize);
    EnableWindow(TForm(Owner).Handle, True);
    Hide;
  end;
end;

procedure TLoadingDlg.SaveTracks;
var At: Cardinal;
    ToRead, TotWritten, ToWrite, BytesWritten, BytesLeft: Cardinal;
    GaugePosition: Cardinal;
    WaveWriter: TWaveWriter;
    Buffer: PChar;
    BufferSize: Cardinal;
begin
  ToWrite := 0;
  with Tracks do
    for At := 0 to Count-1 do
      if Item[At].Checked then inc(ToWrite, PSplitInfo(Item[At].Data).Size);
  Canceled := False;
  Gauge.Min := 0;
  Gauge.Position := 0;
  GaugePosition := 0;
  Gauge.Max := ToWrite shr 1; // avoid out-of-range...
  lDescription.Caption := WriteStr;
  WaveWriter := CreateWaveWriter(Format, ConvertToFormat);
  try
      EnableWindow(TForm(Owner).Handle, False);
      Show;
      Screen.Cursor := crHourGlass;
      Application.ProcessMessages;
      with Tracks do
      begin
        for At := 0 to Count-1 do
        if Item[At].Checked then
        begin
          WaveFile.SetFilePos(PSplitInfo(Item[At].Data).Start);
          ToWrite := PSplitInfo(Item[At].Data).Size;
          WaveWriter.FileName := Directory + Item[At].Caption + '.wav';
          WaveWriter.ToWrite := ToWrite;
          lDescription.Caption := WritingStr + Item[At].Caption;
          try
            TotWritten := 0;
            WaveWriter.InitFile;
            Buffer := WaveWriter.Buffer;
            BufferSize := WaveWriter.BufferSize;
            repeat
              if (ToWrite - TotWritten) > BufferSize then
                ToRead := BufferSize
              else begin
                ToRead := ToWrite - TotWritten;
                WaveWriter.IsLastWrite;
              end;
              if (ToRead <> 0) and
                 (WaveFile.Read(Buffer, ToRead) <> ToRead) then
                  raise Exception.Create(NoReadStr2);
              BytesWritten := WaveWriter.write(ToRead);
              if BytesWritten = 0 then raise Exception.Create(ZeroBytesStr);
              Buffer := WaveWriter.Buffer;
              BytesLeft := ToRead - BytesWritten;
              if BytesLeft <> 0 then
              begin
                Move(Buffer[BytesWritten], Buffer^, BytesLeft);
                Buffer := @Buffer[BytesLeft];
              end;
              BufferSize := WaveWriter.BufferSize - BytesLeft;
              inc(TotWritten, ToRead);
              inc(GaugePosition, ToRead);
              Gauge.Position := integer(GaugePosition shr 1);
              Application.ProcessMessages;
              if Canceled then raise Exception.Create(CancelStr);
            until (TotWritten = ToWrite);
          finally
            WaveWriter.DoneFile;
          end;
        end;
      end;
  finally
    WaveWriter.Free;
    EnableWindow(TForm(Owner).Handle, True);
    Hide;
    Screen.Cursor := crDefault;
  end;
end;

procedure TLoadingDlg.DAE;
const
  FramesPerRead = 23;
var
  PBuf, POverlap: PTRACKBUF;
  liStatus: Integer;
  ToFile: HMMIO;
  MyTOC: TOC;
  ckOutRIFF, ckOut: TMMCKInfo;
  StartSector, EndSector, TotalSectors, Frames, Sector, i: Cardinal;
  SectorStatsList: PSectorStatsList;
  Data: PChar;
begin
  FillChar(MyToc, sizeof(MyTOC), 0);
  Screen.Cursor := crHourglass;
  Canceled := False;
  try
    ModifyCDParms(CDHandle, CDP_MSF, DWORD(true));
    if ReadTOC(CDHandle, MyTOC, false) <> 1 then
      raise Exception.Create(ReadTOCError);
    PBuf := newTrackBuf(FramesPerRead);
    if JitterCorrect then POverlap := newTrackBuf(3) else POverlap := nil;
    //StartSector := MSFtoLBA(MyTOC.tracks[myTOC.firstTrack-1].addr);
    //EndSector := MSFtoLBA(MyTOC.tracks[myTOC.lastTrack].addr);
    StartSector := BigToLittleEndian(MyTOC.tracks[myTOC.firstTrack-1].addr);
    EndSector := BigToLittleEndian(MyTOC.tracks[myTOC.lastTrack].addr);
    TotalSectors := EndSector - StartSector;
    DataSize := TotalSectors * 2352;
    SectorStatsSize := TotalSectors;
    StatsHandle := GlobalAlloc(GHND, TotalSectors * SizeOf(TSectorStats));
    if StatsHandle = 0 then
      raise EOSError.Create(
        NoAllocMemStr + #13#10 + SysErrorMessage(GetLastError));
    SectorStatsList := PSectorStatsList(GlobalLock(StatsHandle));
    try
      ToFile := OpenWaveFile(FileName, nil, GENERIC_WRITE, CREATE_ALWAYS);
      WriteWaveHeader(ToFile, ckOutRIFF, ckOut, @RedBookFormat, DataSize);
      Gauge.Min := 0;
      Gauge.Max := EndSector;
      lDescription.Caption := DAEStr;
      EnableWindow(TForm(Owner).Handle, False);
      Show;
      try
        Sector := 0;
        while StartSector < EndSector do
        begin
          Gauge.Position := StartSector;
          Application.ProcessMessages;
          if Canceled then raise Exception.Create(CancelStr);
          PBuf^.startFrame := StartSector;
          Frames := EndSector - StartSector;
          if Frames > FramesPerRead then Frames := FramesPerRead;
          PBuf^.numFrames := Frames;
          if JitterCorrect then
            liStatus := ReadCDAudioLBAEx(CDHandle, PBuf, POverlap)
          else
            liStatus := ReadCDAudioLBA(CDHandle, PBuf);
          if liStatus = SS_ERR then raise Exception.Create(DAEErr);
          Data := PChar(Addr(PBuf^.buf)) + PBuf^.startOffset;
          if mmioWrite(Tofile, Data, PBuf^.len) <> Integer(PBuf^.len) then
             raise Exception.Create(NoWriteStr);
          for i := 0 to (PBuf^.len div 2352)-1 do
          begin
            SectorStatsList[Sector] := SectorLevel16(Data, 2352 shr 2);
            inc(sector);
            inc(Data, 2352);
          end;
          inc(StartSector, PBuf.numFrames);
        end;
        TrackList.Capacity := myTOC.lastTrack - myTOC.firstTrack + 1;
        //StartSector := MSFtoLBA(MyTOC.tracks[myTOC.firstTrack-1].addr);
        StartSector := BigToLittleEndian(MyTOC.tracks[myTOC.firstTrack-1].addr);
        for i := myTOC.firstTrack-1 to myTOC.lastTrack-1 do
        begin
          //Sector := MSFtoLBA(MyTOC.tracks[i].addr);
          Sector := BigToLittleEndian(MyTOC.tracks[i].addr);
          TrackList.Add(Pointer((Sector - StartSector) * 2352));
        end;
      finally
        mmioAscend(ToFile, @ckOut, 0);
        mmioAscend(ToFile, @ckOutRIFF, 0);
        mmioClose(ToFile, 0);
        DisposeTrackBuf(PBuf);
        if JitterCorrect then DisposeTrackBuf(POverlap);
        EnableWindow(TForm(Owner).Handle, True);
        Hide;
      end;
    except
      GlobalUnLock(StatsHandle);
      GlobalFree(StatsHandle);
      raise;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TLoadingDlg.btnAbortClick(Sender: TObject);
begin
  Canceled := True;
end;

end.
