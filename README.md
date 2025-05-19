# 📱 Reminder App

간단한 Flutter 기반 리마인더 앱입니다.  
사용자는 할 일 목록을 추가하고 삭제하며, 로컬 저장 기능을 통해 일정 관리를 할 수 있습니다.

---

## 🚀 시작하기 전에 (Flutter & Dart 플러그인 설치)

이 프로젝트를 실행하려면 다음 환경이 준비되어 있어야 합니다:

- Flutter SDK
- Dart 플러그인 (IDE용)
- Flutter 플러인 (IDE용)

---

### 🔍 1. 설치 확인

터미널에서 아래 명령어를 입력하여 Flutter와 Dart가 설치되어 있는지 확인하세요:

```bash
flutter doctor
```

출력 결과에 다음 항목이 모두 ✓ 상태인지 확인합니다:

[✓] Flutter

[✓] Dart



### 🛠 2. IDE 플러그인 설치 (Android Studio / IntelliJ / VS Code)
✅ Android Studio 기준
Android Studio 실행

1. Settings 또는 Preferences 열기 (Ctrl + Alt + S or Cmd + ,)

2. 왼쪽 메뉴에서 Plugins 클릭

3. Marketplace 탭에서 아래 플러그인을 검색 후 설치:
- Flutter
- Dart (Flutter 설치 시 자동 설치되는 경우도 있음)

4. 설치 후 IDE 재시작

✅ VS Code 기준
1. Extensions (확장 프로그램) 탭 클릭

2. Flutter, Dart 검색 및 설치


### ⚙️ 프로젝트 실행 방법
``` bash
git clone https://github.com/andrewchoi1735/reminder_app.git
cd reminder_app
flutter pub get
flutter run
```

### 📦 주요 기능
1. 할 일 추가 및 삭제

2. 로컬 저장소를 통한 데이터 보존

3. 직관적인 UI (Jetpack Compose 스타일)

4. 추후 알림 기능 추가 예정

### 🧑‍💻 개발 환경
1. Flutter SDK

2. Dart

3. Android Studio or VS Code

4. Room, Provider, Hive 등은 필요 시 적용
