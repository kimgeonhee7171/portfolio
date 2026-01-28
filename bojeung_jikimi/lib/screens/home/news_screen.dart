import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

// 부동산 뉴스 화면
class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '부동산 뉴스',
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
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _newsData.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
          indent: 88,
        ),
        itemBuilder: (context, index) {
          final news = _newsData[index];
          return _buildNewsItem(
            context,
            title: news['title']!,
            source: news['source']!,
            date: news['date']!,
            icon: news['icon'] as IconData,
            iconColor: news['iconColor'] as Color,
          );
        },
      ),
    );
  }

  // 뉴스 아이템
  Widget _buildNewsItem(
    BuildContext context, {
    required String title,
    required String source,
    required String date,
    required IconData icon,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: () {
        // 뉴스 상세 화면으로 이동 (추후 구현)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(title),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 좌측: 뉴스 썸네일 아이콘
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),

            // 우측: 뉴스 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 (2줄 말줄임)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // 출처 및 날짜
                  Row(
                    children: [
                      // 출처
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
                          source,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 날짜
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 화살표 아이콘
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // 더미 뉴스 데이터
  static final List<Map<String, dynamic>> _newsData = [
    {
      'title': '2026년 전세사기 방지법 전면 시행... 보증금 보호 강화',
      'source': '한국일보',
      'date': '2026.01.19',
      'icon': Icons.gavel,
      'iconColor': Colors.blue,
    },
    {
      'title': '서울 아파트 전세가율 70% 돌파, 전세 사기 위험 주의보',
      'source': '조선일보',
      'date': '2026.01.19',
      'icon': Icons.trending_up,
      'iconColor': Colors.red,
    },
    {
      'title': '국토부, 전세금 반환보증 의무화 법안 국회 통과',
      'source': '중앙일보',
      'date': '2026.01.18',
      'icon': Icons.account_balance,
      'iconColor': Colors.green,
    },
    {
      'title': '임대차 3법 2년 연장... 전월세 시장 안정화 기대',
      'source': '동아일보',
      'date': '2026.01.18',
      'icon': Icons.home_work,
      'iconColor': Colors.orange,
    },
    {
      'title': 'HUG 전세보증보험 가입 한도 상향... 최대 5억까지',
      'source': '매일경제',
      'date': '2026.01.17',
      'icon': Icons.security,
      'iconColor': Colors.purple,
    },
    {
      'title': '수도권 빌라·다세대 전세 사기 주의보... 계약 전 확인 필수',
      'source': '한겨레',
      'date': '2026.01.17',
      'icon': Icons.warning_amber,
      'iconColor': Colors.amber,
    },
    {
      'title': '등기부등본 온라인 열람 서비스 24시간 무료 제공',
      'source': '경향신문',
      'date': '2026.01.16',
      'icon': Icons.description,
      'iconColor': Colors.indigo,
    },
    {
      'title': '깡통전세 피해 보상 청구 소송 1심 승소... 판례 주목',
      'source': '서울신문',
      'date': '2026.01.16',
      'icon': Icons.balance,
      'iconColor': Colors.teal,
    },
    {
      'title': '부동산 중개사 자격시험 합격률 역대 최저... 신뢰도 제고',
      'source': '한국경제',
      'date': '2026.01.15',
      'icon': Icons.school,
      'iconColor': Colors.brown,
    },
    {
      'title': '전세 계약 시 확정일자 받기 필수... 우선변제권 확보',
      'source': '머니투데이',
      'date': '2026.01.15',
      'icon': Icons.verified,
      'iconColor': Colors.cyan,
    },
  ];
}
