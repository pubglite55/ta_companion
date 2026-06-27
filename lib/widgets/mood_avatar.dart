import 'package:flutter/material.dart';
import '../models/mood.dart';
import '../config/colors.dart';

class MoodAvatar extends StatelessWidget {
  final Mood mood;
  final double size;

  const MoodAvatar({
    super.key,
    required this.mood,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(mood.type),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(),
          ),
          boxShadow: [
            BoxShadow(
              color: _getGradientColors().first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            mood.emoji,
            style: TextStyle(fontSize: size * 0.5),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (mood.type) {
      case MoodType.happy:
        return [AppColors.accent, const Color(0xFFFFB347)];
      case MoodType.sad:
        return [const Color(0xFF6B7B8D), const Color(0xFF4A5568)];
      case MoodType.sleepy:
        return [const Color(0xFF9F7AEA), const Color(0xFF6B46C1)];
      case MoodType.sweet:
        return [const Color(0xFFED64A6), const Color(0xFFD53F8C)];
      case MoodType.thinking:
        return [const Color(0xFF4299E1), const Color(0xFF3182CE)];
      case MoodType.calm:
        return [AppColors.accentGreen, const Color(0xFF9AE6B4)];
    }
  }
}
