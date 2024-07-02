@ECHO OFF
SETLOCAL EnableDelayedExpansion
@CALL _global-settings

REM CP 437 (DOS)
REM Argument 1: V„xel [ null | [ ---reset|-r ]          | [ --clear|-c ] | 
REM                            [ --schemainit|-si ]     | [ --backupconfig|-bc ] |
REM                            [ --createsecrets|-cs ]  | [ --deploy|-d ] |
REM                            [ --instal|-i ]          | [ --execute|-e]]

REM Kontrollerar om ett argument existerar, anv„nder argumentet f”r alternativ till att k”ra hela processen.
REM Ska hela processen k”ras skickas inget argument med.
IF NOT [%1]==[] (
    SET _arg=%1
)

REM S„tts per bat-fil
REM Namn f”r hel- eller delprocessen (modul) som batch-filen hanterar
SET DL_PROCESSNAME=datalager

REM S„tts till 1 f”r att indikera att datalagerprocessen k”rs i sin helhet. Anv„nds vid utdistribuering av repot,
REM testas mot variablen i modulerna f”r veta var k„lla till ut kopiering ska skrivas (globalt eller f”r modulen).
REM 0 = processmodul
REM 1 = datalagerprocessen i sin helhet (standardinst„llning)
REM 2 = k”rs med argument, olika metoder, och utg”r inte n†gon dataprocess
SET DL_ISWHOLEPROCESS=1



@CALL _sys\_log-batch #INIT ########################################


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

        CLS
        ECHO.
        ECHO Anv„ndning: datalager [val]
        ECHO.
        ECHO [val]:
        ECHO   --execute ^| -e              Exekverar alla processmoduler f”r databearbetning
        ECHO   --extract ^| -ex             Exekverar alla processmoduler f”r extrahering och insamling av data till repo, ingen distribuering g”rs
        ECHO   --distributionsource ^| -ds  Listar k„llor, f”r distribuering fr†n datarepo, till fil %DL_DISTSOURCEFILE% under "%DL_ROTDIR%%DL_REPOSITORYROTDIR%"
        ECHO   --reset ^| -r                Raderar allt som inte „r n”dv„ndigt f”r datalagerprocessen ^(loggar, data, backup, publisering, ej aff„rslogik^)
        ECHO   --clear ^| -c                Raderar loggar och publiceringsunderlag ^(_deploy, skapad av --deploy^)
        ECHO   --schemainit ^| -si          Initierar nytt schema f”r dataset som underlag f”r manifest
        ECHO   --backupconfig ^| -bc        S„kerhetskopierar schema-filer ^(xlsx, ini^) och inst„llningar f”r m†lkataloger
        ECHO   --createsecrets ^| -cs       Skapar bat-fil med f”ruts„ttningarna ^(variabelnamn^) f”r n”dv„ndiga inlogg och e-postinst„llningar f”r fortsatt ifyllnad
        ECHO   --deploy ^| -d               Skapar en katalog _deploy med de filer och kataloger som kr„vs f”r upps„ttning av ny fullst„ndig process ^(ej inst„llningar och schema^)
        ECHO   --instal ^| -i               OBS Ej fungerande p.g.a. process ej g†r att k”ra genom Windows path.
        ECHO.
        PAUSE

    ) ELSE (
        
        SET DL_ISWHOLEPROCESS=2

        IF "%_arg%"=="--execute" SET EXECUTE=1
        IF "%_arg%"=="-e" SET EXECUTE=1
        IF "%_arg%"=="--extract" SET EXTRACT=1
        IF "%_arg%"=="-ex" SET EXTRACT=1
        IF "%_arg%"=="--distributionsource" SET DISTRIBUTION=1
        IF "%_arg%"=="-ds" SET DISTRIBUTION=1
        IF "%_arg%"=="--reset" SET RESETING=1
        IF "%_arg%"=="-r" SET RESETING=1
        IF "%_arg%"=="--clear" SET CLEARING=1
        IF "%_arg%"=="-c" SET CLEARING=1
        IF "%_arg%"=="--schemainit" SET SCHEMAINIT=1
        IF "%_arg%"=="-si" SET SCHEMAINIT=1
        IF "%_arg%"=="--backupconfig" SET BACKUPCONF=1
        IF "%_arg%"=="-bc" SET BACKUPCONF=1
        IF "%_arg%"=="--createsecrets" SET CREATESECRETS=1
        IF "%_arg%"=="-cs" SET CREATESECRETS=1
        IF "%_arg%"=="--deploy" SET DEPLOY=1
        IF "%_arg%"=="-d" SET DEPLOY=1
        IF "%_arg%"=="--instal" SET INSTALLING=1
        IF "%_arg%"=="-i" SET INSTALLING=1 ELSE GOTO notdefined

        IF DEFINED EXECUTE (
            SET DL_ISWHOLEPROCESS=1
            @CALL :ExecuteDatalager

            SET EXECUTE=

            GOTO exit
        )
        IF DEFINED EXTRACT (
            SET DL_ISWHOLEPROCESS=1
            @CALL :ExecuteDatalager

            SET EXTRACT=

            GOTO exit
        )
        IF DEFINED DISTRIBUTION (
            CD /D "%DL_POWERSHELLDIR%"

            ECHO "%DL_ROTDIR%%DL_REPOSITORYROTDIR%"
            Powershell -noprofile -File "%DL_ROTDIR%_sys\_create_DatalagerDistributionSource.log.ps1" -rootFolder "%DL_ROTDIR%%DL_REPOSITORYROTDIR%"

            CD /D %DL_ROTDIR%

            SET DISTRIBUTION=

            GOTO exit
        )
        IF DEFINED RESETING (
            @CALL _sys\_process-clean-reset

            SET RESETING=

            GOTO exit
        )
        IF DEFINED CLEARING (
            @CALL _sys\_log-batch CLEAR %DL_PROCESSID_MASTER%
            @CALL _sys\_process-clean-clear

            SET CLEARING=

            GOTO exit
        )
        IF DEFINED SCHEMAINIT (
            IF [%4]==[] (
                SET _arg4=NULL
            ) ELSE (
                SET _arg4=%4
            )
            IF [%5]==[] (
                SET _arg5=NULL
            ) ELSE (
                SET _arg5=%5
            )

            @CALL _sys\_log-batch SCHEM %DL_PROCESSID_MASTER%
            @CALL _sys\_schema-driver %2 %DL_ISWHOLEPROCESS% write init %3 !_arg4! !_arg5!

            SET SCHEMAINIT=

            GOTO exit
        )
        IF DEFINED BACKUPCONF (
            @CALL _sys\_log-batch BKPCF %DL_PROCESSID_MASTER%
            @CALL _sys\_backup-config %2

            SET BACKUPCONF=

            GOTO exit
        )
        IF DEFINED CREATESECRETS (
            @CALL _sys\_log-batch SECTS %DL_PROCESSID_MASTER%
            @CALL _sys\_create-secrets-body

            SET CREATESECRETS=

            GOTO exit
        )
        IF DEFINED DEPLOY (
            @CALL _sys\_log-batch DPLOY %DL_PROCESSID_MASTER%
            @CALL _sys\_deploy

            SET DEPLOY=

            GOTO exit
        )
        IF DEFINED INSTALLING (
            @CALL _sys\_log-batch SETUP %DL_PROCESSID_MASTER%
            @CALL _sys\_setup

            SET INSTALLING=

            GOTO exit
        )

        :notdefined
        ECHO V„xeln ej definerad

        @CALL _sys\_log-batch ERROR "%DL_PROCESSID_MASTER% argument %_arg% existerar ej"
        @CALL _sys\_log-error %DL_PROCESSID_MASTER% "Errorlevel %ERRORLEVEL% f”r %DL_PROCESSID_MASTER%, argument %_arg% existerar ej"
        
        GOTO exit
    )
) ELSE (
    @CALL _sys\_log-batch ERROR "Processen %DL_PROCESSID_MASTER% kunde inte k”ras"
    @CALL _sys\_log-error %DL_PROCESSID_MASTER% "Errorlevel %ERRORLEVEL% f”r %DL_PROCESSID_MASTER%"

    GOTO exit
)


