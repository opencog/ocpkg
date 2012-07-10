@echo off

title OpenCog cygwin port script

REM File:			ocCygwinSetup.bat
REM Description:	Windows batch script to install and setup Cygwin packages (needed to build OpenCog)
REM Copyright:		OpenCog Foundation (2012)
REM Requirement:	Windows XP (or higher)

REM This Windows batch script is organized in sections:
REM Section #1: Global variable setting
REM Section #2: Command line option handling
REM Section #3: Main program
REM Section #4: Function definitions

REM ==========================================
REM == Section #1: Setting global variables ==
REM ==========================================

set CYGWIN_BASE_PACKAGES=alternatives,^
base-cygwin,^
base-files,^
bash,^
coreutils,^
cygwin,^
cygwin-doc,^
dash,^
editrights,^
file,^
findutils,^
gawk,^
grep,^
gzip,^
ipc-utils,^
libgcc1,^
libreadline7,^
login,^
man,^
mintty,^
rebase,^
run,^
sed,^
tar,^
terminfo,^
tzcode,^
which,^
zlib0

set PACKAGES_BUILD=gcc4-g++,^
gcc4,^
make,^
cmake,^
rlwrap,^
guile-devel,^
libicu-devel,^
libbz2-devel,^
python-numpy,^
openssl-devel,^
gsl-devel,^
libexpat1-devel,^
libxerces-c-devel,^
libcurl-devel,^
tcsh,^
libuuid-devel,^
doxygen

REM Unset these variables
REM (this is to initialize them to 'empty-ish' value)
REM This is to make them serve the job of variables that can store return values from code inside :getopts label
set PRINT_USAGE=
set INTERACTIVE=

REM ==============================================
REM == Section #2: Command line option handling ==
REM ==============================================

if not (%1)==() call:getopts %*

if defined PRINT_USAGE call:usage
if defined PRINT_USAGE if defined INTERACTIVE echo Script will exit now... & pause
if defined PRINT_USAGE exit /B

set CYGWIN_SETUPEXE_OPTIONS=--quiet-mode ^
--disable-buggy-antivirus ^
--packages

REM TODO: set CYGWIN_SETUPEXE_OPTIONS  ===>  --local-install --no-shortcuts
REM TODO: Add more command line options (handling)

REM ==============================
REM == Section #3: Main program ==
REM ==============================

echo.
echo Setup will download Cygwin's setup.exe now...
if defined INTERACTIVE pause
call:fetchurl

echo Script will install Cygwin 'base' packages now...
if defined INTERACTIVE pause
%TEMP%\cygwin-setup.exe ^
%CYGWIN_SETUPEXE_OPTIONS% ^
%CYGWIN_BASE_PACKAGES%

echo.
echo Script will install OpenCog Cygwin build dependencies now...
if defined INTERACTIVE pause
%TEMP%\cygwin-setup.exe ^
%CYGWIN_SETUPEXE_OPTIONS% ^
%PACKAGES_BUILD%

echo.
echo Script will exit now...
if defined INTERACTIVE pause
goto:eof

REM ======================================
REM == Section #4: Function definitions ==
REM ======================================

:getopts
 if /I %1 == -h set PRINT_USAGE=1
 if /I %1 == -i set INTERACTIVE=1
 shift
if not (%1)==() goto GETOPTS
goto:eof

:usage
echo TODO: Help message
goto :EOF


:fetchurl
set file=%TEMP%\fetch-url.vbs
>%file% echo ' Set your settings
>>%file% echo     strFileURL = "http://cygwin.com/setup.exe"
>>%file% echo     strHDLocation = "%TEMP%\cygwin-setup.txt"
>>%file% echo.
>>%file% echo ' Fetch the file
>>%file% echo     Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
>>%file% echo.
>>%file% echo     objXMLHTTP.open "GET", strFileURL, false
>>%file% echo     objXMLHTTP.send()
>>%file% echo.
>>%file% echo If objXMLHTTP.Status = 200 Then
>>%file% echo Set objADOStream = CreateObject("ADODB.Stream")
>>%file% echo objADOStream.Open
>>%file% echo objADOStream.Type = 1 'adTypeBinary
>>%file% echo.
>>%file% echo objADOStream.Write objXMLHTTP.ResponseBody
>>%file% echo objADOStream.Position = 0    'Set the stream position to the start
>>%file% echo.
>>%file% echo Set objFSO = Createobject("Scripting.FileSystemObject")
>>%file% echo If objFSO.Fileexists(strHDLocation) Then objFSO.DeleteFile strHDLocation
>>%file% echo Set objFSO = Nothing
>>%file% echo.
>>%file% echo objADOStream.SaveToFile strHDLocation
>>%file% echo objADOStream.Close
>>%file% echo Set objADOStream = Nothing
>>%file% echo End if
>>%file% echo.
>>%file% echo Set objXMLHTTP = Nothing
cscript %TEMP%/fetch-url.vbs
mv %TEMP%\cygwin-setup.txt %TEMP%\cygwin-setup.exe
goto:EOF
