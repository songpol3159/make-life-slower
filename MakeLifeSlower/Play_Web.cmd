@echo off
cd /d "%~dp0"
set "ALS_NODE=%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"
if not exist "%ALS_NODE%" set "ALS_NODE=node.exe"
start "Alpine Farm local server" /min "%ALS_NODE%" "%~dp0serve.mjs"
start "" "http://127.0.0.1:8765/"
