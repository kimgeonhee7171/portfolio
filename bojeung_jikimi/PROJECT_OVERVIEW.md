# PROJECT_OVERVIEW.md

> **용도:** 다른 AI에게 프로젝트 맥락(Context)을 주입하기 위한 상세 명세서  
> **대상 앱:** 보증지킴이 (전세 안전 진단 Prop-tech 앱)

---

## 1. 프로젝트 개요

| 항목 | 내용 |
|------|------|
| **앱 이름** | 보증지킴이 (bojeung_jikimi) |
| **앱 설명** | 전세 계약의 안전도를 진단하고, 깡통전세 위험을 예방하는 Prop-tech 앱 |
| **버전** | 1.0.0+1 |
| **SDK** | Dart ^3.10.7, Flutter |
| **테마** | Material 3, Pretendard 폰트 |

### 주요 기술 스택

| 분류 | 패키지 | 용도 |
|------|--------|------|
| **백엔드/DB** | firebase_core, cloud_firestore | 앱 초기화, 전세 꿀팁(Tips) 실시간 저장·조회 |
| **지도** | flutter_map, latlong2 | 리포트 지도 (OpenStreetMap 타일, 마커 표시) |
| **주소 검색** | kpostal | 도로명 주소 검색 (우편번호 API) |
| **공유** | share_plus | 진단 결과 공유 |
| **UI** | dotted_border | 등기부등본 업로드 카드 점선 테두리 |
| **아이콘** | cupertino_icons | iOS 스타일 아이콘 |

### 브랜드 컬러 (AppColors)

- **primary:** #1A237E (Navy) – 신뢰의 네이비
- **accent:** #00C853 (Green) – 안전의 그린
- **background:** #F8FAFC

---

## 2. 폴더 구조 (Directory Structure)

```
lib/
├── main.dart                          # 앱 진입점, Firebase 초기화
├── constants/
│   └── app_colors.dart                # 브랜드 컬러 상수
├── models/
│   ├── report.dart                    # 전세 진단 리포트 모델
│   ├── column_data.dart               # 전문가 칼럼 데이터 + ColumnRepository
│   └── tip_model.dart                 # Firestore Tips 모델
├── repositories/
│   └── report_repository.dart         # 리포트 더미 데이터 저장소
├── services/
│   └── firestore_service.dart         # Firestore CRUD, Tips 스트림
├── utils/
│   └── safety_calculator.dart         # 7-Layer S-GSE 안전도 계산
├── widgets/
│   └── safety_gauge_chart.dart        # 게이지 차트 (바늘 애니메이션)
└── screens/
    ├── main/
    │   └── main_screen.dart           # 하단 탭 네비게이션 (홈/진단/계약서/내정보)
    ├── home/
    │   ├── home_screen.dart           # 홈 대시보드
    │   ├── checklist_screen.dart      # 계약 체크리스트
    │   ├── news_screen.dart           # 부동산 뉴스
    │   └── column_detail_screen.dart  # 전문가 칼럼·꿀팁 상세 (좋아요 Firestore)
    ├── diagnosis/
    │   └── diagnosis_screen.dart      # 7단계 진단 플로우 + OCR 시뮬레이션
    ├── contract/
    │   └── contract_review_screen.dart # 계약서 검토 (AI 스캔 시뮬레이션)
    ├── report/
    │   ├── report_list_screen.dart    # 리포트 보관함 목록
    │   ├── report_map_screen.dart     # 리포트 지도 (flutter_map)
    │   └── report_result_screen.dart  # 진단 결과 상세 (게이지·7대 항목)
    ├── profile/
    │   ├── profile_screen.dart        # 내 정보 (마이페이지)
    │   ├── faq_screen.dart            # 자주 묻는 질문
    │   └── notice_screen.dart         # 공지사항
    └── settings/
        └── settings_screen.dart       # 안심 케어 설정

assets/
└── logo.png
```

---

## 3. 파일별 상세 기능 명세 (File Description)

### `lib/main.dart`

- **역할:** 앱 진입점. Firebase 초기화 후 `MainScreen` 실행.
- **핵심 로직:**
  - `main()`: `WidgetsFlutterBinding.ensureInitialized()`, `Firebase.initializeApp()`
  - `MyApp`: MaterialApp, ThemeData (ColorScheme, Pretendard 폰트), `home: MainScreen`

---

### `lib/constants/app_colors.dart`

- **역할:** 전역 브랜드 색상 상수 정의.
- **핵심 로직:**
  - `AppColors.primary`, `accent`, `background`, `textDark`, `textLight`, `border`

---

### `lib/utils/safety_calculator.dart`

