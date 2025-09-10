import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tailwind_colors/tailwind_colors.dart';
import '../services/api_service.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<Map<String, dynamic>> notes = [];
  bool isLoading = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNote();
  }

  Future<void> _fetchNote() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.getNotes();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          if (data is List) {
            notes = List<Map<String, dynamic>>.from(data);
          } else if (data is Map && data["notes"] is List) {
            notes = List<Map<String, dynamic>>.from(data["notes"]);
          } else {
            notes = [];
          }
        });
      } else {
        _showError("Gagal memuat catatan (${response.statusCode})");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createNote() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      _showError("Judul dan isi tidak boleh kosong");
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await ApiService.createNote(
        titleController.text.trim(),
        contentController.text.trim(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        titleController.clear();
        contentController.clear();
        Navigator.pop(context);
        _fetchNote();
      } else {
        _showError("Gagal menambah catatan");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateNote(int id) async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      _showError("Judul dan isi tidak boleh kosong");
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await ApiService.updateNote(
        id,
        titleController.text.trim(),
        contentController.text.trim(),
      );
      if (response.statusCode == 200) {
        titleController.clear();
        contentController.clear();
        Navigator.pop(context);
        _fetchNote();
      } else {
        _showError("Gagal mengupdate catatan");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteNote(int id) async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.deleteNote(id);
      if (response.statusCode == 200) {
        _fetchNote();
      } else {
        _showError("Gagal menghapus catatan");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: TWColors.red.shade600,
        content: Text(msg),
      ),
    );
  }

  void _openNoteDialog({Map<String, dynamic>? note}) {
    if (note != null) {
      // Edit mode
      titleController.text = note["title"] ?? "";
      contentController.text = note["content"] ?? "";
    } else {
      // New note
      titleController.clear();
      contentController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Content",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (note == null) {
                    _createNote();
                  } else {
                    _updateNote(note["id"]);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TWColors.blue.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  note == null ? "Save Note" : "Update Note",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TWColors.gray.shade50,
      appBar: AppBar(
        title: const Text("Notes"),
        backgroundColor: TWColors.blue.shade500,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNote,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? const Center(child: Text("Belum ada catatan"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          note["title"] ?? "Tanpa Judul",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(note["content"] ?? ""),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.edit, color: Colors.indigoAccent),
                              onPressed: () => _openNoteDialog(note: note),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteNote(note["id"]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteDialog(),
        backgroundColor: TWColors.blue.shade600,
        child: const Icon(Icons.add),
      ),
    );
  }
}
