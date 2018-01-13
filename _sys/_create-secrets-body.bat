@ECHO OFF
@CALL _global-settings

REM CP 437 (DOS)
REM 


REM S„tts per bat-fil
REM Namn f”r hel- eller delprocessen (modul) som batch-filen hanterar
SET DL_PROCESSNAME=_create-secrets-body


REM skapar tidsst„mpel och unikt process-ID f”r sp†rning av k”rd batch-process
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
SET DL_PROCESSID=%DL_PROCESSNAME%_%CurrentDateTime%

@CALL _sys\_log-batch START %DL_PROCESSID%
IF %ERRORLEVEL% EQU 0 (

    REM Kontrollerar s† att rot-katalog f”r hemligheter existerar, annars skapar.
    REM Katalognamnet „r konstant och ska inte „ndras.
    SET DL_SECRETSFOLDER=__secrets\
    SET DL_SECRETSFILE=_secrets.bat
    IF NOT EXIST !DL_SECRETSFOLDER! (

        MD !DL_SECRETSFOLDER!

    )

    REM TODO: Skapar fil om den ej existerar fr†n funktion
    @CALL :CreateFile

) ELSE (

    @CALL _sys\_log-batch ERROR "Processen %DL_PROCESSID% kunde inte k”ras"
    @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_PROCESSID%" %_arg%

    GOTO break

)


:exit
@CALL _sys\_log-batch KLART %DL_PROCESSID%
:break
EXIT /B




REM ### METODER ###
REM Skapar upp filstrukturen f”r d„r hemligheter kan sparas
:CreateFile
    IF NOT EXIST !DL_SECRETSFOLDER!!DL_SECRETSFILE! (

        CHCP 437 > nul
        ECHO. >>!DL_SECRETSFOLDER!!DL_SECRETSFILE! > nul

        ECHO REM CP 437 (DOS^) >>!DL_SECRETSFOLDER!!DL_SECRETSFILE!

        ECHO. >> !DL_SECRETSFOLDER!!DL_SECRETSFILE!
        ECHO REM Lantm„teriet, Geodataplatsen, Fastighetskartan >> !DL_SECRETSFOLDER!!DL_SECRETSFILE!
        ECHO SET USER-LM-GEODATAPLATSEN= >> !DL_SECRETSFOLDER!!DL_SECRETSFILE!
        ECHO SET PASS-LM-GEODATAPLATSEN= >> !DL_SECRETSFOLDER!!DL_SECRETSFILE!
        ECHO. >> !DL_SECRETSFOLDER!!DL_SECRETSFILE!
        ECHO REM E-post >> !DL_SECRETSFOLDER!!DL_SECRETSFILE!
        ECHO REM Flera e-postadresser separeras med komma >> !DL_SECRETSFOLDER!!DL_SECRETSFILE!
        ECHO SET DL-MAIL-HOST= >> !DL_SECRETSFOLDER!!DL_SECRETSFILE!
        ECHO SET DL-MAIL-PORT= >> !DL_SECRETSFOLDER!!DL_SECRETSFILE!
        ECHO SET DL-MAIL-FROM= >> !DL_SECRETSFOLDER!!DL_SECRETSFILE!
        ECHO SET DL-MAIL-TO= >> !DL_SECRETSFOLDER!!DL_SECRETSFILE!
        ECHO SET DL-MAIL-CC= >> !DL_SECRETSFOLDER!!DL_SECRETSFILE!

        CHCP 1252 > nul

    ) ELSE (

        @CALL _sys\_log-batch ERROR "Filen !DL_SECRETSFOLDER!!DL_SECRETSFILE! existerar"

    )

    IF %ERRORLEVEL% NEQ 0 (
        @CALL _sys\_log-batch ERROR "Filen !DL_SECRETSFILE! kunde inte skapas"
        @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r !DL_SECRETSFILE!" %DL_PROCESSNAME%

        EXIT /B
    )
GOTO :eof