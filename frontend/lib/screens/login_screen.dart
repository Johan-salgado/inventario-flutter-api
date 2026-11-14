import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _cargando = false;
  bool _ocultarPassword = true;
  String? _error;

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    _authService.limpiarMensajeExpirado();

    try {
      await _authService.login(
        _correoController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mensajeExpirado = _authService.mensajeExpirado;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sistema de Inventario',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Inicia sesion para acceder al sistema',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 32),
                    if (mensajeExpirado != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                mensajeExpirado,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.red, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electronico',
                        hintText: 'admin@inventario.com',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Ingresa tu correo electronico';
                        }
                        if (!valor.contains('@') || !valor.contains('.')) {
                          return 'Ingresa un correo valido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _ocultarPassword,
                      decoration: InputDecoration(
                        labelText: 'Contrasena',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _ocultarPassword = !_ocultarPassword;
                            });
                          },
                        ),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.isEmpty) {
                          return 'Ingresa tu contrasena';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _cargando ? null : _iniciarSesion,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _cargando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Iniciar Sesion',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
