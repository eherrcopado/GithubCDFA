public without sharing class RSASendEMailCtrl {
    @AuraEnabled
    public static Map<String,object> getEmailRecord() {
        Map<String,object> returnMap = new Map<String,Object>();
        Key_Value_Pair__mdt supportEmail = [select Id,value__c,Label from Key_Value_Pair__mdt WHERE Label='RSA Suppport To Email'];
        returnMap.put('supportEmail', supportEmail);
        return returnMap;
    }

    @AuraEnabled
    public static void sendEmail(String subject, String body) {
        try{
            List<Key_Value_Pair__mdt> supportEmails = 
                [SELECT Id,value__c,Label 
                FROM Key_Value_Pair__mdt 
                WHERE Label in('RSA Suppport To Email')];
            String toEmail;
            for(Key_Value_Pair__mdt keyValPair : supportEmails) {
                    toEmail = keyValPair.value__c;
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {toEmail};
            mail.setToAddresses(toAddresses);
            mail.setSubject(subject);
            mail.setHtmlBody('<h1>'+ body + '</h1>');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
}