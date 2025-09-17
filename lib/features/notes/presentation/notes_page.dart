import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/notes_cubit.dart'; 
import '../logic/note_state.dart'; 

class NotePage extends StatelessWidget {
  const NotePage({super.key});

  @override
  Widget build(BuildContext context) {
    final noteCtrl = TextEditingController();

    return BlocProvider(
      create: (_) => NotesCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Notes"),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                // TODO: pindah ke profile page
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: noteCtrl,
                      decoration: const InputDecoration(
                        hintText: "Tulis catatan...",
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (noteCtrl.text.isNotEmpty) {
                        context.read<NotesCubit>().addNote(noteCtrl.text);
                        noteCtrl.clear();
                      }
                    },
                    child: const Text("Simpan"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<NotesCubit, NotesState>(
                builder: (context, state) {
                  if (state is NotesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is NotesLoaded) {
                    if (state.notes.isEmpty) {
                      return const Center(child: Text("Belum ada catatan"));
                    }
                    return ListView.builder(
                      itemCount: state.notes.length,
                      itemBuilder: (context, i) {
                        return ListTile(
                          title: Text(state.notes[i]),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("Belum ada catatan"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
