@if (@CodeSection == @Batch) @then
@ECHO OFF
cls
:: introduce the program
echo [32mThis program unmounts a volume at the drive letter of your choice. Here is a list of attached storage devices:[0m
echo.
wmic logicaldisk get deviceid, volumename, description
::ask user for drive letter
set /p _drive=[36mEnter the drive letter you wish to disconnect ('X'):[0m 
SET _drive=%_drive%:\
::parse mountvol for the line the drive is on
FOR /F %%G IN ('mountvol ^| findstr /n %_drive%') DO SET _lineStr=%%G 
::subtract 1 from the line the drive is on
SET /A _lineNum = %_lineStr:~0,-2% - 1
::parse volume from mountvol
FOR /F "tokens=2" %%G IN ('mountvol ^| findstr /n ^^^^ ^| findstr "^%_lineNum%"') DO SET _vol=%%G
echo.
IF NOT DEFINED _vol (
ECHO The drive letter does not have a mount point. Bye.
PAUSE
EXIT /b
)
::show the result 
echo %_vol% | clip
echo [32mThe volume for[32m:[0m[0m [33m%_drive%[0m [33m%_vol%[0m [32mwas copied to the clipboard.[0m
echo.
::ask user to enter any key to unmount
echo [36mPress any key to unmount the volume of[0m [33m%_drive%[0m [31m(CTRL^+C to terminate)[0m [36m. . .[0m & PAUSE >NUL
::unmount volume
echo [31mUnmounting[0m [33m%_drive%[0m [31m. . .[0m
mountvol %_drive% /p
echo [33m%_drive%[0m [31mwas unmounted . . .[0m
echo Try to eject the drive now.
:: ask user to enter any key to re-mount the volume
echo.
echo [36mPress any key to re-mount the volume of[0m [33m%_drive%[0m [31m(CTRL^+C to terminate) [36m. . .[0m & PAUSE >NUL
echo [31mRe-mounting[0m [33m%_drive%[0m [31m. . .[0m
::re-mount volume and pause for 3 seconds
:LoopStart
mountvol %_drive% %_vol%
for /l %%f in (1 1 5) do (
CALL :drawProgressBar \
CALL :drawProgressBar /
CALL :drawProgressBar -
)
echo.
set /p _end=Was [33m%_drive%[0m[31m re-mounted?[0m (y, n): 
IF /I NOT "%_end%" == "y" GOTO LoopStart
echo.
echo Good Bye.
echo.
pause
exit /b

:pause <ms>
cscript /nologo /e:JScript "%~f0" "%~1"
goto :EOF

:drawProgressBar
setlocal enableextensions enabledelayedexpansion
for /f %%a in ('copy "%~f0" nul /z') do set "pb.cr=%%a"
<nul set /p "=. . . Waiting for drive to come back . . . [ %1 ] !pb.cr!"
call :pause 125
endlocal
GOTO :EOF

@end // end batch / begin JScript hybrid code
WSH.Sleep(WSH.Arguments(0));
