import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../home/home_screen.dart';
import '../diagnosis/diagnosis_screen.dart';
import '../profile/profile_screen.dart';

// 메인 화면 (하단 탭 네비게이션)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 진단하기 탭으로 이동하는 함수
  void _navigateToDiagnosis() {
    setState(() => _selectedIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(onNavigateToDiagnosis: _navigateToDiagnosis),
          const DiagnosisScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_turned_in),
              label: '진단하기',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '내 정보',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.primary, // Navy
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}
