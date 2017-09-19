@CALL _global-settings

REM CP 437 (DOS)
REM Rensar inte resultaten som kan vara intressant f”r sp†rning (exempelvis resultat av FME-procssor som genererar n†got av st”rre dignitet).
REM Rensar loggar och dyl. som endast kan knytas till respektive delprocess och som inte „r intressant var f”r sig.
REM Rensar tempor„ra dataset som anv„nds f”r processorna.


REM Rensar allt som kan rensas (alla loggar, underkataloger som ej inneh†ller processlogik)
FOR /D %%p IN ("*.*") DO (
    REM Logg-katalogen
    IF %%p==_log (
        REM Rensar filen f”r allvarliga undantagsloggar
        REM "FATAL_ERROR.log"
        IF EXIST %%p\FATAL_ERROR.log DEL /S /Q %%p\FATAL_ERROR.log
        REM Alla "FME-*.log"
        SET folder=%%p
        FOR /R %folder% %%i IN ("FME-*.log") DO DEL /S /Q %%i
        SET folder=
    )


    @CALL :DeleteSubObject %%p
)

REM Skapar signal-fil om att instruktionen „r k”rd
REM skapar tidsst„mpel
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
ECHO. > _cleared_%CurrentDateTime%
GOTO :eof



REM F”r alla kataloger som inte b”rjar med "_" (systemkataloger), processmodulskataloger eller andra underkataloger i systemkataloger som ej 
REM Raderar filer och kataloger s† n„r som f”r _FME men som inte „r en FME-process (exempelvis tempor„r data)
:DeleteSubObject
SET _obj=%1
SET _obj-not-to-delete=%_obj:~0,1%
SET folder_to_clean=%_obj%\_fme
IF NOT "%_obj-not-to-delete%"=="_" (

    REM F”r underkatalogerna som inte „r systemkataloger (b”rjar med _)
    setlocal enabledelayedexpansion
    CD %_obj%
    FOR /D %%f IN (*) DO (
        SET _sub-folder=%%f
        SET _obj-not-to-delete-sub=!_sub-folder:~0,1!
        IF NOT "!_obj-not-to-delete-sub!"=="_" RMDIR /S /Q "%%f"
        DEL /Q *.*
    )
    CD..
    endlocal

    REM Speciellt f”r _fme-systemkatalog (rensas eftersom ev. tempor„r fme-data lagras h„r)
    REM F”r alla underkataloger i _fme
    FOR /D %%i IN (%folder_to_clean%\*) DO RMDIR /S /Q "%%i"
    REM F”r alla filer i _fme
    FOR /R %folder_to_clean% %%i IN (*) DO IF NOT %%~xi==.fmw DEL /S /Q "%%i"
)
GOTO :eof

:Exit