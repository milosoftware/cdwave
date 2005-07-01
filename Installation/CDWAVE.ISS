[Setup]
AppName=CD Wave
AppVerName=CD Wave Editor version 1.94.1
AppVersion=1.94.1
VersionInfoVersion=1.9.4.7
VersionInfoTextVersion=1.94.1
AppCopyright=Copyright © 1997-2005 Mike Looijmans
DefaultDirName={pf}\CD Wave
DefaultGroupName=CD Wave
UninstallDisplayIcon={app}\CDWav.exe
Compression=lzma/max
SolidCompression=yes
AppPublisher=MiLo Software
AppPublisherURL=http://www.cdwave.com/
AppSupportURL=http://www.cdwave.com/contact.html
AppUpdatesURL=http://www.cdwave.com/download.html
DisableStartupPrompt=yes
LicenseFile=license.txt
VersionInfoDescription=CD Wave Editor Setup

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "nl"; MessagesFile: "compiler:Languages/Dutch.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"
Name: "quicklaunchicon"; Description: "Create a &Quick Launch icon"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
Source: "..\Execute\CDWav.exe"; DestDir: "{app}"
Source: "..\Execute\CDWav.nld"; DestDir: "{app}"
Source: "..\Execute\CDWav.hlp"; DestDir: "{app}"
Source: "..\Execute\CDWav.cnt"; DestDir: "{app}"
Source: "..\Execute\vorbis.dll"; DestDir: "{app}"
Source: "..\Execute\libFLAC.dll"; DestDir: "{app}"
Source: "..\Execute\MyAKRIP.dll"; DestDir: "{app}"
Source: "..\Execute\MACDll.dll"; DestDir: "{app}"
Source: "..\Execute\lame_enc.dll"; DestDir: "{app}"
Source: "unicows.dll"; DestDir: "{sys}"; Flags: uninsneveruninstall

; Source: "Readme.txt"; DestDir: "{app}"; Flags: isreadme

[Icons]
Name: "{group}\CD Wave Editor"; Filename: "{app}\CDWav.exe"
Name: "{userdesktop}\CD Wave Editor"; Filename: "{app}\CDWav.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\CD Wave Editor"; Filename: "{app}\CDWav.exe"; Tasks: quicklaunchicon

