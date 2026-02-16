# 🏋️ FitMate — AI 기반 스마트 다이어트 & 건강관리 앱

<p align="center">
  <img src="assets/icons/app_icon.png" alt="FitMate Logo" width="120" height="120" style="border-radius: 24px;" />
</p>

<p align="center">
  <strong>AI 코치와 함께하는 맞춤형 다이어트 파트너</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.41-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.11-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Riverpod-2.6-7C4DFF?style=for-the-badge" />
  <img src="https://img.shields.io/badge/OpenAI-GPT--4o--mini-412991?style=for-the-badge&logo=openai&logoColor=white" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android-2DD4A8?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Tests-81%20passed-brightgreen?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Dart%20Files-38-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Lines-7.6k-blue?style=for-the-badge" />
</p>

---

## 📋 목차

- [프로젝트 소개](#-프로젝트-소개)
- [주요 기능](#-주요-기능)
- [기술 스택](#-기술-스택)
- [프로젝트 구조](#-프로젝트-구조)
- [시작하기](#-시작하기)
- [환경 설정](#-환경-설정)
- [아키텍처](#-아키텍처)
- [테스트](#-테스트)
- [포트폴리오 어필 포인트](#-포트폴리오-어필-포인트)

---

## 📖 프로젝트 소개

**FitMate**는 AI 기반 맞춤형 다이어트 코치 앱입니다. 칼로리·영양소 관리, 체중 추적, AI 식단 분석, 건강 코칭까지 하나의 앱에서 제공합니다.

> **🔑 핵심 가치**: API 키 없이도 내장 DB와 로컬 폴백으로 완전히 동작하며, API 연결 시 3개 외부 서비스와 통합됩니다.

---

## ✨ 주요 기능

### 📊 대시보드

- 칼로리 섭취 현황 — 탄수화물·단백질·지방 영양소 비율 링 차트 시각화
- 체중 변화 추이 차트 (fl_chart 기반 인터랙티브 라인 그래프)
- 수분 섭취·걸음 수·수면 시간 트래킹 카드
- 날짜별 식단 필터링 및 빠른 기록 액션

### 🍽️ 식단 관리 — 다중 소스 검색

| 소스                  | 설명                                      |
| --------------------- | ----------------------------------------- |
| 📦 **내장 DB**        | 80개 이상의 한국 음식 데이터, 즉시 응답   |
| 🏛️ **공공데이터포털** | 식약처 식품영양성분DB정보 API 실시간 연동 |
| 🤖 **AI 분석**        | OpenAI GPT-4o-mini 자연어 기반 영양 분석  |
| 📷 **바코드 검색**    | Open Food Facts API 연동                  |

- 아침 / 점심 / 저녁 / 간식별 식단 기록
- 영양소 자동 계산 및 Swipe-to-delete

### 🤖 AI 코치 (챗봇)

- OpenAI GPT 기반 실시간 건강 코칭
- 사용자 건강 데이터 컨텍스트 자동 연동 (칼로리, 체중, 수분 등)
- 429/5xx 에러 시 자동 재시도 (Exponential Backoff, 최대 3회)
- API 실패 시 로컬 폴백 응답 — 오프라인에서도 동작
- 추천 질문 Suggestion Chips

### 👤 프로필 & 설정

- BMI 자동 계산 및 분류 (저체중/정상/과체중/비만)
- 체중 감량 목표 대비 진행률 시각화
- API 연결 상태 확인 대시보드
- 데이터 내보내기 (JSON) / 전체 초기화
- 다크 모드 / 알림 설정

---

## 🛠 기술 스택

| 구분                 | 기술                                                      |
| -------------------- | --------------------------------------------------------- |
| **Framework**        | Flutter 3.41 / Dart 3.11                                  |
| **State Management** | Riverpod 2.6 (StateNotifier + 파생 프로바이더)            |
| **Navigation**       | GoRouter (선언적 라우팅)                                  |
| **Networking**       | Dio (RetryInterceptor, 지수 백오프 자동 재시도)           |
| **Local Storage**    | Hive (NoSQL, 데이터 영속화)                               |
| **AI / ML**          | OpenAI GPT-4o-mini (챗봇 + 음식 영양 분석)                |
| **외부 API**         | 식약처 식품영양성분DB정보, Open Food Facts                |
| **환경 설정**        | flutter_dotenv (.env 기반 API 키 관리)                    |
| **Charts**           | fl_chart (라인/링 차트)                                   |
| **UI**               | percent_indicator, Google Fonts, shimmer, flutter_animate |
| **Icons**            | flutter_lucide                                            |
| **Testing**          | flutter_test — 81개 단위·위젯 테스트                      |
| **Architecture**     | Feature-first + Service Layer                             |

---

## 📁 프로젝트 구조

```
lib/                                    # 38개 Dart 파일, 7,600+ 라인
├── main.dart                           # 앱 진입점 (Hive/dotenv/splash 초기화)
│
├── core/
│   ├── constants/
│   │   └── api_constants.dart          # API URL, 프롬프트, 설정값
│   ├── theme/
│   │   ├── app_colors.dart             # 디자인 시스템 컬러 (라이트/다크)
│   │   └── app_theme.dart              # Material3 테마 정의
│   ├── router/
│   │   └── app_router.dart             # GoRouter 라우팅 설정
│   └── utils/
│       ├── date_utils.dart             # 날짜 포맷 유틸리티
│       └── number_utils.dart           # 숫자 포맷 유틸리티
│
├── data/
│   ├── models/                         # 도메인 모델 (5개)
│   │   ├── user_profile.dart           # 사용자 프로필 (BMI 계산)
│   │   ├── weight_record.dart          # 체중 기록
│   │   ├── meal_record.dart            # 식단 기록 (영양소 포함)
│   │   ├── daily_health.dart           # 일일 건강 데이터
│   │   └── chat_message.dart           # 채팅 메시지
│   ├── services/                       # 서비스 계층 (4개)
│   │   ├── api_service.dart            # Dio HTTP 클라이언트 + RetryInterceptor
│   │   ├── ai_chat_service.dart        # OpenAI GPT 챗봇 서비스
│   │   ├── food_api_service.dart       # 다중 소스 음식 검색 서비스
│   │   └── local_storage_service.dart  # Hive 영속화 서비스
│   └── repositories/
│       └── dummy_data.dart             # 로컬 음식 DB (80+)
│
├── providers/
│   └── app_providers.dart              # Riverpod 프로바이더 (20+개)
│
├── features/
│   ├── dashboard/                      # 📊 대시보드
│   │   ├── dashboard_screen.dart
│   │   └── widgets/
│   │       ├── calorie_ring_card.dart  # 칼로리 링 차트
│   │       ├── health_metrics_card.dart # 건강 지표 카드
│   │       ├── quick_actions_card.dart # 빠른 기록 액션
│   │       ├── today_summary_card.dart # 오늘 요약
│   │       └── weight_chart_card.dart  # 체중 추이 차트
│   ├── meal/                           # 🍽️ 식단 관리
│   │   ├── meal_screen.dart
│   │   ├── add_meal_screen.dart
│   │   └── widgets/
│   │       ├── meal_type_section.dart  # 식사 유형별 섹션
│   │       └── nutrition_summary_bar.dart # 영양소 요약 바
│   ├── chat/                           # 🤖 AI 챗봇
│   │   ├── chat_screen.dart
│   │   └── widgets/
│   │       ├── chat_bubble.dart        # 채팅 말풍선
│   │       ├── suggestion_chips.dart   # 추천 질문 칩
│   │       └── typing_indicator.dart   # 타이핑 인디케이터
│   └── profile/                        # 👤 프로필/설정
│       ├── profile_screen.dart
│       └── widgets/
│           ├── edit_profile_sheet.dart  # 프로필 편집 바텀시트
│           ├── goal_settings_sheet.dart # 목표 설정 바텀시트
│           ├── profile_stat_card.dart   # 프로필 통계 카드
│           └── settings_section.dart   # 설정 섹션
│
└── shared/
    └── widgets/
        └── main_scaffold.dart          # 하단 네비게이션 공통 레이아웃

test/                                   # 81개 테스트
├── models/                             # 모델 단위 테스트 (4개 파일, 21개 테스트)
├── services/                           # 서비스 단위 테스트 (2개 파일, 36개 테스트)
├── providers/                          # 프로바이더 테스트 (1개 파일, 20개 테스트)
└── widget_test.dart                    # 위젯 통합 테스트 (4개 테스트)
```

---

## 🚀 시작하기

### 사전 요구사항

- Flutter SDK 3.41 이상
- Dart SDK 3.11 이상
- iOS: Xcode 16+ / Android: SDK 21+

### 설치 및 실행

```bash
# 1. 저장소 클론
git clone https://github.com/your-username/fitmate.git
cd fitmate

# 2. 의존성 설치
flutter pub get

# 3. 환경 변수 설정 (선택사항 — 없어도 앱 동작)
cp .env.example .env
# .env 파일에 API 키 입력

# 4. 앱 실행
flutter run

# 5. 테스트 실행
flutter test

# 6. 정적 분석
flutter analyze
```

---

## 🔑 환경 설정

```bash
# .env 파일 예시
OPENAI_API_KEY=your_openai_api_key_here
FOOD_API_KEY=your_data_go_kr_api_key_here
```

| API                    | 용도                     | 발급처                                                           |
| ---------------------- | ------------------------ | ---------------------------------------------------------------- |
| **OpenAI API**         | AI 챗봇 + 음식 영양 분석 | [platform.openai.com](https://platform.openai.com)               |
| **식품영양성분DB API** | 공공 식품 DB 검색        | [data.go.kr](https://www.data.go.kr) — 식약처 식품영양성분DB정보 |

> 💡 **API 키 없이도 앱은 완전히 동작합니다.** 내장 DB(80+ 음식)와 로컬 폴백 응답이 제공됩니다.

---

## 🏗 아키텍처

### Feature-first + Service Layer

```
┌─────────────────────────────────────────────────┐
│                    UI Layer                      │
│  features/ (Screen + Widgets)                    │
│  shared/widgets/ (공통 컴포넌트)                  │
├─────────────────────────────────────────────────┤
│               State Management                   │
│  providers/ (Riverpod StateNotifier + Derived)    │
├─────────────────────────────────────────────────┤
│                Service Layer                     │
│  data/services/ (API, AI, Storage)               │
├─────────────────────────────────────────────────┤
│                 Data Layer                       │
│  data/models/ (도메인 모델)                       │
│  data/repositories/ (로컬 DB)                    │
├─────────────────────────────────────────────────┤
│                  Core Layer                      │
│  core/ (Theme, Router, Constants, Utils)         │
└─────────────────────────────────────────────────┘
```

### 다중 소스 음식 검색 파이프라인

```
사용자 검색어
  │
  ├─ 1️⃣ 로컬 DB (80+ 음식, 즉시 응답)
  │
  ├─ 2️⃣ 공공데이터포털 API (식약처 식품영양정보)
  │     └─ 캐시 확인 → API 호출 → XML 파싱 → 중복 제거
  │
  ├─ 3️⃣ OpenAI GPT 분석 (결과 부족 시 자동 트리거)
  │     └─ 자연어 프롬프트 → JSON 파싱 → 메모리 캐시
  │
  └─ 결과 병합 & 중복 제거 → UI 표시 (출처별 섹션 구분)
```

### 에러 처리 전략

| 전략                     | 설명                                                            |
| ------------------------ | --------------------------------------------------------------- |
| **RetryInterceptor**     | 429(Rate Limit), 5xx 에러 시 지수 백오프로 최대 3회 자동 재시도 |
| **Graceful Degradation** | AI 서비스 불가 시 로컬 폴백 응답 (앱이 항상 동작)               |
| **메모리 캐시**          | AI/공공 API 결과를 캐시하여 중복 API 호출 방지                  |
| **입력 디바운스**        | 검색 입력 300ms 디바운스로 불필요한 API 호출 최소화             |

### 데이터 영속화

- Hive NoSQL 기반 — 모든 StateNotifier가 자동 저장/복원
- 앱 재시작 시 사용자 데이터 유지
- 데이터 내보내기(JSON) 및 전체 초기화 기능 제공

---

## 🧪 테스트

```bash
flutter test        # 전체 81개 테스트 실행
flutter analyze     # 정적 분석 (0 issues)
```

| 영역           | 파일 수 | 테스트 수 | 커버리지                                      |
| -------------- | ------- | --------- | --------------------------------------------- |
| **모델**       | 4       | 21        | JSON 직렬화/역직렬화, 팩토리, 기본값, 복사    |
| **서비스**     | 2       | 36        | 음식 검색/캐시/출처/파싱, AI 폴백/컨텍스트    |
| **프로바이더** | 1       | 20        | StateNotifier CRUD, 파생 프로바이더 계산      |
| **위젯**       | 1       | 4         | 대시보드 로드, 네비게이션, 칼로리 카드, Chips |
| **합계**       | **8**   | **81**    | **All passed ✅**                             |
