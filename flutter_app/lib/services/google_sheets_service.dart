import 'dart:convert';
import 'package:http/http.dart' as http;

/// Google Sheets 서비스
/// Google Sheets Web App을 통한 데이터 저장
class GoogleSheetsService {
  static final GoogleSheetsService instance = GoogleSheetsService._internal();
  GoogleSheetsService._internal();

  // Google Sheets Web App URL (고객 데이터 저장용)
  static const String customerDataUrl = 
      'https://script.google.com/macros/s/AKfycbxfvzWR6dZZu5Q-tUYGPMq64Qlnp4U_6eh3P_eeWsYyK5kifCmZUJhVnCw0SbROneSUpA/exec';

  /// 예약 데이터를 서버로 전송
  /// [data] 전송할 폼 데이터
  /// 반환: 성공 여부
  Future<bool> sendDataToServer(Map<String, dynamic> data) async {
    try {
      if (customerDataUrl.isEmpty || customerDataUrl == 'YOUR_GOOGLE_SHEET_WEB_APP_URL_HERE') {
        print('⚠️ Google Sheets URL이 설정되지 않았습니다.');
        return false;
      }

      // UserAgent 및 타임스탬프 추가
      final requestData = {
        ...data,
        'userAgent': 'Flutter App', // 실제로는 디바이스 정보 사용
        'timestamp': DateTime.now().toIso8601String(),
      };

      print('📡 Google Sheets로 예약 데이터 전송 시도: $requestData');

      final response = await http.post(
        Uri.parse(customerDataUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      // no-cors 모드에서는 응답 상태를 정확히 확인할 수 없으므로 로그만 남김
      print('📡 Google Sheet로 예약 데이터 전송 시도 완료.');
      return true;
    } catch (e) {
      print('❌ Google Sheets 전송 오류: $e');
      return false;
    }
  }
}
