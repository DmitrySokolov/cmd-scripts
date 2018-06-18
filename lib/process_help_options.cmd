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

rem  Function  process_help_options(  [SCRIPT]  ARGS  )
rem  ----------------------------------------------------------------------
rem            Searches command line for help argument (-h, -help, -?)
rem            and print usage message (which is special script comments).
rem
rem     param  SCRIPT  optional script file name, default %0
rem            ARGS    command line arguments, usually %*
rem  ----------------------------------------------------------------------
:process_help_options
setlocal
set "_file_=%~f1"
if not defined _file_   set "_file_=%~f0" & set "_skip_first_=1"
if not exist "%_file_%" set "_file_=%~f0" & set "_skip_first_=1"
set _args_=[ %* ]
set _args_=%_args_: -- =&rem %
if defined _skip_first call set _args_=%%_args_:%1=%%
echo %_args_% | findstr /r /c:" -h\>" /c:" -help\>" /c:" -?\>" >nul && (
  for /f "usebackq delims=" %%A in (`findstr /rbc:"rem +" "%_file_%"`) do (
    set _line_=%%A
    call echo/ %%_line_:rem +=%%
  )
  endlocal & exit /b 0
)
endlocal & exit /b 1


rem  --- Tests ---
:test
setlocal
set "_err_=0"

set _resfile_="%TEMP%\test1.txt"
rem +----------
rem +Test1
rem +----------

call :process_help_options >%_resfile_%
call :assert_empty %_resfile_% "Test1 with no options" || set "_err_=1"

call :process_help_options -h >%_resfile_%
call :assert_equal %_resfile_% " ---------- Test1 ----------" "Test1 with -h option" || set "_err_=1"

del /q /f %_resfile_%

set _testfile_="%TEMP%\test2.cmd"
set _resfile_="%TEMP%\test2.txt"
echo rem +---------->%_testfile_%
echo rem +Test2>>%_testfile_%
echo rem +---------->>%_testfile_%

call :process_help_options %_testfile_% >%_resfile_%
call :assert_empty %_resfile_% "Test2 with no options" || set "_err_=1"

call :process_help_options %_testfile_% -h >%_resfile_%
call :assert_equal %_resfile_% " ---------- Test2 ----------" "Test2 with -h option" || set "_err_=1"

del /q /f %_testfile_%
del /q /f %_resfile_%

if not "%_err_%"=="0" echo/ & echo Failed!

endlocal & exit /b %_err_%

:assert_empty
echo/
if %~z1 GTR 0 echo %~2: fail & exit /b 1
echo %~2: ok & exit /b 0

:assert_equal
echo/
type %1
set "_str_="
for /f "usebackq delims=" %%A in (%1) do call set _str_=%%_str_%%%%A
if not "%_str_%"=="%~2" echo %~3: fail & exit /b 1
echo %~3: ok & exit /b 0
