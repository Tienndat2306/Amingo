import 'package:flutter/material.dart';
import '../../../data/models/listening_lesson.dart';
import '../../../data/models/listening_section.dart';
import '../../../data/repositories/listening_repository.dart';
import 'admin_listening_detail_screen.dart';

// Color constants shared across this file
const Color _primaryBrown = Color(0xFF5D4037);
const Color _textSecondary = Color(0xFF8D6E63);
const Color _backgroundLight = Color(0xFFFDFBF7);
const Color _accentGold = Color(0xFFFFB300);
const Color _buttonGrey = Color(0xFF78909C);

const List<String> _kLevels = [
  'All levels',
  'A1',
  'A2',
  'B1',
  'B2',
  'C1',
  'C2',
];

class AdminListeningSectionsScreen extends StatefulWidget {
  final String topicId;
  final String topicTitle;

  const AdminListeningSectionsScreen({
    super.key,
    required this.topicId,
    required this.topicTitle,
  });

  @override
  State<AdminListeningSectionsScreen> createState() =>
      _AdminListeningSectionsScreenState();
}

class _AdminListeningSectionsScreenState
    extends State<AdminListeningSectionsScreen> {
  final ListeningRepository _repository = ListeningRepository();
  final TextEditingController _searchController = TextEditingController();

  String _selectedLevel = 'All levels';
  String _appliedSearchQuery = '';
  String _appliedLevel = 'All levels';
  List<ListeningSection> _currentSections = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLoading(BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_primaryBrown),
        ),
      ),
    );
  }

  void _showSectionDialog({ListeningSection? section}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SectionFormDialog(
        section: section,
        topicId: widget.topicId,
        currentSections: _currentSections,
        repository: _repository,
      ),
    );
  }

  void _showLessonDialog({
    required String sectionId,
    ListeningLesson? lesson,
    required List<ListeningLesson> existingLessons,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _LessonFormDialog(
        sectionId: sectionId,
        lesson: lesson,
        existingLessons: existingLessons,
        topicId: widget.topicId,
        repository: _repository,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      appBar: AppBar(
        title: Text(
          'Admin: ${widget.topicTitle}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: _primaryBrown,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _primaryBrown,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSectionDialog(),
        backgroundColor: _primaryBrown,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Section',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search & filter bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _primaryBrown,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search lessons...',
                        hintStyle: TextStyle(
                          color: _textSecondary.withAlpha(150),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: _textSecondary,
                          size: 18,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 0.5,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLevel,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _textSecondary,
                          size: 20,
                        ),
                        style: const TextStyle(
                          color: _primaryBrown,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        dropdownColor: Colors.white,
                        items: _kLevels
                            .map(
                              (l) => DropdownMenuItem(value: l, child: Text(l)),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _selectedLevel = v);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonGrey,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _appliedSearchQuery = _searchController.text
                            .trim()
                            .toLowerCase();
                        _appliedLevel = _selectedLevel;
                      });
                    },
                    child: const Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE0E0E0)),
          // Section list
          Expanded(
            child: StreamBuilder<List<ListeningSection>>(
              stream: _repository.watchSections(topicId: widget.topicId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryBrown),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  _currentSections = [];
                  return const Center(
                    child: Text(
                      'No sections available yet.',
                      style: TextStyle(
                        color: _textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                _currentSections = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 12,
                    bottom: 100,
                  ),
                  itemCount: _currentSections.length,
                  itemBuilder: (context, index) {
                    final section = _currentSections[index];
                    return _SectionTile(
                      key: ValueKey(
                        '${section.id}_${_appliedSearchQuery}_$_appliedLevel',
                      ),
                      section: section,
                      topicId: widget.topicId,
                      repository: _repository,
                      appliedSearchQuery: _appliedSearchQuery,
                      appliedLevel: _appliedLevel,
                      onEditSection: () => _showSectionDialog(section: section),
                      onAddLesson: (lessons) => _showLessonDialog(
                        sectionId: section.id,
                        existingLessons: lessons,
                      ),
                      onEditLesson: (lesson, lessons) => _showLessonDialog(
                        sectionId: section.id,
                        lesson: lesson,
                        existingLessons: lessons,
                      ),
                      showLoading: _showLoading,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DIALOG — Add / Edit Section
// ---------------------------------------------------------------------------
class _SectionFormDialog extends StatefulWidget {
  final ListeningSection? section;
  final String topicId;
  final List<ListeningSection> currentSections;
  final ListeningRepository repository;

  const _SectionFormDialog({
    this.section,
    required this.topicId,
    required this.currentSections,
    required this.repository,
  });

  @override
  State<_SectionFormDialog> createState() => _SectionFormDialogState();
}

class _SectionFormDialogState extends State<_SectionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _orderCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.section?.title ?? '');
    _orderCtrl = TextEditingController(
      text: widget.section?.order.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.section != null;
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        isEdit ? 'Edit Section' : 'Add New Section',
        style: const TextStyle(
          color: _primaryBrown,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleCtrl,
              style: const TextStyle(color: _primaryBrown),
              decoration: const InputDecoration(
                labelText: 'Section Title',
                labelStyle: TextStyle(color: _textSecondary),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _primaryBrown),
                ),
                prefixIcon: Icon(Icons.folder_outlined, color: _textSecondary),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter title' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _orderCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: _primaryBrown),
              decoration: const InputDecoration(
                labelText: 'Order Index',
                labelStyle: TextStyle(color: _textSecondary),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _primaryBrown),
                ),
                prefixIcon: Icon(
                  Icons.format_list_numbered,
                  color: _textSecondary,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter order index';
                final n = int.tryParse(v.trim());
                if (n == null) return 'Must be a valid integer';
                final duplicate = widget.currentSections.any(
                  (s) =>
                      s.order == n &&
                      (isEdit ? s.id != widget.section!.id : true),
                );
                if (duplicate) return 'This order index already exists!';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: _buttonGrey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _primaryBrown),
          onPressed: _isSaving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isSaving = true);
                  final order = int.parse(_orderCtrl.text.trim());
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _primaryBrown,
                        ),
                      ),
                    ),
                  );
                  try {
                    if (isEdit) {
                      await widget.repository.updateSection(
                        topicId: widget.topicId,
                        section: ListeningSection(
                          id: widget.section!.id,
                          title: _titleCtrl.text.trim(),
                          order: order,
                        ),
                      );
                    } else {
                      await widget.repository.addSection(
                        topicId: widget.topicId,
                        section: ListeningSection(
                          id: '',
                          title: _titleCtrl.text.trim(),
                          order: order,
                        ),
                      );
                    }
                    if (mounted) {
                      Navigator.pop(this.context);
                      Navigator.pop(this.context);
                    }
                  } catch (_) {
                    if (mounted) {
                      Navigator.pop(this.context);
                      setState(() => _isSaving = false);
                    }
                  }
                },
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// DIALOG — Add / Edit Lesson
// ---------------------------------------------------------------------------
class _LessonFormDialog extends StatefulWidget {
  final String sectionId;
  final ListeningLesson? lesson;
  final List<ListeningLesson> existingLessons;
  final String topicId;
  final ListeningRepository repository;

