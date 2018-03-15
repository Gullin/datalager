@ECHO OFF
@CALL _global-settings

REM CP 437 (DOS)
REM Delar som kopieras f”r deploy
REM  * 
REM Kopieras till .\_deploy


REM S„tts per bat-fil
REM Namn f”r hel- eller delprocessen (modul) som batch-filen hanterar
SET DL_PROCESSNAME=_deploy


REM skapar tidsst„mpel och unikt process-ID f”r sp†rning av k”rd batch-process
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
SET DL_PROCESSID=%DL_PROCESSNAME%_%CurrentDateTime%

@CALL _sys\_log-batch START %DL_PROCESSID%
IF %ERRORLEVEL% EQU 0 (

    REM Kontrollerar s† att rot-katalog f”r backup existerar,
    REM annars skapas katalogen
    REM existerar katalogen rensas den p† inneh†ll
    IF NOT EXIST !DL_DEPLOYDIR! (
        MD !DL_DEPLOYDIR!
        @CALL _sys\_log-batch INFOR "Skapad katalog !DL_DEPLOYDIR!"
    ) ELSE (
        DEL /S /F /Q !DL_DEPLOYDIR!*.* > nul
        FOR /F "delims=" %%f IN ('DIR /ad /b !DL_DEPLOYDIR!') DO RMDIR /S /Q "!DL_DEPLOYDIR!%%f"
        @CALL _sys\_log-batch INFOR "Rensad katalog !DL_DEPLOYDIR!"
    )

    CLS

    REM Kataloger
    ECHO Deploies:
    ECHO        .\__secrets
    SET DL_FOLDERCOPY=__secrets\
    ECHO K| XCOPY !DL_FOLDERCOPY!*.bat !DL_DEPLOYDIR!!DL_FOLDERCOPY! /Y /E /I > nul

    ECHO        .\_sys
    SET DL_FOLDERCOPY=_sys\
    ECHO K| XCOPY !DL_FOLDERCOPY!*.bat !DL_DEPLOYDIR!!DL_FOLDERCOPY! /Y /E /I > nul
    ECHO K| XCOPY !DL_FOLDERCOPY!*.ffs !DL_DEPLOYDIR!!DL_FOLDERCOPY! /Y /E /I > nul
    ECHO K| XCOPY !DL_FOLDERCOPY!*.fmw !DL_DEPLOYDIR!!DL_FOLDERCOPY! /Y /E /I > nul
    ECHO K| XCOPY !DL_FOLDERCOPY!*.fmx !DL_DEPLOYDIR!!DL_FOLDERCOPY! /Y /E /I > nul

    FOR /F "delims=" %%f IN ('DIR /b *.bat') DO (
        SET DL_FOLDERCOPY=%%~nf\
        IF EXIST "!DL_FOLDERCOPY!" (
            ECHO        .\%%~nf
        )
        IF EXIST "!DL_FOLDERCOPY!_fme\*.fmw" (
            ECHO K| XCOPY !DL_FOLDERCOPY!_fme\*.fmw !DL_DEPLOYDIR!!DL_FOLDERCOPY!_fme\ /Y /E /I > nul
        )
        IF EXIST "!DL_FOLDERCOPY!_schema\_modul-settings-datasets.ini" (
            ECHO K| XCOPY !DL_FOLDERCOPY!_schema\_modul-settings-datasets.ini !DL_DEPLOYDIR!!DL_FOLDERCOPY!_schema\ /Y /E /I > nul
        )
        IF EXIST "!DL_FOLDERCOPY!_schema\schema-manifest.xlsx" (
            ECHO K| XCOPY !DL_FOLDERCOPY!_schema\schema-manifest.xlsx !DL_DEPLOYDIR!!DL_FOLDERCOPY!_schema\ /Y /E /I > nul
        )
    )

    REM Filer
    ECHO        _global-settings-targetpaths.ini
    COPY _global-settings-targetpaths.ini !DL_DEPLOYDIR! > nul
    FOR /F "delims=" %%f IN ('DIR /b *.bat') DO (
        ECHO        %%f
        COPY %%f !DL_DEPLOYDIR! > nul
    )

    ECHO.
    ECHO Information:
    ECHO        * Kontrollera _global-settings.bat
    ECHO        * Kontrollera _global-settings-targetpaths.ini
    ECHO        * Kontrollera .\__secrets\_secrets.bat
    ECHO        * Kontrollera s”kv„gar i fmw-filer
    ECHO        * Kontrollera s”kv„gar i schema-manifest.xlsx vid filbaserade processmoduler
    ECHO.

) ELSE (
    @CALL _sys\_log-batch ERROR "Processen %DL_PROCESSID% kunde inte k”ras"
    @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_PROCESSID%" %_arg%

    GOTO break
)


:exit
PAUSE
@CALL _sys\_log-batch KLART %DL_PROCESSID%
:break
EXIT /B