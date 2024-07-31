@isTest
public class RSAAlTriggerHandler_Test {
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
            
            List<Schema.Location> BulkLocationTestRecList = TestDataFactory_Community.getBulkLocationTestRec(5);
            Insert BulkLocationTestRecList;
            List<Schema.Address>BulkAddessRecList = TestDataFactory_Community.getBulkAddessRec(BulkLocationTestRecList);
            Insert BulkAddessRecList;
            List<Schema.AssociatedLocation> BulkAscLationTestRecList = TestDataFactory_Community.getBulkAscLationTestRec(accRec.Id,BulkLocationTestRecList);
            Insert BulkAscLationTestRecList;
            Map<Id,AssociatedLocation>asoLocNewMap = New Map<Id,AssociatedLocation>();
            for(Schema.AssociatedLocation asl:BulkAscLationTestRecList){
                asoLocNewMap.put(asl.Id, asl);
            }
            
            system.runAs(testUser) {
                // statements to be executed by this test user.
                Test.startTest();
                Triggers_Enable__mdt triggerisActive = Triggers_Enable__mdt.getInstance('RSAAlTrigger');
                StopRecursiveHandler.run = false;
                if(triggerisActive.Is_Active__c == TRUE){
                    RSAAlTriggerHandler.beforeInsertRSAAl(BulkAscLationTestRecList);
                    RSAAlTriggerHandler.beforeDeleteRSAAl(BulkAscLationTestRecList,asoLocNewMap);
                    
                    RSAAlTriggerHandler.afterInsertRSAAl(BulkAscLationTestRecList,asoLocNewMap);
                    RSAAlTriggerHandler.afterUpdateRSAAl(BulkAscLationTestRecList,asoLocNewMap,BulkAscLationTestRecList,asoLocNewMap);
                    RSAAlTriggerHandler.afterDeleteRSAAl(BulkAscLationTestRecList,asoLocNewMap);
                }
                Test.stopTest();
            }
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }
}