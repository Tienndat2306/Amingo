import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import '../../../core/constants/app_colors.dart';

class AdminFormScreen extends StatelessWidget {
  final String title;
  final String type;
  final Map<String, dynamic>? initialData;

  const AdminFormScreen({
    super.key,
    required this.title,
    required this.type,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
      ),
      body: Center(
        child: Text(
          'Form for $type\nComing soon!',
          style: GoogleFonts.beVietnamPro(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}