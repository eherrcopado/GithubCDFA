trigger triggerOnContact on Contact(before insert, before update, after update, after insert, after delete, after undelete) {
    
    // all Logic moved on AccountContactRelation RSAacr trigger so everything is commented. (2 Nov 2022.)
    
    // if we change the trigger name, please modify the custom metadata and below statement.
    //Triggers_Enable__mdt triggerisActive = Triggers_Enable__mdt.getInstance('triggerOnContact');
   
    //if(triggerisActive.Is_Active__c == TRUE){
    /* //commented to move logic to AccountContact relation trigger (RSAacr)
        if(trigger.isBefore){
            if(trigger.isInsert || trigger.isupdate){
                List<Contact> conList = trigger.new;
                for(Contact con: conList){
                    if(con.Status__c != '' && con.Status__c != 'Inactive'){
                        con.Status__c='Active';
                        con.Start_Date__c = System.Today();
                    }
                    if(con.Status__c =='Inactive'){
                        con.End_Date__c = System.Today();
                    }
                } 
            }
        }
        if(trigger.isAfter){
            if(trigger.isInsert){
               system.debug('is After');
                contactTriggerHandler.onContactInsert(trigger.new);
            }
            if(trigger.isDelete){
                system.debug('is delete');
                contactTriggerHandler.onContactdelete(trigger.old);
            }
            if(trigger.isUpdate){
                system.debug('is update');
                contactTriggerHandler.onContactUpdate(trigger.new);
            }
        }
    */
   // }
}