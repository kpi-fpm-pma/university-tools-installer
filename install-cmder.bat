pushd %~dp0
powershell -ExecutionPolicy Bypass -NoProfile -Command "& ./installer.ps1 -InstallCmdr" -Elevated
popd
pause