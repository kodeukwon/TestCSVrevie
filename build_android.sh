#!/bin/bash

echo "🚀 Blogger 앱 Android APK 빌드 시작..."
echo ""

# Flutter 설치 확인
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter가 설치되어 있지 않습니다."
    echo ""
    echo "Flutter 설치 방법:"
    echo "1. https://docs.flutter.dev/get-started/install 방문"
    echo "2. 운영체제에 맞는 Flutter SDK 다운로드"
    echo "3. PATH 환경변수에 flutter/bin 추가"
    echo ""
    exit 1
fi

echo "✅ Flutter 버전 확인..."
flutter --version
echo ""

# 의존성 설치
echo "📦 의존성 설치 중..."
flutter pub get
echo ""

# Android 빌드
echo "🔨 APK 빌드 중 (5-10분 소요)..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 빌드 성공!"
    echo ""
    echo "📱 APK 파일 위치:"
    echo "   $(pwd)/build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📲 설치 방법:"
    echo "   1. app-release.apk 파일을 스마트폰으로 전송"
    echo "   2. 파일을 열어서 설치"
    echo "   3. '알 수 없는 출처' 허용 필요할 수 있음"
    echo ""

    # APK 파일 크기 확인
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
        echo "   파일 크기: $SIZE"
    fi
else
    echo ""
    echo "❌ 빌드 실패"
    echo "   에러 메시지를 확인하고 문제를 해결하세요."
    exit 1
fi
