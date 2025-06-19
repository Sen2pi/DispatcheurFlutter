import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../common/glass_container.dart';

class AudioControlsOverlay extends StatefulWidget {
  const AudioControlsOverlay({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onMicrophoneChanged,
    required this.onSpeakerChanged,
    this.selectedMicrophone,
    this.selectedSpeaker,
    this.availableMicrophones = const [],
    this.availableSpeakers = const [],
    required this.isMobile,
  });

  final bool isOpen;
  final VoidCallback onClose;
  final Function(String) onMicrophoneChanged;
  final Function(String) onSpeakerChanged;
  final String? selectedMicrophone;
  final String? selectedSpeaker;
  final List<MediaDeviceInfo> availableMicrophones;
  final List<MediaDeviceInfo> availableSpeakers;
  final bool isMobile;

  @override
  State<AudioControlsOverlay> createState() => _AudioControlsOverlayState();
}

class _AudioControlsOverlayState extends State<AudioControlsOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

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
  void didUpdateWidget(AudioControlsOverlay oldWidget) {
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
                        Expanded(child: _buildDevicesList()),
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
          const Icon(Icons.volume_up, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'Dispositivos de Áudio',
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

  Widget _buildDevicesList() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMicrophonesSection(),
          const SizedBox(height: 24),
          _buildSpeakersSection(),
        ],
      ),
    );
  }

  Widget _buildMicrophonesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.mic, color: Color(0xFF1e3a8a)),
            SizedBox(width: 8),
            Text(
              'Microfones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e3a8a),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.availableMicrophones.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nenhum microfone disponível',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...widget.availableMicrophones.map((device) {
            final isSelected = device.deviceId == widget.selectedMicrophone;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color:
                  isSelected ? const Color(0xFF3b82f6).withOpacity(0.1) : null,
              child: ListTile(
                leading: Icon(
                  Icons.mic,
                  color: isSelected ? const Color(0xFF3b82f6) : Colors.grey,
                ),
                title: Text(
                  device.label.isNotEmpty ? device.label : 'Microfone padrão',
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF1e3a8a) : null,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Color(0xFF22c55e))
                    : null,
                onTap: () => widget.onMicrophoneChanged(device.deviceId),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildSpeakersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.volume_up, color: Color(0xFF1e3a8a)),
            SizedBox(width: 8),
            Text(
              'Alto-falantes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e3a8a),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.availableSpeakers.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nenhum alto-falante disponível',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...widget.availableSpeakers.map((device) {
            final isSelected = device.deviceId == widget.selectedSpeaker;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color:
                  isSelected ? const Color(0xFF3b82f6).withOpacity(0.1) : null,
              child: ListTile(
                leading: Icon(
                  Icons.volume_up,
                  color: isSelected ? const Color(0xFF3b82f6) : Colors.grey,
                ),
                title: Text(
                  device.label.isNotEmpty
                      ? device.label
                      : 'Alto-falante padrão',
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF1e3a8a) : null,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Color(0xFF22c55e))
                    : null,
                onTap: () => widget.onSpeakerChanged(device.deviceId),
              ),
            );
          }),
      ],
    );
  }
}
