pushd %~dp0
powershell -ExecutionPolicy Bypass -NoProfile -Command "& ./installer.ps1 -InstallPython -InstallGCC -InstallVSCode -InstallGit" -Elevated
popd
pause