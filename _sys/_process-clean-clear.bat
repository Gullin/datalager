@CALL _global-settings
SETLOCAL EnableDelayedExpansion

REM CP 437 (DOS)
REM Argument 1: Processmodulsnamn om ej hela datalagerprocessen k”rs
REM Rensar inte resultaten som kan vara intressant f”r sp†rning (exempelvis resultat av FME-procssor som genererar n†got av st”rre dignitet).
REM Rensar loggar och dyl. som endast kan knytas till respektive delprocess och som inte „r intressant var f”r sig.
REM Rensar tempor„ra dataset som anv„nds f”r processorna.

IF NOT [%1]==[] (
    SET _arg1=%1
)

IF DEFINED _arg1 (
    REM Kontrollera om katalogen finns som processmodul
    IF EXIST %DL_ROTDIR%%_arg1%\NUL (
        SET _IsProcessModul=1
    )
) ELSE (
    SET _IsProcessModul=0
)


IF DEFINED _IsProcessModul (
    REM Rensar allt som kan rensas (alla processspecifika loggar och
    REM underkataloger som ej inneh†ller processlogik)
    FOR /D %%p IN ("*.*") DO (
        REM Logg-katalogen
        IF %%p==_log (
            IF EXIST %%p\%DL_LOGFILE% ATTRIB +R %%p\%DL_LOGFILE%
            IF EXIST %%p\DatalagerLogg.sqlite ATTRIB +R %%p\DatalagerLogg.sqlite
            IF EXIST %%p\DatalagerLogg.xlsx ATTRIB +R %%p\DatalagerLogg.xlsx
            IF %_IsProcessModul%==1 (
                IF EXIST %%p\%DL_DISTSOURCEFILE% ATTRIB +R %%p\%DL_DISTSOURCEFILE%
                IF EXIST %%p\%DL_LOGERROR% ATTRIB +R %%p\%DL_LOGERROR%
            )

            2>nul (DEL /S /Q %%p\*.*) >nul

            IF EXIST %%p\%DL_LOGFILE% ATTRIB -R %%p\%DL_LOGFILE%
            IF EXIST %%p\DatalagerLogg.sqlite ATTRIB -R %%p\DatalagerLogg.sqlite
            IF EXIST %%p\DatalagerLogg.xlsx ATTRIB -R %%p\DatalagerLogg.xlsx
            IF EXIST %%p\%DL_DISTSOURCEFILE% ATTRIB -R %%p\%DL_DISTSOURCEFILE%
            IF EXIST %%p\%DL_LOGERROR% ATTRIB -R %%p\%DL_LOGERROR%
        )

        REM Om Argument med processmodulsnamn inte existerar itereras resp. katalog,
        REM i annat fall endast katalog med namn samma som processmodulsnamn
        IF %_IsProcessModul%==0 (
            @CALL :DeleteSubObject %%p
        ) ELSE (
            IF "%%p"=="%_arg1%" (
                @CALL :DeleteSubObject %%p
            )
        )
    )

    REM Skapar signal-fil om att instruktionen „r k”rd, skapas om processen k”rs
    REM i sin helhet d† det endast „r n„r v„xln -c | --clear anv„nds
    IF %_IsProcessModul%==0 (
        REM skapar tidsst„mpel
        FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
        ECHO. > _cleared_!CurrentDateTime!
    )
) ELSE (
    @CALL _sys\_log-batch ERROR "Processen _process-clean-clear.bat kunde inte k”ras"
    @CALL _sys\_log-error "_process-clean-clear.bat" "Errorlevel %ERRORLEVEL% f”r argument %_arg1%"
)
GOTO :eof
ENDLOCAL



REM F”r alla kataloger som inte b”rjar med "_" (systemkataloger), processmodulskataloger eller andra underkataloger i systemkataloger som ej 
REM Raderar filer och kataloger s† n„r som f”r _FME men som inte „r en FME-process (exempelvis tempor„r data)
:DeleteSubObject
SET _obj=%1
SET _obj-not-to-delete=%_obj:~0,1%
IF NOT "%_obj-not-to-delete%"=="_" (

    REM F”r underkatalogerna som inte „r systemkataloger (b”rjar med _)
    setlocal enabledelayedexpansion
    CD %_obj%
    FOR /D %%f IN (*) DO (
        SET _sub-folder=%%f
        SET _obj-not-to-delete-sub=!_sub-folder:~0,1!
        IF NOT "!_obj-not-to-delete-sub!"=="_" RMDIR /S /Q "%%f"
        2>nul (DEL /Q *.*) >nul
    )
    CD..
    endlocal

    REM Speciellt f”r _fme-systemkatalog (rensas eftersom ev. tempor„r fme-data lagras h„r)
    REM F”r alla underkataloger i _fme
    FOR /D %%i IN (%_obj%\_fme\*) DO RMDIR /S /Q "%%i"
    REM F”r alla filer i _fme
    FOR /R %_obj%\_fme %%i IN (*) DO IF NOT %%~xi==.fmw 2>nul (DEL /S /Q "%%i") >nul

    REM Speciellt f”r _log-systemkatalog (ska endast inneh†lla aktuell k”rningsinformation)
    REM F”r alla underkataloger i _log
    FOR /D %%i IN (%_obj%\_log\*) DO RMDIR /S /Q "%%i"
    REM Radera filer endast n„r processmodul k”rs individuellt eller f”r -c | --clear
    IF %DL_ISWHOLEPROCESS% == 0 SET isDelete=true
    IF %DL_ISWHOLEPROCESS% == 2 SET isDelete=true
    IF "!isDelete!" == "true" (
        REM F”r alla filer i _log
        2>nul (DEL /S /Q %_obj%\_log\*.*) >nul
    )

    REM Speciellt f”r _schema-systemkatalog
    REM F”r alla underkataloger i _schema
    FOR /D %%i IN (%_obj%\_schema\*) DO RMDIR /S /Q "%%i"
    REM Radera alla filer i _schema utom de som skrivskyddas
    IF EXIST %_obj%\_schema\_modul-settings-datasets.ini ATTRIB +R %_obj%\_schema\_modul-settings-datasets.ini
    IF EXIST %_obj%\_schema\schema-manifest.xlsx ATTRIB +R %_obj%\_schema\schema-manifest.xlsx
    2>nul (DEL /S /Q %_obj%\_schema\*.*) >nul
    IF EXIST %_obj%\_schema\_modul-settings-datasets.ini ATTRIB -R %_obj%\_schema\_modul-settings-datasets.ini
    IF EXIST %_obj%\_schema\schema-manifest.xlsx ATTRIB -R %_obj%\_schema\schema-manifest.xlsx

)
GOTO :eof

:Exit