  const _LessonFormDialog({
    required this.sectionId,
    this.lesson,
    required this.existingLessons,
    required this.topicId,
    required this.repository,
  });

  @override
  State<_LessonFormDialog> createState() => _LessonFormDialogState();
}

class _LessonFormDialogState extends State<_LessonFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _orderCtrl;
  late String _level;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.lesson?.title ?? '');
    _orderCtrl = TextEditingController(
      text: widget.lesson?.order.toString() ?? '',
    );
    _level = widget.lesson?.vocabLevel ?? 'A1';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.lesson != null;
    final levelItems = _kLevels.where((l) => l != 'All levels').toList();

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        isEdit ? 'Edit Lesson' : 'Add New Lesson',
        style: const TextStyle(
          color: _primaryBrown,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleCtrl,
              style: const TextStyle(color: _primaryBrown),
              decoration: const InputDecoration(
                labelText: 'Lesson Title',
                labelStyle: TextStyle(color: _textSecondary),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _primaryBrown),
                ),
                prefixIcon: Icon(Icons.music_note, color: _textSecondary),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter title' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _orderCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: _primaryBrown),
              decoration: const InputDecoration(
                labelText: 'Order Index',
                labelStyle: TextStyle(color: _textSecondary),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _primaryBrown),
                ),
                prefixIcon: Icon(Icons.low_priority, color: _textSecondary),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter order index';
                final n = int.tryParse(v.trim());
                if (n == null) return 'Must be an integer';
                final duplicate = widget.existingLessons.any(
                  (l) =>
                      l.order == n &&
                      (isEdit ? l.id != widget.lesson!.id : true),
                );
                if (duplicate) return 'This order index already exists!';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _level,
              dropdownColor: Colors.white,
              menuMaxHeight: 220,
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: _primaryBrown,
                size: 26,
              ),
              borderRadius: BorderRadius.circular(12),
              style: const TextStyle(
                color: _primaryBrown,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                labelText: 'Vocabulary Level',
                labelStyle: TextStyle(color: _textSecondary),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _primaryBrown),
                ),
                prefixIcon: Icon(Icons.g_translate, color: _textSecondary),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: levelItems
                  .map(
                    (l) => DropdownMenuItem(
                      value: l,
                      child: Text(
                        l,
                        style: const TextStyle(
                          color: _primaryBrown,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _level = v);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: _buttonGrey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _primaryBrown),
          onPressed: _isSaving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isSaving = true);

                  final newLesson = ListeningLesson(
                    id: widget.lesson?.id ?? '',
                    title: _titleCtrl.text.trim(),
                    order: int.parse(_orderCtrl.text.trim()),
                    totalParts: widget.lesson?.totalParts ?? 0,
                    vocabLevel: _level,
                  );

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _primaryBrown,
                        ),
                      ),
                    ),
                  );

                  try {
                    if (isEdit) {
                      await widget.repository.updateLessonWithLines(
                        topicId: widget.topicId,
                        sectionId: widget.sectionId,
                        lesson: newLesson,
                        lines: [],
                      );
                    } else {
                      await widget.repository.addLessonWithLines(
                        topicId: widget.topicId,
                        sectionId: widget.sectionId,
                        lesson: newLesson,
                        lines: [],
                      );
                    }
                    if (mounted) {
                      Navigator.pop(this.context);
                      Navigator.pop(this.context);
                    }
                  } catch (_) {
                    if (mounted) {
                      Navigator.pop(this.context);
                      setState(() => _isSaving = false);
                    }
                  }
                },
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGET — Section tile with expandable lesson list
// ---------------------------------------------------------------------------
class _SectionTile extends StatelessWidget {
  final ListeningSection section;
  final String topicId;
  final ListeningRepository repository;
  final String appliedSearchQuery;
  final String appliedLevel;
  final VoidCallback onEditSection;
  final Function(List<ListeningLesson>) onAddLesson;
  final Function(ListeningLesson, List<ListeningLesson>) onEditLesson;
  final Function(BuildContext) showLoading;

