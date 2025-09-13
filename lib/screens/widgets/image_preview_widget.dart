import 'dart:io';
import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';

/// Image preview widget with enhanced styling
class ImagePreviewWidget extends StatelessWidget {
  const ImagePreviewWidget({
    super.key,
    required this.imageFile,
  });

  final File imageFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.verticalPaddingMd,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Column(
          children: [
            // Image preview
            Image.file(
              imageFile,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Image info bar
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingSm,
              color: AppTheme.primaryColor.withOpacity(0.9),
              child: Row(
                children: [
                  const Icon(
                    Icons.photo,
                    color: AppTheme.onPrimaryTextColor,
                    size: 16,
                  ),
                  AppSpacing.xs,
                  Expanded(
                    child: Text(
                      "Document scanné • ${_getImageSize(imageFile)}",
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.onPrimaryTextColor,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getImageSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '${bytes}B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } catch (e) {
      return 'Taille inconnue';
    }
  }
}