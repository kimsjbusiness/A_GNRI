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
