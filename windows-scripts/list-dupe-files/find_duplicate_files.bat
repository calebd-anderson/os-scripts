@if (@CodeSection == @Batch) @then
@ECHO OFF
chcp 65001 >NUL
SETLOCAL EnableDelayedExpansion
ECHO [36mCounting files ...[0m
ECHO [36mIn: "%cd%".[0m
CALL :ProgressMeter 0
SET /A "_fileCount=0"
FOR /F "tokens=*" %%i IN ('dir /s /b /a-d') DO (
	SET /A "_fileCount+=1"
)
ECHO					[41m---WARNING---[0m
SET /P "_input=[36mReady to SHA1 hash [47m[30m %_fileCount% [0m[36m files? Enter (y/n):[0m "
IF /I "%_input%"=="y" GOTO :yes
GOTO :EOF

:yes
:: loop directory and set hash/path object
ECHO.
SET /A "_size=0"
:: get simple path
for /f "tokens=1 delims=\" %%a in ("%cd%") do SET "_drive=%%a"
FOR %%I IN (.) DO SET "_currDirName=%%~nxI"
SET "_dirString=%_drive%\...\%_currDirName%\"
:: hash time
CALL :ProgressMeter 10
FOR /F "tokens=*" %%i IN ('dir /s /b /a-d') DO (
	CALL :drawProgressBar / !_fileCount!
	SET "obj[!_size!].path=%%i"
	REM Skip empty file
	IF %%~zi GTR 0 (
		FOR /F "tokens=*" %%j IN ('certutil -hashfile "%%i" SHA1 ^| findstr /V ":"') DO (
			SET "obj[!_size!].hash=%%j:%%~zi"
			CALL :drawProgressBar - !_fileCount!			
		)
	) ELSE SET "obj[!_size!].hash=HASH_ERROR-FILE_INVALID_SIZE:%%~zi"
	SET /A "_size+=1"
	CALL :drawProgressBar \ !_fileCount!
	SET /A "_fileCount-=1"
	CALL :drawProgressBar - !_fileCount!
)
SET /A "_size-=1"
REM ECHO.
REM SET obj
ECHO.
ECHO [36mSearching for duplicates ...[0m
CALL :ProgressMeter 20
:: output all hashes to txt
IF NOT EXIST hashes.txt (
	FOR /F "tokens=2* delims=.=" %%a IN ('SET obj ^| FINDSTR /C:"hash"') DO (
		ECHO %%b >> hashes.txt
	)
)

CALL :ProgressMeter 40
:: output all duplicate hashes to txt
IF NOT EXIST duplicates.txt (
	SET "prev="
	FOR /F "tokens=*" %%a IN ('sort "hashes.txt"') DO (
		IF "%%a"=="!prev!" (
			ECHO %%a >> duplicates.txt
		)
		SET "prev=%%a"
	)
	DEL hashes.txt
	IF NOT EXIST duplicates.txt (
		ECHO [31mNo duplicates^^![0m
		GOTO :EOF
	)
)

CALL :ProgressMeter 60
:: output only unique hashes to txt
IF NOT EXIST unq_duplicates.txt (
	FOR /F %%a IN ('sort duplicates.txt') DO (
		IF NOT "%%a"=="!prev!" (
			ECHO %%a >> unq_duplicates.txt
			SET /A "_count+=1"
		)
		SET "prev=%%a"
	)
	DEL duplicates.txt
)
(SET LF=^

)
ECHO [31m%_count% duplicates found.[0m
ECHO.

ECHO [33mSaving output to: "%userprofile%\Desktop\%_count%_duplicates.txt" . . .[0m
ECHO %_count% duplicates found in "%cd%".!LF! > %userprofile%\Desktop\%_count%_duplicates.txt

CALL :ProgressMeter 80
:: output all paths and shas of duplicate files to console
IF EXIST unq_duplicates.txt (
	FOR /F "tokens=*" %%a IN (unq_duplicates.txt) DO (
		CALL :checkduplicate %%a >> %userprofile%\Desktop\%_count%_duplicates.txt
	)
	DEL unq_duplicates.txt
)

CALL :ProgressMeter 100
FOR /f %%a IN ('copy "%~f0" nul /z') DO SET "pb.cr=%%a"
ECHO [36mPress any key to view the above file in the console now . . .[0m & PAUSE >NUL
ECHO.
more %userprofile%\Desktop\%_count%_duplicates.txt
EXIT /B

:: ========== FUNCTIONS ==========
:checkduplicate
IF "%1" NEQ "" (
	FOR /F "tokens=1 delims=:" %%i IN ("%1") DO ECHO SHA1: %%i
	FOR /F "tokens=2 delims=:" %%i IN ("%1") DO ECHO Size: %%i bytes.
	ECHO Paths:
	FOR /L %%r IN (0 1 %_size%) DO (
		IF "!obj[%%r].hash!"=="%1" ECHO !obj[%%r].path!
	)
	ECHO.
)
GOTO :EOF

:ProgressMeter
SET ProgressPercent=%1
SET /A NumBars=%ProgressPercent%/2
SET /A NumSpaces=50-%NumBars%
SET Meter=
FOR /L %%A IN (%NumBars%,-1,1) DO SET Meter=!Meter!I
FOR /L %%A IN (%NumSpaces%,-1,1) DO SET Meter=!Meter!
TITLE Overall Progress:  [%Meter%]  %ProgressPercent%%%
GOTO :EOF

:pause
wscript /nologo /e:JScript "%~f0" "%~1"
GOTO :EOF

:drawProgressBar
FOR /f %%a IN ('copy "%~f0" nul /z') DO SET "pb.cr=%%a"
<nul set /p "=[32mComputing [ %2 ] SHA1 file hashes in: "%_dirString%". Please Wait [ %1 ] ...!pb.cr![0m"
CALL :pause 0
GOTO :EOF

@end // end batch / begin JScript hybrid code
WScript.Sleep(WScript.Arguments(0));
