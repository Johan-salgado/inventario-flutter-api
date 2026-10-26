// lib/router/app_router.dart
// Configuracion de rutas de la aplicacion utilizando el paquete go_router

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/producto.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/producto_detalle_screen.dart';
import '../screens/producto_form_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Pantalla principal con Dashboard y Listado navegable por BottomBar
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const MainNavigationScreen();
      },
    ),

    // Formulario para registrar un nuevo producto (POST)
    GoRoute(
      path: '/productos/nuevo',
      builder: (BuildContext context, GoRouterState state) {
        return const ProductoFormScreen();
      },
    ),

    // Formulario para editar un producto existente (PUT)
    GoRoute(
      path: '/productos/editar/:id',
      builder: (BuildContext context, GoRouterState state) {
        final producto = state.extra as Producto?;
        return ProductoFormScreen(productoParaEditar: producto);
      },
    ),

    // Pantalla para consultar el detalle de un producto (GET /api/productos/:id)
    GoRoute(
      path: '/productos/detalle/:id',
      builder: (BuildContext context, GoRouterState state) {
        final idStr = state.pathParameters['id'] ?? '0';
        final id = int.tryParse(idStr) ?? 0;
        return ProductoDetalleScreen(productoId: id);
      },
    ),
  ],
);
