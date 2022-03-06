if "%BinDir%" == "" set BinDir=%~dp0..\Out
if "%BinTemp%" == "" set BinTemp=%BinDir%\Temp
if "%SrcNode%" == "" set SrcNode=%BinDir%\Node

if not exist "%SrcNode%/node-v0.12.18" (
    pushd "%SrcNode%"
    del /Q node-v0.12.18.tar 2>nul
    popd
    7z x "%~dp0/node-v0.12.18.tar.xz" -o"%SrcNode%" *
    7z x "%SrcNode%/node-v0.12.18.tar" -o"%SrcNode%" *
)

setlocal

set path=%path%;%~dp0/../dev-bin/python;%~dp0/../dev-bin/sed

rem pythonĬ����ͨ������"lib/os.py"ȷ��ִ���ļ�Ŀ¼����Ŀ¼��Ӱ��DLLs�е�ģ��ļ���
set PYTHONHOME=%~dp0/../dev-bin/python

pushd "%SrcNode%/node-v0.12.18"

rem ���ô˻���������ִ��python�ű�ʱ����������pyc�ļ�
set PYTHONDONTWRITEBYTECODE=False

rem VC����������Ӱ��config.gypi������(variables.node_has_winsdk��ȡֵ)
call "%VS100COMNTOOLS%\..\..\vc\vcvarsall.bat"

rem 1.0 �����ļ�����(config.gypi��config.mk��icu_config.gypi)
rem node��ԭʼ��configure�ű����������������ļ��󣬻��Զ�����tools/gyp_node.py���ɹ����ļ���
rem ���޷�ָ�������ļ�������·������ˣ��������ļ������ɵ������������
rem ������sed��configure��������ɹ��̵Ĵ����ȡ��
sed -rn "1,1047 p" configure >my_config.py

rem ����ӡ�--shared-cares --shared-http-parser --shared-libuv --shared-openssl --shared-v8 --shared-zlib������Ϊ��ᵼ��gyp��������Ӧ�Ĺ����ļ�
rem ��ӡ�--without-etw --without-perfctr������Ϊgyp���ɵĹ����ļ�·�����ԣ������Ϊֱ�ӵ��������д���
python my_config.py --dest-cpu=x86 --tag= --without-etw --without-perfctr

del my_config.py

rem 2.0 �����ļ�����
python tools/gyp_node.py --no-parallel -f msvs -G msvs_version=auto --generator-output "%SrcNode%/Proj"

rem 3.0 ���������ļ��еĴ���
pushd "%SrcNode%/Proj"

rem 3.1 ������js2c�����в��������ļ����������
for /F %%i in ('where python') do set Python_Path=%%i
sed -i -r "s/python/%Python_Path:\=\\%/g; s/&quot;[^ ]+CORE&quot;/CORE/; s/&quot;[^ ]+EXPERIMENTAL&quot;/EXPERIMENTAL/; s/&quot;[^ ]+off&quot;/off/g" ^
	"deps/v8/tools/gyp/js2c.vcxproj"

rem 3.2 ����v8������·��
for /F %%i in ('call find.bat -m f -e "\.vcxproj$" .') do sed -i -r ^
	"s/<OutDir>.*<\/OutDir>/<OutDir>%BinDir:\=\\%\\Node\\<\/OutDir>/; s/<IntDir>.*<\/IntDir>/<IntDir>%BinTemp:\=\\%\\Node\\$\(ProjectName\)\\<\/IntDir>/" %%i

rem 3.3 ����node������manifest·�����������
sed -i -r "s/<AdditionalManifestFiles>.*<\/AdditionalManifestFiles>/<AdditionalManifestFiles>%SrcNode:\=\\%\\node-v0\.12\.18\\src\\res\\node\.exe\.extra\.manifest<\/AdditionalManifestFiles>/" ^
	"node.vcxproj"

rem 3.9 ɾ��sed���ɵ���ʱ�ļ�
for /F %%i in ('call find.bat -m f -e "\\sed\w+$" .') do del %%i

popd

endlocal

rem 4.0 ����
rem set config=Release
rem set target=Build
rem set "msbplatform=Win32"
rem msbuild "%BinTemp%/Node/Proj/node.sln" /m /t:%target% /p:Configuration=%config% /p:Platform=%msbplatform% /clp:NoSummary;NoItemAndPropertyList;Verbosity=minimal /nologo

popd
