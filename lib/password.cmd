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

rem  Function  password(  read  -con  PROMPT_STR  PASSWD_VAR  )   // from console
rem            password(  read  -file FILENAME    PASSWD_VAR  )   // from file
rem            password(  save  PASSWD_STR  FILENAME  )
rem  ----------------------------------------------------------------------
:password
if /i "%~1"=="read" goto read_password
if /i "%~1"=="save" goto save_password
exit /b 1

:read_password
setlocal
set "_var_="
if /i "%~2"=="-con"  set _from_=Read-Host "%~3" -AsSecureString& set "_var_=%4"
if /i "%~2"=="-file" set _from_=Get-Content "%~3" ^^^^^^^| ConvertTo-SecureString& set "_var_=%4"
if not defined _var_ endlocal & exit /b 1
for /f "usebackq delims=" %%A in (`PowerShell -Command $pass^=%_from_% ^; $bstr^=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR^($pass^) ^; [System.Runtime.InteropServices.Marshal]::PtrToStringAuto^($bstr^)`) do set "_val_=%%A"
set "_err_=%ERRORLEVEL%"
endlocal & ( 
  set "%_var_%=%_val_%"
  exit /b %_err_%
)

:save_password
PowerShell -Command ConvertTo-SecureString -String '%~2' -AsPlainText -Force ^| ConvertFrom-SecureString ^| Out-File %3
exit /b


rem  --- Tests ---
:test
setlocal
set "_err_=0"
set _tmp_="%TEMP%\tmp01"
set _tmp2_="%TEMP%\tmp02"

echo Test 'read -con'
set "_val_=testpassw1"
echo %_val_%>%_tmp_%
call :password read -con "Press [Enter]" PASSW1 <%_tmp_% || set "_err_=1"
call :assert_equal "%PASSW1%" "%_val_%" || set "_err_=1"
echo/

echo Test 'save / read -file'
call :password save "%PASSW1%" %_tmp2_% || set "_err_=1"
call :password read -file %_tmp2_% PASSW2 || set "_err_=1"
call :assert_equal "%PASSW2%" "%_val_%" || set "_err_=1"
echo/

del /q %_tmp_% %_tmp2_%

if not "%_err_%"=="0" echo/ & echo Failed!
endlocal & exit /b %_err_%

:assert_equal
set "_res_=ok"
if not %1==%2 set "_res_=fail"
echo -- [%1] == [%2] : %_res_%
if /i "%_res_%"=="ok" exit /b 0
exit /b 1
