import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';

/// Welcome message widget
class WelcomeMessageWidget extends StatelessWidget {
  const WelcomeMessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingMd,
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Text(
            "Bonjour ! Je suis LOUNA",
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.sm,
          Row(
            children: [
              Expanded(
                child: _buildStepCard("1️⃣ Scanner ID", AppTheme.accentColor),
              ),
              AppSpacing.sm,
              Expanded(
                child: _buildStepCard("2️⃣ Carte chambre", AppTheme.primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.smallBorderRadius),
      ),
      child: Text(
        text,
        style: AppTheme.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}