@echo off
setlocal

mkdir build 2>nul

copy /Y "%SDL3_ROOT%\bin\SDL2.dll" build\

copy /Y bin\SDL3_shadercross.dll build\
copy /Y bin\dxcompiler.dll build\
copy /Y bin\dxil.dll build\

odin build example -out:build\example.exe

endlocal
