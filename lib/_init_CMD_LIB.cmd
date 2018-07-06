@echo off

rem   Copyright 2018 Dmitry Sokolov (mr.dmitry.sokolov@gmail.com).
rem
rem   Licensed under the Apache License, Version 2.0 (the "License");
rem   you may not use this file except in compliance with the License.
rem   You may obtain a copy of the License at
rem
rem       http://www.apache.org/licenses/LICENSE-2.0
rem
rem   Unless required by applicable law or agreed to in writing, software
rem   distributed under the License is distributed on an "AS IS" BASIS,
rem   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
rem   See the License for the specific language governing permissions and
rem   limitations under the License.

if not defined CMD_LIB for /f "usebackq delims=" %%A in (`where "%~dp0;%~dp0..\lib;%~dp0..\cmd-scripts\lib:argparse.cmd" 2^>nul`) do set "CMD_LIB=%%~dpA"
