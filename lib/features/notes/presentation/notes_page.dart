import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk kDebugMode
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/features/notes/logic/note_state.dart';
import 'package:notes/features/notes/logic/notes_cubit.dart';
import 'package:notes/features/notes/presentation/detail_note_page.dart';
import 'package:notes/notifications/presentation/notifications_page.dart';
import 'add_note.dart';
import '../../auth/presentation/profile_page.dart';
import '../../debug/presentation/fcm_test_page.dart'; // Developer FCM test
import '../../../core/widgets/custom_button.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_stories, color: Colors.white, size: 26),
            SizedBox(width: 10),
            Text(
              "My Notebook",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xff8b4513),
        elevation: 4,
        shadowColor: const Color.fromARGB(255, 139, 69, 43).withOpacity(0.6),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff8b4513),
                Color(0xff8b4513),
              ],
            ),
          ),
        ),
        actions: [
          if (kDebugMode)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.25),
                borderRadius: BorderRadius.circular(25),
                border:
                    Border.all(color: Colors.orange.withOpacity(0.4), width: 1),
              ),
              child: IconButton(
                icon:
                    const Icon(Icons.bug_report, color: Colors.white, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FCMTestPage()),
                  );
                },
                tooltip: 'FCM Test (Developer)',
              ),
            ),

          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(25),
              border:
                  Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications,
                      color: Colors.white, size: 22),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationsPage()),
                    );
                  },
                  tooltip: 'Notifikasi',
                ),
              ],
            ),
          ),

          // Icon Profile
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(25),
              border:
                  Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 22),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfilePage()),
                );
              },
              tooltip: 'Profile',
            ),
          )
        ],
      ),
      backgroundColor: const Color(0xfff8f5f0),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xfff8f5f0),
              const Color(0xfff5f1eb).withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff8d6e63),
                    Color(0xffa1887f),
                    Color(0xff8d6e63),
                  ],
                ),
              ),
            ),

            if (kDebugMode)
              Container(
                width: double.infinity,
                color: Colors.orange[100]?.withOpacity(0.7),
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.developer_mode,
                        color: Colors.orange, size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      'Debug Mode - Developer Tools Active',
                      style: TextStyle(fontSize: 11, color: Colors.brown),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FCMTestPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'FCM Test',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: BlocBuilder<NotesCubit, NotesState>(
                builder: (context, state) {
                  if (state is NotesInitial ||
                      (state is NotesLoaded && state.notes.isEmpty)) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xff8d6e63).withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.menu_book_outlined,
                                  size: 90,
                                  color:
                                      const Color(0xff8b4513).withOpacity(0.4),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Belum ada catatan",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xff6d4c41),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Mulai tulis catatan pertamamu!",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: const Color(0xff8d6e63)
                                        .withOpacity(0.7),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is NotesLoaded) {
                    return Padding(
                      padding: const EdgeInsets.all(18),
                      child: ListView.builder(
                        itemCount: state.notes.length,
                        itemBuilder: (context, index) {
                          final note = state.notes[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xff8d6e63).withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color:
                                      const Color(0xff8d6e63).withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                              border: Border.all(
                                color:
                                    const Color(0xff8d6e63).withOpacity(0.08),
                                width: 1.5,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    const Color(0xfff8f5f0).withOpacity(0.3),
                                  ],
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(20),
                                leading: Container(
                                  width: 5,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xff8d6e63),
                                        Color(0xff6d4c41),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                title: Text(
                                  note.title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Color(0xff3e2723),
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NoteDetailPage(
                                          note: note, index: index),
                                    ),
                                  );
                                },
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xff8d6e63)
                                            .withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xff8d6e63)
                                              .withOpacity(0.2),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.edit_outlined,
                                            color: Color(0xff6d4c41), size: 22),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AddNotePage(
                                                isEdit: true,
                                                index: index,
                                                initialNote: note,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.2),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red, size: 22),
                                        onPressed: () {
                                          _showDeleteDialog(context, index);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff8d6e63).withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    const Color(0xfff8f5f0).withOpacity(0.3),
                  ],
                ),
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
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        shadowColor: const Color(0xff8d6e63).withOpacity(0.3),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 26),
            SizedBox(width: 10),
            Text(
              "Hapus Catatan",
              style: TextStyle(
                color: Color(0xff3e2723),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          "Apakah kamu yakin ingin menghapus catatan ini?",
          style: TextStyle(
            color: const Color(0xff3e2723).withOpacity(0.8),
            height: 1.5,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xff8d6e63),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Batal",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<NotesCubit>().deleteNote(index as String);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withOpacity(0.15),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Hapus",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
