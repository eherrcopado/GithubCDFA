public  class ReconcileAgency  {
    @AuraEnabled
    public static void Renew(string RenewAgencyID){
        try{
            String sOrgAccID;
            Boolean bOpeartion = false;
            sOrgAccID = CheckRenewAgency(RenewAgencyID);
            if (sOrgAccID.length()>0){
                MergeChild(sOrgAccID, RenewAgencyID, 'ACCAGENT');
                MergeChild(sOrgAccID, RenewAgencyID, 'ACCLOCATION');
                MergeChild(sOrgAccID, RenewAgencyID, 'ACCDEVICE');
                UpdateAgency(RenewAgencyID);
                UpdateRenewalAgency(sOrgAccID,RenewAgencyID);               
                CreateBusinessLicense(sOrgAccID);
                UpdateRenewalAccountToOriginalAccount(sOrgAccID,RenewAgencyID);
                createFilesInOriginalAccountFromRenewalAccount(sOrgAccID,RenewAgencyID);
            }
        }catch (Exception e) { 
            system.debug('Exception ReconcilieAgency.Renew' + e.getMessage());        
        }
    }
    
    public static String CheckRenewAgency(string RenewAgencyID){
        String sOrgAccID;
        try{
            List<sObject> RenewAgency = new List<sObject>();
            RenewAgency = RenewalAgencyController.getInitialData(RenewAgencyID, 'RENEWAGENCY');
            if(!RenewAgency.isEmpty()){
                sOrgAccID = (String)RenewAgency[0].get('Original_Account_Id__c');
            }
        } catch(Exception e) { 
            system.debug('Exception ReconcilieAgency.CheckRenewAgency' + e.getMessage());
            return '';
        }
        return sOrgAccID;
    }
    
    public static void MergeChild(string AgencyID, string RenewAgencyID, string sType){
        try{
            System.debug('Inside Merge MergeChild-->RSA: ' + AgencyID + ' Merge: '+ RenewAgencyID + ' Type: '+ sType);
            String sFieldName;
            String sPrimaryLocationID;
            String sPrimaryType1;
            List<sObject> lOrgData = new List<sObject>();
            List<sObject> lRenewData = new List<sObject>();
            
            Set<String> sOrgData = new Set<String>();
            Set<String> sRenewData = new Set<String>();
            Set<String> sDeleteData = new Set<String>();
            Set<String> sAddData = new Set<String>();
            
            switch on sType{
                when 'ACCAGENT'{
                    sFieldName = 'contactid';                    
                }                  
                when 'ACCLOCATION'{
                    sFieldName = 'LocationId';
                } 
                when 'ACCDEVICE'{                
                    sFieldName = 'Product2Id';
                }                   
            }
            lOrgData = RenewalAgencyController.getInitialData(AgencyID, sType);
            lRenewData = RenewalAgencyController.getInitialData(RenewAgencyID, sType); 
            for(sObject sTemp : lOrgData){
                String sEntID = (String) sTemp.get(sFieldName);
                sOrgData.add(sEntID);                
            }  
            for(sObject sTemp : lRenewData){
                String sEntID = (String) sTemp.get(sFieldName);
                sRenewData.add(sEntID);
                if (sType == 'ACCLOCATION'){
                    sPrimaryType1 = (String) sTemp.get('Type');
                    if (sPrimaryType1 == 'Primary'){
                        sPrimaryLocationID = sEntID;  
                    }
                }
            }          
            sDeleteData = sOrgData.clone();
            sAddData = sRenewData.clone();
            sDeleteData.removeAll(sRenewData);
            sAddData.removeAll(sOrgData);
            
            switch on sType{
                when 'ACCAGENT'{
                    AddAgentToAgency(AgencyID, sAddData,sOrgData, sRenewData);
                    // updateRenewalAgents(RenewAgencyID, sAddData);
                    
                    RemoveAgentToAgency(AgencyID, sDeleteData); 
                    //CreateBusinessLicense(RenewAgencyID); 
                }                  
                when 'ACCLOCATION'{                    
                    AddLocationToAgency(AgencyID, sAddData, sOrgData, sRenewData);
                    //AddLocationToAgency(AgencyID, sAddData);
                    RemoveLocationToAgency(AgencyID, sDeleteData);
                    UpdatePrimaryLocation(AgencyID, sPrimaryLocationID);
                    
                } 
                when 'ACCDEVICE'{                
                    AddDeviceToAgency(AgencyID, RenewAgencyID, sAddData);
                    RemoveDeviceToAgency(AgencyID, sDeleteData);
                }                   
            }
        } catch (Exception e) { 
            system.debug('Exception ReconcilieAgency.MergeChild' + e.getMessage());        
        }
    }
    
    public static void UpdatePrimaryLocation(string AgencyID, string priLocID){
        try{
            String sType;
            String sPrimID;
            //Update the Approval status to Completed in Renewal Agency Object
            List<AssociatedLocation> lUpdaterenewalagency =  New List<AssociatedLocation>();
            For (AssociatedLocation oUpdaterenewalagency : [Select Id, Type, LocationId from AssociatedLocation Where ParentRecordId =: AgencyID]){
                sType = oUpdaterenewalagency.Type;
                sPrimID = oUpdaterenewalagency.LocationId;
                if (sPrimID == priLocID){
                    oUpdaterenewalagency.Type = 'Primary';
                } else {
                    oUpdaterenewalagency.Type = 'Other';
                }               
                lUpdaterenewalagency.add(oUpdaterenewalagency);
            }
            update lUpdaterenewalagency;
        }
        catch (Exception e) { 
            system.debug('Exception UpdatePrimaryLocation' + e.getMessage());        
        }
    }
    
    public static void AddAgentToAgency(string AgencyID, Set<String> sAgentIds, Set<String> sOrgAgentIds, Set<String> sRenAgentIds){
        
        // AgencyID - Orginal AccountId
        // sAgentIds - Renewal Account Agents Contact Id whatever we are added
        // sOrgAgentIds - Only Original Account Agents Contact Id
        // sRenAgentIds - All Agent Ids of Renewal Accounts
        
        system.debug(AgencyID+' AgencyID add Agents ');
        system.debug(sAgentIds.size()+' sAgentIds add Agents '+sAgentIds);
        system.debug(sOrgAgentIds.size()+' sOrgAgentIds add Agents '+sOrgAgentIds);
        system.debug(sRenAgentIds.size()+' sRenAgentIds add Agents '+sRenAgentIds);
        
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        
        Try{
            List<AccountContactRelation>myList = [SELECT Id,contactId FROM AccountContactRelation 
                                                  WHERE accountId=:AgencyID AND contactId IN: sRenAgentIds];
            system.debug(myList.size()+' myList add Agents '+myList);
            Map<String,String>myMap = New Map<String,String>();
            String accountContactId = '';
            if(!myList.isEmpty()){
                for(AccountContactRelation acn:myList){
                    myMap.put(acn.contactId, acn.Id);
                }
            }
            for (String sContactID : sRenAgentIds){
                accountContactId = myMap.get(sContactID);
                system.debug(sContactID +' key and value '+accountContactId);
                if(!myList.isEmpty()){
                    AccountContactRelation acr2 = new AccountContactRelation();
                    if(myMap.containsKey(sContactID)){
                        system.debug('update');
                        acr2.id=accountContactId;
                        //acr.id=
                        acr2.Status__c='Active';
                        acr2.StartDate = System.today();
                        acrList.add(acr2);
                        
                    }else{
                        system.debug('insert');
                        
                        acr2.accountID = AgencyID;
                        acr2.contactID = sContactID;
                        acr2.Status__c='Active';
                        acr2.StartDate = System.today();
                        acrList.add(acr2);
                    }
                }else{
                    system.debug('insert 2');
                    AccountContactRelation acr = new AccountContactRelation();
                    acr.accountID = AgencyID;
                    acr.contactID = sContactID;
                    acr.Status__c='Active';
                    acr.StartDate = System.today();
                    acrList.add(acr);
                }
            }
            if(!acrList.isEmpty()){
                system.debug(acrList.size()+' acrList size '+acrList);
                upsert acrList;
            }
        }Catch(Exception e){
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
        }
        
    }
    
    public static void RemoveAgentToAgency(string AgencyID, Set<String> sAgentIds){
        try{
            if(sAgentIds!=null){
                List<AccountContactRelation> lAccConRel = new List<AccountContactRelation>();
                for (AccountContactRelation deleteAccCon : [SELECT id FROM AccountContactRelation WHERE 
                                                            AccountId =: AgencyID AND ContactId =: sAgentIds]){
                                                                deleteAccCon.Status__c = 'Inactive';
                                                                deleteAccCon.EndDate = System.today();
                                                                lAccConRel.add(deleteAccCon);
                                                                System.debug('RemoveAgentToAgency ' + AgencyID + ' | Contact :' + sAgentIds);
                                                            }
                try{
                    if(lAccConRel != NULL){
                        System.debug(lAccConRel.size()+' <--- size == acnl----> '+ lAccConRel);
                        Database.SaveResult[] srList = Database.update(lAccConRel, false);
                        for (Database.SaveResult sr : srList) {                       
                            if (sr.isSuccess()) {
                                System.debug('Successfully inserted account. Account Contact Relation ID: ' + sr.getId());
                            }
                            else {
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('The following error has occurred.');                    
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Account fields that affected this error: ' + err.getFields());
                                }
                            }
                        }
                    }
                }
                catch(Exception e){
                    system.debug(e.getTypeName());
                    system.debug(e.getLineNumber());
                    system.debug(e.getCause());
                    system.debug(e.getMessage());
                }
            }
        }catch(Exception e){
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getCause());
            system.debug(e.getMessage());
            system.debug('Exception ReconcilieAgency.RemoveAgentToAgency' + e.getMessage()); 
        }
        
    }
    
    public static void AddLocationToAgency(string AgencyID, Set<String> sLocationIds, Set<String> orgLocationIds, Set<String> renewLocationIds){        
        List<AssociatedLocation> asLocList = new List<AssociatedLocation>();
        AssociatedLocation asLoc = new AssociatedLocation();
        String AssociatedLocationId = '';
        system.debug('AgencyID in location ==> '+AgencyID);
        system.debug(sLocationIds.size()+'  sLocationIds List  ==> '+sLocationIds);
        system.debug(orgLocationIds.size()+'  orgLocationIds List  ==> '+orgLocationIds);
        system.debug(renewLocationIds.size()+'  renewLocationIds List  ==> '+renewLocationIds);
        Try{
            List<AssociatedLocation>aslList = [SELECT Id,LocationId, type FROM AssociatedLocation 
                                               WHERE ParentRecordId=:AgencyID AND LocationId IN: renewLocationIds];
            Map<String,String>myMap = New Map<String,String>();
            Map<String,String>TypeMap = New Map<String,String>();
            system.debug('size of List aslList ==> '+aslList.size());
            if(!aslList.isEmpty()){
                for(AssociatedLocation asl:aslList){
                    myMap.put(asl.LocationId, asl.Id);
                    TypeMap.put(asl.LocationId, asl.type);
                }
            }
            
            for (String LocID : renewLocationIds){
                AssociatedLocationId = myMap.get(LocID);
                system.debug(LocID +' key and value '+AssociatedLocationId);
                AssociatedLocation al = new AssociatedLocation();
                if(!aslList.isEmpty()){
                    
                    if(myMap.containsKey(LocID)){
                        system.debug('update');
                        
                        al.Id = AssociatedLocationId;
                        al.Type = 'Other';
                        al.ActiveFrom = System.today();
                        al.ActiveTo= System.today()+365;
                        al.Status__c='Active';
                        asLocList.add(al);
                    }else{
                        system.debug('insert');
                        
                        al.ParentRecordId = AgencyID;
                        al.LocationId = LocId;
                        al.Type = 'Other';
                        al.ActiveFrom = System.today();
                        al.ActiveTo= System.today()+365;
                        al.Status__c='Active';
                        asLocList.add(al);
                        
                    }
                }else{
                    system.debug('insert 2');
                    
                    al.ParentRecordId = AgencyID;
                    al.LocationId = LocId;
                    al.Type = 'Other';
                    al.ActiveFrom = System.today();
                    al.ActiveTo= System.today()+365;
                    al.Status__c='Active';
                    asLocList.add(al);
                }
                
            }
            if(!asLocList.isEmpty()){
                system.debug(asLocList.size()+' acrList size '+asLocList);
                upsert asLocList;
            }
        }Catch(Exception e){
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
        }
    }
    
    public static void RemoveLocationToAgency(string AgencyID, Set<String> sLocationIds){
        List<AssociatedLocation> alList = new List<AssociatedLocation>();
        try{
            for (AssociatedLocation al : [select id, LocationId, ParentRecordId, Status__c from AssociatedLocation where ParentRecordId = :AgencyID
                                          and LocationId IN: sLocationIds]) {
                                              alList.add(al);
                                          }
            if(alList.size() > 0 ){
                delete alList;
            }
        }catch (Exception e) { 
            system.debug('Exception ReconcilieAgency.RemoveLocationToAgency' + e.getMessage());        
        }
    }
    
    public static void AddDeviceToAgency(string AgencyID, String RenewAgencyID, Set<String> sDeviceIds){
        try{            
            List<Asset> renewalAccountAssetsList = [SELECT id, AccountId, Product2Id, name,Device_Type__c,Description,Other_Device_Comments__c FROM Asset where AccountId =: RenewAgencyID];
            List<Asset> originalAccountAssetsList = [SELECT id, AccountId, Product2Id, name,Device_Type__c,Description,Other_Device_Comments__c FROM Asset where AccountId =: AgencyID];
            
            if(renewalAccountAssetsList.size() > 0){
                List<Asset> updateOriginalAccountsAssetsList = new List<Asset>();
                for(Asset oAsset: originalAccountAssetsList){                   
                    for(Asset renewalAccountAsset : renewalAccountAssetsList){         
                        if(oAsset.Product2Id != null && oAsset.Product2Id.equals(renewalAccountAsset.Product2Id)){                        
                            if(renewalAccountAsset.Name.equals('Other Measuring Devices') || renewalAccountAsset.Name.equals('Other Weighing Devices')){
                                Asset asset = oAsset;
                                if(!renewalAccountAsset.Other_Device_Comments__c.equals(asset.Other_Device_Comments__c)){
                                    asset.Other_Device_Comments__c = renewalAccountAsset.Other_Device_Comments__c;
                                    asset.Description = renewalAccountAsset.Description;
                                    updateOriginalAccountsAssetsList.add(asset);
                                }
                            }
                        }
                    }
                }
                if(updateOriginalAccountsAssetsList.size()>0){
                    update updateOriginalAccountsAssetsList;
                }
            }
            system.debug('sDeviceIds size :'+sDeviceIds.size());
            if(sDeviceIds.size()>0){  
                List<Asset> lAsset = new List<Asset>();
                for (Asset aAsset : [SELECT id, AccountId, Product2Id, name,Device_Type__c,Description,Other_Device_Comments__c FROM Asset where AccountId =: RenewAgencyID AND Product2Id IN :sDeviceIds]) {
                    Asset nAsset = new Asset();
                    nAsset.Name = aAsset.Name;
                    nAsset.AccountId = AgencyID;
                    nAsset.Product2Id = aAsset.Product2Id;
                    nAsset.Device_Type__c = aAsset.Device_Type__c;
                    nAsset.Other_Device_Comments__c = aAsset.Other_Device_Comments__c;
                    nAsset.Description = aAsset.Description;
                    lAsset.add(nAsset);
                }
                try{
                    if(lAsset != NULL){
                        System.debug('Full Added Agents List (' + lAsset.size()+ ') ' + lAsset);
                        insert lAsset;
                    }
                }catch(Exception e){
                    system.debug(e.getTypeName());
                    system.debug(e.getLineNumber());
                    system.debug(e.getCause());
                    system.debug(e.getMessage());
                }
            }
        }catch (Exception e) { 
            system.debug('Exception ReconcilieAgency.AddDeviceToAgency' + e.getMessage());        
        }
    }
    
    public static void RemoveDeviceToAgency(string AgencyID, Set<String> sDeviceIds){
        try{  
            if(sDeviceIds.size() > 0 ){           
                List<Asset> lAsset = new List<Asset>();
                for (Asset aAsset : [SELECT id FROM Asset where AccountId =: AgencyID AND Product2Id =: sDeviceIds]) {
                    lAsset.add(aAsset);
                }
                if(lAsset.size() > 0 ){
                    System.debug('Full Remove Agents List (' + lAsset.size()+ ') ' + lAsset);
                    delete lAsset;
                }                
            }
        }catch (Exception e) { 
            system.debug('Exception ReconcilieAgency.RemoveDeviceToAgency' + e.getMessage());        
        }
    }    
    
    public static void UpdateRenewalAgency(string AgencyID,string RenewalAgencyID){
        try{
            //Update the Approval status to Completed in Renewal Agency Object
            List<Agency_Renewal__c> updaterenewalagency =  New List<Agency_Renewal__c>();
            //For (Agency_Renewal__c AgencyRenewal : [Select Id, Status__c from Agency_Renewal__c Where Account__c =: AgencyID AND Renewal_Account__c =:RenewalAgencyID]){
            For (Agency_Renewal__c AgencyRenewal : [Select Id, Status__c from Agency_Renewal__c Where Renewal_Account__c =:RenewalAgencyID]){
                AgencyRenewal.Status__c = 'Completed';
                updaterenewalagency.add(AgencyRenewal);
                system.debug('Update the Approval status to Done in Renewal Agency Object' + AgencyID + ' : Renewal : '+RenewalAgencyID);
            }
            update updaterenewalagency;
        }
        catch (Exception e) { 
            system.debug('Exception UpdateRenewalAgency' + e.getMessage());        
        }
    }
    
    public static void UpdateAgency(string RenewalAgencyID){
        try{
            //Update the RenewalAccount with Status = Dormant/Inactive, Renewal Status = Completed
            List<Account> updaterenewalaccount =  New List<Account>();
            Id RenewalRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal_Complete').getRecordTypeId();
            For (Account Orgacc : [Select Id, Renewal_Process__c from Account Where Id =: RenewalAgencyID]){
                Orgacc.Renewal_Process__c = 'Completed';
                orgacc.RecordTypeId = RenewalRecordTypeID;
                updaterenewalaccount.add(Orgacc);
                system.debug('Update the RenewalAccount with Status = Dormant/Inactive, Renewal Status = Completed RenewalAgency : ' + RenewalAgencyID);
            }
            Update updaterenewalaccount;
        } 
        catch (Exception e) 
        { 
            system.debug('Exception UpdateAgency' + e.getMessage());        
        }
    }
    
    @AuraEnabled
    Public Static void CreateBusinessLicense(String OriginalAgencyID) {
        List<BusinessLicense> blList = [Select Id, Name, AccountId, Status,PeriodStart,PeriodEnd  from BusinessLicense Where AccountId =: OriginalAgencyID and Status = 'Active' limit 1];
        
        List<BusinessLicense> BlInsertList = new List<BusinessLicense>();
        List<BusinessLicense> BlUpdateList = new List<BusinessLicense>();
        
        For (BusinessLicense Bls : blList){
            BusinessLicense Bl= new BusinessLicense();
            Bls.Status = 'Inactive'; 
            
            Bl.Name = Bls.Name ;
            Bl.Status = 'Active';
            /**
            DateTime pstartDate= Bls.PeriodStart;
            DateTime pendDate=Bls.PeriodEnd;            
            
            string dateTimeStr = pstartDate.format('dd-MM-yyyy HH:mm:ss',  'America/Los_Angeles');
            string dateGMTStr  = pstartDate.formatGMT('dd-MM-yyyy HH:mm:ss');
            Datetime localDateTime = DateTime.valueOf(dateTimeStr);
            Datetime baseGMTTime = DateTime.valueOf(dateGMTStr);
            Long milliSecDiff =  baseGMTTime.getTime() - localDateTime.getTime();
            Long minDiff = milliSecDiff / 1000 / 60;
            Datetime outDateTime = pstartDate.addMinutes(minDiff.intValue());
            
            Bl.PeriodStart = outDateTime.date().toStartOfMonth();
            Bl.PeriodStart =  Bl.PeriodStart.addyears(1);
            Bl.PeriodStart =  Bl.PeriodStart.addHours(8);
            pendDate = Bl.PeriodStart.addYears(1);
            Bl.PeriodEnd = pendDate.addDays(-1);   
            **/
            
            Bl.PeriodStart =  Bls.PeriodStart.addyears(1); 
            Bl.PeriodEnd = Bls.PeriodEnd.addyears(1);
            Bl.AccountId = OriginalAgencyID;     
            system.debug('Bl.PeriodStart >>> :'+Bl.PeriodStart);
            system.debug('Bl.PeriodEnd >>> :'+Bl.PeriodEnd);            
            BlInsertList.add(Bl);
            BlUpdateList.add(Bls);
        }
        
            try{
                update BlUpdateList;
                insert BlInsertList; 
            }catch (Exception e) {
                system.debug('Exception BL Insert' + e.getMessage()); 
                system.debug('Exception BL Insert' + e.getStackTraceString()); 
            }
        
    }
    
    Public Static void UpdateRenewalAccountToOriginalAccount(string AgencyID,string RenewalAgencyID){
        List<Account> UpdateNewAccount = New List<Account>();
        
        For(Account renewalAccount : [Select id, Name,DBA_Name__c,Legal_Entity__c,Phone,Email__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Renewal_Process__c From Account Where ID =:RenewalAgencyID])
        {
            For (Account originalAccount : [Select id, Name,DBA_Name__c,Legal_Entity__c,Phone,Email__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Renewal_Process__c From Account Where ID =:AgencyID]) 
            {
                originalAccount.DBA_Name__c=renewalAccount.DBA_Name__c;
                originalAccount.Legal_Entity__c=renewalAccount.Legal_Entity__c;
                originalAccount.BillingStreet=renewalAccount.BillingStreet;
                originalAccount.BillingCity=renewalAccount.BillingCity;
                originalAccount.BillingState=renewalAccount.BillingState;
                originalAccount.BillingPostalCode=renewalAccount.BillingPostalCode;
                originalAccount.BillingCountry=renewalAccount.BillingCountry;
                originalAccount.Phone=renewalAccount.Phone;
                originalAccount.Renewal_Process__c = renewalAccount.Renewal_Process__c;   
                originalAccount.Email__c=renewalAccount.Email__c;
                UpdateNewAccount.add(originalAccount);
            }
            
        }
        Update UpdateNewAccount;
        
    }
    @TestVisible
    private static void createFilesInOriginalAccountFromRenewalAccount(String sOrgAccID,String RenewAgencyID){
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        
        List<ContentDocumentLink> filesList = new List<ContentDocumentLink>();
        for (ContentDocumentLink docLink : [SELECT ContentDocumentId,ShareType,Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :RenewAgencyID]) {
            filesList.add(new ContentDocumentLink(
                LinkedEntityId = sOrgAccID,
                ContentDocumentId = docLink.ContentDocumentId,
                ShareType = docLink.ShareType,
                Visibility = docLink.Visibility
            ));
        }
        if(filesList.size() > 0){
            List<Database.SaveResult> insertSaveResultList = Database.insert(filesList, dml);
        }
    }    
}