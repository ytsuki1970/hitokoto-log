@echo off
rem hitokoto-log launcher (ASCII only)
cd /d "%~dp0"
start "" /min python -m http.server 8932
powershell -NoProfile -Command "$u='http://localhost:8932/'; for($i=0;$i -lt 60;$i++){ try{ Invoke-WebRequest -UseBasicParsing -Uri $u -TimeoutSec 1 ^| Out-Null; break }catch{ Start-Sleep -Milliseconds 250 } }; Start-Process $u"
