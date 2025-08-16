const jwt = require('jsonwebtoken');
const UserModel = require('../models/userModel');
const JWT_SECRET = process.env.JWT_SECRET || 'fitquest-secret-key';

const authenticateUser = async (req, res, next) => {
  const token = req.cookies?.session || req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).json({ message: 'No session token' });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const user = await UserModel.findByIdWithRole(decoded.id);
    if (!user) return res.status(401).json({ message: 'Invalid session' });

    if (user.role !== 'admin') {
      return res.status(401).json({ message: 'Admins only' });
    }

    req.user = user;
    next();
  } catch {
    return res.status(401).json({ message: 'Invalid session' });
  }
};

module.exports = authenticateUser;
