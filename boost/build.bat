if "%BinDir%" == "" set BinDir=%~dp0../Out
if "%BinTemp%" == "" set BinTemp=%BinDir%/Temp
if "%SrcBoost%" == "" set SrcBoost=%BinDir%/Boost

:: tools\build\src\engine\guess_toolset.bat负责查找VS编译器的路径(通过"VS***COMNTOOLS"、"VS_ProgramFiles"查找)，当前的boost版本只支持到VS2017
:: tools\build\src\engine\config_toolset.bat调用vcvarsall.bat(Call_If_Exists)设置编译环境
:: 这里手工设置为2019的编译器的路径(实际上应该是借用的VS2017的配置)

::set VS150COMNTOOLS=D:\DevTool\VS2019\Common7\Tools

if not exist "%SrcBoost%/boost_1_64_0" (
    "%~dp0/../dev-bin/7z" x "%~dp0/boost_1_64_0.7z" -o"%SrcBoost%" ^
        boost_1_64_0\boost\ ^
        boost_1_64_0\libs\ ^
        boost_1_64_0\tools\ ^
        boost_1_64_0\*.jam ^
        boost_1_64_0\*.bat ^
        boost_1_64_0\Jamroot
)

pushd "%SrcBoost%/boost_1_64_0"

if not exist "b2.exe" (
    del bootstrap.log 2>nul
    del project-config.jam 2>nul
    del *.exe 2>nul

    rem 目前先强制使用VC2010编译
    call bootstrap.bat vc10
)

if not exist "%BinTemp%" mkdir "%BinTemp%" 2>nul

::不同的编译选项会影响最终生成文件的名字
::详见boost\config\auto_link.hpp中的代码
::当前配置下，因为编译的是动态库(link=shared)，在主程序中，需要定义BOOST_ALL_DYN_LINK宏，才能正确查找到lib文件

::Debug编译
::b2 --prefix="%SrcBoost%/ind" --exec-prefix="%SrcBoost%/dep" --libdir="%SrcBoost%/lib" --includedir="%SrcBoost%/include" ^
::    --stagedir="%SrcBoost%/stage" --build-dir="%BinTemp%" ^
::    variant=debug link=shared threading=multi runtime-link=shared

::Release编译
b2 --stagedir="%SrcBoost%" --build-dir="%BinTemp%" ^
    variant=release link=shared threading=multi runtime-link=shared ^
    1>"%BinTemp%/boost.log" 2>"%BinTemp%/boost_error.log" ^
    || exit /B 1

popd
