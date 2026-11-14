import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SesionScreen extends StatefulWidget {
  const SesionScreen({super.key});

  @override
  State<SesionScreen> createState() => _SesionScreenState();
}

class _SesionScreenState extends State<SesionScreen> {
  final AuthService _authService = AuthService();
  bool _tieneToken = false;
  bool _cerrandoSesion = false;

  @override
  void initState() {
    super.initState();
    _verificarTokenLocal();
  }

  Future<void> _verificarTokenLocal() async {
    final tiene = await _authService.tieneTokenAlmacenado();
    if (mounted) {
      setState(() {
        _tieneToken = tiene;
      });
    }
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesion'),
        content: const Text('Estas seguro de que deseas cerrar tu sesion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesion'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() {
      _cerrandoSesion = true;
    });

    await _authService.cerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _authService.usuarioActual;
    final autenticado = _authService.autenticado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informacion de Sesion'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        (usuario?.nombre.isNotEmpty ?? false)
                            ? usuario!.nombre[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      usuario?.nombre ?? 'Usuario no autenticado',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      usuario?.correo ?? 'Sin correo',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.verified_user_outlined,
                        color: autenticado ? Colors.green : Colors.red,
                      ),
                      title: const Text('Estado de autenticacion'),
                      trailing: Chip(
                        label: Text(
                          autenticado ? 'Sesion activa' : 'Sin sesion',
                          style: TextStyle(
                            color: autenticado ? Colors.green.shade800 : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor:
                            autenticado ? Colors.green.shade50 : Colors.red.shade50,
                        side: BorderSide.none,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.key_outlined,
                        color: _tieneToken ? Colors.blue : Colors.grey,
                      ),
                      title: const Text('Token seguro almacenado'),
                      subtitle: const Text('Guardado en Flutter Secure Storage'),
                      trailing: Chip(
                        label: Text(
                          _tieneToken ? 'Si' : 'No',
                          style: TextStyle(
                            color: _tieneToken ? Colors.blue.shade800 : Colors.grey.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor:
                            _tieneToken ? Colors.blue.shade50 : Colors.grey.shade200,
                        side: BorderSide.none,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.storage_outlined, color: Colors.orange),
                      title: const Text('Datos de usuario'),
                      subtitle: const Text('Guardados en SharedPreferences'),
                      trailing: const Text(
                        'Nombre y Correo',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.tonalIcon(
              onPressed: _cerrandoSesion ? null : _cerrarSesion,
              style: FilledButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                backgroundColor: Colors.red.shade50,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: _cerrandoSesion
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: Text(
                _cerrandoSesion ? 'Cerrando sesion...' : 'Cerrar Sesion',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
