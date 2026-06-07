import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/listening_topic.dart';
import '../../../data/repositories/listening_repository.dart';
import 'admin_listening_sections_screen.dart';

class AdminListeningScreen extends StatefulWidget {
  const AdminListeningScreen({super.key});

  @override
  State<AdminListeningScreen> createState() => _AdminListeningScreenState();
}

class _AdminListeningScreenState extends State<AdminListeningScreen> {
  final ListeningRepository _repository = ListeningRepository();

  List<ListeningTopic> _topics = [];
  bool _isLoading = true;

  static const List<Color> _cardColors = [
    Color(0xFF7C4DFF),
    Color(0xFF448AFF),
    Color(0xFF69F0AE),
    Color(0xFFFF5252),
    Color(0xFFFFAB40),
  ];

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    setState(() => _isLoading = true);
    try {
      final topics = await _repository.fetchTopics();
      setState(() {
        _topics = topics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _showTopicDialog({ListeningTopic? topic}) {
    final isEdit = topic != null;
    final titleCtrl = TextEditingController(text: topic?.title ?? '');
    final descCtrl = TextEditingController(text: topic?.description ?? '');
    final orderCtrl = TextEditingController(text: topic?.order.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Edit Topic' : 'Add New Topic',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEdit
                        ? 'Update the details for this listening topic.'
                        : 'Enter the specific details for the new listening topic.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      prefixIcon: const Icon(Icons.title, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: orderCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Order Index',
                      prefixIcon: const Icon(Icons.low_priority, size: 20),
                      hintText: 'e.g., 1, 2, 3...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      errorMaxLines: 3,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter an order index';
                      final n = int.tryParse(v.trim());
                      if (n == null) return 'Please enter a valid integer';
                      final duplicate = _topics.any((t) =>
                          t.order == n && (isEdit ? t.id != topic.id : true));
                      if (duplicate) return 'This order index already exists!';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 4,
                    minLines: 3,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'Description',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 45),
                        child: Icon(Icons.description, size: 20),
                      ),
                      hintText: 'Enter a detailed description...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel',
                            style: TextStyle(
                                color: Color(0xFF5D4037), fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C4DFF),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final order = int.parse(orderCtrl.text.trim());
                            final updated = ListeningTopic(
                              id: topic?.id ?? '',
                              title: titleCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              order: order,
                            );
                            if (isEdit) {
                              await _repository.updateTopic(updated);
                            } else {
                              await _repository.addTopic(updated);
                            }
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              _loadTopics();
                            }
                          }
                        },
                        child: Text(isEdit ? 'Update' : 'Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteTopic(String topicId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content:
            const Text('Are you sure you want to delete this topic permanently?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _repository.deleteTopic(topicId);
      _loadTopics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 2 : 1;
    final cardWidth = (screenWidth - 72) / crossAxisCount;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Listening Topics',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showTopicDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Topic'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _topics.isEmpty
                  ? const Center(
                      child: Text('No topics available. Create a new one!'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: _topics.asMap().entries.map((entry) {
                          final topic = entry.value;
                          final color =
                              _cardColors[entry.key % _cardColors.length];
                          return SizedBox(
                            width: cardWidth,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminListeningSectionsScreen(
                                    topicId: topic.id,
                                    topicTitle: topic.title,
                                  ),
                                ),
                              ),
                              child: _TopicCard(
                                topic: topic,
                                cardColor: color,
                                onEdit: () => _showTopicDialog(topic: topic),
                                onDelete: () => _deleteTopic(topic.id),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// PRIVATE WIDGET — Topic Card
// ---------------------------------------------------------------------------
class _TopicCard extends StatelessWidget {
  final ListeningTopic topic;
  final Color cardColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TopicCard({
    required this.topic,
    required this.cardColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
          // Header gradient
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cardColor, cardColor.withValues(alpha: 0.7)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
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
                  child: const Icon(Icons.collections_bookmark,
                      color: Colors.white, size: 24),
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
                        'Order: ${topic.order}',
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
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  topic.description.isEmpty
                      ? 'No description available.'
                      : topic.description,
                  style: GoogleFonts.beVietnamPro(
                      fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit,
                          color: Color(0xFF795548), size: 20),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.red, size: 20),
                      onPressed: onDelete,
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