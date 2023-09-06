param(
    [switch] $InstallVSCode = $false,
    [switch] $InstallPython = $false,
    [switch] $InstallGit    = $false,
    [switch] $InstallGCC    = $false,
    [switch] $InstallCmdr   = $false
)


$CurrentPythonVersion = "3.11.5"
$CurrentGitVersion    = "v2.42.0.windows.2/Git-2.42.0.2"
$CurrentMinGWVersion  = "8.1.0"
$CurrentMinGWRevision = "rt_v6-rev0"
$MinGWThreadType      = "win32" # "posix"
$CmderVersion         = "1.3.24"


function Report-Error ([string]$msg) {
    Write-Host $msg -BackgroundColor Red
    Write-Host $_.ScriptStackTrace
}

function Clean-Up ([string[]]$paths) {
    Write-Output "Cleaning up..."
    $paths | % { Remove-Item $_ }
}


function Install-VSCode {
    Push-Location ..
    $VSInstallerURL  = "https://code.visualstudio.com/sha/download?build=stable&os="
    $VSInstallerURL += $(if ([Environment]::Is64BitOperatingSystem) { "win32-x64-user" } else { "win32-user" })    
    $VSInstallerTempFile = "VSCodeInstall.exe"
    $VSInstallerArgs = "/VERYSILENT /SP- /ALLUSERS /NOCANCEL /NORESTART /MERGETASKS=""!runcode,desktopicon,addtopath"" /DIR=""$((Get-Location).Path)\VSCode"""
    Pop-Location

    try {
        Write-Output "Downloading VS Code installer..."
        Invoke-WebRequest $VSInstallerURL -OutFile $VSInstallerTempFile
        Write-Output "Starting installation of VS Code..."
        Start-Process $VSInstallerTempFile -Args $VSInstallerArgs -Wait
        Clean-Up $VSInstallerTempFile
    } catch {
        Report-Error "An error occured during VS Code installation:"
    }
}

function Install-Python {
    Push-Location ..
    $PythonInstallerURL   = "https://www.python.org/ftp/python/$CurrentPythonVersion/python-$CurrentPythonVersion"
    $PythonInstallerURL  += $(if ([Environment]::Is64BitOperatingSystem) { "-amd64.exe" } else { ".exe" })
    $PythonInstallerTempFile = "python-$CurrentPythonVersion.exe"
    $PythonInstallerArgs  = "/quiet TargetDir=""$((Get-Location).Path)\Python"" InstallAllUsers=1 PrependPath=1 Include_doc=0 Include_test=0"
    Pop-Location

    try {
        Write-Output "Downloading Python installer..."
        Invoke-WebRequest $PythonInstallerURL -OutFile $PythonInstallerTempFile
        Write-Output "Starting installation of Python..."
        Start-Process $PythonInstallerTempFile -Args $PythonInstallerArgs -Wait
        Clean-Up $PythonInstallerTempFile
    } catch {
        Report-Error "An error occured during Python installation:"
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
        [Environment]::SetEnvironmentVariable("PATH", "$path;$((Get-Location).Path)\mingw64\bin", [EnvironmentVariableTarget]::Machine)
        Pop-Location
        Clean-Up $GCCInstallerTempFile
    } catch {
        Report-Error "An error occured during GCC installation:"
    }
}

function Install-Git {
    Push-Location ..
    $GitInstallerUrl  = "https://github.com/git-for-windows/git/releases/download/$CurrentGitVersion"
    $GitInstallerUrl += $(if ([Environment]::Is64BitOperatingSystem) { "-64-bit.exe" } else { "-32-bit.exe" })
    $GitInstallerTempFile = "git-installer.exe"
    $GitInstallerArgs = "/VERYSILENT /SP- /ALLUSERS /NOCANCEL /NORESTART /COMPONENTS=""icons\desktop,ext,"" /DIR=""$((Get-Location).Path)\Git"""
    Pop-Location

    try {
        Write-Output "Downloading Git for Windows..."
        Invoke-WebRequest $GitInstallerUrl -OutFile $GitInstallerTempFile
        Write-Output "Starting installing git..."
        Start-Process $GitInstallerTempFile -Args $GitInstallerArgs -Wait
        Clean-Up $GitInstallerTempFile
    } catch {
        Report-Error "An error occured during Git installation:"
    }
}

function Install-Cmder ([switch]$Mini = $true) {
    $CmderInstallerUrl  = "https://github.com/cmderdev/cmder/releases/download/v$CmderVersion/"
    $CmderInstallerUrl += $(if ($Mini) { "cmder_mini.zip" } else { "cmder.7z" })
    $CmderInstallerTempFile = "cmder.zip"

    try {
        Write-Output "Downloading Cmder..."
        Invoke-WebRequest $CmderInstallerUrl -OutFile $CmderInstallerTempFile
        & ".\7za.exe" x $CmderInstallerTempFile -o"..\cmder"
        Clean-Up $CmderInstallerTempFile
    } catch {
        Report-Error "An error occured during Cmder installation:"
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

if ($InstallCmdr) {
    Install-Cmder
}

Write-Host "Installation completed!" -ForegroundColor Green
