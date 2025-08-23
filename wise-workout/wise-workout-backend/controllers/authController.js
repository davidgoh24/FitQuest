const AuthService = require('../services/authService');
const UserModel = require('../models/userModel');
const DailyQuestModel = require('../models/dailyQuestModel');
const DailyQuestService = require('../services/dailyQuestService');
const UserService = require('../services/userService');
const { setCookie } = require('../utils/cookieAuth');
const { isValidEmail, isValidPassword, sanitizeInput } = require('../utils/sanitize');
const { sendOTPToEmail } = require('../utils/otpService');

exports.login = async (req, res) => {
  const email = isValidEmail(req.body.email);
  const password = isValidPassword(req.body.password);

  if (!email || !password) {
    return res.status(400).json({ message: 'Invalid email or password format' });
  }

  const userObj = await UserModel.findByEmail(email);
  if (!userObj) return res.status(401).json({ message: 'Invalid credentials' });
  if (userObj.isSuspended) return res.status(403).json({ message: 'Account suspended. Contact support.' });

  const user = await AuthService.loginWithCredentials(email, password);
  if (!user) return res.status(401).json({ message: 'Invalid credentials' });

  await DailyQuestService.ensureTodayQuests(userObj.id);
  const today = new Date().toISOString().slice(0, 10);
  await DailyQuestModel.markQuestDone(userObj.id, 'DAILY_LOGIN', today);
  await UserService.updateLoginStreak(userObj.id);

  await setCookie(res, email);
  res.json({ message: 'Login successful' });
};

exports.loginGoogle = async (req, res) => {
  const email = isValidEmail(req.body.email);
  const firstName = sanitizeInput(req.body.firstName || '');
  const lastName = sanitizeInput(req.body.lastName || '');

  if (!email) return res.status(400).json({ message: 'Invalid email' });

  const userObj = await UserModel.findByEmail(email);
  if (userObj && userObj.isSuspended) return res.status(403).json({ message: 'Account suspended. Contact support.' });

  await AuthService.loginWithOAuth(email, firstName, lastName, 'google');
  await setCookie(res, email);

  const userForQuest = await UserModel.findByEmail(email);
  await DailyQuestService.ensureTodayQuests(userForQuest.id);
  const today = new Date().toISOString().slice(0, 10);
  await DailyQuestModel.markQuestDone(userForQuest.id, 'DAILY_LOGIN', today);
  await UserService.updateLoginStreak(userForQuest.id);

  res.json({ message: 'Google login successful' });
};

exports.loginApple = async (req, res) => {
  const email = isValidEmail(req.body.email);
  const firstName = sanitizeInput(req.body.firstName || '');
  const lastName = sanitizeInput(req.body.lastName || '');

  if (!email) return res.status(400).json({ message: 'Invalid email' });

  const userObj = await UserModel.findByEmail(email);
  if (userObj && userObj.isSuspended) return res.status(403).json({ message: 'Account suspended. Contact support.' });

  await AuthService.loginWithOAuth(email, firstName, lastName, 'apple');
  await setCookie(res, email);

  const userForQuest = await UserModel.findByEmail(email);
  await DailyQuestService.ensureTodayQuests(userForQuest.id);
  const today = new Date().toISOString().slice(0, 10);
  await DailyQuestModel.markQuestDone(userForQuest.id, 'DAILY_LOGIN', today);
  await UserService.updateLoginStreak(userForQuest.id);

  res.json({ message: 'Apple login successful' });
};

exports.loginFacebook = async (req, res) => {
  const email = isValidEmail(req.body.email);
  const firstName = sanitizeInput(req.body.firstName || '');
  const lastName = sanitizeInput(req.body.lastName || '');

  if (!email) return res.status(400).json({ message: 'Invalid email' });

  const userObj = await UserModel.findByEmail(email);
  if (userObj && userObj.isSuspended) return res.status(403).json({ message: 'Account suspended. Contact support.' });

  await AuthService.loginWithOAuth(email, firstName, lastName, 'facebook');
  await setCookie(res, email);

  const userForQuest = await UserModel.findByEmail(email);
  await DailyQuestService.ensureTodayQuests(userForQuest.id);
  const today = new Date().toISOString().slice(0, 10);
  await DailyQuestModel.markQuestDone(userForQuest.id, 'DAILY_LOGIN', today);
  await UserService.updateLoginStreak(userForQuest.id);

  res.json({ message: 'Facebook login successful' });
};

exports.register = async (req, res) => {
  const { email, username, password, firstName, lastName } = req.body;

  const cleanEmail = isValidEmail(email);
  const cleanPassword = isValidPassword(password);
  const cleanUsername = sanitizeInput(username);
  const cleanFirstName = sanitizeInput(firstName || '');
  const cleanLastName = sanitizeInput(lastName || '');

  if (!cleanEmail || !cleanPassword || !cleanUsername) {
    return res.status(400).json({ message: 'Invalid email, username, or password format' });
  }

  try {
    const otp = await AuthService.registerUser(
      cleanEmail,
      cleanUsername,
      cleanPassword,
      cleanFirstName,
      cleanLastName
    );
    await sendOTPToEmail(cleanEmail, otp);
    res.status(201).json({ message: 'OTP sent to email. Complete verification to finish registration.' });
  } catch (err) {
    if (err.message === 'EMAIL_EXISTS') {
      return res.status(409).json({ message: 'User with this email already exists' });
    }
    if (err.message === 'USERNAME_EXISTS') {
      return res.status(409).json({ message: 'Username is already taken' });
    }
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

exports.me = async (req, res) => {
  try {
    const user = await UserModel.findById(req.user.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json({ message: 'Authenticated' });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};
