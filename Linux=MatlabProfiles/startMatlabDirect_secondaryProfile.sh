#!/bin/bash

export MATLAB_PREFDIR="/path/to/extracted/ZIP/secondary"; #contains matlab.settings
export STARTUP_PATH="/path/to/extracted/ZIP"; #contains startup.m
export INITIAL_COMMAND="profileStartup('secondary profile','grayed green->yellow');";
/usr/local/bin/matlab -desktop -sd "$STARTUP_PATH" -r "$INITIAL_COMMAND";

#[.85 .91 .97] %vivid blue->cyan
#[.91 .85 .97] %vivid blue->magenta
#[.91 .97 .85] %vivid green->yellow
#[.85 .97 .91] %vivid green->cyan
#[.97 .91 .85] %vivid red->yellow
#[.97 .85 .91] %vivid red->magenta

#[.85 .871 .91] %grayed blue->cyan
#[.871 .85 .91] %grayed blue->magenta
#[.871 .91 .85] %grayed green->yellow
#[.85 .91 .871] %grayed green->cyan
#[.91 .871 .85] %grayed red->yellow
#[.91 .85 .871] %grayed red->magenta
