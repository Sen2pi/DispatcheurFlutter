import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import '../common/glass_container.dart';
import '../common/custom_icon.dart';

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
  String _searchQuery = '';

  // Mock contacts similar to ContactsOverlay
  final List<Map<String, dynamic>> _contacts = [
    {
      'id': '1',
      'name': 'João Silva',
      'avatar': 'JS',
      'mobile': '+351912345678',
      'landline': '+351212345678',
      'email': 'joao@example.com',
      'personal': false,
    },
    {
      'id': '2',
      'name': 'Maria Santos',
      'avatar': 'MS',
      'mobile': '+351987654321',
      'landline': null,
      'email': 'maria@example.com',
      'personal': true,
    },
    {
      'id': '3',
      'name': 'Pedro Costa',
      'avatar': 'PC',
      'mobile': '+351555123456',
      'landline': '+351555123457',
      'email': 'pedro@example.com',
      'personal': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
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

  List<Map<String, dynamic>> get _filteredContacts {
    if (_searchQuery.isEmpty) return _contacts;

    return _contacts.where((contact) {
      final name = contact['name'].toString().toLowerCase();
      final mobile = contact['mobile']?.toString() ?? '';
      final landline = contact['landline']?.toString() ?? '';
      final query = _searchQuery.toLowerCase();

      return name.contains(query) ||
          mobile.contains(query) ||
          landline.contains(query);
    }).toList();
  }

  void _transferToNumber() {
    final number = _numberController.text.trim();
    if (number.isNotEmpty && widget.callId != null) {
      widget.onTransfer(widget.callId!, number);
    }
  }

  void _transferToContact(Map<String, dynamic> contact) {
    final number = contact['mobile'] ?? contact['landline'];
    if (number != null && widget.callId != null) {
      widget.onTransfer(widget.callId!, number);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen || widget.callId == null) return const SizedBox();

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
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0x2659B2F6), // rgba(59, 130, 246, 0.15)
                          Color(0x1A93C5FD), // rgba(147, 197, 253, 0.1)
                          Color(0x0DDBEAFE), // rgba(219, 234, 254, 0.05)
                        ],
                      ),
                      border: Border.all(
                        color:
                            const Color(0x663B82F6), // rgba(59, 130, 246, 0.4)
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                              0x4D3B82F6), // rgba(59, 130, 246, 0.3)
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
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
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1e3a8a), Color(0xFF3b82f6)],
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
            'Transfert d\'Appel',
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
          bottom: BorderSide(color: Color(0x1A3B82F6)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transférer vers un Numéro',
            style: TextStyle(
              fontSize: widget.isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1e3a8a),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _numberController,
                  decoration: InputDecoration(
                    hintText: 'Numéro de destination',
                    prefixIcon:
                        const Icon(Icons.phone, color: Color(0xFF3b82f6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0x663B82F6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF3b82f6)),
                    ),
                    filled: true,
                    fillColor:
                        const Color(0x333B82F6), // rgba(59, 130, 246, 0.2)
                  ),
                  keyboardType: TextInputType.phone,
                  onSubmitted: (_) => _transferToNumber(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _transferToNumber,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3b82f6),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Transférer'),
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
          bottom: BorderSide(color: Color(0x1A3B82F6)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transférer vers un Contact',
            style: TextStyle(
              fontSize: widget.isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1e3a8a),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher des contacts...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF3b82f6)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0x663B82F6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF3b82f6)),
              ),
              filled: true,
              fillColor: const Color(0x263B82F6), // rgba(59, 130, 246, 0.15)
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    final filteredContacts = _filteredContacts;

    if (filteredContacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: widget.isMobile ? 48 : 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Aucun contact trouvé'
                  : 'Aucun contact disponible',
              style: TextStyle(
                fontSize: widget.isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1e3a8a),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
      itemCount: filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = filteredContacts[index];
        return _buildContactItem(contact);
      },
    );
  }

  Widget _buildContactItem(Map<String, dynamic> contact) {
    final hasNumber = contact['mobile'] != null || contact['landline'] != null;
    final primaryNumber = contact['mobile'] ?? contact['landline'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: hasNumber
          ? const Color(0x1A3B82F6) // rgba(59, 130, 246, 0.1)
          : const Color(0x1A64748B), // rgba(100, 116, 139, 0.1)
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              hasNumber ? const Color(0xFF3b82f6) : const Color(0xFF64748b),
          child: Text(
            contact['avatar'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                contact['name'],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: hasNumber
                      ? const Color(0xFF1e3a8a)
                      : const Color(0xFF6b7280),
                  fontSize: widget.isMobile ? 14 : 16,
                ),
              ),
            ),
            if (contact['personal'] == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFf59e0b),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Personnel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isMobile ? 8 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          primaryNumber ?? 'Aucun numéro',
          style: TextStyle(
            fontSize: widget.isMobile ? 12 : 14,
            color:
                hasNumber ? const Color(0xFF64748b) : const Color(0xFF9ca3af),
          ),
        ),
        trailing: hasNumber
            ? IconButton(
                icon: const Icon(
                  Icons.swap_calls,
                  color: Color(0xFF22c55e),
                ),
                onPressed: () => _transferToContact(contact),
                tooltip: 'Transférer vers ${contact['name']}',
              )
            : Icon(
                Icons.phone_disabled,
                color: Colors.grey.withOpacity(0.5),
              ),
        onTap: hasNumber ? () => _transferToContact(contact) : null,
      ),
    );
  }
}
