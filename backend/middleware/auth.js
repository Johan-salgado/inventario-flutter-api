const jwt = require('jsonwebtoken');

function verificarToken(req, res, next) {
  const authHeader = req.headers.authorization || req.headers.Authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token de autenticacion no proporcionado' });
  }

  const token = authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Token de autenticacion no proporcionado' });
  }

  const secret = process.env.JWT_SECRET;

  jwt.verify(token, secret, (err, decoded) => {
    if (err) {
      if (err.name === 'TokenExpiredError') {
        return res.status(401).json({ error: 'El token ha expirado' });
      }
      return res.status(401).json({ error: 'Token de autenticacion invalido' });
    }

    req.usuario = decoded;
    next();
  });
}

module.exports = verificarToken;
