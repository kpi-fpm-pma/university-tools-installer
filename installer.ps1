param(
    [switch] $InstallVSCode = $false,
    [switch] $InstallPython = $false,
    [switch] $InstallGit    = $false,
    [switch] $InstallGCC    = $false
)

#Push-Location ..
$CurrentPath = (Get-Location).Path

$CurrentPythonVersion = "3.9.1"
$CurrentGitVersion    = "v2.29.2.windows.3/Git-2.29.2.3"
$CurrentMinGWVersion  = "8.1.0"
$CurrentMinGWRevision = "rt_v6-rev0"
$MinGWThreadType      = "win32" # "posix"

function Install-VSCode {
    $VSInstallerURL  = "https://code.visualstudio.com/sha/download?build=stable&os="
    $VSInstallerURL += $(if ([Environment]::Is64BitOperatingSystem) { "win32-x64-user" } else { "win32-user" })    
    $VSInstallerTempFile = "$CurrentPath\VSCodeInstall.exe"
    $VSInstallerArgs = "/VERYSILENT /SP- /ALLUSERS /NOCANCEL /NORESTART /MERGETASKS=""!runcode,desktopicon,addtopath"" /DIR=""$CurrentPath\..\VSCode"""

    try {
        Write-Output "Downloading VS Code installer..."
        Invoke-WebRequest $VSInstallerURL -OutFile $VSInstallerTempFile
        Write-Output "Starting installation of VS Code..."
        Start-Process $VSInstallerTempFile -Args $VSInstallerArgs -Wait
        Write-Output "Cleaning up..."
        Remove-Item $VSInstallerTempFile
    } catch {
        Write-Host "An error occured during VS Code installation:" -BackgroundColor Red
        Write-Host $_.ScriptStackTrace
    }
}

function Install-Python {
    $PythonInstallerURL   = "https://www.python.org/ftp/python/$CurrentPythonVersion/python-$CurrentPythonVersion"
    $PythonInstallerURL  += $(if ([Environment]::Is64BitOperatingSystem) { "-amd64.exe" } else { ".exe" })
    $PythonInstallerTempFile = "python-$CurrentPythonVersion.exe"
    $PythonInstallerArgs  = "/quiet TargetDir=""$CurrentPath\..\Python"" InstallAllUsers=1 PrependPath=1 Include_doc=0 Include_test=0"

    try {
        Write-Output "Downloading Python installer..."
        Invoke-WebRequest $PythonInstallerURL -OutFile $PythonInstallerTempFile
        Write-Output "Starting installation of Python..."
        Start-Process $PythonInstallerTempFile -Args $PythonInstallerArgs -Wait
        Write-Output "Cleaning up..."
        Remove-Item $PythonInstallerTempFile
    } catch {
        Write-Host "An error occured during Python installation:" -BackgroundColor Red
        Write-Host $_.ScriptStackTrace
    }
}

function Install-GCC {
    $GCCInstallerUrl = "https://netix.dl.sourceforge.net/project/mingw-w64/Toolchains%20targetting%20Win"
    if ([Environment]::Is64BitOperatingSystem) {
        $GCCInstallerUrl += "64"
        $GCCUrlTarget = "x86_64"
    } else {
        $GCCInstallerUrl += "32"
        $GCCUrlTarget = "i686"
    }
    $GCCInstallerUrl += "/Personal%20Builds/mingw-builds/$CurrentMinGWVersion/threads-$MinGWThreadType/seh/$GCCUrlTarget-$CurrentMinGWVersion-release-$MinGWThreadType-seh-$CurrentMinGWRevision.7z"
    $GCCInstallerTempFile = "mingw-w64-$CurrentMinGWVersion.7z"

    try {
        Write-Output "Downloading GCC MinGW environment..."
        Invoke-WebRequest $GCCInstallerUrl -OutFile $GCCInstallerTempFile
        Write-Output "Unpacking GCC..."
        & ".\7za.exe" x "$GCCInstallerTempFile" -o"..\."
        Write-Output "Updating PATH..."
        $path = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
        Push-Location ..
        [Environment]::SetEnvironmentVariable("PATH", "$path;$($(Get-Location).Path)\mingw64\bin", [EnvironmentVariableTarget]::Machine)
        Pop-Location
        Write-Output "Cleaning up..."
        Remove-Item $GCCInstallerTempFile
    } catch {
        Write-Host "An error occured during GCC installation:" -BackgroundColor Red
        Write-Host $_.ScriptStackTrace
    }
}

function Install-Git {
    $GitInstallerUrl  = "https://github.com/git-for-windows/git/releases/download/$CurrentGitVersion"
    $GitInstallerUrl += $(if ([Environment]::Is64BitOperatingSystem) { "-64-bit.exe" } else { "-32-bit.exe" })
    $GitInstallerTempFile = "git-installer.exe"
    $GitInstallerArgs = "/VERYSILENT /SP- /ALLUSERS /NOCANCEL /NORESTART /COMPONENTS=""icons\desktop,ext,"" /DIR=""$CurrentPath\..\Git"""

    try {
        Write-Output "Downloading Git for Windows..."
        Invoke-WebRequest $GitInstallerUrl -OutFile $GitInstallerTempFile
        Write-Output "Starting installing git..."
        Start-Process $GitInstallerTempFile -Args $GitInstallerArgs -Wait
        Write-Output "Cleaning up..."
        Remove-Item $GitInstallerTempFile
    } catch {
        Write-Host "An error occured during Git installation:" -BackgroundColor Red
        Write-Host $_.ScriptStackTrace
    }
}

if ($InstallPython) {
    Install-Python
}

if ($InstallGCC) {
    Install-GCC
}

if ($InstallVSCode) {
    Install-VSCode
}

if ($InstallGit) {
    Install-Git
}

#Pop-Location
Write-Host "Installation completed!" -ForegroundColor Green
