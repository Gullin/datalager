@CALL _global-settings

REM Sker alltid en kontroll f”r den globala FATAL_ERROR.log filen. Kr„vs att
REM processmodulsnamnet skickas med som argument om lokala FATAL_ERROR.log ska
REM kontrolleras.
REM Argument 1: Processmodulsnamn
REM Returns:    99999 i variabeln ERRORLEVEL om fil existerar, kontroll av 
REM             variabeln kr„vs


SET DL_LOG_ARG1=%1

IF NOT "%DL_LOG_ARG1%"=="" (
    IF EXIST %DL_LOG_ARG1%\_log\FATAL_ERROR.log EXIT /b 99999
)
IF EXIST _log\FATAL_ERROR.log EXIT /b 99999