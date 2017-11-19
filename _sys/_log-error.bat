@CALL _global-settings

:: Argument 1: Process-ID
:: Argument 2: Logg-meddelande
:: Argument 3: Processmodulsnamn, om processmodulen k”rs separat skickas parametern med annars NULL
SET DL_LOG_ARG1=%1
SET DL_LOG_ARG2=%2
SET DL_LOG_ARG3=%3

:: skapar tidsst„mpel
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime standard') DO SET CurrentDateTime=%%i %%j

IF NOT DEFINED DL_ISWHOLEPROCESS (
    SET DL_ISWHOLEPROCESS=0
)

CHCP 1252 > nul
IF %DL_ISWHOLEPROCESS% == 1 (
    @ECHO %CurrentDateTime% ^| %DL_LOG_ARG1% ^| null ^| ERROR ^| %DL_LOG_ARG2% ^| null >> %DL_LOGDIR%%DL_LOGERROR%
) ELSE (
    @ECHO %CurrentDateTime% ^| %DL_LOG_ARG1% ^| null ^| ERROR ^| %DL_LOG_ARG2% ^| null >> %DL_LOG_ARG3%\%DL_LOGDIR%%DL_LOGERROR%
)
CHCP 437 > nul