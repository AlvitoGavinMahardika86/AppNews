import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import 'package:news_app/controllers/saved_controller.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/utils/date_formatter.dart';

class NewsDetailView extends StatelessWidget {
  const NewsDetailView({super.key});

  NewsArticle get article => Get.arguments as NewsArticle;

  @override
  Widget build(BuildContext context) {
    final currentArticle = article;

    DateTime? publishedDate;
    if (currentArticle.publishedAt != null) {
      publishedDate = DateTime.tryParse(currentArticle.publishedAt!);
    }
    final publicationLabel = DateFormatter.fullDateTime(
      currentArticle.publishedAt,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Image header with collapsing app bar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  color: Colors.white,
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            actions: [
              // Bookmark button
              GetBuilder<SavedController>(
                builder: (savedController) {
                  final isSaved = savedController.isArticleSaved(
                    currentArticle,
                  );
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 20,
                        ),
                        color: isSaved
                            ? AppColors.bookmarkActive
                            : Colors.white,
                        tooltip: isSaved ? 'Remove Bookmark' : 'Bookmark',
                        onPressed: () {
                          savedController.toggleArticle(currentArticle);
                          Get.snackbar(
                            isSaved ? 'Removed' : 'Saved',
                            isSaved
                                ? 'Article removed from bookmarks'
                                : 'Article saved to bookmarks',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppColors.textPrimary,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              // Share button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share_rounded, size: 20),
                    color: Colors.white,
                    tooltip: 'Share Article',
                    onPressed: _shareArticle,
                  ),
                ),
              ),
              // More options
              Padding(
                padding: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'copy_link':
                          _copyLink();
                          break;
                        case 'open_browser':
                          _openInBrowser();
                          break;
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'copy_link',
                        child: Row(
                          children: [
                            Icon(
                              Icons.copy_rounded,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 12),
                            Text('Copy Link'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'open_browser',
                        child: Row(
                          children: [
                            Icon(
                              Icons.open_in_browser_rounded,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 12),
                            Text('Open in Browser'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildHeaderImage(currentArticle),
                  // Gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0x80000000)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Article content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              transform: Matrix4.translationValues(0, -24, 0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source and publication date
                    Row(
                      children: [
                        if (currentArticle.source?.name != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              currentArticle.source!.name!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (publishedDate != null) ...[
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            publicationLabel ?? timeago.format(publishedDate),
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Article title
                    if (currentArticle.title != null) ...[
                      Text(
                        currentArticle.title!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.3,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Divider
                    Container(
                      height: 3,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Article description
                    if (currentArticle.description != null) ...[
                      Text(
                        currentArticle.description!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Article content
                    if (currentArticle.content != null) ...[
                      Text(
                        currentArticle.content!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Read full article button
                    if (currentArticle.url != null &&
                        currentArticle.url!.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openInBrowser,
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: const Text(
                            'Read Full Article',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header image
  Widget _buildHeaderImage(NewsArticle currentArticle) {
    final imageUrl = _normalizeImageUrl(currentArticle.urlToImage);

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: const Center(
          child: Icon(Icons.newspaper_rounded, size: 64, color: Colors.white38),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white.withValues(alpha: 0.7),
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: const Icon(
          Icons.image_not_supported_outlined,
          size: 50,
          color: Colors.white38,
        ),
      ),
    );
  }

  String? _normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    return uri.scheme == 'http' ? uri.replace(scheme: 'https').toString() : url;
  }

  // Share article
  void _shareArticle() {
    final currentArticle = article;
    final url = currentArticle.url;

    if (url == null || url.isEmpty) {
      Get.snackbar(
        'Error',
        'Article link is unavailable',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    SharePlus.instance.share(
      ShareParams(
        text: '${currentArticle.title ?? 'Check out this news'}\n\n$url',
        subject: currentArticle.title,
      ),
    );
  }

  // Copy article link
  Future<void> _copyLink() async {
    final url = article.url;

    if (url == null || url.isEmpty) {
      Get.snackbar(
        'Error',
        'Article link is unavailable',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: url));

    Get.snackbar(
      'Copied!',
      'Link copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: AppColors.textPrimary,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  // Open article in external browser
  Future<void> _openInBrowser() async {
    final articleUrl = article.url;

    if (articleUrl == null || articleUrl.isEmpty) {
      Get.snackbar(
        'Error',
        'Article link is unavailable',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    final Uri? uri = Uri.tryParse(articleUrl);

    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      Get.snackbar(
        'Error',
        'Invalid article link',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        Get.snackbar(
          'Error',
          'Could not open the link',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not open the link',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
}
