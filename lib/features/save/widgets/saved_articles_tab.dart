import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/news_article.dart';
import '../../news/widgets/news_card.dart';
import '../../news/screens/news_detail_screen.dart';
import 'empty_state_widget.dart';
import '../../../data/services/article_service.dart';

class SavedArticlesTab extends StatelessWidget {
  final String userId;
  final String searchQuery;

  const SavedArticlesTab({
    super.key,
    required this.userId,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final ArticleService articleService = ArticleService();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('saved_articles')
          .where('userId', isEqualTo: userId)
          .orderBy('savedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingWidget());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.bookmark_border,
            message: 'No saved articles yet.',
          );
        }

        final query = searchQuery.toLowerCase().trim();
        final bookmarkedDocs = snapshot.data!.docs.where((doc) {
          if (query.isEmpty) return true;
          final data = doc.data() as Map<String, dynamic>;
          final title = data['title']?.toString().toLowerCase() ?? '';
          return title.contains(query);
        }).toList();

        if (bookmarkedDocs.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.search_off,
            message: 'No saved articles match your search.',
          );
        }

        return StreamBuilder<List<String>>(
          stream: articleService.getAlreadyReadArticles(),
          builder: (context, readSnapshot) {
            final List<String> readArticleIds = readSnapshot.data ?? [];

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: bookmarkedDocs.length,
              itemBuilder: (context, index) {
                final NewsArticle article = NewsArticle.fromFirestore(bookmarkedDocs[index]);

                final bool isRead = readArticleIds.contains(article.id);

                return NewsCard(
                  article: article,
                  isRead: isRead,
                  isBookmarked: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailScreen(article: article),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
