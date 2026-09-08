import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../constants/colors.dart';
import '../models/product.dart';

class ProductRowCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ProductRowCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    final formattedPrice = '${currencyFormatter.format(product.price)} د.ج';
    final hasComparePrice = product.compareAtPrice != null && product.compareAtPrice! > product.price;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E1B4B).withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 70,
                  height: 70,
                  color: AppColors.primaryBg,
                  child: product.images.isNotEmpty
                      ? Image.network(
                          product.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(LucideIcons.image, size: 24, color: AppColors.primary),
                          ),
                        )
                      : const Center(
                          child: Icon(LucideIcons.image, size: 24, color: AppColors.primary),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      product.titleAr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Text(
                          formattedPrice,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        if (hasComparePrice) ...[
                          const SizedBox(width: 6),
                          Text(
                            '${currencyFormatter.format(product.compareAtPrice)} د.ج',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: product.stockQuantity > 5 ? AppColors.success : AppColors.danger,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'المخزون: ${product.stockQuantity}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: product.stockQuantity > 5 ? AppColors.textSub : AppColors.danger,
                          ),
                        ),
                        if (product.isFeatured) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.warningBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'مميز ⭐',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.warning),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Trailing arrow
              const Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
