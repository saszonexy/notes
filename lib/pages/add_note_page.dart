import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  bool isLoading = false;

  Future<void> _createNote() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Judul dan isi tidak boleh kosong"),
          backgroundColor: const Color(0xFF8B4513),
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await ApiService.createNote(
        titleController.text.trim(),
        contentController.text.trim(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true); // kirim sinyal sukses
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menambah catatan")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0), // cream background
      appBar: AppBar(
        title:
            const Text("Tambah Diary", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8B4513), // brown color
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: titleController,
                style: const TextStyle(color: Color(0xFF8B4513)),
                decoration: const InputDecoration(
                  labelText: "Judul",
                  labelStyle: TextStyle(color: Color(0xFF8B4513)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF8B4513)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF8B4513)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: contentController,
                maxLines: 5,
                style: const TextStyle(color: Color(0xFF8B4513)),
                decoration: const InputDecoration(
                  labelText: "Isi Diary",
                  labelStyle: TextStyle(color: Color(0xFF8B4513)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF8B4513)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF8B4513)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _createNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513), // brown color
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan Diary",
                        style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
