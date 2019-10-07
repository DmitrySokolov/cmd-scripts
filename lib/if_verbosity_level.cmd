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


if /i "%~1"=="test" goto test

rem  Function  if_verbosity_level(  N  )
rem  ----------------------------------------------------------------------
rem   expects  V   env var, actual verbosity level
rem
rem   returns  0 (if level N greater or equal V),
rem            1 (otherwise)
rem  ----------------------------------------------------------------------
:if_verbosity_level
if not defined V exit /b 1
if %V% GEQ %~1 exit /b 0
exit /b 1


rem  --- Tests ---
:test
setlocal
set "_err_=0"

echo Test 01
set V=
echo -- V =
call :assert_false call :if_verbosity_level 0  || set "_err_=1"
echo/

echo Test 02
set V=1
echo -- V = %V%
call :assert_true  call :if_verbosity_level 0  || set "_err_=1"
call :assert_true  call :if_verbosity_level 1  || set "_err_=1"
call :assert_false call :if_verbosity_level 2  || set "_err_=1"
echo/

if not "%_err_%"=="0" echo/ & echo Failed!
endlocal & exit /b %_err_%

:assert_true
set "_res_=ok"
%*  || set "_res_=fail"
echo -- %*  =^> [true]  : %_res_%
if /i "%_res_%"=="ok" exit /b 0
exit /b 1

:assert_false
set "_res_=fail"
%*  || set "_res_=ok"
echo -- %*  =^> [false] : %_res_%
if /i "%_res_%"=="ok" exit /b 0
exit /b 1
