# 📥 APK 다운로드 및 설치 가이드

## 🎯 방법 1: GitHub Actions에서 자동 빌드된 APK 다운로드

### 1단계: GitHub Actions 페이지로 이동

1. 이 저장소의 **Actions** 탭 클릭
2. 왼쪽에서 "Android APK 자동 빌드" 워크플로우 선택
3. 가장 최근의 성공한 빌드(녹색 체크마크) 클릭

### 2단계: APK 다운로드

1. 페이지 아래 **Artifacts** 섹션 찾기
2. `blogger-app-apk` 클릭하여 다운로드
3. ZIP 파일 압축 해제

### 3단계: 스마트폰에 설치

1. APK 파일을 스마트폰으로 전송
   - USB 케이블로 연결하거나
   - 이메일/클라우드로 전송

2. 스마트폰에서 APK 파일 열기

3. "알 수 없는 출처" 허용
   - 설정 → 보안 → "알 수 없는 앱 설치" 허용

4. 설치 버튼 클릭

5. 완료! 🎉

---

## 🚀 방법 2: GitHub Release에서 다운로드

### Release 만들기 (개발자용)

```bash
# 1. 태그 생성
git tag v1.0.0

# 2. 태그 푸시
git push origin v1.0.0
```

태그를 푸시하면 자동으로:
- APK 빌드
- GitHub Release 생성
- APK 파일 업로드

### Release에서 다운로드 (사용자용)

1. 저장소의 **Releases** 페이지로 이동
2. 최신 릴리스 선택
3. **Assets** 섹션에서 APK 다운로드
4. 위의 "3단계: 스마트폰에 설치" 진행

---

## 📱 빠른 다운로드 링크

자동 빌드가 완료되면 여기서 다운로드:

**GitHub Actions (매 푸시마다 빌드):**
```
https://github.com/kodeukwon/TestCSVrevie/actions
```

**GitHub Releases (정식 버전):**
```
https://github.com/kodeukwon/TestCSVrevie/releases
```

---

## ⚡ 지금 바로 다운로드하기

### 현재 상태 확인

1. **이 저장소의 Actions 탭 확인**
   - 녹색 체크마크: 빌드 성공 ✅
   - 노란색 점: 빌드 진행 중 ⏳
   - 빨간색 X: 빌드 실패 ❌

2. **빌드가 성공했다면:**
   - Actions → 최근 워크플로우 → Artifacts → `blogger-app-apk` 다운로드

3. **Release가 있다면:**
   - Releases → 최신 버전 → Assets → APK 다운로드

---

## 🔧 문제 해결

### ❓ Artifacts가 안 보여요

**원인:** 워크플로우가 아직 실행되지 않았거나 실패함

**해결:**
1. Actions 탭에서 워크플로우 상태 확인
2. 실패했다면 에러 로그 확인
3. 또는 아래 명령으로 수동 실행:
   ```bash
   # GitHub 저장소 페이지 → Actions → 워크플로우 선택 → "Run workflow"
   ```

### ❓ APK 설치가 안 돼요

**원인:** "알 수 없는 출처" 차단

**해결:**
1. **설정** → **보안** 또는 **개인정보보호**
2. **알 수 없는 앱 설치** 또는 **알 수 없는 출처**
3. APK를 설치하려는 앱(파일 관리자, Chrome 등) 허용
4. 다시 APK 설치 시도

### ❓ "앱이 설치되지 않았습니다" 오류

**원인:**
- 저장공간 부족
- 이전 버전과 서명이 다름

**해결:**
1. 이전 버전 완전히 삭제
2. 저장공간 확보
3. 다시 설치

---

## 📊 버전 히스토리

| 버전 | 날짜 | 다운로드 |
|------|------|----------|
| v1.0.0 | 2025-12-28 | [Actions](https://github.com/kodeukwon/TestCSVrevie/actions) |

---

## 🎯 최초 설치 체크리스트

- [ ] GitHub Actions에서 빌드 성공 확인
- [ ] APK 파일 다운로드
- [ ] 스마트폰으로 파일 전송
- [ ] "알 수 없는 출처" 허용
- [ ] APK 설치
- [ ] 앱 실행 및 Google 로그인
- [ ] 블로그 포스트 작성 테스트

---

## 📞 도움이 필요하신가요?

GitHub Issues에서 질문하세요:
```
https://github.com/kodeukwon/TestCSVrevie/issues
```

**성공적으로 설치하셨다면 ⭐ Star를 눌러주세요!**
