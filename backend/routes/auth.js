const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const db = require('../database');
const verificarToken = require('../middleware/auth');

router.post('/login', (req, res) => {
  const { correo, password } = req.body;

  if (!correo || !password) {
    return res.status(401).json({
      error: 'Correo y contrasena requeridos'
    });
  }

  const sql = 'SELECT * FROM usuarios WHERE correo = ?';
  db.get(sql, [correo.trim().toLowerCase()], (err, usuario) => {
    if (err) {
      return res.status(500).json({ error: 'Error al consultar usuario' });
    }

    if (!usuario) {
      return res.status(401).json({
        error: 'Credenciales incorrectas'
      });
    }

    const passwordValida = bcrypt.compareSync(password, usuario.password);
    if (!passwordValida) {
      return res.status(401).json({
        error: 'Credenciales incorrectas'
      });
    }

    const payload = {
      id: usuario.id,
      nombre: usuario.nombre,
      correo: usuario.correo
    };

    const secret = process.env.JWT_SECRET || 'clave_secreta_jwt_inventario_uceva_2026';
    const expiresIn = process.env.JWT_EXPIRES_IN || '1h';
    const token = jwt.sign(payload, secret, { expiresIn });

    res.status(200).json({
      token,
      usuario: {
        id: usuario.id,
        nombre: usuario.nombre,
        correo: usuario.correo
      }
    });
  });
});

router.get('/perfil', verificarToken, (req, res) => {
  res.status(200).json({
    usuario: {
      id: req.usuario.id,
      nombre: req.usuario.nombre,
      correo: req.usuario.correo
    },
    nombre: req.usuario.nombre,
    correo: req.usuario.correo
  });
});

module.exports = router;
