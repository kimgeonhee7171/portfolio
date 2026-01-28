import 'package:flutter/material.dart';

// 신호등 리포트 화면 (Safe-Guard Scoring Engine)
class ReportResultScreen extends StatelessWidget {
  final String contractType;
  final String deposit;
  final String monthlyRent;
  final String address;
  final String detailAddress;
  final int score;

  const ReportResultScreen({
    super.key,
    required this.contractType,
    required this.deposit,
    required this.monthlyRent,
    required this.address,
    required this.detailAddress,
    this.score = 95,
  });

  // 점수에 따른 등급 색상
  Color get _gradeColor {
    if (score >= 90) return const Color(0xFF00C853); // Green
    if (score >= 70) return const Color(0xFFFFA726); // Orange
    return const Color(0xFFEF5350); // Red
  }

  String get _gradeText {
    if (score >= 90) return '안전합니다';
    if (score >= 70) return '주의가 필요합니다';
    return '위험합니다';
  }

  String get _gradeDescription {
    if (score >= 90) return '계약 진행에 문제가 없습니다';
    if (score >= 70) return '몇 가지 확인이 필요합니다';
    return '계약을 재검토하시기 바랍니다';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '진단 결과',
          style: TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF1A237E)),
            onPressed: () {
              // 공유 기능
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 상단 종합 등급 (Shield Card)
            _buildGradeShieldCard(),

            const SizedBox(height: 24),

            // Safe-Guard 엔진 배지
            _buildEngineBadge(),

            const SizedBox(height: 24),

            // 분석 대상 정보
            _buildPropertyInfo(),

            const SizedBox(height: 24),

            // 상세 분석 리스트
            _buildDetailAnalysis(),

            const SizedBox(height: 24),

            // 전문가 검토 CTA
            _buildExpertReviewCTA(context),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 상단 종합 등급 쉴드 카드
  Widget _buildGradeShieldCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _gradeColor.withValues(alpha: 0.1),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _gradeColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 쉴드 아이콘 + 점수
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _gradeColor.withValues(alpha: 0.15),
                ),
              ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _gradeColor.withValues(alpha: 0.25),
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _gradeColor,
                ),
                child: Icon(
                  Icons.shield,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 점수
          Text(
            '$score점',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _gradeColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),

          // 등급 텍스트
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _gradeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _gradeText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 설명
          Text(
            _gradeDescription,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // Safe-Guard 엔진 배지
  Widget _buildEngineBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF00C853)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_user, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Safe-Guard Scoring Engine (S-GSE)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 분석 대상 정보
  Widget _buildPropertyInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '분석 대상',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.home, '주소', address),
          if (detailAddress.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, '상세', detailAddress),
          ],
          const SizedBox(height: 8),
          _buildInfoRow(Icons.description, '계약 유형', contractType),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.payments,
            '보증금',
            '${_formatNumber(deposit)}만원',
          ),
          if (monthlyRent.isNotEmpty && monthlyRent != '0') ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_month,
              '월세',
              '${_formatNumber(monthlyRent)}만원',
            ),
          ],
        ],
      ),
    );
  }

  // 정보 행
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // 상세 분석 리스트
  Widget _buildDetailAnalysis() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '상세 분석 결과',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // [권리 분석]
          _buildAnalysisItem(
            category: '권리 분석',
            icon: Icons.gavel,
            items: [
              _AnalysisDetail(
                title: '근저당권 설정액',
                result: '정상 범위',
                status: 'safe',
                detail: '전세가 대비 60% 수준으로 안전합니다',
              ),
              _AnalysisDetail(
                title: '선순위 채권 확인',
                result: '문제 없음',
                status: 'safe',
                detail: '선순위 채권이 없습니다',
              ),
            ],
          ),

          const Divider(height: 1),

          // [임대인 분석]
          _buildAnalysisItem(
            category: '임대인 분석 (Dual-Check)',
            icon: Icons.person_search,
            items: [
              _AnalysisDetail(
                title: 'HUG 블랙리스트',
                result: '미등재',
                status: 'safe',
                detail: '한국주택금융공사 블랙리스트에 등재되지 않았습니다',
              ),
              _AnalysisDetail(
                title: '고액 체납 이력',
                result: '없음',
                status: 'safe',
                detail: '국세·지방세 체납 이력이 없습니다',
              ),
            ],
          ),

          const Divider(height: 1),

          // [시세 분석]
          _buildAnalysisItem(
            category: '시세 분석',
            icon: Icons.analytics,
            items: [
              _AnalysisDetail(
                title: '전세가율',
                result: '70%',
                status: 'safe',
                detail: '매매가 대비 70%로 깡통전세 위험이 낮습니다',
              ),
              _AnalysisDetail(
                title: '시세 추이',
                result: '안정적',
                status: 'safe',
                detail: '최근 6개월간 가격 변동이 5% 이내입니다',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 분석 항목
  Widget _buildAnalysisItem({
    required String category,
    required IconData icon,
    required List<_AnalysisDetail> items,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF1A237E),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 상세 항목들
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDetailItem(item),
              )),
        ],
      ),
    );
  }

  // 상세 항목
  Widget _buildDetailItem(_AnalysisDetail detail) {
    final statusColor = detail.status == 'safe'
        ? const Color(0xFF00C853)
        : detail.status == 'caution'
            ? const Color(0xFFFFA726)
            : const Color(0xFFEF5350);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                detail.status == 'safe'
                    ? Icons.check_circle
                    : detail.status == 'caution'
                        ? Icons.warning
                        : Icons.error,
                size: 20,
                color: statusColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  detail.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  detail.result,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detail.detail,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // 전문가 검토 CTA
  Widget _buildExpertReviewCTA(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A237E).withValues(alpha: 0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1A237E).withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.support_agent,
            size: 48,
            color: Color(0xFF1A237E),
          ),
          const SizedBox(height: 16),
          const Text(
            '이대로 계약해도 될까요?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '부동산 전문가가 꼼꼼하게 재검토해드립니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 20),

          // 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showExpertReviewDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '전문가 검토 요청하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 가격 안내
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                '전문가 검토 비용: 49,000원',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 전문가 검토 다이얼로그
  void _showExpertReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.verified, color: Color(0xFF1A237E)),
            SizedBox(width: 12),
            Text('전문가 검토'),
          ],
        ),
        content: const Text(
          '부동산 전문가가 리포트를 재검토하고\n맞춤 컨설팅을 제공해드립니다.\n\n영업일 기준 1~2일 소요됩니다.',
          style: TextStyle(fontSize: 15, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('전문가 검토 요청이 접수되었습니다'),
                  backgroundColor: Color(0xFF00C853),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('요청하기'),
          ),
        ],
      ),
    );
  }

  // 숫자 포맷팅
  String _formatNumber(String number) {
    if (number.isEmpty) return '0';
    final value = int.tryParse(number.replaceAll(',', '')) ?? 0;
    return value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

// 분석 상세 데이터 모델
class _AnalysisDetail {
  final String title;
  final String result;
  final String status; // 'safe', 'caution', 'danger'
  final String detail;

  _AnalysisDetail({
    required this.title,
    required this.result,
    required this.status,
    required this.detail,
  });
}
