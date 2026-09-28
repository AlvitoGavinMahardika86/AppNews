import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/widgets/animated_list_item.dart';
import 'package:news_app/widgets/news_card.dart';

class SearchView extends GetView<NewsController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Search header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Search for news around the world',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  _buildSearchBar(context),
                ],
              ),
            ),

            // Results / Recent Searches
            Expanded(
              child: Obx(() {
                final query = controller.searchQuery;

                if (query.isEmpty) {
                  return _buildRecentSearches();
                }

                if (controller.isSearching) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (controller.searchResults.isEmpty) {
                  return _buildNoResults(query);
                }

                return _buildSearchResults();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textController = TextEditingController(text: controller.searchQuery);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Obx(() {
        // Keep cursor position consistent
        if (textController.text != controller.searchQuery) {
          textController.text = controller.searchQuery;
          textController.selection = TextSelection.fromPosition(
            TextPosition(offset: textController.text.length),
          );
        }
        return TextField(
          controller: textController,
          onChanged: controller.updateSearchQuery,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              controller.searchNews(value.trim());
            }
          },
          textInputAction: TextInputAction.search,
          style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Search articles, topics...',
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 15),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textHint,
            ),
            suffixIcon: controller.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      textController.clear();
                      controller.clearSearch();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRecentSearches() {
    return Obx(() {
      final searches = controller.recentSearches;

      if (searches.isEmpty) {
        return Center(
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
                  Icons.search_rounded,
                  size: 48,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Start searching',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Find news that matters to you',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: controller.clearRecentSearches,
                  child: const Text(
                    'Clear all',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: searches.length,
                itemBuilder: (context, index) {
                  final query = searches[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.history_rounded,
                      color: AppColors.textHint,
                    ),
                    title: Text(
                      query,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textHint,
                      ),
                      onPressed: () => controller.removeRecentSearch(query),
                    ),
                    onTap: () => controller.searchNews(query),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final article = controller.searchResults[index];
        return AnimatedListItem(
          index: index,
          child: NewsCard(
            article: article,
            onTap: () {
              Get.toNamed(Routes.NEWS_DETAIL, arguments: article);
            },
          ),
        );
      },
    );
  }

  Widget _buildNoResults(String query) {
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
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No results for "$query"',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different keyword or check the spelling',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
