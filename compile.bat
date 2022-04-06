@echo on
setLocal enableDelayedExpansion 
pushd %~dp0
:: EZ compile script, just add folders in mod folder and they will automatically be copied to the ../raw dir
:: compiled into newly generated mod folder, iwd files are copied over automatically 
:: additional shortcut batch file has been added to the output dir, run and launch the mod in two clicks!
:: http://gmzorz.com/
:dir
for /f "delims=" %%A in ('cd') do (
    set fn=%%~nxA
    )
set "moddir=%fn%_compiled"
if exist "..\%moddir%" ( del ..\%moddir%\mod.ff ) else ( mkdir ..\%moddir% ) >nul
if not exist mod2.csv ( goto zip ) >nul
:modprompt
echo secondary mod.csv found
echo merging..
ren mod.csv mod1.txt >nul
ren mod2.csv mod2.txt >nul
echo. >> mod1.txt
copy mod1.txt + mod2.txt mod.txt >nul
ren mod.txt mod.csv >nul
del mod1.txt & del mod2.txt >nul
:zip
if exist weapons ( 7za a -r -tzip z_%fn%.iwd weapons ) 
if exist images ( 7za a -r -tzip z_%fn%.iwd images ) 
if exist sound ( 7za a -r -tzip z_%fn%.iwd sound ) 
for %%a in (*.iwd) do ( xcopy %%a ..\%moddir% /SY ) 
:compile
echo compiling..
for /f "usebackq tokens=*" %%a in (`dir /b /a:d`) do ( xcopy "%%a" "..\..\raw\%%a" /SY )
echo for /f "delims=" %%%%A in ('cd') do ( > run.txt
echo     set fn=%%%%~nxA >> run.txt
echo     ) >> run.txt 
echo cd ../.. >> run.txt
echo iw3mp +set r_fullscreen "0" +set r_mode "1280x720" +set fs_game mods/%%fn%% +exec mod.cfg >> run.txt
echo seta scr_war_timelimit "0" > modcfg.txt
echo seta g_gametype "war" >> modcfg.txt
copy modcfg.txt ..\%moddir%\mod.cfg & del modcfg.txt >nul
copy run.txt ..\%moddir%\launch.bat & del run.txt >nul
copy /Y mod.csv ..\..\zone_source >nul
echo %cd%
cd ..\..\bin
linker_pc.exe -language english -compress -cleanup mod
cd ..\Mods\%moddir%
copy ..\..\zone\english\mod.ff >nul
echo %cd%
start "" ..\%moddir%\
pause
