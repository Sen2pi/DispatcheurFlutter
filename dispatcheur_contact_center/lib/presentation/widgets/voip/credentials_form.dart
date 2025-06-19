import 'package:flutter/material.dart';
import 'dart:ui';

class CredentialsForm extends StatefulWidget {
  const CredentialsForm({
    super.key,
    required this.open,
    required this.onClose,
    required this.onSubmit,
    this.initialCredentials,
  });

  final bool open;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSubmit;
  final Map<String, dynamic>? initialCredentials;

  @override
  State<CredentialsForm> createState() => _CredentialsFormState();
}

class _CredentialsFormState extends State<CredentialsForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _portController = TextEditingController(text: '5060');

  bool _secure = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadInitialCredentials();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    if (widget.open) {
      _animationController.forward();
    }
  }

  void _loadInitialCredentials() {
    if (widget.initialCredentials != null) {
      _serverController.text = widget.initialCredentials!['server'] ?? '';
      _usernameController.text = widget.initialCredentials!['username'] ?? '';
      _passwordController.text = widget.initialCredentials!['password'] ?? '';
      _displayNameController.text =
          widget.initialCredentials!['displayName'] ?? '';
      _portController.text =
          widget.initialCredentials!['port']?.toString() ?? '5060';
      _secure = widget.initialCredentials!['secure'] ?? false;
    }
  }

  @override
  void didUpdateWidget(CredentialsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open && !oldWidget.open) {
      _animationController.forward();
    } else if (!widget.open && oldWidget.open) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final credentials = {
        'server': _serverController.text.trim(),
        'username': _usernameController.text.trim(),
        'password': _passwordController.text,
        'displayName': _displayNameController.text.trim(),
        'port': int.tryParse(_portController.text) ?? 5060,
        'secure': _secure,
      };
      widget.onSubmit(credentials);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.open) return const SizedBox();

    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1e3a8a),
                          Color(0xFF3b82f6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3b82f6).withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          _buildForm(),
                          _buildActions(),
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.settings, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'Configurations VoIP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
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

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Servidor
          TextFormField(
            controller: _serverController,
            decoration: InputDecoration(
              labelText: 'Serveur SIP',
              hintText: 'sip.example.com',
              prefixIcon: const Icon(Icons.dns, color: Colors.white70),
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: const TextStyle(color: Colors.white38),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Serveur est obligatoire';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Username e Porta
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Utilisateur',
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Utilisateur obligatoire';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _portController,
                  decoration: InputDecoration(
                    labelText: 'Port',
                    prefixIcon: const Icon(Icons.settings_ethernet,
                        color: Colors.white70),
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Port obligatoire';
                    }
                    final port = int.tryParse(value);
                    if (port == null || port < 1 || port > 65535) {
                      return 'Port invalide';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock, color: Colors.white70),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Mot de passe obligatoire';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Display Name
          TextFormField(
            controller: _displayNameController,
            decoration: InputDecoration(
              labelText: 'Nom d\'affichage',
              prefixIcon: const Icon(Icons.badge, color: Colors.white70),
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),

          const SizedBox(height: 16),

          // Secure connection
          Row(
            children: [
              Checkbox(
                value: _secure,
                onChanged: (value) => setState(() => _secure = value ?? false),
                checkColor: Colors.blue,
                fillColor: WidgetStateProperty.all(Colors.white),
              ),
              const Text(
                'Connexion sécurisée (TLS)',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onClose,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Connecter',
                style: TextStyle(
                  color: Color(0xFF1e3a8a),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
