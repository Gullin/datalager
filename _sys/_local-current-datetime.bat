@echo off

IF NOT [%1]==[] (
    SET _arg=%1
)

for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
IF %_arg%==iso-simple (
    ECHO %ldt:~0,4%%ldt:~4,2%%ldt:~6,2%T%ldt:~8,2%%ldt:~10,2%%ldt:~12,6%
) ELSE (
    ECHO %ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%
)