import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';

/// Processing indicator widget with animation
class ProcessingIndicatorWidget extends StatefulWidget {
  const ProcessingIndicatorWidget({super.key});

  @override
  State<ProcessingIndicatorWidget> createState() => _ProcessingIndicatorWidgetState();
}

class _ProcessingIndicatorWidgetState extends State<ProcessingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                  ),
                ),
              );
            },
          ),
          AppSpacing.md,
          Text(
            "⚡ Analyse en cours...",
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "LOUNA traite votre document",
            style: AppTheme.bodySmall,
          ),
          AppSpacing.sm,
          // Progress steps
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStep("📄", "Scan", true),
              _buildStep("🔍", "Analyse", true),
              _buildStep("📝", "Extraction", false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String icon, String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Text(
            icon,
            style: TextStyle(
              fontSize: 20,
              color: isActive ? AppTheme.primaryColor : Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: isActive ? AppTheme.primaryColor : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}