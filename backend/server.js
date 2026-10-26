require('dotenv').config();
const express = require('express');
const cors = require('cors');
const productosRouter = require('./routes/productos');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    mensaje: 'API REST - Sistema de Gestion de Inventario',
    endpoints: {
      listar: 'GET /api/productos',
      detalle: 'GET /api/productos/:id',
      crear: 'POST /api/productos',
      actualizar: 'PUT /api/productos/:id',
      eliminar: 'DELETE /api/productos/:id'
    }
  });
});

app.use('/api/productos', productosRouter);

app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada' });
});

app.listen(PORT, () => {
  console.log(`Servidor iniciado en puerto ${PORT}`);
});
