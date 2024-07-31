public without sharing class RSAContactViewCtrl {
    
    @AuraEnabled
    public static void updateContact(String contactStr) {
        try {
            Contact con = (Contact) JSON.deserialize(contactStr, Contact.Class);
            update con;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}