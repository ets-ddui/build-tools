@if "%~1" == "ClearErrorLevel" goto ClearErrorLevel
@if "%~1" == "EnvironmentInit" goto EnvironmentInit
@if "%~1" == "ExpandPath" goto ExpandPath
@if "%~1" == "ExtractFileNameAndExt" goto ExtractFileNameAndExt
@if "%~1" == "GetEnvVarWithPrompt" goto GetEnvVarWithPrompt
@if "%~1" == "GetReg" goto GetReg
@if "%~1" == "SetReg" goto SetReg
@if "%~1" == "ShowInputBox" goto ShowInputBox
echo 不支持的函数: %~1
exit /B 1



:ClearErrorLevel
::用于将errorlevel清0
exit /B 0



:ExpandPath
:: 将入参%3的所有路径扩展为完整的路径(如果路径的第2、3字符不为":\"<例如C:\Windows>，则在路径前添加%4参数的值)
:: %1 in  函数名
:: %2 out 输出参数名
:: %3 in  待扩展的路径列表
:: %4 in  绝对路径名
setlocal

set Result=
set strIncludePaths=%~3
set strFullPath=%~4

:: 删掉strFullPath最后的"\"字符
if not "%strFullPath:~-1%" == "\" set strFullPath=%strFullPath%\

:ExpandPath_Loop
for /f "tokens=1* delims=;" %%i in ("%strIncludePaths%") do set strPath=%%i&set strIncludePaths=%%j
if not "%strPath:~1,2%" == ":\" set strPath=%strFullPath%%strPath%
set Result=%Result%%strPath%;

if not "%strIncludePaths%" == "" goto ExpandPath_Loop

endlocal&set %~2=%Result%
exit /B 0



:ExtractFileNameAndExt
:: 将文件名%4分解为名称(不带扩展名)及扩展名，存放到入参%2、%3中(不支持文件路径的解析)
:: %1 in  函数名
:: %2 out 文件名称(不带扩展名)
:: %3 out 文件扩展名
:: %4 in  文件全名
setlocal

set strFullName=%~4
for /f "tokens=1,* delims=." %%s in ("%strFullName%") do set strName=%%s&set strExt=%%t

if not defined strName exit /B 1
if not defined strExt exit /B 1

endlocal&set %~2=%strName%&set %~3=%strExt%
exit /B 0



:ShowInputBox
:: 弹出窗口提示用户输入
:: 执行成功，errorlevel返回0，否则，大于0
:: %1 in  函数名
:: %2 out 用户输入的内容
:: %3 in  窗口名
:: %4 in  提示信息
:: %5 in  初始值
setlocal

set Result=

>$.vbs echo Result=inputbox("%~4","%~3","%~5")
>>$.vbs echo Wscript.Echo Result
for /f "delims=" %%s in ('cscript //nologo $.vbs') do set Result=%%s
del $.vbs

if not defined Result exit /B 1

endlocal&set %~2=%Result%
exit /B 0



:GetReg
:: 读取注册表
:: 执行成功，errorlevel返回0，否则，大于0
:: %1 in  函数名
:: %2 out 输出参数名
:: %3 in  注册表路径
:: %4 in  注册表键名
setlocal

set Result=
for /f "tokens=1,2,*" %%s in ('reg query "%~3" /v "%~4" 2^>nul ^| find /I "%~4"') do set Result=%%u

if not defined Result exit /B 1

::去掉末尾的空格
:GetReg_Trim
if "%Result:~-1%" == " " set Result=%Result:~0,-1%&goto GetReg_Trim

endlocal&set %~2=%Result%
exit /B 0



:SetReg
:: 将值写入注册表
:: 执行成功，errorlevel返回0，否则，大于0
:: %1 in 函数名
:: %2 in 注册表路径
:: %3 in 注册表键名
:: %4 in 注册表键值
setlocal

>nul reg add "%~2" /v "%~3" /t REG_SZ /f /d "%~4

endlocal
exit /B 0



:GetEnvVarWithPrompt
:: 从注册表读取环境变量的值，当不存在时，提示用户手工输入，输入完成将结果再存放到注册表中
:: 执行成功，errorlevel返回0，否则，大于0
:: %1 in  函数名
:: %2 out 输出参数名
:: %3 in  注册表路径
:: %4 in  窗口名
:: %5 in  提示信息
:: %6 in  默认值
:: %7 in  是否强制输入，为空表示当注册表中没值时才提示输入，否则，强制用户输入
setlocal

call %0 GetReg Result "%~3" "%~2"
if %errorlevel% == 0 if "%~7" == "" goto GetEnvVarWithPrompt_End

if "%Result%" == "" set Result=%~6
call %0 ShowInputBox Result "%~4" "设置%~5" "%Result%"
if errorlevel 1 echo 设置%~5失败&exit /B 1

call %0 SetReg "%~3" "%~2" "%Result%"
if errorlevel 1 echo 保存%~5失败&exit /B 1

:GetEnvVarWithPrompt_End

endlocal&set %~2=%Result%
exit /B 0



:EnvironmentInit
:: 初始化编译环境的各类路径，供后续编译脚本使用，初始化的路径均为全局变量
:: %1 in 函数名

call %0 ClearErrorLevel

exit /B 0
