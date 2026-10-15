@echo off
set "ALS_GODOT=%~dp0..\tools\godot\Godot_v4.7.2-stable_win64.exe"
if exist "%ALS_GODOT%" (
  start "" "%ALS_GODOT%" --editor --path "%~dp0"
) else (
  echo Open project.godot with Godot 4.7.2.
  pause
)
