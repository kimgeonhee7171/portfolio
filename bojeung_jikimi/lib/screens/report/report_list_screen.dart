import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'report_result_screen.dart';

// 리포트 보관함 화면
class ReportListScreen extends StatelessWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '리포트 보관함',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reportData.length,
        itemBuilder: (context, index) {
          final report = _reportData[index];
          return _buildReportCard(
            context,
            address: report['address']!,
            date: report['date']!,
            score: report['score'] as int,
            grade: report['grade']!,
            contractType: report['contractType']!,
            deposit: report['deposit']!,
            monthlyRent: report['monthlyRent']!,
            detailAddress: report['detailAddress']!,
          );
        },
      ),
    );
  }

  // 리포트 카드
  Widget _buildReportCard(
    BuildContext context, {
    required String address,
    required String date,
    required int score,
    required String grade,
    required String contractType,
    required String deposit,
    required String monthlyRent,
    required String detailAddress,
  }) {
    // 등급에 따른 색상 및 아이콘
    final bool isSafe = grade == '안전';
    final Color gradeColor = isSafe ? Colors.green : Colors.orange;
    final IconData gradeIcon = isSafe ? Icons.shield : Icons.warning_amber;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // 리포트 상세 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportResultScreen(
                contractType: contractType,
                deposit: deposit,
                monthlyRent: monthlyRent,
                address: address,
                detailAddress: detailAddress,
                score: score,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 좌측: 등급 아이콘
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  gradeIcon,
                  size: 32,
                  color: gradeColor,
                ),
              ),
              const SizedBox(width: 16),

              // 중앙: 주소 및 날짜
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 주소
                    Text(
                      address,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // 진단 일시
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 우측: 점수 및 화살표
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 점수
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: gradeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: gradeColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '$score점',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 화살표
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 더미 리포트 데이터
  static final List<Map<String, dynamic>> _reportData = [
    {
      'address': '서울시 송파구 위례광장로 100',
      'detailAddress': '101동 1502호',
      'date': '2026.01.20',
      'score': 95,
      'grade': '안전',
      'contractType': '월세',
      'deposit': '10000',
      'monthlyRent': '50',
    },
    {
      'address': '서울시 강남구 강남대로 298',
      'detailAddress': '202동 805호',
      'date': '2026.01.18',
      'score': 70,
      'grade': '주의',
      'contractType': '전세',
      'deposit': '30000',
      'monthlyRent': '',
    },
    {
      'address': '경기도 성남시 분당구 판교역로 235',
      'detailAddress': '303동 1204호',
      'date': '2026.01.15',
      'score': 98,
      'grade': '안전',
      'contractType': '반전세',
      'deposit': '15000',
      'monthlyRent': '30',
    },
    {
      'address': '경기도 성남시 수정구 위례대로 55',
      'detailAddress': '104동 601호',
      'date': '2026.01.12',
      'score': 88,
      'grade': '안전',
      'contractType': '월세',
      'deposit': '5000',
      'monthlyRent': '80',
    },
  ];
}
