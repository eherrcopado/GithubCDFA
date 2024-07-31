@isTest
public class PenaltyCalculationHandler_Test {
    
    @isTest
    Private static void test_PenaltyMethod(){
        try{  
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            
			Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;            
            
            RegulatoryAuthorizationType RATyeprec = TestDataFactory_Community.getRegAuthType();
            Insert RATyeprec;
            
            Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            Account renewalAcc = new Account(Name = 'TestAcc',Original_Account_Id__c=accRec.Id, Registration_Number__c='123', RecordTypeId = accountRecordTypeId);
            Insert renewalAcc;
            
            BusinessLicense BLRec = TestDataFactory_Community.getBusnLicTestRec(accRec.Id, conRec.Id, RATyeprec.Id);
            Insert BLRec;
            
            system.runAs(testUser) {
                // statements to be executed by this test user.
                Test.startTest();

                PenaltyCalculationHandler.PenaltyCalculator(accRec.Id);  
                
                 Test.stopTest();
            }
            
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }   
    }    
}