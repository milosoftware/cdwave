unit ShellUtils;

interface

procedure AddAssociate(const ext, shortname, longname, action, actiondesc, command: string; AsDefault: boolean);

implementation

uses Windows, Registry, Sysutils;

resourcestring
  NoOpenStr = 'Unable to create/open registry key: "%s"';

procedure AddAssociate;
var
   Reg: TRegistry;
   Id:  string;
   newId: boolean;
begin
  Reg := TRegistry.Create;
  with Reg do try
    RootKey := HKEY_CLASSES_ROOT;
    if not Reg.OpenKey(ext, true) then
      raise Exception.Create(Format(NoOpenStr, [ext]));
    newId := ValueExists('');
    if newId then
      id := ReadString('')
    else begin
      id := shortname;
      WriteString('', id);
    end;
    if not OpenKey('\' + id, True) then
      raise Exception.Create(Format(NoOpenStr, [id]));
    if newId then
      WriteString('', longname);
    if not OpenKey('shell', True) then
      raise Exception.Create(Format(NoOpenStr, [id +'\shell']));
    if (AsDefault) then
      WriteString('', action);
    if not OpenKey(action, True) then
      raise Exception.Create(Format(NoOpenStr, [id +'\shell' + action]));
    WriteString('', actiondesc);
    if not OpenKey('command', True) then
      raise Exception.Create(Format(NoOpenStr, [id +'\shell' + action + '\command']));
    WriteString('', command);
  finally
    Reg.Free;
  end;
end;

end.

