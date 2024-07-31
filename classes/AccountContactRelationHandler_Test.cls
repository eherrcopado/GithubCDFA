@isTest
public class AccountContactRelationHandler_Test {
    @isTest
    Private static void TestUseCase1(){
        Try{
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            id RSAContactRecTypeid  = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('RSAContact').getRecordTypeId();
            conRec.RecordTypeId = RSAContactRecTypeid;
            update conRec;
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser; 

            
            Account accRec2 = TestDataFactory_Community.createAccountTestRec('TestAcc2', 'RSA');
            Insert accRec2;
            
            RegulatoryAuthorizationType rAuth = TestDataFactory_Community.getRegAuthType();
            insert rAuth;
            BusinessLicense licrec = TestDataFactory_Community.getBusnLicTestRec(accRec2.Id, conrec.Id, rAuth.Id);
            insert licrec;
            
            List<Contact> bulkContactsTestRecs = TestDataFactory_Community.createRenewalContactsTestRec(accRec.Id,5);
            Insert bulkContactsTestRecs;
            
            List<AccountContactRelation>BulkACRRecords = TestDataFactory_Community.createBulkACRRecords(accRec2.Id,bulkContactsTestRecs);
            Insert BulkACRRecords;
            for(AccountContactRelation acr:BulkACRRecords){
                acr.status__c = 'Pending';
            }
            update BulkACRRecords;
            
            
            Map<Id,AccountContactRelation>acrMap = New Map<Id,AccountContactRelation>();
            for(AccountContactRelation acr:BulkACRRecords){
                acrMap.put(acr.Id,acr);
            }
            
            List<AccountContactRelation>newBulkACRRecords = New List<AccountContactRelation>();
            Map<Id,AccountContactRelation>acrNewMap = New Map<Id,AccountContactRelation>();
            for(AccountContactRelation acr:BulkACRRecords){
                AccountContactRelation acrRec = New AccountContactRelation();
                acrRec.Id = acr.Id;
                acrRec.Status__c = 'Pending Payment';
                newBulkACRRecords.add(acrRec);
            }
            Update newBulkACRRecords;
            
            for(AccountContactRelation acr:newBulkACRRecords){
                acrNewMap.put(acr.Id,acr);
            }
            
            system.runAs(testUser) {
                // statements to be executed by this test user.
                Test.startTest();
                AccountContactRelationHandler ac = new AccountContactRelationHandler();
                
                AccountContactRelationHandler.beforeInsert(BulkACRRecords);
                AccountContactRelationHandler.beforeDelete(BulkACRRecords,acrMap);
                AccountContactRelationHandler.RegulatoryTrxnFee(BulkACRRecords[0], 'RSA', true);
                
                AccountContactRelationHandler.afterUpdate(BulkACRRecords,acrMap, newBulkACRRecords,acrNewMap);
                Test.stopTest();
            }
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }

    @isTest
    Private static void TestUseCase2(){
        Try{
            Test.startTest();
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            id RSAContactRecTypeid  = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('RSAContact').getRecordTypeId();
            conRec.RecordTypeId = RSAContactRecTypeid;
            update conRec;
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
            for(AccountContactRelation acr:BulkACRRecords){
                acr.status__c = 'Active';
            }
            update BulkACRRecords;
            
            
            Map<Id,AccountContactRelation>acrMap = New Map<Id,AccountContactRelation>();
            for(AccountContactRelation acr:BulkACRRecords){
                acrMap.put(acr.Id,acr);
            }
            
            List<AccountContactRelation>newBulkACRRecords = New List<AccountContactRelation>();
            Map<Id,AccountContactRelation>acrNewMap = New Map<Id,AccountContactRelation>();
            for(AccountContactRelation acr:BulkACRRecords){
                AccountContactRelation acrRec = New AccountContactRelation();
                acrRec.Id = acr.Id;
                acrRec.Status__c = 'Inactive';
                newBulkACRRecords.add(acrRec);
            }
            Update newBulkACRRecords;
            
            for(AccountContactRelation acr:newBulkACRRecords){
                acrNewMap.put(acr.Id,acr);
            }
            
            system.runAs(testUser) {
                // statements to be executed by this test user.
                AccountContactRelationHandler.afterUpdate(BulkACRRecords,acrMap, newBulkACRRecords,acrNewMap);
            }
            
            Delete BulkACRRecords;
            system.runAs(testUser) {
                AccountContactRelationHandler.beforeDelete(BulkACRRecords,acrMap);
            }
            Test.stopTest();
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }
    
    @isTest
    Private static void TestUseCase3(){
        Try{
            Test.startTest();
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            Account accRec2 = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec2;
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            id RSAContactRecTypeid  = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('RSAContact').getRecordTypeId();
            conRec.RecordTypeId = RSAContactRecTypeid;
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
    
}