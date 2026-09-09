@echo off
setlocal

mkdir build 2>nul

copy /Y lib\SDL3_shadercross.lib build\
copy /Y "%SDL3_ROOT%\lib\SDL2.lib" build\

odin build example -out:build\example.exe

endlocal
