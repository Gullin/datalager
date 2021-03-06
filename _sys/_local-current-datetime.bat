@echo off
SETLOCAL EnableDelayedExpansion

IF NOT [%1]==[] (
    SET _arg=%1
) ELSE (
    SET _arg=
)

for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
IF NOT DEFINED _arg (
    @CALL :DefaultDateTimeFormat
) ELSE (
    IF %_arg%==iso-simple (
        ECHO %ldt:~0,4%%ldt:~4,2%%ldt:~6,2%T%ldt:~8,2%%ldt:~10,2%%ldt:~12,6%
    ) ELSE IF %_arg%==standard (
        @CALL :DefaultDateTimeFormat
    ) ELSE (
        @CALL :DefaultDateTimeFormat
    )
)
ENDLOCAL
EXIT /B

:DefaultDateTimeFormat
    ECHO %ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%
GOTO :EOF