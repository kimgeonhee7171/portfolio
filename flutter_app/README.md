# 보증지킴이 Flutter 앱

## 프로젝트 구조

이 Flutter 앱은 웹 버전의 JavaScript 로직을 기반으로 설계되었습니다.

### 디렉토리 구조

```
lib/
├── main.dart                 # 앱 진입점 및 초기화
├── models/                   # 데이터 모델
│   ├── modal_data.dart      # 멀티스텝 모달 데이터 모델
│   ├── fraud_stats.dart     # 전세사기 통계 모델
│   └── traffic_event.dart   # 트래픽 이벤트 모델
├── services/                 # 비즈니스 로직 서비스
│   ├── router_service.dart           # 라우팅 관리
│   ├── traffic_tracking_service.dart # 트래픽 추적
│   ├── scroll_tracking_service.dart  # 스크롤 추적
│   ├── data_storage_service.dart     # 로컬 데이터 저장
│   ├── email_service.dart            # 이메일 전송 (EmailJS)
│   ├── google_sheets_service.dart    # Google Sheets 연동
│   ├── fraud_stats_service.dart      # 전세사기 통계 관리
│   ├── validation_service.dart       # 입력 검증
│   └── formatting_service.dart       # 포맷팅 유틸리티
└── screens/                  # 화면 위젯
    └── home_screen.dart     # 홈 화면
```

## 주요 서비스 설명

### 1. RouterService
- SPA 라우팅 관리
- 섹션 기반 네비게이션
- 페이지 전환 추적

### 2. TrafficTrackingService
- 사용자 행동 추적
- 세션 ID 생성 및 관리
- Google Sheets로 트래픽 데이터 전송
- 로컬 저장소 백업

### 3. ScrollTrackingService
- 섹션별 스크롤 진입 추적
- Intersection Observer 패턴 구현
- 중복 추적 방지

### 4. DataStorageService
- SharedPreferences 래퍼
- 로컬 데이터 저장 및 관리

### 5. EmailService
- EmailJS를 통한 이메일 전송
- 관리자 및 고객 알림 이메일

### 6. GoogleSheetsService
- Google Sheets Web App 연동
- 예약 데이터 저장

### 7. FraudStatsService
- 지역별 전세사기 통계 데이터 관리
- 위험도 색상 매핑

### 8. ValidationService
- 입력 데이터 검증
- 에러 메시지 관리

### 9. FormattingService
- 전화번호 포맷팅 (010-XXXX-XXXX)
- 금액 한국어 포맷팅 (억, 만원 등)
- 숫자 콤마 추가

## 주요 기능

### 멀티스텝 모달 (7단계)
1. 거래 유형 선택 (전세/월세/반전세)
2. 현재 상황 선택
3. 상세 상황 선택 (조건부)
4. 금액 입력
5. 계약 기간 선택
6. 주소 입력
7. 본인 정보 입력 및 통계 표시

### 트래픽 추적
- 버튼 클릭 추적
- 섹션 뷰 추적
- 퍼널 단계별 추적
- Meta Pixel 이벤트 (웹 전용)

### 데이터 저장
- 로컬 저장소 (SharedPreferences)
- Google Sheets 연동
- 이메일 알림

## 필요한 패키지

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
  http: ^1.1.0
```

## 초기화 순서

1. `main()` 함수에서 `WidgetsFlutterBinding.ensureInitialized()` 호출
2. 서비스 초기화 (`_initializeServices()`)
3. `MaterialApp` 생성 및 라우팅 설정

## 참고사항

- JavaScript 버전의 로직을 Flutter/Dart로 포팅
- 웹 전용 기능 (Meta Pixel 등)은 제외
- 네이티브 앱 환경에 맞게 최적화 필요
