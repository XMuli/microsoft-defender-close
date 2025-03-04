@echo off
setlocal enabledelayedexpansion

set QT_PATH=C:\Qt\6.7.3\msvc2022_64
set BUILD_DIR=build
set BIN_DIR=bin
set PROJECT_NAME=ToggleGuardian
set "VERSION=2.2.0" 
set CONFIG_TYPE=Release 
REM true - Ninja ����;  false - Visual Studio 17 2022 ����; ��һ����β���һ���ո�
set IS_USE_NINJA=true 
set BUILD_DIR_NAME=Desktop_Qt_6_7_3_MSVC2022_64bit-%CONFIG_TYPE% 
set "TOOL_7Z=C:\Program Files\7-Zip\7z.exe" 
REM true �����ٹ��� setup ��װ����ǩ����false Ĭ�ϲ���Ҫ����
set IS_CREATE_SETUP_PACAKE=true  

echo "****************** ������ʼ ******************"
echo Qt Path: "%QT_PATH%"
echo Build Directory: "%BUILD_DIR%"
echo Bin Directory: "%BIN_DIR%"
echo Build Type: "%CONFIG_TYPE%"

echo "****************** ��������ɵĹ���Ŀ¼�� bin �ļ��� ******************"
if exist %BUILD_DIR% (
    echo ɾ�����е� "%BUILD_DIR%" �ļ���...
    rmdir /s /q %BUILD_DIR%
)
if exist %BIN_DIR% (
    echo ɾ�����е� "%BIN_DIR%" �ļ���...
    rmdir /s /q %BIN_DIR%
)

echo "****************** ������Ŀ¼ ******************"
mkdir %BUILD_DIR%
mkdir %BIN_DIR%

echo "****************** �������û������� ******************"
call "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" -arch=amd64
call "%QT_PATH%\bin\qtenv2.bat" 

echo "****************** ��ǰ·�� ******************"
cd /d %~dp0
echo ��ǰ·��: "%CD%"

set START_TIME=%TIME%

echo "****************** ѡ����뷽ʽ ******************"
if "%IS_USE_NINJA%"=="true" (
    echo "****************** ����ʹ�� Visual Studio 17 2022 ���� ******************"
    "C:\Program Files\CMake\bin\cmake.exe" -DCMAKE_BUILD_TYPE=%CONFIG_TYPE% -DCMAKE_PREFIX_PATH="%QT_PATH%" ^
          -G "Visual Studio 17 2022" -A x64 . ^
          -S . -B .\%BUILD_DIR%\%BUILD_DIR_NAME%
    if %ERRORLEVEL% NEQ 0 (
        echo ����ʧ�ܣ�
        exit /b %ERRORLEVEL%
    )

    echo "****************** ���ڱ�����Ŀ ******************"
    "C:\Program Files\CMake\bin\cmake.exe" --build .\%BUILD_DIR%\%BUILD_DIR_NAME% --target %PROJECT_NAME% -- /m:%NUMBER_OF_PROCESSORS%
    if %ERRORLEVEL% NEQ 0 (
        echo ����ʧ�ܣ�
        exit /b %ERRORLEVEL%
    )

) else (
    echo "****************** ����ʹ�� Ninja ���� ******************"
    "C:\Program Files\CMake\bin\cmake.exe" -DCMAKE_BUILD_TYPE=%CONFIG_TYPE% -DCMAKE_PREFIX_PATH="%QT_PATH%" ^
          -DCMAKE_MAKE_PROGRAM="C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe" ^
          -G Ninja -S . -B .\%BUILD_DIR%\%BUILD_DIR_NAME%
    if %ERRORLEVEL% NEQ 0 (
        echo ����ʧ�ܣ�
        exit /b %ERRORLEVEL%
    )

    echo "****************** ���ڱ�����Ŀ ******************"
    "C:\Program Files\CMake\bin\cmake.exe" --build .\%BUILD_DIR%\%BUILD_DIR_NAME% --target %PROJECT_NAME% -- -j%NUMBER_OF_PROCESSORS%
    if %ERRORLEVEL% NEQ 0 (
        echo ����ʧ�ܣ�
        exit /b %ERRORLEVEL%
    )
)

echo "****************** ����ɹ� ******************"

set END_TIME=%TIME%

echo "���뿪ʼʱ��: "%START_TIME%""
echo "�������ʱ��: "%END_TIME%""

set /a START_HOUR=%START_TIME:~0,2%
set /a START_MINUTE=%START_TIME:~3,2%
set /a START_SECOND=%START_TIME:~6,2%

set /a END_HOUR=%END_TIME:~0,2%
set /a END_MINUTE=%END_TIME:~3,2%
set /a END_SECOND=%END_TIME:~6,2%

set /a START_TOTAL_SEC=%START_HOUR%*3600+%START_MINUTE%*60+%START_SECOND%
set /a END_TOTAL_SEC=%END_HOUR%*3600+%END_MINUTE%*60+%END_SECOND%

set /a ELAPSED_SEC=%END_TOTAL_SEC% - %START_TOTAL_SEC%
set /a ELAPSED_MINUTES=%ELAPSED_SEC% / 60
set /a ELAPSED_SECONDS=%ELAPSED_SEC% %% 60

echo "�����ܺ�ʱ: "%ELAPSED_MINUTES%" ���� "%ELAPSED_SECONDS%" ��"

echo "****************** ɾ���ļ�: .\bin\Qt6Pdf.dll ******************"
if exist .\bin\Qt6Pdf.dll (
    echo ɾ���ļ�: .\bin\Qt6Pdf.dll
    del /f /q .\bin\Qt6Pdf.dll
)

echo "****************** ����ΪӦ��ǩ�� ******************"

"C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\signtool.exe" sign /sha1 "8e383d678f5e22ddcdd42c9571d3b9a4bdbd2860" /tr http://time.certum.pl /td sha256 /fd sha256 /v ".\bin\%PROJECT_NAME%.exe"


:: ѹ���ļ���
echo ѹ���ļ���Ϊ .7z �ļ�...
"%TOOL_7Z%" a ".\%PROJECT_NAME%_protable_%VERSION%_x64.7z" ".\%BIN_DIR%\*"


:: ��� IS_CREATE_SETUP_PACAKE Ϊ true����ִ�����²���
if "%IS_CREATE_SETUP_PACAKE%"=="true" (

	echo ���� setup exe ��װ��
	"C:\Program Files (x86)\Inno Setup 6\Compil32.exe" /cc ".\setup_package.iss"
	
	:: ��ȡ���������� .exe �ļ�����û�к�׺��
	for %%f in (%PROJECT_NAME%_setup_*_x64.exe) do (
		set "FILENAME=%%~nf"
		echo �ļ�����û�к�׺��: !FILENAME!
	)
	
	echo ��װ��������: !FILENAME!
    echo ������ "%PROJECT_NAME%_setup_%VERSION%_x64.exe"
    ren "!FILENAME!.exe" "%PROJECT_NAME%_setup_%VERSION%_x64.exe"
	
	echo "****************** signtool ���ǩ�� ******************"
	"C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\signtool.exe" sign /sha1 "8e383d678f5e22ddcdd42c9571d3b9a4bdbd2860" /tr http://time.certum.pl /td sha256 /fd sha256 /v ".\%PROJECT_NAME%_setup_%VERSION%_x64.exe"


) else (
    echo δ���ð�װ��������ǩ������
)


REM ����������Ӧ��
REM echo "****************** ������Ŀ ******************"
REM .\bin\%PROJECT_NAME%.exe

pause