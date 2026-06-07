package be.mxs.common.util.tools;

import javax.mail.*;
import javax.mail.internet.*;

import java.util.Properties;

import javax.activation.*; // Needed for Email with Images // Attachments .DataSource

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;

public class sendHtmlMail {
	
	static public boolean sendSimpleMail(String smtpServer, String sFrom, String sTo, String sSubject, String sMessage){    	
		boolean bSuccess=false;
		try{
			final String username = MedwanQuery.getInstance(false).getConfigString("mailbot.user","openclinic.mailrobot@ict4d.be");
			final String password = MedwanQuery.getInstance(false).getConfigString("mailbot.password","nopass");

			Properties props = new Properties();
			props.put("mail.smtp.auth", "true");
			props.put("mail.smtp.starttls.enable", "true");
			props.put("mail.smtp.host", MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"));
			props.put("mail.smtp.port", MedwanQuery.getInstance(false).getConfigString("mailbot.port","587"));
	        props.put("mail.smtp.user", username);
	        props.put("mail.smtp.password", password);
	        props.put("mail.smtp.ssl.trust", MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"));        

	        Session mailSession = Session.getInstance(props);

	        mailSession.setDebug(MedwanQuery.getInstance(false).getConfigString("Debug").equalsIgnoreCase("On"));
	        Transport transport = mailSession.getTransport("smtp");
	
	        MimeMessage message = new MimeMessage(mailSession);
	        message.setSubject(sSubject);
	        message.setFrom(new InternetAddress(sFrom));
	        
	        message.setHeader("content-type: text/plain", "charset=ISO-8859-1");
	 
	        message.setContent(sMessage, "text/plain");
	        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(sTo,false));
	
	        transport.connect(MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"),username,password);
	        transport.sendMessage(message,message.getRecipients(Message.RecipientType.TO));
	        transport.close();
	        bSuccess=true;
		}
        catch(Exception e){
        	Debug.println(e.getMessage());
        }
		return bSuccess;
	}

	static public void sendMail(String smtpServer, String sFrom, String sTo, String sSubject, String sMessage)
			throws AddressException, MessagingException {    	
		try{
			final String username = MedwanQuery.getInstance(false).getConfigString("mailbot.user","openclinic.mailrobot@ict4d.be");
			final String password = MedwanQuery.getInstance(false).getConfigString("mailbot.password","nopass");

			Properties props = new Properties();
			props.put("mail.smtp.auth", "true");
			props.put("mail.smtp.starttls.enable", "true");
			props.put("mail.smtp.host", MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"));
			props.put("mail.smtp.port", MedwanQuery.getInstance(false).getConfigString("mailbot.port","587"));
	        props.put("mail.smtp.user", username);
	        props.put("mail.smtp.password", password);
	        props.put("mail.smtp.ssl.trust", MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"));        

	        Session mailSession = Session.getInstance(props);

	        mailSession.setDebug(MedwanQuery.getInstance(false).getConfigString("Debug").equalsIgnoreCase("On"));
	        Transport transport = mailSession.getTransport("smtp");
	
	        MimeMessage message = new MimeMessage(mailSession);
	        message.setSubject(sSubject);
	        message.setFrom(new InternetAddress(sFrom));
	        
	        message.setHeader("content-type", "text/html; charset=ISO-8859-1"); 
	        //message.setHeader("content-type: text/html", "charset=ISO-8859-1"); 
	        //This works!! Output is: Content-Type: text/html; charset=ISO-8859-1. Content-Transfer-Encoding: quoted-printable. content-type: text/html: charset=ISO-8859-1
	 
	        message.setContent(sMessage, "text/html");
	        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(sTo,false));
	
	        transport.connect(MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"),username,password);
	        transport.sendMessage(message,message.getRecipients(Message.RecipientType.TO));
	        transport.close();
		}
        catch(Exception e){
        	Debug.print(e.getMessage());
        }

        //transport.sendMessage(message, message.getAllRecipients());               
	}
	
	static public boolean sendEmailWithImages(String smtpServer, String sFrom, String sTo, String sSubject, String sMessage, String sImage) throws Exception{      		    	
	    	// * * The browser accesses these images just as if it were displaying an image in a Web page. Unfortunately, spammers have used this mechanism as a sneaky way to record who visits their site (and mark your email as valid). To protect your privacy, many Web-based (and other) email clients don't display images in HTML emails.
			//	An alternative to placing absolute URLs to images in your HTML is to include the images as attachments to the email. The HTML can reference the image in an attachment by using the protocol prefix cid: plus the content-id of the attachment.      		       
	    boolean bSuccess = false;    
		try{
			final String username = MedwanQuery.getInstance(false).getConfigString("mailbot.user","openclinic.mailrobot@ict4d.be");
			final String password = MedwanQuery.getInstance(false).getConfigString("mailbot.password","nopass");

			Properties props = new Properties();
			props.put("mail.smtp.auth", "true");
			props.put("mail.smtp.starttls.enable", "true");
			props.put("mail.smtp.host", MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"));
			props.put("mail.smtp.port", MedwanQuery.getInstance(false).getConfigString("mailbot.port","587"));
	        props.put("mail.smtp.user", username);
	        props.put("mail.smtp.password", password);
	        props.put("mail.smtp.ssl.trust", MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"));        

	        Session mailSession = Session.getInstance(props);

	        mailSession.setDebug(MedwanQuery.getInstance(false).getConfigString("Debug").equalsIgnoreCase("On"));
	        Transport transport = mailSession.getTransport("smtp");
	
	        MimeMessage message = new MimeMessage(mailSession);
	        message.setSubject(sSubject);
	        message.setFrom(new InternetAddress(sFrom));	  
	        message.setSentDate(new java.util.Date());
	        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(sTo,false));
	
	        // This HTML mail have to 2 part, the BODY and the embedded image       
	        MimeMultipart multipart = new MimeMultipart("related");
	
	        // first part  (the html)
	        BodyPart messageBodyPart = new MimeBodyPart();		
	        String htmlText = sMessage;	    //String htmlText = "<H1>Hello</H1>	<img src=\"cid:image\">";
	        //messageBodyPart.setHeader("content-type: text/html", "charset=ISO-8859-1")
	        message.setHeader("content-type", "text/html; charset=ISO-8859-1"); 
	        messageBodyPart.setContent(htmlText, "text/html");
	
	        // add it
	        multipart.addBodyPart(messageBodyPart);
	        
	        if(new java.io.File(sImage).exists()){
		        // second part (the image)
		        messageBodyPart = new MimeBodyPart();
		        DataSource fds = new FileDataSource(sImage);
		        messageBodyPart.setDataHandler(new DataHandler(fds));
		        messageBodyPart.setHeader("Content-ID","<image_logo>");
		
		        // add it
		        multipart.addBodyPart(messageBodyPart);
	        }
	
	        // put everything together
	        message.setContent(multipart);
	
	        transport.connect(MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"),username,password);
	        transport.sendMessage(message,message.getRecipients(Message.RecipientType.TO));
	        transport.close();
	        bSuccess=true;
        }
        catch(Exception e){
        	Debug.print(e.getMessage());
        }
		return bSuccess;
		       
    }
	//sendAttachEmail
    static public void sendAttachEmailWithImages(String smtpServer, String sFrom, String sTo, String sSubject, String sMessage, String sAttachment, String sFileName, String sLogo)
            throws AddressException, MessagingException {
    	try{
			final String username = MedwanQuery.getInstance(false).getConfigString("mailbot.user","openclinic.mailrobot@ict4d.be");
			final String password = MedwanQuery.getInstance(false).getConfigString("mailbot.password","nopass");

			Properties props = new Properties();
			props.put("mail.smtp.auth", "true");
			props.put("mail.smtp.starttls.enable", "true");
			props.put("mail.smtp.host", MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"));
			props.put("mail.smtp.port", MedwanQuery.getInstance(false).getConfigString("mailbot.port","587"));
	        props.put("mail.smtp.user", username);
	        props.put("mail.smtp.password", password);
	        props.put("mail.smtp.ssl.trust", MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"));        

	        Session mailSession = Session.getInstance(props);

	        mailSession.setDebug(MedwanQuery.getInstance(false).getConfigString("Debug").equalsIgnoreCase("On"));
	        Transport transport = mailSession.getTransport("smtp");
	
	        MimeMessage message = new MimeMessage(mailSession);
	        message.setSubject(sSubject);
	        message.setFrom(new InternetAddress(sFrom));	  
	        //message.setSentDate(new java.util.Date());
	        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(sTo,false));
	
	        // This HTML mail have to 2 part, the BODY and the embedded image       
	        MimeMultipart multipart = new MimeMultipart("related");
	
	        // first part  (the html)
	        BodyPart messageBodyPart = new MimeBodyPart();	             
	        String htmlText = sMessage;	    //String htmlText = "<H1>Hello</H1>	<img src=\"cid:image\">";
	        //messageBodyPart.setHeader("content-type: text/html", "charset=ISO-8859-1");
	        messageBodyPart.addHeader("content-type: text/html", "charset=ISO-8859-1");
	        messageBodyPart.setContent(htmlText, "text/html");
	
	        // add it
	        multipart.addBodyPart(messageBodyPart);
	   
	        //second  part: (The Attachment)
	        messageBodyPart = new MimeBodyPart();
	        DataSource fdsAttach = new FileDataSource(sAttachment);
	        messageBodyPart.setDataHandler(new DataHandler(fdsAttach));
	        messageBodyPart.setFileName(sFileName);
	       
	        // add it
	        multipart.addBodyPart(messageBodyPart);
	        
	        // third part (the image)
	        messageBodyPart = new MimeBodyPart();
	        DataSource fds = new FileDataSource(sLogo);
	        messageBodyPart.setDataHandler(new DataHandler(fds));
	        //messageBodyPart.setHeader("Content-ID","<image_logo>");
	        messageBodyPart.addHeader("Content-ID","<image_logo>");
	
	        // add it
	        multipart.addBodyPart(messageBodyPart);
	
	        // put everything together
	        message.setContent(multipart);
	
	        transport.connect(MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"),username,password);
	        transport.sendMessage(message,message.getRecipients(Message.RecipientType.TO));
	        transport.close();
    	}
        catch(Exception e){
        	Debug.print(e.getMessage());
        }
    }	
	//sendAttachEmail
    static public boolean sendAttachEmail(String smtpServer, String sFrom, String sTo, String sSubject, String sMessage, String sAttachment, String sFileName)
            throws AddressException, MessagingException {
    	boolean bSuccess = false;
    	try{
			final String username = MedwanQuery.getInstance(false).getConfigString("mailbot.user","openclinic.mailrobot@ict4d.be");
			final String password = MedwanQuery.getInstance(false).getConfigString("mailbot.password","nopass");
	        
			Properties props = new Properties();
			props.put("mail.smtp.auth", "true");
			props.put("mail.smtp.starttls.enable", "true");
			props.put("mail.smtp.host", MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"));
			props.put("mail.smtp.port", MedwanQuery.getInstance(false).getConfigString("mailbot.port","587"));
	        props.put("mail.smtp.user", username);
	        props.put("mail.smtp.password", password);
	        props.put("mail.smtp.ssl.trust", MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"));        
	
	        Session mailSession = Session.getInstance(props);
	        mailSession.setDebug(MedwanQuery.getInstance(false).getConfigString("Debug").equalsIgnoreCase("On"));
	        Transport transport = mailSession.getTransport("smtp");
	
	        MimeMessage message = new MimeMessage(mailSession);
	        message.setSubject(sSubject);
	        message.setFrom(new InternetAddress(sFrom));	  
	        //message.setSentDate(new java.util.Date());
	        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(sTo,false));
	
	        // This HTML mail have to 2 part, the BODY and the embedded image       
	        MimeMultipart multipart = new MimeMultipart("related");
	
	        // first part  (the html)
	        BodyPart messageBodyPart = new MimeBodyPart();	             
	        String htmlText = sMessage;	    //String htmlText = "<H1>Hello</H1>	<img src=\"cid:image\">";
	        //messageBodyPart.setHeader("content-type: text/html", "charset=ISO-8859-1");
	        //messageBodyPart.addHeader("content-type: text/html", "charset=ISO-8859-1"); //This works on yahoo mail and in earlier mxs mail. now no more in MXS (attach is not visible
	        
	        //message.setHeader("content-type", "text/html; charset=ISO-8859-1"); //in yahoo ok. In MxS: Attachment is visible but error
	        //Problem accessing /service/home/~/Transaction18112011-130314_Tid7259.html. Reason: us-ascii;
	        
	        
	        
	        messageBodyPart.setContent(htmlText, "text/html");
	
	        // add it
	        multipart.addBodyPart(messageBodyPart);
	   
	        //second  part: (The Attachment)
	        messageBodyPart = new MimeBodyPart();
	        DataSource fdsAttach = new FileDataSource(sAttachment);
	        messageBodyPart.setDataHandler(new DataHandler(fdsAttach));
	        messageBodyPart.setFileName(sFileName);
	       
	        // add it
	        multipart.addBodyPart(messageBodyPart);
	        
	         // put everything together
	        //message.setHeader("content-type", "text/html; charset=ISO-8859-1");
	        message.setContent(multipart);
	
	        transport.connect(MedwanQuery.getInstance(false).getConfigString("mailbot.server","smtp.gmail.com"),username,password);
	        transport.sendMessage(message,message.getRecipients(Message.RecipientType.TO));
	        transport.close();
	        bSuccess = true;
    	}
        catch(Exception e){
        	Debug.print(e.getMessage());
        }
    	return bSuccess;
    }
	 
}

