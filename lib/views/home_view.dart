import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/widgets/animated_list_item.dart';
import 'package:news_app/widgets/category_chip.dart';
import 'package:news_app/widgets/loading_shimmer.dart';
import 'package:news_app/widgets/news_card.dart';

class HomeView extends GetView<NewsController> {
  const HomeView({super.key});

  void _loadMoreIfNeeded(ScrollNotification notification) {
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 500) {
      controller.loadMoreNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Category filters
            _buildCategoryBar(context),

            // News list
            Expanded(
              child: Obx(() {
                if (controller.isLoading) {
                  return const LoadingShimmer();
                }

                if (controller.error.isNotEmpty) {
                  return _buildErrorWidget();
                }

                if (controller.articles.isEmpty) {
                  return _buildEmptyWidget();
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshNews,
                  color: colorScheme.primary,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      _loadMoreIfNeeded(notification);
                      return false;
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: controller.articles.length + 1,
                      itemBuilder: (context, index) {
                        if (index == controller.articles.length) {
                          return _buildLoadMoreFooter();
                        }

                        final article = controller.articles[index];
                        return AnimatedListItem(
                          index: index,
                          child: NewsCard(
                            article: article,
                            onTap: () {
                              Get.toNamed(
                                Routes.NEWS_DETAIL,
                                arguments: article,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreFooter() {
    return Obx(() {
      if (controller.isLoadingMore) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      if (!controller.hasMore) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'No more stories available right now',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 20),
        child: OutlinedButton.icon(
          onPressed: controller.loadMoreNews,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Load newer stories'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.newspaper_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NewsHub',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Top Headlines',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Quick access to the full search experience.
          InkWell(
            onTap: () => Get.toNamed(Routes.SEARCH),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(minWidth: 92),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 19,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Search',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Notification-style icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 64,
      color: colorScheme.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Obx(
            () => CategoryChip(
              label: category.capitalize ?? category,
              isSelected: controller.selectedCategory == category,
              onTap: () => controller.selectCategory(category),
            ),
          );
        },
      ),
    );
  }

  // Error state
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your internet connection\nand try again',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: controller.refreshNews,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty state
  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.article_outlined,
                size: 48,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No news available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pull down to refresh',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
