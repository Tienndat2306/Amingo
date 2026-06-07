import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/vocabulary_word.dart';
import '../../../data/models/vocabulary_set.dart';

class AdminVocabularyForm extends StatefulWidget {
  final VocabularySet? vocabularySet;
  final VocabularyWord? word;
  final String? setId;
  final bool isEditingWord;

  const AdminVocabularyForm({
    super.key,
    this.vocabularySet,
    this.word,
    this.setId,
    this.isEditingWord = false,
  });

  @override
  State<AdminVocabularyForm> createState() => _AdminVocabularyFormState();
}

class _AdminVocabularyFormState extends State<AdminVocabularyForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers
  final _titleController = TextEditingController();
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _pronunciationController = TextEditingController();
  final _exampleController = TextEditingController();
  final _exampleMeaningController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isLoading = false;
  String _selectedLevel = 'Beginner';
  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.vocabularySet != null) {
      _titleController.text = widget.vocabularySet!.title;
      _selectedLevel = widget.vocabularySet!.level;
    }

    if (widget.word != null) {
      _wordController.text = widget.word!.word;
      _meaningController.text = widget.word!.meaning;
      _pronunciationController.text = widget.word!.pronunciation;
      _exampleController.text = widget.word!.example;
      _exampleMeaningController.text = widget.word!.exampleMeaning;
      _imageUrlController.text = widget.word!.imageUrl;
      _selectedLevel = widget.word!.level;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.isEditingWord && widget.word != null) {
        // Cập nhật từ vựng
        final wordData = {
          'word': _wordController.text,
          'meaning': _meaningController.text,
          'example': _exampleController.text,
          'exampleMeaning': _exampleMeaningController.text,
          'pronunciation': _pronunciationController.text,
          'imageUrl': _imageUrlController.text,
          'level': _selectedLevel,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        await _firestore
            .collection('vocabulary_words')
            .doc(widget.word!.id)
            .update(wordData);
      } else if (widget.vocabularySet != null) {
        // Cập nhật bộ từ
        final setData = {
          'title': _titleController.text,
          'level': _selectedLevel,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        await _firestore
            .collection('vocabulary_sets')
            .doc(widget.vocabularySet!.id)
            .update(setData);
      } else if (widget.word != null) {
        // Thêm từ vựng mới
        final newWord = {
          'id': widget.word!.id,
          'word': _wordController.text,
          'meaning': _meaningController.text,
          'example': _exampleController.text,
          'exampleMeaning': _exampleMeaningController.text,
          'pronunciation': _pronunciationController.text,
          'imageUrl': _imageUrlController.text,
          'category': widget.word!.category,
          'setId': widget.word!.setId,
          'level': _selectedLevel,
          'createdAt': FieldValue.serverTimestamp(),
        };
        await _firestore
            .collection('vocabulary_words')
            .doc(widget.word!.id)
            .set(newWord);

        // Cập nhật số lượng từ trong bộ
        final setRef = _firestore
            .collection('vocabulary_sets')
            .doc(widget.word!.setId);
        await setRef.update({'wordCount': FieldValue.increment(1)});
      } else {
        // Thêm bộ từ mới
        final newSet = {
          'title': _titleController.text,
          'wordCount': 0,
          'learnedCount': 0,
          'level': _selectedLevel,
          'icon': 'school',
          'color': 0xFFFFA726,
          'createdAt': FieldValue.serverTimestamp(),
        };
        await _firestore.collection('vocabulary_sets').add(newSet);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved successfully!')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditingSet = widget.vocabularySet != null && !widget.isEditingWord;
    final isEditingWordMode = widget.isEditingWord;
    final isAddingWord = widget.word != null && !widget.isEditingWord;

    String getTitle() {
      if (isEditingSet) return 'Edit vocabulary set';
      if (isEditingWordMode) return 'Edit vocabulary word';
      if (isAddingWord) return 'Add new vocabulary word';
      return 'Add new vocabulary set';
    }

    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(title: Text(getTitle()), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isEditingWordMode && !isAddingWord)
                _buildTextField(_titleController, 'Set name', Icons.title),

              if (isEditingWordMode || isAddingWord) ...[
                _buildTextField(_wordController, 'Word', Icons.text_fields),
                const SizedBox(height: 16),
                _buildTextField(_meaningController, 'Meaning', Icons.translate),
                const SizedBox(height: 16),
                _buildTextField(
                  _pronunciationController,
                  'Pronunciation',
                  Icons.record_voice_over,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _exampleController,
                  'Example sentence',
                  Icons.format_quote,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _exampleMeaningController,
                  'Example sentence meaning',
                  Icons.translate,
                ),
                const SizedBox(height: 16),
                _buildTextField(_imageUrlController, 'Image URL', Icons.image),
              ],

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Level',
                  border: OutlineInputBorder(),
                ),
                items: _levels.map((level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) => setState(() => _selectedLevel = value!),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
      value?.isEmpty == true ? 'Please enter $label' : null,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _wordController.dispose();
    _meaningController.dispose();
    _pronunciationController.dispose();
    _exampleController.dispose();
    _exampleMeaningController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
