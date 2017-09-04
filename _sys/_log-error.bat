@CALL _global-settings

:: Argument 1: Processnamn
:: Argument 2: Logg-meddelande
SET DL_LOG_ARG1=%1
SET DL_LOG_ARG2=%2

:: skapar tidsst„mpel
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime') DO SET CurrentDateTime=%%i %%j

@ECHO %CurrentDateTime% ^| %DL_LOG_ARG1% ^| null ^| ERROR ^| %DL_LOG_ARG2% ^| null >> %DL_LOGDIR%%DL_LOGERROR%