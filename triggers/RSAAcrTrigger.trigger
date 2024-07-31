trigger RSAAcrTrigger on AccountContactRelation (before insert,before update, after insert, after update, before delete,after Delete) {
    Triggers_Enable__mdt triggerisActive = Triggers_Enable__mdt.getInstance('RSAAcrTrigger');   
    if(triggerisActive.Is_Active__c == TRUE){
       // if(StopRecursiveHandler.run == FALSE){    
       //     StopRecursiveHandler.run = TRUE;
       // }
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                contactTriggerHandler.beforeInsertMethodCTH(Trigger.New);
                AccountContactRelationHandler.beforeInsert(Trigger.New);
            }
            if(Trigger.isUpdate){
                for(AccountContactRelation con:Trigger.New){
                    contactTriggerHandler.beforeupdateMethodCTH(Trigger.New, Trigger.NewMap, Trigger.Old, Trigger.OldMap);
                }
            }
            
            if(Trigger.isDelete){
                AccountContactRelationHandler.beforeDelete(Trigger.Old,Trigger.OldMap);
            }
        }
        
        
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                system.debug('Inside Trigger');
                AccountContactRelationHandler.afterInsert(Trigger.New,Trigger.NewMap);
                contactTriggerHandler.afterInsertMethodCTH(Trigger.New,Trigger.NewMap);
                
            }
            if(Trigger.isUpdate){
                system.debug('Inside Trigger');
                AccountContactRelationHandler.afterUpdate(Trigger.New,Trigger.NewMap,Trigger.Old,Trigger.OldMap);
                contactTriggerHandler.afterUpdateMethodCTH(Trigger.New,Trigger.NewMap,Trigger.Old,Trigger.OldMap);
            }
            if(Trigger.isDelete){
                system.debug('Inside Trigger');
                contactTriggerHandler.afterDeleteMethodCTH(Trigger.Old,Trigger.OldMap);
            }
            
        }
    }
}