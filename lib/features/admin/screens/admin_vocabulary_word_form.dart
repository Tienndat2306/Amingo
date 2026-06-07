import 'dart:convert'; // Thêm để dùng Base64
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/vocabulary_set.dart';
import '../../../data/models/vocabulary_word.dart';

class AdminVocabularyWordForm extends StatefulWidget {
  final VocabularySet vocabularySet;
  final VocabularyWord? word;

  const AdminVocabularyWordForm({
    super.key,
    required this.vocabularySet,
    this.word,
  });

  @override
  State<AdminVocabularyWordForm> createState() =>
      _AdminVocabularyWordFormState();
}

class _AdminVocabularyWordFormState extends State<AdminVocabularyWordForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _pronunciationController = TextEditingController();
  final _exampleController = TextEditingController();
  final _exampleMeaningController = TextEditingController();

  // Lưu chuỗi base64 thay vì URL
  String? _base64Image;

  bool _isLoading = false;
  String _selectedLevel = 'Beginner';

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.word != null) {
      _wordController.text = widget.word!.word;
      _meaningController.text = widget.word!.meaning;
      _pronunciationController.text = widget.word!.pronunciation;
      _exampleController.text = widget.word!.example;
      _exampleMeaningController.text = widget.word!.exampleMeaning;
      _base64Image = widget.word!.imageUrl; // Coi đây là base64
      _selectedLevel = widget.word!.level;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 500, // Giới hạn kích thước để base64 không quá lớn
        maxHeight: 500,
        imageQuality: 70, // Giảm chất lượng
      );
      if (pickedFile != null) {
        final bytes = await File(pickedFile.path).readAsBytes();
        setState(() {
          _base64Image = base64Encode(bytes);
        });
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh: $e');
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a new photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_base64Image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final wordData = {
        'word': _wordController.text,
        'meaning': _meaningController.text,
        'example': _exampleController.text,
        'exampleMeaning': _exampleMeaningController.text,
        'pronunciation': _pronunciationController.text,
        'imageUrl': _base64Image, // Lưu trực tiếp chuỗi base64
        'category': widget.vocabularySet.title,
        'setId': widget.vocabularySet.id,
        'level': _selectedLevel,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.word != null) {
        final docId = widget.word!.id;
        wordData['createdAt'] = widget.word!.createdAt;

        await _firestore
            .collection('vocabulary_words')
            .doc(docId)
            .set(wordData, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Updated successfully!')),
          );
        }
      } else {
        wordData['createdAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('vocabulary_words').add(wordData);

        final setRef = _firestore
            .collection('vocabulary_sets')
            .doc(widget.vocabularySet.id);
        await setRef.update({'wordCount': FieldValue.increment(1)});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vocabulary word added successfully!'),
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Lỗi lưu: $e');
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
    final isEditing = widget.word != null;

    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit vocabulary word' : 'Add new vocabulary word',
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _base64Image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _base64Image!.startsWith('http')
                              ? Image.network(
                                  _base64Image!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                )
                              : _base64Image!.startsWith('assets/')
                              ? Image.asset(
                                  _base64Image!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                )
                              : Image.memory(
                                  base64Decode(_base64Image!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text('Tap to add an image'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
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
                'Example (English)',
                Icons.format_quote,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _exampleMeaningController,
                'Example meaning',
                Icons.translate,
              ),
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
                      : const Text('Save vocabulary word'),
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
          value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _pronunciationController.dispose();
    _exampleController.dispose();
    _exampleMeaningController.dispose();
    super.dispose();
  }
}
