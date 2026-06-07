import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/news_article.dart';
import '../../../data/services/article_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../features/news/screens/news_detail_screen.dart';


class AdminNewsScreen extends StatefulWidget {
  const AdminNewsScreen({super.key});

  @override
  State<AdminNewsScreen> createState() => _AdminNewsScreenState();
}

class _AdminNewsScreenState extends State<AdminNewsScreen> {
  List<NewsArticle> _articles = [];
  bool _isLoading = true;
  List<NewsArticle> _filteredArticles = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<String> _categories = ['All'];

  final List<Color> _cardColors = [
    const Color(0xFFE53935),
    const Color(0xFF1E88E5),
    const Color(0xFF43A047),
    const Color(0xFFFB8C00),
    const Color(0xFF8E24AA),
    const Color(0xFF00ACC1),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          _applyFilters(updateState: false);
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

  Future<void> _addArticle() async {
    final TextEditingController urlController = TextEditingController();
    bool isProcessing = false;

    await showDialog(
      context: context,
      barrierDismissible: !isProcessing,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Article from URL'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  hintText: 'Enter article URL (e.g. NYTimes, BBC...)',
                  border: OutlineInputBorder(),
                ),
                enabled: !isProcessing,
              ),
              if (isProcessing) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
                const SizedBox(height: 10),
                const Text("Amingo is extracting article...", style: TextStyle(fontSize: 12)),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: isProcessing ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isProcessing ? null : () async {
                final url = urlController.text.trim();
                if (url.isEmpty) return;

                setDialogState(() => isProcessing = true);

                try {
                  final apiUrl = Uri.parse('http://10.0.2.2:5000/extract-article');

                  final response = await http.post(
                    apiUrl,
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({"url": url}),
                  ).timeout(const Duration(seconds: 20));

                  final result = jsonDecode(response.body);

                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Article added successfully!'), backgroundColor: Colors.green),
                    );
                  } else {
                    throw Exception(result['message'] ?? 'Failed to fetch');
                  }
                } catch (e) {
                  setDialogState(() => isProcessing = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Extract & Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteArticle(
      String articleId,
      ) async {
    try {
      await FirebaseFirestore.instance
          .collection('articles')
          .doc(articleId)
          .delete();
      setState(() {
        _articles.removeWhere(
              (article) =>
          article.id == articleId,
        );
        _applyFilters(updateState: false);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Article deleted successfully',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to delete article',
          ),
        ),
      );
    }
  }

  void _filterArticles() {
    _applyFilters();
  }

  void _applyFilters({bool updateState = true}) {
    final query = _searchQuery.toLowerCase().trim();
    _filteredArticles = _articles.where((article) {
      final matchesCategory =
          _selectedCategory == 'All' || article.category == _selectedCategory;
      final matchesSearch =
          query.isEmpty || article.title.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    if (updateState) setState(() {});
  }

  void _onCategorySelected(String category) {
    _selectedCategory = category;
    _filterArticles();
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _filterArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAdminHeader(),
            _buildSearchBar(),
            _buildAdminCategoryFilter(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                onRefresh: _loadData,
                child: _filteredArticles.isEmpty
                    ? const Center(child: Text('No articles found'))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredArticles.length,
                  itemBuilder: (context, index) => _buildAdminArticleCard(_filteredArticles[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search articles by title...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
          suffixIcon: _searchQuery.trim().isEmpty
              ? null
              : IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                ),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
      ),
    );
  }

  // 1. Header riêng cho Admin
  Widget _buildAdminHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Content Manager',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                'Total: ${_articles.length} articles',
                style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _addArticle,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Add New'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCategoryFilter() {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == _categories[index];
          return GestureDetector(
            onTap: () => _onCategorySelected(_categories[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                _categories[index],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminArticleCard(NewsArticle article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(
              article: article,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                article.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  width: 80, height: 80,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      article.category,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${article.wordCount} words • ${article.difficulty}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailScreen(
                          article: article,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _deleteArticle(article.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
