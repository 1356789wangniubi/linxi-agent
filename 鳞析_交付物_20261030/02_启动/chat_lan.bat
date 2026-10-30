@echo off
cd /d "%~dp0"
set "PY=python"
where python >nul 2>nul
if errorlevel 1 set "PY=py -3"

%PY% -c "import socket,sys; s=socket.socket(); s.settimeout(0.4); sys.exit(0 if s.connect_ex(('127.0.0.1',8765))==0 else 1)"
if not errorlevel 1 (
  echo Chat server is already running.
  start "" "http://127.0.0.1:8765/"
  goto end
)

echo ============================================================
echo   LinXi chat - LAN mode
echo   Other devices on the same Wi-Fi/LAN can open the URL shown.
echo   Keep this window open. Ctrl+C to stop.
echo ============================================================
%PY% -m fishflow.chat_server --host 0.0.0.0

:end
echo.
pause
