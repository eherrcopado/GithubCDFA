@isTest
public class RenewalAgencyController_Test {
    @isTest
    Private static void test_Method(){
        try{
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;
            Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            Account renewalAcc = new Account(Name = 'TestAcc', Registration_Number__c='123', RecordTypeId = accountRecordTypeId);
            Insert renewalAcc;
            //Agency_Renewal__c ar = new Agency_Renewal__c(Renewal_Account__c=renewalAcc.Id, Status__c='Payment Pending');
            //insert ar;
            List<Contact> testConList = TestDataFactory_Community.createContactsTestRec(accRec.Id, 5);
            insert testConList;
            Asset assetRec = TestDataFactory_Community.createAssetTestRec(accRec.Id,conRec.Id);
            Insert assetRec;
            
            Schema.Location locRec = TestDataFactory_Community.getLocationTestRec();
            Insert locRec;
            RegulatoryAuthorizationType rAuth = TestDataFactory_Community.getRegAuthType();
            insert rAuth;
            BusinessLicense licrec = TestDataFactory_Community.getBusnLicTestRec(accRec.Id, conRec.Id, rAuth.Id);
            insert licrec;
            Schema.AssociatedLocation assloc = TestDataFactory_Community.getAscLationTestRec(accRec.Id,locRec.Id);
            Insert assloc;
            Schema.Address addrec = testdatafactory_community.getAddessRec(locRec.Id);
            Insert addrec;
            
            
            system.runAs(testUser) {
                // statements to be executed by this test user.
                Test.startTest();
                RenewalAgencyController.getRegTxnFee(accRec.Id);
                
                //getRenAccfromPmtReq
                RenewalAgencyController.getRenAccfromPmtReq(accRec.Id);
                
                //getBusLicenseID
                RenewalAgencyController.getBusLicenseID(accRec.Id);
                
                //createRenewalAgency
                RenewalAgencyController.UserAccountWrapper wrpData =  RenewalAgencyController.createRenewalAgency(accRec.Id);
                
                //getRecCount
                RenewalAgencyController.getRecCount(accRec.Id, 'AGENT');
                RenewalAgencyController.getRecCount(accRec.Id, 'LOCATION');
                
                //getInitialData
                List<sObject>getInitialData = RenewalAgencyController.getInitialData(accRec.Id, 'RENACCPMTREQ');
                List<sObject>getInitialData1 = RenewalAgencyController.getInitialData(accRec.Id, 'AGENT');
                List<sObject>getInitialData2 = RenewalAgencyController.getInitialData(accRec.Id, 'RENEWAGENCY');
                List<sObject>getInitialData3 = RenewalAgencyController.getInitialData(accRec.Id, 'AGNREGNUM');
                List<sObject>getInitialData4 = RenewalAgencyController.getInitialData(accRec.Id, 'DEVICE');
                List<sObject>getInitialData5 = RenewalAgencyController.getInitialData(accRec.Id, 'ACCAGENT');
                List<sObject>getInitialData6 = RenewalAgencyController.getInitialData(accRec.Id, 'ACCLOCATION');
                List<sObject>getInitialData7 = RenewalAgencyController.getInitialData(accRec.Id, 'ACCDEVICE');
                List<sObject>getInitialData8 = RenewalAgencyController.getInitialData(accRec.Id, 'BUSLIC');
                List<sObject>getInitialData9 = RenewalAgencyController.getInitialData(accRec.Id, 'REGTXN');
                List<sObject>getInitialData10 = RenewalAgencyController.getInitialData(accRec.Id, 'REGTXNITEM');
                
                
                
                //updateRenewalAgency
                RenewalAgencyController.updateRenewalAgency(accRec.Id, '123456', 'test@email.com',
                                                            'parker road ', 'New York', 'CA', 
                                                            'USA', '78654', accRec.name, 'Corporation', '');
                
                //updateAgencyRenewalFormStatus
                RenewalAgencyController.updateAgencyRenewalFormStatus(accRec.Id, 'Form F Completed', renewalAcc.Id);
                
                //getRegTxnFee
                
                
                //saveAgents
                
                RenewalAgencyController.ContactWrapper conWrap = new RenewalAgencyController.ContactWrapper();
                conWrap.Name='TestAgent';
                conWrap.Phone='123123123';
                conWrap.conID=testConList[0].Id;
                
                List<RenewalAgencyController.ContactWrapper> conWrapList= new List<RenewalAgencyController.ContactWrapper>();
                conWrapList.add(conWrap);
                string accId=accRec.Id;
                RenewalAgencyController.saveAgents(accId, conWrapList);
                
                
                Test.stopTest();
            }
            
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }

}