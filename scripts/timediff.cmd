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

rem +---------------------------------------------------------------------------
rem + Usage:
rem +     timediff  end_ts  start_ts  [msg]
rem +
rem + Arguments:
rem +     end_ts      End timestamp in format YYYYMMDDhhmmss.xxxxxx+zzz
rem +     start_ts    Start timestamp
rem +     msg         Optional message (prefix)
rem +
rem + Timestamps macros and example of usage:
rem +     set _timestamp_=set "var="^& for /f "skip=1" %%A in ('wmic os get LocalDateTime') do if not defined var set "var=%%A"
rem +     set _timediff_=echo/^& call "%CMD_LIB%\..\scripts\timediff.cmd"
rem +
rem +     %_timestamp_:var=starttime%
rem +     %_timestamp_:var=endtime%
rem +     %_timediff_% "%endtime%" "%starttime%" "Total time: "
rem +---------------------------------------------------------------------------

setlocal

call "%CMD_LIB%\process_help_options.cmd" "%~f0" %*  && (endlocal & exit /b 1)

if "%~1"=="" endlocal & exit /b 1
if "%~2"=="" endlocal & exit /b 1

call :get_JDN %~1 end_JDN
call :get_JDN %~2 start_JDN

call :get_time_msec %~1 end_msec
call :get_time_msec %~2 start_msec

set /a "tdiff_msec=end_msec - start_msec + (end_JDN - start_JDN) * 24 * 3600000"

call :format_time %tdiff_msec% output
echo %~3%output%

endlocal & exit /b 0


rem  Function  get_JDN(  timestamp  out_var  )
rem  ------------------------------------------------------------
rem     param  timestamp, format YYYYMMDDhhmmss.xxxxxx+zzz
rem  ------------------------------------------------------------
:get_JDN
setlocal
set "ts_=%~1"
set "year_=%ts_:~0,4%"
call :trim_zero %ts_:~4,2%  month_
call :trim_zero %ts_:~6,2%  day_
set /a "a_=( 14 - month_ ) / 12"
set /a "y_=year_ + 4800 - a_"
set /a "m_=month_ + 12 * a_ - 3"
set /a "jdn_=day_ + ( 153 * m_ + 2 ) / 5 + 365 * y_ + y_ / 4 - y_ / 100 + y_ / 400 - 32045"
endlocal & set "%~2=%jdn_%"
exit /b 0


rem  Function  get_time_msec(  timestamp  out_var  )
rem  ------------------------------------------------------------
rem     param  timestamp, format YYYYMMDDhhmmss.xxxxxx+zzz
rem  ------------------------------------------------------------
:get_time_msec
setlocal
set "ts_=%~1"
call :trim_zero %ts_:~8,2%   hh_
call :trim_zero %ts_:~10,2%  mm_
call :trim_zero %ts_:~12,2%  ss_
call :trim_zero %ts_:~15,3%  xx_
rem calc time in msec
set /a "t_=hh_ * 3600000 + mm_ * 60000 + ss_ * 1000 + xx_"
endlocal & set "%~2=%t_%"
exit /b 0


rem  Function  format_time(  time_msec  out_var  )
rem  ------------------------------------------------------------
:format_time
setlocal
set /a "t_=%~1"
set /a "h_=t_  / 3600000"
set /a "t_=t_ %% 3600000"
set /a "m_=t_  / 60000"
set /a "t_=t_ %% 60000"
set /a "s_=t_  / 1000"
set /a "t_=t_ %% 1000"
call :pad_with_zero %h_% 2 h_
call :pad_with_zero %m_% 2 m_
call :pad_with_zero %s_% 2 s_
call :pad_with_zero %t_% 3 t_
endlocal & set "%~2=%h_%:%m_%:%s_%.%t_%"
exit /b 0


rem  Function  pad_with_zero(  value  width  out_var  )
rem  ------------------------------------------------------------
:pad_with_zero
setlocal
set "value_=%~1"
set "width_=%~2"
set "varname_=%~3"
set "value_=000000000000000000000000000000%value_%"
call set "value_=%%value_:~-%width_%%%"
endlocal & set "%varname_%=%value_%"
exit /b 0


rem  Function  trim_zero(  value  out_var  )
rem  ------------------------------------------------------------
:trim_zero
setlocal
set "value_=%~1"
set "nz_=%value_:0=%"
if defined nz_ (
  call set "tail_=%%value_:*%nz_:~0,1%=%%"
  call set "value_=%nz_:~0,1%%%tail_%%"
) else (
  set "value_=0"
)
endlocal & set "%~2=%value_%"
exit /b 0
