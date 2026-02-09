import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 안전도 점수(0~100)를 반원 게이지로 표시하는 위젯
/// - 0~70: 위험(빨강), 70~80: 주의(노랑), 80~100: 안전(초록)
/// - 바늘 애니메이션으로 점수 위치 표시
class SafetyGaugeChart extends StatefulWidget {
  final int score; // 0~100
  final Color gradeColor; // 현재 등급 색상
  final double size;

  const SafetyGaugeChart({
    super.key,
    required this.score,
    required this.gradeColor,
    this.size = 240,
  });

  @override
  State<SafetyGaugeChart> createState() => _SafetyGaugeChartState();
}

class _SafetyGaugeChartState extends State<SafetyGaugeChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _needleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _needleAnimation = Tween<double>(begin: 0, end: widget.score.clamp(0, 100) / 100)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant SafetyGaugeChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      final endValue = widget.score.clamp(0, 100) / 100;
      _needleAnimation = Tween<double>(
        begin: _needleAnimation.value,
        end: endValue,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size * 0.65,
      child: AnimatedBuilder(
        animation: _needleAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _GaugePainter(
              value: _needleAnimation.value,
              gradeColor: widget.gradeColor,
            ),
            size: Size(widget.size, widget.size * 0.65),
          );
        },
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value; // 0.0 ~ 1.0
  final Color gradeColor;

  _GaugePainter({required this.value, required this.gradeColor});

  static const Color _green = Color(0xFF00C853);
  static const Color _amber = Color(0xFFFFA726);
  static const Color _red = Color(0xFFEF5350);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 8);
    final radius = size.width * 0.42;
    const startAngle = math.pi; // 180° (왼쪽)
    const sweepAngle = math.pi; // 180° (반원)

    // 1. 배경 트랙 (연한 회색)
    final trackPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // 2. 구간별 컬러 아크 (0~70%=위험, 70~80%=주의, 80~100%=안전)
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    // 빨강: 0~70% (180° → 54°)
    arcPaint.color = _red;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * 0.70,
      false,
      arcPaint,
    );
    // 노랑: 70~80%
    arcPaint.color = _amber;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sweepAngle * 0.70,
      sweepAngle * 0.10,
      false,
      arcPaint,
    );
    // 초록: 80~100%
    arcPaint.color = _green;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sweepAngle * 0.80,
      sweepAngle * 0.20,
      false,
      arcPaint,
    );

    // 3. 바늘: value 0→1 에 따라 180°→0°
    final needleAngle = startAngle - (value * sweepAngle);
    final needleLength = radius - 12;
    final needleTip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy - needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = gradeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleTip, needlePaint);

    // 바늘 끝 원 (시각적 강조)
    final tipPaint = Paint()..color = gradeColor;
    canvas.drawCircle(needleTip, 6, tipPaint);
    canvas.drawCircle(needleTip, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.gradeColor != gradeColor;
  }
}
