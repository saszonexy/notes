import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'note_state.dart';
import '../models/note.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesInitial());

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> loadNotes() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .get();

    final notes = snapshot.docs
        .map((doc) => Note(
              id: doc.id,
              title: doc['title'],
              content: doc['content'],
            ))
        .toList();

    emit(NotesLoaded(notes));
  }

  Future<void> addNote(String title, String content) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).collection('notes').add({
      'title': title,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });

    loadNotes(); 
  }

  Future<void> deleteNote(String noteId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(noteId)
        .delete();

    loadNotes();
  }

  Future<void> updateNote(String noteId, String title, String content) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(noteId)
        .update({
      'title': title,
      'content': content,
    });

    loadNotes();
  }
}
