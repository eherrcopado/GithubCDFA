/* 
* @ Class Name: ContactsLwcController
* @ Objective: This class is used for AgentsForm LWC Component Controller
* @ Developer: QualApps(130897)
* @ Test Class : ContactsLwcController_Test
* @ Test Coverage : 
* @ Logs Modified By: 
*     User Name      |     Modified Date     |     Comments
* ---------------------------------------------------------------
* 	   130897               dd/MM/2022              Intial Creation
* 	   130897               dd/MM/2022              Added extra fields as per req
*/



public without sharing class ContactsLwcController {    
    /* 
    * @ Method Name: getContacts
    * @ Description: This method is used to Display Associated Agents for Renewal Agents 
    * @ Author: QualApps(130897)
    * @ Created Date: 
    * @ Parameters: 
    *       Name      |     Type
    * ------------------------------
    * 	 accId         	String
    * @ Return: List<SObject>
    */
    // This Method for Load Initial Data based on Account (1)
    @AuraEnabled//(cacheable=true)
    public static List<SObject> getContacts(String accId){
        Id RSAAgentRecordTypeId = SObjectType.contact.getRecordTypeInfosByDeveloperName().get('RSAAgent').getRecordTypeId();
        //List<Contact>conList = [Select Id, Name, Phone, FirstName, LastName, License_No__c from Contact WHERE AccountId =: accId];
        // Last Query = [ Select Id, Name, Phone, FirstName, LastName, License_No__c from Contact WHERE Id IN(Select contactId from AccountContactRelation Where AccountId=: accId) ]
        
        List<Contact>conList = [SELECT Id, Name, Phone, FirstName, LastName, License_No__c 
                                FROM Contact WHERE Id IN
                                (SELECT contactId FROM AccountContactRelation WHERE AccountId=: accId AND (status__c='Pending Payment' OR status__c='Active'))
                                AND RecordTypeId=: RSAAgentRecordTypeId];
        system.debug(accId+' <-- accId ======= size --> '+conList.size());
        system.debug('--- Data -- '+conList); //AND Status__c = 'Active'
        return conList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<contact> search(String searchTerm, string myObject, String filter) {
        system.debug('shahid-----------------');
        String myQuery = null;
        if(searchTerm == null || searchTerm == ''){
            myQuery = 'Select Id, Name, Phone,License_No__c from Contact order by CreatedDate desc LIMIT 10';
            system.debug('myQuery else-if '+myQuery);
        }
        else {
            myQuery = 'Select Id, Name,Phone,License_No__c from Contact Where (name like \'%' + searchTerm + '%\' OR  License_No__c like \'%' + searchTerm + '%\') LIMIT  10';
            system.debug('myQuery else '+myQuery);
        }
        
        List<contact> lookUpList = database.query(myQuery);
        return lookUpList;
    }// EO getContacts
    
    //
    public static list<sObject> getAgents(string searchKey) {    
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        string sQuery = 'Select Id, Name,Phone,License_No__c from Contact Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    /* 
    * @ Method Name: fetchLookupData(2)
    * @ Description: This Method ued to fetch lookup search result as per the search key.
    * @ Author: QualApps(130897)
    * @ Created Date: 
    * @ Parameters: 
    *       Name      |     Type
    * ------------------------------
    * 	 searchKey         	String
    * @ Return: List<SObject>
    */
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey) {
        Id RSAAgentRecordTypeId = SObjectType.contact.getRecordTypeInfosByDeveloperName().get('RSAAgent').getRecordTypeId();
        //List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        List<Contact> returnList = [SELECT Id, Name,Phone,License_No__c 
                                    FROM Contact 
                                    WHERE Name Like : sWildCardText AND status__c='Active'
                                    AND RecordTypeId=: RSAAgentRecordTypeId order by createdDate DESC LIMIT 10];
        return returnList;
        
    }
    
    /* 
    * @ Method Name: addAgent(3)
    * @ Description: This Method used to Adding(Insert and update) the Agents in Renewal Process.
    * @ Author: QualApps(130897)
    * @ Parameters: 
    *       Name      |     Type
    * ------------------------------
    * 	 accId         	Id
    * 	wrapperList		List<String>
    * @ Return: List<AccountContactRelation>
    * Logs
    * 	Date	|	Modified By		|	Comments
    * ===========================================
    * 	
    */
    @auraenabled
    public static List<AccountContactRelation> addAgent(List<String> wrapperList, Id accId){
        set<String>wrapperSet = new set<String>();
        List<AccountContactRelation> accConList2 = [SELECT id,contactId,accountId FROM AccountContactRelation
                                                    WHERE accountId =: accId AND contactId IN: wrapperSet];
        
        wrapperSet.addAll(wrapperList);
        system.debug('<---accId-----> '+accId);
        system.debug(wrapperList.size()+'<---Size ---Insertion-------Data-----> '+wrapperList);
        List<AccountContactRelation> accConList = new List<AccountContactRelation>();
        try{
            if(wrapperList!=null)
            {
                
                for(String wrapper : wrapperList){
                    List<AccountContactRelation> accConIdList = [SELECT id FROM AccountContactRelation WHERE accountId =: accId AND contactId =: wrapper limit 1];
                    system.debug(accConIdList.size()+'  size');
                    AccountContactRelation acr = new AccountContactRelation();
                    if(accConIdList.isEmpty()){
                        acr.AccountId = accId;
                        acr.ContactId = wrapper;
                        acr.Status__c = 'Pending Payment';
                        accConList.add(acr);
                    }else{
                        acr.Id = accConIdList[0].Id;
                        acr.Status__c = 'Pending Payment';
                        accConList.add(acr);
                    }
                    
                }
                if(!accConList.isEmpty()){
                    Database.DMLOptions dml = new Database.DMLOptions();
                    Database.UpsertResult[] insertSaveResult = Database.upsert(accConList, false);
                    system.debug('accConList---> '+accConList);
                    system.debug('insertSaveResult----------> '+insertSaveResult);
                }
            }
            
        }catch(Exception e){
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getCause());
            system.debug(e.getMessage());
        }
        return accConList;
    }
    
    /* 
    * @ Method Name: removeAgent(4)
    * @ Description: This Method used to Removing(it will set status as inactive) the Agents in Renewal Process.
    * @ Author: QualApps(130897)
    * @ Parameters: 
    *       Name      |     Type
    * ------------------------------
    * 	 accId         	Id
    * 	removeList		List<String>
    * @ Return: None
    * Logs
    * 	Date	|	Modified By		|	Comments
    * ===========================================
    * 	
    */
    @auraenabled
    public static void removeAgent(List<String> removeList, Id accId){
        system.debug(removeList.size()+'<---Size ---Deletion-------Data-----> '+removeList);
        System.debug('accId----> '+ accId);
        List<AccountContactRelation> accConList = new List<AccountContactRelation>();
        List<AccountContactRelation> acnlist = new List<AccountContactRelation>();
        List<AccountContactRelation> updatelist = new List<AccountContactRelation>();
        try{
            if(removeList!=null)
            {
                
                for(String wrapper : removeList){
                    AccountContactRelation deleteAccCon = [SELECT id FROM AccountContactRelation WHERE 
                                                           AccountId =: accId AND ContactId =: wrapper];// AND isDirect=false 
                    acnlist.add(deleteAccCon);
                }
                for(AccountContactRelation acn:acnlist){
                    AccountContactRelation acr = new AccountContactRelation();
                    acr.id = acn.Id;
                    acr.Status__c = 'Inactive';
                    updatelist.add(acr);
                }
                
                if(!updatelist.isEmpty()){
                    System.debug(updatelist.size()+' <--- size == updatelist----> '+ updatelist);
                    update updatelist;
                }
                
            }
        }catch(Exception e){
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getCause());
            system.debug(e.getMessage());
        }
    }
    
    /* 
    * @ Method Name: checkPrimaryContact(5)
    * @ Description: This Method for identify agent is Primary Contact or Secoundury for the Account.
    * @ Author: QualApps(130897)
    * @ Parameters: 
    *       Name      |     Type
    * ------------------------------
    * 	 acnId         	Id(Account Id)
    * 	conId			Id(Contact Id)
    * @ Return: Boolean Value
    * Logs
    * 	Date	|	Modified By		|	Comments
    * ===========================================
    * 	
    */
    @auraenabled//(cacheable=true)
    public static Boolean checkPrimaryContact(Id acnId, Id conId){
        system.debug(acnId+' <--------> '+conId);
        //SELECT contactID,accountId,isDirect FROM AccountContactRelation WHERE contactID ='003BZ000007quFcYAI' AND accountId= '001BZ000007W9esYAC'
        Boolean checkPrimaryFlag = false;
        Integer iRecCnt = [SELECT count() FROM AccountContactRelation 
                           WHERE isDirect = true AND contactID =: conId AND accountId=: acnId];
        if(iRecCnt != 0){
            checkPrimaryFlag = true;
        }else{
            checkPrimaryFlag = false;
        }
        system.debug('checkPrimaryFlag-- '+checkPrimaryFlag);
        return checkPrimaryFlag;
    }
    
    /* 
    * @ Method Name: getRenewalPaid(6)
    * @ Description: This Method for if the renewal Account's agency renewal record's status paid or Payment Pending 
    * 				 then it will return 1 otherwise 0 and this using in Progressindicatorlwc and businessform(section A).
    * @ Author: QualApps(130897)
    * @ Parameters: 
    *       Name      |     Type
    * ------------------------------
    * 	 renAccId		Id(Renewal Account Id)
    * @ Return: Integer Value
    * Logs
    * 	Date	|	Modified By		|	Comments
    * ===========================================
    * 	
    */
    @AuraEnabled
    public static Integer getRenewalPaid(String renAccId){ //List<Agency_Renewal__c>
        //select id,Renewal_Process__c from account where Renewal_Process__c='Pending Approval' AND id='001BZ000007kFSjYAM'
        List<Agency_Renewal__c>agnRenewal = [SELECT Id, Name, Status__c, Renewal_Account__c FROM Agency_Renewal__c 
                                             where Renewal_Account__c=: renAccId AND status__C IN ('Paid', 'Payment Pending')];
        
        system.debug(renAccId+' <-- accId ======= size --> '+agnRenewal.size());
        system.debug(renAccId+' <-- accId ======= size --> '+agnRenewal);
        return agnRenewal.size();
    }
    
    /* 
    * @ Method Name: getPaidStatus(7)
    * @ Description: This Method for if the renewal Account's agency renewal record's status paid or then it will 
    				 return 1 otherwise 0, it will effect only for form F and this also using in Progressindicatorlwc.
    * @ Author: QualApps(130897)
    * @ Parameters: 
    *       Name      |     Type
    * ------------------------------
    * 	 renAccId		Id(Renewal Account Id)
    * @ Return: Integer Value
    * Logs
    * 	Date	|	Modified By		|	Comments
    * ===========================================
    * 	
    */
    @AuraEnabled
    public static Integer getPaidStatus(String renAccId){ //List<Agency_Renewal__c>
        //select id,Renewal_Process__c from account where Renewal_Process__c='Pending Approval' AND id='001BZ000007kFSjYAM'
        //if Status Paid is then only Form F and Make PAyment
        List<Agency_Renewal__c>agnRenewal = [SELECT Id, Name, Status__c, Renewal_Account__c FROM Agency_Renewal__c 
                                             where Renewal_Account__c=: renAccId AND status__C =: 'Paid'];
        system.debug(renAccId+' <-- accId ======= size --> '+agnRenewal.size());
        system.debug(renAccId+' <-- accId ======= size --> '+agnRenewal);
        return agnRenewal.size();
    }
	
	/* 
    * @ Method Name: updateAgentStatus(8)
    * @ Description: This Method used for updating agents and associatedlocation status to active whenever
    * 				 Renewal Accounts related agency renewal Status changed from Payment Pending to Paid and
    * 				 this method calling in Agency Reneal Trigger.
    * @ Author: QualApps(130897)
    * @ Parameters: 
    *       Name      |     Type
    * ------------------------------
    * 	 renAccId		Id(Renewal Account Id)
    * @ Return: Integer Value
    * Logs
    * 	Date		|	Modified By			|	Comments
    * ======================================================
    * 	06-09-2022		QualApps(130897)	 Intial Creation
    * 	07-09-2022		QualApps(130897)	 Clubed agents and Associatedlocation in one method.
    */
    public static void updateAgentStatus(Map<id,Agency_Renewal__c> con_old , Map<id,Agency_Renewal__c> con_new){
        //system.debug(con_old+'  updateAgentStatus --> '+con_new);
        Set<id> Keys  = con_old.keyset();
        set<id> accnId = new set<id>();
        Agency_Renewal__c oldStatus = new Agency_Renewal__c();
        Agency_Renewal__c newStatus = new Agency_Renewal__c();
        
        for(Agency_Renewal__c ar : con_old.values()){
            accnId.add(ar.Renewal_Account__c);
            system.debug('  accnId --> '+accnId);
        }
        // Renewal Agents
        List<AccountContactRelation> renewalAgentsList = [SELECT Id,Status__c FROM AccountContactRelation
                                                          WHERE accountId=:accnId AND Status__c='Pending Payment'];
        // Renewal Associated Location
        List<AssociatedLocation> renewalAsLocList = [SELECT Id,Status__c FROM AssociatedLocation
                                                     WHERE ParentRecordId=:accnId AND Status__c='Pending Payment'];
        for(Id k: keys){
            oldStatus = con_old.get(k);
            newStatus = con_new.get(k);
        }
        //system.debug(renewalAgentsList.size()+'  renewalAgentsList size --> '+renewalAgentsList);
        
        List<AccountContactRelation> updateAcrList = new List<AccountContactRelation>();
        List<AssociatedLocation> updateAsLocList = new List<AssociatedLocation>(); //
        
        if(oldStatus.Status__c == 'Payment Pending' && newStatus.Status__c == 'Paid'){
            
            // Agents Update Process Start
            try{
                system.debug('size renewalAgentsList --> '+renewalAgentsList.size());
                if(!renewalAgentsList.isEmpty()){
                    for(AccountContactRelation acn : renewalAgentsList){
                        AccountContactRelation acr = new AccountContactRelation();
                        acr.id = acn.Id;
                        acr.Status__c = 'Active';
                        updateAcrList.add(acr);
                    }
                    if(!updateAcrList.isEmpty()){
                        update updateAcrList;
                    }
                }
                
            }catch (Exception e) { 
                system.debug(e.getTypeName());
                system.debug(e.getLineNumber());
                system.debug(e.getCause());
                system.debug(e.getMessage());
            }// Agents Update Process End
            
            // AssociatedLocation Update Process Start
            try{
                system.debug('size renewalAsLocList --> '+renewalAsLocList.size());
                if(!renewalAsLocList.isEmpty()){
                    
                    for(AssociatedLocation asl : renewalAsLocList){
                        AssociatedLocation asloc = new AssociatedLocation();
                        asloc.id = asl.Id;
                        asloc.Status__c = 'Active';
                        updateAsLocList.add(asloc);
                    }
                    if(!updateAsLocList.isEmpty()){
                        update updateAsLocList;
                    }
                }
                
            }catch (Exception e) { 
                system.debug(e.getTypeName());
                system.debug(e.getLineNumber());
                system.debug(e.getCause());
                system.debug(e.getMessage());
            }// AssociatedLocation Update Process End
            
        }
    }
}