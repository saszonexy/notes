import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/notes_cubit.dart';
import '../logic/note_state.dart';
import '../models/note.dart'; 
import '../../../core/widgets/custom_button.dart';

class AddNotePage extends StatelessWidget {
  final bool isEdit;
  final int? index;
  final Note? initialNote;

  AddNotePage({
    super.key,
    this.isEdit = false,
    this.index,
    this.initialNote,
  });

  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (isEdit && initialNote != null) {
      titleController.text = initialNote!.title;
      noteController.text = initialNote!.content;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              isEdit ? Icons.edit_note : Icons.note_add,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              isEdit ? "Edit Catatan" : "Tambah Catatan",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xff8b4513),
        elevation: 3,
        shadowColor: Colors.brown.withOpacity(0.5),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      backgroundColor: const Color(0xfff5f1eb),
      body: BlocConsumer<NotesCubit, NotesState>(
        listener: (context, state) {
          if (state is NotesLoaded) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xff8b4513),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isEdit ? "Edit catatan kamu" : "Tulis catatan baru",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff2d1810),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Judul Catatan",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff2d1810),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xfff9f7f4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xff8b4513).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: "Masukkan judul catatan...",
                            hintStyle: TextStyle(
                              color: const Color(0xff8b4513).withOpacity(0.5),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xff2d1810),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Isi Catatan",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff2d1810),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xfff9f7f4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xff8b4513).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: noteController,
                          decoration: InputDecoration(
                            hintText: "Mulai menulis catatan...",
                            hintStyle: TextStyle(
                              color: const Color(0xff8b4513).withOpacity(0.5),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xff2d1810),
                            height: 1.5,
                          ),
                          maxLines: 10,
                          minLines: 6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: isEdit
                              ? "💾 Update Catatan"
                              : "💾 Simpan Catatan",
                          onPressed: () {
                            if (titleController.text.isNotEmpty ||
                                noteController.text.isNotEmpty) {
                              final cubit = context.read<NotesCubit>();
                              if (isEdit && index != null) {
                                cubit.updateNote(
                                  index!,
                                  titleController.text,
                                  noteController.text,
                                );
                              } else {
                                cubit.addNote(
                                  titleController.text,
                                  noteController.text,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xff8b4513).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xff8b4513).withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xff8b4513),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Tips: Tulis catatan dengan jelas agar mudah dibaca kembali",
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xff8b4513).withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
