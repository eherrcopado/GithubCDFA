@isTest
Public class createUserFromContact_test{
    @isTest
    Private static void TestUseCase(){
        Try{
            Test.startTest();
            List<Profile> profileList = [Select Id from Profile where Name=: 'CDFA Community Login User' limit 1];
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            Account accRec2 = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec2;
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            id RSAContactRecTypeid  = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('RSAContact').getRecordTypeId();
            conRec.RecordTypeId = RSAContactRecTypeid;
            conRec.CDFA_User_Status__c ='Activated';
            update conRec;
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;
            
            List<Contact> bulkContactsTestRecs = TestDataFactory_Community.createRenewalContactsTestRec(accRec.Id,5);
            Insert bulkContactsTestRecs;
            List<AccountContactRelation>BulkACRRecords = TestDataFactory_Community.createBulkACRRecords(accRec2.Id,bulkContactsTestRecs);
            Insert BulkACRRecords;
            Map<Id,AccountContactRelation>acrMap = New Map<Id,AccountContactRelation>();
            for(AccountContactRelation acr:BulkACRRecords){
                acr.status__c = 'Pending Payment';
                acr.initiated_by__c = 'Agency';
                acrMap.put(acr.Id,acr);
            }
            update BulkACRRecords;
            system.runAs(testUser) {
                AccountContactRelationHandler.afterInsert(BulkACRRecords,acrMap);
            }
            
            Test.stopTest();
        }catch(Exception e){
            system.debug(e.getCause());
        }
    } 
 
    public static void TestUseCase1(){
        Test.startTest();
        Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
        Insert accRec;
        Contact cnt = new Contact();
        cnt.FirstName='firstname';
        cnt.LastName='lName';
        cnt.email='test@test.com';
        cnt.AccountId=accRec.id;
        insert cnt;
        cnt.CDFA_User_Status__c ='Activated';
        update cnt;
        Test.stopTest();
         
    }
    public static void TestUseCase2(){
        Test.startTest();
        Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
        Insert accRec;
        Contact cnt = new Contact();
        cnt.FirstName='firstname';
        cnt.LastName='lName';
        cnt.email='test1@test.com';
        cnt.AccountId=accRec.id;
        insert cnt;
        cnt.CDFA_User_Status__c ='Pending';
        update cnt;
        Test.stopTest();
    }
}