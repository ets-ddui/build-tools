@if "%~1" == "ClearErrorLevel" goto ClearErrorLevel
@if "%~1" == "EnvironmentInit" goto EnvironmentInit
@if "%~1" == "ExpandPath" goto ExpandPath
@if "%~1" == "ExtractFileNameAndExt" goto ExtractFileNameAndExt
@if "%~1" == "GetEnvVarWithPrompt" goto GetEnvVarWithPrompt
@if "%~1" == "GetReg" goto GetReg
@if "%~1" == "SetReg" goto SetReg
@if "%~1" == "ShowInputBox" goto ShowInputBox
echo ��֧�ֵĺ���: %~1
exit /B 1



:ClearErrorLevel
::���ڽ�errorlevel��0
exit /B 0



:ExpandPath
:: �����%3������·����չΪ������·��(���·���ĵ�2��3�ַ���Ϊ":\"<����C:\Windows>������·��ǰ���%4������ֵ)
:: %1 in  ������
:: %2 out ���������
:: %3 in  ����չ��·���б�
:: %4 in  ����·����
setlocal

set Result=
set strIncludePaths=%~3
set strFullPath=%~4

:: ɾ��strFullPath����"\"�ַ�
if not "%strFullPath:~-1%" == "\" set strFullPath=%strFullPath%\

:ExpandPath_Loop
for /f "tokens=1* delims=;" %%i in ("%strIncludePaths%") do set strPath=%%i&set strIncludePaths=%%j
if not "%strPath:~1,2%" == ":\" set strPath=%strFullPath%%strPath%
set Result=%Result%%strPath%;

if not "%strIncludePaths%" == "" goto ExpandPath_Loop

endlocal&set %~2=%Result%
exit /B 0



:ExtractFileNameAndExt
:: ���ļ���%4�ֽ�Ϊ����(������չ��)����չ������ŵ����%2��%3��(��֧���ļ�·���Ľ���)
:: %1 in  ������
:: %2 out �ļ�����(������չ��)
:: %3 out �ļ���չ��
:: %4 in  �ļ�ȫ��
setlocal

set strFullName=%~4
for /f "tokens=1,* delims=." %%s in ("%strFullName%") do set strName=%%s&set strExt=%%t

if not defined strName exit /B 1
if not defined strExt exit /B 1

endlocal&set %~2=%strName%&set %~3=%strExt%
exit /B 0



:ShowInputBox
:: ����������ʾ�û�����
:: ִ�гɹ���errorlevel����0�����򣬴���0
:: %1 in  ������
:: %2 out �û����������
:: %3 in  ������
:: %4 in  ��ʾ��Ϣ
:: %5 in  ��ʼֵ
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
:: ��ȡע���
:: ִ�гɹ���errorlevel����0�����򣬴���0
:: %1 in  ������
:: %2 out ���������
:: %3 in  ע���·��
:: %4 in  ע������
setlocal

set Result=
for /f "tokens=1,2,*" %%s in ('reg query "%~3" /v "%~4" 2^>nul ^| find /I "%~4"') do set Result=%%u

if not defined Result exit /B 1

::ȥ��ĩβ�Ŀո�
:GetReg_Trim
if "%Result:~-1%" == " " set Result=%Result:~0,-1%&goto GetReg_Trim

endlocal&set %~2=%Result%
exit /B 0



:SetReg
:: ��ֵд��ע���
:: ִ�гɹ���errorlevel����0�����򣬴���0
:: %1 in ������
:: %2 in ע���·��
:: %3 in ע������
:: %4 in ע����ֵ
setlocal

>nul reg add "%~2" /v "%~3" /t REG_SZ /f /d "%~4

endlocal
exit /B 0



:GetEnvVarWithPrompt
:: ��ע����ȡ����������ֵ����������ʱ����ʾ�û��ֹ����룬������ɽ�����ٴ�ŵ�ע�����
:: ִ�гɹ���errorlevel����0�����򣬴���0
:: %1 in  ������
:: %2 out ���������
:: %3 in  ע���·��
:: %4 in  ������
:: %5 in  ��ʾ��Ϣ
:: %6 in  Ĭ��ֵ
:: %7 in  �Ƿ�ǿ�����룬Ϊ�ձ�ʾ��ע�����ûֵʱ����ʾ���룬����ǿ���û�����
setlocal

call %0 GetReg Result "%~3" "%~2"
if %errorlevel% == 0 if "%~7" == "" goto GetEnvVarWithPrompt_End

if "%Result%" == "" set Result=%~6
call %0 ShowInputBox Result "%~4" "����%~5" "%Result%"
if errorlevel 1 echo ����%~5ʧ��&exit /B 1

call %0 SetReg "%~3" "%~2" "%Result%"
if errorlevel 1 echo ����%~5ʧ��&exit /B 1

:GetEnvVarWithPrompt_End

endlocal&set %~2=%Result%
exit /B 0



:EnvironmentInit
:: ��ʼ�����뻷���ĸ���·��������������ű�ʹ�ã���ʼ����·����Ϊȫ�ֱ���
:: %1 in ������

call %0 ClearErrorLevel

exit /B 0
