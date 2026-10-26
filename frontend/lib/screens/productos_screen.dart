import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ProductoService _productoService = ProductoService();
  bool _cargando = true;
  String? _error;
  List<Producto> _productos = [];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final lista = await _productoService.obtenerProductos();
      setState(() {
        _productos = lista;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _cargando = false;
      });
    }
  }

  Future<void> _confirmarYEliminar(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminacion'),
        content: Text('¿Estas seguro de eliminar el producto "${producto.nombre}"?\nEsta accion no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      try {
        await _productoService.eliminarProducto(producto.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Producto "${producto.nombre}" eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          _cargarProductos();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatearPrecio(double precio) {
    final formato = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    return formato.format(precio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario de Productos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: _cargarProductos,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final resultado = await context.push('/productos/nuevo');
          if (resultado == true) {
            _cargarProductos();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: RefreshIndicator(
        onRefresh: _cargarProductos,
        child: _construirContenido(),
      ),
    );
  }

  Widget _construirContenido() {
    if (_cargando) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Obteniendo lista de productos...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'No se pudo conectar con la API',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _cargarProductos,
                icon: const Icon(Icons.refresh),
                label: const Text('Volver a intentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_productos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No hay productos registrados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pulsa el boton "Agregar" para registrar el primero.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final res = await context.push('/productos/nuevo');
                if (res == true) _cargarProductos();
              },
              icon: const Icon(Icons.add),
              label: const Text('Registrar Producto'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _productos.length,
      itemBuilder: (context, index) {
        final p = _productos[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () async {
              final res = await context.push('/productos/detalle/${p.id}');
              if (res == true) {
                _cargarProductos();
              }
            },
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            title: Text(
              p.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Codigo: ${p.codigo}  •  ${p.categoria}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatearPrecio(p.precio),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: p.cantidad > 5 ? Colors.green.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: p.cantidad > 5 ? Colors.green : Colors.orange,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'Stock: ${p.cantidad}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: p.cantidad > 5 ? Colors.green.shade900 : Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  tooltip: 'Editar',
                  onPressed: () async {
                    final res = await context.push('/productos/editar/${p.id}', extra: p);
                    if (res == true) {
                      _cargarProductos();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Eliminar',
                  onPressed: () => _confirmarYEliminar(p),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
