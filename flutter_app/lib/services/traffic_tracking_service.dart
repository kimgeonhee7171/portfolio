import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'data_storage_service.dart';

/// 트래픽 추적 서비스
/// 사용자 행동 추적 및 분석 데이터 수집
class TrafficTrackingService {
  static final TrafficTrackingService instance = TrafficTrackingService._internal();
  TrafficTrackingService._internal();

  // Google Sheets Web App URL (트래픽 분석 전용)
  static const String trafficApiUrl = 
      'https://script.google.com/macros/s/AKfycbwcwe6bcn1zjnnO_A-XDoKgjIryJEVdBgFUWkmYdHmXKzYpo5GMb41mChTieMYzwsDw/exec';

  // 저장소 키
  static const String storageKey = 'bojeungjikimi_traffic_data';

  /// 서비스 초기화
  void init() {
    // 초기화 로직
  }

  /// 트래픽 데이터 전송
  /// [category] 이벤트 카테고리 (예: 'Funnel', 'ButtonClick')
  /// [action] 이벤트 액션 (예: 'Step_Complete', 'Click')
  /// [label] 이벤트 상세 레이블 (예: 'Step1_전세')
  Future<void> sendTrafficData(String category, String action, String label) async {
    final sessionId = _generateSessionId();
    
    final eventData = {
      'timestamp': DateTime.now().toIso8601String(),
      'sessionId': sessionId,
      'category': category,
      'action': action,
      'label': label,
      'userAgent': 'Flutter App', // 실제로는 디바이스 정보 사용
    };

    // 로컬 저장소에 저장
    await _saveToLocalStorage(eventData);

    // 서버로 전송 (도메인 환경에서만)
    if (_isDomainEnvironment()) {
      await _sendToApi(eventData);
    }
  }

  /// 버튼 클릭 추적
  Future<void> trackButtonClick(String category, String action, String label) async {
    await sendTrafficData(category, action, label);
  }

  /// 팝업 클릭 추적
  Future<void> trackPopupClick(String category, String action, String label) async {
    await trackButtonClick(category, action, label);
  }

  /// 세션 ID 생성
  String _generateSessionId() {
    // SharedPreferences에서 세션 ID 가져오기
    final prefs = DataStorageService.instance.prefs;
    String? sessionId = prefs.getString('scrollSessionId');
    
    if (sessionId == null || sessionId.isEmpty) {
      sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}_${_randomString(9)}';
      prefs.setString('scrollSessionId', sessionId);
    }
    
    return sessionId;
  }

  /// 랜덤 문자열 생성
  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (_) => chars[(DateTime.now().millisecondsSinceEpoch % chars.length)]).join();
  }

  /// 도메인 환경 확인
  bool _isDomainEnvironment() {
    // Flutter에서는 빌드 모드로 판단
    // const bool.fromEnvironment('dart.vm.product') 사용 가능
    return true; // 실제로는 환경 변수로 판단
  }

  /// 로컬 저장소에 저장
  Future<void> _saveToLocalStorage(Map<String, dynamic> eventData) async {
    try {
      final prefs = DataStorageService.instance.prefs;
      final existingData = prefs.getString(storageKey);
      final List<dynamic> data = existingData != null 
          ? jsonDecode(existingData) 
          : [];
      
      data.add(eventData);
      await prefs.setString(storageKey, jsonEncode(data));
    } catch (e) {
      print('로컬 저장소 저장 오류: $e');
    }
  }

  /// API로 전송
  Future<void> _sendToApi(Map<String, dynamic> eventData) async {
    try {
      // HTTP 패키지 사용 필요
      // final response = await http.post(
      //   Uri.parse(trafficApiUrl),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(eventData),
      // );
      print('📡 트래픽 데이터 전송 시도: $eventData');
    } catch (e) {
      print('❌ 트래픽 데이터 전송 오류: $e');
    }
  }

  /// 저장된 트래픽 데이터 가져오기
  Future<List<Map<String, dynamic>>> getTrafficData() async {
    try {
      final prefs = DataStorageService.instance.prefs;
      final data = prefs.getString(storageKey);
      if (data != null) {
        return List<Map<String, dynamic>>.from(jsonDecode(data));
      }
    } catch (e) {
      print('트래픽 데이터 불러오기 오류: $e');
    }
    return [];
  }

  /// 트래픽 데이터 삭제
  Future<bool> clearTrafficData() async {
    try {
      final prefs = DataStorageService.instance.prefs;
      await prefs.remove(storageKey);
      return true;
    } catch (e) {
      print('트래픽 데이터 삭제 오류: $e');
      return false;
    }
  }
}
