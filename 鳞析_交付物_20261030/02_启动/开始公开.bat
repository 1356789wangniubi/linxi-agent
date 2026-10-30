@echo off
cd /d "%~dp0"
chcp 65001 >nul
set "PY=python"
where python >nul 2>nul
if errorlevel 1 set "PY=py -3"

if not exist "secrets" mkdir "secrets"
set "ACCESS_CODE="
if exist "secrets\access_code.txt" set /p ACCESS_CODE=<"secrets\access_code.txt"
if "%ACCESS_CODE%"=="" set "ACCESS_CODE=UGTZR55H"

set "FISHFLOW_LLM_URL=https://open.bigmodel.cn/api/paas/v4/chat/completions"
set "FISHFLOW_LLM_MODEL=glm-4-flash"
set "FISHFLOW_ACCESS_CODE=%ACCESS_CODE%"

echo ============================================================
echo  LinXi public launcher
echo  Access code: %ACCESS_CODE%
echo  Browser prompt: username = anything, password = access code
echo ============================================================

%PY% -c "import socket,sys; s=socket.socket(); s.settimeout(0.6); sys.exit(0 if s.connect_ex(('127.0.0.1',8765))==0 else 1)"
if errorlevel 1 (
  echo Starting local server...
  start "LinXi Server" /min cmd /c "%PY% -m fishflow.chat_server --host 0.0.0.0 --no-open --port 8765"
  timeout /t 4 >nul
) else (
  echo A server is already listening on 8765.
  echo If it was NOT started with this access code, close it first.
)

set "SSHHOME=%~dp0.sshhome"
if not exist "%SSHHOME%\.ssh" mkdir "%SSHHOME%\.ssh"
set "USERPROFILE=%SSHHOME%"
set "HOME=%SSHHOME%"

echo.
echo Opening public tunnel. Keep this window open.
echo The public URL will appear below; send it with the access code.
echo.
ssh -F NUL -o UserKnownHostsFile="%SSHHOME%\.ssh\known_hosts" -o StrictHostKeyChecking=no -o ServerAliveInterval=20 -o ExitOnForwardFailure=yes -R 80:127.0.0.1:8765 nokey@localhost.run
echo.
echo Tunnel closed. Run this file again for a new URL.
pause
