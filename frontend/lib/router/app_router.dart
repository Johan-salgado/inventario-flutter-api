import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/producto.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/producto_detalle_screen.dart';
import '../screens/producto_form_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const MainNavigationScreen();
      },
    ),
    GoRoute(
      path: '/productos/nuevo',
      builder: (BuildContext context, GoRouterState state) {
        return const ProductoFormScreen();
      },
    ),
    GoRoute(
      path: '/productos/editar/:id',
      builder: (BuildContext context, GoRouterState state) {
        final producto = state.extra as Producto?;
        return ProductoFormScreen(productoParaEditar: producto);
      },
    ),
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
