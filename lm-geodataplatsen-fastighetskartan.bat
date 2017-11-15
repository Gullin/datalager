@CALL _global-settings
@CALL __secrets\_secrets.bat
SETLOCAL EnableDelayedExpansion

REM CP 437 (DOS)


REM S„tts per bat-fil
REM Namn f”r hela processen
SET DL_PROCESSNAME=lm-geodataplatsen-fastighetskartan
REM Processlokala parametrar
SET DL_OUTDIR=lantmateriet\gsd-fastighetskartan\
SET DL_FMEPROCESS01="_sys\_ftp-caller.fmw"
SET DL_FMEPROCESS02="%DL_PROCESSNAME%\_fme\01-KlippytorFromFKSkaneSw99TM.fmw"
SET DL_FMEPROCESS03="%DL_PROCESSNAME%\_fme\02-GSD-Fastighetskartan-DatalagerManage-driver.fmw"
IF NOT DEFINED DL_ISWHOLEPROCESS (
    SET DL_ISWHOLEPROCESS=0
)



@CALL _sys\_process-create-frame %DL_PROCESSNAME%
IF %DL_ISWHOLEPROCESS%==0 (
    @CALL _sys\_process-clean-clear %DL_PROCESSNAME%
)



REM Anv„nds f”r utdata vid alla FME-processer
SET DL_PROCESSMODULOUTDIR=%DL_ROTDIR%%DL_REPOSITORYROTDIR%%DL_OUTDIR%


REM skapar tidsst„mpel och unikt process-ID f”r sp†rning av k”rd batch-process
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
SET DL_PROCESSID=%DL_PROCESSNAME%_%CurrentDateTime%

@CALL _sys\_log-batch START %DL_PROCESSID%
IF %ERRORLEVEL% EQU 0 (



    REM FME-processer
    @CALL :GetFastighetskartanSkane

    REM Validering av data-schema
    @CALL _sys\_schema-driver %DL_PROCESSNAME% %DL_ISWHOLEPROCESS% validate NULL ESRISHAPE

    
    
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
        @CALL :CreateCutingSurface
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
                    @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel !ERRORLEVEL! fr†n FATAL_ERROR f”r %DL_PROCESSID% genererad av FME-processerna. Kunde ej g† vidare med distribuering av repository."

                    @CALL :SendErrorMessage
                )
            )
        ) ELSE (
            @CALL _sys\_log-batch ERROR "Allvarligt fel vid dataprocessandet i process %DL_PROCESSID%"
            @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_PROCESSID%, dataprocessandet har misslyckats"

            @CALL :SendErrorMessage
        )

    ) ELSE (
        @CALL _sys\_log-batch ERROR "Allvarligt fel vid validering av datasets schema i process %DL_PROCESSID%"
        @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_PROCESSID%, validering av dataschema har misslyckats"

        @CALL :SendErrorMessage
    )



) ELSE (
    @CALL _sys\_log-batch ERROR "Processen %DL_PROCESSID% kunde inte k”ras"
    @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_PROCESSID%"

    @CALL :SendErrorMessage
)


:exit
@CALL _sys\_log-batch KLART %DL_PROCESSID%
EXIT /B




REM ### METODER ###
REM Meddelandefunktion
REM Skickas endast om processmodulen k”rs individuellt och inte n„r datalagerprocessen k”rs i sin helhet
:SendErrorMessage
    IF %DL_ISWHOLEPROCESS% == 0 (
        @CALL _sys\_emailer-send-error %DL_PROCESSNAME%
    )
GOTO :eof

REM H„mtar Lantm„teriets Fastighetskartan
:GetFastighetskartanSkane
    @CALL _sys\_log-batch START "%DL_PROCESSID% %DL_FMEPROCESS01%"

    REM Landskrona --FtpUrl "ftp://download.lantmateriet.se/produkter/GSD-Fastighetskartan vektor/Skane/Landskrona/Sweref 99 1330/Shape/fk_1282.Sweref_99_1330.Shape.zip"
    REM Sk†ne      --FtpUrl "ftp://download.lantmateriet.se/produkter/GSD-Fastighetskartan vektor/Skane/Lan 12/Sweref 99 TM/Shape/fk_12.Sweref_99_TM.Shape.zip"
    @%DL_FMEFULLPATH% %DL_FMEPROCESS01% ^
                        --ProcessName %DL_PROCESSNAME% ^
                        --RotDirectory %DL_ROTDIR% ^
                        --FtpUrl "ftp://download.lantmateriet.se/produkter/GSD-Fastighetskartan vektor/Skane/Lan 12/Sweref 99 TM/Shape/fk_12.Sweref_99_TM.Shape.zip" ^
                        --User %USER-LM-GEODATAPLATSEN% ^
                        --Password %PASS-LM-GEODATAPLATSEN% ^
                        --OutputDirectory %DL_ROTDIR%%DL_PROCESSNAME%/_ned ^
                        --ProcessModulName %DL_PROCESSNAME% ^
                        --IsWholeProcessRun %DL_ISWHOLEPROCESS%

    IF %ERRORLEVEL% NEQ 0 (
        @CALL _sys\_log-batch ERROR "FME-processen slutf”rdes inte korrekt"
        @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_FMEPROCESS01%"

        EXIT /B
    ) ELSE (
        @CALL _sys\_log-batch KLART "%DL_PROCESSID% %DL_FMEPROCESS01%"
    )
GOTO :eof


REM Skapar klippytor fr†n kommungr„nser i Fastighetskartan
:CreateCutingSurface
    @CALL _sys\_log-batch START "Process %DL_PROCESSID% %DL_FMEPROCESS02%"

    REM Valfri parameter med enhet meter (anv„nds inte s„tts ett standardv„rde)
    REM FME-parameter --Buffer
    @%DL_FMEFULLPATH% %DL_FMEPROCESS02% ^
                        --ProcessName %DL_PROCESSNAME% ^
                        --RotDirectory %DL_ROTDIR% ^
                        --ShpInData %DL_ROTDIR%%DL_PROCESSNAME%/_ned/fk_12.Sweref_99_TM.Shape.zip ^
                        --ProcessModulName %DL_PROCESSNAME% ^
                        --IsWholeProcessRun %DL_ISWHOLEPROCESS%

    IF %ERRORLEVEL% NEQ 0 (
        @CALL _sys\_log-batch ERROR "FME-processen slutf”rdes inte korrekt"
        @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_FMEPROCESS02%"

        EXIT /B
    ) ELSE (
        @CALL _sys\_log-batch KLART "%DL_PROCESSID% %DL_FMEPROCESS02%"
    )
GOTO :eof


REM Hanterar data till datalager
:ManageSourceDatalager
    @CALL _sys\_log-batch START "%DL_PROCESSID% %DL_FMEPROCESS03%"

    @%DL_FMEFULLPATH% %DL_FMEPROCESS03% ^
                        --ProcessName %DL_PROCESSNAME% ^
                        --RotDirectory %DL_ROTDIR% ^
                        --OutputDirectory %DL_PROCESSMODULOUTDIR% ^
                        --ProcessModulName %DL_PROCESSNAME% ^
                        --IsWholeProcessRun %DL_ISWHOLEPROCESS%

    IF %ERRORLEVEL% NEQ 0 (
        @CALL _sys\_log-batch ERROR "FME-processen slutf”rdes inte korrekt"
        @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_FMEPROCESS03%"

        EXIT /B
    ) ELSE (
        @CALL _sys\_log-batch KLART "%DL_PROCESSID% %DL_FMEPROCESS03%"
    )
GOTO :eof
ENDLOCAL