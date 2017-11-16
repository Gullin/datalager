@CALL _global-settings

:: Argument 1: Processnamn
:: Argument 2: Logg-meddelande
SET DL_LOG_ARG1=%1
SET DL_LOG_ARG2=%2

:: skapar tidsst„mpel
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime standard') DO SET CurrentDateTime=%%i %%j

IF NOT DEFINED DL_ISWHOLEPROCESS (
    SET DL_ISWHOLEPROCESS=1
)

IF %DL_ISWHOLEPROCESS% == 1 (
    @ECHO %CurrentDateTime% ^| %DL_LOG_ARG1% ^| null ^| ERROR ^| %DL_LOG_ARG2% ^| null >> %DL_LOGDIR%%DL_LOGERROR%
) ELSE (
    @ECHO %CurrentDateTime% ^| %DL_LOG_ARG1% ^| null ^| ERROR ^| %DL_LOG_ARG2% ^| null >> %DL_LOG_ARG1%\%DL_LOGDIR%%DL_LOGERROR%
)