import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';

class AdminGrammarQuestionForm extends StatefulWidget {
  final String topicId;
  final Map<String, dynamic>? question;

  const AdminGrammarQuestionForm({
    super.key,
    required this.topicId,
    this.question,
  });

  @override
  State<AdminGrammarQuestionForm> createState() =>
      _AdminGrammarQuestionFormState();
}

class _AdminGrammarQuestionFormState extends State<AdminGrammarQuestionForm> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final _questionController = TextEditingController();
  String _questionType = 'multiple_choice';
  final List<TextEditingController> _optionControllers = [];
  final List<String> _options = [];
  String? _selectedCorrectAnswer;
  final _explanationController = TextEditingController();
  String _difficulty = 'medium';

  bool _isLoading = false;

  final List<String> _questionTypes = [
    'multiple_choice',
    'fill_blank',
    'true_false',
  ];
  final List<String> _difficulties = ['easy', 'medium', 'hard'];

  @override
  void initState() {
    super.initState();
    _loadData();
    for (int i = 0; i < 4; i++) {
      _addOptionField();
    }
  }

  void _loadData() {
    if (widget.question != null) {
      _questionController.text = widget.question!['question'] ?? '';
      _questionType = widget.question!['questionType'] ?? 'multiple_choice';
      _selectedCorrectAnswer = widget.question!['correctAnswer'] ?? '';
      _explanationController.text = widget.question!['explanation'] ?? '';
      _difficulty = widget.question!['difficulty'] ?? 'medium';

      final options = List<String>.from(widget.question!['options'] ?? []);
      _options.clear();
      _optionControllers.clear();
      for (final option in options) {
        final controller = TextEditingController(text: option);
        _optionControllers.add(controller);
        _options.add(option);
      }
      while (_optionControllers.length < 4) {
        _addOptionField();
      }
      if (_questionType == 'true_false' &&
          (_selectedCorrectAnswer == null || _selectedCorrectAnswer!.isEmpty)) {
        _selectedCorrectAnswer = 'True';
      }
    }
  }

  void _addOptionField() {
    setState(() {
      final controller = TextEditingController();
      _optionControllers.add(controller);
      _options.add('');
    });
  }

  void _removeOptionField(int index) {
    final removedOption = _options[index];

    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      _options.removeAt(index);

      if (_selectedCorrectAnswer == removedOption) {
        _selectedCorrectAnswer = null;
      }
    });
  }

  void _updateOptions() {
    for (int i = 0; i < _optionControllers.length; i++) {
      _options[i] = _optionControllers[i].text;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _updateOptions();

    if (_questionType == 'multiple_choice') {
      if (_selectedCorrectAnswer == null || _selectedCorrectAnswer!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select the correct answer!')),
        );
        return;
      }

      if (!_options.contains(_selectedCorrectAnswer)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The correct answer must be in the answer list!'),
          ),
        );
        return;
      }
    } else if (_selectedCorrectAnswer == null ||
        _selectedCorrectAnswer!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the correct answer!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final questionData = {
      'topicId': widget.topicId,
      'question': _questionController.text,
      'questionType': _questionType,
      'options': _questionType == 'multiple_choice'
          ? _options.where((o) => o.isNotEmpty).toList()
          : [],
      'correctAnswer': _selectedCorrectAnswer,
      'explanation': _explanationController.text,
      'difficulty': _difficulty,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (!mounted) return;

    try {
      if (widget.question != null) {
        await _firestore
            .collection('grammar_questions')
            .doc(widget.question!['id'])
            .update(questionData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question updated successfully!')),
        );
      } else {
        await _firestore.collection('grammar_questions').add(questionData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question added successfully!')),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getQuestionTypeDisplay(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Multiple choice';
      case 'fill_blank':
        return 'Fill in the blank';
      case 'true_false':
        return 'True/False';
      default:
        return 'Multiple choice';
    }
  }

  String _getDifficultyDisplay(String diff) {
    switch (diff) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      default:
        return 'Medium';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        title: Text(
          widget.question != null ? 'Edit question' : 'Add new question',
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _questionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Please enter a question' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _questionType,
                decoration: const InputDecoration(
                  labelText: 'Question type',
                  border: OutlineInputBorder(),
                ),
                items: _questionTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getQuestionTypeDisplay(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _questionType = value!;
                    _selectedCorrectAnswer = _questionType == 'true_false'
                        ? 'True'
                        : null;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_questionType == 'multiple_choice') ...[
                const Text(
                  'Distractor answers:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(_optionControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _optionControllers[index],
                            decoration: InputDecoration(
                              hintText: 'Answer ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                final previousOption = _options[index];
                                _options[index] = value;
                                if (_selectedCorrectAnswer == previousOption) {
                                  _selectedCorrectAnswer = value;
                                }
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          onPressed: () => _removeOptionField(index),
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: _addOptionField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add answer'),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(_selectedCorrectAnswer),
                    initialValue:
                        _selectedCorrectAnswer != null &&
                            _selectedCorrectAnswer!.isNotEmpty
                        ? _selectedCorrectAnswer
                        : null,
                    hint: const Text('Select the correct answer'),
                    decoration: const InputDecoration(
                      labelText: 'Correct answer',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: _options.where((o) => o.isNotEmpty).map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(
                          option,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCorrectAnswer = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select the correct answer';
                      }
                      return null;
                    },
                  ),
                ),
              ],
              if (_questionType == 'fill_blank')
                TextFormField(
                  initialValue: _selectedCorrectAnswer,
                  decoration: const InputDecoration(
                    labelText: 'Correct answer',
                    border: OutlineInputBorder(),
                    hintText: 'Enter the correct answer',
                  ),
                  onChanged: (value) => _selectedCorrectAnswer = value,
                  validator: (value) => value?.isEmpty == true
                      ? 'Please enter the correct answer'
                      : null,
                ),
              if (_questionType == 'true_false')
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.adminPrimary.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SegmentedButtonTheme(
                    data: SegmentedButtonThemeData(
                      style: SegmentedButton.styleFrom(
                        backgroundColor: Colors.white,
                        selectedBackgroundColor: AppColors.adminPrimary,
                        selectedForegroundColor: Colors.white,
                        foregroundColor: AppColors.adminPrimary,
                        side: const BorderSide(color: AppColors.adminPrimary),
                      ),
                    ),
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'True', label: Text('True')),
                        ButtonSegment(value: 'False', label: Text('False')),
                      ],
                      selected: {_selectedCorrectAnswer ?? 'True'},
                      onSelectionChanged: (set) {
                        setState(() => _selectedCorrectAnswer = set.first);
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _explanationController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Explanation',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _difficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty',
                  border: OutlineInputBorder(),
                ),
                items: _difficulties.map((diff) {
                  return DropdownMenuItem(
                    value: diff,
                    child: Text(_getDifficultyDisplay(diff)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _difficulty = value!),
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
                      : const Text('Save question'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
