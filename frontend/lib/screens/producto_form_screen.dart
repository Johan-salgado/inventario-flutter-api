import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

class ProductoFormScreen extends StatefulWidget {
  final Producto? productoParaEditar;

  const ProductoFormScreen({super.key, this.productoParaEditar});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductoService _productoService = ProductoService();

  late TextEditingController _nombreCtrl;
  late TextEditingController _codigoCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _cantidadCtrl;
  late TextEditingController _categoriaCtrl;

  bool _esEdicion = false;
  bool _guardando = false;

  final List<String> _categoriasSugeridas = [
    'Computadores',
    'Accesorios',
    'Monitores',
    'Audio',
    'Impresoras',
    'Almacenamiento',
    'Componentes',
    'Redes',
    'Muebles',
    'Cables y Adaptadores',
  ];

  @override
  void initState() {
    super.initState();
    _esEdicion = widget.productoParaEditar != null;

    final p = widget.productoParaEditar;
    _nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    _codigoCtrl = TextEditingController(text: p?.codigo ?? '');
    _descripcionCtrl = TextEditingController(text: p?.descripcion ?? '');
    _precioCtrl = TextEditingController(text: p != null ? p.precio.toString() : '');
    _cantidadCtrl = TextEditingController(text: p != null ? p.cantidad.toString() : '');
    _categoriaCtrl = TextEditingController(text: p?.categoria ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _codigoCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _cantidadCtrl.dispose();
    _categoriaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final productoDatos = Producto(
        id: widget.productoParaEditar?.id,
        nombre: _nombreCtrl.text.trim(),
        codigo: _codigoCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        precio: double.parse(_precioCtrl.text.trim()),
        cantidad: int.parse(_cantidadCtrl.text.trim()),
        categoria: _categoriaCtrl.text.trim(),
      );

      if (_esEdicion) {
        await _productoService.actualizarProducto(
          widget.productoParaEditar!.id!,
          productoDatos,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await _productoService.crearProducto(productoDatos);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto registrado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error al guardar'),
            content: Text(errorMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Producto' : 'Registrar Producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.blue.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _esEdicion
                              ? 'Modifica los datos del producto y presiona guardar.'
                              : 'Ingresa la informacion para agregar un nuevo producto.',
                          style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto *',
                  hintText: 'Ej: Monitor Gamer 27"',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _codigoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Codigo Unico *',
                  hintText: 'Ej: PROD-101',
                  prefixIcon: Icon(Icons.qr_code),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'El codigo unico es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Autocomplete<String>(
                initialValue: TextEditingValue(text: _categoriaCtrl.text),
                optionsBuilder: (TextEditingValue valor) {
                  if (valor.text.isEmpty) {
                    return _categoriasSugeridas;
                  }
                  return _categoriasSugeridas.where((cat) =>
                      cat.toLowerCase().contains(valor.text.toLowerCase()));
                },
                onSelected: (String seleccion) {
                  _categoriaCtrl.text = seleccion;
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  controller.addListener(() {
                    _categoriaCtrl.text = controller.text;
                  });
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Categoria *',
                      hintText: 'Selecciona o escribe una categoria',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'La categoria es obligatoria';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precioCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Precio Unitario *',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Ingresa el precio';
                        }
                        final num = double.tryParse(valor.trim());
                        if (num == null || num <= 0) {
                          return 'Debe ser mayor a 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cantidadCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad Stock *',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Ingresa la cantidad';
                        }
                        final num = int.tryParse(valor.trim());
                        if (num == null || num < 0) {
                          return 'Minimo 0';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripcion Adicional (Opcional)',
                  hintText: 'Especificaciones tecnicas, garantia, etc.',
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _guardando ? null : _guardarProducto,
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        _esEdicion ? 'Actualizar Producto' : 'Guardar Producto',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
