import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import '../common/glass_container.dart';

class QuickNotesOverlay extends ConsumerStatefulWidget {
  const QuickNotesOverlay({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.isMobile,
  });

  final bool isOpen;
  final VoidCallback onClose;
  final bool isMobile;

  @override
  ConsumerState<QuickNotesOverlay> createState() => _QuickNotesOverlayState();
}

class _QuickNotesOverlayState extends ConsumerState<QuickNotesOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> _notes = [];
  final TextEditingController _newNoteController = TextEditingController();
  String? _editingNoteId;
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadNotes();
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

  void _loadNotes() {
    try {
      // TODO: Implementar com SharedPreferences
      const savedNotes = '[]'; // Mock
      final List<dynamic> notesList = json.decode(savedNotes);
      setState(() {
        _notes = notesList.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      setState(() {
        _notes = [];
      });
    }
  }

  void _saveNotes() {
    try {
      // TODO: Implementar com SharedPreferences
      final notesJson = json.encode(_notes);
      print('Saving notes: $notesJson'); // Mock
    } catch (e) {
      print('Error saving notes: $e');
    }
  }

  void _addNote() {
    final content = _newNoteController.text.trim();
    if (content.isEmpty) return;

    final note = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'text': content,
      'timestamp': DateTime.now().toString(),
    };

    setState(() {
      _notes.insert(0, note);
      _newNoteController.clear();
    });
    _saveNotes();
  }

  void _deleteNote(int id) {
    setState(() {
      _notes.removeWhere((note) => note['id'] == id);
    });
    _saveNotes();
  }

  void _startEdit(Map<String, dynamic> note) {
    setState(() {
      _editingNoteId = note['id'].toString();
      _editController.text = note['text'];
    });
  }

  void _saveEdit() {
    final content = _editController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      final index =
          _notes.indexWhere((note) => note['id'].toString() == _editingNoteId);
      if (index != -1) {
        _notes[index] = {
          ..._notes[index],
          'text': content,
          'timestamp': DateTime.now().toString(),
        };
      }
      _editingNoteId = null;
      _editController.clear();
    });
    _saveNotes();
  }

  void _cancelEdit() {
    setState(() {
      _editingNoteId = null;
      _editController.clear();
    });
  }

  @override
  void didUpdateWidget(QuickNotesOverlay oldWidget) {
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
    _newNoteController.dispose();
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox();

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
                        _buildAddNoteSection(),
                        Expanded(child: _buildNotesList()),
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
          colors: [Color(0xFF1e3a8a), Color(0xFF3b82f6)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.note, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'Notes Rapides',
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

  Widget _buildAddNoteSection() {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFe2e8f0)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newNoteController,
              decoration: const InputDecoration(
                hintText: 'Ajouter une note rapide...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onSubmitted: (_) => _addNote(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF3b82f6)),
            onPressed: _addNote,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    if (_notes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune note',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Text(
              'Ajoutez votre première note rapide',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        final isEditing = _editingNoteId == note['id'].toString();

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.note, color: Color(0xFF3b82f6), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatTimestamp(note['timestamp']),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    if (isEditing) ...[
                      IconButton(
                        icon: const Icon(Icons.save, color: Colors.green),
                        onPressed: _saveEdit,
                        iconSize: 20,
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: _cancelEdit,
                        iconSize: 20,
                      ),
                    ] else ...[
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF3b82f6)),
                        onPressed: () => _startEdit(note),
                        iconSize: 20,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteNote(note['id']),
                        iconSize: 20,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                if (isEditing)
                  TextField(
                    controller: _editController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  )
                else
                  Text(
                    note['text'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1e3a8a),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'À l\'instant';
      }
    } catch (e) {
      return 'Maintenant';
    }
  }
}
