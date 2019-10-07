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

rem  Function  argparse(  [ VAR=TYPE{NAME,ALIAS,...ALIAS}[{VAL}] ]...  --  STR  )
rem  ----------------------------------------------------------------------
rem     param  VAR     output var to save option value
rem            TYPE    option type [ flag, counter, val, val_n ]
rem            NAME    option name
rem            ALIAS   option alias
rem            VAL     default value for
rem                      flag:    1 (initial value of a flag)
rem                      counter: 0 (initial value of a counter)
rem                      val:     1 (number of arguments to consume)
rem                      val_n:   1 (number of arguments to consume)
rem            --      separator
rem            STR     string to parse
rem
rem   returns  ARGS    all arguments
rem            ARG[i]  i-th argument
rem            N       arguments count
rem            PARAMS  command line remainder after "--" mark
rem            V       verbosity level
rem            VAR     all option variables
rem
rem  examples  call :argparse  -- %*
rem            call :argparse  FOO=flag{foo,f}  -- %*
rem            call :argparse  FOO=flag{foo,f}{On}  -- %*
rem            call :argparse  VERBOSE=counter{verbose,v}  -- %*
rem            call :argparse  VERBOSE=counter{verbose,v}{1}  -- %*
rem            call :argparse  CONFIG=val{config,conf,cfg}  POINT=val_n{point,pt,p}{2}  -- %*
rem  ----------------------------------------------------------------------
:argparse
if defined TRACE echo -- call :argparse `%*`
if defined TRACE if not defined _timediff_ set "_clean_timediff_=1"
if defined TRACE if not defined _timediff_ call :argparse_init_timediff
set _tmp_=[ %* ]
set _tmp_=%_tmp_:[  ]=%
if not defined _tmp_ (
  if defined TRACE echo --   nothing to parse
  call :argparse_cleanup
  exit /b 1
)
set _defs_=%_tmp_: -- =&rem %
set _args_=%_tmp_:* -- =%
call :argparse_init  %%_defs_:~1%%
call :argparse_parse %%_args_:~0,-1%%
call :argparse_info %%_args_:~0,-1%%
call :argparse_cleanup
exit /b 0

:argparse_init_timediff
set _timestamp_=set "var="^& for /f "skip=1" %%A in ('wmic os get LocalDateTime') do if not defined var set "var=%%A"
set _timediff_=call "%~dp0..\scripts\timediff"
exit /b 0

:argparse_cleanup
set "_tmp_="
set "_defs_="
set "_args_="
if defined _clean_timediff_ set "_timediff_=" & set "_timestamp_=" & set "_clean_timediff_="
exit /b 0

:argparse_init
if defined TRACE echo -- call :argparse_init `%*`
if defined TRACE  %_timestamp_:var=starttime1%
set "ARGS="
set "PARAMS="
set "N=0"
set "V=0"
set "_opt_prefix_=-"
set "_opt_len_=0"
set "_opt_name_cache_="
if defined TRACE echo --   added default options:
call :argparse_init_option  V counter "verbose:v" 0
set _tmp_=%*
if not defined _tmp_ goto argparse_init_end
set _tmp_=%_tmp_:,=:%
if defined TRACE echo --   added options:
for /f "usebackq delims=" %%S in (`echo %_tmp_: =^&echo/%`) do (
  for /f "tokens=1-4 delims={} " %%A in ("%%S") do (
    call :argparse_init_option  %%A %%B "%%C" "%%D"
  )
)
set "_opt_name_cache_=%_opt_name_cache_%:"
:argparse_init_end
if defined TRACE %_timestamp_:var=endtime1%
if defined TRACE  %_timediff_% "%endtime1%" "%starttime1%" "--   time: "
rem --- clean up ---
set "starttime1="
set "endtime1="
set "_opt_prefix_="
set "_i_="
set "_name_="
exit /b 0

:argparse_init_option
set "_i_=1" & if defined _opt_len_ set /a "_i_=_opt_len_ + 1"
set "_opt_var_[%_i_%]=%~1"
set "_opt_type_[%_i_%]=%~2"
set "_name_="
set "_tmp_=%~3"
for %%A in (%_tmp_::= %) do call set "_name_=%%_name_%%:%_opt_prefix_%%%A"
set "_opt_name_[%_i_%]=%_name_:~1%"
set "_opt_name_cache_=%_opt_name_cache_%:{%_i_%}:%_name_:~1%"
set "_tmp_=%~4"
if defined _tmp_ (set "_opt_val_[%_i_%]=%_tmp_%") else (call :argparse_init_option_%~2  _opt_val_[%_i_%])
set "_opt_len_=%_i_%"
if defined TRACE call echo --     %%_opt_var_[%_i_%]%% = %%_opt_type_[%_i_%]%%{%%_opt_name_[%_i_%]%%}
exit /b 0

:argparse_init_option_flag
:argparse_init_option_val
:argparse_init_option_val_n
  set "%~1=1" & exit /b 0
:argparse_init_option_counter
  set "%~1=0" & exit /b 0

