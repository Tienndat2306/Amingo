import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/grammar_topic.dart';
import '../../../data/mock/mock_grammar.dart';

class AdminGrammarScreen extends StatefulWidget {
  const AdminGrammarScreen({super.key});

  @override
  State<AdminGrammarScreen> createState() => _AdminGrammarScreenState();
}

class _AdminGrammarScreenState extends State<AdminGrammarScreen> {
  List<GrammarTopic> _topics = [];
  bool _isLoading = true;

  final List<Color> _cardColors = [
    const Color(0xFF42A5F5),  // Xanh dương - Present Simple
    const Color(0xFF66BB6A),  // Xanh lá - Past Simple
    const Color(0xFFFFA726),  // Cam - Future Simple
    const Color(0xFFAB47BC),  // Tím - Present Continuous
    const Color(0xFFEF5350),  // Đỏ - Prepositions
    const Color(0xFF26C6DA),  // Xanh ngọc - Modal Verbs
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    _topics = MockGrammarData.getMockGrammarTopics();
    setState(() => _isLoading = false);
  }

  void _addTopic() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add grammar topic feature coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 1);
    final cardWidth = (screenWidth - 72) / crossAxisCount;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grammar Topics',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addTopic,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Topic'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.start,
              children: _topics.asMap().entries.map((entry) {
                final index = entry.key;
                final topic = entry.value;
                final cardColor = _cardColors[index % _cardColors.length];
                return SizedBox(
                  width: cardWidth,
                  child: _buildTopicCard(topic, cardColor),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicCard(GrammarTopic topic, Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(topic.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          topic.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${topic.lessonCount} lessons • ${topic.level}',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  topic.description,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.trending_up, size: 14, color: cardColor),
                    const SizedBox(width: 4),
                    Text(
                      '${(topic.progress * 100).toInt()}% completed',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cardColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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