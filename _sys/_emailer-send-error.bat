@ECHO OFF
@CALL _global-settings
@CALL __secrets\_secrets

REM CP 437 (DOS)
REM Argument 1: Om processmodulen k”rs enskilt processmodulens namn med in som argument


IF NOT [%1]==[] (
    SET _arg=%1
)

> nul @%DL_FMEFULLPATH% _sys\_emailer-send-error.fmw ^
                    --ProcessName %DL_PROCESSNAME% ^
                    --RotDirectory %DL_ROTDIR% ^
                    --ProcessModulName %_arg% ^
                    --IsWholeProcessRun %DL_ISWHOLEPROCESS% ^
                    --EmailHost %DL-MAIL-HOST% ^
                    --EmailPort %DL-MAIL-PORT% ^
                    --EmailFrom %DL-MAIL-FROM% ^
                    --EmailTo %DL-MAIL-TO% ^
                    --EmailCC %DL-MAIL-CC%