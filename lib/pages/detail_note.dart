import 'package:flutter/material.dart';
import 'package:tailwind_colors/tailwind_colors.dart';
import '../services/api_service.dart';

class NoteDetailPage extends StatefulWidget {
  final Map<String, dynamic> note;
  const NoteDetailPage({super.key, required this.note});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note["title"]);
    _contentController = TextEditingController(text: widget.note["content"]);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _updateNote() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: TWColors.red.shade600,
          content: const Text("Judul dan isi catatan tidak boleh kosong"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService.updateNote(
        widget.note["id"],
        _titleController.text.trim(),
        _contentController.text.trim(),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // sukses → balik dengan flag true
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: TWColors.red.shade600,
            content: Text("Gagal update: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: TWColors.red.shade600,
          content: Text("Error: $e"),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      appBar: AppBar(
        title: const Text(
          "Detail Diary",
          style:
              TextStyle(color: Color(0xFF8B4513), fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFF5F1E8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF8B4513)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xFF8B4513)),
            onPressed: _updateNote,
          ),
        ],
        bottom: isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(
                  backgroundColor: Color(0xFFF5F1E8),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
                ),
              )
            : null,
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "Judul diary",
                hintStyle: TextStyle(color: Color(0xFFB8860B)),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: "Tulis isi diary...",
                  hintStyle: TextStyle(color: Color(0xFFB8860B)),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF8B4513),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
