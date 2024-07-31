public without sharing class NewAgencyController {
    
    //Wrapper class to return for Business info form
    public class UserAccountWrapper {
        @AuraEnabled
        public Id accId;
        @AuraEnabled
        public Account renewalAccount;
        @AuraEnabled
        public String conFName;
        @AuraEnabled
        public String conLName;
    }
    
    @auraenabled//(cacheable=true)
    public static UserAccountWrapper createNewAccountRecord(){  
        Account acc = new Account(); 
        BusinessLicense bl = new BusinessLicense(); 
        UserAccountWrapper uaw = new UserAccountWrapper();
        Try{
            Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Application').getRecordTypeId();
            User userrecord = [SELECT Id,ContactId,Contact.OwnerId from User where Id =: UserInfo.getUserId()];
            List<Account> newAcc= [SELECT Id, Name,AccountNumber,Legal_Entity__c,DBA_Name__c,Phone,Email__c,BillingStreet,
                                   BillingCity,BillingState,BillingCountry,BillingPostalCode,Status__c,Registration_Number__c,
                                   RecordTypeId,OwnerId,Original_Account_Id__c 
                                   FROM Account 
                                   WHERE RecordTypeId=:accountRecordTypeId AND //OwnerId=:userrecord.Contact.OwnerId];
                                   Id IN (select AccountId from contact where id=:userrecord.ContactId)];
            system.debug('newAcc List --> '+newAcc);
            if(newAcc.isEmpty()){
                
                DateTime now = System.now();
                acc.name='New Agency';
                acc.Legal_Entity__c='Corporation';
                acc.Status__c='Active';  
                acc.RecordTypeId=accountRecordTypeId;            
                acc.OwnerId = userrecord.Contact.OwnerId;  
                acc.Renewal_Process__c='Draft';//registration status field
                insert acc;
                acc.Original_Account_Id__c = acc.Id;
                update acc;
                
                //update account assigned to portal user from generic to newly created Application Account
                User lgnUser = PaymentGatewayUtility.getUserInfo(UserInfo.getUserId());
                String usrAcctId=lgnUser.Contact.AccountID;
                System.debug('usrAcctId in NEWAGENCY==>'+usrAcctId);
                lgnUser.Contact.AccountID=acc.Id;
                update lgnUser.Contact;
                 
                 //Inserting Buisiness License record for account
                bl.Name = 'BL-'+acc.Name;
                //bl.RegulatoryAuthorizationTypeId = raType.Id;//111
                bl.PeriodStart = system.today()-1;
                bl.PeriodEnd = system.today()+30;
                bl.AccountId = acc.Id;
                bl.ContactId = userrecord.ContactId;
                bl.status = 'Active';
                insert bl;
                
                
                uaw.accId = acc.Id;
                uaw.renewalAccount = acc;
                
            }else{
                acc.Id=newAcc[0].Id;
                uaw.accId = acc.Id;
                uaw.renewalAccount = newAcc[0];
            }
            system.debug('Account Id ----> '+acc.Id);
            
            User curUser = [SELECT Id,contact.FirstName, contact.LastName, contact.AccountId,
                            Contact.Account.Registration_Number__c FROM User
                            WHERE Id=:UserInfo.getUserId()];
            
            //checking user's linked account, if it is not to newly created Application account then assigning it.
            if(curUser.contact.AccountId!=acc.Id){
                curUser.contact.AccountId=acc.Id;
                update curUser.contact;
            }

            uaw.conFName = curUser.contact.FirstName;
            uaw.conLName = curUser.contact.LastName;
            System.debug('uaw:::::'+uaw);

            List<AccountContactRelation> agentsACRList = [SELECT Id,contactId,accountId FROM AccountContactRelation 
                                                     WHERE account.Name='Agents' AND contactId=:curUser.contact.Id];
            delete agentsACRList;
            
        }catch(Exception e){
            system.debug('Type==> '+e.getTypeName());
            system.debug('Line==> '+e.getLineNumber());
            system.debug('Cause==> '+e.getCause());
            system.debug('Message==> '+e.getMessage());
        }
        system.debug(uaw);
        return uaw;
    }

    public Static void submitApprovalNewRegistration(List<Account> accList){
        String Renewal_Process;
        Id accountRecordTypeId;
        Id accountId,ownerId;
        Id RecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Application').getRecordTypeId();
        System.debug('accList'+accList);
        for(Account ac : accList){          
            Renewal_Process = ac.Renewal_Process__c;
            accountRecordTypeId = ac.RecordTypeId;
            accountId = ac.Id;
            ownerId = ac.OwnerId;
        }
        
        if(Renewal_Process == 'Pending Approval' && accountRecordTypeId == RecTypeId) {           
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments('Account Submitted for approval');
            approvalRequest.setObjectId(accountId);
            approvalRequest.setSubmitterId(ownerId); 
            approvalRequest.setSkipEntryCriteria(true);
            Approval.ProcessResult approvalResult = Approval.process(approvalRequest);  
        } 
    }    
}