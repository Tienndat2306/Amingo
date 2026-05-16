import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_widget.dart';
import 'empty_state_widget.dart';

class SavedVocabularyTab extends StatelessWidget {
  final String userId;
  const SavedVocabularyTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('saved_vocabulary')
          .where('userId', isEqualTo: userId)
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

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  word,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    pronunciation.isNotEmpty ? '$pronunciation • $definition' : definition,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
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
}