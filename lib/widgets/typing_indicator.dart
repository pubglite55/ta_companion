import 'package:flutter/material.dart';
import '../config/colors.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dot1;
  late Animation<double> _dot2;
  late Animation<double> _dot3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _dot1 = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5)),
    );
    _dot2 = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.7)),
    );
    _dot3 = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.9)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'TA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDot(_dot1.value),
                    const SizedBox(width: 4),
                    _buildDot(_dot2.value),
                    const SizedBox(width: 4),
                    _buildDot(_dot3.value),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(double offset) {
    return Transform.translate(
      offset: Offset(0, offset),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
