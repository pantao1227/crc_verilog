@echo off
del a.out
iverilog test.v
if %ERRORLEVEL% neq 0 goto EOF
vvp a.out

:EOF