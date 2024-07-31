public without sharing class RelatedAccountCtrl {
    @AuraEnabled
    public static Map<String,Object> getCurrentConstituentInfo(String contactId){
        system.debug('contactId----'+contactId);
        Map<String,Object> returnMap = new Map<String,Object>();
        List<Contact> accList = [select Id,Account.Name from contact where Id=:contactId AND Account.Status__c ='Active'];
        returnMap.put('accList',accList);
        return returnMap;
    }
}