@CALL _global-settings
@call __secrets\_secrets.bat
SETLOCAL

REM CP 437 (DOS)


REM S„tts per bat-fil
REM Namn f”r hela processen
SET DL_PROCESSNAME=lm-geodataplatsen-fastighetskartan
REM Processlokala parametrar
SET DL_OUTDIR=lantmateriet\gsd-fastighetskartan\
SET DL_FMEPROCESS01="_sys\_ftp-caller.fmw"
SET DL_FMEPROCESS02="%DL_PROCESSNAME%\_fme\01-KlippytorFromFKSkaneSw99TM.fmw"
SET DL_FMEPROCESS03="%DL_PROCESSNAME%\_fme\02-GSD-Fastighetskartan-DatalagerManage-driver.fmw"



@CALL _sys\_process-create-frame %DL_PROCESSNAME%



REM Anv„nds f”r utdata vid alla FME-processer
SET DL_PROCESSMODULOUTDIR=%DL_ROTDIR%%DL_REPOSITORYROTDIR%%DL_OUTDIR%


REM skapar tidsst„mpel och unikt process-ID f”r sp†rning av k”rd batch-process
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
SET DL_PROCESSID=%DL_PROCESSNAME%_%CurrentDateTime%

@CALL _sys\_log-batch START %DL_PROCESSID%
IF %ERRORLEVEL% EQU 0 (



    REM FME-processer
    REM @CALL :GetFastighetskartanSkane
    REM @CALL :CreateCutingSurface
    @CALL :ManageSourceDatalager



    REM Loggning av resp. process resurskatalog f”r distribuering och distribuering om processmodulen k”rs enskilt
    IF DEFINED DL_ISWHOLEPROCESS (
        ECHO %DL_OUTDIR% >> %DL_DISTSOURCE%
    ) ELSE (
        ECHO %DL_OUTDIR% > %DL_ROTDIR%%DL_PROCESSNAME%/_log/%DL_DISTSOURCEFILE%
        @CALL _sys\_datalager-distribute %DL_PROCESSNAME%
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
                        --OutputDirectory %DL_ROTDIR%%DL_PROCESSNAME%/_ned

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
                        --ShpInData %DL_ROTDIR%%DL_PROCESSNAME%/_ned/fk_12.Sweref_99_TM.Shape.zip

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
                        --OutputDirectory %DL_PROCESSMODULOUTDIR%

    IF %ERRORLEVEL% NEQ 0 (
        @CALL _sys\_log-batch ERROR "FME-processen slutf”rdes inte korrekt"
        @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_FMEPROCESS03%"

        EXIT /B
    ) ELSE (
        @CALL _sys\_log-batch KLART "%DL_PROCESSID% %DL_FMEPROCESS03%"
    )
GOTO :eof
ENDLOCAL