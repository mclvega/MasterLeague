@echo off
setlocal
cd /d "%~dp0.."

echo [1/2] Running flutter clean...
call flutter clean
if errorlevel 1 (
  echo Error: flutter clean failed.
  exit /b 1
)

echo [2/2] Running flutter run --debug...
call flutter run --debug
if errorlevel 1 (
  echo Error: flutter run failed.
  exit /b 1
)

echo Done.
endlocal
