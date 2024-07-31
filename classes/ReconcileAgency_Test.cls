@isTest
public class ReconcileAgency_Test {
    
  @isTest
    Private static void test_Method(){
        try{ 
            //Test Data
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            
            Account accRec1 = TestDataFactory_Community.createAccountTestRec('TestAcc', 'Renewal_Complete');
            Insert accRec1;
            
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            
            Asset assetRec = TestDataFactory_Community.createAssetTestRec(accRec.Id,conRec.Id);
            Insert assetRec;
          
            Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            
            Account renewalAcc = new Account(Name = 'TestAcc',Original_Account_Id__c=accRec.Id, Registration_Number__c='123', RecordTypeId = accountRecordTypeId);
            Insert renewalAcc;
                        
            RegulatoryAuthorizationType getRegAuthTypeRec = TestDataFactory_Community.getRegAuthType();
            insert getRegAuthTypeRec;
           
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;
            
            Agency_Renewal__c ar = new Agency_Renewal__c(Renewal_Account__c=renewalAcc.Id, Status__c='Draft');
            insert ar;
            ar.Status__c='Completed';
            update ar;
            
            RegulatoryAuthorizationType raType = new RegulatoryAuthorizationType();
            raType.Name = 'Test raType';
            raType.RegulatoryAuthCategory = 'License';
            insert raType;
            
            //List<BusinessLicense> blList = new List<BusinessLicense>();
            BusinessLicense bl1 = new BusinessLicense();
            bl1.Name = 'Test BL1';
            bl1.RegulatoryAuthorizationTypeId = getRegAuthTypeRec.id;
            bl1.PeriodStart = system.today()-1;
            bl1.PeriodEnd =system.today();
            bl1.AccountId = accRec.Id;
            bl1.ContactId = conRec.Id;
            bl1.status = 'Active';
            insert bl1;
            bl1.Status = 'Inactive';
            update bl1;
            
             
            BusinessLicense bl2 = new BusinessLicense();
            bl2.Name = 'Test BL2';
            bl2.RegulatoryAuthorizationTypeId = getRegAuthTypeRec.id;
            bl2.PeriodStart =system.today().addYears(1);
            bl2.PeriodEnd =system.today().addDays(-1);
            bl2.AccountId = accRec.Id;
            bl2.ContactId = conRec.Id;
            bl2.status = 'Active';
            insert bl2;
            
            List<Product2>product2List = new List<Product2>();
            for(integer i=0; i<5; i++){
                Product2 pd = new Product2();
                pd.Name = 'Test Asset '+i;
                if(i>2){
                    pd.Family = 'Measuring Devices';
                }else{
                    pd.Family = 'Weighing Devices';
                }
                pd.IsActive = true;
                product2List.add(pd);
            }
            insert product2List;
            
            List<Asset>asstList = new List<Asset>();
            for(integer i=0; i<5; i++){
                Asset asst = new Asset();
                asst.Name = 'Test Asset '+i;
                asst.AccountId = accRec.Id;
                asst.Product2Id = product2List[i].Id;
                asst.Device_Type__c = 'Measuring';
                asst.Other_Device_Comments__c = 'test';
                asstList.add(asst);
            }
            if(asstList.size()>0){
                insert asstList;
            }
            set<String> sDeviceIds = new set<String>();
                sDeviceIds.add(asstList[0].name);
                sDeviceIds.add(asstList[1].name);
                sDeviceIds.add(asstList[2].name);
                sDeviceIds.add(asstList[3].name);
              
            Schema.Location locationRec = TestDataFactory_Community.getLocationTestRec();
            insert locationRec;
            
            Schema.Address addressRec = TestDataFactory_Community.getAddessRec(locationRec.Id);
            insert addressRec;
            
            Schema.AssociatedLocation ascLocationRec = TestDataFactory_Community.getAscLationTestRec(accRec.Id,locationRec.Id);
            insert ascLocationRec;
            
             List<Schema.Location> locList = new List<Schema.Location>();
                for(integer i=0; i<5; i++){    
                    Schema.Location lc = new Schema.Location();
                    lc.name ='test lc' +i;
                    lc.LocationType='Business Site';
                    locList.add(lc);
                }
              
                if(loclist.size()>0){
                    insert loclist;
                }
             set<String> sLocationIds = new set<String>();
                sLocationIds.add(locList[0].name);
                sLocationIds.add(locList[0].name);
                sLocationIds.add(locList[0].name);
                sLocationIds.add(locList[0].name);
            
                List<Contact> conList = new List<Contact>();
                    for(integer i=0; i<5; i++){    
                        Contact c1 = new Contact();
                        c1.LastName = 'test data';
                        c1.AccountId = accRec1.id;
                        conList.add(c1);
                    }
                    if(conList.size()>0){
                        insert conList;
                    }
            
                List<AccountContactRelation> acrnList = new List<AccountContactRelation>();
                AccountContactRelation acrRec = new AccountContactRelation();       
                acrRec.AccountId=accRec.Id;
                acrRec.ContactId=conList[0].Id;
                acrRec.Agent_Name__c='Test Agent1';
                acrRec.Status__c='Active';
                acrnList.add(acrRec);
                
                if(acrnList.size()>0){
                    insert acrnList;
                }
                
                Map<String,String> myMap = New Map<String,String>();
                mymap.put(acrRec.ContactId,acrRec.Id);   
                
                Map<String,String> myMap1 = New Map<String,String>();
                mymap.put(ascLocationRec.LocationId,ascLocationRec.Id);
            
          
                
             system.runAs(testUser) {
                // statements to be executed by this test user.
                Test.startTest();
                //Renew
                ReconcileAgency.Renew(renewalAcc.Id);
                 
                //createFilesInOriginalAccountFromRenewalAccount
                ReconcileAgency.createFilesInOriginalAccountFromRenewalAccount(accRec.Id,renewalAcc.Id);
                 
                               
                 //AddDeviceToAgency
                ReconcileAgency.AddDeviceToAgency(accRec.Id, renewalAcc.Id, sDeviceIds);
                 
                 //RemoveDeviceToAgency
                ReconcileAgency.RemoveDeviceToAgency(accRec.Id, sDeviceIds);
                 
                 //UpdateAgency
                 ReconcileAgency.UpdateAgency(renewalAcc.id);
                 
                 //UpdateRenewalAccountToOriginalAccount
                ReconcileAgency.UpdateRenewalAccountToOriginalAccount(accRec.Id, renewalAcc.Id); 
                 
                 //AddLocationToAgency
               //ReconcileAgency.AddLocationToAgency(accRec.Id, sLocationIds);
            
                Test.stopTest();
             }
            
            }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }
    
    
    
    
    @isTest
    Private static void test_Method2(){
        try{
            //Test Data
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            
            Account accRenewalRec = TestDataFactory_Community.createAccountTestRec('TestAcc33', 'Renewal');
            Insert accRenewalRec;
            
            Agency_Renewal__c ar = new Agency_Renewal__c(Renewal_Account__c=accRenewalRec.Id, Status__c='Payment Pending');
            insert ar;
            Agency_Renewal__c ar1 = new Agency_Renewal__c(Renewal_Account__c=accRenewalRec.Id, Status__c='Paid');
            insert ar1;
            
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;
            
            
            // AscLocations Start
            RegulatoryAuthorizationType rAuth = TestDataFactory_Community.getRegAuthType();
            insert rAuth;
            BusinessLicense licrec = TestDataFactory_Community.getBusnLicTestRec(accRec.Id, conRec.Id, rAuth.Id);
            insert licrec;
            // 1 Location
            Schema.Location locationRec = TestDataFactory_Community.getLocationTestRec();
            insert locationRec;
            Schema.Address addressRec = TestDataFactory_Community.getAddessRec(locationRec.Id);
            insert addressRec;
            Schema.Location lc = new Schema.Location();
            lc.Id = locationRec.Id;
            lc.VisitorAddressId = addressRec.id;
            update lc;
            
            // 2 location
            Schema.Location locationRec2 = TestDataFactory_Community.getLocationTestRec();
            insert locationRec2;
            Schema.Address addressRec2 = TestDataFactory_Community.getAddessRec(locationRec2.Id);
            insert addressRec2;
            Schema.Location lc2 = new Schema.Location();
            lc2.Id = locationRec2.Id;
            lc2.VisitorAddressId = addressRec2.id;
            update lc2;
            
            // 3 location
            Schema.Location locationRec3 = TestDataFactory_Community.getLocationTestRec();
            insert locationRec3;
            Schema.Address addressRec3 = TestDataFactory_Community.getAddessRec(locationRec3.Id);
            insert addressRec3;
            Schema.Location lc3= new Schema.Location();
            lc3.Id = locationRec3.Id;
            lc.VisitorAddressId = addressRec3.id;
            update lc3;
            
            set<String>sLocationIds2 = new set<String>();
            set<String>orgLocationIds = new set<String>();
            
            List<Schema.AssociatedLocation> orgascLocationRecs = new List<Schema.AssociatedLocation>();
            for(integer i=0;i<5;i++){
                Schema.AssociatedLocation asl = new Schema.AssociatedLocation();
                asl.Type ='other';
                asl.ParentRecordId = accRenewalRec.Id;
                if(i>1 && i<4){
                    asl.LocationId =  locationRec2.Id;
                }else if(i==4){
                    asl.LocationId =  locationRec3.Id;
                }else{
                    asl.LocationId =  locationRec.Id;
                }
                asl.Status__c='Active';
                orgascLocationRecs.add(asl);
                orgLocationIds.add(orgascLocationRecs[i].LocationId);
            }
            Insert orgascLocationRecs;
            
            List<Schema.AssociatedLocation> RenewalascLocationRecs = new List<Schema.AssociatedLocation>();
            for(integer i=0;i<5;i++){
                Schema.AssociatedLocation asl = new Schema.AssociatedLocation();
                asl.Type ='other';
                asl.ParentRecordId = accRenewalRec.Id;
                if(i>1 && i<4){
                    asl.LocationId =  locationRec2.Id;
                }else if(i==4){
                    asl.LocationId =  locationRec3.Id;
                }else{
                    asl.LocationId =  locationRec.Id;
                }
                asl.Status__c='Pending Payment';
                RenewalascLocationRecs.add(asl);
                sLocationIds2.add(RenewalascLocationRecs[i].LocationId);
            }
            Insert RenewalascLocationRecs;
            
            set<String>renewLocationIds = new set<String>();
            renewLocationIds.addAll(orgLocationIds);
            renewLocationIds.addAll(sLocationIds2);
            
            
            // AscLocations End
            
            // Contacts Start
            Id RSAAgentRecordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('RSAAgent').getRecordTypeId();
            List<Contact> testOrgConList = TestDataFactory_Community.createContactsTestRec(accRec.Id, 5);
            insert testOrgConList;
            
            List<Contact>testRenewalConList = TestDataFactory_Community.createRenewalContactsTestRec(accRenewalRec.Id,5);
            insert testRenewalConList;
            
            set<String>sAgentIds2 = new set<String>();
            sAgentIds2.add(testOrgConList[0].Id);
            sAgentIds2.add(testOrgConList[1].Id);
            
            set<String>orgAgentIds = new set<String>();
            orgAgentIds.add(testOrgConList[0].Id);
            
            set<String>renewAgentIds = new set<String>();
            renewAgentIds.add(testOrgConList[1].Id);
            renewAgentIds.add(testOrgConList[3].Id);
            renewAgentIds.add(testOrgConList[4].Id);
            // Contact End
            
            
            system.runAs(testUser){
                Test.startTest();
                ReconcileAgency.AddLocationToAgency(accRec.Id,sLocationIds2, orgLocationIds, renewLocationIds);
                Test.stopTest();
            }
            
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }

    
     @isTest
    Private static void test_Method3(){
        try{
            //Test Data
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            
            Account accRenewalRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'Renewal');
            Insert accRenewalRec;
            
            Agency_Renewal__c ar = new Agency_Renewal__c(Renewal_Account__c=accRenewalRec.Id, Status__c='Payment Pending');
            insert ar;
            Agency_Renewal__c ar1 = new Agency_Renewal__c(Renewal_Account__c=accRenewalRec.Id, Status__c='Paid');
            insert ar1;
            
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;
            
            // Contacts Start
            Id RSAAgentRecordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('RSAAgent').getRecordTypeId();
            List<Contact> testOrgConList = TestDataFactory_Community.createContactsTestRec(accRec.Id, 5);
            insert testOrgConList;
            
            
            List<Contact>testRenewalConList = TestDataFactory_Community.createRenewalContactsTestRec(accRenewalRec.Id,5);
            insert testRenewalConList;
            
            String AccnID = [select id from AccountContactRelation WHERE ContactID =:testOrgConList[1].Id AND AccountId=:accRec.Id].Id;
            
            AccountContactRelation acr = new AccountContactRelation();
            acr.Status__c ='Pending Payment';
            acr.Id = AccnID;
            upsert acr;
            
            set<String>sAgentIds2 = new set<String>();
            sAgentIds2.add(testRenewalConList[0].Id);
            sAgentIds2.add(testRenewalConList[1].Id);
            
            set<String>orgAgentIds = new set<String>();
            orgAgentIds.add(testOrgConList[0].Id);
            
            set<String>renewAgentIds = new set<String>();
            renewAgentIds.add(testRenewalConList[1].Id);
            renewAgentIds.add(testRenewalConList[3].Id);
            renewAgentIds.add(testRenewalConList[4].Id);
            renewAgentIds.add(testOrgConList[1].Id);
            renewAgentIds.add(testOrgConList[0].Id);
            renewAgentIds.add(testOrgConList[2].Id);
            // Contact End
             
            // AscLocations Start
            RegulatoryAuthorizationType rAuth = TestDataFactory_Community.getRegAuthType();
            insert rAuth;
            
            BusinessLicense licrec = TestDataFactory_Community.getBusnLicTestRec(accRec.Id, conRec.Id, rAuth.Id);
            insert licrec;
            // 1 Location
            Schema.Location locationRec = TestDataFactory_Community.getLocationTestRec();
            insert locationRec;
            Schema.Address addressRec = TestDataFactory_Community.getAddessRec(locationRec.Id);
            insert addressRec;
            Schema.Location lc = new Schema.Location();
            lc.Id = locationRec.Id;
            lc.VisitorAddressId = addressRec.id;
            update lc;
            
            // 2 location
            Schema.Location locationRec2 = TestDataFactory_Community.getLocationTestRec();
            insert locationRec2;
            Schema.Address addressRec2 = TestDataFactory_Community.getAddessRec(locationRec2.Id);
            insert addressRec2;
            Schema.Location lc2 = new Schema.Location();
            lc2.Id = locationRec2.Id;
            lc2.VisitorAddressId = addressRec2.id;
            update lc2;
            
            // 3 location
            Schema.Location locationRec3 = TestDataFactory_Community.getLocationTestRec();
            insert locationRec3;
            Schema.Address addressRec3 = TestDataFactory_Community.getAddessRec(locationRec3.Id);
            insert addressRec3;
            Schema.Location lc3= new Schema.Location();
            lc3.Id = locationRec3.Id;
            lc.VisitorAddressId = addressRec3.id;
            update lc3;
            
            set<String>sLocationIds2 = new set<String>();
            set<String>orgLocationIds = new set<String>();
            
            List<Schema.AssociatedLocation> orgascLocationRecs = new List<Schema.AssociatedLocation>();
            for(integer i=0;i<5;i++){
                Schema.AssociatedLocation asl = new Schema.AssociatedLocation();
                asl.Type ='other';
                asl.ParentRecordId = accRec.Id;
                if(i>1 && i<4){
                    asl.LocationId =  locationRec2.Id;
                }else if(i==4){
                    asl.LocationId =  locationRec3.Id;
                }else{
                    asl.LocationId =  locationRec.Id;
                }
                asl.Status__c='Active';
                orgascLocationRecs.add(asl);
                orgLocationIds.add(orgascLocationRecs[i].LocationId);
            }
            Insert orgascLocationRecs;
            
            List<Schema.AssociatedLocation> RenewalascLocationRecs = new List<Schema.AssociatedLocation>();
            for(integer i=0;i<5;i++){
                Schema.AssociatedLocation asl = new Schema.AssociatedLocation();
                asl.Type ='other';
                asl.ParentRecordId = accRenewalRec.Id;
                if(i>1 && i<4){
                    asl.LocationId =  locationRec2.Id;
                }else if(i==4){
                    asl.LocationId =  locationRec3.Id;
                }else{
                    asl.LocationId =  locationRec.Id;
                }
                asl.Status__c='Pending Payment';
                RenewalascLocationRecs.add(asl);
                sLocationIds2.add(RenewalascLocationRecs[i].LocationId);
            }
            Insert RenewalascLocationRecs;
            
            set<String>renewLocationIds = new set<String>();
            renewLocationIds.addAll(orgLocationIds);
            renewLocationIds.addAll(sLocationIds2);
            
            
            // AscLocations End
            
            
            system.runAs(testUser){
                Test.startTest();
                ReconcileAgency.AddAgentToAgency(accRec.Id,sAgentIds2, orgAgentIds, renewAgentIds);
                
                ReconcileAgency.AddLocationToAgency(accRec.Id,sLocationIds2, orgLocationIds, renewLocationIds);
                
                ReconcileAgency.CreateBusinessLicense(accRec.Id);
                Test.stopTest();
            }
            
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }
   
}