const AuthService = require('../services/authService');

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const { user, token, message } = await AuthService.login(email, password);

    if (!user) {
      return res.status(401).json({ message: message || 'Invalid email or password' });
    }

    res.clearCookie('session', { httpOnly: true, sameSite: 'lax', secure: false });

    res.cookie('session', token, {
      httpOnly: true,
      sameSite: 'None',   
      secure: true,       
      maxAge: 3 * 24 * 60 * 60 * 1000
    });    

    res.status(200).json({
      message: 'Login Successful',
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role
      }
    });
  } catch {
    res.status(500).json({ message: 'Something went wrong.' });
  }
};
exports.me = async (req, res) => {
  res.status(200).json({ message: "logged in" });
};
