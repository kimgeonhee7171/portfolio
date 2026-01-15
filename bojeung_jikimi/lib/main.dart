import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ★ 사용자님의 CSS에서 가져온 색상들입니다!
class AppColors {
  static const Color primary = Color(0xFF1E40AF); // --primary-color (#1e40af)
  static const Color primaryLight = Color(0xFF3B82F6); // 밝은 블루
  static const Color background = Color(0xFFF8FAFC); // --bg-light (#f8fafc)
  static const Color textDark = Color(0xFF000000); // --text-dark
  static const Color textLight = Color(0xFF718096); // --text-light
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '보증지킴이',
      theme: ThemeData(
        // 앱의 메인 색상을 CSS와 동일하게 설정
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          background: AppColors.background,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background, // 배경색 적용
        // 입력창(TextField) 기본 스타일 잡기
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFCBD5E1),
            ), // --border-color
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),
    const DiagnosisTab(),
    const Center(child: Text('내 정보 준비중')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              label: '진단하기',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: '내 정보',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.primary,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}

// 1. 홈 탭 (깔끔하게 유지)
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '안녕하세요, 건희님! 👋',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text(
              '어떤 집의 안전도를\n분석해 드릴까요? 🏠',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.3,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 30),

            // 검색창 (그림자 추가)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: '도로명 주소나 아파트 검색',
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. ★ 진단하기 탭 (CSS 디자인 적용!) ★
class DiagnosisTab extends StatefulWidget {
  const DiagnosisTab({super.key});

  @override
  State<DiagnosisTab> createState() => _DiagnosisTabState();
}

class _DiagnosisTabState extends State<DiagnosisTab> {
  int _currentStep = 0;
  String _selectedType = '';

  void _nextStep() {
    if (_currentStep < 3) setState(() => _currentStep++);
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 상단 단계바
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / 4,
                      color: AppColors.primary,
                      backgroundColor: Colors.grey[200],
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  'Step ${_currentStep + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              // 배경 흰색 + 위쪽 둥글게 (카드 느낌)
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                child: _buildStepContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: // 1단계: 계약 유형
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '계약 유형을\n선택해주세요',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 30),
            _buildOptionCard(
              '월세',
              Icons.calendar_today_outlined,
              _selectedType == '월세',
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              '전세',
              Icons.home_work_outlined,
              _selectedType == '전세',
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              '매매',
              Icons.real_estate_agent_outlined,
              _selectedType == '매매',
            ),
          ],
        );
      case 1: // 2단계: 보증금
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '보증금은\n얼마인가요?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '0',
                suffixText: '만원',
                suffixStyle: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
                prefixIcon: const Icon(
                  Icons.attach_money,
                  color: AppColors.textLight,
                ),
              ),
            ),
            const Spacer(),
            _buildNextButton('다음으로'),
          ],
        );
      case 2: // 3단계: 주소
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '어느 집을\n알아볼까요?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 30),
            const TextField(
              decoration: InputDecoration(
                hintText: '주소 검색',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(hintText: '상세 주소 (동/호수)'),
            ),
            const Spacer(),
            _buildNextButton('무료로 리포트 받기'),
          ],
        );
      case 3: // 4단계: 결과 (HTML 그라데이션 적용!)
        return SingleChildScrollView(
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              const Text(
                '신청이 완료되었습니다!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '담당 매니저가 등기부등본을 확인 후\n24시간 내에 연락드립니다.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 40),

              // ★ CSS의 .payment-info-card 스타일 구현 (그라데이션)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF0F9FF),
                      Color(0xFFE0F2FE),
                    ], // HTML의 그라데이션 색상
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF3B82F6),
                    width: 1.5,
                  ), // 파란 테두리
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '현재 리포트 무료 이벤트 중! 🎉',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          '13,900원',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '0원 (무료)',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _currentStep = 0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // 처음으로 버튼은 검정색
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '처음으로 돌아가기',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return Container();
    }
  }

  // 선택 옵션 카드 위젯
  Widget _buildOptionCard(String title, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedType = title);
        Future.delayed(const Duration(milliseconds: 200), _nextStep);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textDark,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  // 다음 버튼 위젯
  Widget _buildNextButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // --primary-color
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
