import 'package:flutter/material.dart';
import '../../../data/models/listening_section.dart';
import '../../../data/models/listening_lesson.dart';
import '../../../data/repositories/listening_repository.dart';
import 'listening_detail_screen.dart';

class ListeningSectionsScreen extends StatefulWidget {
  final String topicId;
  final String topicTitle;

  const ListeningSectionsScreen({
    super.key,
    required this.topicId,
    required this.topicTitle,
  });

  @override
  State<ListeningSectionsScreen> createState() =>
      _ListeningSectionsScreenState();
}

class _ListeningSectionsScreenState extends State<ListeningSectionsScreen> {
  final ListeningRepository _repository = ListeningRepository();

  final TextEditingController _searchController = TextEditingController();
  String _selectedLevel = 'All levels';

  String _appliedSearchQuery = '';
  String _appliedLevel = 'All levels';

  final List<String> _levels = [
    'All levels',
    'A1',
    'A2',
    'B1',
    'B2',
    'C1',
    'C2',
  ];

  static const Color primaryBrown = Color(0xFF5D4037);
  static const Color textSecondary = Color(0xFF8D6E63);
  static const Color backgroundLight = Color(0xFFFDFBF7);
  static const Color accentGold = Color(0xFFFFB300);
  static const Color buttonGrey = Color(0xFF78909C);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.topicTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: primaryBrown,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryBrown,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
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
                      style: const TextStyle(fontSize: 14, color: primaryBrown),
                      decoration: InputDecoration(
                        hintText: 'Search lessons...',
                        hintStyle: TextStyle(
                          color: textSecondary.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: textSecondary,
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
                  child: StatefulBuilder(
                    builder:
                        (BuildContext context, StateSetter setDropdownState) {
                          return Container(
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
                                  color: textSecondary,
                                  size: 20,
                                ),
                                style: const TextStyle(
                                  color: primaryBrown,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                dropdownColor: Colors.white,
                                items: _levels.map((String level) {
                                  return DropdownMenuItem<String>(
                                    value: level,
                                    child: Text(level),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setDropdownState(() {
                                      _selectedLevel = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          );
                        },
                  ),
                ),
                const SizedBox(width: 8),

                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonGrey,
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
                      'OK',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE0E0E0)),

          Expanded(
            child: StreamBuilder<List<ListeningSection>>(
              stream: _repository.watchSections(topicId: widget.topicId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryBrown),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "An error occurred while loading sections.",
                      style: TextStyle(
                        color: primaryBrown,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No sections available yet.",
                      style: TextStyle(
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                final sections = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  itemCount: sections.length,
                  itemBuilder: (context, sectionIndex) {
                    final section = sections[sectionIndex];

                    return StreamBuilder<List<ListeningLesson>>(
                      stream: _repository.watchLessons(
                        topicId: widget.topicId,
                        sectionId: section.id,
                      ),
                      builder: (context, lessonSnapshot) {
                        List<ListeningLesson> filteredLessons = [];

                        if (lessonSnapshot.hasData) {
                          filteredLessons = lessonSnapshot.data!.where((
                            lesson,
                          ) {
                            final matchesSearch = lesson.title
                                .toLowerCase()
                                .contains(_appliedSearchQuery);
                            final matchesLevel =
                                _appliedLevel == 'All levels' ||
                                lesson.vocabLevel == _appliedLevel;
                            return matchesSearch && matchesLevel;
                          }).toList();
                        }

                        final currentCount = filteredLessons.length;
                        final totalLessonCount =
                            lessonSnapshot.data?.length ?? 0;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primaryBrown.withValues(alpha: 0.04),
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
                              key: ValueKey((
                                section.id,
                                _appliedSearchQuery,
                                _appliedLevel,
                              )),
                              initiallyExpanded:
                                  _appliedSearchQuery.isNotEmpty ||
                                  _appliedLevel != 'All levels',
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              childrenPadding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                bottom: 16,
                              ),
                              textColor: primaryBrown,
                              iconColor: accentGold,
                              collapsedIconColor: accentGold,
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF5EBE6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.folder_open_rounded,
                                  color: primaryBrown,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                section.title,
                                style: const TextStyle(
                                  color: primaryBrown,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: StreamBuilder<Set<String>>(
                                stream: _repository.watchCompletedLessonIds(
                                  topicId: widget.topicId,
                                  sectionId: section.id,
                                ),
                                builder: (context, progressSnapshot) {
                                  final completedIds =
                                      progressSnapshot.data ?? {};
                                  final allLessons =
                                      lessonSnapshot.data ??
                                      <ListeningLesson>[];
                                  final completedCount = allLessons
                                      .where(
                                        (lesson) =>
                                            completedIds.contains(lesson.id),
                                      )
                                      .length;
                                  final progress = totalLessonCount == 0
                                      ? 0.0
                                      : completedCount / totalLessonCount;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Includes: $currentCount lessons  -  Progress: $completedCount/$totalLessonCount",
                                        style: const TextStyle(
                                          color: textSecondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        child: LinearProgressIndicator(
                                          value: progress.clamp(0.0, 1.0),
                                          minHeight: 6,
                                          backgroundColor: const Color(
                                            0xFFF5EBE6,
                                          ),
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Color(0xFF2E7D32)),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              children: [
                                const Divider(
                                  color: Color(0xFFF5EBE6),
                                  thickness: 1,
                                  height: 1,
                                ),
                                const SizedBox(height: 8),

                                if (lessonSnapshot.connectionState ==
                                    ConnectionState.waiting)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                primaryBrown,
                                              ),
                                        ),
                                      ),
                                    ),
                                  )
                                else if (filteredLessons.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.0,
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      "No lessons match the selected filters.",
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  )
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: filteredLessons.length,
                                    itemBuilder: (context, index) {
                                      final lesson = filteredLessons[index];

                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFDFBF7),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFF5EBE6),
                                            width: 1,
                                          ),
                                        ),
                                        child: ListTile(
                                          dense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 4,
                                              ),
                                          leading: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.music_note_rounded,
                                              color: textSecondary,
                                              size: 16,
                                            ),
                                          ),
                                          title: Text(
                                            "${index + 1}. ${lesson.title}",
                                            style: const TextStyle(
                                              color: primaryBrown,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          subtitle: StreamBuilder<Set<String>>(
                                            stream: _repository
                                                .watchCompletedLessonIds(
                                                  topicId: widget.topicId,
                                                  sectionId: section.id,
                                                ),
                                            builder: (context, progressSnapshot) {
                                              final completedIds =
                                                  progressSnapshot.data ?? {};
                                              final isCompleted = completedIds
                                                  .contains(lesson.id);

                                              return Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      "Level: ${lesson.vocabLevel}  -  ${lesson.totalParts} parts",
                                                      style: const TextStyle(
                                                        color: textSecondary,
                                                        fontSize: 12,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (isCompleted) ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFFE8F5E9,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(999),
                                                      ),
                                                      child: const Text(
                                                        'Learned',
                                                        style: TextStyle(
                                                          color: Color(
                                                            0xFF2E7D32,
                                                          ),
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              );
                                            },
                                          ),
                                          trailing: StreamBuilder<Set<String>>(
                                            stream: _repository
                                                .watchCompletedLessonIds(
                                                  topicId: widget.topicId,
                                                  sectionId: section.id,
                                                ),
                                            builder: (context, progressSnapshot) {
                                              final completedIds =
                                                  progressSnapshot.data ?? {};
                                              final isCompleted = completedIds
                                                  .contains(lesson.id);

                                              return Container(
                                                width: 34,
                                                height: 34,
                                                decoration: BoxDecoration(
                                                  color: isCompleted
                                                      ? const Color(0xFFE8F5E9)
                                                      : const Color(0xFFFFF9C4),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  isCompleted
                                                      ? Icons
                                                            .check_circle_rounded
                                                      : Icons
                                                            .play_arrow_rounded,
                                                  color: isCompleted
                                                      ? const Color(0xFF2E7D32)
                                                      : const Color(0xFFFFB300),
                                                  size: 24,
                                                ),
                                              );
                                            },
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ListeningDetailScreen(
                                                      topicId: widget.topicId,
                                                      sectionId: section.id,
                                                      lesson: lesson,
                                                    ),
                                              ),
                                            );
                                          },
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
