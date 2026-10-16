@echo off
setlocal EnableExtensions
cd /d "%~dp0"
echo.
echo === COURT IQ - Flutter setup ===
echo.
echo IMPORTANT: Keep this project in a simple path such as C:\FlutterProjects\CourtIQ
 echo Avoid parentheses in folder names (example: CC(dart)).
echo.
where flutter >nul 2>nul
if errorlevel 1 (
  echo ERROR: Flutter not found. Install the Flutter SDK and add its bin folder to PATH.
  goto fail
)
if not exist "lib\main.dart" (
  echo ERROR: Open the extracted CourtIQ folder, which contains lib\main.dart.
  goto fail
)
if exist "android\app\src\main\AndroidManifest.xml" if not exist "android\gradlew" (
  echo ERROR: Incomplete Android project detected.
  echo Rename the android folder to android_backup, then rerun this script.
  goto fail
)
echo [1/3] Generate current Android and web project files...
call flutter create --project-name court_iq --platforms=android,web .
if errorlevel 1 goto fail

echo [2/3] Configure app label and Android internet permission...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\configure_android.ps1"
if errorlevel 1 goto fail

echo [3/3] Install Flutter dependencies...
call flutter pub get
if errorlevel 1 goto fail

echo.
echo SETUP COMPLETE.
echo Run: flutter devices
echo Then: flutter run -d emulator-5554
exit /b 0
:fail
echo.
echo SETUP FAILED. Read the error messages above.
exit /b 1
