import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

/// 라우터 서비스
/// SPA 라우팅 및 페이지 전환 관리
class RouterService {
  // 라우트 경로 상수
  static const String home = '/';
  static const String about = '/about';
  static const String services = '/services';
  static const String cases = '/cases';
  static const String contact = '/contact';

  // 섹션 ID 매핑
  static const Map<String, String> sectionMap = {
    'home': 'hero',
    'about': 'problem-solution',
    'services': 'curiosity',
    'cases': 'testimonials',
    'contact': 'faq-section',
  };

  // RouteObserver for navigation tracking
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  /// 라우트 생성
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final String? routeName = settings.name;
    final Map<String, dynamic>? arguments = settings.arguments as Map<String, dynamic>?;

    switch (routeName) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      
      case about:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(scrollToSection: 'problem-solution'),
          settings: settings,
        );
      
      case services:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(scrollToSection: 'curiosity'),
          settings: settings,
        );
      
      case cases:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(scrollToSection: 'testimonials'),
          settings: settings,
        );
      
      case contact:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(scrollToSection: 'faq-section'),
          settings: settings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
    }
  }

  /// 페이지 네비게이션
  static void navigate(BuildContext context, String routeName, {Map<String, dynamic>? arguments}) {
    Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// 섹션으로 스크롤
  static void scrollToSection(BuildContext context, String sectionId) {
    // HomeScreen의 ScrollController를 통해 스크롤
    // 실제 구현은 HomeScreen에서 처리
  }
}
