import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/note_model.dart';
import '../../providers/notes_provider.dart';
import '../common/glass_container.dart';

class NotesOverlay extends ConsumerStatefulWidget {
  const NotesOverlay({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.isMobile,
  });

  final bool isOpen;
  final VoidCallback onClose;
  final bool isMobile;

  @override
  ConsumerState<NotesOverlay> createState() => _NotesOverlayState();
}

class _NotesOverlayState extends ConsumerState<NotesOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _newNoteController = TextEditingController();
  String? _editingNoteId;
  final TextEditingController _editController = TextEditingController();

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
  void didUpdateWidget(NotesOverlay oldWidget) {
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

    final notesState = ref.watch(notesProvider);
    final notesNotifier = ref.read(notesProvider.notifier);

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
                        _buildAddNoteSection(notesNotifier),
                        Expanded(
                            child: _buildNotesList(notesState, notesNotifier)),
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
          const Icon(Icons.note, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'Notas Rápidas',
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

  Widget _buildAddNoteSection(NotesNotifier notesNotifier) {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newNoteController,
              decoration: const InputDecoration(
                hintText: 'Adicionar nota rápida...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onSubmitted: (_) => _addNote(notesNotifier),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF3B82F6)),
            onPressed: () => _addNote(notesNotifier),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(NotesState state, NotesNotifier notesNotifier) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.notes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhuma nota',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Text(
              'Adicione sua primeira nota rápida',
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
      itemCount: state.notes.length,
      itemBuilder: (context, index) {
        final note = state.notes[index];
        return _buildNoteItem(note, notesNotifier);
      },
    );
  }

  Widget _buildNoteItem(NoteModel note, NotesNotifier notesNotifier) {
    final isEditing = _editingNoteId == note.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note, color: Color(0xFF3B82F6), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note.formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (isEditing) ...[
                  IconButton(
                    icon: const Icon(Icons.save, color: Colors.green),
                    onPressed: () => _saveEdit(note, notesNotifier),
                    iconSize: 20,
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: _cancelEdit,
                    iconSize: 20,
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                    onPressed: () => _startEdit(note),
                    iconSize: 20,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteNote(note.id, notesNotifier),
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
                note.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E3A8A),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _addNote(NotesNotifier notesNotifier) {
    final content = _newNoteController.text.trim();
    if (content.isNotEmpty) {
      final note = NoteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        createdAt: DateTime.now(),
        type: NoteType.general,
      );

      notesNotifier.addNote(note);
      _newNoteController.clear();
    }
  }

  void _startEdit(NoteModel note) {
    setState(() {
      _editingNoteId = note.id;
      _editController.text = note.content;
    });
  }

  void _saveEdit(NoteModel note, NotesNotifier notesNotifier) {
    final content = _editController.text.trim();
    if (content.isNotEmpty) {
      final updatedNote = note.copyWith(
        content: content,
        updatedAt: DateTime.now(),
      );

      notesNotifier.updateNote(updatedNote);
      _cancelEdit();
    }
  }

  void _cancelEdit() {
    setState(() {
      _editingNoteId = null;
      _editController.clear();
    });
  }

  void _deleteNote(String noteId, NotesNotifier notesNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Deseja excluir esta nota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              notesNotifier.deleteNote(noteId);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
