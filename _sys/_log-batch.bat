@CALL _global-settings

:: Argument 1: Logg-typ
:: Argument 2: Logg-meddelande
SET DL_LOG_ARG1=%1
SET DL_LOG_ARG2=%2

:: skapar tidsst„mpel
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime standard') DO SET CurrentDateTime=%%i %%j

CHCP 1252 > nul
@ECHO %CurrentDateTime% ^| %DL_LOG_ARG1% ^| %DL_LOG_ARG2% >> %DL_LOGDIR%%DL_LOGFILE%
CHCP 437 > nul