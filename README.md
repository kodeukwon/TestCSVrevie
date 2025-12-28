# 📱 Blogger 포스팅 앱

Google Blogger와 연동하여 모바일과 데스크톱에서 블로그 포스트를 작성하고 게시할 수 있는 크로스 플랫폼 앱입니다.

## ✨ 주요 기능

- ✅ **Google 계정 로그인** - OAuth2 인증
- ✅ **멀티 플랫폼** - Android, iOS, Windows, macOS, Linux 지원
- ✅ **블로그 관리** - 여러 블로그 선택 가능
- ✅ **포스트 작성** - HTML 에디터 지원
- ✅ **이미지 업로드** - 갤러리 선택 및 카메라 촬영
- ✅ **라벨(태그) 관리** - 포스트 분류
- ✅ **임시저장** - 초안 저장 기능
- ✅ **포스트 게시** - 바로 게시 또는 예약 게시

## 🛠 기술 스택

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **API**: Google Blogger API v3
- **인증**: Google Sign-In (OAuth2)
- **상태관리**: Provider
- **에디터**: HTML Editor Enhanced

## 📋 사전 요구사항

### 1. Flutter 설치

Flutter SDK가 설치되어 있어야 합니다.

```bash
# Flutter 버전 확인
flutter --version

# Flutter 3.0 이상이어야 합니다
```

[Flutter 설치 가이드](https://docs.flutter.dev/get-started/install)

### 2. Google Cloud Platform 설정

Google Blogger API를 사용하려면 GCP에서 프로젝트를 설정해야 합니다.

#### 2.1. Google Cloud Console 설정

1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 새 프로젝트 생성
3. **API 및 서비스 > 라이브러리**로 이동
4. "Blogger API v3" 검색 후 활성화

#### 2.2. OAuth 2.0 클라이언트 ID 생성

1. **API 및 서비스 > 사용자 인증 정보**로 이동
2. **+ 사용자 인증 정보 만들기 > OAuth 클라이언트 ID** 선택

**Android용:**
- 애플리케이션 유형: Android
- 패키지 이름: `com.example.blogger_app`
- SHA-1 서명 인증서 지문:
  ```bash
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```

**iOS용:**
- 애플리케이션 유형: iOS
- 번들 ID: `com.example.bloggerApp`

**웹용 (데스크톱):**
- 애플리케이션 유형: 웹 애플리케이션
- 승인된 리디렉션 URI: `http://localhost`

#### 2.3. 클라이언트 ID 설정

생성된 클라이언트 ID를 `lib/services/auth_service.dart`에 추가합니다:

```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com', // 웹 클라이언트 ID
  scopes: [
    'https://www.googleapis.com/auth/blogger',
    'https://www.googleapis.com/auth/blogger.readonly',
  ],
);
```

## 🚀 설치 및 실행

### 1. 저장소 클론

```bash
git clone https://github.com/YOUR_USERNAME/TestCSVrevie.git
cd TestCSVrevie
```

### 2. 의존성 설치

```bash
flutter pub get
```

### 3. 플랫폼별 실행

#### 📱 Android

```bash
# USB 디버깅 연결 또는 에뮬레이터 실행 후
flutter run -d android
```

#### 📱 iOS

```bash
# 시뮬레이터 실행 후 (macOS만 가능)
flutter run -d ios
```

#### 💻 Windows

```bash
flutter run -d windows
```

#### 💻 macOS

```bash
flutter run -d macos
```

#### 💻 Linux

```bash
flutter run -d linux
```

### 4. 빌드

#### Android APK

```bash
flutter build apk --release
```

#### iOS (macOS 필요)

```bash
flutter build ios --release
```

#### Windows

```bash
flutter build windows --release
```

#### macOS

```bash
flutter build macos --release
```

## 📁 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점
├── screens/
│   ├── login_screen.dart        # 로그인 화면
│   ├── home_screen.dart         # 홈/블로그 선택 화면
│   └── post_editor_screen.dart  # 포스트 작성 화면
└── services/
    ├── auth_service.dart        # Google 인증 서비스
    └── blogger_service.dart     # Blogger API 서비스
```

## 🎨 사용 방법

### 1. 로그인
- 앱 실행 후 "Google 계정으로 로그인" 버튼 클릭
- Google 계정 선택 및 권한 승인

### 2. 블로그 선택
- 여러 블로그가 있는 경우 상단에서 선택

### 3. 포스트 작성
- "새 포스트" 버튼 클릭
- 제목, 본문 작성
- 이미지 추가 (갤러리 또는 카메라)
- 라벨(태그) 추가
- 임시저장 또는 바로 게시

## 🔧 문제 해결

### Google 로그인 실패

**증상**: "로그인에 실패했습니다" 메시지

**해결책**:
1. GCP에서 Blogger API가 활성화되었는지 확인
2. OAuth 클라이언트 ID가 올바르게 설정되었는지 확인
3. SHA-1 지문이 정확한지 확인 (Android)
4. 번들 ID가 일치하는지 확인 (iOS)

### 이미지 업로드 오류

**증상**: 이미지 선택 후 오류 발생

**해결책**:
1. AndroidManifest.xml에 권한이 있는지 확인
2. Info.plist에 권한 설명이 있는지 확인
3. 런타임 권한 승인 확인

### 빌드 오류

```bash
# 캐시 삭제 후 재빌드
flutter clean
flutter pub get
flutter run
```

## 🔐 보안 주의사항

⚠️ **중요**:
- `google-services.json` (Android) 및 `GoogleService-Info.plist` (iOS) 파일을 Git에 커밋하지 마세요
- `.gitignore`에 추가되어 있는지 확인하세요

## 📝 TODO

- [ ] 포스트 수정 기능
- [ ] 포스트 삭제 기능
- [ ] 이미지 호스팅 서비스 연동 (Imgur 등)
- [ ] 마크다운 에디터 옵션
- [ ] 다크 모드 지원
- [ ] 오프라인 임시저장
- [ ] 예약 게시 기능

## 📄 라이센스

MIT License

## 👨‍💻 개발자

Created with ❤️ by kodeukwon

## 🤝 기여

버그 리포트, 기능 제안, Pull Request를 환영합니다!

---

**참고 링크**:
- [Google Blogger API 문서](https://developers.google.com/blogger)
- [Flutter 공식 문서](https://flutter.dev)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
