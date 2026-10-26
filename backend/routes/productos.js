// routes/productos.js - Endpoints CRUD para la gestion de productos
const express = require('express');
const router = express.Router();
const db = require('../database');

// 1. GET /api/productos - Listar todos los productos
router.get('/', (req, res) => {
  const sql = 'SELECT * FROM productos ORDER BY id DESC';

  db.all(sql, [], (err, rows) => {
    if (err) {
      console.error('Error al listar productos:', err.message);
      return res.status(500).json({
        error: 'Error interno del servidor al consultar productos'
      });
    }

    // Retornamos la lista de productos
    res.status(200).json(rows);
  });
});

// 2. GET /api/productos/:id - Consultar el detalle de un producto por ID
router.get('/:id', (req, res) => {
  const { id } = req.params;
  const sql = 'SELECT * FROM productos WHERE id = ?';

  db.get(sql, [id], (err, row) => {
    if (err) {
      console.error('Error al consultar producto:', err.message);
      return res.status(500).json({
        error: 'Error interno del servidor al consultar el producto'
      });
    }

    if (!row) {
      return res.status(404).json({
        error: `No se encontro ningun producto con el ID ${id}`
      });
    }

    res.status(200).json(row);
  });
});

// 3. POST /api/productos - Registrar un nuevo producto
router.post('/', (req, res) => {
  const { nombre, codigo, descripcion, precio, cantidad, categoria } = req.body;

  // Validacion de campos obligatorios
  if (!nombre || !codigo || precio === undefined || cantidad === undefined || !categoria) {
    return res.status(422).json({
      error: 'Los campos nombre, codigo, precio, cantidad y categoria son obligatorios'
    });
  }

  // Validacion de valores numericos
  const numPrecio = parseFloat(precio);
  const numCantidad = parseInt(cantidad, 10);

  if (isNaN(numPrecio) || numPrecio <= 0) {
    return res.status(422).json({
      error: 'El precio debe ser un numero mayor a 0'
    });
  }

  if (isNaN(numCantidad) || numCantidad < 0) {
    return res.status(422).json({
      error: 'La cantidad debe ser un numero entero mayor o igual a 0'
    });
  }

  // Validar si el codigo ya existe
  const sqlVerificarCodigo = 'SELECT id FROM productos WHERE codigo = ?';
  db.get(sqlVerificarCodigo, [codigo.trim()], (err, existe) => {
    if (err) {
      console.error('Error al verificar codigo:', err.message);
      return res.status(500).json({ error: 'Error al verificar disponibilidad del codigo' });
    }

    if (existe) {
      return res.status(422).json({
        error: `El codigo "${codigo}" ya se encuentra registrado para otro producto`
      });
    }

    // Insertar el nuevo producto
    const sqlInsert = `
      INSERT INTO productos (nombre, codigo, descripcion, precio, cantidad, categoria)
      VALUES (?, ?, ?, ?, ?, ?)
    `;

    const desc = descripcion ? descripcion.trim() : '';

    db.run(
      sqlInsert,
      [nombre.trim(), codigo.trim(), desc, numPrecio, numCantidad, categoria.trim()],
      function (err) {
        if (err) {
          console.error('Error al registrar producto:', err.message);
          return res.status(500).json({ error: 'Error al registrar el producto en la base de datos' });
        }

        // Consultar el registro recien insertado para devolverlo completo
        db.get('SELECT * FROM productos WHERE id = ?', [this.lastID], (err, nuevoProducto) => {
          if (err) {
            return res.status(201).json({
              id: this.lastID,
              nombre,
              codigo,
              descripcion: desc,
              precio: numPrecio,
              cantidad: numCantidad,
              categoria
            });
          }

          res.status(201).json(nuevoProducto);
        });
      }
    );
  });
});

// 4. PUT /api/productos/:id - Actualizar un producto existente
router.put('/:id', (req, res) => {
  const { id } = req.params;
  const { nombre, codigo, descripcion, precio, cantidad, categoria } = req.body;

  // Validar que el producto exista primero
  db.get('SELECT * FROM productos WHERE id = ?', [id], (err, productoActual) => {
    if (err) {
      return res.status(500).json({ error: 'Error al verificar existencia del producto' });
    }

    if (!productoActual) {
      return res.status(404).json({
        error: `No se encontro el producto con ID ${id} para actualizar`
      });
    }

    // Validacion de campos obligatorios
    if (!nombre || !codigo || precio === undefined || cantidad === undefined || !categoria) {
      return res.status(422).json({
        error: 'Los campos nombre, codigo, precio, cantidad y categoria son obligatorios'
      });
    }

    // Validacion de numeros
    const numPrecio = parseFloat(precio);
    const numCantidad = parseInt(cantidad, 10);

    if (isNaN(numPrecio) || numPrecio <= 0) {
      return res.status(422).json({
        error: 'El precio debe ser un numero mayor a 0'
      });
    }

    if (isNaN(numCantidad) || numCantidad < 0) {
      return res.status(422).json({
        error: 'La cantidad debe ser un numero entero mayor o igual a 0'
      });
    }

    // Validar si el codigo ya pertenece a OTRO producto
    const sqlCheckCodigo = 'SELECT id FROM productos WHERE codigo = ? AND id != ?';
    db.get(sqlCheckCodigo, [codigo.trim(), id], (err, existeOtro) => {
      if (err) {
        return res.status(500).json({ error: 'Error al validar codigo unico' });
      }

      if (existeOtro) {
        return res.status(422).json({
          error: `El codigo "${codigo}" ya esta en uso por otro producto`
        });
      }

      const desc = descripcion ? descripcion.trim() : '';

      const sqlUpdate = `
        UPDATE productos
        SET nombre = ?, codigo = ?, descripcion = ?, precio = ?, cantidad = ?, categoria = ?
        WHERE id = ?
      `;

      db.run(
        sqlUpdate,
        [nombre.trim(), codigo.trim(), desc, numPrecio, numCantidad, categoria.trim(), id],
        function (err) {
          if (err) {
            console.error('Error al actualizar producto:', err.message);
            return res.status(500).json({ error: 'Error al actualizar el producto' });
          }

          // Consultar el producto actualizado
          db.get('SELECT * FROM productos WHERE id = ?', [id], (err, productoActualizado) => {
            res.status(200).json(productoActualizado);
          });
        }
      );
    });
  });
});

// 5. DELETE /api/productos/:id - Eliminar un producto
router.delete('/:id', (req, res) => {
  const { id } = req.params;

  // Verificar si existe antes de eliminar
  db.get('SELECT * FROM productos WHERE id = ?', [id], (err, producto) => {
    if (err) {
      return res.status(500).json({ error: 'Error al buscar producto' });
    }

    if (!producto) {
      return res.status(404).json({
        error: `No se encontro el producto con ID ${id} para eliminar`
      });
    }

    const sqlDelete = 'DELETE FROM productos WHERE id = ?';
    db.run(sqlDelete, [id], function (err) {
      if (err) {
        return res.status(500).json({ error: 'Error al eliminar producto' });
      }

      res.status(200).json({
        mensaje: `Producto "${producto.nombre}" eliminado correctamente`,
        idEliminado: parseInt(id, 10)
      });
    });
  });
});

module.exports = router;