:argparse_parse
if defined TRACE echo -- call :argparse_parse `%*`
if defined TRACE %_timestamp_:var=starttime2%
set _tmp_=%*
if not defined _tmp_ (
  if defined TRACE echo --   nothing to parse
  goto argparse_parse_end
)
:argparse_parse_option
rem --- parse PARAMS ---
if "%~1"=="--" (
  set PARAMS=%* ]
  call set PARAMS=%%PARAMS:*-- =%%
  call set PARAMS=%%PARAMS:~0,-1%%
  goto argparse_parse_end
)
rem --- parse option ---
set "_i_="
call set "_tmp_=%%_opt_name_cache_::%~1:=&rem %%"
set _head_=%_tmp_%
if not "%_head_%"=="%_opt_name_cache_%" for /f "usebackq delims={}:" %%A in (`echo %_head_:{=^&echo %`) do set "_i_=%%A"
if defined _i_ call goto argparse_parse_%%_opt_type_[%_i_%]%%
rem --- parse arg ---
if not "%~1"=="" (
  if not defined ARGS (set ARGS=%1) else (set ARGS=%ARGS% %1)
  set /a "N+=1"  &  call set "ARG[%%N%%]=%~1"  &  shift /1
  goto argparse_parse_option
)
:argparse_parse_end
if defined TRACE %_timestamp_:var=endtime2%
if defined TRACE %_timediff_% "%endtime2%" "%starttime2%" "--   time: "
rem --- clean up ---
set "starttime2="
set "endtime2="
set "_i_="
set "_head_="
set "_var_="
set "_val_="
set "_a_="
set "_narg_="
set "_res_="
exit /b 0

:argparse_parse_flag
call set "_var_=%%_opt_var_[%_i_%]%%"
call set "_val_=%%_opt_val_[%_i_%]%%"
set "%_var_%=%_val_%"  &  shift /1  &  goto argparse_parse_option

:argparse_parse_counter
call set "_var_=%%_opt_var_[%_i_%]%%"
call set "_val_=%%_opt_val_[%_i_%]%%"
call set "_tmp_=%%_var_%%"
if not defined _tmp_ set "%_var_%=%_val_%"
if not "%~2"=="" (
  set /a "_val_=%~2" 2>nul & call set "_val_=%%_val_:0=%%"
  if defined _val_  set "%_var_%=%~2"  &  shift /1  &  shift /1  &  goto argparse_parse_option
  if "%~2"=="0"     set "%_var_%=%~2"  &  shift /1  &  shift /1  &  goto argparse_parse_option
)
set /a "%_var_%+=1"  &  shift /1  &  goto argparse_parse_option

:argparse_parse_val
:argparse_parse_val_n
call set "_var_=%%_opt_var_[%_i_%]%%"
call set "_narg_=%%_opt_val_[%_i_%]%%"
set "_a_=1"
set "_res_="
:argparse_parse_val_next
if %_a_% LEQ %_narg_% (
  set _res_=%_res_% %2& shift /2 & set /a "_a_+=1"
  goto argparse_parse_val_next
)
set %_var_%=%_res_:~1%
shift /1  &  goto argparse_parse_option

:argparse_info
set "_tmp_="
if %V% GTR 0 set "_tmp_=1"
if defined TRACE set "_tmp_=1"
if defined _tmp_ (
  echo/
  echo -- Command line: %*
  echo --   ARGS   = %ARGS%
  for /L %%I in (1,1,%N%) do call ^
  echo --   ARG[%%I] = %%ARG[%%I]%%
  echo --   PARAMS = %PARAMS%
  for /L %%I in (1,1,%_opt_len_%) do call set "_tmp_=%%_opt_var_[%%I]%%"& if defined _tmp_ call call ^
  echo --   %%_tmp_%% = %%%%%%_tmp_%%%%%%
)
rem --- clean up ---
for /L %%I in (1,1,%_opt_len_%) do set "_opt_var_[%%I]=" & set "_opt_type_[%%I]="^
                                 & set "_opt_val_[%%I]="& set "_opt_name_[%%I]="
set "_opt_len_="
set "_opt_name_cache_="
exit /b 0


rem  --- Tests ---
:test
setlocal
set "TRACE=1"
echo/ & call :argparse
echo/ & call :argparse --
echo/ & call :argparse --  --
echo/ & call :argparse --  -- sub_arg1 "sub arg2" --sub_longopt1=1  -sub_opt1
echo/ & call :argparse -- arg1 "arg 2"  -opt1  --longopt1 -v
echo/ & call :argparse -- arg1 "arg 2"  -opt1  --longopt1  --
echo/ & call :argparse -- arg1 "arg 2"  -opt1  --longopt1  -- sub_arg1 "sub arg2" --sub_longopt1=1  -sub_opt1
echo/ & call :argparse FOO=flag{foo,f}  VERBOSE=counter{verbose,v}  XVAL=val{x}  POINT=val_n{point,pt,p}{2}  --
echo/ & call :argparse FOO=flag{foo,f}  VERBOSE=counter{verbose,v}  XVAL=val{x}  POINT=val_n{point,pt,p}{2}  --  --
echo/ & call :argparse FOO=flag{foo,f}  VERBOSE=counter{verbose,v}  XVAL=val{x}  POINT=val_n{point,pt,p}{2}  --  -- sub_arg1 "sub arg2" --sub_longopt1=1  -sub_opt1
echo/ & call :argparse FOO=flag{foo,f}  VERBOSE=counter{verbose,v}  XVAL=val{x}  POINT=val_n{point,pt,p}{2}  -- arg1 "arg 2"  -opt1  --longopt1
echo/ & call :argparse FOO=flag{foo,f}  VERBOSE=counter{verbose,v}  XVAL=val{x}  POINT=val_n{point,pt,p}{2}  -- arg1 "arg 2"  -opt1  --longopt1  --
echo/ & call :argparse FOO=flag{foo,f}  VERBOSE=counter{verbose,v}  XVAL=val{x} YVAL=val{y}{2}  POINT=val_n{point,pt,p}{2}  -- arg1 "arg 2"  -foo  -verbose 3 -x qwer -y abc 1 -point 1.1 2.2 -v -- sub_arg1 "sub arg2" --sub_longopt1=1  -sub_opt1
endlocal
exit /b
