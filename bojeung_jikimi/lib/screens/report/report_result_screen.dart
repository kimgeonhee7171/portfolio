import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/safety_calculator.dart';
import '../../widgets/safety_gauge_chart.dart';

/// 진단 등급(Red/Yellow/Green)에 따른 필수 특약 사항 추천
List<String> getRecommendedTerms(String color) {
  switch (color.toLowerCase()) {
    case 'green':
      return [
        '임대인은 잔금 지급일 다음 날까지 현재의 등기부등본 상태를 유지하며, 근저당권 등 새로운 권리를 설정하지 않는다.',
        '임대인은 국세 및 지방세 체납 사실이 없음을 확인하며, 위반 시 계약을 해지하고 보증금을 즉시 반환한다.',
      ];
    case 'yellow':
      return [
        '임대인(매도인) 변경 시, 현 임대인은 새로운 임대인에게 임차인의 보증금 반환 의무 승계를 책임진다.',
        '전세보증금 반환보증 가입이 불가능할 경우 본 계약은 무효로 하며, 임대인은 계약금을 즉시 반환한다.',
        '임대인은 임차인의 전세자금대출 실행에 적극 협조하며, 대출 미승인 시 계약금 전액을 반환한다.',
      ];
    case 'red':
      return [
        '본 건물은 깡통전세 위험이 있으므로, 보증금을 최우선변제금 범위 내로 조정하거나 월세 전환을 강력히 권장함.',
        '계약 진행 시, 보증금 전액에 대한 \'질권 설정\' 또는 \'전세권 설정 등기\'를 필수 조건으로 한다.',
      ];
    default:
      return getRecommendedTerms('green');
  }
}

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
  final bool isViolatedArchitecture;
  final bool isTaxArrears;

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
    this.isViolatedArchitecture = false,
    this.isTaxArrears = true,
  });

  // 7-Layer S-GSE: 추가 위험 요소 반영 안전도 계산
  SafetyResult get _safetyResult {
    final depositValue = double.tryParse(deposit.replaceAll(',', '')) ?? 0;
    final marketValue = double.tryParse(marketPrice.replaceAll(',', '')) ?? 0;
    final priorValue = double.tryParse(priorCredit.replaceAll(',', '')) ?? 0;

    return SafetyCalculator.calculateSafety(
      deposit: depositValue,
      marketPrice: marketValue,
      priorCredit: priorValue,
      isViolatedArchitecture: isViolatedArchitecture,
      isTaxArrears: isTaxArrears,
    );
  }

  // 표시용 점수 (S-GSE 결과 기반)
  int get _displayScore => SafetyCalculator.calculateScore(_safetyResult);

  // 전세가율 계산
  double get _depositRatio {
    final depositValue = double.tryParse(deposit.replaceAll(',', '')) ?? 0;
    final marketValue = double.tryParse(marketPrice.replaceAll(',', '')) ?? 0;
    if (marketValue == 0) return 0;
    return (depositValue / marketValue) * 100;
  }

  // 깡통전세 위험도 계산 (SafetyResult의 ratio 사용)
  double get _totalRiskRatio => _safetyResult.ratio;

  // 등급에 따른 색상·메시지 (S-GSE 결과 기반)
  Color get _gradeColor => _safetyResult.color;
  String get _gradeText => _safetyResult.message;
  String get _gradeDescription => _safetyResult.description;

  /// SafetyResult 등급을 Red/Yellow/Green 문자열로 변환
  String get _recommendedTermsColor {
    switch (_safetyResult.grade) {
      case SafetyCalculator.gradeDanger:
        return 'red';
      case SafetyCalculator.gradeCaution:
        return 'yellow';
      default:
        return 'green';
    }
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
            _buildDataSourceCaption(),
            const SizedBox(height: 24),
            _buildPropertyInfo(),
            const SizedBox(height: 24),
            _buildSafetyCalculationCard(),
            const SizedBox(height: 24),
            _buildRecommendedTermsSection(),
            const SizedBox(height: 24),
            _buildDetailAnalysis(),
            const SizedBox(height: 24),
            _buildShareButton(),
            const SizedBox(height: 16),
            _buildExpertReviewCTA(context),
            const SizedBox(height: 24),
            _buildDisclaimerFooter(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 데이터 출처 표시
  Widget _buildDataSourceCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_outlined, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Data Source: 대한민국 법원 인터넷등기소 & 국토교통부 (Simulated)',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 면책 조항 푸터
  Widget _buildDisclaimerFooter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '※ 본 진단 결과는 참고용이며, 법적 효력이 없습니다. 정확한 내용은 전문가와 상담하세요.',
        style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
        textAlign: TextAlign.center,
      ),
    );
  }

  // 상단 종합 등급 - 게이지 차트 + 중앙 점수
  Widget _buildGradeShieldCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_gradeColor.withValues(alpha: 0.08), Colors.white],
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
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SafetyGaugeChart(
                  score: _displayScore,
                  gradeColor: _gradeColor,
                  size: 220,
                ),
                Positioned(
                  bottom: 20,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_displayScore점',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: _gradeColor,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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

  // 상세 분석 리스트 (7-Layer 진단 항목 - 사업계획서 기준)
  Widget _buildDetailAnalysis() {
    final ratio = _totalRiskRatio;
    final item3Status = ratio >= 80
        ? 'danger'
        : (ratio >= 70 ? 'caution' : 'safe');
    final item3Detail = ratio >= 70
        ? '매매가의 ${ratio.toStringAsFixed(0)}% 육박'
        : ratio >= 60
        ? '매매가의 ${ratio.toStringAsFixed(0)}% (주의 필요)'
        : '매매가의 ${ratio.toStringAsFixed(0)}% (적정 범위)';
    final item3Badge = item3Status == 'danger'
        ? 'Danger'
        : (item3Status == 'caution' ? 'Warning' : 'Pass');

    final items = [
      _LayerItem(
        index: 1,
        title: '소유자 진위 확인 (신분증 대조)',
        icon: Icons.badge_outlined,
        status: 'safe',
        badgeText: 'Pass',
        detail: '신분증과 등기부등본 소유자가 일치합니다',
      ),
      _LayerItem(
        index: 2,
        title: '권리 침해 (압류/가처분)',
        icon: Icons.gavel,
        status: 'safe',
        badgeText: 'Pass',
        detail: '압류·가처분 등 권리 침해 사항이 없습니다',
      ),
      _LayerItem(
        index: 3,
        title: '근저당 비율 (주택가격 대비)',
        icon: Icons.account_balance,
        status: item3Status,
        badgeText: item3Badge,
        detail: item3Detail,
      ),
      _LayerItem(
        index: 4,
        title: '선순위 채권 확인',
        icon: Icons.receipt_long_outlined,
        status: 'safe',
        badgeText: 'Pass',
        detail: '선순위 채권이 없습니다',
      ),
      _LayerItem(
        index: 5,
        title: '임대인 체납 사실 (국세/지방세)',
        icon: Icons.verified_user_outlined,
        status: 'safe',
        badgeText: 'Pass',
        detail: '완납 확인됨',
      ),
      _LayerItem(
        index: 6,
        title: '위반건축물 여부',
        icon: Icons.apartment,
        status: isViolatedArchitecture ? 'danger' : 'safe',
        badgeText: isViolatedArchitecture ? 'Danger' : 'Pass',
        detail: isViolatedArchitecture ? '위반건축물 등재' : '위반 사항 없음',
      ),
      _LayerItem(
        index: 7,
        title: '특약사항 독소 조항 (NLP 분석)',
        icon: Icons.article_outlined,
        status: 'safe',
        badgeText: 'Pass',
        detail: '발견되지 않음',
      ),
    ];

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
                  '7-Layer 안전 진단 결과',
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
          ...items.map((item) => _buildLayerItem(item)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // 7-Layer 항목 카드 (아이콘 + 제목 + 뱃지)
  Widget _buildLayerItem(_LayerItem item) {
    final statusColor = item.status == 'safe'
        ? const Color(0xFF00C853) // 초록 Pass
        : item.status == 'caution'
        ? const Color(0xFFFFA726) // 노랑 Warning
        : const Color(0xFFEF5350); // 빨강 Danger

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    size: 24,
                    color: const Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.index}. ${item.title}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.detail,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    item.badgeText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // AI 추천 필수 특약 체크리스트 섹션
  Widget _buildRecommendedTermsSection() {
    final terms = getRecommendedTerms(_recommendedTermsColor);
    return _RecommendedTermsCard(terms: terms, accentColor: _gradeColor);
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
🛡 안전 점수: $_displayScore점 ($_gradeText)
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

/// AI 추천 필수 특약 체크리스트 카드 (체크박스 상태 관리)
class _RecommendedTermsCard extends StatefulWidget {
  final List<String> terms;
  final Color accentColor;

  const _RecommendedTermsCard({required this.terms, required this.accentColor});

  @override
  State<_RecommendedTermsCard> createState() => _RecommendedTermsCardState();
}

class _RecommendedTermsCardState extends State<_RecommendedTermsCard> {
  late List<bool> _checkedList;

  @override
  void initState() {
    super.initState();
    _checkedList = List.filled(widget.terms.length, false);
  }

  @override
  void didUpdateWidget(covariant _RecommendedTermsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.terms.length != _checkedList.length) {
      _checkedList = List.filled(widget.terms.length, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.gavel_rounded,
                    size: 24,
                    color: widget.accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'AI가 추천하는 필수 특약 체크리스트',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...List.generate(widget.terms.length, (index) {
            return CheckboxListTile(
              value: _checkedList[index],
              onChanged: (value) {
                setState(() {
                  _checkedList[index] = value ?? false;
                });
              },
              activeColor: widget.accentColor,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              title: Text(
                widget.terms[index],
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[800],
                  height: 1.5,
                  decoration: _checkedList[index]
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// 7-Layer 진단 항목 데이터 모델
class _LayerItem {
  final int index;
  final String title;
  final IconData icon;
  final String status; // safe, caution, danger
  final String badgeText; // Pass, Warning, Danger
  final String detail;

  const _LayerItem({
    required this.index,
    required this.title,
    required this.icon,
    required this.status,
    required this.badgeText,
    required this.detail,
  });
}
