import 'package:flutter_bloc/flutter_bloc.dart';
import 'note_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesInitial());

  void addNote(String note, String text) {
    if (state is NotesLoaded) {
      final currentNotes = List<String>.from((state as NotesLoaded).notes);
      currentNotes.add(note);
      emit(NotesLoaded(currentNotes));
    } else {
      emit(NotesLoaded([note]));
    }
  }

  void deleteNote(int index) {
    if (state is NotesLoaded) {
      final currentNotes = List<String>.from((state as NotesLoaded).notes);
      if (index >= 0 && index < currentNotes.length) {
        currentNotes.removeAt(index);
        emit(NotesLoaded(currentNotes));
      }
    }
  }

  void updateNote(int index, String newNote, String text) {
    if (state is NotesLoaded) {
      final currentNotes = List<String>.from((state as NotesLoaded).notes);
      if (index >= 0 && index < currentNotes.length) {
        currentNotes[index] = newNote;
        emit(NotesLoaded(currentNotes));
      }
    }
  }
}
