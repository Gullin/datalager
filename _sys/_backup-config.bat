@ECHO OFF
@CALL _global-settings

REM CP 437 (DOS)
REM Argument 1: Processmodulsnamn (valfri). Uppges n„r inte hela datalager-
REM             processens filer f”r konfiguration och schema ska kopieras.
REM Delar som kopieras
REM  * _global-settings-targetpaths.ini
REM  * [processmodul]\_schema\_modul-settings-datasets.ini
REM  * [processmodul]\_schema\schema-manifest.xlsx
REM Kopieras till .\_bkp med underkatalog _config-[DATUMTID]


IF NOT [%1]==[] (
    SET _arg1=%1
)

REM S„tts per bat-fil
REM Namn f”r hel- eller delprocessen (modul) som batch-filen hanterar
SET DL_PROCESSNAME=_backup-config


REM skapar tidsst„mpel och unikt process-ID f”r sp†rning av k”rd batch-process
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
SET DL_PROCESSID=%DL_PROCESSNAME%_%CurrentDateTime%

@CALL _sys\_log-batch START %DL_PROCESSID%
IF %ERRORLEVEL% EQU 0 (

    ECHO TEST
    ECHO Argument: %_arg1%
    IF NOT EXIST _bkp (
        MD _bkp
        @CALL _sys\_log-batch INFOR "Skapad katalog _bkp"
    )


) ELSE (
    @CALL _sys\_log-batch ERROR "Processen %DL_PROCESSID% kunde inte k”ras"
    @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_PROCESSID%" %_arg%

    GOTO break
)


:exit
@CALL _sys\_log-batch KLART %DL_PROCESSID%
:break
EXIT /B



Metoder
:CopyStructuresFiles

GOTO :eof