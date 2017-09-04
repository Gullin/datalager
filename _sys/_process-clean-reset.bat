@CALL _global-settings

REM CP 437 (DOS)
REM K”r en clean samt, rensar
REM  * alla loggar,
REM  * data f”r distribution (repository)
REM  * kataloger som ej ses som systemkataloger (ej prefix "_")
REM  * underkataloger som ej inneh†ller processlogik


@CALL _sys\_process-clean-clear

FOR /D %%p IN ("*.*") DO (
    REM Raderar log-katalog och alla loggar
    IF %%p==_log RMDIR %%p /S /Q

    REM Radera katalog f”r repository
    IF %%p==%DL_REPOSITORYROTDIR% RMDIR %%p /S /Q

    @CALL :DeleteSubObject %%p
)

REM Skapar signal-fil om att instruktionen „r k”rd
REM skapar tidsst„mpel
FOR /f "tokens=1,2" %%i IN ('_sys\_local-current-datetime iso-simple') DO SET CurrentDateTime=%%i %%j
ECHO. > _reseted_%CurrentDateTime%
GOTO :eof



REM Raderar filer och kataloger i underliggande processkataloger som ej „r systemkataloger (startar med "_")
:DeleteSubObject
SET _obj=%1
SET _obj-not-to-delete=%_obj:~0,1%
IF NOT "%_obj-not-to-delete%"=="_" (
    FOR /D %%i IN (%_obj%\*) DO IF NOT "%%i"=="%_OBJ%\_fme" RMDIR /S /Q "%%i"
)
GOTO :eof

:Exit