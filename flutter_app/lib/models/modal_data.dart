/// 멀티스텝 모달 데이터 모델
class ModalData {
  String propertyType;        // 거래 유형 (전세, 월세, 반전세 등)
  String trafficCode;         // 트래픽 코드
  String residenceStatus;     // 거주 상태
  String detailStatus;        // 상세 상황
  int amount;                 // 보증금 금액
  int monthlyRent;            // 월세 금액
  String contractPeriod;      // 계약 기간
  String address;             // 주소
  String userName;            // 이름
  String userPhone;           // 전화번호
  String userEmail;           // 이메일
  bool privacyAgreement;      // 개인정보 동의 여부

  ModalData({
    this.propertyType = '',
    this.trafficCode = '',
    this.residenceStatus = '',
    this.detailStatus = '',
    this.amount = 0,
    this.monthlyRent = 0,
    this.contractPeriod = '',
    this.address = '',
    this.userName = '',
    this.userPhone = '',
    this.userEmail = '',
    this.privacyAgreement = false,
  });

  /// 모달 데이터 초기화
  void reset() {
    propertyType = '';
    trafficCode = '';
    residenceStatus = '';
    detailStatus = '';
    amount = 0;
    monthlyRent = 0;
    contractPeriod = '';
    address = '';
    userName = '';
    userPhone = '';
    userEmail = '';
    privacyAgreement = false;
  }

  /// Map으로 변환 (서버 전송용)
  Map<String, dynamic> toMap() {
    return {
      'propertyType': propertyType,
      'trafficCode': trafficCode,
      'residenceStatus': residenceStatus,
      'detailStatus': detailStatus,
      'amount': amount,
      'monthlyRent': monthlyRent,
      'contractPeriod': contractPeriod,
      'address': address,
      'userName': userName,
      'userPhone': userPhone,
      'userEmail': userEmail,
      'privacyAgreement': privacyAgreement,
    };
  }

  /// Map에서 생성
  factory ModalData.fromMap(Map<String, dynamic> map) {
    return ModalData(
      propertyType: map['propertyType'] ?? '',
      trafficCode: map['trafficCode'] ?? '',
      residenceStatus: map['residenceStatus'] ?? '',
      detailStatus: map['detailStatus'] ?? '',
      amount: map['amount'] ?? 0,
      monthlyRent: map['monthlyRent'] ?? 0,
      contractPeriod: map['contractPeriod'] ?? '',
      address: map['address'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      userEmail: map['userEmail'] ?? '',
      privacyAgreement: map['privacyAgreement'] ?? false,
    );
  }

  /// JSON으로 변환
  String toJson() {
    return toMap().toString();
  }

  /// JSON에서 생성
  factory ModalData.fromJson(String json) {
    // 실제로는 jsonDecode 사용
    return ModalData();
  }
}
