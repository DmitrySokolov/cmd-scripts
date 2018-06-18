@echo off
chcp 850 >nul

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

setlocal

set _timestamp_=set "var="^& for /f "skip=1" %%A in ('wmic os get LocalDateTime') do if not defined var set "var=%%A"
set _timediff_=echo/^& call "%~dp0timediff.cmd"

%_timestamp_:var=starttime%

start "subprocess" /b /wait  cmd /c  %*
set _err_=%ERRORLEVEL%

%_timestamp_:var=endtime%
%_timediff_% "%endtime%" "%starttime%" "Spent time: "

endlocal & exit /b %_err_%
