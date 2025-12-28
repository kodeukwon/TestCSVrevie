@echo off
echo 🚀 Blogger 앱 Windows 빌드 시작...
echo.

REM Flutter 설치 확인
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Flutter가 설치되어 있지 않습니다.
    echo.
    echo Flutter 설치 방법:
    echo 1. https://docs.flutter.dev/get-started/install/windows 방문
    echo 2. Flutter SDK 다운로드 및 압축 해제
    echo 3. PATH 환경변수에 flutter\bin 추가
    echo.
    pause
    exit /b 1
)

echo ✅ Flutter 버전 확인...
flutter --version
echo.

REM 의존성 설치
echo 📦 의존성 설치 중...
flutter pub get
echo.

REM Windows 빌드
echo 🔨 Windows 앱 빌드 중...
flutter build windows --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ 빌드 성공!
    echo.
    echo 💻 실행 파일 위치:
    echo    %CD%\build\windows\x64\runner\Release\
    echo.
    echo 🎯 실행 방법:
    echo    위 폴더의 blogger_app.exe 더블클릭
    echo.
) else (
    echo.
    echo ❌ 빌드 실패
    echo    에러 메시지를 확인하고 문제를 해결하세요.
    pause
    exit /b 1
)

pause
