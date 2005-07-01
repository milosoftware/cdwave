unit Ultils;

interface

function CalcDiskFreeSpace(const Drive: string): Real;

implementation

function CalcDiskFreeSpace(const Drive: string): Real;
var spc, bps, nofc, toc: Integer;
begin
  if GetDiskFreeSpace(PChar(Drive), spc, bps, nofc, toc) then
  begin
    Result := nofc * spc * bps;
  end else
    Result := -1;
end;

end.
 