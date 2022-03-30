let nodemailer = require('nodemailer');


module.exports = async function (req, res) {

  // Send a contact email
  const mailData = JSON.parse(process.env.APPWRITE_FUNCTION_DATA)

  var transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT),
    secure: false,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASSWORD,
    },
  })

  var mailOptions = {
    from: "noreply@eliasschneider.com",
    to: process.env.TO,
    subject: 'New Mail from Gradely 2',
    text: mailData.message + "\n\n From:" + mailData.sender
  };

  transporter.sendMail(mailOptions, function (error, info) {
    res.json({
      message: `Deleted user ${info.response} successfully`,
    });
  });
};


