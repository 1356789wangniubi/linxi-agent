@echo off
cd /d "%~dp0"
set "PY=python"
where python >nul 2>nul
if errorlevel 1 set "PY=py -3"

set "FISHFLOW_LLM_URL=https://open.bigmodel.cn/api/paas/v4/chat/completions"
set "FISHFLOW_LLM_MODEL=glm-4-flash"

%PY% -c "import socket,sys; s=socket.socket(); s.settimeout(0.4); sys.exit(0 if s.connect_ex(('127.0.0.1',8765))==0 else 1)"
if not errorlevel 1 (
  echo Chat server is already running.
  start "" "http://127.0.0.1:8765/"
  goto end
)

%PY% -c "from fishflow.secret_store import has; import sys; sys.exit(0 if has('zhipu') else 1)"
if errorlevel 1 (
  echo [WARN] No DPAPI secret found. Run: python -m fishflow.secret_setup
  echo        The chat still works in rule-only mode.
) else (
  echo Zhipu GLM-4-Flash enabled. Key loaded from Windows DPAPI.
)

echo Starting chat UI...
%PY% -m fishflow.chat_server

:end
echo.
pause
