import 'package:flutter/material.dart';

// FAQ (자주 묻는 질문) 화면 - Soft & Clean Design
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          '자주 묻는 질문',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.1),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // 안내 메시지 (Soft 버전)
          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: Colors.grey[600],
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '질문을 클릭하시면 답변을 확인하실 수 있습니다',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          _buildFaqItem(
            context,
            question: '분석 결과는 법적 효력이 있나요?',
            answer:
                '본 리포트는 참고용이며 법적 효력은 없습니다. 법적 분쟁 시에는 변호사 자문이 필요합니다.\n\n보증지킴이는 공적장부 데이터를 기반으로 객관적인 분석 결과를 제공하지만, 법적 판단이나 책임을 대신할 수 없습니다. 계약 전 반드시 전문가의 도움을 받으시기 바랍니다.',
            icon: Icons.gavel,
          ),
          const Divider(height: 1, thickness: 1),
          _buildFaqItem(
            context,
            question: '분석 시간은 얼마나 걸리나요?',
            answer:
                'AI Safe-Guard 엔진을 통해 약 3초 이내에 분석이 완료됩니다.\n\n보증지킴이는 자체 개발한 S-GSE (Safe-Guard Scoring Engine)를 활용하여 실시간으로 공적장부를 스크래핑하고, 임대인 정보를 대조하여 초고속으로 결과를 제공합니다.',
            icon: Icons.speed,
          ),
          const Divider(height: 1, thickness: 1),
          _buildFaqItem(
            context,
            question: '집주인 정보는 어떻게 확인하나요?',
            answer:
                '입력해주신 임대인 명의를 HUG 블랙리스트 및 고액 체납자 명단과 대조하여 분석합니다.\n\n보증지킴이의 차별화된 "Dual-Check" 시스템은 집(권리)뿐만 아니라 집주인(인물)까지 검증하여 임차인의 안전을 이중으로 보호합니다.',
            icon: Icons.person_search,
          ),
          const Divider(height: 1, thickness: 1),
          _buildFaqItem(
            context,
            question: '개인정보는 안전하게 관리되나요?',
            answer:
                '고객님의 개인정보는 철저히 암호화되어 안전하게 보관됩니다.\n\n보증지킴이는 개인정보보호법을 준수하며, 수집된 정보는 분석 목적으로만 사용되고 제3자에게 제공되지 않습니다. 또한 주기적인 보안 점검을 통해 안전성을 유지하고 있습니다.',
            icon: Icons.security,
          ),
          const Divider(height: 1, thickness: 1),
          _buildFaqItem(
            context,
            question: '분석 비용은 얼마인가요?',
            answer:
                '현재 보증지킴이는 무료 베타 서비스로 제공되고 있습니다.\n\n정식 출시 후에는 기본 분석은 무료로 제공하며, 상세 리포트 및 전문가 상담 서비스는 별도 요금제로 운영될 예정입니다. 자세한 내용은 추후 공지사항을 통해 안내드리겠습니다.',
            icon: Icons.payments,
          ),
          const Divider(height: 1, thickness: 1),
          _buildFaqItem(
            context,
            question: '분석 결과를 다시 볼 수 있나요?',
            answer:
                '네, "내 정보" 탭의 "내 진단 리포트 보관함"에서 언제든지 확인하실 수 있습니다.\n\n과거에 진행한 모든 분석 기록이 저장되어 있으며, 클릭하시면 상세 리포트를 다시 열람할 수 있습니다.',
            icon: Icons.folder_open,
          ),
        ],
      ),
    );
  }

  // FAQ 아이템 (Soft & Clean 버전)
  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
    required IconData icon,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        iconColor: Colors.grey[400],
        collapsedIconColor: Colors.grey[400],
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.grey[500],
            size: 20,
          ),
        ),
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
