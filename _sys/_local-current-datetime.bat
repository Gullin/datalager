@ECHO OFF
SETLOCAL

SET "_arg=%~1"

IF /I "%_arg%"=="iso-simple" GOTO IsoSimple
IF /I "%_arg%"=="standard" GOTO Standard
GOTO Standard

:IsoSimple
FOR /F "delims=" %%I IN ('powershell.exe -NoLogo -NoProfile -NonInteractive -Command "Get-Date -Format yyyyMMddTHHmmssfff"') DO ECHO %%I
GOTO End

:Standard
FOR /F "delims=" %%I IN ('powershell.exe -NoLogo -NoProfile -NonInteractive -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'"') DO ECHO %%I

:End
ENDLOCAL
EXIT /B
