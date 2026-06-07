import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Source;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../data/models/listening_lesson.dart';
import '../../../data/models/dictation_line.dart';
import '../widgets/dictation_line_tile.dart';

class AdminListeningDetailScreen extends StatefulWidget {
  final String topicId;
  final String sectionId;
  final ListeningLesson lesson;

  const AdminListeningDetailScreen({
    super.key,
    required this.topicId,
    required this.sectionId,
    required this.lesson,
  });

  @override
  State<AdminListeningDetailScreen> createState() =>
      _AdminListeningDetailScreenState();
}

class _AdminListeningDetailScreenState
    extends State<AdminListeningDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Audio Player & State Management
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingLineId;
  bool _isPlaying = false;
  StreamSubscription? _playerCompleteSubscription;

  late final Stream<QuerySnapshot> _linesStream;

  // System Design Palette
  static const Color primaryBrown = Color(0xFF5D4037);
  static const Color textSecondary = Color(0xFF8D6E63);
  static const Color backgroundLight = Color(0xFFFDFBF7);
  static const Color accentGold = Color(0xFFFFB300);
  static const Color deleteRed = Color(0xFFC62828);

  DocumentReference get _lessonDocRef => _firestore
      .collection('listening_topics')
      .doc(widget.topicId)
      .collection('sections')
      .doc(widget.sectionId)
      .collection('lessons')
      .doc(widget.lesson.id);

  CollectionReference get _linesCollection =>
      _lessonDocRef.collection('dictation_lines');

  String _normalizeAudioSource(String audioPath) {
    final trimmedPath = audioPath.trim();
    if (trimmedPath.startsWith('http://') ||
        trimmedPath.startsWith('https://')) {
      return trimmedPath;
    }

    final slashNormalizedPath = trimmedPath.replaceAll('\\', '/');
    final assetsIndex = slashNormalizedPath.indexOf('assets/audio/');
    if (assetsIndex != -1) {
      return slashNormalizedPath.substring(assetsIndex);
    }

    return trimmedPath;
  }

  Source _buildAudioSource(String audioPath) {
    final normalizedAudioPath = _normalizeAudioSource(audioPath);
    if (normalizedAudioPath.startsWith('assets/')) {
      return AssetSource(normalizedAudioPath.replaceFirst('assets/', ''));
    }
    if (normalizedAudioPath.startsWith('http://') ||
        normalizedAudioPath.startsWith('https://')) {
      return UrlSource(normalizedAudioPath);
    }
    return DeviceFileSource(normalizedAudioPath);
  }

  Future<String?> _uploadAudioFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final fileName = file.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final storagePath =
        'listening_audio/${widget.topicId}/${widget.sectionId}/${widget.lesson.id}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final ref = FirebaseStorage.instance.ref().child(storagePath);

    if (file.bytes != null) {
      await ref.putData(
        file.bytes!,
        SettableMetadata(contentType: 'audio/mpeg'),
      );
    } else if (file.path != null) {
      await ref.putFile(
        File(file.path!),
        SettableMetadata(contentType: 'audio/mpeg'),
      );
    } else {
      throw Exception('Unable to read the selected audio file.');
    }

    return ref.getDownloadURL();
  }

  @override
  void initState() {
    super.initState();

    _linesStream = _linesCollection
        .orderBy('index', descending: false)
        .snapshots();

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentlyPlayingLineId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio(String lineId, String audioPath) async {
    if (audioPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Audio path is not configured for this line!"),
        ),
      );
      return;
    }

    if (_currentlyPlayingLineId == lineId && _isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioPlayer.stop();
      try {
        await _audioPlayer.play(_buildAudioSource(audioPath));
        if (!mounted) return;
        setState(() {
          _currentlyPlayingLineId = lineId;
          _isPlaying = true;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Audio playback error: $e")));
      }
    }
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(
        color: textSecondary.withValues(alpha: 0.5),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: primaryBrown, size: 20),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      floatingLabelStyle: const TextStyle(
        color: primaryBrown,
        fontWeight: FontWeight.bold,
      ),
      filled: true,
      fillColor: const Color(0xFFFDFBF7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEFEBE9), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBrown, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: Text(
          "Admin: ${widget.lesson.title}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _linesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Something went wrong: ${snapshot.error}"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(accentGold),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.queue_music_rounded,
                    size: 64,
                    color: textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No dictation lines yet!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap the '+' button below to add a new line.",
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final line = DictationLine.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
              final isCurrentLinePlaying =
                  (_currentlyPlayingLineId == line.id && _isPlaying);

              return DictationLineTile(
                key: ValueKey(line.id),
                line: line,
                isPlaying: isCurrentLinePlaying,
                onPlayToggle: () => _toggleAudio(line.id, line.audioUrl),
                onEdit: () => _showFormDialog(context, line: line),
                onDelete: () => _confirmDelete(context, line.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        onPressed: () => _showFormDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFormDialog(BuildContext context, {DictationLine? line}) {
    final isEdit = line != null;
    final indexController = TextEditingController(
      text: isEdit ? line.index.toString() : "",
    );
    final textController = TextEditingController(
      text: isEdit ? line.correctText : "",
    );
    final audioController = TextEditingController(
      text: isEdit ? line.audioUrl : "",
    );

    String? dialogError;
    bool isSaving = false;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (subContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    isEdit
                        ? Icons.edit_note_rounded
                        : Icons.add_circle_outline_rounded,
                    color: primaryBrown,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? "Edit Dictation Line" : "Add New Line",
                    style: const TextStyle(
                      color: primaryBrown,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (dialogError != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: deleteRed.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: deleteRed.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: deleteRed,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  dialogError!,
                                  style: const TextStyle(
                                    color: deleteRed,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      const SizedBox(height: 4),
                      TextField(
                        controller: indexController,
                        keyboardType: TextInputType.number,
                        enabled: !isSaving,
                        style: const TextStyle(
                          color: primaryBrown,
                          fontSize: 15,
                        ),
                        decoration: _buildInputDecoration(
                          label: "Line Order (Index)",
                          icon: Icons.format_list_numbered_rounded,
                          hint: "e.g., 1, 2, 3",
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: textController,
                        maxLines: 3,
                        enabled: !isSaving,
                        style: const TextStyle(
                          color: primaryBrown,
                          fontSize: 15,
                        ),
                        decoration: _buildInputDecoration(
                          label: "Correct Transcription Text",
                          icon: Icons.text_fields_rounded,
                          hint: "Type the exact speech text here...",
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: audioController,
                        enabled: !isSaving && !isUploading,
                        style: const TextStyle(
                          color: primaryBrown,
                          fontSize: 14,
                        ),
                        decoration: _buildInputDecoration(
                          label: "Audio Source Path / URL",
                          icon: Icons.audiotrack_rounded,
                          hint: "assets/audio/... or https://...",
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryBrown,
                            side: BorderSide(
                              color: primaryBrown.withValues(alpha: 0.35),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isSaving || isUploading
                              ? null
                              : () async {
                                  setDialogState(() {
                                    isUploading = true;
                                    dialogError = null;
                                  });

                                  try {
                                    final downloadUrl =
                                        await _uploadAudioFile();
                                    if (downloadUrl == null) {
                                      setDialogState(() {
                                        isUploading = false;
                                      });
                                      return;
                                    }

                                    audioController.text = downloadUrl;
                                    setDialogState(() {
                                      isUploading = false;
                                    });
                                  } catch (e) {
                                    setDialogState(() {
                                      dialogError = "Audio upload failed: $e";
                                      isUploading = false;
                                    });
                                  }
                                },
                          icon: isUploading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: primaryBrown,
                                  ),
                                )
                              : const Icon(Icons.upload_file_rounded),
                          label: Text(
                            isUploading ? "Uploading audio..." : "Upload MP3",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.only(
                right: 16,
                bottom: 16,
                left: 16,
              ),
              actions: [
                TextButton(
                  onPressed: isSaving || isUploading
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBrown,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isSaving || isUploading
                      ? null
                      : () async {
                          final String text = textController.text.trim();
                          final String audio = _normalizeAudioSource(
                            audioController.text,
                          );
                          final int? indexNum = int.tryParse(
                            indexController.text.trim(),
                          );

                          if (text.isEmpty ||
                              audio.isEmpty ||
                              indexNum == null) {
                            setDialogState(() {
                              dialogError =
                                  "Please fill in all fields with valid details!";
                            });
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                            dialogError = null;
                          });

                          try {
                            final checkQuery = await _linesCollection
                                .where('index', isEqualTo: indexNum)
                                .get();

                            bool isDuplicate = false;
                            if (isEdit) {
                              isDuplicate = checkQuery.docs.any(
                                (doc) => doc.id != line.id,
                              );
                            } else {
                              isDuplicate = checkQuery.docs.isNotEmpty;
                            }

                            if (isDuplicate) {
                              setDialogState(() {
                                dialogError =
                                    "Index '$indexNum' already exists! Please use a unique order number.";
                                isSaving = false;
                              });
                              return;
                            }

                            final data = {
                              'index': indexNum,
                              'correctText': text,
                              'audioUrl': audio,
                            };

                            if (isEdit) {
                              await _linesCollection.doc(line.id).update(data);
                            } else {
                              await _linesCollection.add(data);
                              await _lessonDocRef.update({
                                'totalParts': FieldValue.increment(1),
                              });
                            }

                            if (context.mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEdit
                                        ? "Updated successfully!"
                                        : "Added successfully!",
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() {
                              dialogError = "Error saving data: $e";
                              isSaving = false;
                            });
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: deleteRed, size: 24),
              SizedBox(width: 8),
              Text(
                "Confirm Delete",
                style: TextStyle(
                  color: primaryBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to delete this dictation line? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                "Cancel",
                style: TextStyle(color: textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: deleteRed,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                try {
                  await _linesCollection.doc(docId).delete();
                  await _lessonDocRef.update({
                    'totalParts': FieldValue.increment(-1),
                  });

                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Line deleted successfully!"),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error deleting line: $e")),
                    );
                  }
                }
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
