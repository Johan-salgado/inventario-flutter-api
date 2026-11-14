require('dotenv').config();

if (!process.env.JWT_SECRET) {
  console.error('Falta JWT_SECRET en el archivo .env');
  process.exit(1);
}
const express = require('express');
const cors = require('cors');
const authRouter = require('./routes/auth');
const productosRouter = require('./routes/productos');
const verificarToken = require('./middleware/auth');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    mensaje: 'API REST - Sistema de Gestion de Inventario',
    endpoints: {
      login: 'POST /api/auth/login',
      perfil: 'GET /api/auth/perfil',
      listar: 'GET /api/productos',
      detalle: 'GET /api/productos/:id',
      crear: 'POST /api/productos',
      actualizar: 'PUT /api/productos/:id',
      eliminar: 'DELETE /api/productos/:id'
    }
  });
});

app.use('/api/auth', authRouter);
app.use('/api/productos', verificarToken, productosRouter);

app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada' });
});

app.listen(PORT, () => {
  console.log(`Servidor iniciado en puerto ${PORT}`);
});
