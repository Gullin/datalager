@ECHO OFF
@CALL _global-settings


SET DL_PROCESSNAME=%1

IF NOT EXIST %DL_PROCESSNAME% (
    MD %DL_PROCESSNAME%
    @CALL _sys\_log-batch INFOR "Skapad katalog %DL_PROCESSNAME%"
)

IF NOT EXIST %DL_PROCESSNAME%\_fme (
    MD %DL_PROCESSNAME%\_fme
    @CALL _sys\_log-batch INFOR "Skapad katalog %DL_PROCESSNAME%\_fme"
)

IF NOT EXIST %DL_PROCESSNAME%\_log (
    MD %DL_PROCESSNAME%\_log
    @CALL _sys\_log-batch INFOR "Skapad katalog %DL_PROCESSNAME%\_log"
)

IF NOT EXIST %DL_PROCESSNAME%\_ned (
    MD %DL_PROCESSNAME%\_ned
    @CALL _sys\_log-batch INFOR "Skapad katalog %DL_PROCESSNAME%\_ned"
)

IF NOT EXIST %DL_PROCESSNAME%\_schema (
    MD %DL_PROCESSNAME%\_schema
    @CALL _sys\_log-batch INFOR "Skapad katalog %DL_PROCESSNAME%\_schema"
)
REM Skapar fil f”r f”rutsatta dataset om filen ej existerar
IF NOT EXIST %DL_PROCESSNAME%\_schema\_modul-settings-datasets.ini (
    @CALL :Create_modul-settings-datasets
    @CALL _sys\_log-batch INFOR "Skapat fil %DL_PROCESSNAME%\_schema\_modul-settings-datasets.ini"
)

IF NOT EXIST %DL_PROCESSNAME%\_temp (
    MD %DL_PROCESSNAME%\_temp
    @CALL _sys\_log-batch INFOR "Skapad katalog %DL_PROCESSNAME%\_temp"
)


:break
EXIT /B




REM ### METODER ###
:Create_modul-settings-datasets
    SET file=%DL_PROCESSNAME%\_schema\_modul-settings-datasets.ini
    IF NOT EXIST %file% (


        CHCP 1252 > nul

        ECHO ; Dataset fr†n olika datak„llor [ers„tt raden med relevant information] >>%file%
        ECHO ; INFORMATION: Nedan kommenterade rader inkl. denna kan raderas. >>%file%
        ECHO ;    Rad kommenteras med inledande ; ^(semikolon^). >>%file%
        ECHO ;    Filen m†ste ha en inledande rad som „r bortkommenterad. >>%file%
        ECHO ;    Formatet best†r av fem kolumner med ^| ^(pipe^) som kolumnavgr„nsare. >>%file%
        ECHO ;       Kolumn 1: namn p† feature/datset. Ska subkataloger med filter i exempelvis zip-fil genoms”kas l„ggs \**\*.shp till efter namnet. >>%file%
        ECHO ;       Kolumn 2: s”kv„g till dataset ^(exempelvis distanserad plats^). Relativ eller absolut s”kv„g. Relativ s”kv„g b”rjar med \ ^(backslash^) eller / ^(slash^). Relativ s”kv„g f”ruts„tts vara i processmodulskatalogen. Absolut s”kv„g m†ste inneh†lla : ^(kolon^). >>%file%
        ECHO ;       Kolumn 3: S”kv„g till dataset ^(exempelvis lokalt^). Relativ eller absolut s”kv„g. Relativ s”kv„g b”rjar med \ ^(backsh^) eller / ^(slash^). Relativ s”kv„g f”ruts„tts vara i processmodulskatalogen. Absolut s”kv„g m†ste inneh†lla : ^(kolon^). >>%file%
        ECHO ;       Kolumn 4: kommentarsf„lt, fritext. >>%file%
        ECHO ;       Kolumn 5: datasets format, FME:s kortnamn f”r formatet. Fungerar som signal f”r hur FME ska tolka datasetet. >>%file%

        CHCP 437 > nul


    ) ELSE (

        @CALL _sys\_log-batch ERROR "Filen %file% existerar"

    )

    IF %ERRORLEVEL% NEQ 0 (
        @CALL _sys\_log-batch ERROR "Filen %file% kunde inte skapas"
        @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f?r %file%" %DL_PROCESSNAME%

        EXIT /B
    )
GOTO :eof