- **역할:** **7-Layer S-GSE (Safe-Guard Scoring Engine)** 핵심 계산 유틸.
- **핵심 로직:**
  - `SafetyCalculator.calculate()`: 기본 위험도 계산  
    - `(전세금 + 근저당) ÷ 매매가 × 100` → ratio  
    - ratio ≥80: 위험(DANGER), ≥70: 주의(CAUTION), else: 안전(SAFE)
  - `SafetyCalculator.calculateSafety()`: 추가 위험 요소 반영 (우선순위)  
    - 1순위: `isViolatedArchitecture` → 무조건 위험  
    - 2순위: `!isTaxArrears` → 최소 주의  
    - 3순위: 기존 ratio 기반 등급
  - `SafetyCalculator.calculateScore()`: 100점 만점 점수 반환 (60/75/85/95)
  - `SafetyResult`: grade, ratio, color, message, description

---

### `lib/models/report.dart`

- **역할:** 전세 진단 리포트 데이터 모델.
- **핵심 로직:**
  - `Report`: address, detailAddress, date, score, grade, contractType, deposit, monthlyRent, marketPrice, priorCredit, isViolatedArchitecture, isTaxArrears, lat, lng
  - `fromJson()`, `toJson()`: Firestore/API 연동용 직렬화

---

### `lib/models/column_data.dart`

- **역할:** 전문가 법률 칼럼 더미 데이터.
- **핵심 로직:**
  - `ColumnData`: id, title, author, date, icon, content
  - `ColumnRepository.columns`: 3개 칼럼 (특약사항, HUG 보증보험, 등기부등본 을구)

---

### `lib/models/tip_model.dart`

- **역할:** Firestore `tips` 컬렉션 데이터 모델.
- **핵심 로직:**
  - `Tip`: id, title, content, order, likeCount, dislikeCount
  - `fromFirestore()`, `toMap()`: Firestore 문서 ↔ 객체 변환

---

### `lib/repositories/report_repository.dart`

- **역할:** 리포트 더미 데이터 저장소 (현재 Firestore 미연동).
- **핵심 로직:**
  - `ReportRepository.reports`: 3개 더미 리포트  
    - 송파구(안전), 강남구(주의), 성남시(위험)

---

### `lib/services/firestore_service.dart`

- **역할:** Firestore `tips` 컬렉션 CRUD 및 스트림.
- **핵심 로직:**
  - `getTips()`: tips 조회 (order 오름차순)
  - `getTipsStream()`: 실시간 업데이트 스트림
  - `addTip()`: Tip 추가
  - `toggleLike()`, `toggleDislike()`: like_count/dislike_count 증감 (동시성 처리)

---

### `lib/widgets/safety_gauge_chart.dart`

- **역할:** 안전도 점수를 반원 게이지로 시각화.
- **핵심 로직:**
  - `SafetyGaugeChart`: score(0~100), gradeColor, size
  - 반원 아크: 0~70(빨강), 70~80(노랑), 80~100(초록)
  - `_GaugePainter`: CustomPainter로 아크·바늘 그리기
  - 바늘 애니메이션: TweenAnimationBuilder, 약 1.2초 easeOutCubic

---

### `lib/screens/main/main_screen.dart`

- **역할:** 하단 탭 네비게이션 메인 프레임.
- **핵심 로직:**
  - `MainScreen` (StatefulWidget): `_selectedIndex`로 4개 탭 전환
  - 탭: 홈, 진단하기, 계약서 검토, 내 정보
  - AppBar: '보증지킴이' + BETA 배지 (OrangeAccent)
  - `IndexedStack`로 탭별 화면 유지, `_navigateToDiagnosis()` 콜백

---

### `lib/screens/home/home_screen.dart`

- **역할:** 홈 대시보드 (안심 대시보드).
- **핵심 로직:**
  - `_buildWelcomeHeader()`: 환영 문구
  - `_buildMainActionCard()`: '3초 진단하기' CTA → `onNavigateToDiagnosis`
  - `_buildChecklistSummary()`: 체크리스트 요약 → `ChecklistScreen` 이동
  - `_buildNewsTicker()`: 부동산 뉴스 → `NewsScreen` 이동
  - `_buildLegalColumnList()`: 전문가 칼럼 → `ColumnDetailScreen` 이동
  - `_buildFirestoreTipsSection()`: Firestore Tips 스트림 → `ColumnDetailScreen` (좋아요 연동)

---

### `lib/screens/home/checklist_screen.dart`

- **역할:** 계약 준비 체크리스트 (방문 시/계약 시/잔금 시).
- **핵심 로직:**
  - `ChecklistItem`: title, isChecked
  - `_checklistData`: 카테고리별 체크 항목
  - `_progressPercentage`, `_checkedCount`, `_totalCount`: 진행률 계산

---

### `lib/screens/home/news_screen.dart`

