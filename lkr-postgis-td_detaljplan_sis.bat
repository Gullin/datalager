@CALL _global-settings
SETLOCAL EnableDelayedExpansion

REM CP 437 (DOS)


REM S„tts per bat-fil
REM Namn f”r hela processen
SET DL_PROCESSNAME=lkr-postgis-td_detaljplan_sis
REM Processlokala parametrar
SET DL_OUTDIR=landskrona\td_detaljplan_sis
SET DL_OUTDBSCHEMA=data_auto_landskrona_td_detaljplan_sis
SET DL_FMEPROCESS01="%DL_PROCESSNAME%\_fme\postgis-td_detaljplan_sis-DatalagerManage-driver.fmw"
IF NOT DEFINED DL_ISWHOLEPROCESS (
    SET DL_ISWHOLEPROCESS=0
)



@CALL _sys\_process-create-frame %DL_PROCESSNAME%
IF %DL_ISWHOLEPROCESS%==0 (
    @CALL _sys\_log-batch #INIT ########################################
    @CALL _sys\_process-clean-clear %DL_PROCESSNAME%
)



REM Anv„nds f”r utdata vid alla FME-processer
SET DL_PROCESSMODULOUTDIR=%DL_ROTDIR%%DL_REPOSITORYROTDIR%%DL_OUTDIR%

REM skapar tidsst„mpel och unikt process-ID f”r sp†rning av k”rd batch-process
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
SET DL_PROCESSID=%DL_PROCESSNAME%_%CurrentDateTime%

@CALL _sys\_log-batch START %DL_PROCESSID%
IF %ERRORLEVEL% EQU 0 (
    REM Validering av data-schema
    REM Žndras f”r resp. processmodul
    @CALL _sys\_schema-driver %DL_PROCESSNAME% %DL_ISWHOLEPROCESS% validate NULL POSTGIS PG_GEODATA

    REM Kontrollerar om valideringen har godk„nnts annars k”rs ej resterande
    IF %DL_ISWHOLEPROCESS% == 1 (
        @CALL _sys\_exist-FATAL_ERROR
    ) ELSE (
        @CALL _sys\_exist-FATAL_ERROR %DL_PROCESSNAME%
    )

    IF !ERRORLEVEL! NEQ 99999 (

        REM Nollst„ller felkod genom en instruktion som endast kan fungera
        verify >nul



        REM FME-processer
        @CALL :ManageSourceDatalager



        IF !ERRORLEVEL! EQU 0 (
            REM Loggning av resp. process resurskatalog f”r distribuering och distribuering om processmodulen k”rs enskilt
            REM Distribuering g”rs ej vid fel.
            IF %DL_ISWHOLEPROCESS% == 1 (
                ECHO %DL_OUTDIR% >> %DL_DISTSOURCE%
            ) ELSE (
                @CALL _sys\_exist-FATAL_ERROR %DL_PROCESSNAME%

                IF !ERRORLEVEL! NEQ 99999 (
                    ECHO %DL_OUTDIR% > %DL_ROTDIR%%DL_PROCESSNAME%/_log/%DL_DISTSOURCEFILE%
                    @CALL _sys\_datalager-distribute %DL_PROCESSNAME%
                ) ELSE (
                    @CALL _sys\_log-batch ERROR "Allvarligt fel i FME-skript vid exekvering av process %DL_PROCESSID%"
                    @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel !ERRORLEVEL! fr†n FATAL_ERROR f”r %DL_PROCESSID% genererad av FME-processerna. Kunde ej g† vidare med distribuering av repository." %DL_PROCESSNAME%

                    GOTO exit
                )
            )
        ) ELSE (
            @CALL _sys\_log-batch ERROR "Allvarligt fel vid dataprocessandet i process %DL_PROCESSID%"
            @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_PROCESSID%, dataprocessandet har misslyckats" %DL_PROCESSNAME%

            GOTO exit
        )

    ) ELSE (
        @CALL _sys\_log-batch ERROR "Allvarligt fel vid validering av datasets schema i process %DL_PROCESSID%"
        @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_PROCESSID%, validering av dataschema har misslyckats" %DL_PROCESSNAME%

        GOTO exit
    )


) ELSE (
    @CALL _sys\_log-batch ERROR "Processen %DL_PROCESSID% kunde inte k”ras"
    @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_PROCESSID%" %DL_PROCESSNAME%

    GOTO exit
)


:exit
REM Kontrollerar om processen har k”rts med allvarliga fel, i s† fall skicka meddelande
@CALL _sys\_exist-FATAL_ERROR %DL_PROCESSNAME%

IF !ERRORLEVEL! EQU 99999 (
    IF %DL_ISWHOLEPROCESS% == 0 (
        REM Meddelandefunktion
        REM Skickas endast om processmodulen k”rs individuellt och inte n„r datalagerprocessen k”rs i sin helhet
        @CALL _sys\_emailer-send-error %DL_PROCESSNAME%
    )
)

@CALL _sys\_log-batch KLART %DL_PROCESSID%
EXIT /B




REM ### METODER ###
REM Hanterar data till datalager
:ManageSourceDatalager
    @CALL _sys\_log-batch START "%DL_PROCESSID% %DL_FMEPROCESS01%"

    REM <#BESKRIVNING AV PARAMETRAR TILL FME-PROCESS#>
    >nul (
        @%DL_FMEFULLPATH% %DL_FMEPROCESS01% ^
                            --ProcessName %DL_PROCESSNAME% ^
                            --RotDirectory %DL_ROTDIR% ^
                            --OutputDirectory %DL_PROCESSMODULOUTDIR% ^
                            --ProcessModulName %DL_PROCESSNAME% ^
                            --IsWholeProcessRun %DL_ISWHOLEPROCESS% ^
                            --PG_SCHEMA %DL_OUTDBSCHEMA%
    )

    IF %ERRORLEVEL% NEQ 0 (
        @CALL _sys\_log-batch ERROR "FME-processen slutf”rdes inte korrekt"
        @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_FMEPROCESS01%" %DL_PROCESSNAME%

        EXIT /B
    ) ELSE (
        @CALL _sys\_log-batch KLART "%DL_PROCESSID% %DL_FMEPROCESS01%"
    )
GOTO :eof
ENDLOCAL