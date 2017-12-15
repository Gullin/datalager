@ECHO OFF
REM Kallas p� fr�n alla bat-filer.
REM Placeras f�rst i andra bat-filer.
REM Ska ligga i processens rotkatalog

REM SetLocal EnableDelayedExpansion



REM GLOBALA VARIABLER
REM Rotkatalogen d�r datalagerprocessen k�rs ifr�n (huvudbatch-filen datalager.bat)
SET DL_ROTDIR=%~dp0

REM �vergripande katalog f�r loggning
SET DL_LOGDIR=_log\

REM �vergripande katalog f�r backup
SET DL_BKPDIR=_bkp\

REM Loggfil f�r batch-h�ndelserna, redog�r f�r processtege
SET DL_LOGFILE=BatchEventLog.log

REM Skapas om fel uppst�r i processen och inneh�ller ett mer utf�rligare felmeddelande �n det som loggas i DL_LOGFILE
SET DL_LOGERROR=FATAL_ERROR.log

REM Fil inneh�llande s�kv�gar till repositoryts underkataloger genererade av resp. processmodul (repositorydelar)
SET DL_DISTSOURCEFILE=DatalagerDistributionSource.log

REM S�kv�g till de olika repositorydelarna n�r processen k�rs i sin helhet (gobalt)
SET DL_DISTSOURCE=%DL_LOGDIR%%DL_DISTSOURCEFILE%

REM Repositorydelarnas rotkatalog
SET DL_REPOSITORYROTDIR=_geodatarepo\



REM FME-VARIABLER
REM S�kv�g till fme som k�r fmw-filerna (FME-skripten). Fullst�ndig s�kv�g kr�vs n�r flera installationer finns p� k�rande maskin
REM Om l�sning av Oracle-data ska g�ras f�r FME:s s�kv�g ej inneh�lla tecken som strider mot Oracle (ex. paranteser, accepteras i katalognamngivning men ej av Oracles' anslutningsstr�ng)
SET DL_FMEFULLPATH="C:\Program Files\FME\2017_1_17539\fme.exe"
REM SET DL_FMEFULLPATH="C:\Program Files\FME 2017.0.1.1.17291\fme.exe"

REM S�kv�g till FME:s arbetskatalog. Ska ligga skilt fr�n enhet d�r OS finns installerat, g�rna p� snabb diskyta med SSD-diskar och med bra tilltaget lagringsutrymme
SET FME_TEMP=d:\fme_temp_workdir\



REM MISC
REM Skapandet av loggningskatalog existerar h�r eftersom detta ska g�ras bland det f�rsta
IF NOT EXIST %DL_LOGDIR% MD %DL_LOGDIR%