- **역할:** 부동산 뉴스 목록.
- **핵심 로직:**
  - `_newsData`: 더미 뉴스 (제목, 출처, 날짜, 아이콘)

---

### `lib/screens/home/column_detail_screen.dart`

- **역할:** 전문가 칼럼 또는 Firestore Tips 상세 + 좋아요/아쉬워요.
- **핵심 로직:**
  - `ColumnDetailScreen`: title, author, date, content, documentId(optional)
  - `_toggleLike()`, `_toggleDislike()`: FirestoreService 호출, 낙관적 업데이트
  - documentId가 있을 때만 Firestore 반영

---

### `lib/screens/diagnosis/diagnosis_screen.dart` ⭐ 핵심

- **역할:** 7단계 진단 플로우 + **등기부등본 OCR 시뮬레이션** + 7-Layer 위험요소 입력.
- **핵심 로직:**
  - `_currentStep` (0~6): Step 1~7 진행
  - **Step 1:** 계약유형 (월세/전세/반전세/매매)
  - **Step 2:** 현재 상황 (계약 예정/거주 중/계약 만료 전)
  - **Step 3:** 보증금, 월세, 매매가, 선순위 채권 입력  
    - **등기부등본 업로드 (DottedBorder):** `_simulateOcrExtraction()`  
      - 1.5초 로딩 다이얼로그 → 매매가 3억, 근저당 1.2억 테스트 데이터 할당  
      - *실제 OCR AI 연동은 미구현, 시뮬레이션*
    - **Step 2. 추가 위험 요소:**  
      - `_isViolatedArchitecture`: 위반건축물 여부  
      - `_isTaxArrears`: 국세/지방세 완납 확인 여부
  - **Step 4:** 계약 기간 (1년/2년/기타)
  - **Step 5:** 주소 검색 (`kpostal`), 상세 주소
  - **Step 6:** 임대인 이름, 이름, 전화번호 (Dual-Check)
  - **Step 7:** `_SGSEAnalysisScreen` → 분석 완료 시 `ReportResultScreen`으로 이동
  - `_calculateSafetyScore()`: SafetyCalculator로 점수 계산
  - `_resetAllData()`: 결과 화면 복귀 시 초기화

---

### `lib/screens/contract/contract_review_screen.dart`

- **역할:** 계약서 AI 검토 시뮬레이션 (업로드 → 분석 → 하이라이트 결과).
- **핵심 로직:**
  - `_state`: 0(초기), 1(분석 중), 2(결과)
  - `_showUploadOptions()`: Modal Bottom Sheet (사진 촬영/갤러리/파일)
  - `_startScan()`: 2초 로딩 다이얼로그 → 결과 화면 전환
  - 하이라이트 애니메이션 (`_fadeAnimation`)
  - "다른 계약서 검토하기" → `_resetScan()`

---

### `lib/screens/report/report_list_screen.dart`

- **역할:** 리포트 보관함 목록.
- **핵심 로직:**
  - `ReportRepository.reports` 기반 ListView
  - 점수별 색상(초록/주황/빨강), 탭 시 `ReportResultScreen` 이동
  - AppBar: 지도 아이콘 → `ReportMapScreen` 이동

---

### `lib/screens/report/report_map_screen.dart`

- **역할:** 리포트 지도 (OpenStreetMap + 마커).
- **핵심 로직:**
  - `flutter_map`, `TileLayer` (OpenStreetMap), `MarkerLayer`
  - `ReportRepository.reports`의 lat/lng로 마커 표시
  - `_markerColorByScore()`: 점수별 색상 (Green/Amber/Red)
  - 마커 탭 → Bottom Sheet → `ReportResultScreen` 이동

---

### `lib/screens/report/report_result_screen.dart` ⭐ 핵심

- **역할:** 진단 결과 상세 (게이지, 7대 안전 진단, AI 추천 특약, 공유).
- **핵심 로직:**
  - `ReportResultScreen`: contractType, deposit, monthlyRent, marketPrice, priorCredit, address, detailAddress, isViolatedArchitecture, isTaxArrears
  - `_safetyResult`: SafetyCalculator.calculateSafety() 호출
  - `_displayScore`: SafetyCalculator.calculateScore()
  - `_buildGradeShieldCard()`: **SafetyGaugeChart** + 중앙 점수 + 등급 배지
  - `_buildEngineBadge()`: S-GSE 배지
  - `_buildPropertyInfo()`: 분석 대상 정보
  - `_buildSafetyCalculationCard()`: 위험도 공식, ratio, 메시지
  - `_buildDetailAnalysis()`: **7대 안전 진단 결과** (A. 자산 가치, B. 임대인 신용, C. 건물·권리)  
    - 통과: 초록 체크(Icons.check_circle), 주의: 노란 느낌표(Icons.warning_amber_rounded)  
    - 4번(세금), 6번(위반건축물): isTaxArrears, isViolatedArchitecture 반영
  - `getRecommendedTerms()`: 등급별 필수 특약 추천 (green/yellow/red)
  - `_buildShareButton()`, `_shareResult()`: share_plus로 결과 공유
  - `_buildDisclaimerFooter()`: 면책 조항 (회색 박스)
  - `_buildDataSourceCaption()`: 데이터 출처 (법원 등기소 & 국토부 Simulated)

