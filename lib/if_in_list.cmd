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


if /i "%~1"=="test" goto test

rem  Function  if_in_list(  STR  STR1:"STR 2":...  [ci]  )
rem  ----------------------------------------------------------------------
rem      args  ci   case insensitive, optional
rem
rem   returns  0 (in list),
rem            1 (not in list)
rem  ----------------------------------------------------------------------
:if_in_list
setlocal
set _LIST_=%2
set "_CMP_=if" & if /i "%~3"=="ci" set "_CMP_=if /i"
for /f "usebackq delims=" %%A in (`echo %_LIST_::=^&echo %`) do (
  %_CMP_% "%~1"=="%%~A" ( endlocal & exit /b 0 )
)
endlocal & exit /b 1


rem  --- Tests ---
:test
setlocal
set "_err_=0"

echo Test 01
call :assert_true  call :if_in_list aa aa:bb:cc  || set "_err_=1"
call :assert_true  call :if_in_list bb aa:bb:cc  || set "_err_=1"
call :assert_true  call :if_in_list cc aa:bb:cc  || set "_err_=1"
call :assert_false call :if_in_list dd aa:bb:cc  || set "_err_=1"
echo/

echo Test 02
call :assert_true  call :if_in_list aa     aa:"bb b":cc  || set "_err_=1"
call :assert_false call :if_in_list bb     aa:"bb b":cc  || set "_err_=1"
call :assert_true  call :if_in_list "bb b" aa:"bb b":cc  || set "_err_=1"
call :assert_true  call :if_in_list cc     aa:"bb b":cc  || set "_err_=1"
call :assert_false call :if_in_list dd     aa:"bb b":cc  || set "_err_=1"
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
