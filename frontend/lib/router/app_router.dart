import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/producto.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/producto_detalle_screen.dart';
import '../screens/producto_form_screen.dart';
import '../screens/splash_screen.dart';
import '../services/auth_service.dart';

final AuthService authService = AuthService();

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: authService,
  redirect: (BuildContext context, GoRouterState state) {
    if (!authService.inicializado) {
      if (state.matchedLocation != '/splash') {
        return '/splash';
      }
      return null;
    }

    final autenticado = authService.autenticado;
    final enLogin = state.matchedLocation == '/login';
    final enSplash = state.matchedLocation == '/splash';

    if (!autenticado) {
      return enLogin ? null : '/login';
    }

    if (enLogin || enSplash) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
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
