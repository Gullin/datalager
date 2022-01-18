@CALL _global-settings
@CALL __secrets\_secrets.bat
SETLOCAL EnableDelayedExpansion

REM CP 437 (DOS)


REM Processmodulen kan ta 1 argument, antingen f”rkortat eller utskrivet, -oo | --only-order.
REM Skickas inget eller fel argument k”rs hela processen.
REM Kontrollerar om ett argument existerar, anv„nder argumentet f”r att alternativt k”ra processen f”r att endast genomf”ra en best„llning av leverans.
IF NOT [%1]==[] (
    SET _arg=%1

    IF "!_arg!"=="-oo" SET ORDER=1
    IF "!_arg!"=="--only-order" SET ORDER=1
)

REM S„tts per bat-fil
REM Namn f”r hela processen
SET DL_PROCESSNAME=lm-geotorget
REM Processlokala parametrar
SET DL_OUTDIR=lantmateriet\topografi_10_nedladdning
SET DL_FMEPROCESS01="%DL_PROCESSNAME%\_fme\01-download-geotorget-api.fmw"
SET DL_FMEPROCESS02="%DL_PROCESSNAME%\_fme\02-geotorget-DatalagerManage-driver.fmw"
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
    
    REM Loggar att processen k”rs med endast best„llning av ny leverans
    IF "%ORDER%"=="1" (
        @CALL _sys\_log-batch INFOR "%DL_PROCESSID% Best„ller ny leverans enligt befintliga order-ID:n i _modul-settings-datasets.ini"
    )



    REM FME-processer
    @CALL :GetDataGeotorget



    REM Hela processen med databeredning k”rs om inte argument med r„tt v„rde existerar
    IF "%ORDER%"=="1" (

        @CALL _sys\_log-batch INFOR "%DL_PROCESSID% Data processas inte"
        GOTO exit

    ) ELSE (

        REM Validering av data-schema
        REM Žndras f”r resp. processmodul
        @CALL _sys\_schema-driver %DL_PROCESSNAME% %DL_ISWHOLEPROCESS% validate NULL OGCGEOPACKAGE

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
REM H„mta data fr†n Geotorget
:GetDataGeotorget
    @CALL _sys\_log-batch START "%DL_PROCESSID% %DL_FMEPROCESS01%"

    REM <#BESKRIVNING AV PARAMETRAR TILL FME-PROCESS#>
    >nul (
        @%DL_FMEFULLPATH% %DL_FMEPROCESS01% ^
                            --ProcessName %DL_PROCESSNAME% ^
                            --RotDirectory %DL_ROTDIR% ^
                            --MaxTimmarTillNyLeverans 24 ^
                            --CONSUMERKEY %CONSUMERKEY-LM-GEOTORGET% ^
                            --CONSUMERSECRET %CONSUMERSECRET-LM-GEOTORGET% ^
                            --OnlyOrder "%ORDER%" ^
                            --OutputDirectory %DL_ROTDIR%%DL_PROCESSNAME%/_ned ^
                            --ProcessModulName %DL_PROCESSNAME% ^
                            --IsWholeProcessRun %DL_ISWHOLEPROCESS%
    )

    IF %ERRORLEVEL% NEQ 0 (
        @CALL _sys\_log-batch ERROR "FME-processen slutf”rdes inte korrekt"
        @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_FMEPROCESS01%" %DL_PROCESSNAME%

        EXIT /B
    ) ELSE (
        @CALL _sys\_log-batch KLART "%DL_PROCESSID% %DL_FMEPROCESS01%"
    )
GOTO :eof


REM Hanterar data till datalager
:ManageSourceDatalager
    @CALL _sys\_log-batch START "%DL_PROCESSID% %DL_FMEPROCESS01%"

    REM <#BESKRIVNING AV PARAMETRAR TILL FME-PROCESS#>
    >nul (
        @%DL_FMEFULLPATH% %DL_FMEPROCESS02% ^
                            --ProcessName %DL_PROCESSNAME% ^
                            --RotDirectory %DL_ROTDIR% ^
                            --OutputDirectory %DL_PROCESSMODULOUTDIR% ^
                            --ProcessModulName %DL_PROCESSNAME% ^
                            --IsWholeProcessRun %DL_ISWHOLEPROCESS%
    )

    IF %ERRORLEVEL% NEQ 0 (
        @CALL _sys\_log-batch ERROR "FME-processen slutf”rdes inte korrekt"
        @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_FMEPROCESS02%" %DL_PROCESSNAME%

        EXIT /B
    ) ELSE (
        @CALL _sys\_log-batch KLART "%DL_PROCESSID% %DL_FMEPROCESS02%"
    )
GOTO :eof
ENDLOCAL