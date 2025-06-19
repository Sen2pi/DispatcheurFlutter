import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/contact_model.dart';
import '../../providers/contacts_provider.dart';
import '../common/glass_container.dart';

class ContactsOverlay extends ConsumerStatefulWidget {
  const ContactsOverlay({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.isMobile,
    required this.onCallContact,
  });

  final bool isOpen;
  final VoidCallback onClose;
  final bool isMobile;
  final Function(String) onCallContact;

  @override
  ConsumerState<ContactsOverlay> createState() => _ContactsOverlayState();
}

class _ContactsOverlayState extends ConsumerState<ContactsOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isOpen) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ContactsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _animationController.forward();
    } else if (!widget.isOpen && oldWidget.isOpen) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox();

    final contactsState = ref.watch(contactsProvider);
    final filteredContacts = _filterContacts(contactsState.contacts);

    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {}, // Prevent closing when tapping inside
                child: Container(
                  width: widget.isMobile
                      ? MediaQuery.of(context).size.width * 0.9
                      : 400,
                  height: double.infinity,
                  margin: EdgeInsets.only(
                    top: widget.isMobile ? 50 : 80,
                    bottom: widget.isMobile ? 50 : 80,
                    right: widget.isMobile ? 20 : 80,
                  ),
                  child: GlassContainer(
                    borderRadius: 16,
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildSearchBar(),
                        Expanded(child: _buildContactsList(filteredContacts)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.contacts, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'Contactos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Pesquisar contactos...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildContactsList(List<ContactModel> contacts) {
    if (contacts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum contacto encontrado',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return _buildContactItem(contact);
      },
    );
  }

  Widget _buildContactItem(ContactModel contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF3B82F6),
          child: Text(
            contact.initials,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(contact.displayName),
        subtitle: Text(contact.primaryPhone),
        trailing: contact.hasPhoneNumber
            ? IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: () => widget.onCallContact(contact.primaryPhone),
              )
            : const Icon(Icons.call_end, color: Colors.grey),
        onTap: contact.hasPhoneNumber
            ? () => widget.onCallContact(contact.primaryPhone)
            : null,
      ),
    );
  }

  List<ContactModel> _filterContacts(List<ContactModel> contacts) {
    if (_searchQuery.isEmpty) return contacts;

    return contacts.where((contact) {
      return contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (contact.mobile?.contains(_searchQuery) ?? false) ||
          (contact.landline?.contains(_searchQuery) ?? false);
    }).toList();
  }
}
