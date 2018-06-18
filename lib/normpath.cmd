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


rem  Macro  _normpath_(  VAR  PATH  )
rem  ----------------------------------------------------------------------
rem         Normalizes path PATH and assing it to VAR. Path containing
rem         spaces ' ' should be enclosed within double quotes - "".
rem
rem         Example:  set _normpath_=for...
rem                   %_normpath_:var=PFRoot%  "C:\Program Files\.."
rem  ----------------------------------------------------------------------
set _normpath_=for /L %%S in (1,1,2) do if %%S==2 (set "var="^& for %%A in (!va_arg!) do if not defined var endlocal^& set "var=%%~fA") else setlocal EnableDelayedExpansion^& set va_arg=,


if /i "%~1"=="test" goto test


rem  --- Tests ---
:test
setlocal
set "_err_=0"

call :test_path path01 "c:\."                     "c:\"              || set "_err_=1"
call :test_path path02 "c:\file.txt"              "c:\file.txt"      || set "_err_=1"
call :test_path path02 "c:\dir\."                 "c:\dir"           || set "_err_=1"
call :test_path path04 "c:\dir\.."                "c:\"              || set "_err_=1"
call :test_path path05 "c:\dir\.\file.txt"        "c:\dir\file.txt"  || set "_err_=1"
call :test_path path05 "c:\dir\..\file.txt"       "c:\file.txt"      || set "_err_=1"
call :test_path path05 "c:\dir\subdir\..\..\123"  "c:\123"           || set "_err_=1"

if not "%_err_%"=="0" echo/ & echo Failed!
endlocal & exit /b %_err_%

:test_path
setlocal EnableDelayedExpansion
echo -- test: %*
echo -- %~1 = [!%~1!]
set np=!_normpath_:var=%~1! %2
%np%
echo -- %~1 = [!%~1!]
call :assert_equal "!%~1!" "%~3"  && (
  echo/
  endlocal
  exit /b 0
)
echo/
endlocal
exit /b 1

:assert_equal
if /i "%~1"=="%~2" echo -- ok & exit /b 0
echo -- fail & exit /b 1
