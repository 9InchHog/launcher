[Setup]
AppName=SpoonLite Launcher
AppPublisher=SpoonLite
UninstallDisplayName=SpoonLite
AppVersion=@project.version@
AppSupportURL=https://discord.gg/mZvA6My
DefaultDirName={localappdata}\SpoonLite
; vcredist queues files to be replaced at next reboot, however it doesn't seem to matter
RestartIfNeededByRun=no

; ~30 mb for the repo the launcher downloads
ExtraDiskSpaceRequired=30000000
ArchitecturesAllowed=x86 x64
PrivilegesRequired=lowest

WizardSmallImageFile=@basedir@/innosetup/SpoonLite.bmp
SetupIconFile=@basedir@/SpoonLite.ico
UninstallDisplayIcon={app}\SpoonLite.exe

Compression=lzma2
SolidCompression=yes

OutputDir=@basedir@/release
OutputBaseFilename=SpoonLiteSetup32

[Tasks]
Name: DesktopIcon; Description: "Create a &desktop icon";

[Files]
Source: "@basedir@\native-win32\SpoonLite.exe"; DestDir: "{app}"
Source: "@basedir@\native-win32\SpoonLite-shaded.jar"; DestDir: "{app}"
Source: "@basedir@\native-win32\config.json"; DestDir: "{app}"
Source: "@basedir@\native-win32\jre\*"; DestDir: "{app}\jre"; Flags: recursesubdirs
Source: "@basedir@\vcredist_x86.exe"; DestDir: {tmp}; Flags: deleteafterinstall

[Icons]
; start menu
Name: "{userprograms}\SpoonLite"; Filename: "{app}\SpoonLite.exe"
Name: "{userdesktop}\SpoonLite"; Filename: "{app}\SpoonLite.exe"; Tasks: DesktopIcon

[Run]
Filename: "{tmp}\vcredist_x86.exe"; Check: VCRedistNeedsInstall; Parameters: "/install /quiet /norestart"; StatusMsg: "Installing VC++ 2013 (x86) Redistributables..."
Filename: "{app}\SpoonLite.exe"; Description: "&Open SpoonLite"; Flags: postinstall skipifsilent nowait

[InstallDelete]
; Delete the old jvm so it doesn't try to load old stuff with the new vm and crash
Type: filesandordirs; Name: "{app}"

[UninstallDelete]
Type: filesandordirs; Name: "{%USERPROFILE}\.openosrs\repository2"

; Code to check if installing the redistributables is necessary - https://stackoverflow.com/a/11172939/7189686
[Code]
type
  INSTALLSTATE = Longint;
const
  INSTALLSTATE_INVALIDARG = -2;  { An invalid parameter was passed to the function. }
  INSTALLSTATE_UNKNOWN = -1;     { The product is neither advertised or installed. }
  INSTALLSTATE_ADVERTISED = 1;   { The product is advertised but not installed. }
  INSTALLSTATE_ABSENT = 2;       { The product is installed for a different user. }
  INSTALLSTATE_DEFAULT = 5;      { The product is installed for the current user. }

  { Visual C++ 2013 Redistributable 12.0.30501 }
  VC_2013_REDIST_X86_MIN = '{13A4EE12-23EA-3371-91EE-EFB36DDFFF3E}';
  VC_2013_REDIST_X86_ADD = '{F8CFEB22-A2E7-3971-9EDA-4B11EDEFC185}';

function MsiQueryProductState(szProduct: string): INSTALLSTATE;
  external 'MsiQueryProductStateA@msi.dll stdcall';

function VCVersionInstalled(const ProductID: string): Boolean;
begin
  Result := MsiQueryProductState(ProductID) = INSTALLSTATE_DEFAULT;
end;

function VCRedistNeedsInstall: Boolean;
begin
  Result := not (VCVersionInstalled(VC_2013_REDIST_X86_MIN) and
    VCVersionInstalled(VC_2013_REDIST_X86_MIN));
end;