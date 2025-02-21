@echo off
setlocal enabledelayedexpansion

:: ��������ļ�·��
set "OUTPUT_FOLDER=.\Output_3.1.3"
set "OUTPUT_FILE=%OUTPUT_FOLDER%\checksums_md5_sha256.txt"


:: ��鲢�������ļ�������Ѵ��ڣ�
if exist "%OUTPUT_FILE%" del /f /q "%OUTPUT_FILE%"

:: ����ָ���ļ�����У��ֵ
for /r "%OUTPUT_FOLDER%" %%f in (*) do (
    echo �����ļ�: %%f

    :: ��ʼ����ϣֵ
    set "MD5="
    set "SHA1="
    set "SHA256="

    :: ��ȡ����� MD5 У��ֵ��ȥ���������ʾ��Ϣ��ֻ������ϣֵ
    for /f "skip=1 tokens=*" %%a in ('certutil -hashfile "%%f" MD5 ^| findstr /v /c:"CertUtil:"') do (
        set "MD5=%%a"
    )
    set "MD5=!MD5: =!"

    :: ��ȡ����� SHA1 У��ֵ��ȥ���������ʾ��Ϣ��ֻ������ϣֵ
    for /f "skip=1 tokens=*" %%a in ('certutil -hashfile "%%f" SHA1 ^| findstr /v /c:"CertUtil:"') do (
        set "SHA1=%%a"
    )
    set "SHA1=!SHA1: =!"

    :: ��ȡ����� SHA256 У��ֵ��ȥ���������ʾ��Ϣ��ֻ������ϣֵ
    for /f "skip=1 tokens=*" %%a in ('certutil -hashfile "%%f" SHA256 ^| findstr /v /c:"CertUtil:"') do (
        set "SHA256=%%a"
    )
    set "SHA256=!SHA256: =!"

    :: ������������У��ֵ���ļ���ʹ���Ʊ�����ж���
    echo %%~nxf >> "%OUTPUT_FILE%"
    echo MD5:     !MD5! >> "%OUTPUT_FILE%"
    echo SHA-1:   !SHA1! >> "%OUTPUT_FILE%"
    echo SHA-256: !SHA256! >> "%OUTPUT_FILE%"
    echo. >> "%OUTPUT_FILE%"
)

echo У��ֵ�������! У����Ϣ��д�뵽 %OUTPUT_FILE%

:: pause