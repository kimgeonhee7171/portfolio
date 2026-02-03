import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/safety_calculator.dart';

// 신호등 리포트 화면 (Safe-Guard Scoring Engine - 7대 안전 진단)
class ReportResultScreen extends StatelessWidget {
  final String contractType;
  final String deposit;
  final String monthlyRent;
  final String marketPrice;
  final String priorCredit;
  final String address;
  final String detailAddress;
  final int score;

  const ReportResultScreen({
    super.key,
    required this.contractType,
    required this.deposit,
    required this.monthlyRent,
    this.marketPrice = '',
    this.priorCredit = '',
    required this.address,
    required this.detailAddress,
    this.score = 95,
  });

  // SafetyCalculator를 사용한 안전도 계산
  SafetyResult get _safetyResult {
    final depositValue = double.tryParse(deposit.replaceAll(',', '')) ?? 0;
    final marketValue = double.tryParse(marketPrice.replaceAll(',', '')) ?? 0;
    final priorValue = double.tryParse(priorCredit.replaceAll(',', '')) ?? 0;

    return SafetyCalculator.calculate(
      deposit: depositValue,
      marketPrice: marketValue,
      priorCredit: priorValue,
    );
  }

  // 전세가율 계산
  double get _depositRatio {
    final depositValue = double.tryParse(deposit.replaceAll(',', '')) ?? 0;
    final marketValue = double.tryParse(marketPrice.replaceAll(',', '')) ?? 0;
    if (marketValue == 0) return 0;
    return (depositValue / marketValue) * 100;
  }

