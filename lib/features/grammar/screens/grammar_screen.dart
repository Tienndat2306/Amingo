import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/grammar_topic.dart';
import '../widgets/grammar_topic_card.dart';
import 'grammar_detail_screen.dart';

class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<GrammarTopic> _topics = [];
  final Map<String, Map<String, dynamic>> _progressMap = {};
  final Map<String, int> _questionCountMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<int> _getQuestionCount(String topicId) async {
    try {
      final snapshot = await _firestore
          .collection('grammar_questions')
          .where('topicId', isEqualTo: topicId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      final snapshot = await _firestore.collection('grammar_topics').get();
      _topics = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GrammarTopic.fromJson(data);
      }).toList();

      for (var topic in _topics) {
        final questionCount = await _getQuestionCount(topic.id);
        _questionCountMap[topic.id] = questionCount;
      }

      final Set<String> completedSetIds = {};
      final Map<String, int> completedQuestionCount = {};

      if (userId != null) {
        final completedSnapshot = await _firestore
            .collection('user_progress')
            .doc(userId)
            .collection('completed_topics')
            .where('type', isEqualTo: 'grammar')
            .get();

        for (var doc in completedSnapshot.docs) {
          completedSetIds.add(doc.id);
          completedQuestionCount[doc.id] = doc.data()['totalQuestions'] ?? 0;
        }
      }

      for (var topic in _topics) {
        final currentQuestionCount = _questionCountMap[topic.id] ?? 0;
        final completedCount = completedQuestionCount[topic.id] ?? 0;
        final wasCompleted = completedSetIds.contains(topic.id);

        if (wasCompleted && currentQuestionCount != completedCount) {
          if (userId != null) {
            await _firestore
                .collection('user_progress')
                .doc(userId)
                .collection('completed_topics')
                .doc(topic.id)
                .delete();
          }
          _progressMap[topic.id] = {
            'percentage': 0,
            'score': 0,
            'totalQuestions': currentQuestionCount,
            'isPassed': false,
          };
        } else if (wasCompleted) {
          _progressMap[topic.id] = {
            'percentage': 100,
            'score': currentQuestionCount,
            'totalQuestions': currentQuestionCount,
            'isPassed': true,
          };
        } else if (userId != null) {
          final progressDoc = await _firestore
              .collection('user_progress')
              .doc(userId)
              .collection('grammar')
              .doc(topic.id)
              .get();

          if (progressDoc.exists) {
            _progressMap[topic.id] = progressDoc.data()!;
          } else {
            _progressMap[topic.id] = {
              'percentage': 0,
              'score': 0,
              'totalQuestions': currentQuestionCount,
              'isPassed': false,
            };
          }
        } else {
          _progressMap[topic.id] = {
            'percentage': 0,
            'score': 0,
            'totalQuestions': currentQuestionCount,
            'isPassed': false,
          };
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double _getProgress(GrammarTopic topic) {
    final progress = _progressMap[topic.id];
    if (progress == null) return 0.0;
    final percentage = (progress['percentage'] ?? 0) / 100;
    return percentage.clamp(0.0, 1.0);
  }

  bool _isCompleted(GrammarTopic topic) {
    final progress = _progressMap[topic.id];
    if (progress == null) return false;
    return (progress['percentage'] ?? 0) >= 100;
  }

  DateTime? _getCompletedAt(GrammarTopic topic) {
    final progress = _progressMap[topic.id];
    if (progress == null) return null;
    final timestamp = progress['completedAt'];
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return null;
  }

  void _navigateToDetail(GrammarTopic topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GrammarDetailScreen(
          topic: topic,
          userProgress: _progressMap[topic.id],
        ),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _resetTopic(GrammarTopic topic) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset progress'),
        content: Text(
          'Are you sure you want to restart "${topic.title}" from the beginning?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _firestore
          .collection('user_progress')
          .doc(userId)
          .collection('grammar')
          .doc(topic.id)
          .delete();

      await _firestore
          .collection('user_progress')
          .doc(userId)
          .collection('completed_topics')
          .doc(topic.id)
          .delete();

      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress has been reset!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _topics.where((t) => _isCompleted(t)).length;
    final avgProgress = _topics.isEmpty
        ? 0.0
        : _topics.fold(0.0, (total, t) => total + _getProgress(t)) /
              _topics.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Grammar',
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Grammar Mastery',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Completed $completedCount/${_topics.length} topics',
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: LinearProgressIndicator(
                                  value: avgProgress,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.3,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _topics.isEmpty
                        ? const Center(child: Text('No grammar topics yet.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            itemCount: _topics.length,
                            itemBuilder: (context, index) {
                              final topic = _topics[index];
                              return GrammarTopicCard(
                                topic: topic,
                                progress: _getProgress(topic),
                                isCompleted: _isCompleted(topic),
                                completedAt: _getCompletedAt(topic),
                                onTap: () => _navigateToDetail(topic),
                                onReset: () => _resetTopic(topic),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
