import 'traffic_tracking_service.dart';

/// 스크롤 추적 서비스
/// 섹션별 스크롤 진입 추적
class ScrollTrackingService {
  static final ScrollTrackingService instance = ScrollTrackingService._internal();
  ScrollTrackingService._internal();

  // 추적 대상 섹션 ID 목록
  static const List<String> trackedSections = [
    'hero',                    // 1단계: 인지단계 - Hero Section
    'problem-solution',        // 1단계: 인지단계 - Problem Awareness Section
    'curiosity',              // 2단계: 호기심단계 - How It Works Section
    'safety-score-section',   // 2.5단계: 안전도 점수 시스템
    'trust',                  // 3단계: 신뢰단계 - Trust Section
    'testimonials',           // 3단계: 신뢰단계 - Testimonials Section
    'faq-section',            // 3단계: 신뢰단계 - FAQ Section
    'urgency-section',        // 4단계: 욕구단계 - Urgency Section
    'purchase'                // 5단계: 구매단계 - Final CTA Section
  ];

  // 이미 추적된 섹션 목록
  final Set<String> _trackedSections = {};

  /// 서비스 초기화
  void init() {
    // 초기화 로직
  }

  /// 섹션 진입 추적
  /// [sectionId] 섹션 ID
  Future<void> trackSectionView(String sectionId) async {
    // 이미 추적된 섹션은 무시
    if (_trackedSections.contains(sectionId)) {
      return;
    }

    // 추적 대상 섹션인지 확인
    if (trackedSections.contains(sectionId)) {
      await TrafficTrackingService.instance.sendTrafficData(
        'Scroll',
        'Section_View',
        sectionId,
      );
      
      _trackedSections.add(sectionId);
      print('📊 스크롤 추적: Scroll - Section_View - $sectionId');
    }
  }

  /// 모든 섹션 추적 초기화
  void reset() {
    _trackedSections.clear();
  }
}
