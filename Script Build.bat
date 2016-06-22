@echo off
call BuildVariables.cmd

echo Bundling scripts.........
XCOPY "%SCRIPTS%" "%PACKEDSCRIPTS%" /S/Y
echo.
echo.
echo %NAME% generated successfully.
echo.
:choice
set /P c="Install %NAME% scripts to Witcher 3? (Y/N)"
if /I "%c%" EQU "Y" goto :movespot
if /I "%c%" EQU "N" goto :exitspot
goto :choice
:movespot
if not exist %GAMEPATH%\Mods\%NAME% mkdir %GAMEPATH%\Mods\%NAME%
XCOPY "%SCRIPTS%" "%GAMEPATH%\Mods\%NAME%" /S/Y
echo.
echo.
echo %NAME% scripts successfully installed to Witcher 3.
echo Remember to use Script Merger if you have other mods installed.
pause 
exit
:exitspot
echo.
echo.
echo %NAME% scripts generated successfully.
pause 
exit