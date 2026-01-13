import 'package:flutter/material.dart';

/// 홈 화면
/// 메인 랜딩 페이지
class HomeScreen extends StatefulWidget {
  final String? scrollToSection;

  const HomeScreen({super.key, this.scrollToSection});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 특정 섹션으로 스크롤
    if (widget.scrollToSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSection(widget.scrollToSection!);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 특정 섹션으로 스크롤
  void _scrollToSection(String sectionId) {
    // 실제 구현은 섹션 위치를 계산하여 스크롤
    // 예: _scrollController.animateTo(position, ...)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(),
            
            // Problem Solution Section
            _buildProblemSolutionSection(),
            
            // Curiosity Section
            _buildCuriositySection(),
            
            // Safety Score Section
            _buildSafetyScoreSection(),
            
            // Trust Section
            _buildTrustSection(),
            
            // Testimonials Section
            _buildTestimonialsSection(),
            
            // FAQ Section
            _buildFaqSection(),
            
            // Urgency Section
            _buildUrgencySection(),
            
            // Purchase Section
            _buildPurchaseSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      key: const ValueKey('hero'),
      height: MediaQuery.of(context).size.height,
      // Hero Section UI 구현
      child: const Center(child: Text('Hero Section')),
    );
  }

  Widget _buildProblemSolutionSection() {
    return Container(
      key: const ValueKey('problem-solution'),
      height: 600,
      // Problem Solution Section UI 구현
      child: const Center(child: Text('Problem Solution Section')),
    );
  }

  Widget _buildCuriositySection() {
    return Container(
      key: const ValueKey('curiosity'),
      height: 600,
      // Curiosity Section UI 구현
      child: const Center(child: Text('Curiosity Section')),
    );
  }

  Widget _buildSafetyScoreSection() {
    return Container(
      key: const ValueKey('safety-score-section'),
      height: 600,
      // Safety Score Section UI 구현
      child: const Center(child: Text('Safety Score Section')),
    );
  }

  Widget _buildTrustSection() {
    return Container(
      key: const ValueKey('trust'),
      height: 600,
      // Trust Section UI 구현
      child: const Center(child: Text('Trust Section')),
    );
  }

  Widget _buildTestimonialsSection() {
    return Container(
      key: const ValueKey('testimonials'),
      height: 600,
      // Testimonials Section UI 구현
      child: const Center(child: Text('Testimonials Section')),
    );
  }

  Widget _buildFaqSection() {
    return Container(
      key: const ValueKey('faq-section'),
      height: 600,
      // FAQ Section UI 구현
      child: const Center(child: Text('FAQ Section')),
    );
  }

  Widget _buildUrgencySection() {
    return Container(
      key: const ValueKey('urgency-section'),
      height: 600,
      // Urgency Section UI 구현
      child: const Center(child: Text('Urgency Section')),
    );
  }

  Widget _buildPurchaseSection() {
    return Container(
      key: const ValueKey('purchase'),
      height: 600,
      // Purchase Section UI 구현
      child: const Center(child: Text('Purchase Section')),
    );
  }
}
