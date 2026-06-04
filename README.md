# 🌐 A-GNRI — Auto-scheduled Global News Report Integrator

> 전세계 통합 뉴스 & 경제 리포트를 매일 자동 생성하여 알림으로 전달하는 Android 앱

---

## 📋 목차

1. [프로젝트 개요](#프로젝트-개요)
2. [기술 스택](#기술-스택)
3. [사전 준비 (API 키 발급)](#사전-준비-api-키-발급)
4. [설치법](#설치법)
   - [백엔드 (FastAPI 파이프라인)](#백엔드-fastapi-파이프라인)
   - [프론트엔드 (Flutter 앱)](#프론트엔드-flutter-앱)
   - [데이터베이스 (PostgreSQL)](#데이터베이스-postgresql)
5. [실행법](#실행법)
6. [사용법 가이드](#사용법-가이드)
7. [프로젝트 구조](#프로젝트-구조)
8. [문의](#문의)

---

## 프로젝트 개요

**A-GNRI**는 전세계 15개 주요국의 뉴스를 GDP 비율에 따라 자동 수집하고,  
Gemini API로 번역·요약, Imagen3 API로 삽화 이미지 생성, 감성 분석을 통해  
매일 하나의 통합 리포트를 생성하여 사용자에게 알림으로 전달합니다.

### 주요 기능

- 📰 **전세계 뉴스 자동 수집** — 15개국, 450개 기사, GDP 가중치 적용
- 🤖 **AI 요약 및 번역** — Gemini API 기반 MMR 요약, 한국어 번역
- 🖼️ **뉴스 이미지 자동 생성** — Imagen3 API 기반 삽화 3장
- 📊 **감성 분석 및 시장 동향** — 밝음 / 보통 / 어두움 3단계
- 📈 **Google 인기 검색어** — Pytrends 기반 실시간 트렌드
- 🔔 **자동 푸시 알림** — 사용자 지정 시간에 하루 1회 발송
- 📂 **과거 리포트 조회** — 날짜별 아카이브

---

## 기술 스택

| 구분 | 기술 |
|------|------|
| 프론트엔드 | Flutter (Dart), Android Studio |
| 백엔드 | FastAPI (Python) |
| 데이터베이스 | PostgreSQL |
| AI / API | Gemini API, Imagen3 API, NewsAPI, Pytrends |
| 버전 관리 | Git / GitHub |

---

## 사전 준비 (API 키 발급)

아래 API 키들이 필요합니다. 각 링크에서 발급 후 `.env` 파일에 등록합니다.

| API | 발급 링크 | 비고 |
|-----|-----------|------|
| NewsAPI | https://newsapi.org | 무료 플랜 가능 |
| Gemini API | https://aistudio.google.com | Google 계정 필요 |
| Imagen3 API | https://cloud.google.com/vertex-ai | GCP 프로젝트 필요 |

> **Pytrends**는 별도 키 없이 사용 가능합니다.

---

## 설치법

### 공통 — 저장소 클론

```bash
git clone https://github.com/your-org/A-GNRI-Auto-scheduled-Global-News-Report-Integrator.git
cd A-GNRI-Auto-scheduled-Global-News-Report-Integrator
```

---

### 백엔드 (Python)

#### 1. Python 환경 세팅

```bash
cd BackEnd
python -m venv venv

# Windows
venv\Scripts\activate

# Mac / Linux
source venv/bin/activate
```

#### 2. 패키지 설치

```bash
pip install -r requirements.txt
```

> `requirements.txt` 가 없을 경우 아래 명령어로 필요 패키지를 직접 설치합니다.

```bash
pip install fastapi uvicorn psycopg2-binary python-dotenv google-generativeai pytrends newsapi-python
```

#### 3. 환경 변수 설정

`BackEnd/` 폴더 안에 `.env` 파일을 생성하고 아래 내용을 입력합니다.

```env
NEWS_API_KEY=your_newsapi_key
GEMINI_API_KEY=your_gemini_api_key
IMAGEN_API_KEY=your_imagen3_api_key
DB_HOST=localhost
DB_PORT=5432
DB_NAME=gnri_db
DB_USER=your_db_user
DB_PASSWORD=your_db_password
```

---

### 프론트엔드 (Flutter 앱)

#### 1. Flutter SDK 설치

Flutter 공식 사이트에서 SDK를 다운로드합니다.  
👉 https://docs.flutter.dev/get-started/install/windows/android

설치 후 환경 변수에 `C:\flutter\bin` 경로를 추가합니다.

#### 2. 설치 확인

```bash
flutter --version
```

아래와 같이 버전 정보가 출력되면 정상입니다.

```
Flutter 3.x.x • channel stable
Dart 3.x.x
```

#### 3. 패키지 설치

```bash
cd frontend
flutter pub get
```

#### 4. API 서버 주소 설정

`frontend/lib/core/constants.dart` 파일에서 서버 주소를 설정합니다.

```dart
const String baseUrl = 'http://localhost:8000'; // 로컬 개발 시
```

---

### 데이터베이스 (PostgreSQL)

#### 1. PostgreSQL 설치

👉 https://www.postgresql.org/download/windows/

설치 완료 후 pgAdmin 또는 터미널에서 DB를 생성합니다.

#### 2. DB 및 테이블 생성

```sql
-- DB 생성
CREATE DATABASE gnri_db;

-- 테이블 생성
\c gnri_db

CREATE TABLE news (
    id SERIAL PRIMARY KEY,
    title TEXT,
    content TEXT,
    source TEXT,
    country_code VARCHAR(10),
    category VARCHAR(50),
    collected_at DATE
);

CREATE TABLE reports (
    id SERIAL PRIMARY KEY,
    report_date DATE UNIQUE,
    summary_ko TEXT,
    sentiment VARCHAR(10),
    market_trend TEXT,
    theme_keyword TEXT,
    image_url_1 TEXT,
    image_url_2 TEXT,
    image_url_3 TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE trends (
    id SERIAL PRIMARY KEY,
    keyword TEXT,
    rank INTEGER,
    google_url TEXT,
    collected_at DATE
);

CREATE TABLE settings (
    id SERIAL PRIMARY KEY,
    alarm_time VARCHAR(5),
    sound_enabled BOOLEAN DEFAULT TRUE,
    vibration_enabled BOOLEAN DEFAULT TRUE
);
```

---

## 실행법

### 1. 백엔드 서버 실행

```bash
cd BackEnd
python MAIN.py
```

서버 실행 후 브라우저에서 API 문서를 확인할 수 있습니다.  
👉 http://localhost:8000/docs

### 2. 파이프라인 수동 실행 (테스트용)

각 모듈을 개별 실행하여 테스트할 수 있습니다.

```bash
# 뉴스 수집 테스트
python NEWSAPI.py

# DB 테이블 생성 (최초 1회)
python DATABASEBUILD.py

# 전체 파이프라인 실행
python MAIN.py
```

### 3. Flutter 앱 실행

안드로이드 에뮬레이터 또는 실제 기기를 연결한 후 실행합니다.

```bash
cd frontend
flutter run
```

웹 브라우저로 확인하려면:

```bash
flutter run -d chrome
```

---

## 사용법 가이드

### 🔔 알림 설정

1. 앱 하단 탭에서 **설정** 탭 선택
2. **일일 리포트 알림 시간** 입력란을 탭하여 원하는 시간 선택
3. 알림음 / 진동 토글로 ON·OFF 설정
4. **알림 테스트** 버튼으로 정상 동작 확인

### 📰 오늘의 리포트 확인

1. 앱 실행 또는 알림 클릭
2. **1면** — 오늘의 주요 뉴스 요약 + AI 생성 삽화 확인
3. **2면** 탭 — 세계 감성 분위기, 시장 동향, 추천 테마 확인
4. **3면** 탭 — Google 실시간 인기 검색어 확인 (탭 시 브라우저 연결)

### 📂 과거 리포트 조회

1. 하단 탭에서 **기록** 탭 선택
2. 날짜별 리포트 목록에서 원하는 날짜 선택
3. 해당 날짜의 리포트 상세 내용 확인

### 🌙 다크모드 전환

- 상단 앱바 우측 달 모양 아이콘 클릭으로 라이트 / 다크 모드 전환

---

## 프로젝트 구조

```
A-GNRI/
├── frontend/                   # Flutter 앱 (프론트엔드)
│   └── lib/
│       ├── main.dart
│       ├── core/               # 공통 상수, 테마, 유틸
│       ├── models/             # 데이터 모델
│       ├── providers/          # 상태 관리
│       ├── services/           # API 통신, 알림, 저장
│       ├── screens/            # 화면 (1면·2면·3면·기록·설정)
│       └── widgets/            # 공통 UI 위젯
│
└── BackEnd/                    # 백엔드 (Python)
    ├── MAIN.py                 # 진입점, REST API 엔드포인트
    ├── NEWSAPI.py              # NewsAPI 뉴스 수집
    ├── PYTRENDSAPI.py          # Pytrends 인기 검색어 수집
    ├── GEMINIAPI.py            # Gemini API 번역·요약·감성분석
    ├── IMAGEN3API.py           # Imagen3 API 이미지 생성
    ├── STATISTICS.py           # MMR 분석, 감성 분석
    ├── DATACRAWLING.py         # 데이터 크롤링
    ├── DATASAVE.py             # DB 저장 처리
    ├── DATACALL.py             # DB 조회 처리
    ├── DATABASEBUILD.py        # DB 테이블 생성
    ├── DataHandling.py         # 데이터 가공·처리
    ├── ALLOT.py                # GDP 비율 기반 기사 수 배분
    └── ETCS.py                 # 기타 유틸리티
```

---

## 문의

> 대진대학교 AI빅데이터학과 | 오픈소스소프트웨어응용  
> 팀명: 2조 AI디어  
> GitHub: https://github.com/your-org/A-GNRI-Auto-scheduled-Global-News-Report-Integrator