---

### `lib/screens/profile/profile_screen.dart`

- **역할:** 내 정보 (마이페이지).
- **핵심 로직:**
  - `_buildProfileSection()`: 프로필 이미지, 이름, 안전 등급 배지
  - `_buildMenuList()`: 리포트 보관함, 지도, 자산 보호 설정, 공지사항, FAQ → 각 화면 Navigator.push

---

### `lib/screens/settings/settings_screen.dart`

- **역할:** 안심 케어 (사후 관리) 설정.
- **핵심 로직:**
  - `_isNotificationEnabled`: 실시간 등기부등본 변동 알림 토글
  - `_buildNotificationCard()`: SwitchListTile
  - `_buildMonitoringItemsCard()`: 모니터링 항목 리스트

---

### `lib/screens/profile/faq_screen.dart`

- **역할:** 자주 묻는 질문 (Accordion 스타일).
- **핵심 로직:**
  - `_buildFaqItem()`: 질문 클릭 시 답변 펼침/접힘

---

### `lib/screens/profile/notice_screen.dart`

- **역할:** 공지사항 목록.
- **핵심 로직:**
  - `_buildNoticeItem()`: 제목, 날짜, 내용, isNew 배지

---

## 4. 데이터 모델 및 상태 관리

### 주요 데이터 모델

| 모델 | 위치 | 용도 |
|------|------|------|
| **Report** | models/report.dart | 전세 진단 리포트 (주소, 점수, 등급, 위험요소 등) |
| **SafetyResult** | utils/safety_calculator.dart | 계산 결과 (grade, ratio, color, message, description) |
| **Tip** | models/tip_model.dart | Firestore tips (제목, 내용, 좋아요/아쉬워요) |
| **ColumnData** | models/column_data.dart | 전문가 칼럼 (더미) |
| **_AnalysisDetail** | report_result_screen.dart | 7대 진단 항목 (title, result, status, detail) |

### 상태 관리 방식

- **전역 상태 라이브러리:** Provider, GetX, Riverpod **미사용**
- **로컬 상태:** `StatefulWidget` + `setState()` 만 사용
- **데이터 소스:**
  - **ReportRepository:** 정적 리스트 (더미)
  - **Firestore:** `FirestoreService`로 tips 스트림 구독, `StreamBuilder` 또는 `FutureBuilder` 사용
  - **진단 플로우:** `DiagnosisScreen` 내 변수들 (`_deposit`, `_marketPrice` 등) → 결과 화면에 인자로 전달

### 화면 간 데이터 전달

- **DiagnosisScreen → ReportResultScreen:** 생성자 인자로 전달 (deposit, marketPrice, isViolatedArchitecture 등)
- **ReportListScreen / ReportMapScreen → ReportResultScreen:** `Report` 객체에서 필드 추출해 전달

---

## 5. 핵심 알고리즘 요약 (7-Layer S-GSE)

```
1. 기본 위험도: (전세금 + 근저당) ÷ 매매가 × 100 = ratio (%)
2. 등급: ratio ≥80 → 위험, ≥70 → 주의, else → 안전
3. 우선순위 오버라이드:
   - 위반건축물 있음 → 무조건 위험
   - 세금 미확인 → 최소 주의
4. 점수: 위험 60점, 주의 75점, 양호 85점, 안전 95점
```

---

## 6. 화면 흐름 (네비게이션)

```
MainScreen (탭)
├── HomeScreen
│   ├── ChecklistScreen
│   ├── NewsScreen
│   ├── ColumnDetailScreen (칼럼/Tips)
│   └── (3초 진단 CTA) → DiagnosisScreen 탭으로 전환
├── DiagnosisScreen
│   └── Step 7 완료 → ReportResultScreen
├── ContractReviewScreen
└── ProfileScreen
    ├── ReportListScreen
    │   ├── ReportMapScreen
    │   └── ReportResultScreen (카드/마커 탭)
    ├── SettingsScreen
    ├── NoticeScreen
    └── FaqScreen
```

---

*본 문서는 프로젝트 구조를 AI가 빠르게 이해할 수 있도록 작성되었습니다. 수정·추가 시 이 문서를 함께 갱신하는 것을 권장합니다.*
