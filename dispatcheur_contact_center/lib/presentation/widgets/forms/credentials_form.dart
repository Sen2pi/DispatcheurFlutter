import 'package:flutter/material.dart';

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

class _CredentialsFormState extends State<CredentialsForm> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _portController = TextEditingController(text: '5060');

  bool _secure = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
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
  void dispose() {
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

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.settings, color: Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  const Text(
                    'Configurações VoIP',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _serverController,
                decoration: const InputDecoration(
                  labelText: 'Servidor SIP',
                  hintText: 'sip.exemplo.com',
                  prefixIcon: Icon(Icons.dns),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Servidor é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Utilizador',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Utilizador é obrigatório';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _portController,
                      decoration: const InputDecoration(
                        labelText: 'Porta',
                        prefixIcon: Icon(Icons.settings_ethernet),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Porta é obrigatória';
                        }
                        final port = int.tryParse(value);
                        if (port == null || port < 1 || port > 65535) {
                          return 'Porta inválida';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome de Exibição',
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Conexão Segura (TLS)'),
                value: _secure,
                onChanged: (value) => setState(() => _secure = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onClose,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
