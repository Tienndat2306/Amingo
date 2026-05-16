import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/news_article.dart';
import '../widgets/news_card.dart';
import '../widgets/news_header.dart';
import '../widgets/news_category_filter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'news_detail_screen.dart';
import '../../../data/services/article_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final ArticleService _articleService = ArticleService();
  List<NewsArticle> _articles = [];
  List<NewsArticle> _filteredArticles = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final snapshot = await FirebaseFirestore
          .instance
          .collection('articles')
          .orderBy(
        'createdAt',
        descending: true,
      )
          .get();
      final articles = snapshot.docs.map((doc) {
        return NewsArticle.fromFirestore(doc);
      }).toList();

      if (mounted) {
        setState(() {
          _articles = articles;
          final dynamicCategories = articles.map((a) => a.category).toSet().toList();
          dynamicCategories.sort();

          _categories = ['All', ...dynamicCategories];
          _filteredArticles = articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to load articles',
            ),
          ),
        );
      }
    }
  }

  void _filterArticles() {
    if (_selectedCategory == 'All') {
      _filteredArticles = _articles;
    } else {
      _filteredArticles = _articles.where((article) => article.category == _selectedCategory).toList();
    }
    setState(() {});
  }

  void _onCategorySelected(String category) {
    _selectedCategory = category;
    _filterArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'News',
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: AppColors.primary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const NewsHeader(),
          NewsCategoryFilter(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: _onCategorySelected,
          ),
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : RefreshIndicator(
              onRefresh: _loadData,
              child: _filteredArticles.isEmpty
                  ? const Center(child: Text('No news articles found'))
                  : StreamBuilder<List<String>>(

                stream: _articleService.getAlreadyReadArticles(),
                builder: (context, readSnapshot) {

                  final List<String> readArticleIds = readSnapshot.data ?? [];

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: _filteredArticles.length,
                    itemBuilder: (context, index) {
                      final currentArticle = _filteredArticles[index];

                      final bool isRead = readArticleIds.contains(currentArticle.id);

                      return NewsCard(
                        article: currentArticle,
                        isRead: isRead,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticleDetailScreen(article: currentArticle,),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}