:exit
REM Kontrollerar om processen har k”rts med allvarliga fel, i s† fall skicka meddelande
@CALL _sys\_exist-FATAL_ERROR

IF !ERRORLEVEL! EQU 99999 (
    @CALL _sys\_emailer-send-error %DL_PROCESSNAME%
)

@CALL _sys\_log-batch KLART %DL_PROCESSID_MASTER%
ENDLOCAL
EXIT


:ExecuteDatalager
    @CALL _sys\_process-clean-clear

    REM M†lkatalog f”r processernas resulterande data.
    REM Variabeln DL_REPOSITORYROTDIR ska skickas med som parameter till alla FME-processer som genererar output till datalagret.
    REM Respektive processmodul skapar upp sina substrukturer under repo-roten.
    IF NOT DEFINED DL_REPOSITORYROTDIR SET DL_REPOSITORYROTDIR=_geodatarepo\

    REM Loggning av resp. process resurskatalog f”r distribuering senare i processen. Skapar tom fil.
    >nul ECHO 2> %DL_DISTSOURCE%


    REM Processmoduler
    @CALL lkr-anpassat
    @CALL lkr-anpassat-ecos
    @CALL lkr-postgis-lk_gis
    @CALL lkr-postgis-lk_gis_anpassat
    @CALL lkr-postgis-ex_special
    @CALL lkr-postgis-td_baskarta
    @CALL lkr-postgis-td_baskarta_anpassat
    @CALL lkr-postgis-td_baskarta_anpassat_markdetaljtyp
    @CALL lkr-postgis-td_detaljplan
    @CALL lkr-postgis-td_drk
    @CALL lkr-postgis-td_drk_anpassat
    @CALL lkr-postgis-td_bal
    @CALL lkr-postgis-td_bal_anpassat

    @CALL lkr-postgis-flex_grund

    @REM "lm-geodataplatsen-fastighetskartan" ska plockas bort i en kommande version. Ers„tts med "GSD-Fastighetskartan topografi, vektor"
    @REM @CALL lm-geodataplatsen-fastighetskartan

    @CALL lm-geotorget
    @CALL lst
    @CALL raa
    @CALL nvv
    @CALL trv
    @CALL trv-lastkajen
    @CALL msb



    REM Kontrollerar om processen har k”rts utan allvarliga fel, distribueras i s† fall
    @CALL _sys\_exist-FATAL_ERROR
    
    IF !ERRORLEVEL! NEQ 99999 (
        IF NOT DEFINED EXTRACT (
            REM Kopierar ut genererat datalager till platser. Platser definieras i rutinen.
            @CALL _sys\_datalager-distribute %DL_PROCESSNAME%
        )
    ) ELSE (
        @CALL _sys\_log-batch ERROR "Allvarligt fel i FME-skript vid exekvering av process %DL_PROCESSID_MASTER%"
        @CALL _sys\_log-error %DL_PROCESSID_MASTER% "Errorlevel !ERRORLEVEL! fr†n FATAL_ERROR i %DL_PROCESSID_MASTER% f”r n†gon av processmodulerna"

        GOTO exit
    )

GOTO :eof