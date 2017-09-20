@CALL _global-settings
SETLOCAL EnableDelayedExpansion

REM CP 437 (DOS)


REM S�tts per bat-fil
REM Namn f�r hela processen
SET DL_PROCESSNAME=lkr-oracle-lkr_gis
REM Processlokala parametrar
SET DL_OUTDIR=landskrona\lkr_gis\
SET DL_FMEPROCESS01="%DL_PROCESSNAME%\_fme\oracle-lkr_gis-DatalagerManage-driver.fmw"
IF NOT DEFINED DL_ISWHOLEPROCESS (
    SET DL_ISWHOLEPROCESS=0
)



@CALL _sys\_process-create-frame %DL_PROCESSNAME%



REM Anv�nds f�r utdata vid alla FME-processer
SET DL_PROCESSMODULOUTDIR=%DL_ROTDIR%%DL_REPOSITORYROTDIR%%DL_OUTDIR%

REM skapar tidsst�mpel och unikt process-ID f�r sp�rning av k�rd batch-process
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
SET DL_PROCESSID=%DL_PROCESSNAME%_%CurrentDateTime%

@CALL _sys\_log-batch START %DL_PROCESSID%
IF %ERRORLEVEL% EQU 0 (
    REM Validering av data-schema
    @CALL _sys\_schema-driver %DL_PROCESSNAME% %DL_ISWHOLEPROCESS% validate NULL ORACLE_SPATIAL LKR_GIS

    REM Kontrollerar om valideringen har godk�nnts annars k�rs ej resterande
    IF DEFINED DL_ISWHOLEPROCESS (
        @CALL _sys\_exist-FATAL_ERROR
    ) ELSE (
        @CALL _sys\_exist-FATAL_ERROR %DL_PROCESSNAME%
    )

    IF NOT !ERRORLEVEL!==99999 (



        REM FME-processer
        @CALL :ManageSourceDatalager



        REM Loggning av resp. process resurskatalog f�r distribuering och distribuering om processmodulen k�rs enskilt
        REM Distribuering g�rs ej vid fel.
        IF %DL_ISWHOLEPROCESS% == 1 (
            ECHO %DL_OUTDIR% >> %DL_DISTSOURCE%
        ) ELSE (
            @CALL _sys\_exist-FATAL_ERROR %DL_PROCESSNAME%

            IF !ERRORLEVEL! NEQ 99999 (
                ECHO %DL_OUTDIR% > %DL_ROTDIR%%DL_PROCESSNAME%/_log/%DL_DISTSOURCEFILE%
                @CALL _sys\_datalager-distribute %DL_PROCESSNAME%
            ) ELSE (
                @CALL _sys\_log-batch ERROR "Allvarligt fel i FME-skript vid exekvering av process %DL_PROCESSID%"
                @CALL :Message
            )
        )

    ) ELSE (
        @CALL _sys\_log-batch ERROR "Allvarligt fel vid validering av datasets schema i process %DL_PROCESSID%"
        @CALL :Message
    )


) ELSE (
    @CALL _sys\_log-batch ERROR "Processen %DL_PROCESSID% kunde inte k�ras"
    @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f�r %DL_PROCESSID%"

    GOTO break
)


:exit
@CALL _sys\_log-batch KLART %DL_PROCESSID%
:break
EXIT /B




REM ### METODER ###
REM Meddelandefunktion
:Message
    IF %DL_ISWHOLEPROCESS% == 0 (
        REM TODO: K�r meddelandefunktion - NOT IMPLEMENTED
        ECHO Meddelar...
    )
GOTO :eof

REM Hanterar data till datalager
:ManageSourceDatalager
    @CALL _sys\_log-batch START "%DL_PROCESSID% %DL_FMEPROCESS01%"

    REM Valfri parameter med enhet meter (anv�nds inte s�tts ett standardv�rde)
    REM FME-parameter --InData (tabeller som ska l�sas skrivs med punktnoterad schemanamn och tabellnamn [ex. LKR_GIS.GIS_V_BLADINDELNING], mellanslag mellan tabeller)
    @%DL_FMEFULLPATH% %DL_FMEPROCESS01% ^
                        --ProcessName %DL_PROCESSNAME% ^
                        --RotDirectory %DL_ROTDIR% ^
                        --Manifest %DL_ROTDIR%%DL_PROCESSNAME%\_schema\schema-manifest.xlsx ^
                        --OutputDirectory %DL_PROCESSMODULOUTDIR% ^
                        --ProcessModulName %DL_PROCESSNAME% ^
                        --IsWholeProcessRun %DL_ISWHOLEPROCESS%

    IF %ERRORLEVEL% NEQ 0 (
        @CALL _sys\_log-batch ERROR "FME-processen slutf�rdes inte korrekt"
        @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f�r %DL_FMEPROCESS01%"

        EXIT /B
    ) ELSE (
        @CALL _sys\_log-batch KLART "%DL_PROCESSID% %DL_FMEPROCESS01%"
    )
GOTO :eof
ENDLOCAL