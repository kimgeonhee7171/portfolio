/// 검증 서비스
/// 입력 데이터 검증 로직
class ValidationService {
  static final ValidationService instance = ValidationService._internal();
  ValidationService._internal();

  /// 이름 검증
  /// [name] 이름
  /// 반환: 검증 결과 및 에러 메시지
  ValidationResult validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: '이름을 입력해주시면 리포트를 받으실 수 있어요!',
      );
    }
    return ValidationResult(isValid: true);
  }

  /// 전화번호 검증
  /// [phone] 전화번호
  /// 반환: 검증 결과 및 에러 메시지
  ValidationResult validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: '연락처를 입력해주시면 리포트를 받으실 수 있어요!',
      );
    }

    // 전화번호 형식 검증 (010-XXXX-XXXX)
    final phoneRegex = RegExp(r'^010-\d{4}-\d{4}$');
    if (!phoneRegex.hasMatch(phone.trim())) {
      return ValidationResult(
        isValid: false,
        errorMessage: '올바른 전화번호 형식으로 입력해주세요.\n예시: 010-1234-5678',
      );
    }

    return ValidationResult(isValid: true);
  }

  /// 이메일 검증
  /// [email] 이메일 주소
  /// 반환: 검증 결과 및 에러 메시지
  ValidationResult validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: '이메일 주소를 입력해주시면 리포트를 받으실 수 있어요!',
      );
    }

    // 이메일 형식 검증
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email.trim())) {
      return ValidationResult(
        isValid: false,
        errorMessage: '올바른 이메일 형식으로 입력해주세요.\n예시: example@email.com',
      );
    }

    return ValidationResult(isValid: true);
  }

  /// 개인정보 동의 검증
  /// [isAgreed] 동의 여부
  /// 반환: 검증 결과 및 에러 메시지
  ValidationResult validatePrivacyAgreement(bool? isAgreed) {
    if (isAgreed != true) {
      return ValidationResult(
        isValid: false,
        errorMessage: '개인정보 수집 및 이용에 동의해주시면 안전하게 리포트를 받으실 수 있어요!',
      );
    }
    return ValidationResult(isValid: true);
  }

  /// 금액 검증
  /// [amount] 금액
  /// 반환: 검증 결과 및 에러 메시지
  ValidationResult validateAmount(int? amount) {
    if (amount == null || amount <= 0) {
      return ValidationResult(
        isValid: false,
        errorMessage: '💰 보증금 금액을 입력해주시면 안전성 분석을 시작할 수 있어요!',
      );
    }
    return ValidationResult(isValid: true);
  }

  /// 주소 검증
  /// [cityDistrict] 시/도, 구/군
  /// [detail] 상세 주소
  /// 반환: 검증 결과 및 에러 메시지
  ValidationResult validateAddress(String? cityDistrict, String? detail) {
    if (cityDistrict == null || cityDistrict.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: '🏡 시/도, 구/군을 입력해주시면 해당 지역의 안전성을 분석해드릴 수 있어요!',
      );
    }

    if (detail == null || detail.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: '🏡 상세 주소를 입력해주시면 정확한 분석이 가능해요!',
      );
    }

    return ValidationResult(isValid: true);
  }

  /// 본인 정보 전체 검증
  /// [name] 이름
  /// [phone] 전화번호
  /// [email] 이메일
  /// [isAgreed] 개인정보 동의 여부
  /// 반환: 검증 결과 및 에러 메시지
  ValidationResult validatePersonalInfo({
    String? name,
    String? phone,
    String? email,
    bool? isAgreed,
  }) {
    // 이름 검증
    final nameResult = validateName(name);
    if (!nameResult.isValid) return nameResult;

    // 전화번호 검증
    final phoneResult = validatePhone(phone);
    if (!phoneResult.isValid) return phoneResult;

    // 이메일 검증
    final emailResult = validateEmail(email);
    if (!emailResult.isValid) return emailResult;

    // 개인정보 동의 검증
    final agreementResult = validatePrivacyAgreement(isAgreed);
    if (!agreementResult.isValid) return agreementResult;

    return ValidationResult(isValid: true);
  }
}

/// 검증 결과 모델
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}
