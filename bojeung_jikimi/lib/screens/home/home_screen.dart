import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'column_detail_screen.dart';

// 홈 화면 (안심 대시보드)
class HomeScreen extends StatelessWidget {
  final VoidCallback? onNavigateToDiagnosis;

  const HomeScreen({super.key, this.onNavigateToDiagnosis});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 헤더 (Welcome)
            _buildWelcomeHeader(),

            const SizedBox(height: 24),

            // 메인 액션 카드 (3초 진단하기)
            _buildMainActionCard(),

            const SizedBox(height: 32),

            // 전문가 법률 칼럼 리스트
            _buildLegalColumnList(context),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // 상단 헤더
  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '안녕하세요, 건희님! 🏠',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '오늘도 안전한 집을 찾아볼까요?',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  // 메인 액션 카드 (3초 진단하기)
  Widget _buildMainActionCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: InkWell(
        onTap: () {
          if (onNavigateToDiagnosis != null) {
            onNavigateToDiagnosis!();
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '무료',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '3초 만에\n우리집 안전 진단',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'AI 엔진으로 빠르고 정확하게',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '지금 시작하기',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // 쉴드 아이콘
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 전문가 법률 칼럼 리스트
  Widget _buildLegalColumnList(BuildContext context) {
    final columns = [
      {
        'title': "특약사항에 '이 문구' 없으면 보증금 날립니다",
        'author': '박성훈 변호사',
        'date': '2026.01.20',
        'icon': Icons.gavel,
        'content': '''전세 계약 시 특약사항에 반드시 기재해야 할 핵심 문구를 알려드립니다.

1. "본 계약의 잔금은 확정일자를 받은 후 지급한다"
→ 이 문구가 없으면 잔금을 먼저 주고 확정일자를 못 받는 경우가 발생할 수 있습니다.

2. "임대인은 보증금 반환 시까지 근저당권 설정을 금지한다"
→ 계약 후 추가로 근저당을 설정하여 전세금이 위험해지는 것을 방지합니다.

3. "임대인의 체납 세금이 있을 시 계약을 해지할 수 있다"
→ 나중에 발견되는 체납으로 인한 피해를 예방할 수 있습니다.

이 세 가지 문구는 변호사로서 강력히 권장하는 필수 특약사항입니다.
계약서에 반드시 기재하시고, 임대인과 중개업소의 날인을 받으세요.''',
      },
      {
        'title': 'HUG 보증보험, 거절되는 집의 3가지 특징',
        'author': '최지수 법무사',
        'date': '2026.01.18',
        'icon': Icons.shield_outlined,
        'content': '''HUG(주택도시보증공사) 전세보증보험 가입이 거절되는 경우가 있습니다.

1. 전세가율이 매우 높은 경우 (매매가 대비 80% 이상)
→ 깡통전세 위험이 높아 보험사에서 가입을 거부합니다.

2. 근저당권 설정액이 과도한 경우
→ 선순위 채권이 많으면 보증금 회수가 어려워 거절됩니다.

3. 임대인이 세금 체납 중인 경우
→ 국세, 지방세 체납 이력이 있으면 위험 신호입니다.

보증보험 가입이 거절된 집은 위험 신호이므로, 계약을 재고하시는 것이 안전합니다.
보증지킴이 앱으로 사전에 진단받으시면 이런 위험을 미리 확인하실 수 있습니다.''',
      },
      {
        'title': "등기부등본 '을구'에서 꼭 봐야 할 권리 관계",
        'author': '김건희 대표',
        'date': '2026.01.15',
        'icon': Icons.description_outlined,
        'content': '''등기부등본의 '을구'는 소유권 이외의 권리 관계를 보여줍니다.

확인해야 할 핵심 항목:

1. 근저당권 설정액
→ 전세보증금보다 근저당이 크면 위험합니다.

2. 선순위 채권 여부
→ 먼저 설정된 전세권이나 임차권이 있는지 확인하세요.

3. 가압류, 가등기 등 제한물권
→ 이런 권리가 있으면 경매로 갈 가능성이 높습니다.

등기부등본은 반드시 계약 당일 발급본을 받아서 확인하시고,
의심스러운 내용이 있다면 반드시 전문가와 상담하세요.

Safe-Guard 엔진은 이런 복잡한 권리 관계를 3초 만에 분석해드립니다.''',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '전문가 법률 인사이트',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '매주 업데이트',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...columns.map((column) => _buildColumnCard(
              context,
              title: column['title'] as String,
              author: column['author'] as String,
              date: column['date'] as String,
              icon: column['icon'] as IconData,
              content: column['content'] as String,
            )),
      ],
    );
  }

  // 전문가 칼럼 카드
  Widget _buildColumnCard(
    BuildContext context, {
    required String title,
    required String author,
    required String date,
    required IconData icon,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ColumnDetailScreen(
                title: title,
                author: author,
                date: date,
                content: content,
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
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 아이콘
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.accent.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),

              // 텍스트 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // 작성자 및 날짜
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            author,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 화살표
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
