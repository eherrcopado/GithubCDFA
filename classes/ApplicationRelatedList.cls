public with sharing class ApplicationRelatedList {
   
    @AuraEnabled(Cacheable=true)
    public static Map<String,Object> getRecordData( String wireExecutor, String objectApiName){
        Map<String,Object> returnMap = new Map<String, Object>();        
        String userLevel = '';
        String userId = UserInfo.getUserId();
        System.debug('#userId :'+userId);
       // System.debug('*****recordId:'+recordId);
        System.debug('*****objectApiName:'+objectApiName);
        List<Contact> cont = new List<Contact>();
        
        if(objectApiName == 'Contact'){
     
           cont = [SELECT Id,Name FROM Contact];
                                                returnMap.put('cont', cont);
                System.debug('####cont:'+cont);
         }
                                            
           String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
           returnMap.put('URL',baseURL);
        System.debug('#cont :'+cont);
        system.debug('#returnMap :'+returnMap);
        return returnMap; 
    }

}