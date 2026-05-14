import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/news_article.dart';
import '../../../data/mock/mock_news.dart';
import '../widgets/news_card.dart';
import '../widgets/news_header.dart';
import '../widgets/news_category_filter.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<NewsArticle> _articles = [];
  List<NewsArticle> _filteredArticles = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'World News', 'Technology', 'Education', 'Culture', 'Business', 'Science'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    _articles = MockNewsData.getMockNewsArticles();
    _filterArticles();
    setState(() => _isLoading = false);
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
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _filteredArticles.length,
                itemBuilder: (context, index) {
                  return NewsCard(
                    article: _filteredArticles[index],
                    onTap: () {},
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