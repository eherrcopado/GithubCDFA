public without sharing class AccountAssociatedLocHandler {
    Public static void OnCreateAccAssociatedLoc(List<AssociatedLocation> newList ){
        List<Account_Associated_Location__c> associatedloc = new List<Account_Associated_Location__c>();
        for(AssociatedLocation asloc : newList){
            Account_Associated_Location__c accloc = new Account_Associated_Location__c();
            accloc.ActiveTo__c = asloc.ActiveTo;
            accloc.Active_From__c = asloc.ActiveFrom;
            accloc.ParentRecordId__c = asloc.ParentRecordId;
            accloc.Payment_Status__c = asloc.Payment_Status__c;
            accloc.Status__c = asloc.Status__c;
            accloc.Type__c =asloc.Type;
            accloc.LocationId__c = asloc.LocationId;
            accloc.Associated_Location__c =asloc.Id;
            accloc.Name = asloc.AssociatedLocationNumber;
            associatedloc.add(accloc);
            
        }
        insert associatedloc;
    }//end of OnCreateAccAssociatedLoc method
    
    Public static void onUpdateAccAssociatedLoc(List<AssociatedLocation> newlist){
        List<Account_Associated_Location__c> associatedlocToUpdate = new List<Account_Associated_Location__c>();
        system.debug(newlist.size()+ ' newlist Size '+newlist);
      
        if(newList.size()>0){
            for(AssociatedLocation asloc2 : newList){
                System.debug('On Update==>');
                List<Account_Associated_Location__c> acclocList = [select Id from Account_Associated_Location__c where Associated_Location__c =:asloc2.Id];  //new Account_Associated_Location__c();
                  if(acclocList.size()==0)
                    {
                    OnCreateAccAssociatedLoc(newlist);
                    }
                if(acclocList.size()>0){
                    for(Account_Associated_Location__c accloc : acclocList){
                        accloc.ActiveTo__c = asloc2.ActiveTo;
                        accloc.Active_From__c = asloc2.ActiveFrom;
                        accloc.ParentRecordId__c = asloc2.ParentRecordId;
                        accloc.Payment_Status__c = asloc2.Payment_Status__c;
                        accloc.Status__c = asloc2.Status__c;
                        accloc.Type__c =asloc2.Type;
                        accloc.LocationId__c = asloc2.LocationId;
                        accloc.Name = asloc2.AssociatedLocationNumber;
                        associatedlocToUpdate.add(accloc); 
                    }
                                       
                }
                
            }
            if(!associatedlocToUpdate.isEmpty()){
                update associatedlocToUpdate;
            }
        }
        
    }
    //End of onUpdateAccAssociatedLoc method
    
    
    Public static void onDeleteAccAssociatedLoc(List<AssociatedLocation> oldList){
        List<Account_Associated_Location__c> associatedlocToDelete = new List<Account_Associated_Location__c>();  
        system.debug('In delete method onDeleteAccAssociatedLoc=');
        
        For(AssociatedLocation asloc1 : oldList){
            system.debug('asloc1.Id=='+asloc1.Id);
            List<Account_Associated_Location__c> asslocoldList =[Select id from Account_Associated_Location__c where Associated_Location__c =: asloc1.id];
            if(asslocoldList.size()>0){
            for(Account_Associated_Location__c ac : asslocoldList){
                associatedlocToDelete.add(ac); 
                system.debug('In for loop of delete method onDeleteAccAssociatedLoc='+ac);
            }
        }
        }
        if(associatedlocToDelete.size() > 0){
            Delete associatedlocToDelete;  
            system.debug('Afte delete method onDeleteAccAssociatedLoc=');
        }
    } 
    // End Of onDeleteAccAssociatedLoc method
    
}