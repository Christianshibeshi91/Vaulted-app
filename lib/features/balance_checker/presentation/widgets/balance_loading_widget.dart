import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/theme/typography.dart';

/// Premium loading animation for balance checks.
///
/// Displays a gold circular progress ring with a pulsing Vaulted logo
/// and status text. Transitions to a checkmark on success.
class BalanceLoadingWidget extends StatefulWidget {
  const BalanceLoadingWidget({
    super.key,
    this.isComplete = false,
    this.statusText = 'Checking your balance...',
  });

  final bool isComplete;
  final String statusText;

  @override
  State<BalanceLoadingWidget> createState() => _BalanceLoadingWidgetState();
}

class _BalanceLoadingWidgetState extends State<BalanceLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _pulseController;
  late AnimationController _checkController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(BalanceLoadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isComplete && !oldWidget.isComplete) {
      _ringController.stop();
      _pulseController.stop();
      _checkController.forward();
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    _pulseController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Gold progress ring
              if (!widget.isComplete)
                AnimatedBuilder(
                  animation: _ringController,
                  builder: (_, _) => CustomPaint(
                    size: const Size(100, 100),
                    painter: _GoldRingPainter(
                      progress: _ringController.value,
                    ),
                  ),
                ),

              // Checkmark on success
              if (widget.isComplete)
                AnimatedBuilder(
                  animation: _checkController,
                  builder: (_, _) => CustomPaint(
                    size: const Size(100, 100),
                    painter: _CheckmarkPainter(
                      progress: Curves.elasticOut
                          .transform(_checkController.value),
                    ),
                  ),
                ),

              // Pulsing V logo in center
              if (!widget.isComplete)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, child) => Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.05),
                    child: child,
                  ),
                  child: Text(
                    'V',
                    style: VaultedTypography.displayLarge.copyWith(
                      color: VaultedColors.accentGold,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        VaultedSpacing.gapLg,
        Text(
          widget.statusText,
          style: VaultedTypography.bodyMedium.copyWith(
            color: widget.isComplete
                ? VaultedColors.success
                : VaultedColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        )
            .animate(
              target: widget.isComplete ? 1 : 0,
            )
            .fadeIn(duration: 200.ms),
      ],
    );
  }
}

class _GoldRingPainter extends CustomPainter {
  _GoldRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background ring (dim)
    final bgPaint = Paint()
      ..color = const Color(0x1FC9A55A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Animated gold arc
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: const [
          Color(0xFFC9A55A),
          Color(0xFFE4C97A),
          Color(0xFFC9A55A),
        ],
        transform: GradientRotation(progress * math.pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final startAngle = progress * math.pi * 2 - math.pi / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      math.pi * 1.4,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_GoldRingPainter old) => old.progress != progress;
}

class _CheckmarkPainter extends CustomPainter {
  _CheckmarkPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Complete ring
    final ringPaint = Paint()
      ..color = const Color(0xFF4ADE80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, ringPaint);

    // Checkmark path
    if (progress > 0) {
      final checkPaint = Paint()
        ..color = const Color(0xFF4ADE80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      final startX = size.width * 0.28;
      final startY = size.height * 0.52;
      final midX = size.width * 0.44;
      final midY = size.height * 0.66;
      final endX = size.width * 0.72;
      final endY = size.height * 0.38;

      path.moveTo(startX, startY);

      if (progress < 0.5) {
        final t = progress * 2;
        path.lineTo(
          startX + (midX - startX) * t,
          startY + (midY - startY) * t,
        );
      } else {
        path.lineTo(midX, midY);
        final t = (progress - 0.5) * 2;
        path.lineTo(
          midX + (endX - midX) * t,
          midY + (endY - midY) * t,
        );
      }

      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(_CheckmarkPainter old) => old.progress != progress;
}
