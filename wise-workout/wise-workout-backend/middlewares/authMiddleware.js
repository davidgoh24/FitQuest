const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET;

const authenticateUser = (req, res, next) => {
  const skipPaths = ['/auth/login', '/auth/google', '/auth/facebook', '/auth/register']; // Add more if needed
  if (skipPaths.includes(req.path)) {
    return next();
  }

  const token = req.cookies.session;
  if (!token) return res.status(401).json({ message: 'No session token' });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Invalid session' });
  }
};

module.exports = authenticateUser;
