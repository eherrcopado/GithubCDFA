public class EmailMessagingHelper {

    public static void sendEmail (
        String[] toAddresses, 
        String[] ccAddresses, 
        String replyToAddress,
        String senderDisplayName,
        String orgWideEmailAddressId,
        String subject,
        String plainTextBody,
        String htmlBody,
        Boolean bccSender,
        Boolean useSignature
	) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        
        if (toAddresses != null && !toAddresses.isEmpty ()) {
	        mail.setToAddresses(toAddresses);            
        }
        if (ccAddresses != null && !ccAddresses.isEmpty ()) {
	        mail.setCcAddresses(ccAddresses);
        }
		if (String.isNotBlank(replyToAddress)) {
	        mail.setReplyTo(replyToAddress);
        }
        
        if (String.isNotBlank(orgWideEmailAddressId)) {
	        mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        } else {
        	if (String.isNotBlank(senderDisplayName)) {
                mail.setSenderDisplayName(senderDisplayName);
            } else {
                mail.setSenderDisplayName('Support');
            }     
        }
        
		         
        mail.setBccSender(bccSender);
        mail.setUseSignature(useSignature); 

        mail.setSubject(subject);         
        mail.setPlainTextBody(plainTextBody);
		mail.setHtmlBody(htmlBody); 
 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}