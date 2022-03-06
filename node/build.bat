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

rem python默认是通过查找"lib/os.py"确定执行文件目录，此目录会影响DLLs中的模块的加载
set PYTHONHOME=%~dp0/../dev-bin/python

pushd "%SrcNode%/node-v0.12.18"

rem 设置此环境变量后，执行python脚本时，不会生成pyc文件
set PYTHONDONTWRITEBYTECODE=False

rem VC环境变量会影响config.gypi的生成(variables.node_has_winsdk的取值)
call "%VS100COMNTOOLS%\..\..\vc\vcvarsall.bat"

rem 1.0 配置文件生成(config.gypi、config.mk、icu_config.gypi)
rem node中原始的configure脚本，在生成了配置文件后，会自动调用tools/gyp_node.py生成工程文件，
rem 但无法指定工程文件的生成路径，因此，将工程文件的生成单独抽出来处理，
rem 这里用sed将configure中最后生成工程的代码截取掉
sed -rn "1,1047 p" configure >my_config.py

rem 不添加“--shared-cares --shared-http-parser --shared-libuv --shared-openssl --shared-v8 --shared-zlib”是因为这会导致gyp不生成相应的工程文件
rem 添加“--without-etw --without-perfctr”是因为gyp生成的工程文件路径不对，后面改为直接调用命令行处理
python my_config.py --dest-cpu=x86 --tag= --without-etw --without-perfctr

del my_config.py

rem 2.0 工程文件生成
python tools/gyp_node.py --no-parallel -f msvs -G msvs_version=auto --generator-output "%SrcNode%/Proj"

rem 3.0 修正工程文件中的错误
pushd "%SrcNode%/Proj"

rem 3.1 修正误将js2c命令行参数当成文件处理的问题
for /F %%i in ('where python') do set Python_Path=%%i
sed -i -r "s/python/%Python_Path:\=\\%/g; s/&quot;[^ ]+CORE&quot;/CORE/; s/&quot;[^ ]+EXPERIMENTAL&quot;/EXPERIMENTAL/; s/&quot;[^ ]+off&quot;/off/g" ^
	"deps/v8/tools/gyp/js2c.vcxproj"

rem 3.2 修正v8的生成路径
for /F %%i in ('call find.bat -m f -e "\.vcxproj$" .') do sed -i -r ^
	"s/<OutDir>.*<\/OutDir>/<OutDir>%BinDir:\=\\%\\Node\\<\/OutDir>/; s/<IntDir>.*<\/IntDir>/<IntDir>%BinTemp:\=\\%\\Node\\$\(ProjectName\)\\<\/IntDir>/" %%i

rem 3.3 修正node工程中manifest路径错误的问题
sed -i -r "s/<AdditionalManifestFiles>.*<\/AdditionalManifestFiles>/<AdditionalManifestFiles>%SrcNode:\=\\%\\node-v0\.12\.18\\src\\res\\node\.exe\.extra\.manifest<\/AdditionalManifestFiles>/" ^
	"node.vcxproj"

rem 3.9 删除sed生成的临时文件
for /F %%i in ('call find.bat -m f -e "\\sed\w+$" .') do del %%i

popd

endlocal

rem 4.0 编译
rem set config=Release
rem set target=Build
rem set "msbplatform=Win32"
rem msbuild "%BinTemp%/Node/Proj/node.sln" /m /t:%target% /p:Configuration=%config% /p:Platform=%msbplatform% /clp:NoSummary;NoItemAndPropertyList;Verbosity=minimal /nologo

popd
