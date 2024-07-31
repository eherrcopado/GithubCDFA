public Without Sharing class PaymentResponseHandler {
    
    Public void  Paymentresponse(List<Payment_Response__c> PaymentResponseList){
        System.debug('PaymentResponseList-->  ' +PaymentResponseList);
        Id RenaccId;
        String RenewAgencyID;
        List<Id> AccountId = New List<Id>();
        List<Id> PaymentRequestId = New List<Id>();
        List<Account> updateAccRenewalProcess = New List<Account>();
        List<Account> updateRenAccRenewalProcess = New List<Account>();
        System.debug('PaymentResponseList-->  ' +PaymentResponseList);
        For(Payment_Response__c Pr :PaymentResponseList){
            if(Pr.Status__c == 'Success'){
                PaymentRequestId.add(Pr.Payment_Request__c);
            } 
            //PaymentRequestId.add(Pr.Payment_Request__c);
        }
        If(!PaymentRequestId.isEmpty()){
            System.debug('PaymentRequestId-->  ' +PaymentRequestId);
            For (Payment_Request__c PayReq : [Select Id, Status__c, Account__c from Payment_Request__c Where Id=:PaymentRequestId]){                  
                AccountId.add(PayReq.Account__c);         
            }
            
            If(!AccountId.isEmpty()){ 
                Id RenewalRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
                Id ApplicationRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Application').getRecordTypeId();
                List<Account> renewalAccountList = new List<Account>([select Id,Name from Account where Original_Account_Id__c= :AccountId AND (RecordTypeID = :RenewalRecordTypeID OR  RecordTypeID = :ApplicationRecordTypeID)]);
                if(renewalAccountList.size()>0){
                    For(Account Acc : [Select id, Renewal_Process__c from Account Where id=:AccountId])
                    {   
                        system.debug('Acc 1:'+Acc.ID);
                        system.debug('Status 1:'+Acc.Renewal_Process__c);
                        if(Acc.Renewal_Process__c !='Draft' && Acc.Renewal_Process__c !=' '){
                            Acc.Renewal_Process__c = 'Pending Approval';
                            updateAccRenewalProcess.add(Acc);
                        }
                        System.debug('Updated Account');
                    } 
                    
                    For(Account RenAcc : [Select id, Original_Account_Id__c, Renewal_Process__c from Account Where Original_Account_Id__c=:AccountId ORDER BY CreatedDate DESC limit 1]){
                        system.debug('RenAcc  1:'+RenAcc.ID);
                        system.debug('Status 2:'+RenAcc.Renewal_Process__c);
                        if(RenAcc.Renewal_Process__c !='Draft' && RenAcc.Renewal_Process__c !=' '){
                            RenAcc.Renewal_Process__c = 'Pending Approval';
                            RenaccId = RenAcc.id;
                            updateRenAccRenewalProcess.add(RenAcc);
                        }
                        System.debug('Updated RenAccount--->'+RenAcc.ID);
                    }
                    System.debug('updateAccRenewalProcess-->' +updateAccRenewalProcess);   
                    System.debug('updateAccRenewalProcess-->' +updateRenAccRenewalProcess); 
                    Update updateAccRenewalProcess;     
                    Update updateRenAccRenewalProcess;
                   System.debug('RenaccId in PaymentResponseHandler=>' +RenaccId);
                    if(RenaccId != null){
                        RenewAgencyID  = Id.valueOf(RenaccId);
                        RegulatoryTxn.UpdatePaymentTxnDone(RenewAgencyID);                
                    } 
                }
                    
            }
            
        }      
        
    }
    
}