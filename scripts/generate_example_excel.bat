@echo off
setlocal
cd /d "%~dp0.."

echo Generating example Excel data...
call dart run tool/generate_example_excel.dart
if errorlevel 1 (
  echo Error: excel generation failed.
  exit /b 1
)

echo Done. File: datos_prueba\master_league_ejemplo.xlsx
endlocal
