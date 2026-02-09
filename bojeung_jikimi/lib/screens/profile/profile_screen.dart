import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../report/report_list_screen.dart';
import '../settings/settings_screen.dart';
import 'notice_screen.dart';
import 'faq_screen.dart';

// 내 정보 화면 (마이페이지)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 프로필 섹션 (상단)
          _buildProfileSection(),

          const SizedBox(height: 8),

          // 메뉴 리스트 (하단)
          Expanded(
            child: _buildMenuList(context),
          ),
        ],
      ),
    );
  }

  // 프로필 섹션
  Widget _buildProfileSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // 프로필 이미지
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // 이름
          const Text(
            '김건희 님',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),

          // 안전 등급 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🟢',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  '내 안전 등급: 안전',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 메뉴 리스트
  Widget _buildMenuList(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildMenuItem(
            context,
            icon: Icons.description_outlined,
            iconColor: AppColors.primary,
            title: '내 진단 리포트 보관함',
            onTap: () {
              // 리포트 보관함 리스트 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportListScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, thickness: 1),
          _buildMenuItem(
            context,
            icon: Icons.campaign_outlined,
            iconColor: const Color(0xFF1A237E), // Navy
            title: '공지사항',
            onTap: () {
              // 공지사항 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NoticeScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, thickness: 1),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            iconColor: const Color(0xFF00C853), // Green
            title: '자주 묻는 질문 (FAQ)',
            onTap: () {
              // FAQ 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FaqScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, thickness: 1),
          _buildMenuItem(
            context,
            icon: Icons.shield_outlined,
            iconColor: AppColors.primary,
            title: '안심 케어 (자산 보호)',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, thickness: 1),
          _buildMenuItem(
            context,
            icon: Icons.settings_outlined,
            iconColor: Colors.grey,
            title: '앱 설정',
            onTap: () {
              _showComingSoon(context, '앱 설정');
            },
          ),
          const Divider(height: 1, thickness: 1),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            iconColor: Colors.red,
            title: '로그아웃',
            titleColor: Colors.red,
            onTap: () {
              // 로그아웃 확인 다이얼로그
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // 메뉴 아이템
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.textDark,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  // 준비중 메시지
  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text('알림'),
          ],
        ),
        content: Text(
          '$feature 기능은 곧 제공될 예정입니다.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 로그아웃 확인 다이얼로그
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 12),
            Text('로그아웃'),
          ],
        ),
        content: const Text(
          '정말 로그아웃 하시겠습니까?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 로그아웃 로직 (추후 구현)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('로그아웃되었습니다'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
