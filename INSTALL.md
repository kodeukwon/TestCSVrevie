# 📱 간편 설치 가이드

이 가이드를 따라하면 **10분 안에** Blogger 앱을 내 기기에 설치할 수 있습니다!

## 📋 목차

1. [Android 스마트폰에 설치](#android-스마트폰에-설치)
2. [Windows PC에 설치](#windows-pc에-설치)
3. [웹 버전 사용](#웹-버전-사용)
4. [문제 해결](#문제-해결)

---

## 📱 Android 스마트폰에 설치

### 1단계: Flutter 설치 (처음 한 번만)

**Windows:**
```bash
# 1. Flutter 다운로드
https://docs.flutter.dev/get-started/install/windows

# 2. 압축 해제 후 PATH 추가
# "시스템 환경 변수 편집" → Path에 flutter\bin 추가

# 3. 확인
flutter doctor
```

**macOS:**
```bash
# 1. Homebrew 사용 (권장)
brew install --cask flutter

# 2. 확인
flutter doctor
```

**Linux:**
```bash
# 1. Flutter 다운로드
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz

# 2. 압축 해제
tar xf flutter_linux_3.24.0-stable.tar.xz

# 3. PATH 추가 (~/.bashrc 또는 ~/.zshrc)
export PATH="$PATH:$HOME/flutter/bin"

# 4. 확인
flutter doctor
```

### 2단계: 프로젝트 다운로드

```bash
git clone https://github.com/kodeukwon/TestCSVrevie.git
cd TestCSVrevie
git checkout claude/cloud-account-differences-32ZVF
```

### 3단계: APK 빌드 (클릭 한 번!)

**Windows:**
```bash
# CMD나 PowerShell에서
.\build_android.sh
```

**macOS/Linux:**
```bash
# 터미널에서
./build_android.sh
```

빌드가 완료되면 **5-10분 소요**됩니다.

### 4단계: APK 파일 찾기

빌드 완료 후 다음 위치에 APK 파일이 생성됩니다:

```
build/app/outputs/flutter-apk/app-release.apk
```

### 5단계: 스마트폰에 설치

1. `app-release.apk` 파일을 스마트폰으로 전송
   - USB 케이블로 연결
   - 또는 이메일/클라우드로 전송

2. 스마트폰에서 APK 파일 열기

3. "알 수 없는 출처" 허용
   - 설정 → 보안 → "알 수 없는 앱 설치" 허용

4. 설치 완료! 🎉

---

## 💻 Windows PC에 설치

### 1단계: Flutter 설치

위의 "Android > 1단계" 참고

### 2단계: 프로젝트 다운로드

```bash
git clone https://github.com/kodeukwon/TestCSVrevie.git
cd TestCSVrevie
git checkout claude/cloud-account-differences-32ZVF
```

### 3단계: Windows 앱 빌드

```bash
build_windows.bat
```

**더블클릭만 해도 됩니다!**

### 4단계: 실행

빌드 완료 후:

```
build\windows\x64\runner\Release\blogger_app.exe
```

이 파일을 더블클릭하면 앱이 실행됩니다!

---

## 🌐 웹 버전 사용

**가장 쉬운 방법 - 설치 필요 없음!**

### 1단계: 웹 빌드

```bash
# macOS/Linux
./build_web.sh

# Windows
build_web.bat
```

### 2단계: 로컬 테스트

```bash
cd build/web
python3 -m http.server 8000
```

브라우저에서 http://localhost:8000 접속

### 3단계: 온라인 배포 (선택)

**GitHub Pages로 무료 호스팅:**

```bash
# build/web/ 폴더를 gh-pages 브랜치에 푸시
git checkout -b gh-pages
git add build/web/*
git commit -m "Deploy web app"
git push origin gh-pages
```

설정 → Pages → Source: gh-pages 선택

이제 `https://kodeukwon.github.io/TestCSVrevie` 에서 접속 가능!

---

## 🔧 문제 해결

### ❌ "flutter: command not found"

**원인:** Flutter가 PATH에 없음

**해결:**
```bash
# Windows (관리자 권한 CMD)
setx PATH "%PATH%;C:\flutter\bin"

# macOS/Linux (~/.bashrc 또는 ~/.zshrc에 추가)
export PATH="$PATH:$HOME/flutter/bin"
source ~/.bashrc
```

### ❌ Android 빌드 실패: "Android SDK not found"

**해결:**
```bash
# Android Studio 설치
https://developer.android.com/studio

# Flutter 설정
flutter doctor --android-licenses
```

### ❌ Google 로그인 실패

**원인:** Google Cloud Platform 설정 안 됨

**해결:** README.md의 "Google Cloud Platform 설정" 섹션 참고

---

## 🎯 빠른 시작 체크리스트

- [ ] Flutter 설치 완료
- [ ] 프로젝트 클론 완료
- [ ] Google Cloud 설정 (OAuth 클라이언트 ID)
- [ ] 빌드 스크립트 실행
- [ ] 앱 설치/실행

---

## 💡 추천 방법

**처음 사용하시는 분:**
→ **웹 버전**부터 시작하세요! (가장 쉬움)

**스마트폰에서 쓰고 싶으신 분:**
→ **Android APK** 빌드 (10분)

**PC 프로그램으로 쓰고 싶으신 분:**
→ **Windows 빌드** (10분)

---

## 📞 도움이 필요하신가요?

- GitHub Issues: https://github.com/kodeukwon/TestCSVrevie/issues
- Flutter 공식 문서: https://docs.flutter.dev

**성공하셨다면 GitHub에 ⭐ 눌러주세요!**
