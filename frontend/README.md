# ⭐ A-GNRI — Auto-scheduled Global News Report Integrator

---

## 📁 프로젝트 폴더 구조
```
A-GNRI/
├── frontend/                        # Flutter 앱 (프론트엔드)
│   ├── lib/
│   │   ├── main.dart                # 앱 시작점 (Firebase 초기화)
│   │   ├── firebase_options.dart    # FlutterFire CLI 자동 생성
│   │   ├── core/                    # 앱 전체 공통 요소
│   │   │   ├── constants/           # API URL, GDP 가중치, 색상값
│   │   │   ├── theme/               # 다크/라이트 모드 테마
│   │   │   └── utils/               # 날짜 포맷, 유틸리티 함수
│   │   ├── data/                    # 데이터 계층
│   │   │   ├── models/              # 데이터 모델 (Report, News 등)
│   │   │   ├── providers/           # 상태 관리
│   │   │   └── repositories/        # 데이터 가공 저장소
│   │   ├── services/
│   │   │   ├── notification_service.dart  # 배너 알림, 진동, 소리
│   │   │   └── firebase_service.dart      # Firestore 데이터 조회
│   │   └── views/                   # UI 화면
│   │       ├── home/                # 1면: 오늘의 리포트
│   │       ├── insight/             # 2면: 시장 동향
│   │       ├── trend/               # 3면: 인기 검색어
│   │       ├── archive/             # 과거 기록 조회
│   │       └── widgets/             # 공통 재사용 위젯
│   └── assets/
│       ├── icons/                   # 앱 아이콘
│       └── images/                  # 기본 이미지 리소스
│
└── pipeline/                        # FastAPI 파이프라인 (백엔드)
    ├── collectors/                  # 뉴스 수집
    ├── processors/                  # 번역·요약·감성분석
    ├── generators/                  # 이미지·워드클라우드 생성
    ├── services/                    # Firebase 업로드, 트렌드
    ├── main.py
    ├── scheduler.py
    └── config.py
```

---

## ⚙️ 설치 및 실행 방법

### 사전 준비
- Flutter 3.x 이상
- Android Studio 또는 VS Code
- Firebase 프로젝트 (Firestore + FCM 활성화)

### 1. 저장소 클론
```bash
git clone https://github.com/kimsjbusiness/A-GNRI-Auto-scheduled-Global-News-Report-Integrator.git
```

### 2. 본인 브랜치로 이동
```bash
git checkout 본인브랜치명
```

### 3. Flutter 패키지 설치
```bash
cd frontend
flutter pub get
```

### 4. Firebase 연결
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 5. 앱 실행
```bash
flutter run
```


---
## 📁 프로젝트 폴더 구조 수정본
```
A-GNRI/
├─ frontend/
│  └─ lib/
│     ├─ main.dart
│     │  # 앱 실행 시작 파일
│     │  # - 앱 초기화 후 runApp() 실행
│
│     ├─ app.dart
│     │  # 앱 전체 설정 파일
│     │  # - MaterialApp 구성
│     │  # - 테마(light/dark) 적용
│     │  # - 초기 화면 및 네비게이션 설정
│
│     ├─ core/
│     │  # 앱 전체에서 공통으로 사용하는 설정/유틸
│
│     │  ├─ constants.dart
│     │  │  # API 주소, 앱 상수 등 하드코딩 방지용 값 정의
│
│     │  ├─ theme.dart
│     │  │  # 색상, 텍스트 스타일, ThemeData 정의
│
│     │  └─ utils.dart
│     │     # 공통 함수 모음
│     │     # - 날짜 포맷 변환
│     │     # - 감성값 변환 (밝음/보통/어두움)
│
│     ├─ models/
│     │  # 데이터 구조 정의 (백엔드 ↔ 프론트 연결)
│
│     │  ├─ report_model.dart
│     │  │  # 하루 리포트 전체 데이터 (1면, 2면, 3면 포함)
│
│     │  ├─ archive_model.dart
│     │  │  # 과거 리포트 리스트용 데이터
│
│     │  └─ settings_model.dart
│     │     # 사용자 설정 데이터 (알림 시간, 테마 등)
│
│     ├─ providers/
│     │  # 상태관리 (Provider 사용)
│
│     │  ├─ report_provider.dart
│     │  │  # 오늘 리포트 상태 관리
│     │  │  # - 로딩 / 성공 / 에러 상태 포함
│
│     │  ├─ archive_provider.dart
│     │  │  # 과거 리포트 목록 및 상세 상태 관리
│
│     │  └─ settings_provider.dart
│     │     # 사용자 설정 상태 관리
│
│     ├─ services/
│     │  # 외부 기능 처리 (서버, 알림, 저장소)
│
│     │  ├─ api_service.dart
│     │  │  # 서버 API 통신 (GET, POST 등)
│
│     │  ├─ notification_service.dart
│     │  │  # 알림 기능 처리 (로컬 알림)
│
│     │  ├─ storage_service.dart
│     │  │  # 로컬 저장 (SharedPreferences)
│
│     │  └─ mock_service.dart
│     │     # 백엔드 없이 개발할 때 사용하는 더미 데이터
│
│     ├─ screens/
│     │  # 실제 화면(UI)
│
│     │  ├─ home_screen.dart
│     │  │  # 메인 홈 화면 (1면)
│     │  │  # - 뉴스 카드 표시
│     │
│     │  ├─ insight_screen.dart
│     │  │  # 분석 화면 (2면)
│     │  │  # - 시장 분위기, 테마, 감성 분석
│     │
│     │  ├─ trend_screen.dart
│     │  │  # 트렌드 화면 (3면)
│     │  │  # - 실시간 인기 검색어, 인사이트
│     │
│     │  ├─ archive_screen.dart
│     │  │  # 과거 리포트 목록 화면
│     │
│     │  └─ settings_screen.dart
│     │     # 설정 화면
│     │     # - 알림 시간, 진동/소리, 테마 설정
│
│     ├─ widgets/
│     │  # 여러 화면에서 재사용하는 UI 컴포넌트
│
│     │  ├─ bottom_nav_bar.dart
│     │  │  # 하단 네비게이션 바
│     │  │  # (홈 / 분석 / 트렌드 / 기록 / 설정)
│
│     │  ├─ sentiment_chip.dart
│     │  │  # 감성 상태 표시 UI (밝음 / 보통 / 어두움)
│
│     │  ├─ section_card.dart
│     │  │  # 공통 카드 UI (박스 형태 레이아웃)
│
│     │  └─ state_views.dart
│     │     # 상태 UI 모음
│     │     # - 로딩 화면
│     │     # - 데이터 없음 화면
│     │     # - 에러 화면
│
│     └─ assets/
│        ├─ icons/
│        │  # 앱 아이콘 및 UI 아이콘
│        └─ images/
│           # 이미지, placeholder 등
│
└─ backend/ (예정)
   # PostgreSQL + Docker 기반 서버 (추후 구현)
```
---