  const _SectionTile({
    super.key,
    required this.section,
    required this.topicId,
    required this.repository,
    required this.appliedSearchQuery,
    required this.appliedLevel,
    required this.onEditSection,
    required this.onAddLesson,
    required this.onEditLesson,
    required this.showLoading,
  });

  Future<bool?> _confirmDelete(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Confirm Delete',
          style: TextStyle(fontWeight: FontWeight.bold, color: _primaryBrown),
        ),
        content: Text('Delete "$name" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: _buttonGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ListeningLesson>>(
      stream: repository.watchLessons(topicId: topicId, sectionId: section.id),
      builder: (context, snapshot) {
        final allLessons = snapshot.data ?? [];
        final filtered = allLessons.where((l) {
          final matchSearch = l.title.toLowerCase().contains(
            appliedSearchQuery,
          );
          final matchLevel =
              appliedLevel == 'All levels' || l.vocabLevel == appliedLevel;
          return matchSearch && matchLevel;
        }).toList();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _primaryBrown.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: ExpansionTile(
              initiallyExpanded:
                  appliedSearchQuery.isNotEmpty || appliedLevel != 'All levels',
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              childrenPadding: const EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: 16,
              ),
              iconColor: _accentGold,
              collapsedIconColor: _accentGold,
              leading: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5EBE6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.folder_open_rounded,
                  color: _primaryBrown,
                  size: 18,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: const TextStyle(
                            color: _primaryBrown,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${filtered.length} lessons',
                          style: const TextStyle(
                            color: _textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: _textSecondary,
                      size: 18,
                    ),
                    onPressed: onEditSection,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    onPressed: () async {
                      final ok = await _confirmDelete(
                        context,
                        'Section: ${section.title}',
                      );
                      if (ok == true && context.mounted) {
                        final nav = Navigator.of(context);
                        showLoading(context);
                        try {
                          await repository.deleteSection(
                            topicId: topicId,
                            sectionId: section.id,
                          );
                        } finally {
                          nav.pop();
                        }
                      }
                    },
                  ),
                ],
              ),
              children: [
                const Divider(
                  color: Color(0xFFF5EBE6),
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => onAddLesson(allLessons),
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: _accentGold,
                      size: 18,
                    ),
                    label: const Text(
                      'Add Lesson',
                      style: TextStyle(
                        color: _primaryBrown,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No lessons available.',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final lesson = filtered[i];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: _backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF5EBE6)),
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(
                            left: 12,
                            right: 4,
                            top: 2,
                            bottom: 2,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminListeningDetailScreen(
                                topicId: topicId,
                                sectionId: section.id,
                                lesson: lesson,
                              ),
                            ),
                          ),
                          leading: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.music_note_rounded,
                              color: _textSecondary,
                              size: 14,
                            ),
                          ),
                          title: Text(
                            '${i + 1}. ${lesson.title}',
                            style: const TextStyle(
                              color: _primaryBrown,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            'Level: ${lesson.vocabLevel} • Parts: ${lesson.totalParts}',
                            style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: _textSecondary,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    onEditLesson(lesson, allLessons),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                onPressed: () async {
                                  final ok = await _confirmDelete(
                                    context,
                                    'Lesson: ${lesson.title}',
                                  );
                                  if (ok == true && context.mounted) {
                                    final nav = Navigator.of(context);
                                    showLoading(context);
                                    try {
                                      await repository.deleteLesson(
                                        topicId: topicId,
                                        sectionId: section.id,
                                        lessonId: lesson.id,
                                      );
                                    } finally {
                                      nav.pop();
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
