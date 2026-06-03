@ECHO OFF
@CALL _global-settings

REM CP 437 (DOS)
REM Tar 3 argument
REM   argument 1: Processmodulsnamn, l„mnas tom om alla "schema-manifest.xlsx" ska „ndras
REM   argument 2: Textstr„ng att byta ut
REM   argument 3: Ny textstr„ng
REM Žndrar s”kv„g i en eller alla processmodulers "schema-manifest.xlsx" och
REM "_dirpath" f”r filbaserade dataset. S”kv„garna „r absoluta.
REM Žr prim„rt t„nkt att anv„ndas f”r att anpassa schemadokumentationen mot
REM aktuell exekveringsplats.


IF "%~3"=="" (
    REM Endast tv† argument
    SET "ARG1=%DL_ROTDIR%"
    SET "ARG2=%~1"
    SET "ARG3=%~2"

    SET DL_ISWHOLEPROCESS=1
    SET _arg=datalager
) ELSE (
    REM Tre argument
    IF "%~1" NEQ "%DL_ROTDIR%" (
      SET "_arg=%~1"
      SET DL_ISWHOLEPROCESS=0
    ) ELSE (
      SET _arg=datalager
      SET DL_ISWHOLEPROCESS=1
    )
    SET "ARG1=%~1"
    SET "ARG2=%~2"
    SET "ARG3=%~3"

)



REM S„tts per bat-fil
REM Namn f”r hel- eller delprocessen (modul) som batch-filen hanterar
SET DL_PROCESSNAME=_change-schema-path
SET DL_FMEPROCESS01="_sys\_change-schema-path.fmw"


REM skapar tidsst„mpel och unikt process-ID f”r sp†rning av k”rd batch-process
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
SET DL_PROCESSID=%DL_PROCESSNAME%_%CurrentDateTime%

@CALL _sys\_log-batch START %DL_PROCESSID%
IF %ERRORLEVEL% EQU 0 (



  REM FME-processer
  @CALL :ChangeSchemaPath



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
:ChangeSchemaPath
    @CALL _sys\_log-batch START "%DL_PROCESSID% %DL_FMEPROCESS01%"

    >nul (
        @%DL_FMEFULLPATH% %DL_FMEPROCESS01% ^
                            --RotDirectory %DL_ROTDIR% ^
                            --ProcessName %DL_PROCESSID% ^
                            --ProcessModulName "%_arg%" ^
                            --InData "%ARG1%" ^
                            --StrSearch "%ARG2%" ^
                            --StrReplace "%ARG3%" ^
                            --IsWholeProcessRun %DL_ISWHOLEPROCESS% ^
                            --FME_LAUNCH_VIEWER_APP YES
    )

    IF %ERRORLEVEL% NEQ 0 (

        @CALL _sys\_log-batch ERROR "FME-processen slutf”rdes inte korrekt"
        @CALL _sys\_log-error %DL_PROCESSID% "Errorlevel %ERRORLEVEL% f”r %DL_FMEPROCESS01%"

        EXIT /B
    ) ELSE (
        @CALL _sys\_log-batch KLART "%DL_PROCESSID% %DL_FMEPROCESS01%"
    )
GOTO :eof
ENDLOCAL