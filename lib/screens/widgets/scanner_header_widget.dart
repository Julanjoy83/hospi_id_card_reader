import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';

/// Header widget for the document scanner screen
class ScannerHeaderWidget extends StatelessWidget {
  const ScannerHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingMd,
      decoration: AppTheme.primaryGradientDecoration,
      child: Row(
        children: [
          // Logo container
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Ibis_Styles_Logo.png/1200px-Ibis_Styles_Logo.png?20200720215646',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.hotel,
                      size: 30,
                      color: AppTheme.accentColor,
                    );
                  },
                ),
              ),
            ),
          ),
          AppSpacing.md,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Check-in Intelligent",
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.onPrimaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}