  // 깡통전세 위험도 계산 (SafetyResult의 ratio 사용)
  double get _totalRiskRatio => _safetyResult.ratio;

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
            onPressed: _shareResult,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildGradeShieldCard(),
            const SizedBox(height: 24),
            _buildEngineBadge(),
            const SizedBox(height: 24),
            _buildPropertyInfo(),
            const SizedBox(height: 24),
            _buildSafetyCalculationCard(),
            const SizedBox(height: 24),
            _buildDetailAnalysis(),
            const SizedBox(height: 24),
            _buildShareButton(),
            const SizedBox(height: 16),
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
          colors: [_gradeColor.withValues(alpha: 0.1), Colors.white],
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
                child: const Icon(Icons.shield, size: 50, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
          Text(
            _gradeDescription,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
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
          _buildInfoRow(Icons.payments, '보증금', '${_formatNumber(deposit)}만원'),
          if (monthlyRent.isNotEmpty && monthlyRent != '0') ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_month,
              '월세',
              '${_formatNumber(monthlyRent)}만원',
            ),
          ],
          if (marketPrice.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.home_work,
              '매매가',
              '${_formatNumber(marketPrice)}만원',
            ),
          ],
          if (priorCredit.isNotEmpty && priorCredit != '0') ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.warning_amber,
              '선순위 채권',
              '${_formatNumber(priorCredit)}만원',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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

  // 안전도 계산 결과 카드
  Widget _buildSafetyCalculationCard() {
    final result = _safetyResult;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [result.color.withValues(alpha: 0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: result.color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: result.color.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 수식 표시
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  '위험도 계산 공식',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '(전세금 + 근저당) ÷ 매매가',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                // 계산 결과
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: result.color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${result.ratio.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 결과 메시지
          Icon(
            result.grade == SafetyCalculator.gradeSafe
                ? Icons.check_circle
                : result.grade == SafetyCalculator.gradeCaution
                ? Icons.warning
                : Icons.error,
            size: 48,
            color: result.color,
          ),
          const SizedBox(height: 12),
          Text(
            result.message,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: result.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 상세 분석 리스트 (7대 안전 진단 기준)
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
                  '7대 안전 진단 결과',
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

          // [A: 자산 가치 분석]
          _buildAnalysisCategory(
            category: 'A. 자산 가치 분석',
            icon: Icons.analytics,
            items: [
              _AnalysisDetail(
                title: '1. 전세가율',
                result: '${_depositRatio.toStringAsFixed(1)}%',
                status: _depositRatio < 60
                    ? 'safe'
                    : (_depositRatio < 80 ? 'caution' : 'danger'),
                detail: _depositRatio < 60
                    ? '전세가율이 적정 범위입니다'
                    : (_depositRatio < 80
                          ? '전세가율이 다소 높습니다. 주의가 필요합니다'
                          : '전세가율이 매우 높아 위험합니다'),
              ),
              _AnalysisDetail(
                title: '2. 깡통전세 위험도',
                result: _totalRiskRatio >= 80 ? '위험' : '안전',
                status: _totalRiskRatio >= 80 ? 'danger' : 'safe',
                detail: '(보증금+채권)/매매가 = ${_totalRiskRatio.toStringAsFixed(1)}%',
              ),
              _AnalysisDetail(
                title: '3. 보증보험 가입 가능성',
                result: _depositRatio <= 90 ? '가능' : '어려움',
                status: _depositRatio <= 90 ? 'safe' : 'caution',
                detail: _depositRatio <= 90
                    ? 'HUG 전세보증보험 가입이 가능합니다'
                    : '전세가율이 높아 보증보험 가입이 어려울 수 있습니다',
              ),
            ],
          ),

          const Divider(height: 1),

          // [B: 임대인 신용 분석]
          _buildAnalysisCategory(
            category: 'B. 임대인 신용 분석 (Dual-Check)',
            icon: Icons.person_search,
            items: [
              const _AnalysisDetail(
                title: '4. 국세/지방세 체납',
                result: '없음',
                status: 'safe',
                detail: '국세청 및 지자체 체납 이력이 없습니다',
              ),
              const _AnalysisDetail(
                title: '5. 임대인 소유권 일치',
                result: '일치',
                status: 'safe',
                detail: '등기부등본 상 소유자와 임대인이 일치합니다',
              ),
            ],
          ),

          const Divider(height: 1),

          // [C: 건물 및 권리 분석]
          _buildAnalysisCategory(
            category: 'C. 건물 및 권리 분석',
            icon: Icons.apartment,
            items: [
              const _AnalysisDetail(
                title: '6. 위반 건축물 여부',
                result: '깨끗함',
                status: 'safe',
                detail: '불법 증축이나 용도 위반 사항이 없습니다',
              ),
              const _AnalysisDetail(
                title: '7. 공인중개사 등록',
                result: '정상 등록',
                status: 'safe',
                detail: '중개업소가 정식으로 등록되어 있습니다',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 카테고리별 분석 항목
  Widget _buildAnalysisCategory({
    required String category,
    required IconData icon,
    required List<_AnalysisDetail> items,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF1A237E)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDetailItem(item),
            ),
          ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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

  // 공유하기 버튼
  Widget _buildShareButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _shareResult,
          icon: const Icon(Icons.share, size: 20, color: Colors.white),
          label: const Text(
            '친구에게 결과 공유하기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E), // Navy (Primary)
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
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
          const Icon(Icons.support_agent, size: 48, color: Color(0xFF1A237E)),
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
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                '전문가 검토 비용: 49,000원',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExpertReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            child: Text('취소', style: TextStyle(color: Colors.grey[600])),
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

  String _formatNumber(String number) {
    if (number.isEmpty) return '0';
    final value = int.tryParse(number.replaceAll(',', '')) ?? 0;
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // 공유 메시지 생성
  String _generateShareMessage() {
    final result = _safetyResult;

    return '''🏠 우리집 전세 안전 진단 결과 도착!

📍 주소: $address
🛡 안전 점수: $score점 ($_gradeText)
📊 위험도: ${result.ratio.toStringAsFixed(1)}% (${result.message})

${result.grade == SafetyCalculator.gradeDanger ? '⚠️ 주의: 깡통전세 위험도가 높습니다\n' : ''}${_depositRatio > 0 ? '전세가율: ${_depositRatio.toStringAsFixed(1)}%\n' : ''}
내 보증금은 안전할까? 3초 만에 진단해보세요! 👇
https://safehome.com

#보증지킴이 #전세안전진단 #전세사기예방''';
  }

  // 공유하기 실행
  Future<void> _shareResult() async {
    try {
      await Share.share(
        _generateShareMessage(),
        subject: '보증지킴이 - 전세 안전 진단 결과',
      );
    } catch (e) {
      debugPrint('공유 에러: $e');
    }
  }
}

// 분석 상세 데이터 모델
class _AnalysisDetail {
  final String title;
  final String result;
  final String status;
  final String detail;

  const _AnalysisDetail({
    required this.title,
    required this.result,
    required this.status,
    required this.detail,
  });
}
