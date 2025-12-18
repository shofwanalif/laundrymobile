import 'package:flutter/material.dart';
import '../../../data/models/service_model.dart';
import '../../../core/theme/app_colors.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? AppColors.darkCardBorder
              : AppColors.cardBorder,
        ),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildPriceTag(context),
                ],
              ),
              const SizedBox(height: 8),

              /// ================= DESCRIPTION =================
              Text(
                service.description,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              /// ================= FOOTER =================
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= PRICE TAG =================
  Widget _buildPriceTag(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatPrice(service.pricePerKg),
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  /// ================= FOOTER =================
  Widget _buildFooter(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 14,
          color: isDark
              ? AppColors.darkTextTertiary
              : AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          '${service.duration} • per Kg',
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.darkTextTertiary
                : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  /// ================= PRICE FORMAT =================
  String _formatPrice(int price) {
    if (price >= 1000) {
      final priceInK = price / 1000;
      return 'Rp ${priceInK.toStringAsFixed(
        price % 1000 == 0 ? 0 : 1,
      )}k';
    }
    return 'Rp $price';
  }
}
