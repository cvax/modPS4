@echo off
call BuildVariables.cmd
if not exist %PACKED% mkdir %PACKED%

echo Packaging bundles.............
cd /d "%MODKITPATH%"

echo.
echo.
echo Success. Bundles packaged.
echo.
echo Bundling scripts.........
XCOPY "%SCRIPTS%" "%PACKEDSCRIPTS%" /S/Y
echo.
echo Success. Scripts packaged.
echo.
echo.
:choice
set /P c="Install %NAME% to Witcher 3? (Y/N)"
if /I "%c%" EQU "Y" goto :movespot
if /I "%c%" EQU "N" goto :exitspot
goto :choice
:movespot
if not exist %GAMEPATH%\Mods\%NAME% mkdir %GAMEPATH%\Mods\%NAME%
XCOPY "%COMPILED%" "%GAMEPATH%\Mods" /S/Y
echo.
echo.
echo %NAME% successfully installed to Witcher 3.
echo Remember to use Script Merger if you have other mods installed.
pause 
exit
:exitspot
echo.
echo.
echo %NAME% generated successfully.
pause 
exit