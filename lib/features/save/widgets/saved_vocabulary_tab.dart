import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_widget.dart';
import 'empty_state_widget.dart';
import 'package:audioplayers/audioplayers.dart';

class SavedVocabularyTab extends StatefulWidget {
  final String userId;
  const SavedVocabularyTab({super.key, required this.userId});

  @override
  State<SavedVocabularyTab> createState() => _SavedVocabularyTabState();
}

class _SavedVocabularyTabState extends State<SavedVocabularyTab> {
  // 🌟 2. Khởi tạo đối tượng phát âm thanh dùng chung cho danh sách
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playAudio(String url) async {
    if (url.isNotEmpty) {
      try {
        await _audioPlayer.stop(); // Dừng âm thanh cũ nếu đang phát dở
        await _audioPlayer.play(UrlSource(url));
      } catch (e) {
        debugPrint("Lỗi phát âm thanh: $e");
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Giải phóng bộ nhớ khi thoát trang
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('saved_vocabulary')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('savedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingWidget());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.g_translate,
            message: 'No saved vocabulary yet.',
          );
        }

        final vocabDocs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: vocabDocs.length,
          itemBuilder: (context, index) {
            final doc = vocabDocs[index];
            final data = doc.data() as Map<String, dynamic>;

            final String word = data['word'] ?? '';
            final String definition = data['definition'] ?? '';
            final String pronunciation = data['pronunciation'] ?? '';
            final String audioUrl = data['audioUrl'] ?? ''; // 🌟 3. Lấy link audio từ Firestore

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                // 🌟 Tối ưu Title: Đưa Từ vựng + Nút Loa + Phiên âm sát cạnh nhau
                title: Row(
                  children: [
                    Text(
                      word,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 🌟 4. Nếu có link audio thì hiển thị nút loa nhỏ màu xanh dương
                    if (audioUrl.isNotEmpty)
                      GestureDetector(
                        onTap: () => _playAudio(audioUrl),
                        child: const Icon(Icons.volume_up, size: 18, color: Colors.blueAccent),
                      ),
                    const SizedBox(width: 8),
                    if (pronunciation.isNotEmpty)
                      Expanded(
                        child: Text(
                          pronunciation,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 13,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildParsedDefinition(definition),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('saved_vocabulary')
                        .doc(doc.id)
                        .delete();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildParsedDefinition(String rawDefinition) {
    String formattedText = rawDefinition;

    formattedText = formattedText
        .replaceAll('; 2.', '\n2.')
        .replaceAll('; 3.', '\n3.')
        .replaceAll('; 4.', '\n4.');

    final regex = RegExp(r'(\[[A-Z]+\])\s*(1\.)');

    formattedText = formattedText.replaceAllMapped(regex, (match) {
      return '${match.group(1)}\n${match.group(2)}';
    });

    List<String> lines = formattedText.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        String trimmedLine = line.trim();
        if (trimmedLine.isEmpty) return const SizedBox.shrink();

        bool isHeader = trimmedLine.startsWith('[') && trimmedLine.contains(']');

        return Padding(
          padding: EdgeInsets.only(
            top: isHeader ? 10.0 : 4.0,
            bottom: isHeader ? 4.0 : 2.0,
            left: isHeader ? 0.0 : 12.0,
          ),
          child: Text(
            trimmedLine,
            style: GoogleFonts.beVietnamPro(
              fontSize: isHeader ? 14 : 13,
              fontWeight: isHeader ? FontWeight.w800 : FontWeight.w500,
              color: isHeader ? const Color(0xFF1E88E5) : const Color(0xFF333333),
              height: 1.4,
            ),
          ),
        );
      }).toList(),
    );
  }
}