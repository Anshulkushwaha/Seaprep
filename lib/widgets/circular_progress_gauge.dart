import 'dart:math';
import 'package:flutter/material.dart';

class CircularProgressGauge extends StatefulWidget {
  final double percentage; // 0 to 100
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;
  final String centerLabel;
  final String? centerSubtitle;
  final TextStyle? labelTextStyle;

  const CircularProgressGauge({
    super.key,
    required this.percentage,
    this.size = 180,
    this.strokeWidth = 12,
    this.progressColor = const Color(0xFF0074D9),
    this.backgroundColor = const Color(0xFFE0E7ED),
    required this.centerLabel,
    this.centerSubtitle,
    this.labelTextStyle,
  });

  @override
  State<CircularProgressGauge> createState() => _CircularProgressGaugeState();
}

class _CircularProgressGaugeState extends State<CircularProgressGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0, end: widget.percentage).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(CircularProgressGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.percentage,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GaugePainter(
                  percentage: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  progressColor: widget.progressColor,
                  backgroundColor: widget.backgroundColor,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _animation.value.toInt().toString(),
                        style: widget.labelTextStyle ??
                            TextStyle(
                              fontSize: widget.size * 0.26,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF000613),
                              height: 1.0,
                            ),
                      ),
                      Text(
                        '%',
                        style: TextStyle(
                          fontSize: widget.size * 0.14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF000613),
                        ),
                      ),
                    ],
                  ),
                  if (widget.centerSubtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.centerSubtitle!,
                      style: TextStyle(
                        fontSize: widget.size * 0.08,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF43474E),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  _GaugePainter({
    required this.percentage,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    // Background track circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc starting from top (-pi / 2)
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
