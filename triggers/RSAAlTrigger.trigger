trigger RSAAlTrigger on AssociatedLocation (before insert, after insert, After Update, After Delete, Before Delete) {
    
    Triggers_Enable__mdt triggerisActive = Triggers_Enable__mdt.getInstance('RSAAlTrigger');   
    if(triggerisActive.Is_Active__c == TRUE){
        //if(StopRecursiveHandler.run == FALSE){    
        //    StopRecursiveHandler.run = TRUE;
        //}
            if(Trigger.isBefore){
                if(Trigger.isInsert){
                    RSAAlTriggerHandler.beforeInsertRSAAl(Trigger.New);
                }
                
                if(Trigger.isDelete){
                    AccountAssociatedLocHandler.onDeleteAccAssociatedLoc(trigger.old);
                    RSAAlTriggerHandler.beforeDeleteRSAAl(Trigger.Old,Trigger.OldMap);
                }
            }
            
            if(Trigger.isAfter){
                if(Trigger.isInsert){
                    system.debug('after insert in RSAAL');
                    AccountAssociatedLocHandler.onCreateAccAssociatedLoc(trigger.new);
                    RSAAlTriggerHandler.afterInsertRSAAl(Trigger.New,Trigger.NewMap);
                }
                if(Trigger.isUpdate){
                    AccountAssociatedLocHandler.onCreateAccAssociatedLoc(trigger.new);
                    RSAAlTriggerHandler.afterUpdateRSAAl(Trigger.New,Trigger.NewMap,Trigger.Old,Trigger.OldMap);
                }
                if(Trigger.isDelete){
                    RSAAlTriggerHandler.afterDeleteRSAAl(Trigger.Old,Trigger.OldMap);
                }
                
            }
       
    }
}