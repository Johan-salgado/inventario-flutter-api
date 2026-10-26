// server.js - Servidor principal de la API REST
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const productosRouter = require('./routes/productos');

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors()); // Habilita peticiones cruzadas para Flutter (Web, Emulador, Dispositivo)
app.use(express.json()); // Permite recibir cuerpos de peticion en formato JSON

// Ruta de bienvenida y prueba rapida
app.get('/', (req, res) => {
  res.json({
    mensaje: 'API REST - Sistema de Gestion de Inventario (Electiva Profesional I)',
    version: '1.0.0',
    endpoints: {
      listar: 'GET /api/productos',
      detalle: 'GET /api/productos/:id',
      crear: 'POST /api/productos',
      actualizar: 'PUT /api/productos/:id',
      eliminar: 'DELETE /api/productos/:id'
    }
  });
});

// Registrar las rutas de productos
app.use('/api/productos', productosRouter);

// Manejador para rutas no encontradas (404)
app.use((req, res) => {
  res.status(404).json({
    error: 'Ruta no encontrada en la API'
  });
});

// Iniciar el servidor
app.listen(PORT, () => {
  console.log(`====================================================`);
  console.log(` Servidor corriendo en http://localhost:${PORT}`);
  console.log(` Endpoints disponibles en http://localhost:${PORT}/api/productos`);
  console.log(`====================================================`);
});
