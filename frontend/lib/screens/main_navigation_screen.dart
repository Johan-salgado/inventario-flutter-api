// lib/screens/main_navigation_screen.dart
// Pantalla contenedor con BottomNavigationBar para alternar entre Dashboard y Productos

import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'productos_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _indiceSeleccionado = 0;

  void _cambiarPestana(int indice) {
    setState(() {
      _indiceSeleccionado = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pantallas = [
      DashboardScreen(
        onIrAProductos: () => _cambiarPestana(1),
      ),
      const ProductosScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _indiceSeleccionado,
        children: pantallas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSeleccionado,
        onDestinationSelected: _cambiarPestana,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Productos',
          ),
        ],
      ),
    );
  }
}
