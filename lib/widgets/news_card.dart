import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:news_app/controllers/saved_controller.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/utils/date_formatter.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;
  final bool showBookmark;

  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
    this.showBookmark = true,
  });

  @override
  Widget build(BuildContext context) {
    DateTime? publishedDate;
    if (article.publishedAt != null) {
      publishedDate = DateTime.tryParse(article.publishedAt!);
    }

    final imageUrl = _normalizeImageUrl(article.urlToImage);
    final hasImage = imageUrl != null;
    final publicationLabel = DateFormatter.fullDateTime(article.publishedAt);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay gradient + bookmark button
            if (hasImage)
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: AppColors.shimmerBase,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: AppColors.shimmerBase,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                  // Gradient overlay at bottom of image
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.cardOverlayGradient,
                      ),
                    ),
                  ),
                  // Source badge on image
                  if (article.source?.name != null)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          article.source!.name!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  // Bookmark button
                  if (showBookmark) _buildBookmarkButton(),
                ],
              ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source + time (only show source here if no image)
                  Row(
                    children: [
                      if (!hasImage && article.source?.name != null)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              article.source!.name!,
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      if (publishedDate != null) ...[
                        if (!hasImage && article.source?.name != null)
                          const SizedBox(width: 8),
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: AppColors.textHint,
                        ),
                        Expanded(
                          child: Text(
                            publicationLabel ?? timeago.format(publishedDate),
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      // Bookmark for no-image cards
                      if (!hasImage && showBookmark) ...[
                        const Spacer(),
                        _buildBookmarkIconOnly(),
                      ],
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Title
                  if (article.title != null)
                    Text(
                      article.title!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 6),

                  // Description
                  if (article.description != null)
                    Text(
                      article.description!,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return Positioned(
      top: 10,
      right: 10,
      child: GetBuilder<SavedController>(
        builder: (savedController) {
          final isSaved = savedController.isArticleSaved(article);
          return _BookmarkButton(
            isSaved: isSaved,
            onTap: () => savedController.toggleArticle(article),
          );
        },
      ),
    );
  }

  Widget _buildBookmarkIconOnly() {
    return GetBuilder<SavedController>(
      builder: (savedController) {
        final isSaved = savedController.isArticleSaved(article);
        return GestureDetector(
          onTap: () => savedController.toggleArticle(article),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              key: ValueKey(isSaved),
              color: isSaved ? AppColors.bookmarkActive : AppColors.textHint,
              size: 22,
            ),
          ),
        );
      },
    );
  }

  String? _normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    return uri.scheme == 'http' ? uri.replace(scheme: 'https').toString() : url;
  }
}

class _BookmarkButton extends StatefulWidget {
  final bool isSaved;
  final VoidCallback onTap;

  const _BookmarkButton({required this.isSaved, required this.onTap});

  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _bounceController.forward().then((_) => _bounceController.reverse());
        widget.onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: ScaleTransition(
          scale: _bounceAnimation,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              widget.isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              key: ValueKey(widget.isSaved),
              color: widget.isSaved ? AppColors.bookmarkActive : Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
