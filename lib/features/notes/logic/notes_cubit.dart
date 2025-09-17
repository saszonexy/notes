import 'package:flutter_bloc/flutter_bloc.dart';
import 'note_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesInitial());

  void addNote(String note) {
    if (state is NotesLoaded) {
      final currentNotes = List<String>.from((state as NotesLoaded).notes);
      currentNotes.add(note);
      emit(NotesLoaded(currentNotes));
    } else {
      emit(NotesLoaded([note]));
    }
  }
}
