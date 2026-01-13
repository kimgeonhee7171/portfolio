/// 트래픽 이벤트 모델
class TrafficEvent {
  final String timestamp;      // 타임스탬프
  final String sessionId;      // 세션 ID
  final String category;       // 이벤트 카테고리
  final String action;         // 이벤트 액션
  final String label;          // 이벤트 레이블
  final String userAgent;      // User Agent

  TrafficEvent({
    required this.timestamp,
    required this.sessionId,
    required this.category,
    required this.action,
    required this.label,
    required this.userAgent,
  });

  /// Map에서 생성
  factory TrafficEvent.fromMap(Map<String, dynamic> map) {
    return TrafficEvent(
      timestamp: map['timestamp'] ?? '',
      sessionId: map['sessionId'] ?? '',
      category: map['category'] ?? '',
      action: map['action'] ?? '',
      label: map['label'] ?? '',
      userAgent: map['userAgent'] ?? '',
    );
  }

  /// Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'sessionId': sessionId,
      'category': category,
      'action': action,
      'label': label,
      'userAgent': userAgent,
    };
  }
}
