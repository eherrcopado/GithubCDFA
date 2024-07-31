trigger createUserFromContact on Contact (after update) {
    Triggers_Enable__mdt triggerisActive = Triggers_Enable__mdt.getInstance('createUserFromContact');
    if(triggerisActive.Is_Active__c == TRUE){
        Set<Id> contactIds = new Set<Id>();
        for(Contact c: Trigger.New){
           if(c.CDFA_User_Status__c =='Activated'){
               contactIds.add(c.id);
           }
        }
        if(contactIds.size() > 0){
            CreateUserHandler.createUserFromContact(contactIds);
        }
    }
}