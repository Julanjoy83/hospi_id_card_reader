import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';

/// Data extraction result widget with NFC writing functionality
class ExtractionResultWidget extends StatelessWidget {
  const ExtractionResultWidget({
    super.key,
    required this.data,
    required this.onNfcWritePressed,
    this.isWritingNfc = false,
  });

  final Map<String, String> data;
  final VoidCallback onNfcWritePressed;
  final bool isWritingNfc;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: AppTheme.successGradientDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppTheme.onPrimaryTextColor,
                  size: 20,
                ),
              ),
              AppSpacing.md,
              Expanded(
                child: Text(
                  "✅ Informations extraites avec succès !",
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.successColor,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.lg,

          // Extracted data display
          _buildDataDisplay(),
          AppSpacing.lg,

          // NFC write button
          _buildNfcWriteButton(),
        ],
      ),
    );
  }

  Widget _buildDataDisplay() {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📋 Données du document",
            style: AppTheme.labelLarge.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
          AppSpacing.sm,
          const Divider(),
          AppSpacing.sm,
          ...data.entries.map((entry) => _buildDataRow(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildDataRow(String key, String value) {
    // Skip empty values
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "${_formatFieldName(key)}:",
              style: AppTheme.labelLarge.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          AppSpacing.sm,
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Text(
                value,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFieldName(String key) {
    switch (key.toLowerCase()) {
      case 'name':
        return 'Prénom';
      case 'surname':
        return 'Nom';
      case 'idnumber':
        return 'N° ID';
      case 'nationality':
        return 'Nationalité';
      case 'dateofbirth':
        return 'Naissance';
      case 'expirationdate':
        return 'Expiration';
      case 'documenttype':
        return 'Type doc';
      default:
        return key;
    }
  }

  Widget _buildNfcWriteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: isWritingNfc
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.onPrimaryTextColor),
                ),
              )
            : const Icon(Icons.nfc, size: 24),
        label: Text(
          isWritingNfc ? "Préparation en cours..." : "🏨 Créer ma carte de chambre",
          style: AppTheme.headingSmall.copyWith(
            color: AppTheme.onPrimaryTextColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isWritingNfc ? AppTheme.warningColor : AppTheme.accentColor,
          foregroundColor: AppTheme.onPrimaryTextColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          elevation: 6,
          shadowColor: AppTheme.accentColor.withOpacity(0.4),
        ),
        onPressed: isWritingNfc ? null : onNfcWritePressed,
      ),
    );
  }
}