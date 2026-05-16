import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/news_article.dart';
import '../../../data/services/article_service.dart';

class NewsCard extends StatefulWidget {
  final NewsArticle article;
  final VoidCallback onTap;
  final bool isRead;

  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
    this.isRead = false,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  final ArticleService _articleService = ArticleService();

  bool _isMarkingAsRead = false;

  @override
  Widget build(BuildContext context) {
    final Color buttonBgColor = widget.isRead
        ? const Color(0xFFD49A15)
        : AppColors.primary.withValues(alpha: 0.1);

    final Color buttonIconColor = widget.isRead
        ? Colors.white
        : AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  widget.article.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.image_not_supported, size: 50, color: AppColors.primary),
                    );
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        widget.article.category,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.article.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          widget.onTap();
                          if (!widget.isRead && widget.article.id != null) {
                            try {
                              await _articleService.markAsRead(widget.article.id!);
                            } catch (e) {
                            }
                          }
                        },
                        icon: const Icon(Icons.play_lesson, size: 18),
                        label: const Text('Read Article'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.bookmark_border, size: 20),
                        color: AppColors.primary,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: buttonBgColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: _isMarkingAsRead
                          ? const SizedBox(
                        width: 48,
                        height: 48,
                        child: Padding(
                          padding: EdgeInsets.all(14.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      )
                          : IconButton(
                        icon: const Icon(Icons.done_all, size: 20),
                        color: buttonIconColor,
                        onPressed: widget.isRead
                            ? null
                            : () async {
                          if (widget.article.id == null) return;

                          setState(() => _isMarkingAsRead = true);

                          try {
                            await _articleService.markAsRead(widget.article.id!);
                          } catch (e) {
                            debugPrint('Lỗi lưu trạng thái đã đọc: $e');
                          } finally {
                            if (mounted) {
                              setState(() => _isMarkingAsRead = false);
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}