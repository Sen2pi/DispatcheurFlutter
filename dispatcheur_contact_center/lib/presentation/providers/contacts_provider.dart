import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/contact_model.dart';
import '../../services/api_service.dart';

part 'contacts_provider.freezed.dart';

@freezed
class ContactsState with _$ContactsState {
  const factory ContactsState({
    @Default([]) List<ContactModel> contacts,
    @Default(false) bool isLoading,
    String? error,
  }) = _ContactsState;
}

class ContactsNotifier extends StateNotifier<ContactsState> {
  ContactsNotifier(this._apiService) : super(const ContactsState()) {
    fetchContacts();
  }

  final ApiService _apiService;

  Future<void> fetchContacts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final contactsData = await _apiService.getContacts();
      final contacts =
          contactsData.map((data) => ContactModel.fromJson(data)).toList();

      state = state.copyWith(
        contacts: contacts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> addContact(ContactModel contact) async {
    try {
      // TODO: Implementar API para adicionar contacto
      final updatedContacts = [...state.contacts, contact];
      state = state.copyWith(contacts: updatedContacts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateContact(ContactModel contact) async {
    try {
      // TODO: Implementar API para atualizar contacto
      final updatedContacts =
          state.contacts.map((c) => c.id == contact.id ? contact : c).toList();
      state = state.copyWith(contacts: updatedContacts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      // TODO: Implementar API para remover contacto
      final updatedContacts =
          state.contacts.where((c) => c.id != contactId).toList();
      state = state.copyWith(contacts: updatedContacts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final contactsProvider =
    StateNotifierProvider<ContactsNotifier, ContactsState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ContactsNotifier(apiService);
});
