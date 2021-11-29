if "%BinDir%" == "" set BinDir=%~dp0../Out
if "%BinTemp%" == "" set BinTemp=%BinDir%/Temp
if "%SrcBoost%" == "" set SrcBoost=%BinDir%/Boost

:: tools\build\src\engine\guess_toolset.bat�������VS��������·��(ͨ��"VS***COMNTOOLS"��"VS_ProgramFiles"����)����ǰ��boost�汾ֻ֧�ֵ�VS2017
:: tools\build\src\engine\config_toolset.bat����vcvarsall.bat(Call_If_Exists)���ñ��뻷��
:: �����ֹ�����Ϊ2019�ı�������·��(ʵ����Ӧ���ǽ��õ�VS2017������)

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

    rem Ŀǰ��ǿ��ʹ��VC2010����
    call bootstrap.bat vc10
)

if not exist "%BinTemp%" mkdir "%BinTemp%" 2>nul

::��ͬ�ı���ѡ���Ӱ�����������ļ�������
::���boost\config\auto_link.hpp�еĴ���
::��ǰ�����£���Ϊ������Ƕ�̬��(link=shared)�����������У���Ҫ����BOOST_ALL_DYN_LINK�꣬������ȷ���ҵ�lib�ļ�

::Debug����
::b2 --prefix="%SrcBoost%/ind" --exec-prefix="%SrcBoost%/dep" --libdir="%SrcBoost%/lib" --includedir="%SrcBoost%/include" ^
::    --stagedir="%SrcBoost%/stage" --build-dir="%BinTemp%" ^
::    variant=debug link=shared threading=multi runtime-link=shared

::Release����
b2 --stagedir="%SrcBoost%" --build-dir="%BinTemp%" ^
    variant=release link=shared threading=multi runtime-link=shared ^
    1>"%BinTemp%/boost.log" 2>"%BinTemp%/boost_error.log" ^
    || exit /B 1

popd
