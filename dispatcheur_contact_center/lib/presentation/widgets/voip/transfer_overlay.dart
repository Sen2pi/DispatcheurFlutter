import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/contact_model.dart';
import '../../providers/contacts_provider.dart';
import '../common/glass_container.dart';

class TransferOverlay extends ConsumerStatefulWidget {
  const TransferOverlay({
    super.key,
    required this.isOpen,
    required this.callId,
    required this.onClose,
    required this.onTransfer,
    required this.isMobile,
  });

  final bool isOpen;
  final String? callId;
  final VoidCallback onClose;
  final Function(String, String) onTransfer;
  final bool isMobile;

  @override
  ConsumerState<TransferOverlay> createState() => _TransferOverlayState();
}

class _TransferOverlayState extends ConsumerState<TransferOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<ContactModel> _filteredContacts = [];

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
  void didUpdateWidget(TransferOverlay oldWidget) {
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
    _numberController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen || widget.callId == null) return const SizedBox();

    final contactsState = ref.watch(contactsProvider);

    // Filtrar contactos baseado na pesquisa
    _filteredContacts = _filterContacts(contactsState.contacts);

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
                onTap: () {},
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
                        _buildManualTransferSection(),
                        _buildSearchSection(),
                        Expanded(child: _buildContactsList()),
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
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
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
          const Icon(Icons.swap_calls, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'Transferir Chamada',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isMobile ? 16 : 18,
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

  Widget _buildManualTransferSection() {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transferir para Número',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _numberController,
                  decoration: const InputDecoration(
                    hintText: 'Número de destino',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  onSubmitted: (_) => _transferToNumber(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _transferToNumber,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                ),
                child: const Text('Transferir'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transferir para Contacto',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Pesquisar contactos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    if (_filteredContacts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum contacto encontrado',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        return _buildContactItem(contact);
      },
    );
  }

  Widget _buildContactItem(ContactModel contact) {
    final hasPhoneNumber = contact.hasPhoneNumber;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              hasPhoneNumber ? const Color(0xFF3B82F6) : Colors.grey,
          child: Text(
            contact.initials,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          contact.displayName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: hasPhoneNumber ? const Color(0xFF1E3A8A) : Colors.grey,
          ),
        ),
        subtitle: Text(
          contact.primaryPhone.isNotEmpty ? contact.primaryPhone : 'Sem número',
          style: TextStyle(
            color: hasPhoneNumber ? Colors.grey : Colors.red,
          ),
        ),
        trailing: hasPhoneNumber
            ? IconButton(
                icon: const Icon(Icons.swap_calls, color: Color(0xFF3B82F6)),
                onPressed: () => _transferToContact(contact),
              )
            : const Icon(Icons.phone_disabled, color: Colors.grey),
        onTap: hasPhoneNumber ? () => _transferToContact(contact) : null,
      ),
    );
  }

  List<ContactModel> _filterContacts(List<ContactModel> contacts) {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      return contacts;
    }

    return contacts.where((contact) {
      return contact.name.toLowerCase().contains(query) ||
          (contact.mobile?.contains(query) ?? false) ||
          (contact.landline?.contains(query) ?? false);
    }).toList();
  }

  void _transferToNumber() {
    final number = _numberController.text.trim();
    if (number.isNotEmpty && widget.callId != null) {
      widget.onTransfer(widget.callId!, number);
      widget.onClose();
    }
  }

  void _transferToContact(ContactModel contact) {
    if (contact.hasPhoneNumber && widget.callId != null) {
      widget.onTransfer(widget.callId!, contact.primaryPhone);
      widget.onClose();
    }
  }
}
