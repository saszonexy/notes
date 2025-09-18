import 'package:flutter_bloc/flutter_bloc.dart';
import 'note_state.dart';
import '../models/note.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesInitial());

  void addNote(String title, String content) {
    if (state is NotesLoaded) {
      final currentNotes = List<Note>.from((state as NotesLoaded).notes);
      currentNotes.add(Note(title: title, content: content));
      emit(NotesLoaded(currentNotes));
    } else {
      emit(NotesLoaded([Note(title: title, content: content)]));
    }
  }

  void deleteNote(int index) {
    if (state is NotesLoaded) {
      final currentNotes = List<Note>.from((state as NotesLoaded).notes);
      if (index >= 0 && index < currentNotes.length) {
        currentNotes.removeAt(index);
        emit(NotesLoaded(currentNotes));
      }
    }
  }

  void updateNote(int index, String title, String content) {
    if (state is NotesLoaded) {
      final currentNotes = List<Note>.from((state as NotesLoaded).notes);
      if (index >= 0 && index < currentNotes.length) {
        currentNotes[index] = Note(title: title, content: content);
        emit(NotesLoaded(currentNotes));
      }
    }
  }
}
