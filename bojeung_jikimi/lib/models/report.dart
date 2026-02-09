/// 전세 안전 진단 리포트 데이터 모델
class Report {
  final String address;
  final String detailAddress;
  final String date;
  final int score;
  final String grade;
  final String contractType;
  final String deposit;
  final String monthlyRent;
  final String marketPrice;
  final String priorCredit;
  final bool isViolatedArchitecture;
  final bool isTaxArrears;
  final double? lat;
  final double? lng;

  const Report({
    required this.address,
    required this.detailAddress,
    required this.date,
    required this.score,
    required this.grade,
    required this.contractType,
    required this.deposit,
    required this.monthlyRent,
    this.marketPrice = '',
    this.priorCredit = '',
    this.isViolatedArchitecture = false,
    this.isTaxArrears = true,
    this.lat,
    this.lng,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      address: json['address'] as String? ?? '',
      detailAddress: json['detailAddress'] as String? ?? '',
      date: json['date'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      grade: json['grade'] as String? ?? '',
      contractType: json['contractType'] as String? ?? '',
      deposit: json['deposit'] as String? ?? '',
      monthlyRent: json['monthlyRent'] as String? ?? '',
      marketPrice: json['marketPrice'] as String? ?? '',
      priorCredit: json['priorCredit'] as String? ?? '',
      isViolatedArchitecture: json['isViolatedArchitecture'] as bool? ?? false,
      isTaxArrears: json['isTaxArrears'] as bool? ?? true,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'detailAddress': detailAddress,
      'date': date,
      'score': score,
      'grade': grade,
      'contractType': contractType,
      'deposit': deposit,
      'monthlyRent': monthlyRent,
      'marketPrice': marketPrice,
      'priorCredit': priorCredit,
      'isViolatedArchitecture': isViolatedArchitecture,
      'isTaxArrears': isTaxArrears,
      'lat': lat,
      'lng': lng,
    };
  }
}
