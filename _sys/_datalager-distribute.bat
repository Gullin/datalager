@ECHO OFF
@CALL _global-settings

REM CP 437 (DOS)
REM Argument 1: Om processmodulen k”rs enskilt skickas processmodulens utkatalog med in som argument

IF NOT [%1]==[] (
    SET _arg=%1
)

REM S„tts per bat-fil
REM Namn f”r hel- eller delprocessen (modul) som batch-filen hanterar
SET DL_PROCESSNAME=_datalager_distribute
SET DL_FMEPROCESS01="_sys\_datalager-distribute.fmw"


REM skapar tidsst„mpel och unikt process-ID f”r sp†rning av k”rd batch-process
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
SET DL_PROCESSID=%DL_PROCESSNAME%_%CurrentDateTime%

@CALL _sys\_log-batch START %DL_PROCESSID%
IF %ERRORLEVEL% EQU 0 (
    IF DEFINED DL_ISWHOLEPROCESS (
        SET DL_SOURCES=%DL_ROTDIR%%DL_DISTSOURCE%



        REM FME-processer
        @CALL :DistributeDatalager



    ) ELSE (
        SET DL_SOURCES=%DL_ROTDIR%%_arg%\_temp\%DL_DISTSOURCEFILE%
    ECHO INNE-MODUL



    REM FME-processer
    @CALL :DistributeDatalager



    )
) ELSE (
    @CALL _sys\_log-batch ERROR "Processen %DL_PROCESSID% kunde inte k”ras"
    @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_PROCESSID%"

    GOTO break
)


:exit
@CALL _sys\_log-batch KLART %DL_PROCESSID%
:break
EXIT /B



REM Metoder
:DistributeDatalager
    @CALL _sys\_log-batch START "%DL_PROCESSID% %DL_FMEPROCESS01%"

    @%DL_FMEFULLPATH% %DL_FMEPROCESS01% ^
                        --ProcessName %DL_PROCESSID% ^
                        --RotDirectory %DL_ROTDIR% ^
                        --InData %DL_SOURCES% ^
                        --RepoSourceDirectory %DL_ROTDIR%%DL_REPOSITORYROTDIR%

    IF %ERRORLEVEL% NEQ 0 (
        @CALL _sys\_log-batch ERROR "FME-processen slutf”rdes inte korrekt"
        @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_FMEPROCESS01%"

        EXIT /B
    ) ELSE (
        @CALL _sys\_log-batch KLART "%DL_PROCESSID% %DL_FMEPROCESS01%"
    )
GOTO :eof