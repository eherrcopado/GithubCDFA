trigger ReconcileTrigger on Account (after update, After Insert,before update) {  
    if(Trigger.isBefore && Trigger.isUpdate){
      ReconcileTriggerHandler.beforeUpdateMethod(Trigger.New,Trigger.NewMap,Trigger.Old,Trigger.OldMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
     ReconcileTriggerHandler.approvalMethod(Trigger.New);
    }
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        ApplicationEmailClass.sendEmail(Trigger.New);
    }
    
    /*
   // Triggers_Enable__mdt triggerisActive = Triggers_Enable__mdt.getInstance('ReconcileTrigger');   
    //system.debug('triggerisActive >> :'+triggerisActive); 
    //if(triggerisActive.Is_Active__c == TRUE){
      //  system.debug('triggerisActive >> :'+triggerisActive); 
        Id RenewalRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        String AccountID;
        List<Account>updateAccountList = new List<Account>();
        For(Account Acc: Trigger.new) {
            if(Acc.RecordTypeId == RenewalRecordTypeID && Acc.Renewal_Process__c == 'Approved'){
                AccountID = String.valueOf(Acc.id);
                System.debug('I am calling ReconcileAgency' +AccountID);
                // 23-08-2022
                List<Account> renewalAccountList = new List<Account>([select Id,Original_Account_Id__c from Account where Id = :Acc.id limit 1]);
                if(renewalAccountList.size()>0){
                    List<Account> renewalAccountList2 = [Select Renewal_Process__c, id from Account Where Id=:renewalAccountList[0].Original_Account_Id__c];
                    if(renewalAccountList2.size()>0){
                        renewalAccountList2[0].Renewal_Process__c = 'Approved';
                        update renewalAccountList2;
                    }
                }           
                ReconcileAgency.Renew(AccountID);   
            }
           
                if(Acc.Renewal_Process__c == 'Pending Approval' && Acc.RecordTypeId == RenewalRecordTypeID) {           
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    approvalRequest.setComments('Account Submitted for approval');
                    approvalRequest.setObjectId(Acc.Id);
                    approvalRequest.setSubmitterId(Acc.OwnerId); 
                    approvalRequest.setSkipEntryCriteria(true);
                    Approval.ProcessResult approvalResult = Approval.process(approvalRequest);            
                    
                } 
                
            system.debug('Rejected 1 '+ Acc.Renewal_Process__c);
            system.debug(Acc.RecordTypeId + 'Rejected 1' + RenewalRecordTypeID);
            // Renewal Reject
            if(Acc.RecordTypeId == RenewalRecordTypeID && Acc.Renewal_Process__c == 'Rejected'){
                system.debug('Rejected 2');
                Id RenewalRejectRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal_Rejected').getRecordTypeId();
                Account ac = new Account();
                ac.id = Acc.Id;
                ac.RecordTypeId = RenewalRejectRecordTypeID;
                updateAccountList.add(ac);
                List<Account> renewalAccountList = new List<Account>([select Id,Original_Account_Id__c from Account where Id = :Acc.id limit 1]);
                if(renewalAccountList.size()>0){
                    List<Account> renewalAccountList2 = [Select Renewal_Process__c, id from Account Where Id=:renewalAccountList[0].Original_Account_Id__c];
                    if(renewalAccountList2.size()>0){
                        renewalAccountList2[0].Renewal_Process__c = 'Rejected';
                        update renewalAccountList2;
                    }
                }  
            }     
       // }
        if(!updateAccountList.isEmpty()){
            system.debug('Rejected 3');
            update updateAccountList;
        }
    }
    */
}