import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';

/// Action buttons widget for camera and gallery with proper permissions
class ActionButtonsWidget extends StatelessWidget {
  const ActionButtonsWidget({
    super.key,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    this.isSpeaking = false,
  });

  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final bool isSpeaking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  icon: Icons.photo_library_rounded,
                  label: "Galerie",
                  color: Colors.orange.shade600,
                  onPressed: onGalleryPressed,
                ),
              ),
              AppSpacing.md,
              Expanded(
                child: ActionButton(
                  icon: Icons.camera_alt_rounded,
                  label: "Caméra",
                  color: AppTheme.primaryColor,
                  onPressed: onCameraPressed,
                ),
              ),
            ],
          ),
          if (isSpeaking) ...[
            AppSpacing.sm,
            const SpeakingIndicator(),
          ],
        ],
      ),
    );
  }
}

/// Individual action button with enhanced styling
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppTheme.onPrimaryTextColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        elevation: 4,
        shadowColor: color.withOpacity(0.4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTheme.iconSize),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.onPrimaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Speaking indicator widget
class SpeakingIndicator extends StatelessWidget {
  const SpeakingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.successColor.withOpacity(0.1),
            AppTheme.successColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.largeBorderRadius),
        border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.successColor),
            ),
          ),
          AppSpacing.sm,
          Text(
            "🎤 LOUNA vous parle...",
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.successColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}