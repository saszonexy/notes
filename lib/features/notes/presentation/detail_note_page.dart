import 'package:flutter/material.dart';
import '../models/note.dart'; 

class NoteDetailPage extends StatelessWidget {
  final Note note;
  final int index;

  const NoteDetailPage({
    super.key,
    required this.note,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Catatan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xff8b4513),
        elevation: 2,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff8b4513), Color(0xff6b3410)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xfff5f1eb),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff8b4513).withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xff8b4513).withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: const Color(0xff8b4513).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 2,
                width: 60,
                decoration: BoxDecoration(
                  color: const Color(0xff8b4513).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2d1810),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                note.content, 
                style: const TextStyle(
                  fontSize: 17,
                  color: Color(0xff2d1810),
                  height: 1.7,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 1,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xff8b4513).withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
