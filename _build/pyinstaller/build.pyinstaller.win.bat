@echo off

REM ......................setup variables......................

if [%1]==[] (
    SET ARCH=64
) else (
    SET ARCH=%1
)

if ["%ARCH%"]==["64"] (
    SET BINARCH=x64
    SET FFMPEG=https://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-latest-win64-static.7z
)
if ["%ARCH%"]==["32"] (
    SET BINARCH=x86
    SET FFMPEG=https://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-latest-win32-static.7z
)

REM ......................get latest version number......................

for /f "delims=" %%a in ('python version.py') do @set VERSION=%%a

REM ......................cleanup previous build scraps......................

rd /s /q build
rd /s /q dist
del /q ..\..\bin\ffmpeg.exe

REM ......................download latest FFmpeg static binary......................

if not exist ".\temp\" mkdir temp
aria2c -d temp -x 6 %FFMPEG%

REM ......................extract ffmpeg.exe to its expected location......................

cd temp
"C:\Program Files\7-Zip\7z.exe" e ffmpeg-latest-win%ARCH%-static.7z ffmpeg-latest-win%ARCH%-static/bin/ffmpeg.exe
if not exist "..\..\..\bin\" mkdir "..\..\..\bin\"
move ffmpeg.exe ..\..\..\bin\
cd ..

REM ......................run pyinstaller......................

pyinstaller --clean vidcutter.win%ARCH%.spec

REM ......................add metadata to built Windows binary......................

verpatch dist\vidcutter.exe /va %VERSION%.0 /pv %VERSION%.0 /s desc "VidCutter" /s name "VidCutter" /s copyright "2017 Pete Alexandrou" /s product "VidCutter %BINARCH%"
