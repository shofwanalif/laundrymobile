import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OfflineIndicator extends StatelessWidget {
  final VoidCallback onRetry;

  const OfflineIndicator({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.warning.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off,
            size: 20,
            color: AppColors.warning,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Offline',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
                Text(
                  'Menampilkan data terakhir yang tersimpan',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.warning.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warning,
              side: BorderSide(color: AppColors.warning),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'COBA LAGI',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}