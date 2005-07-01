unit Utils;

interface

type
  TWindowsVersion = (Unknown, Win95, Win95osr2, WinNT);

function GetWindowsVersion: TWindowsVersion;
function CalcDiskFreeSpace(const Drive: string): Int64;

implementation

uses Windows;

// The GetDiskFreeSpaceExA needs to be dynamically linked to
// enable the program to run on Win95 "pre osr2" releases.
type
  TGetDiskFreeSpaceExA = function (lpDirectoryName: PAnsiChar;
    lpFreeBytesAvailableToCaller, lpTotalNumberOfBytes,
    lpTotalNumberOfFreeBytes: PLargeInteger): BOOL; stdcall;

const
  DGetDiskFreeSpaceExA: TGetDiskFreeSpaceExA = nil;

function CalcDiskFreeSpaceOld(const Drive: string): Int64;
var spc, bps, nofc, toc: DWORD;
begin
  if GetDiskFreeSpace(PChar(Drive), spc, bps, nofc, toc) then
  begin
    Result := Int64(nofc) * (spc * bps);
  end else
    Result := -1;
end;

function CalcDiskFreeSpaceNew(const Drive: string): Int64;
var t: TLargeInteger;
begin
  t := 0;
  if not DGetDiskFreeSpaceExA(PChar(Drive), @Result, @t, nil) then
    Result := -1;
end;

function CalcDiskFreeSpace;
begin
  if @DGetDiskFreeSpaceExA = nil then
    Result := CalcDiskFreeSpaceOld(Drive)
  else
    Result := CalcDiskFreeSpaceNew(Drive);
end;


function GetWindowsVersion;
const WinVer: TWindowsVersion = Unknown;
procedure DoGet;
var
  VersionInfo: TOSVERSIONINFO;
begin
  FillChar(VersionInfo, sizeof(VersionInfo), 0);
  VersionInfo.dwOSVersionInfoSize := sizeof(VersionInfo);
  GetVersionEx(VersionInfo);
  if VersionInfo.dwPlatformId = VER_PLATFORM_WIN32_NT then
    WinVer := WinNT
  else
  begin
    if (VersionInfo.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS) and
       (LOWORD(VersionInfo.dwBuildNumber) > 1000) then
       WinVer := Win95osr2
    else
      WinVer := Win95;
  end;
end;
begin
  if WinVer = Unknown then DoGet;
  Result := WinVer;
end;

initialization
  if GetWindowsVersion >= Win95osr2 then
  begin
    @DGetDiskFreeSpaceExA := GetProcAddress(GetModuleHandle('KERNEL32'), 'GetDiskFreeSpaceExA');
  end;
end.
