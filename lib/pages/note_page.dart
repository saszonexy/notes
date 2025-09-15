import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_note_page.dart';
import 'detail_note.dart';
import 'login_page.dart'; 

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<Map<String, dynamic>> notes = [];
  bool isLoading = false;
  String userEmail = "Guest";

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNote();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final token = await ApiService.getToken();
    setState(() {
      userEmail = token != null ? "User Aktif" : "Guest";
    });
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

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah kamu yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD2691E),
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
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

  Future<void> _deleteNoteWithConfirm(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah kamu yakin ingin menghapus catatan ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD2691E),
            ),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deleteNote(id);
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
        backgroundColor: const Color(0xFFD2691E),
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.menu_book, color: Color(0xFF8B4513)),
            SizedBox(width: 8),
            Text("My Diary", style: TextStyle(color: Color(0xFF8B4513))),
          ],
        ),
        backgroundColor: const Color(0xFFF5F1E8),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Color(0xFF8B4513)),
            onPressed: () {
              Navigator.pushNamed(context, "/profile", arguments: {
                "email": userEmail,
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF8B4513)),
            onPressed: _fetchNote,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF8B4513)),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B4513)))
          : notes.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada catatan",
                    style: TextStyle(color: Color(0xFF8B4513)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: const Color(0xFFFFFDF7),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                            color: Color(0xFFE8D5B7), width: 1),
                      ),
                      child: ListTile(
                        title: Text(
                          note["title"] ?? "Tanpa Judul",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                        subtitle: Text(
                          note["content"] ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xFF8B4513)),
                        ),
                        onTap: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteDetailPage(note: note),
                            ),
                          );

                          if (updated == true) {
                            _fetchNote();
                          }
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Color(0xFFD2691E)),
                          onPressed: () => _deleteNoteWithConfirm(note["id"]),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddNotePage()),
          );
          if (result == true) {
            _fetchNote();
          }
        },
        backgroundColor: const Color(0xFF8B4513),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}
