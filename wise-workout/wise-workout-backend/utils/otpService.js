require('dotenv').config();
const nodemailer = require('nodemailer');

exports.sendOTPToEmail = async (email, otp) => {
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    }
  });

  const mailOptions = {
    from: `Wise Workout <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Your OTP for Wise Workout',
    text: `Your OTP is: ${otp}`
  };

  await transporter.sendMail(mailOptions);
};
