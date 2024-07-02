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

        ECHO ; Dataset från olika datakällor [ersätt raden med relevant information] >>%file%
        ECHO ; INFORMATION: Nedan kommenterade rader inkl. denna kan raderas. >>%file%
        ECHO ;    Rad kommenteras med inledande ; ^(semikolon^). >>%file%
        ECHO ;    Filen måste ha en inledande rad som är bortkommenterad. >>%file%
        ECHO ;    Formatet består av fem kolumner med ^| ^(pipe^) som kolumnavgränsare. >>%file%
        ECHO ;       Kolumn 1: namn på feature/datset. Ska subkataloger med filter i exempelvis zip-fil genomsökas läggs \**\*.shp till efter namnet. >>%file%
        ECHO ;       Kolumn 2: söväg till dataset ^(exempelvis distanserad plats^). Relativ eller absolut sökväg. Relativ sökväg börjar med \ ^(backslash^) eller / ^(slash^). Relativ sökväg förutsätts vara i processmodulskatalogen. Absolut sökväg måste innehålla : ^(kolon^). >>%file%
        ECHO ;       Kolumn 3: Sökväg till dataset ^(exempelvis lokalt^). Relativ eller absolut sökväg. Relativ sökväg börjar med \ ^(backsh^) eller / ^(slash^). Relativ sökväg förutsätts vara i processmodulskatalogen. Absolut sökväg måste innehålla : ^(kolon^). >>%file%
        ECHO ;       Kolumn 4: kommentarsfält, fritext. >>%file%
        ECHO ;       Kolumn 5: datasets format, FME:s kortnamn för formatet. Fungerar som signal för hur FME ska tolka datasetet. >>%file%

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