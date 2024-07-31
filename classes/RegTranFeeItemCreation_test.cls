@isTest
public class RegTranFeeItemCreation_test {
    @isTest
    Private static void test_Method1(){
        try{  
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            
            Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            Account renewalAcc = new Account(Name = 'TestAcc',Original_Account_Id__c=accRec.Id, Registration_Number__c='123', RecordTypeId = accountRecordTypeId);
            Insert renewalAcc;
            
            RegulatoryAuthorizationType RATyeprec = TestDataFactory_Community.getRegAuthType();
            Insert RATyeprec;
            
            BusinessLicense BLRec = TestDataFactory_Community.getBusnLicTestRec(accRec.Id, conRec.Id, RATyeprec.Id);
            Insert BLRec;
            
            RegulatoryTrxnFee rtfrec = TestDataFactory_Community.getRegTranFeeTestRec(accRec.Id,renewalAcc.id, BLRec.id);
            insert rtfrec;
            
            List<RegulatoryTrxnFeeItem> rtfirec = TestDataFactory_Community.getRegItemsTestRecs(rtfrec.Id);
            insert rtfirec;
            
            Schema.Location locationRec = TestDataFactory_Community.getLocationTestRec();
            insert locationRec;
            
            
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;            
            
            Decimal penaltyFee = 6483.9;
            String acname = 'TESTIING';
            String Type = 'Primary';
            
            String NewLocName;
            system.runAs(testUser) {
                // statements to be executed by this test user.
                Test.startTest();
                RegTranFeeItemCreation.createPenaltyRegFeeItem(accRec.Id,penaltyFee);
                RegTranFeeItemCreation.createPenaltyRegFeeItem(NULL,penaltyFee);
                Test.stopTest();
                
                Test.startTest();
                //RegTranFeeItemCreation.createLocationRegFeeItem(rtfirec[0].Id, locationRec.id,'Primary');
                
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
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            
            Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            Account renewalAcc = new Account(Name = 'TestAcc',Original_Account_Id__c=accRec.Id, Registration_Number__c='123', RecordTypeId = accountRecordTypeId);
            Insert renewalAcc;
            
            RegulatoryAuthorizationType RATyeprec = TestDataFactory_Community.getRegAuthType();
            Insert RATyeprec;
            
            BusinessLicense BLRec = TestDataFactory_Community.getBusnLicTestRec(accRec.Id, conRec.Id, RATyeprec.Id);
            Insert BLRec;
            
            RegulatoryTrxnFee rtfrec = TestDataFactory_Community.getRegTranFeeTestRec(accRec.Id,renewalAcc.id, BLRec.id);
            insert rtfrec;
            
            List<RegulatoryTrxnFeeItem> rtfirec = TestDataFactory_Community.getRegItemsTestRecs(rtfrec.Id);
            insert rtfirec;
            
            Schema.Location locationRec = TestDataFactory_Community.getLocationTestRec();
            insert locationRec;
            
            
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;            
            
            Decimal penaltyFee = 6483.9;
            String acname = 'TESTIING';
            String Type = 'Primary';
            
            String NewLocName;
            system.runAs(testUser) {
                // statements to be executed by this test user.
                
                Test.startTest();
                RegTranFeeItemCreation.createAgentRegFeeItem(rtfirec[0].Id,'TESTIING' );                
                Test.stopTest();    
                
                Test.startTest();
                //RegTranFeeItemCreation.createLocationRegFeeItem(rtfirec[0].Id, locationRec.id,'Primary');
                
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
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            
            Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            Account renewalAcc = new Account(Name = 'TestAcc',Original_Account_Id__c=accRec.Id, Registration_Number__c='123', RecordTypeId = accountRecordTypeId);
            Insert renewalAcc;
            
            RegulatoryAuthorizationType RATyeprec = TestDataFactory_Community.getRegAuthType();
            Insert RATyeprec;
            
            BusinessLicense BLRec = TestDataFactory_Community.getBusnLicTestRec(accRec.Id, conRec.Id, RATyeprec.Id);
            Insert BLRec;
            
            RegulatoryTrxnFee rtfrec = TestDataFactory_Community.getRegTranFeeTestRec(accRec.Id,renewalAcc.id, BLRec.id);
            insert rtfrec;
            
            List<RegulatoryTrxnFeeItem> rtfirec = TestDataFactory_Community.getRegItemsTestRecs(rtfrec.Id);
            insert rtfirec;
           
            
            Schema.Location locationRec = TestDataFactory_Community.getLocationTestRec();
            insert locationRec;
            
            
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;            
            
            Decimal penaltyFee = 6483.9;
            String acname = 'TESTIING';
            String Type = 'Primary';
            
            String NewLocName;
            system.runAs(testUser) {
                Test.startTest();
                RegTranFeeItemCreation.createLocationRegFeeItem(rtfirec[0].Id, locationRec.id,'Primary');
                
                Test.stopTest();
            }
            
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }   
    }    
}