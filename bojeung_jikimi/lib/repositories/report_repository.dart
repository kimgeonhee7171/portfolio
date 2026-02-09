import '../models/report.dart';

/// 리포트 더미 데이터 저장소
class ReportRepository {
  ReportRepository._();

  static final List<Report> reports = [
    // [데이터 1] 송파구 안전 매물 (Green)
    const Report(
      address: '서울시 송파구 올림픽로 300 (신천동)',
      detailAddress: '101동 1502호',
      date: '2026.01.20',
      score: 92,
      grade: '안전',
      contractType: '월세',
      deposit: '10000',
      monthlyRent: '50',
      marketPrice: '25000',
      priorCredit: '0',
      isViolatedArchitecture: false,
      isTaxArrears: false,
      lat: 37.5145,
      lng: 127.1066,
    ),
    // [데이터 2] 강남구 주의 매물 (Yellow - 세금 미확인)
    const Report(
      address: '서울시 강남구 테헤란로 152 (역삼동)',
      detailAddress: '202동 805호',
      date: '2026.01.18',
      score: 70,
      grade: '주의',
      contractType: '전세',
      deposit: '30000',
      monthlyRent: '',
      marketPrice: '50000',
      priorCredit: '5000',
      isViolatedArchitecture: false,
      isTaxArrears: true, // 미확인 간주
      lat: 37.4980,
      lng: 127.0276,
    ),
    // [데이터 3] 성남시 위험 매물 (Red - 위반건축물)
    const Report(
      address: '경기도 성남시 분당구 판교역로 160',
      detailAddress: '303동 1204호',
      date: '2026.01.15',
      score: 45,
      grade: '위험',
      contractType: '전세',
      deposit: '20000',
      monthlyRent: '',
      marketPrice: '22000',
      priorCredit: '15000',
      isViolatedArchitecture: true,
      isTaxArrears: false,
      lat: 37.3947,
      lng: 127.1112,
    ),
  ];
}
