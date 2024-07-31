public without sharing class RenewalAgencyController {
    //public enum objectType {AGENT, LOCATION, DEVICE, AGNREGNUM}
    public class ContactWrapper
    {
        @auraenabled
        public string Name{get;set;}
        @auraenabled
        public string Phone{get;set;}
        @auraenabled
        public Id conId{get;set;}
    }
    //Wrapper class to return for Business info form
    public class UserAccountWrapper {
        @AuraEnabled
        public Account renewalAccount;
        @AuraEnabled
        public String conFName;
        @AuraEnabled
        public String conLName;
    }
    
    @auraenabled
    public static UserAccountWrapper createRenewalAgency(String originalAccountId){
        System.debug('In createRenewalAgency originalAccountId'+originalAccountId); 
        User curUser = [SELECT Id,contact.FirstName, contact.LastName,
                        Contact.Account.Registration_Number__c FROM User
                        WHERE Id=:UserInfo.getUserId()];    
        Account renAccount = createRenewalAccountRecord(originalAccountId);    
        system.debug('renAccount*****'+renAccount);
        UserAccountWrapper uaw = new UserAccountWrapper();
        uaw.renewalAccount = renAccount;
        uaw.conFName = curUser.contact.FirstName;
        uaw.conLName = curUser.contact.LastName;
        System.debug('uaw:::::'+uaw);
        return uaw;
        // return renewalAccountDetails ;
    }
    
    //method for update currrent form status Picklist Values as Form A Completed, Form B Completed... on Renewal Agency Object 
    @auraenabled
    public static void updateAgencyRenewalFormStatus(String originalAccountId, String statusValue, string renewalAccId){
        System.debug('originalAccountId updateAgencyRenewalFormStatus===>'+originalAccountId);
        System.debug('statusValue updateAgencyRenewalFormStatus===>'+statusValue);

        //List<Agency_Renewal__c> arl = [select id from Agency_Renewal__c where Account__c =: originalAccountId];
        List<Agency_Renewal__c> arl = [select id from Agency_Renewal__c where Renewal_Account__c =: renewalAccId ];
        if(arl.size()>0){
            system.debug('agencyId------- '+arl[0].Id);
            Agency_Renewal__c arRec =new Agency_Renewal__c();
            arRec.Id= arl[0].Id;
            arRec.Current_Form_Status__c = statusValue;
            update arRec;
        }else{
            system.debug('no agency------- ');
            Agency_Renewal__c arNew=new Agency_Renewal__c();              
            arNew.Created_Date__c=DateTime.now();
            arNew.Status__c = 'In Progress';
            arNew.Current_Form_Status__c = statusValue;
            arNew.Renewal_Account__c = renewalAccId;
            insert arNew; 
        }
    }// EO updateAgencyRenewalFormStatus
    
    private static Account createRenewalAccountRecord(String originalAccountId){
         Id RenewalRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        System.debug('In createRenewalAccountRecord originalAccountId'+originalAccountId);
        List<Account> accountsList = new List<Account>([select Id, Name,AccountNumber,DBA_Name__c,Legal_Entity__c,RecordTypeId,Active__c,Registration_Number__c,
                                                        Renewal_Process__c,Parent_Account_Id__c,Original_Account_Id__c,
                                                        BillingAddress,Phone,Email__c,BillingStreet,BillingCity, BillingState, BillingPostalCode,
                                                        BillingCountry,OwnerId,Renewal_Registration_Number__c,Renewal_Registration__c                                           
                                                        from Account where Id= :originalAccountId limit 1]);
        
        List<Account> renewalAccountList = new List<Account>([select Id,Name,AccountNumber,DBA_Name__c,Legal_Entity__c,RecordTypeId,Active__c,Registration_Number__c,
                                                              Renewal_Process__c,Parent_Account_Id__c,Original_Account_Id__c,
                                                              BillingAddress,Phone,Email__c,BillingStreet,BillingCity, BillingState, BillingPostalCode,
                                                              BillingCountry,OwnerId,Renewal_Registration_Number__c,Renewal_Registration__c                                           
                                                              from Account where Original_Account_Id__c= :originalAccountId AND RecordTypeID = :RenewalRecordTypeID limit 1]);
        
        system.debug('<----originalAccountId--> '+originalAccountId);
        updateRenewalProcess(originalAccountId);
        system.debug(accountsList.size()+'<----accountsList.size && renewalAccountList.size--> '+renewalAccountList.size());                                                  
        if(accountsList.size() > 0 && renewalAccountList.size() == 0){
            system.debug('<----if block--> ');
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            //Id RenewalRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            Account renewalAccount = new Account();
            renewalAccount.Name = accountsList.get(0).Name;
            renewalAccount.AccountNumber = accountsList.get(0).AccountNumber;
            // renewalAccount.RecordTypeId = accountsList.get(0).RecordTypeId;
            // renewalAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            renewalAccount.RecordTypeID = RenewalRecordTypeID;
            renewalAccount.Active__c = accountsList.get(0).Active__c;
            // renewalAccount.Registration_Number__c = accountsList.get(0).Registration_Number__c;
            renewalAccount.Renewal_Process__c = 'Draft';
            renewalAccount.Renewal_Registration_Number__c = accountsList.get(0).Registration_Number__c;
            renewalAccount.Original_Account_Id__c = originalAccountId;
            renewalAccount.DBA_Name__c=accountsList.get(0).DBA_Name__c;
            renewalAccount.Legal_Entity__c=accountsList.get(0).Legal_Entity__c;
            renewalAccount.BillingStreet=accountsList.get(0).BillingStreet;
            renewalAccount.BillingCity=accountsList.get(0).BillingCity;
            renewalAccount.BillingState=accountsList.get(0).BillingState;
            renewalAccount.BillingPostalCode=accountsList.get(0).BillingPostalCode;
            renewalAccount.BillingCountry=accountsList.get(0).BillingCountry;
            renewalAccount.Phone=accountsList.get(0).Phone;
            renewalAccount.Email__c=accountsList.get(0).Email__c;
            renewalAccount.OwnerId=accountsList.get(0).OwnerId;
            Database.SaveResult insertSaveResult = Database.insert(renewalAccount, dml);
            System.debug('insertSaveResult-----------> '+insertSaveResult);
            
            System.debug('renewalAccount:::::'+renewalAccount);
            createContactsForRenewalRecord(originalAccountId,renewalAccount);
            createAssetsForRenewalRecord(originalAccountId,renewalAccount);
            createAssociatedLocation(originalAccountId,renewalAccount); //RenewalAssociatedLocationController.createAssociatedLocation(originalAccountId,renewalAccount);
            return renewalAccount;
        }else{
            system.debug('<----else  block--> '+renewalAccountList.get(0));
            return renewalAccountList.get(0);
        } 
    }
    @AuraEnabled
    public static Account updateRenewalAgency(String Id,String phone, String email,
                                              String street, String city, String state,
                                              String country, String zipcode, string accName, String entity, String dbaName) {
                                                  Account accountObj= new Account(Id=Id);
                                                  accountObj.Phone = phone;
                                                  accountObj.Email__c = email;
                                                  accountObj.BillingStreet = street;
                                                  accountObj.BillingCity= city;
                                                  accountObj.BillingState= state;
                                                  accountObj.BillingCountry= country;
                                                  accountObj.BillingPostalCode= zipcode;
                                                   accountObj.Name=accName;
                                                  accountObj.Legal_Entity__c = entity;
                                                  accountObj.DBA_Name__c = dbaName;
                                                  try {
                                                      
                                                      Database.DMLOptions dml = new Database.DMLOptions(); 
                                                      dml.DuplicateRuleHeader.allowSave = true;
                                                      dml.DuplicateRuleHeader.runAsCurrentUser = true;
                                                      Database.SaveResult updateSaveResult = Database.update(accountObj, dml);
                                                      
                                                      if (updateSaveResult.isSuccess()) {
                                                          // Operation was successful, so get the ID of the record that was processed
                                                          System.debug('Successfully updated account. Account ID: ' );
                                                      }
                                                      else {
                                                          // Operation failed, so get all errors                
                                                          for(Database.Error err : updateSaveResult.getErrors()) {
                                                              System.debug('The following error has occurred.');                    
                                                              System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                                              System.debug('Account fields that affected this error: ' + err.getFields());
                                                          }
                                                          
                                                      }
                                                      
                                                  } catch (Exception exp) { 
                                                      system.debug('exp:::::'+exp.getMessage());
                                                  }
          // Added Query to Return Accurate Updated Account Data By QualApps[130897]
          List<Account> accList = [	SELECT Id,Name,BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,
                                 	Email__c,Legal_Entity__c,DBA_Name__c,Phone,Registration_Number__c,OwnerId FROM Account
                                	WHERE Id =: Id LIMIT 1 ];
                                                  return accList[0];
                  
                                              }
    
    
    private static void createContactsForRenewalRecord(String originalAccountId,Account renewalAccount){
        System.debug('Inside ContactCreateMethod');
        List<Contact> cons = new List<Contact>();
        List<AccountContactRelation> accountContactRelationList = new List<AccountContactRelation>();
        system.debug('originalAccountId ---> '+originalAccountId);
        List<Contact> conList = [select Id,Name,LastName,License_No__c,RecordType.DeveloperName,AccountId,Department,
                                 Description,Email,Fax,MobilePhone,Phone 
                                 FROM Contact where RecordType.DeveloperName IN ('RSAAgent','RSAContact') And Id in 
                                 (SELECT ContactId FROM AccountContactRelation WHERE AccountId = :originalAccountId AND (Status__c = 'Active' OR Status__c = 'Pending Payment'))];
        system.debug('conList size 143---> '+conList.size());
        
        for(Contact c : conList)
        {
            AccountContactRelation accCon =new AccountContactRelation();
            accCon.AccountId = renewalAccount.Id;
            accCon.ContactId = c.Id;
            accCon.Status__c = 'Active';
            accountContactRelationList.add(accCon);
        }
        System.debug('createContactsForRenewalRecord--->'+accountContactRelationList.size());
        if(accountContactRelationList.size()>0){
            Database.SaveResult[] insertSaveResult = Database.insert(accountContactRelationList, true); 
            System.debug('createContactsForRenewalRecord--->'+insertSaveResult);
            //insert accountContactRelationList;
        }
    }
    
    private static void createAssetsForRenewalRecord(String originalAccountId,Account renewalAccount){
        System.debug('Inside ContactCreateMethod');
        List<AccountContactRelation> accconList = new List<AccountContactRelation>();
        List<Asset> assetsList  = new List<Asset>();
        for(Asset a : [select Name,AccountId,Device_Type__c,Product2Id,Description,Other_Device_Comments__c 
                       from Asset where AccountId = :originalAccountId]) 
        {         
            Asset asset = new Asset();
            asset.Name = a.Name ;
            asset.Device_Type__c = a.Device_Type__c;
            asset.Product2Id = a.Product2Id; // 26-Aug -- ProductId was not getting populated in the renewal record, so this is added.
             asset.Other_Device_Comments__c = a.Other_Device_Comments__c;
            asset.Description = a.Description;
            asset.AccountId=renewalAccount.Id;
            assetsList.add(asset);
        }
        if(assetsList.size() > 0){
            insert assetsList;  
        }
    }
    
    
    
    
    @AuraEnabled
    public static Integer getRecCount(string AgencyID, string sObj ){ 
        Integer iRecCnt = 0;
        switch on sObj{
            when 'AGENT'{ //Agent Count
                Id RSAAgentRecordTypeId = SObjectType.contact.getRecordTypeInfosByDeveloperName().get('RSAAgent').getRecordTypeId();                    
                //iRecCnt = [SELECT count() FROM Contact WHERE AccountID =: AgencyID];
                //iRecCnt = [SELECT count() FROM AccountContactRelation WHERE AccountID =: AgencyID];
                
                iRecCnt = [ SELECT count() 
                           FROM AccountContactRelation 
                           WHERE AccountID =: AgencyID 
                           AND contact.RecordTypeId=: RSAAgentRecordTypeId 
                           AND contact.Status__c= 'Active' AND (status__c='Active' OR status__c='Pending Payment') //''
                          ];
                system.debug('iRecCnt==>'+iRecCnt);            
            }  
            when 'LOCATION'{ //Location Count        
                iRecCnt = [SELECT count() FROM AssociatedLocation WHERE ParentRecordId = :AgencyID];
                //iRecCnt = [SELECT count() FROM Contact WHERE AccountID =: AgencyID];
                //iRecCnt= iRecCnt + 10;
            }             
        }
        return iRecCnt;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getInitialData(string AgencyID, string sType){ 
        system.debug('Initial '+sType + ' ID ' + AgencyID);      
        List<sObject>ObjList = new List<sObject>();
        switch on sType{
            when 'AGENT'{                      
                ObjList = [Select Id, Name, Phone from Contact WHERE AccountId =: AgencyID];
            }
            when 'RENEWAGENCY'{                      
                //ObjList = [SELECT Id, Original_Account_Id__c, name, Status__c FROM Account WHERE Id =: AgencyID AND RecordType.name = 'Renewal' and Status__c = 'Active' LIMIT 1];
                ObjList = [SELECT Id, Original_Account_Id__c, name, Status__c FROM Account WHERE Id =: AgencyID AND (RecordType.name = 'Renewal'OR RecordType.name = 'Application') LIMIT 1];  
            }   
            when 'AGNREGNUM'{  
                system.debug('Final SELECT Id, Registration_Number__c FROM Account WHERE Id = ' + AgencyID);                    
                ObjList = [SELECT Id, Registration_Number__c FROM Account WHERE Id =: AgencyID];
            } 
            when 'DEVICE'{                
                //ObjList = [Select Id, Name, AccountID, SerialNumber from Asset WHERE AccountId =: AgencyID];
                ObjList = [select Id, name, device_type__c from Asset where AccountId =: AgencyID And (Device_Type__c ='Weighing' or Device_Type__c ='Measuring')];
            }
            when 'ACCAGENT'{                      
                //ObjList = [SELECT ContactId, Contact.Name FROM AccountContactRelation WHERE AccountId =: AgencyID AND (status__c = 'Active' OR status__c = 'Pending Payment') ];
            ObjList = [SELECT ContactId, Contact.Name FROM AccountContactRelation 
                       WHERE AccountId =: AgencyID AND 
                       (status__c = 'Active' OR status__c = 'Pending Payment') 
                       AND Contact.RecordType.DeveloperName='RSAAgent'];
            }
            when 'ACCLOCATION'{                      
                ObjList = [SELECT LocationId, Location.Name, Type FROM AssociatedLocation where ParentRecordId =: AgencyID];
            }
            when 'ACCDEVICE'{                      
                ObjList = [SELECT Product2Id from Asset where AccountId =: AgencyID And (Device_Type__c ='Weighing' or Device_Type__c ='Measuring')];
            }
            when 'BUSLIC'{                      
                ObjList = [Select Id, Name, AccountId, Status from BusinessLicense Where AccountId =: AgencyID AND Status = 'Active'];
            }
            when 'REGTXN'{                      
                ObjList = [SELECT id, status FROM RegulatoryTrxnFee where Renewal_Account_Id__c =: AgencyID];
                system.debug('REGTXN ObjList in RenewealAgencyController==>'+ObjList);
            }
            when 'REGTXNITEM'{                      
                ObjList = [SELECT id, Status__c FROM RegulatoryTrxnFeeitem where RegulatoryTrxnFeeId =: AgencyID];
            }
            when 'RENACCPMTREQ'{                      
                ObjList = [SELECT Ren_Acc_id__c, Account__c, Id FROM Payment_Request__c where id =: AgencyID];
            }
            

        }        
        
        return ObjList;
    }

    public static String getBusLicenseID(string AgencyID){
        String sBusLicID;
        try{
            List<sObject> RenewAgency = new List<sObject>();
            System.debug('RenewAgency ' + RenewAgency);
            RenewAgency = RenewalAgencyController.getInitialData(AgencyID, 'BUSLIC');
            system.debug('RenewAgency ==>' + JSON.serialize(RenewAgency));
            if(!RenewAgency.isEmpty()){
                sBusLicID = (String)RenewAgency[0].get('Id');
            }
        } catch(Exception e) { 
            system.debug('Exception ReconcilieAgency.CheckRenewAgency' + e.getMessage());
            return '';
        }
        System.debug('sBusLicID Existing ID ' + sBusLicID);
        return sBusLicID;
    }

    public static String getRegTxnFee(string AgencyID){
        String sRegTxnID;
        system.debug('Inside ReconcilieAgency.getRegTxnFee');
        try{
            List<sObject> RegTxn = new List<sObject>();
            RegTxn = RenewalAgencyController.getInitialData(AgencyID, 'REGTXN');
            system.debug('REGTXN ==>' + JSON.serialize(RegTxn));
            if(!RegTxn.isEmpty()){
                sRegTxnID = (String)RegTxn[0].get('Id');
            }
        } catch(Exception e) { 
            system.debug('Exception ReconcilieAgency.getRegTxnFee' + e.getMessage());
            return '';
        }
        system.debug('sRegTxnID '+sRegTxnID);
        return sRegTxnID;
    }

    public static String getRenAccfromPmtReq(string ReqId){
        String sRegTxnID;
        system.debug('Inside RenewalAgencyController.getRenAccfromPmtReq');
        try{
            List<sObject> RegTxn = new List<sObject>();
            RegTxn = RenewalAgencyController.getInitialData(ReqId, 'RENACCPMTREQ');
            system.debug('REGTXN ==>' + JSON.serialize(RegTxn));
            if(!RegTxn.isEmpty()){
                sRegTxnID = (String)RegTxn[0].get('Ren_Acc_id__c');
            }
        } catch(Exception e) { 
            system.debug('Exception RenewalAgencyController.getRenAccfromPmtReq' + e.getMessage());
            return '';
        }
        system.debug('RenAccfromPmtReq '+sRegTxnID);
        return sRegTxnID;
    }
    @AuraEnabled(cacheable=true)
    public static void saveAgents(String AgencyID, List<ContactWrapper> AgentList){
        system.debug(AgencyID+' <-- AgencyID==RenewalAgencyController===AgentList--> '+AgentList.size());
        List<sObject> insList = new List<sObject>(); 
        if(AgentList!=null){
            for(ContactWrapper conWrapper : AgentList){
                Contact conTemp = new Contact();
                conTemp.LastName = conWrapper.Name;
                conTemp.AccountId = AgencyID;
                //conTemp.Agent__c=wrapper.conId;
                //conTemp.Agent_Number__c = wrapper.Phone;
                insList.add(conTemp);
            }
            Insert insList;
        }
        
    }
    
    Public static void updateRenewalProcess(String originalAccountId){
        List<Account> updateRenewalProcessAccount = New List<Account>(); 
        For (Account originalAccount : [Select id, Renewal_Process__c From Account Where ID =: originalAccountId]) {
            if(originalAccount.Renewal_Process__c != 'Pending Approval'){ // Updated on 13 sept
				originalAccount.Renewal_Process__c = 'Draft';
                updateRenewalProcessaccount.add(originalAccount);
            }
        }
        if(!updateRenewalProcessAccount.isEmpty()){
            update updateRenewalProcessAccount;
        }
    }
    
    Public static  void createAssociatedLocation(String originalAccountId,Account renewalAccount){
        system.debug('inside createLocationForRenewalRecord class');
        List<Schema.AssociatedLocation> RenewalAssociatedLocation = New List<Schema.AssociatedLocation>();
        For(Schema.AssociatedLocation  AssociatedLoc: [Select id, Address__c,ParentRecordId,LocationId,Status__c,Type From AssociatedLocation Where ParentRecordId =:originalAccountId AND (status__c='Pending Payment' OR status__c='Active') AND LocationId IN (Select id From Location)]){
            AssociatedLocation al = new AssociatedLocation();
            al.ParentRecordId = renewalAccount.id;
            al.status__c = 'Pending Payment';//AssociatedLoc.Status__c;
            al.Type = AssociatedLoc.Type;
            al.LocationId = AssociatedLoc.LocationId;
            RenewalAssociatedLocation.add(al);
        }
        insert RenewalAssociatedLocation;
    }
    

}