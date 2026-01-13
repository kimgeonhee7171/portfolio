/// 전세사기 통계 모델
class FraudStats {
  final int count;           // 사기 건수
  final String amount;       // 사기 금액
  final String risk;         // 위험도 (매우 낮음, 낮음, 보통, 높음)

  FraudStats({
    required this.count,
    required this.amount,
    required this.risk,
  });

  /// Map에서 생성
  factory FraudStats.fromMap(Map<String, dynamic> map) {
    return FraudStats(
      count: map['count'] ?? 0,
      amount: map['amount'] ?? '0원',
      risk: map['risk'] ?? '보통',
    );
  }

  /// Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'count': count,
      'amount': amount,
      'risk': risk,
    };
  }
}
