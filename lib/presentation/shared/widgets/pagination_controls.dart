import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/domain/entities/pagination.dart';

/// Shared component untuk pagination controls
class PaginationControls extends StatelessWidget {
  final PaginationMeta meta;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Function(int)? onPageSelect;

  const PaginationControls({
    Key? key,
    required this.meta,
    this.onPrevious,
    this.onNext,
    this.onPageSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // Info text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Menampilkan ${_getStartItem()}-${_getEndItem()} dari ${meta.total} data',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              _buildNavButton(
                icon: Icons.chevron_left,
                onPressed: meta.hasPreviousPage ? onPrevious : null,
              ),

              const SizedBox(width: 12),

              // Page numbers
              ..._buildPageNumbers(),

              const SizedBox(width: 12),

              // Next button
              _buildNavButton(
                icon: Icons.chevron_right,
                onPressed: meta.hasNextPage ? onNext : null,
                isReversed: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool isReversed = false,
  }) {
    final isEnabled = onPressed != null;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled
            ? AppColors.primary
            : AppColors.backgroundLight,
        foregroundColor: isEnabled ? Colors.white : AppColors.textLight,
        elevation: 0,
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusSM,
          side: BorderSide(
            color: isEnabled ? AppColors.primary : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isReversed
            ? [
                Icon(icon, size: 16),
              ]
            : [
                Icon(icon, size: 16),
              ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final pages = <Widget>[];
    final totalPages = meta.lastPage;
    final currentPage = meta.currentPage;

    // Show max 3 page numbers
    int startPage = (currentPage - 1).clamp(1, totalPages);
    int endPage = (currentPage + 1).clamp(1, totalPages);

    // Adjust if at start or end
    if (endPage - startPage < 2) {
      if (startPage == 1) {
        endPage = (startPage + 2).clamp(1, totalPages);
      } else if (endPage == totalPages) {
        startPage = (endPage - 2).clamp(1, totalPages);
      }
    }

    // Show first page if not in range
    if (startPage > 1) {
      pages.add(_buildPageButton(1));
      if (startPage > 2) {
        pages.add(_buildEllipsis());
      }
    }

    // Show page numbers
    for (int i = startPage; i <= endPage; i++) {
      pages.add(_buildPageButton(i));
    }

    // Show last page if not in range
    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pages.add(_buildEllipsis());
      }
      pages.add(_buildPageButton(totalPages));
    }

    return pages;
  }

  Widget _buildPageButton(int page) {
    final isActive = page == meta.currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: AppRadius.radiusSM,
        child: InkWell(
          onTap: isActive ? null : () => onPageSelect?.call(page),
          borderRadius: AppRadius.radiusSM,
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: AppRadius.radiusSM,
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.borderLight,
              ),
            ),
            child: Text(
              page.toString(),
              style: AppTextStyles.caption.copyWith(
                color: isActive ? Colors.white : AppColors.textMedium,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '...',
        style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
      ),
    );
  }

  int _getStartItem() {
    if (meta.total == 0) return 0;
    return ((meta.currentPage - 1) * meta.perPage) + 1;
  }

  int _getEndItem() {
    final end = meta.currentPage * meta.perPage;
    return end > meta.total ? meta.total : end;
  }
}
