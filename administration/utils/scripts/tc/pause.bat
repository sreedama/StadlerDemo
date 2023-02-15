@echo off
REM use this script to take a pause for X seconds, default seconds are 5
set SEC=%1
if %1x==x set SEC=5
PING -n %SEC% 127.0.0.1 >NUL