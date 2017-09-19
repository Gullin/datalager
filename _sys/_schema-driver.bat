@ECHO OFF
@CALL _global-settings


REM CP 437 (DOS)
REM Argument 1: Processmodulsnamn
REM Argument 2: Action f�r Workspace Drivern. Antar v�rde [write | validate]. �vriga argument beh�ver ej ha v�rde vid "validate".
REM Argument 3: Suffix p� fil f�r schema-dokumentationen (standardsuffix "flush", f�r att inte skriva �ver en ev. init-fil).
REM             Ska endast anta init eller flush. "init" ska endast anv�ndas n�r utg�ngsfil skapas f�r manifest. "flush" skapas vid varje datak�rning.
REM             Validering mellan k�rningar g�rs med "manifest" mot "flush".
REM Argument 4: Format, FME:s kortnamn f�r formatet. Fungerar som signal f�r hur FME ska tolka datasetet.
REM             ESRISHAPE           F�r ESRI shape-filer
REM             ORACLE_SPATIAL      F�r databas Oracle och datatypen spatial
REM Argument 5: Dataset vars schema-struktur ska l�sas av.
REM             F�r filer anges s�kv�g och f�r databas anges det namn i FME som definierar anslutningen. Absoluta s�kv�gen anges vid filer.
REM             F�r specifik fil ange exempelvis c:\katalog\dataset.shp
REM             F�r flera filer ange exempelvis c:\katalog\*.shp
REM             Vid databas beh�ver databasanslutningen vara f�rdefinierad i fmw-filen, formatets l�sare beh�ver vara tillagd som
REM             "Workspace Resource" f�r att komma �t dess specifika parametrar och kopplad till databasanslutningen f�r databasl�sare.
REM Argument 6: Tabeller, anv�nds n�r datasetet �r en databas f�r tabellnamn. Flera tabellnamn listas med mellanrum som separator och
REM             inom situationstecken. Ej k�nslig f�r stora eller sm� bokst�ver.
REM             Beh�ver ej v�rde om datasetet ej �r en databas. Argumentet beh�ver dock alltid komma sist f�r att kunna hantera ett icke-v�rde.


IF NOT [%1]==[] (
    SET _arg1=%1
)
IF NOT [%2]==[] (
    SET _arg2=%2
)
IF NOT [%3]==[] (
    SET _arg3=%3
) ELSE (
    SET _arg3=flush
)
IF NOT [%4]==[] (
    SET _arg4=%4
)
IF NOT [%5]==[] (
    SET _arg5=%5
) ELSE (
    SET _arg5=NULL
)
REM Hanterar icke-v�rde f�r argumentet som definierar vilka tabeller som ska h�mtas vid databas som dataset
IF NOT [%6]==[] (
    SET _arg6=%6
) ELSE (
    SET _arg6=NULL
)

REM S�tts per bat-fil
REM Namn f�r hel- eller delprocessen (modul) som batch-filen hanterar
SET DL_PROCESSNAME=_schema
SET DL_FMEPROCESS01="_sys\_schema-driver.fmw"


REM skapar tidsst�mpel och unikt process-ID f�r sp�rning av k�rd batch-process
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
SET DL_PROCESSID=%DL_PROCESSNAME%_%CurrentDateTime%

@CALL _sys\_log-batch START %DL_PROCESSID%
IF %ERRORLEVEL% EQU 0 (



    REM FME-processer
    @CALL :SchemaInit



) ELSE (
    @CALL _sys\_log-batch ERROR "Processen %DL_PROCESSID% kunde inte k�ras"
    @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f�r %DL_PROCESSID%"

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
                        --DriverAction %_arg2% ^
                        --InData %_arg5% ^
                        --InData-DatabaseTable %_arg6% ^
                        --DataFormat %_arg4% ^
                        --OutSchemaFileNameSuffix %_arg3%^
                        --OutputDirectory %DL_ROTDIR%%_arg1%\_schema\

    IF %ERRORLEVEL% NEQ 0 (
        @CALL _sys\_log-batch ERROR "FME-processen slutf�rdes inte korrekt"
        @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f�r %DL_FMEPROCESS01%"

        EXIT /B
    ) ELSE (
        @CALL _sys\_log-batch KLART "%DL_PROCESSID% %DL_FMEPROCESS01%"
    )
GOTO :eof