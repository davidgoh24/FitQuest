const sanitizeInput = (input) => {
    if (typeof input !== 'string') return '';
    return input.trim().replace(/<[^>]*>?/gm, ''); 
  };
  
const isValidEmail = (email) => {
    const sanitized = sanitizeInput(email);
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(sanitized) ? sanitized : null;
  };
  
const isValidPassword = (password) => {
  if (typeof password !== 'string') return null;
  const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$/;
  return regex.test(password) ? password : null;
};
  
module.exports = {
    sanitizeInput,
    isValidEmail,
    isValidPassword
  };
  