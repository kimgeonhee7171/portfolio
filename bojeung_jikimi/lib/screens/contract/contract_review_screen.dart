import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// 계약서 검토 화면 (AI 스캔 시뮬레이션)
class ContractReviewScreen extends StatefulWidget {
  const ContractReviewScreen({super.key});

  @override
  State<ContractReviewScreen> createState() => _ContractReviewScreenState();
}

class _ContractReviewScreenState extends State<ContractReviewScreen>
    with SingleTickerProviderStateMixin {
  // 0: 초기, 1: 분석 중, 2: 분석 결과
  int _state = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startScan() async {
    if (_state != 0) return;

    setState(() => _state = 1);

    // 2초 동안 로딩 다이얼로그
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'AI가 계약서를 스캔하고 있습니다...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.of(context).pop();

    setState(() => _state = 2);
    _animationController.forward();
  }

  /// 초기 화면으로 재설정 (다른 계약서 검토)
  void _resetScan() {
    _animationController.reset();
    setState(() => _state = 0);
  }

  /// 업로드 방식 선택 모달 (사진 촬영 / 갤러리 / 파일)
  void _showUploadOptions() {
    if (_state != 0) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Text(
                '계약서 업로드 방식',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('사진 촬영하기'),
                onTap: () {
                  Navigator.pop(context);
                  _startScan();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('갤러리에서 선택하기'),
                onTap: () {
                  Navigator.pop(context);
                  _startScan();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.folder_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('파일에서 찾기'),
                onTap: () {
                  Navigator.pop(context);
                  _startScan();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '계약서 검토',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: _state == 0
          ? _buildInitialState()
          : _state == 1
          ? _buildLoadingState()
          : _buildResultState(),
    );
  }

  // 상태 1: 초기 화면 (사진 찍기 전)
  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              '계약서를 촬영하거나\n이미지를 업로드해주세요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _showUploadOptions,
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(20),
                dashPattern: const [10, 6],
                color: AppColors.primary.withValues(alpha: 0.5),
                strokeWidth: 2.5,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 80,
                    horizontal: 32,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '계약서 촬영/업로드',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '표준임대차계약서, 특약란까지\n전체가 보이도록 촬영해주세요',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 상태 2: 분석 중 (로딩 시 body에 아무것도 안 보이거나 빈 화면)
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('분석 중...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // 상태 3: 분석 결과
  Widget _buildResultState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 계약서 이미지 Placeholder + AI 하이라이트
          _buildContractImageWithHighlights(),
          const SizedBox(height: 24),
          // 분석 결과 요약
          _buildAnalysisSummary(),
          const SizedBox(height: 32),
          // 다른 계약서 검토하기 (재설정)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _resetScan,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('다른 계약서 검토하기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildContractImageWithHighlights() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(opacity: _fadeAnimation.value, child: child);
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 계약서 이미지 Placeholder
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  color: Colors.grey[100],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '계약서 이미지',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // AI 하이라이트 박스 (애니메이션)
              ..._buildHighlightOverlays(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHighlightOverlays() {
    return [
      // 상단: 표준 양식 확인 구간
      Positioned(
        top: 20,
        left: 20,
        right: 20,
        child: _AnimatedHighlightBox(
          delay: 200,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.8),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      // 중간: 필수 특약 확인 구간
      Positioned(
        top: 100,
        left: 20,
        right: 20,
        child: _AnimatedHighlightBox(
          delay: 400,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.8),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      // 하단: 주의 구간 (독소조항)
      Positioned(
        bottom: 80,
        left: 20,
        right: 20,
        child: _AnimatedHighlightBox(
          delay: 600,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.9),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.orange.withValues(alpha: 0.1),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildAnalysisSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '분석 결과 요약',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryItem(
            Icons.check_circle,
            AppColors.accent,
            '표준임대차계약서 양식 확인',
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            Icons.check_circle,
            AppColors.accent,
            '필수 특약사항 포함됨',
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            Icons.warning_amber_rounded,
            Colors.orange,
            '[주의] 독소조항 의심 구간 1건 발견 (특약란 확인 필요)',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// 애니메이션으로 나타나는 하이라이트 박스
class _AnimatedHighlightBox extends StatefulWidget {
  final int delay;
  final Widget child;

  const _AnimatedHighlightBox({required this.delay, required this.child});

  @override
  State<_AnimatedHighlightBox> createState() => _AnimatedHighlightBoxState();
}

class _AnimatedHighlightBoxState extends State<_AnimatedHighlightBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_animation),
        child: widget.child,
      ),
    );
  }
}
