@ECHO OFF
set MATLAB_PREFDIR=C:\Users\MG\AppData\Roaming\MathWorks\MATLAB\tertiary
start "MATLAB, tertiary profile" "C:\Program Files\MATLAB\R2018b\bin\matlab.exe" -r "profileStartup('tertiary profile','grayed red->magenta');"

REM [.85 .91 .97] %vivid blue->cyan
REM [.91 .85 .97] %vivid blue->magenta
REM [.91 .97 .85] %vivid green->yellow
REM [.85 .97 .91] %vivid green->cyan
REM [.97 .91 .85] %vivid red->yellow
REM [.97 .85 .91] %vivid red->magenta

REM [.85 .871 .91] %grayed blue->cyan
REM [.871 .85 .91] %grayed blue->magenta
REM [.871 .91 .85] %grayed green->yellow
REM [.85 .91 .871] %grayed green->cyan
REM [.91 .871 .85] %grayed red.>yellow
REM [.91 .85 .871] %grayed red->magenta
