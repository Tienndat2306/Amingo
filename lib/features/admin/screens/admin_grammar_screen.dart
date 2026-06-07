import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/grammar_topic.dart';
import 'admin_grammar_form.dart';

class AdminGrammarScreen extends StatefulWidget {
  const AdminGrammarScreen({super.key});

  @override
  State<AdminGrammarScreen> createState() => _AdminGrammarScreenState();
}

class _AdminGrammarScreenState extends State<AdminGrammarScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _topics = [];
  bool _isLoading = true;

  final List<Color> _cardColors = const [
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFFFA726),
    Color(0xFFAB47BC),
    Color(0xFFEF5350),
    Color(0xFF26C6DA),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _firestore.collection('grammar_topics').get();
      _topics = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      debugPrint('Số lượng grammar topics: ${_topics.length}');
      for (var topic in _topics) {
        debugPrint('ID: ${topic['id']}, Title: ${topic['title']}');
      }
    } catch (e) {
      debugPrint('Lỗi load grammar topics: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTopic(Map<String, dynamic> topic) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete topic'),
        content: Text('Are you sure you want to delete "${topic['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        final questions = await _firestore
            .collection('grammar_questions')
            .where('topicId', isEqualTo: topic['id'])
            .get();
        for (var doc in questions.docs) {
          await doc.reference.delete();
        }

        await _firestore.collection('grammar_topics').doc(topic['id']).delete();

        await _loadData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _editTopic(Map<String, dynamic> topic) {
    final grammarTopic = GrammarTopic(
      id: topic['id'],
      title: topic['title'] ?? '',
      description: topic['description'] ?? '',
      level: topic['level'] ?? 'Beginner',
      progress: (topic['progress'] ?? 0).toDouble(),
      icon: Icons.article,
      createdAt: (topic['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      theory: topic['theory'] ?? '',
      formulas: List<String>.from(topic['formulas'] ?? []),
      keywords: List<String>.from(topic['keywords'] ?? []),
      rules:
          (topic['rules'] as List?)
              ?.map((e) => GrammarRule.fromJson(e))
              .toList() ??
          [],
      examples: [],
      quizCount: topic['quizCount'] ?? 0,
      passingScore: topic['passingScore'] ?? 70,
      estimatedTime: topic['estimatedTime'] ?? 15,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminGrammarForm(topic: grammarTopic),
      ),
    ).then((_) => _loadData());
  }

  void _addTopic() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminGrammarForm()),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grammar Management',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _addTopic,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add topic'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _topics.isEmpty
                      ? const Center(
                          child: Text('No topics yet. Tap + to add one.'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _topics.length,
                          itemBuilder: (context, index) {
                            final topic = _topics[index];
                            final cardColor =
                                _cardColors[index % _cardColors.length];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildTopicCard(topic, cardColor),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic, Color cardColor) {
    final progress = (topic['progress'] ?? 0).toDouble();
    final level = topic['level'] ?? 'Beginner';
    final title = topic['title'] ?? '';
    final description = topic['description'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.article, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                          size: 18,
                        ),
                        onPressed: () => _editTopic(topic),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 18,
                        ),
                        onPressed: () => _deleteTopic(topic),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          level,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: cardColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
