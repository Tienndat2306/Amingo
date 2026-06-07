import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/grammar_topic.dart';
import 'admin_grammar_question_form.dart';

class AdminGrammarForm extends StatefulWidget {
  final GrammarTopic? topic;

  const AdminGrammarForm({super.key, this.topic});

  @override
  State<AdminGrammarForm> createState() => _AdminGrammarFormState();
}

class _AdminGrammarFormState extends State<AdminGrammarForm>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // ==================== CONTROLLERS ====================
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _theoryController = TextEditingController();
  final _formulasController = TextEditingController();
  final _keywordsController = TextEditingController();

  // ==================== RULES ====================
  List<Map<String, dynamic>> _rules = [];
  final _ruleTitleController = TextEditingController();
  final _ruleDescController = TextEditingController();
  final _ruleFormulasController = TextEditingController();
  final _ruleExamplesController = TextEditingController();
  final _ruleExceptionsController = TextEditingController();
  final _ruleNotesController = TextEditingController();

  // ==================== QUESTIONS ====================
  List<Map<String, dynamic>> _questions = [];
  bool _isLoadingQuestions = false;

  // ==================== SETTINGS ====================
  String _selectedLevel = 'Beginner';
  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  int _passingScore = 70;
  int _estimatedTime = 15;

  bool _isLoading = false;
  List<String> _keywords = [];
  String? _topicId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
    _loadQuestions();
  }

  void _loadData() {
    if (widget.topic != null) {
      _topicId = widget.topic!.id;
      _titleController.text = widget.topic!.title;
      _descriptionController.text = widget.topic!.description;
      _theoryController.text = widget.topic!.theory;
      _formulasController.text = widget.topic!.formulas.join('\n');
      _keywords = List.from(widget.topic!.keywords);
      _selectedLevel = widget.topic!.level;
      _passingScore = widget.topic!.passingScore;
      _estimatedTime = widget.topic!.estimatedTime;
      _rules = widget.topic!.rules.map((rule) => rule.toJson()).toList();
      _keywordsController.text = _keywords.join(', ');
    } else {
      _topicId = DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  Future<void> _loadQuestions() async {
    final targetId = widget.topic?.id ?? _topicId;
    if (targetId == null) return;

    setState(() => _isLoadingQuestions = true);
    try {
      final snapshot = await _firestore
          .collection('grammar_questions')
          .where('topicId', isEqualTo: targetId)
          .get();
      _questions = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      debugPrint('Số câu hỏi: ${_questions.length}');
    } catch (e) {
      debugPrint('Lỗi load câu hỏi: $e');
    } finally {
      setState(() => _isLoadingQuestions = false);
    }
  }

  void _addKeyword() {
    if (_keywordsController.text.isNotEmpty) {
      setState(() {
        _keywords = _keywordsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      });
    }
  }

  void _addRule() {
    if (_ruleTitleController.text.isEmpty) return;

    final examples = _ruleExamplesController.text
        .split('\n')
        .where((e) => e.isNotEmpty)
        .map((e) {
          final parts = e.split('|');
          return {
            'sentence': parts[0].trim(),
            'meaning': parts.length > 1 ? parts[1].trim() : '',
          };
        })
        .toList();

    setState(() {
      _rules.add({
        'title': _ruleTitleController.text,
        'description': _ruleDescController.text,
        'formulas': _ruleFormulasController.text
            .split('\n')
            .where((e) => e.isNotEmpty)
            .toList(),
        'examples': examples,
        'exceptions': _ruleExceptionsController.text
            .split('\n')
            .where((e) => e.isNotEmpty)
            .toList(),
        'notes': _ruleNotesController.text
            .split('\n')
            .where((e) => e.isNotEmpty)
            .toList(),
      });
    });

    _ruleTitleController.clear();
    _ruleDescController.clear();
    _ruleFormulasController.clear();
    _ruleExamplesController.clear();
    _ruleExceptionsController.clear();
    _ruleNotesController.clear();
  }

  void _removeRule(int index) {
    setState(() => _rules.removeAt(index));
  }

  Future<void> _addQuestion() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminGrammarQuestionForm(topicId: _topicId!),
      ),
    );
    if (result == true && mounted) {
      _loadQuestions();
    }
  }

  Future<void> _editQuestion(Map<String, dynamic> question) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AdminGrammarQuestionForm(topicId: _topicId!, question: question),
      ),
    );
    if (result == true && mounted) {
      _loadQuestions();
    }
  }

  Future<void> _deleteQuestion(Map<String, dynamic> question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete question'),
        content: const Text('Are you sure you want to delete this question?'),
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
      setState(() => _isLoadingQuestions = true);
      try {
        await _firestore
            .collection('grammar_questions')
            .doc(question['id'])
            .delete();
        await _loadQuestions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Question deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        setState(() => _isLoadingQuestions = false);
      }
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final topicData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'level': _selectedLevel,
        'theory': _theoryController.text,
        'formulas': _formulasController.text
            .split('\n')
            .where((e) => e.isNotEmpty)
            .toList(),
        'keywords': _keywords,
        'rules': _rules,
        'quizCount': _questions.length,
        'passingScore': _passingScore,
        'estimatedTime': _estimatedTime,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.topic != null) {
        topicData['createdAt'] = widget.topic!.createdAt;
        topicData['progress'] = widget.topic!.progress;
        topicData['icon'] = 'article';

        await _firestore
            .collection('grammar_topics')
            .doc(widget.topic!.id)
            .set(topicData, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Updated successfully!')),
          );
        }
      } else {
        topicData['createdAt'] = FieldValue.serverTimestamp();
        topicData['progress'] = 0.0;
        topicData['icon'] = 'article';
        topicData['id'] = _topicId!;

        await _firestore
            .collection('grammar_topics')
            .doc(_topicId!)
            .set(topicData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Topic added successfully!')),
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
    final isEditing = widget.topic != null;

    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit topic' : 'Add new topic'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Formulas'),
            Tab(text: 'Keywords'),
            Tab(text: 'Rules'),
            Tab(text: 'Exercises'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _KeepAliveWrapper(child: _buildInfoTab()),
            _KeepAliveWrapper(child: _buildFormulasTab()),
            _KeepAliveWrapper(child: _buildKeywordsTab()),
            _KeepAliveWrapper(child: _buildRulesTab()),
            _KeepAliveWrapper(child: _buildQuestionsTab()),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SafeArea(
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
                : const Text('SAVE TOPIC'),
          ),
        ),
      ),
    );
  }

  // ==================== TAB 1: THÔNG TIN ====================
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTextField(_titleController, 'Title', Icons.title),
          const SizedBox(height: 16),
          _buildTextField(
            _descriptionController,
            'Short description',
            Icons.description,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            _theoryController,
            'Detailed theory',
            Icons.menu_book,
            maxLines: 10,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedLevel,
            decoration: const InputDecoration(
              labelText: 'Level',
              border: OutlineInputBorder(),
            ),
            items: _levels.map((level) {
              return DropdownMenuItem(value: level, child: Text(level));
            }).toList(),
            onChanged: (value) => setState(() => _selectedLevel = value!),
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            _questions.length.toString(),
            'Question count (automatic)',
            Icons.quiz,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            TextEditingController(text: _passingScore.toString()),
            'Passing score (%)',
            Icons.assignment_turned_in,
            keyboardType: TextInputType.number,
            onChanged: (v) => _passingScore = int.tryParse(v) ?? 70,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            TextEditingController(text: _estimatedTime.toString()),
            'Estimated time (minutes)',
            Icons.timer,
            keyboardType: TextInputType.number,
            onChanged: (v) => _estimatedTime = int.tryParse(v) ?? 15,
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: CÔNG THỨC ====================
  Widget _buildFormulasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter formulas, one per line',
            style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _formulasController,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Example:\nS + V(s/es) + O\nS + do/does + not + V',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 3: TỪ KHÓA ====================
  Widget _buildKeywordsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recognition signals, separated by commas',
            style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _keywordsController,
            decoration: const InputDecoration(
              hintText: 'Example: always, usually, every day, often',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _addKeyword(),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _keywords
                .map((keyword) => Chip(label: Text(keyword)))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 4: QUY TẮC ====================
  Widget _buildRulesTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_rules.isNotEmpty)
            ..._rules.asMap().entries.map((entry) {
              final index = entry.key;
              final rule = entry.value;
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(rule['title'] ?? ''),
                  subtitle: Text(
                    (rule['description'] ?? '').length > 80
                        ? '${(rule['description'] ?? '').substring(0, 80)}...'
                        : rule['description'] ?? '',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeRule(index),
                  ),
                ),
              );
            }),

          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Add new rule',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSmallTextField(_ruleTitleController, 'Rule title'),
                const SizedBox(height: 8),
                _buildSmallTextField(
                  _ruleDescController,
                  'Description',
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                _buildSmallTextField(
                  _ruleFormulasController,
                  'Formula',
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                _buildSmallTextField(
                  _ruleExamplesController,
                  'Example',
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                _buildSmallTextField(
                  _ruleExceptionsController,
                  'Exception',
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                _buildSmallTextField(
                  _ruleNotesController,
                  'Notes',
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _addRule,
                  icon: const Icon(Icons.add),
                  label: const Text('Add rule'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ==================== TAB 5: BÀI TẬP ====================
  Widget _buildQuestionsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question list',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add question'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingQuestions
              ? const Center(child: CircularProgressIndicator())
              : _questions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No questions yet'),
                      Text('Tap "Add question" to create an exercise'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final q = _questions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          q['question'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Answer: ${q['correctAnswer']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editQuestion(q),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteQuestion(q),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==================== HELPER WIDGETS ====================
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value?.isEmpty == true ? 'Please enter $label' : null,
    );
  }

  Widget _buildReadOnlyField(String value, String label, IconData icon) {
    return TextFormField(
      initialValue: value,
      key: Key(value),
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        fillColor: Colors.grey.shade100,
        filled: true,
      ),
    );
  }

  Widget _buildSmallTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _theoryController.dispose();
    _formulasController.dispose();
    _keywordsController.dispose();
    _ruleTitleController.dispose();
    _ruleDescController.dispose();
    _ruleFormulasController.dispose();
    _ruleExamplesController.dispose();
    _ruleExceptionsController.dispose();
    _ruleNotesController.dispose();
    super.dispose();
  }
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
