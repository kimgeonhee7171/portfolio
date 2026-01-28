import 'package:flutter/material.dart';

// 계약 체크리스트 화면
class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  // 체크리스트 데이터 (카테고리별)
  final Map<String, List<ChecklistItem>> _checklistData = {
    '방문 시': [
      ChecklistItem(title: '수압 체크하기', isChecked: false),
      ChecklistItem(title: '곰팡이 확인하기', isChecked: false),
      ChecklistItem(title: '채광 확인하기', isChecked: false),
    ],
    '계약 시': [
      ChecklistItem(title: '신분증 진위 확인하기', isChecked: false),
      ChecklistItem(title: '등기부등본 날짜 확인하기', isChecked: false),
      ChecklistItem(title: '특약사항 기재 여부 확인하기', isChecked: false),
    ],
    '잔금 시': [
      ChecklistItem(title: '이체 한도 확인하기', isChecked: false),
      ChecklistItem(title: '영수증 챙기기', isChecked: false),
    ],
  };

  // 전체 진행률 계산
  double get _progressPercentage {
    int totalItems = 0;
    int checkedItems = 0;

    _checklistData.forEach((category, items) {
      totalItems += items.length;
      checkedItems += items.where((item) => item.isChecked).length;
    });

    return totalItems > 0 ? checkedItems / totalItems : 0.0;
  }

  int get _checkedCount {
    int count = 0;
    _checklistData.forEach((category, items) {
      count += items.where((item) => item.isChecked).length;
    });
    return count;
  }

  int get _totalCount {
    int count = 0;
    _checklistData.forEach((category, items) {
      count += items.length;
    });
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
        title: const Text(
          '계약 체크리스트',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1A237E),
          ),
        ),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // 진행률 카드
          _buildProgressCard(),

          // 체크리스트
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _checklistData.entries.map((entry) {
                return _buildCategorySection(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 진행률 카드
  Widget _buildProgressCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A237E).withValues(alpha: 0.1),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '전체 진행률',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              Text(
                '${(_progressPercentage * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00C853), // Green
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progressPercentage,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00C853), // Green
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _progressPercentage == 1.0
                    ? '모든 준비가 완료되었습니다!'
                    : '현재 ${(_progressPercentage * 100).toInt()}% 준비되었습니다',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _progressPercentage == 1.0
                      ? const Color(0xFF00C853)
                      : Colors.grey[700],
                ),
              ),
              if (_progressPercentage == 1.0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '완료!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  '$_checkedCount/$_totalCount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 카테고리 섹션
  Widget _buildCategorySection(String category, List<ChecklistItem> items) {
    final categoryColor = category == '방문 시'
        ? Colors.blue
        : category == '계약 시'
            ? Colors.orange
            : Colors.purple;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // 카테고리 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    category == '방문 시'
                        ? Icons.home_outlined
                        : category == '계약 시'
                            ? Icons.description_outlined
                            : Icons.payments_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
          ),

          // 체크리스트 아이템들
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                CheckboxListTile(
                  value: item.isChecked,
                  onChanged: (value) {
                    setState(() {
                      item.isChecked = value ?? false;
                    });
                  },
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: item.isChecked ? Colors.grey[500] : Colors.black87,
                      decoration: item.isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationThickness: 2,
                    ),
                  ),
                  activeColor: const Color(0xFF00C853), // Green
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                ),
                if (index < items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 56,
                    color: Colors.grey[200],
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// 체크리스트 아이템 모델
class ChecklistItem {
  final String title;
  bool isChecked;

  ChecklistItem({
    required this.title,
    required this.isChecked,
  });
}
