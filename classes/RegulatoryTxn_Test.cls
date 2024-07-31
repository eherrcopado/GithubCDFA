@isTest
public class RegulatoryTxn_Test {
    @isTest
    Private static void test_RegTxnMethod(){
        try{
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;
            
            Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            Account renewalAcc = new Account(Name = 'TestAcc',Original_Account_Id__c=accRec.Id, Registration_Number__c='123', RecordTypeId = accountRecordTypeId);
            Insert renewalAcc;
            
            RegulatoryAuthorizationType RATyeprec = TestDataFactory_Community.getRegAuthType();
            Insert RATyeprec;
            BusinessLicense BLRec = TestDataFactory_Community.getBusnLicTestRec(accRec.Id, conRec.Id, RATyeprec.Id);
            Insert BLRec;
            
            Schema.Location loctn= TestDataFactory_Community.getLocationTestRec();
            Insert loctn;
            Schema.AssociatedLocation assoLoc= TestDataFactory_Community.getAscLationTestRec(renewalAcc.Id, loctn.Id);
            Insert assoLoc;
            
            AccountContactRelation acr= TestDataFactory_Community.getAccConRelTestRec(renewalAcc.Id, conRec.Id);
            Insert acr;
            
            system.runAs(testUser) {
                // statements to be executed by this test user.
                Test.startTest();
                
                RegulatoryTxn.CreatePaymentTxn(renewalAcc.Id, 120, 30);
                RegulatoryTxn.UpdatePaymentTxnDone(renewalAcc.Id);
                //RegulatoryTxn.UpdateRegulatoryTxnDone(RegTxnID);
                
                Test.stopTest();
            }
            
            
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
        
    }
}