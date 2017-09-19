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

IF NOT EXIST %DL_PROCESSNAME%\_temp (
    MD %DL_PROCESSNAME%\_temp
    @CALL _sys\_log-batch INFOR "Skapad katalog %DL_PROCESSNAME%\_temp"
)