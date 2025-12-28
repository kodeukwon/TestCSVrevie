#!/bin/bash

echo "🌐 Blogger 앱 웹 버전 빌드 시작..."
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

# Web 빌드
echo "🔨 웹 버전 빌드 중..."
flutter build web --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 빌드 성공!"
    echo ""
    echo "🌐 웹 파일 위치:"
    echo "   $(pwd)/build/web/"
    echo ""
    echo "📤 배포 방법:"
    echo "   1. build/web/ 폴더 전체를 웹 호스팅에 업로드"
    echo "   2. GitHub Pages, Vercel, Netlify 등 사용 가능"
    echo ""
    echo "🧪 로컬 테스트:"
    echo "   cd build/web && python3 -m http.server 8000"
    echo "   브라우저에서 http://localhost:8000 접속"
    echo ""
else
    echo ""
    echo "❌ 빌드 실패"
    echo "   에러 메시지를 확인하고 문제를 해결하세요."
    exit 1
fi
