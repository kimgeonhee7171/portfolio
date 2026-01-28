import 'package:flutter/material.dart';

// 공지사항 화면
class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E), // Navy
        foregroundColor: Colors.white,
        title: const Text(
          '공지사항',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNoticeItem(
            context,
            title: '보증지킴이 v1.0 정식 출시 안내',
            date: '2026.08.01',
            content: '''안녕하세요, 보증지킴이입니다.

드디어 보증지킴이 v1.0이 정식 출시되었습니다!

주요 기능:
• Safe-Guard Scoring Engine (S-GSE) 탑재
• 3초 이내 초고속 AI 분석
• 집(권리) + 집주인(인물) Dual-Check 시스템
• HUG 블랙리스트 실시간 대조

많은 이용 부탁드립니다. 감사합니다.''',
          ),
          const SizedBox(height: 12),
          _buildNoticeItem(
            context,
            title: '[업데이트] Safe-Guard 엔진 고도화 완료',
            date: '2026.08.15',
            content: '''Safe-Guard Scoring Engine이 업데이트되었습니다.

업데이트 내용:
• 분석 정확도 15% 향상
• 임대인 블랙리스트 데이터베이스 확대
• 공적장부 스크래핑 속도 개선
• UI/UX 개선 (Navy & Green 브랜드 컬러 적용)

더욱 신뢰할 수 있는 서비스로 보답하겠습니다.''',
            isNew: true,
          ),
          const SizedBox(height: 12),
          _buildNoticeItem(
            context,
            title: '서버 점검 예정 안내 (02:00 ~ 04:00)',
            date: '2026.08.20',
            content: '''서버 점검이 예정되어 있습니다.

점검 일시: 2026년 8월 22일 (목) 02:00 ~ 04:00 (약 2시간)

점검 내용:
• 데이터베이스 최적화
• 보안 패치 적용
• 시스템 안정화 작업

점검 시간 동안 서비스 이용이 일시적으로 제한될 수 있습니다.
양해 부탁드립니다.''',
            isNew: true,
          ),
        ],
      ),
    );
  }

  // 공지사항 아이템
  Widget _buildNoticeItem(
    BuildContext context, {
    required String title,
    required String date,
    required String content,
    bool isNew = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.campaign,
              color: Color(0xFF1A237E), // Navy
              size: 24,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
              if (isNew) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853), // Green
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              date,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
