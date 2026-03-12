@echo off
setlocal
cd /d "%~dp0.."

set TARGET=%~1
if "%TARGET%"=="" set TARGET=apk

if /i "%TARGET%"=="apk" (
  echo Building Android APK release...
  call flutter build apk --release
  if errorlevel 1 goto :fail
  echo Output: build\app\outputs\flutter-apk\app-release.apk
  goto :ok
)

if /i "%TARGET%"=="aab" (
  echo Building Android App Bundle release...
  call flutter build appbundle --release
  if errorlevel 1 goto :fail
  echo Output: build\app\outputs\bundle\release\app-release.aab
  goto :ok
)

if /i "%TARGET%"=="web" (
  echo Building Web release...
  call flutter build web --release
  if errorlevel 1 goto :fail
  echo Output: build\web
  goto :ok
)

if /i "%TARGET%"=="windows" (
  echo Building Windows release...
  call flutter build windows --release
  if errorlevel 1 goto :fail
  echo Output: build\windows\x64\runner\Release
  goto :ok
)

echo Unknown target "%TARGET%".
echo Usage: build_share.bat [apk^|aab^|web^|windows]
exit /b 1

:fail
echo Error: build failed for target %TARGET%.
exit /b 1

:ok
echo Done.
endlocal
