@ECHO OFF
@CALL _global-settings

REM CP 437 (DOS)
REM Argument 1: Processmodulsnamn (valfri). Uppges n„r inte hela datalager-
REM             processens filer f”r konfiguration och schema ska kopieras.
REM Delar som kopieras
REM  * _global-settings-targetpaths.ini
REM  * [processmodul]\_schema\_modul-settings-datasets.ini
REM  * [processmodul]\_schema\schema-manifest.xlsx
REM Kopieras till .\_bkp med underkatalog _config-[DATUMTID]


IF NOT [%1]==[] (
    SET _arg1=%1
)

REM S„tts per bat-fil
REM Namn f”r hel- eller delprocessen (modul) som batch-filen hanterar
SET DL_PROCESSNAME=_backup-config


REM skapar tidsst„mpel och unikt process-ID f”r sp†rning av k”rd batch-process
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
SET DL_PROCESSID=%DL_PROCESSNAME%_%CurrentDateTime%

@CALL _sys\_log-batch START %DL_PROCESSID%
IF %ERRORLEVEL% EQU 0 (

    REM Kontrollerar s† att rot-katalog f”r backup existerar, annars skapar
    IF NOT EXIST !DL_BKPDIR! (
        MD !DL_BKPDIR!
        @CALL _sys\_log-batch INFOR "Skapad katalog !DL_BKPDIR!"
    )

    REM Skapar underkatalogs namn unikt
    FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i%%j
    SET configBkpFolder=_config_!CurrentDateTime!
    IF NOT DEFINED _arg1 (
        SET configBkpFolder=!configBkpFolder!_all
    ) ELSE (
        SET configBkpFolder=!configBkpFolder!_%_arg1%
    )
    REM Skapar sessionens katalog f”r backup
    CD !DL_BKPDIR!
    IF NOT EXIST !configBkpFolder! (
        MD !configBkpFolder!
        CD..
        @CALL _sys\_log-batch INFOR "Skapad katalog !DL_BKPDIR!!configBkpFolder!"
    ) ELSE (
        CD..
    )

    SET COPYTOFOLDER=!DL_BKPDIR!!configBkpFolder!
    IF NOT DEFINED _arg1 (
        COPY _global-settings-targetpaths.ini !COPYTOFOLDER! > nul
        FOR /D %%p IN ("*.*") DO (
            SET FOLDER=%%p
            IF NOT "!FOLDER:~0,1!"=="_" (
                IF EXIST !FOLDER!\_schema\_modul-settings-datasets.ini ECHO K| XCOPY /Y !FOLDER!\_schema\_modul-settings-datasets.ini !COPYTOFOLDER!\!FOLDER!\_schema /I > nul
                IF EXIST !FOLDER!\_schema\schema-manifest.xlsx ECHO K| XCOPY /Y !FOLDER!\_schema\schema-manifest.xlsx !COPYTOFOLDER!\!FOLDER!\_schema /I > nul
            )
        )
    ) ELSE (
        IF EXIST %_arg1%\_schema\_modul-settings-datasets.ini ECHO K| XCOPY %_arg1%\_schema\_modul-settings-datasets.ini !COPYTOFOLDER!\%_arg1%\_schema /I > nul
        IF EXIST %_arg1%\_schema\schema-manifest.xlsx ECHO K| XCOPY %_arg1%\_schema\schema-manifest.xlsx !COPYTOFOLDER!\%_arg1%\_schema /I > nul
    )


) ELSE (
    @CALL _sys\_log-batch ERROR "Processen %DL_PROCESSID% kunde inte k”ras"
    @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_PROCESSID%" %_arg%

    GOTO break
)


:exit
@CALL _sys\_log-batch KLART %DL_PROCESSID%
:break
EXIT /B