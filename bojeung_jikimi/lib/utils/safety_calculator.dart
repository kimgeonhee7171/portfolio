import 'package:flutter/material.dart';

// 전세 안전도 계산 유틸리티
class SafetyCalculator {
  // 안전도 등급
  static const String gradeSafe = 'SAFE';
  static const String gradeCaution = 'CAUTION';
  static const String gradeDanger = 'DANGER';

  // 전세 안전도 계산 결과
  static SafetyResult calculate({
    required double deposit, // 전세금 (만원)
    required double marketPrice, // 매매가 (만원)
    required double priorCredit, // 근저당 설정액 (만원)
  }) {
    // 매매가가 0이면 계산 불가
    if (marketPrice == 0) {
      return SafetyResult(
        grade: gradeSafe,
        ratio: 0.0,
        color: Colors.grey,
        message: '정보 부족',
        description: '매매가 정보가 없어 정확한 분석이 어렵습니다',
      );
    }

    // 위험도 계산: (전세금 + 근저당) ÷ 매매가 × 100
    final ratio = ((deposit + priorCredit) / marketPrice) * 100;

    // 등급 판정
    if (ratio >= 80) {
      return SafetyResult(
        grade: gradeDanger,
        ratio: ratio,
        color: const Color(0xFFEF5350), // Red
        message: '위험합니다',
        description: '깡통전세 위험이 매우 높습니다. 계약을 재검토하세요.',
      );
    } else if (ratio >= 70) {
      return SafetyResult(
        grade: gradeCaution,
        ratio: ratio,
        color: const Color(0xFFFFA726), // Orange/Yellow
        message: '주의가 필요합니다',
        description: '전세가율이 높은 편입니다. 추가 확인이 필요합니다.',
      );
    } else {
      return SafetyResult(
        grade: gradeSafe,
        ratio: ratio,
        color: const Color(0xFF00C853), // Green
        message: '안전합니다',
        description: '전세가율이 적정 범위입니다. 계약 진행에 문제없습니다.',
      );
    }
  }

  /// 7-Layer S-GSE: 추가 위험 요소 반영 안전도 계산 (우선순위 적용)
  /// 1순위: 위반건축물 → 무조건 위험
  /// 2순위: 세금 미확인 → 최소 주의
  /// 3순위: 기존 깡통전세율 로직
  static SafetyResult calculateSafety({
    required double deposit,
    required double marketPrice,
    required double priorCredit,
    required bool isViolatedArchitecture,
    required bool isTaxArrears,
  }) {
    final base = calculate(
      deposit: deposit,
      marketPrice: marketPrice,
      priorCredit: priorCredit,
    );

    // 1순위: 위반건축물이면 전세가율과 관계없이 무조건 위험
    if (isViolatedArchitecture) {
      return SafetyResult(
        grade: gradeDanger,
        ratio: base.ratio,
        color: const Color(0xFFEF5350),
        message: '위험합니다',
        description: '위반건축물은 전세자금대출 및 보증보험 가입이 불가능하여 매우 위험합니다.',
      );
    }

    // 2순위: 세금 미확인/체납이면 최소 주의
    if (!isTaxArrears) {
      if (base.grade == gradeDanger) return base;
      return SafetyResult(
        grade: gradeCaution,
        ratio: base.ratio,
        color: const Color(0xFFFFA726),
        message: '주의가 필요합니다',
        description: '집주인의 세금 체납 여부가 확인되지 않았습니다. 조세 채권은 보증금보다 우선할 수 있습니다.',
      );
    }

    // 3순위: 기존 깡통전세율 로직
    return base;
  }

  // 점수 계산 (100점 만점)
  static int calculateScore(SafetyResult result) {
    if (result.ratio >= 80) {
      return 60; // 위험: 50~69점
    } else if (result.ratio >= 70) {
      return 75; // 주의: 70~79점
    } else if (result.ratio >= 60) {
      return 85; // 양호: 80~89점
    } else {
      return 95; // 안전: 90~100점
    }
  }
}

// 안전도 계산 결과 클래스
class SafetyResult {
  final String grade; // SAFE, CAUTION, DANGER
  final double ratio; // 위험도 비율 (%)
  final Color color; // 등급별 색상
  final String message; // 한 줄 메시지
  final String description; // 상세 설명

  SafetyResult({
    required this.grade,
    required this.ratio,
    required this.color,
    required this.message,
    required this.description,
  });
}
