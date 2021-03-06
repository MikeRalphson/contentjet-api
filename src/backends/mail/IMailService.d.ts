import * as nodemailer from 'nodemailer';
import Mail = require('nodemailer/lib/mailer');

export default interface IMailService {
  sendMail(data: Mail.Options): Promise<nodemailer.SentMessageInfo>;
}
