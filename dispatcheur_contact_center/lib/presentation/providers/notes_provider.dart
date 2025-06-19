import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../data/models/note_model.dart';

part 'notes_provider.freezed.dart';

@freezed
class NotesState with _$NotesState {
  const factory NotesState({
    @Default([]) List<NoteModel> notes,
    @Default(false) bool isLoading,
    String? error,
  }) = _NotesState;
}

class NotesNotifier extends StateNotifier<NotesState> {
  NotesNotifier() : super(const NotesState()) {
    loadNotes();
  }

  static const String _storageKey = 'voip_quick_notes';

  Future<void> loadNotes() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getStringList(_storageKey) ?? [];

      final notes = notesJson
          .map((json) => NoteModel.fromJson(jsonDecode(json)))
          .toList();

      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = state.copyWith(
        notes: notes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> addNote(NoteModel note) async {
    try {
      final updatedNotes = [note, ...state.notes];
      await _saveNotes(updatedNotes);

      state = state.copyWith(notes: updatedNotes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateNote(NoteModel note) async {
    try {
      final updatedNotes =
          state.notes.map((n) => n.id == note.id ? note : n).toList();

      await _saveNotes(updatedNotes);

      state = state.copyWith(notes: updatedNotes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      final updatedNotes = state.notes.where((n) => n.id != noteId).toList();

      await _saveNotes(updatedNotes);

      state = state.copyWith(notes: updatedNotes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _saveNotes(List<NoteModel> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = notes.map((note) => jsonEncode(note.toJson())).toList();

    await prefs.setStringList(_storageKey, notesJson);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  return NotesNotifier();
});
