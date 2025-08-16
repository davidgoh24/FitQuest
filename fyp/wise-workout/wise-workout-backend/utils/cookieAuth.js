const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET;
const UserEntity = require('../models/userModel');

exports.setCookie = async (res, email) => {
  const user = await UserEntity.findByEmail(email);
  if (!user) return;

  const token = jwt.sign({ id: user.id }, JWT_SECRET, { expiresIn: '3d' });

  res.cookie('session', token, {
    httpOnly: true,
    secure: false,
    sameSite: 'Lax',
    maxAge: 3 * 24 * 60 * 60 * 1000,
  });
};
