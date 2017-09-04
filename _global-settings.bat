REM Kallas p† fr†n alla bat-filer.
REM Placeras f”rst i andra bat-filer.
REM Ska ligga i processens rotkatalog

@ECHO OFF
REM SetLocal EnableDelayedExpansion

REM Globala variabler
SET DL_ROTDIR=%~dp0
SET DL_LOGDIR=_log\
SET DL_LOGFILE=BatchEventLog.log
SET DL_LOGERROR=Exception.log
SET DL_DISTSOURCEFILE=DatalagerDistributionSource.log
SET DL_DISTSOURCE=%DL_LOGDIR%%DL_DISTSOURCEFILE%
SET DL_REPOSITORYROTDIR=_geodatarepo\
SET DL_FMEFULLPATH="C:\Program Files\FME 2017.0.1.1.17291\fme.exe"
REM SET DL_FMEFULLPATH="C:\Program Files (x86)\FME 2017.0 (17259)\fme.exe"
REM SET DL_FMEFULLPATH="C:\Program Files\FME 2017.1 (17465)\fme.exe"

REM FME-variabler
SET FME_TEMP=d:\fme_temp_workdir\


REM Misc
IF NOT EXIST %DL_LOGDIR% MD %DL_LOGDIR%