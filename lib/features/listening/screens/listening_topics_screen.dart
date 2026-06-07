import 'package:flutter/material.dart';
import '../../../data/models/listening_topic.dart';
import '../../../data/repositories/listening_repository.dart';
import 'listening_sections_screen.dart';

class ListeningTopicsScreen extends StatelessWidget {
  const ListeningTopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ListeningRepository repository = ListeningRepository();
    
    const primaryBrown = Color(0xFF5D4037);
    const subTextBrown = Color(0xFF8D6E63);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text(
          'Listening Topics',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryBrown),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: StreamBuilder<List<ListeningTopic>>(
        stream: repository.watchTopics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryBrown)),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No listening topics available yet.", style: TextStyle(color: primaryBrown)),
            );
          }

          final topics = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBrown.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    leading: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF9C4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.folder_special_rounded, color: Color(0xFFFFB300), size: 28),
                    ),
                    title: Text(
                      topic.title,
                      style: const TextStyle(color: primaryBrown, fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        topic.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: subTextBrown, fontSize: 13, height: 1.3),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFB300), size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListeningSectionsScreen(
                            topicId: topic.id,
                            topicTitle: topic.title,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}