/// 포맷팅 서비스
/// 전화번호, 금액 등 포맷팅 유틸리티
class FormattingService {
  static final FormattingService instance = FormattingService._internal();
  FormattingService._internal();

  /// 전화번호 포맷팅
  /// [input] 입력된 전화번호 (숫자만)
  /// 반환: 포맷팅된 전화번호 (010-XXXX-XXXX)
  String formatPhoneNumber(String input) {
    // 숫자만 추출
    String value = input.replaceAll(RegExp(r'[^\d]'), '');

    // 010으로 시작하지 않으면 010으로 강제 설정
    if (!value.startsWith('010')) {
      value = '010' + value.replaceFirst(RegExp(r'^010'), '');
    }

    // 010이 삭제되려고 하면 강제로 010 유지
    if (value.length < 3) {
      value = '010';
    }

    // 최대 11자리까지만 허용
    if (value.length > 11) {
      value = value.substring(0, 11);
    }

    // 하이픈 자동 추가
    String formatted = '';
    if (value.length >= 3) {
      formatted = value.substring(0, 3) + '-';
      if (value.length >= 7) {
        formatted += value.substring(3, 7);
        if (value.length >= 11) {
          formatted += '-' + value.substring(7, 11);
        } else if (value.length > 7) {
          formatted += '-' + value.substring(7);
        }
      } else if (value.length > 3) {
        formatted += value.substring(3);
      }
    } else {
      formatted = value;
    }

    return formatted;
  }

  /// 금액을 한국어 형식으로 포맷팅
  /// [num] 금액
  /// 반환: 포맷팅된 문자열 (예: "1억 2천만원")
  String formatNumberToKorean(int num) {
    if (num >= 100000000) {
      final eok = num ~/ 100000000;
      final man = (num % 100000000) ~/ 10000;
      if (man > 0) {
        return '$eok억 ${man}만원';
      }
      return '${eok}억원';
    } else if (num >= 10000) {
      return '${num ~/ 10000}만원';
    } else if (num >= 1000) {
      return '${num ~/ 1000}천원';
    } else {
      return '${num.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
    }
  }

  /// 숫자에 천 단위 콤마 추가
  /// [num] 숫자
  /// 반환: 콤마가 추가된 문자열
  String formatNumberWithCommas(int num) {
    return num.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// 문자열에서 숫자만 추출
  /// [input] 입력 문자열
  /// 반환: 숫자만 포함된 문자열
  String extractNumbers(String input) {
    return input.replaceAll(RegExp(r'[^\d]'), '');
  }
}
