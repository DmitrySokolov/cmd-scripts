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
rem +     findvc  [-arch ARCH_TYPE]  [-toolset TS_VER]  [-host HOST_TYPE]
rem +             [-n]  [-v [N]]...
rem +
rem + Options:
rem +     -arch       Target OS architecture [ x86, x86_64, arm, arm64 ].
rem +     -toolset    MSVC toolset version [ 14.0, 14.1 or {14.10, 14.11, 14.12, 14.13, 14.14} ].
rem +     -host       Host OS architecture [ x86, x86_64 ].
rem +     -v          Verbosity level [ 0=quiet, 1=minimal, 2=normal, 3=detailed, 4=diagnostic ],
rem +                 but without N argument it just increases level.
rem +     -n          Test run - show commands without performing them.
rem +
rem + Default:
rem +     findvc  -arch x86_64  -toolset 14.1  -host x86_64
rem +---------------------------------------------------------------------------

setlocal

call "%~dp0..\lib\_init_CMD_LIB.cmd"

call "%CMD_LIB%\process_help_options.cmd" "%~f0" %*  && (endlocal & exit /b 1)

set "ARCH_TYPE=x86_64"
set "TS_VER=14.1"
set "HOST_TYPE=x86_64"
set "_RUN_="

call "%CMD_LIB%\argparse.cmd" ARCH_TYPE=val{arch} TS_VER=val{toolset,ts} HOST_TYPE=val{host} ^
  _RUN_=flag{dry-run,n}{echo} -- %*

call :if_verbosity_level 1  && (
  echo/
  echo ========================================
  echo Setting up MSVC environment:
  echo ========================================
  echo -- Arch     = %ARCH_TYPE%
  echo -- Toolset  = %TS_VER%
  echo -- Host     = %HOST_TYPE%
)

call :find_vswhere   || (echo/ & echo Error: can not find vswhere.exe & goto end_fail)
call :find_vsdevcmd  || (echo/ & echo Error: can not find vsdevcmd.bat & goto end_fail)

set "VS_ARCH_x86=-arch=x86"
set "VS_ARCH_x86_64=-arch=amd64"
set "VS_ARCH_arm=-arch=arm"
set "VS_ARCH_arm64=-arch=arm64"

set "VS_HOST_x86=-host_arch=x86"
set "VS_HOST_x86_64=-host_arch=amd64"

call set "VS_ARGS=-no_logo %%VS_ARCH_%ARCH_TYPE%%% %%VS_HOST_%HOST_TYPE%%% -vcvars_ver=%TS_VER%"

:end
endlocal & %_RUN_% call "%VSDEVCMD%" %VS_ARGS% %PARAMS%
exit /b

:end_fail
endlocal
exit /b 1


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


rem  Function  find_vswhere(  )
rem  ----------------------------------------------------------------------
rem   expects  [VSWHERE], optional
rem
rem   returns  VSWHERE
rem  ----------------------------------------------------------------------
:find_vswhere
if defined VSWHERE (
  "%VSWHERE%" >nul 2>&1  && goto find_vswhere_end
)
for /f "usebackq delims=" %%A in (`where "%~dp0.;%~dp0.\vswhere;%~dp0..\thirdparty;%~dp0..\thirdparty\vswhere:vswhere.exe" 2^>nul`) do (
  set "VSWHERE=%%~A"
  goto find_vswhere_end
)
exit /b 1
:find_vswhere_end
call :if_verbosity_level 1  && echo -- VSWHERE  = "%VSWHERE%"
exit /b 0


rem  Function  find_vsdevcmd(  )
rem  ----------------------------------------------------------------------
rem   expects  VSWHERE
rem
rem   returns  VSDEVCMD
rem  ----------------------------------------------------------------------
:find_vsdevcmd
for /f "usebackq delims=" %%A in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
  if exist "%%~A\Common7\Tools\vsdevcmd.bat" (
    set "VSDEVCMD=%%~A\Common7\Tools\vsdevcmd.bat"
    goto find_vsdevcmd_end
  )
)
exit /b 1
:find_vsdevcmd_end
call :if_verbosity_level 1  && echo -- VSDEVCMD = "%VSDEVCMD%"
exit /b 0
