import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/news_article.dart';
import '../../news/widgets/news_card.dart';
import '../../news/screens/news_detail_screen.dart';
import 'empty_state_widget.dart';

class SavedArticlesTab extends StatelessWidget {
  final String userId;
  const SavedArticlesTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookmarks')
          .where('userId', isEqualTo: userId)
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

        final bookmarkedDocs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: bookmarkedDocs.length,
          itemBuilder: (context, index) {
            final NewsArticle article = NewsArticle.fromFirestore(bookmarkedDocs[index]);

            return NewsCard(
              article: article,
              isRead: false,
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
  }
}