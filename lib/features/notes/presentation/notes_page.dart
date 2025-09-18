import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button.dart';
import '../logic/notes_cubit.dart';
import '../logic/note_state.dart';
import 'add_note.dart';
import '../../auth/presentation/profile_page.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.book, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              "My Notebook",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xff8b4513),
        elevation: 3,
        shadowColor: Colors.brown.withOpacity(0.5),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfilePage()),
                );
              },
            ),
          )
        ],
      ),
      backgroundColor: const Color(0xfff5f1eb),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<NotesCubit, NotesState>(
              builder: (context, state) {
                if (state is NotesInitial ||
                    (state is NotesLoaded && state.notes.isEmpty)) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 80,
                          color: const Color(0xff8b4513).withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada catatan",
                          style: TextStyle(
                            fontSize: 18,
                            color: const Color(0xff8b4513).withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Mulai tulis catatan pertamamu!",
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xff8b4513).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is NotesLoaded) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      itemCount: state.notes.length,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff8b4513).withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xff8b4513).withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 4,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xff8b4513),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          title: Text(
                            state.notes[index],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xff2d1810),
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xff8b4513).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Color(0xff8b4513), size: 20),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddNotePage(
                                          isEdit: true,
                                          index: index,
                                          initialText: state.notes[index],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red, size: 20),
                                  onPressed: () {
                                    _showDeleteDialog(context, index);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff8b4513).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: CustomButton(
              text: "✍️ Tambah Catatan",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddNotePage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text(
              "Hapus Catatan",
              style: TextStyle(
                color: Color(0xff2d1810),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          "Apakah kamu yakin ingin menghapus catatan ini?",
          style: TextStyle(
            color: const Color(0xff2d1810).withOpacity(0.8),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xff8b4513),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              context.read<NotesCubit>().deleteNote(index);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Hapus",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
