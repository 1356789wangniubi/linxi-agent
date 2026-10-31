@echo off
chcp 65001 >nul
set "APPDIR=%~dp0..\03_源码\源码_智能体"
if not exist "%APPDIR%\fishflow\chat_server.py" (
  echo Extract 03_源码\源码_智能体.zip into 03_源码 first.
  pause
  exit /b 1
)
call "%APPDIR%\开始公开.bat"
