import 'package:flutter/material.dart';
import 'package:news_app/utils/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'general':
        return Icons.public;
      case 'technology':
        return Icons.computer;
      case 'business':
        return Icons.business_center;
      case 'sports':
        return Icons.sports_soccer;
      case 'health':
        return Icons.favorite;
      case 'science':
        return Icons.science;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(25),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                borderRadius: BorderRadius.circular(25),
                color: isSelected ? null : colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : colorScheme.outlineVariant,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(label),
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
