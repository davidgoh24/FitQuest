const UserModel = require('../models/userModel');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'fitquest-secret-key';

class AuthService {
  static async login(email, password) {
    const user = await UserModel.verifyLogin(email, password);
    if (!user) return { user: null, token: null };
    if (user.role !== 'admin') {
      return { user: null, token: null, message: 'Admins only' };
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      JWT_SECRET,
      { expiresIn: '3d' }
    );

    return { user, token };
  }
}

module.exports = AuthService;
