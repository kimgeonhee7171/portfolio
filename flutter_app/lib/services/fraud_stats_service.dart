import 'dart:convert';
import 'data_storage_service.dart';

/// 전세사기 통계 서비스
/// 지역별 전세사기 통계 데이터 관리
class FraudStatsService {
  static final FraudStatsService instance = FraudStatsService._internal();
  FraudStatsService._internal();

  // 전세사기 통계 데이터
  static const Map<String, Map<String, dynamic>> fraudStatsData = {
    '서울특별시 강남구': {'count': 12, 'amount': '3억 2천만원', 'risk': '보통'},
    '서울특별시 서초구': {'count': 8, 'amount': '2억 1천만원', 'risk': '낮음'},
    '서울특별시 송파구': {'count': 15, 'amount': '4억 5천만원', 'risk': '높음'},
    '서울특별시 강동구': {'count': 6, 'amount': '1억 8천만원', 'risk': '낮음'},
    '서울특별시 마포구': {'count': 9, 'amount': '2억 7천만원', 'risk': '보통'},
    '서울특별시 영등포구': {'count': 11, 'amount': '3억 1천만원', 'risk': '보통'},
    '서울특별시 구로구': {'count': 7, 'amount': '2억 2천만원', 'risk': '낮음'},
    '서울특별시 금천구': {'count': 4, 'amount': '1억 2천만원', 'risk': '낮음'},
    '서울특별시 관악구': {'count': 13, 'amount': '3억 8천만원', 'risk': '높음'},
    '서울특별시 동작구': {'count': 8, 'amount': '2억 3천만원', 'risk': '보통'},
    '서울특별시 서대문구': {'count': 5, 'amount': '1억 5천만원', 'risk': '낮음'},
    '서울특별시 은평구': {'count': 6, 'amount': '1억 9천만원', 'risk': '낮음'},
    '서울특별시 종로구': {'count': 3, 'amount': '9천만원', 'risk': '낮음'},
    '서울특별시 중구': {'count': 4, 'amount': '1억 1천만원', 'risk': '낮음'},
    '서울특별시 용산구': {'count': 7, 'amount': '2억 4천만원', 'risk': '보통'},
    '서울특별시 성동구': {'count': 5, 'amount': '1억 6천만원', 'risk': '낮음'},
    '서울특별시 광진구': {'count': 6, 'amount': '1억 8천만원', 'risk': '낮음'},
    '서울특별시 중랑구': {'count': 8, 'amount': '2억 5천만원', 'risk': '보통'},
    '서울특별시 성북구': {'count': 4, 'amount': '1억 3천만원', 'risk': '낮음'},
    '서울특별시 강북구': {'count': 3, 'amount': '8천만원', 'risk': '낮음'},
    '서울특별시 도봉구': {'count': 2, 'amount': '6천만원', 'risk': '낮음'},
    '서울특별시 노원구': {'count': 5, 'amount': '1억 4천만원', 'risk': '낮음'},
    '서울특별시 양천구': {'count': 7, 'amount': '2억 1천만원', 'risk': '보통'},
    '서울특별시 강서구': {'count': 6, 'amount': '1억 7천만원', 'risk': '낮음'},
    '경기도 성남시': {'count': 9, 'amount': '2억 6천만원', 'risk': '보통'},
    '경기도 수원시': {'count': 11, 'amount': '3억 2천만원', 'risk': '보통'},
    '경기도 고양시': {'count': 7, 'amount': '2억 1천만원', 'risk': '보통'},
    '경기도 용인시': {'count': 8, 'amount': '2억 4천만원', 'risk': '보통'},
    '경기도 부천시': {'count': 6, 'amount': '1억 8천만원', 'risk': '낮음'},
    '경기도 안양시': {'count': 5, 'amount': '1억 5천만원', 'risk': '낮음'},
    '경기도 안산시': {'count': 4, 'amount': '1억 2천만원', 'risk': '낮음'},
    '경기도 의정부시': {'count': 3, 'amount': '9천만원', 'risk': '낮음'},
    '경기도 평택시': {'count': 2, 'amount': '6천만원', 'risk': '낮음'},
    '경기도 시흥시': {'count': 3, 'amount': '8천만원', 'risk': '낮음'},
    '경기도 김포시': {'count': 4, 'amount': '1억 1천만원', 'risk': '낮음'},
    '경기도 광주시': {'count': 2, 'amount': '5천만원', 'risk': '낮음'},
    '경기도 이천시': {'count': 1, 'amount': '3천만원', 'risk': '낮음'},
    '경기도 양주시': {'count': 1, 'amount': '2천만원', 'risk': '낮음'},
    '경기도 오산시': {'count': 2, 'amount': '6천만원', 'risk': '낮음'},
    '경기도 의왕시': {'count': 1, 'amount': '3천만원', 'risk': '낮음'},
    '경기도 하남시': {'count': 3, 'amount': '8천만원', 'risk': '낮음'},
    '경기도 여주시': {'count': 1, 'amount': '2천만원', 'risk': '낮음'},
    '경기도 양평군': {'count': 0, 'amount': '0원', 'risk': '매우 낮음'},
    '경기도 연천군': {'count': 0, 'amount': '0원', 'risk': '매우 낮음'},
    '경기도 가평군': {'count': 0, 'amount': '0원', 'risk': '매우 낮음'},
    '인천시 연수구': {'count': 5, 'amount': '1억 4천만원', 'risk': '낮음'},
    '인천시 남동구': {'count': 6, 'amount': '1억 7천만원', 'risk': '낮음'},
    '인천시 부평구': {'count': 4, 'amount': '1억 1천만원', 'risk': '낮음'},
    '인천시 계양구': {'count': 3, 'amount': '8천만원', 'risk': '낮음'},
    '인천시 서구': {'count': 2, 'amount': '5천만원', 'risk': '낮음'},
    '인천시 미추홀구': {'count': 3, 'amount': '8천만원', 'risk': '낮음'},
    '인천시 동구': {'count': 1, 'amount': '3천만원', 'risk': '낮음'},
    '인천시 중구': {'count': 1, 'amount': '2천만원', 'risk': '낮음'},
    '인천시 강화군': {'count': 0, 'amount': '0원', 'risk': '매우 낮음'},
    '인천시 옹진군': {'count': 0, 'amount': '0원', 'risk': '매우 낮음'},
    '전국': {'count': 2847, 'amount': '1,247억 3천만원', 'risk': '보통'},
  };

  /// 서비스 초기화
  Future<void> init() async {
    // 필요시 초기화 로직 추가
  }

  /// 지역별 통계 가져오기
  /// [cityDistrict] 시/도, 구/군 (예: '서울특별시 강남구')
  /// 반환: 통계 데이터 또는 null
  Map<String, dynamic>? getFraudStats(String cityDistrict) {
    return fraudStatsData[cityDistrict];
  }

  /// 전국 통계 가져오기
  Map<String, dynamic> getNationalStats() {
    return fraudStatsData['전국']!;
  }

  /// 위험도에 따른 색상 가져오기
  /// [risk] 위험도 ('매우 낮음', '낮음', '보통', '높음')
  /// 반환: 색상 코드
  String getRiskColor(String risk) {
    switch (risk) {
      case '매우 낮음':
        return '#10b981'; // 초록색
      case '낮음':
        return '#3b82f6'; // 파란색
      case '보통':
        return '#f59e0b'; // 주황색
      case '높음':
        return '#ef4444'; // 빨간색
      default:
        return '#f59e0b'; // 기본값
    }
  }
}
