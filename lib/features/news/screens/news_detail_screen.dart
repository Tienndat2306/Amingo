import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/news_article.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import '../../../data/services/article_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleDetailScreen extends StatelessWidget {
  final NewsArticle article;

  final ArticleService _articleService = ArticleService();

  ArticleDetailScreen({super.key, required this.article});

  // Future<Map<String, dynamic>> fetchWordDefinition(String word) async {
  //   final url = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
  //
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       if (data.isNotEmpty) {
  //         return data[0];
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Dictionary API Error: $e");
  //   }
  //   return {};
  // }

  // Nhiều nghĩa
  Future<List<dynamic>> fetchWordDefinition(String word) async {
    final url = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data;
        }
      }
    } catch (e) {
      debugPrint("Dictionary API Error: $e");
    }
    return [];
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playPronunciation(String url) async {
    if (url.isNotEmpty) {
      await _audioPlayer.play(UrlSource(url));
    }
  }

  String _extractAllDefinitions(List<dynamic> entries) {
    StringBuffer buffer = StringBuffer();

    for (var entry in entries) {
      final List<dynamic> meanings = entry['meanings'] ?? [];

      for (var meaning in meanings) {
        final String partOfSpeech = meaning['partOfSpeech'] ?? '';
        final List<dynamic> definitions = meaning['definitions'] ?? [];

        buffer.write('[${partOfSpeech.toUpperCase()}] ');

        List<String> defLines = [];
        for (int i = 0; i < definitions.length && i < 3; i++) {
          String defText = definitions[i]['definition'] ?? '';
          defLines.add('${i + 1}. $defText');
        }

        buffer.write(defLines.join('; '));
        buffer.write('\n');
      }
    }

    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> sections = article.sections ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              article.difficulty ?? 'B2',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.category?.toUpperCase() ?? 'NEWS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              article.title ?? '',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  article.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            const SizedBox(height: 24),
            // Content Sections
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                final String heading = section.heading ?? '';
                final List<dynamic> paragraphs = section.paragraphs ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (heading.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        heading,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ...paragraphs.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildInteractiveParagraph(context, p.toString()),
                    )),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveParagraph(BuildContext context, String paragraph) {
    String normalizedParagraph = paragraph
        .replaceAll('—', ' ')
        .replaceAll('-', ' ')
        .replaceAll('/', ' ');

    final List<String> words = normalizedParagraph.split(' ');

    return Wrap(
      spacing: 4.0,
      runSpacing: 6.0,
      children: words.map((word) {
        final cleanWord = word.replaceAll(RegExp(r'[^a-zA-Z]'), '');
        return GestureDetector(
          onDoubleTap: () => _showDictionaryBottomSheet(context, cleanWord),
          child: Text(
            '$word ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              height: 1.5,
              color: const Color(0xFF2D3436),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showDictionaryBottomSheet(BuildContext context, String word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // Dùng FutureBuilder để lắng nghe dữ liệu từ API mạng
        // return FutureBuilder<Map<String, dynamic>>(
        //   future: fetchWordDefinition(word),
        //   builder: (context, snapshot) {
        //     // 1. Trạng thái Đang tải dữ liệu
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return Container(
        //         height: 200,
        //         alignment: Alignment.center,
        //         child: const CircularProgressIndicator(color: Colors.green),
        //       );
        //     }
        //
        //     final data = snapshot.data;
        //     String phonetic = "/.../";
        //     String definition = "No definition found for this word.";
        //
        //     if (data != null && data.isNotEmpty) {
        //       phonetic = data['phonetic'] ?? (data['phonetics'] != null && data['phonetics'].isNotEmpty ? data['phonetics'][0]['text'] ?? '/.../' : '/.../');
        //
        //       if (data['meanings'] != null && data['meanings'].isNotEmpty) {
        //         final firstMeaning = data['meanings'][0];
        //         final partOfSpeech = firstMeaning['partOfSpeech'] ?? ''; // Danh từ, động từ...
        //
        //         if (firstMeaning['definitions'] != null && firstMeaning['definitions'].isNotEmpty) {
        //           final defText = firstMeaning['definitions'][0]['definition'] ?? '';
        //           definition = "($partOfSpeech) $defText";
        //         }
        //       }
        //     }
        //
        //     return Container(
        //       padding: const EdgeInsets.all(24),
        //       constraints: const BoxConstraints(maxHeight: 300),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             children: [
        //               Expanded(
        //                 child: Text(
        //                   word,
        //                   style: GoogleFonts.plusJakartaSans(
        //                     fontSize: 24,
        //                     fontWeight: FontWeight.bold,
        //                     color: Colors.black,
        //                   ),
        //                   overflow: TextOverflow.ellipsis,
        //                 ),
        //               ),
        //               ElevatedButton.icon(
        //                 style: ElevatedButton.styleFrom(
        //                   backgroundColor: Colors.green,
        //                   foregroundColor: Colors.white,
        //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        //                 ),
        //                 icon: const Icon(Icons.add_circle_outline, size: 18),
        //                 label: const Text("Save Word"),
        //                 onPressed: () {
        //                   Navigator.pop(context);
        //                   ScaffoldMessenger.of(context).showSnackBar(
        //                     SnackBar(content: Text('Saved "$word" to vocabulary notebook!')),
        //                   );
        //                 },
        //               )
        //             ],
        //           ),
        //           const SizedBox(height: 6),
        //           Text(
        //             phonetic,
        //             style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 15),
        //           ),
        //           const Divider(height: 24),
        //           Expanded(
        //             child: SingleChildScrollView(
        //               child: Text(
        //                 definition,
        //                 style: GoogleFonts.plusJakartaSans(
        //                   fontSize: 16,
        //                   color: Colors.black87,
        //                   height: 1.4,
        //                 ),
        //               ),
        //             ),
        //           )
        //         ],
        //       ),
        //     );
        //   },
        // );

        return FutureBuilder<List<dynamic>>(
          future: fetchWordDefinition(word),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator(color: Colors.green)),
              );
            }

            final List<dynamic>? apiList = snapshot.data;

            if (apiList == null || apiList.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                child: const Text("No definitions found."),
              );
            }

            String phonetic = apiList[0]['phonetic'] ?? '/.../';

            String audioUrl = "";
            for (var entry in apiList) {
              final List<dynamic> phonetics = entry['phonetics'] ?? [];
              for (var p in phonetics) {
                if (p['audio'] != null && p['audio'].toString().isNotEmpty) {
                  audioUrl = p['audio'].toString();
                  break;
                }
              }
              if (audioUrl.isNotEmpty) break;
            }

            return Container(
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        word,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),

                      if (audioUrl.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.blue),
                          onPressed: () => _playPronunciation(audioUrl),
                        ),
                      const Spacer(),

                      ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text("Save Word"),
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please login to save words!'), backgroundColor: Colors.red),
                            );
                            return;
                          }
                          try {
                            final String allDefinitions = _extractAllDefinitions(apiList);
                            await FirebaseFirestore.instance.collection('saved_vocabulary').add({
                              'userId': user.uid,
                              'word': word,
                              'pronunciation': phonetic,
                              'definition': allDefinitions.isNotEmpty ? allDefinitions : 'No definition found.',
                              'audioUrl': audioUrl,
                              'savedAt': FieldValue.serverTimestamp(),
                            });
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Saved "$word" to vocabulary notebook!'),
                                  backgroundColor: const Color(0xFFD49A15),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phonetic,
                    style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 15),
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _buildAllEntries(apiList),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAllEntries(List<dynamic> entries) {
    List<Widget> children = [];

    for (var entry in entries) {
      final List<dynamic> meanings = entry['meanings'] ?? [];

      for (var meaning in meanings) {
        final String partOfSpeech = meaning['partOfSpeech'] ?? '';
        final List<dynamic> definitions = meaning['definitions'] ?? [];

        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              partOfSpeech.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        );

        for (int i = 0; i < definitions.length; i++) {
          String defText = definitions[i]['definition'] ?? '';
          children.add(
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
              child: Text("- ${i + 1}: $defText"),
            ),
          );
        }

        children.add(const Divider());
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}