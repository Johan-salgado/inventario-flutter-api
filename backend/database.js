// database.js - Conexion y configuracion de la base de datos SQLite
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// Ruta donde se guardara el archivo de la base de datos
const dbPath = path.resolve(__dirname, 'inventario.db');

// Crear o abrir la base de datos
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error al conectar con la base de datos SQLite:', err.message);
  } else {
    console.log('Conectado exitosamente a la base de datos SQLite (inventario.db)');
    inicializarBaseDatos();
  }
});

// Funcion para crear la tabla y agregar productos iniciales si esta vacia
function inicializarBaseDatos() {
  const sqlCrearTabla = `
    CREATE TABLE IF NOT EXISTS productos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      codigo TEXT NOT NULL UNIQUE,
      descripcion TEXT,
      precio REAL NOT NULL,
      cantidad INTEGER NOT NULL,
      categoria TEXT NOT NULL
    )
  `;

  db.run(sqlCrearTabla, (err) => {
    if (err) {
      console.error('Error al crear la tabla productos:', err.message);
      return;
    }

    // Verificar si ya existen productos registrados
    db.get('SELECT COUNT(*) AS total FROM productos', (err, row) => {
      if (err) {
        console.error('Error al contar productos:', err.message);
        return;
      }

      // Si la tabla esta vacia, insertamos al menos 10 productos de prueba (requisito 3.3)
      if (row.total === 0) {
        console.log('Tabla vacia. Insertando productos de prueba iniciales...');

        const productosSemilla = [
          ['Laptop Lenovo ThinkPad', 'PROD-001', 'Intel Core i5, 16GB RAM, 512GB SSD', 2850000, 15, 'Computadores'],
          ['Mouse Inalambrico Logitech', 'PROD-002', 'Conexion Bluetooth y USB 2.4Ghz', 75000, 40, 'Accesorios'],
          ['Teclado Mecanico RGB', 'PROD-003', 'Switches Red silenciosos con retroiluminacion', 190000, 25, 'Accesorios'],
          ['Monitor Gamer 24" 144Hz', 'PROD-004', 'Panel IPS Full HD con FreeSync', 650000, 12, 'Monitores'],
          ['Auriculares HyperX Cloud', 'PROD-005', 'Microfono con cancelacion de ruido', 220000, 18, 'Audio'],
          ['Impresora Multifuncional Epson', 'PROD-006', 'Sistema continuo EcoTank WiFi', 820000, 8, 'Impresoras'],
          ['Disco Solido SSD 1TB NVMe', 'PROD-007', 'Velocidad de lectura 3500 MB/s', 310000, 30, 'Almacenamiento'],
          ['Memoria RAM 16GB DDR4', 'PROD-008', 'Frecuencia 3200MHz para PC gamer', 160000, 22, 'Componentes'],
          ['Silla Ergonomica de Oficina', 'PROD-009', 'Soporte lumbar ajustable y descansabrazos', 450000, 10, 'Muebles'],
          ['Webcam Full HD 1080p', 'PROD-010', 'Camara web con microfono estereo integrado', 115000, 20, 'Accesorios'],
          ['Cable HDMI 2.1 4K', 'PROD-011', 'Cable de alta velocidad de 2 metros', 35000, 50, 'Cables y Adaptadores'],
          ['Router TP-Link WiFi 6', 'PROD-012', 'Doble banda con tecnologia Mesh Gigabit', 280000, 14, 'Redes']
        ];

        const sqlInsert = `
          INSERT INTO productos (nombre, codigo, descripcion, precio, cantidad, categoria)
          VALUES (?, ?, ?, ?, ?, ?)
        `;

        const stmt = db.prepare(sqlInsert);
        productosSemilla.forEach((producto) => {
          stmt.run(producto);
        });
        stmt.finalize();

        console.log('Se registraron exitosamente los 12 productos de prueba.');
      }
    });
  });
}

module.exports = db;
