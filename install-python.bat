pushd %~dp0
powershell -ExecutionPolicy Bypass -NoProfile -Command "& ./installer.ps1 -InstallPython" -Elevated
popd
pause