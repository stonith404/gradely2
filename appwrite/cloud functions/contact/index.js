let nodemailer = require('nodemailer');

const mailData = JSON.parse(process.env.APPWRITE_FUNCTION_DATA)
console.log(process.env.SMTP_HOST)

var transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: parseInt(process.env.SMTP_PORT),
    secure: false,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASSWORD,
    },})

var mailOptions = {
  from: "noreply@eliasschneider.com",
  to: process.env.TO,
  subject: 'New Mail from Gradely 2',
  text: mailData.message + "\n\n From:"+ mailData.sender
};

transporter.sendMail(mailOptions, function(error, info){
  if (error) {
    console.log(error);
  } else {
    console.log('Email sent: ' + info.response);
  }
}); 