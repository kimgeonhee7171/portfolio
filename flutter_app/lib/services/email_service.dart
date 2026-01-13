import 'dart:convert';
import 'package:http/http.dart' as http;

/// 이메일 서비스
/// EmailJS를 통한 이메일 전송
class EmailService {
  static final EmailService instance = EmailService._internal();
  EmailService._internal();

  // EmailJS 설정
  static const String serviceId = 'service_1bvu13q';
  static const String templateId = 'template_ocdkmfj';
  static const String publicKey = 'IlLEKruddDnX0TLdG';
  static const String adminEmail = 'bojeungjikimi@gmail.com';

  /// 이메일 알림 전송
  /// [templateParams] 이메일 템플릿 파라미터
  /// 반환: {adminSuccess: bool, customerSuccess: bool}
  Future<Map<String, bool>> sendEmailNotifications(Map<String, dynamic> templateParams) async {
    try {
      // 관리자 이메일 전송
      final adminFuture = _sendEmail(
        templateParams: {
          ...templateParams,
          'to_email': adminEmail,
          'reply_to': templateParams['userEmail'] as String? ?? '',
        },
      );

      // 고객 이메일 전송
      final customerFuture = _sendEmail(
        templateParams: {
          ...templateParams,
          'to_email': templateParams['userEmail'] as String? ?? '',
        },
      );

      // 병렬 실행
      final results = await Future.wait([
        adminFuture.then((_) => true).catchError((_) => false),
        customerFuture.then((_) => true).catchError((_) => false),
      ]);

      return {
        'adminSuccess': results[0],
        'customerSuccess': results[1],
      };
    } catch (e) {
      print('❌ 이메일 전송 과정 중 심각한 오류 발생: $e');
      return {
        'adminSuccess': false,
        'customerSuccess': false,
      };
    }
  }

  /// 이메일 전송 (EmailJS API 호출)
  Future<void> _sendEmail({required Map<String, dynamic> templateParams}) async {
    try {
      // EmailJS API 엔드포인트
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': templateParams,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('이메일 전송 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 이메일 전송 오류: $e');
      rethrow;
    }
  }
}
