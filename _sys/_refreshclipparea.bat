@ECHO OFF
@CALL _global-settings

REM CP 437 (DOS)
REM Anv„nder sig av hemtagen data fr†n processmodul lm-geotorget-kommun_lan_rike
REM f”r att skapa upp klippdata .\_sys\KlippytorSweref99TM1330_skane-krans-lkr_buff5m.ffs.



REM S„tts per bat-fil
REM Namn f”r hel- eller delprocessen (modul) som batch-filen hanterar
SET DL_PROCESSNAME=_refreshclipparea
SET DL_FMEPROCESS01="_sys\_refreshclipparea.fmw"


REM skapar tidsst„mpel och unikt process-ID f”r sp†rning av k”rd batch-process
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
SET DL_PROCESSID=%DL_PROCESSNAME%_%CurrentDateTime%

@CALL _sys\_log-batch START %DL_PROCESSID%
IF %ERRORLEVEL% EQU 0 (



  REM FME-processer
  @CALL :RefreshClippArea



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
:RefreshClippArea
    @CALL _sys\_log-batch START "%DL_PROCESSID% %DL_FMEPROCESS01%"

    >nul (
        @%DL_FMEFULLPATH% %DL_FMEPROCESS01% ^
                            --RotDirectory %DL_ROTDIR% ^
                            --ProcessName %DL_PROCESSID% ^
                            --ProcessModulName "%_arg%" ^
                            --RepositoryRotDir %DL_REPOSITORYROTDIR% ^
                            --ProcessModuleClippArea %DL_PROCESSMODULE_CLIPPAREA% ^
                            --DistSourceFile %DL_DISTSOURCEFILE% ^
                            --IsWholeProcessRun %DL_ISWHOLEPROCESS% ^
                            --FME_LAUNCH_VIEWER_APP NO
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