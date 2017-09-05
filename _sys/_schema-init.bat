@ECHO OFF
@CALL _global-settings

REM CP 437 (DOS)
REM Argument 1: Processmodulsnamn
REM Argument 2: Dataset vars schema-struktur ska l„sas av. Absoluta s”kv„gen anges vid filer. Format tolkas av FME.
REM             F”r specifik fil ange exempelvis c:\katalog\dataset.shp
REM             F”r flera filer ange exempelvis c:\katalog\*.shp

IF NOT [%1]==[] (
    SET _arg1=%1
)
IF NOT [%2]==[] (
    SET _arg2=%2
)

REM S„tts per bat-fil
REM Namn f”r hel- eller delprocessen (modul) som batch-filen hanterar
SET DL_PROCESSNAME=_schema-init
SET DL_FMEPROCESS01="_sys\_schema-init.fmw"


REM skapar tidsst„mpel och unikt process-ID f”r sp†rning av k”rd batch-process
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
SET DL_PROCESSID=%DL_PROCESSNAME%_%CurrentDateTime%

@CALL _sys\_log-batch START %DL_PROCESSID%
IF %ERRORLEVEL% EQU 0 (



    REM FME-processer
    @CALL :SchemaInit



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
:SchemaInit
    @CALL _sys\_log-batch START "%DL_PROCESSID% %DL_FMEPROCESS01%"

    @%DL_FMEFULLPATH% %DL_FMEPROCESS01% ^
                        --ProcessName %DL_PROCESSID% ^
                        --RotDirectory %DL_ROTDIR% ^
                        --InData %_arg2% ^
                        --OutputDirectory %DL_ROTDIR%%_arg1%\_schema\

    IF %ERRORLEVEL% NEQ 0 (
        @CALL _sys\_log-batch ERROR "FME-processen slutf”rdes inte korrekt"
        @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_FMEPROCESS01%"

        EXIT /B
    ) ELSE (
        @CALL _sys\_log-batch KLART "%DL_PROCESSID% %DL_FMEPROCESS01%"
    )
GOTO :eof