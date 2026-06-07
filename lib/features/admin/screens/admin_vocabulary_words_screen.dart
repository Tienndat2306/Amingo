import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/vocabulary_set.dart';
import '../../../data/models/vocabulary_word.dart';
import 'admin_vocabulary_word_form.dart';

class AdminVocabularyWordsScreen extends StatefulWidget {
  final VocabularySet vocabularySet;

  const AdminVocabularyWordsScreen({super.key, required this.vocabularySet});

  @override
  State<AdminVocabularyWordsScreen> createState() =>
      _AdminVocabularyWordsScreenState();
}

class _AdminVocabularyWordsScreenState
    extends State<AdminVocabularyWordsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<VocabularyWord> _words = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _firestore
          .collection('vocabulary_words')
          .where('setId', isEqualTo: widget.vocabularySet.id)
          .get();

      _words = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Gán ID từ document vào data
        return VocabularyWord.fromJson(data);
      }).toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteWord(VocabularyWord word) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete vocabulary word'),
        content: Text('Are you sure you want to delete "${word.word}"?'),
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
        await _firestore.collection('vocabulary_words').doc(word.id).delete();

        final setRef = _firestore
            .collection('vocabulary_sets')
            .doc(widget.vocabularySet.id);
        await setRef.update({'wordCount': FieldValue.increment(-1)});

        await _loadWords();

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

  Future<void> _editWord(VocabularyWord word) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminVocabularyWordForm(
          vocabularySet: widget.vocabularySet,
          word: word,
        ),
      ),
    );
    if (result == true && mounted) {
      _loadWords();
    }
  }

  Future<void> _addWord() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AdminVocabularyWordForm(vocabularySet: widget.vocabularySet),
      ),
    );
    if (result == true && mounted) {
      _loadWords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        title: Text('Words in "${widget.vocabularySet.title}"'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addWord,
            tooltip: 'Add word',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _words.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.create_new_folder,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No vocabulary words yet. Tap + to add one.',
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _words.length,
        itemBuilder: (context, index) {
          final word = _words[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: word.imageUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: word.imageUrl.startsWith('http')
                      ? Image.network(
                    word.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
                  )
                      : word.imageUrl.startsWith('assets/')
                      ? Image.asset(
                    word.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
                  )
                      : Image.memory(
                    base64Decode(word.imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
                  ),
                )
                    : const Icon(Icons.text_fields, color: AppColors.primary),
              ),
              title: Text(
                word.word,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('${word.meaning} • ${word.level}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editWord(word),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteWord(word),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
