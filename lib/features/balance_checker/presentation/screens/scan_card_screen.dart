import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/radii.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/haptics.dart';

/// Camera-based card scanner screen.
///
/// Attempts barcode/QR scan first via [MobileScanner]. If a barcode
/// containing digits is detected, it returns the extracted number.
class ScanCardScreen extends StatefulWidget {
  const ScanCardScreen({super.key});

  /// Shows the scanner and returns the scanned card number, or null.
  static Future<String?> show(BuildContext context) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanCardScreen()),
    );
  }

  @override
  State<ScanCardScreen> createState() => _ScanCardScreenState();
}

class _ScanCardScreenState extends State<ScanCardScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;

      // Extract digits from the barcode
      final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length >= 4) {
        _scanned = true;
        Haptics.success();
        Navigator.of(context).pop(digits);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera feed
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Dark overlay with card-shaped cutout
          Positioned.fill(
            child: CustomPaint(
              painter: _CardOverlayPainter(),
            ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl,
                  vertical: VaultedSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _controller.toggleTorch(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: ValueListenableBuilder(
                          valueListenable: _controller,
                          builder: (_, state, _) => Icon(
                            state.torchState == TorchState.on
                                ? Icons.flash_on
                                : Icons.flash_off,
                            color: state.torchState == TorchState.on
                                ? VaultedColors.accentGold
                                : Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom instruction
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(VaultedSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: VaultedSpacing.lg,
                        vertical: VaultedSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: VaultedRadii.brCard,
                      ),
                      child: Text(
                        'Position the barcode within the frame',
                        style: VaultedTypography.bodyMedium.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, curve: Curves.easeOut),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a dark overlay with a card-shaped transparent cutout.
class _CardOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Full overlay
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Card cutout (credit card aspect ratio ~1.586)
    final cardWidth = size.width * 0.82;
    final cardHeight = cardWidth / 1.586;
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 - 30),
        width: cardWidth,
        height: cardHeight,
      ),
      const Radius.circular(16),
    );

    // Draw overlay with cutout
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(cardRect);
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Draw gold border around cutout
    final borderPaint = Paint()
      ..color = const Color(0xFFC9A55A).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(cardRect, borderPaint);

    // Corner accents
    final cornerPaint = Paint()
      ..color = const Color(0xFFC9A55A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect = cardRect.outerRect;
    const len = 24.0;
    const r = 16.0;

    // Top-left
    canvas.drawLine(
      Offset(rect.left, rect.top + r + len),
      Offset(rect.left, rect.top + r),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left + r, rect.top),
      Offset(rect.left + r + len, rect.top),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(rect.right - r - len, rect.top),
      Offset(rect.right - r, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top + r),
      Offset(rect.right, rect.top + r + len),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(rect.left, rect.bottom - r - len),
      Offset(rect.left, rect.bottom - r),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left + r, rect.bottom),
      Offset(rect.left + r + len, rect.bottom),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(rect.right - r - len, rect.bottom),
      Offset(rect.right - r, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom - r),
      Offset(rect.right, rect.bottom - r - len),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
