@isTest
public class BatchAgentAgencyCount_Test {
	@isTest
    Private static void TestUseCase1(){
        Try{
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;
            RegulatoryAuthorizationType rAuth = TestDataFactory_Community.getRegAuthType();
            insert rAuth;
            BusinessLicense licrec = TestDataFactory_Community.getBusnLicTestRec(accRec.Id, conrec.Id, rAuth.Id);
            insert licrec;
            
            List<Contact> bulkContactsTestRecs = TestDataFactory_Community.createRenewalContactsTestRec(accRec.Id,5);
            Insert bulkContactsTestRecs;
            Account accRec2 = TestDataFactory_Community.createAccountTestRec('TestAcc2', 'RSA');
            Insert accRec2;
            List<AccountContactRelation>BulkACRRecords = TestDataFactory_Community.createBulkACRRecords(accRec2.Id,bulkContactsTestRecs);
            Insert BulkACRRecords;
            
            AddressWrapper wrapper= new AddressWrapper();
            wrapper.street='1 INFINITE LOOP';
            wrapper.city='CUPERTINO';
            wrapper.state='CA';
            wrapper.postalcode='95014';
            wrapper.country='USA';
            wrapper.county='Calaveras';
            wrapper.parentRecordId= accRec.Id;
            wrapper.locationName= 'Test Loc 95014';
            wrapper.type = 'Other';
            
            system.runAs(testUser) {
                // statements to be executed by this test user.
                Test.startTest();
                
                BatchAgentAgencyCount obj = new BatchAgentAgencyCount();
                DataBase.executeBatch(obj); 
                
                Test.stopTest();
            }
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }
}