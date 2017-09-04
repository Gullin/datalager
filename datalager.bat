@ECHO OFF
SETLOCAL
@CALL _global-settings

REM CP 437 (DOS)
REM Argument 1: V„xel [ null | [ reset|-r ] | [ clear|-c ] | [instal|-i] ]

REM Kontrollerar om ett argument existerar, anv„nder argumentet f”r alternativ till att k”ra hela processen.
REM Ska hela processen k”ras skickas inget argument med.
IF NOT [%1]==[] (
    SET _arg=%1
)

REM S„tts per bat-fil
REM Namn f”r hel- eller delprocessen (modul) som batch-filen hanterar
SET DL_PROCESSNAME=datalager

REM S„tts till 1 f”r att indikera att datalagerprocessen k”rs i sin helhet. Anv„nds vid utdistribuering av repot,
REM testas mot variablen i modulerna f”r veta var k„lla tillut kopiering ska skrivas (globalt eller f”r modulen).
SET DL_ISWHOLEPROCESS=1



@CALL _sys\_process-create-frame %DL_PROCESSNAME%

REM skapar tidsst„mpel och unikt process-ID f”r sp†rning av k”rd batch-process
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
SET DL_PROCESSID_MASTER=%DL_PROCESSNAME%_%CurrentDateTime%

@CALL _sys\_log-batch START %DL_PROCESSID_MASTER%
REM Raderar tidigare "signal"-filer som endast „r intressant f”r k”rd processor
IF EXIST _reseted_*.* DEL _reseted_*.*
IF EXIST _cleared_*.* DEL _cleared_*.*
IF %ERRORLEVEL% EQU 0 (
    IF NOT DEFINED _arg (

        REM M†lkatalog f”r processernas resulterande data.
        REM Variabeln DL_REPOSITORYROTDIR ska skickas med som parameter till alla FME-processer som genererar output till datalagret.
        REM Respektive processmodul skapar upp sina substrukturer under repo-roten.
        IF NOT DEFINED DL_REPOSITORYROTDIR SET DL_REPOSITORYROTDIR=_geodatarepo\

        REM Loggning av resp. process resurskatalog f”r distribuering senare i processen. Skapar tom fil.
        ECHO. 2> %DL_DISTSOURCE%


        
        REM Processmoduler
        REM @CALL lm-geodataplatsen-fastighetskartan
        @CALL lkr-oracle-lkr_gis



        REM Kopierar ut genererat datalager till platser. Platser definieras i rutinen.
        REM @CALL _sys\_datalager-distribute

    ) ELSE (
        IF "%_arg%"=="reset" SET RESETING=1
        IF "%_arg%"=="-r" SET RESETING=1
        IF "%_arg%"=="clear" SET CLEARING=1
        IF "%_arg%"=="-c" SET CLEARING=1
        IF "%_arg%"=="instal" SET INSTALLING=1
        IF "%_arg%"=="-i" SET INSTALLING=1

        IF DEFINED RESETING (
            @CALL _sys\_process-clean-reset

            SET RESETING=

            GOTO break
        )
        IF DEFINED CLEARING (
            @CALL _sys\_log-batch CLEAR %DL_PROCESSID_MASTER%
            @CALL _sys\_process-clean-clear

            SET CLEARING=

            GOTO exit
        )
        IF DEFINED INSTALLING (
            @CALL _sys\_log-batch SETUP %DL_PROCESSID_MASTER%
            @CALL _sys\_setup

            SET INSTALLING=

            GOTO exit
        )

        @CALL _sys\_log-batch ERROR "%DL_PROCESSID_MASTER% argument %_arg% existerar ej"
    )
) ELSE (
    @CALL _sys\_log-batch ERROR "Processen %DL_PROCESSID_MASTER% kunde inte k”ras"
    @CALL _sys\_log-error %DL_PROCESSID_MASTER% "Errorlevel %ERRORLEVEL% f”r %DL_PROCESSID_MASTER%"

    GOTO break
)


:exit
@CALL _sys\_log-batch KLART %DL_PROCESSID_MASTER%
:break
ENDLOCAL
PAUSE