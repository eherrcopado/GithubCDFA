@isTest
public class contactTriggerHandler_test {
    @isTest
    Private static void test_Method2(){
        try{
            List<Account> actList = new List<Account>();
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            Set<Id> accId = new Set<Id>();
            accId.add(accRec.Id);
            actList.add(accRec);
            
            List<Contact> conList = new List<Contact>();
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            conList.add(conRec);
            
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;
            
            Account accRec2 = TestDataFactory_Community.createAccountTestRec('TestAcc2', 'RSA');
            Insert accRec2;
            
            List<Contact> bulkContactsTestRecs = TestDataFactory_Community.createRenewalContactsTestRec(accRec.Id,5);
            Insert bulkContactsTestRecs;
            
            List<AccountContactRelation>BulkACRRecords = TestDataFactory_Community.createBulkACRRecords(accRec2.Id,bulkContactsTestRecs);
            Insert BulkACRRecords;
            
            Map<Id,AccountContactRelation>acrMap = New Map<Id,AccountContactRelation>();
            for(AccountContactRelation acr:BulkACRRecords){
                acr.Status__c = 'Active';
            }
            update BulkACRRecords;
            
            delete BulkACRRecords;
            delete acrMap.values();            
            
            system.runAs(testUser) {
                Test.startTest();
                //contactTriggerHandler.afterDeleteMethodCTH(asoLocOldList, acrMap);
                contactTriggerHandler.countUpdate(BulkACRRecords,'DELETE');
                Test.stopTest();
            }  
        }catch(Exception e){
            system.debug(e.getCause());
        }
    }
}