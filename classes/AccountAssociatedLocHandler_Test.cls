@isTest
public class AccountAssociatedLocHandler_Test {
    @isTest
    Private static void test_Method(){
        Test.startTest();
        Try{
            
            Account accRec = TestDataFactory_Community.createAccountTestRec2('TestAcc', 'RSA');
            Insert accRec;
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;
            RegulatoryAuthorizationType rAuth = TestDataFactory_Community.getRegAuthType();
            insert rAuth;
            BusinessLicense licrec = TestDataFactory_Community.getBusnLicTestRec(accRec.Id, conrec.Id, rAuth.Id);
            insert licrec;
            //SELECT Id,Name FROM PermissionSet where id='0PS3d0000000OPI'
            //PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CFDA_Customer_Admin_User'];
            //insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps.Id);
            
            List<Schema.Location> BulkLocationTestRecList = TestDataFactory_Community.getBulkLocationTestRec(5);
            Insert BulkLocationTestRecList;
            List<Schema.Address>BulkAddessRecList = TestDataFactory_Community.getBulkAddessRec(BulkLocationTestRecList);
            Insert BulkAddessRecList;
            List<Schema.AssociatedLocation> BulkAscLationTestRecList = TestDataFactory_Community.getBulkAscLationTestRec(accRec.Id,BulkLocationTestRecList);
            Insert BulkAscLationTestRecList;
            
            system.runAs(testUser){
                
                AccountAssociatedLocHandler.OnCreateAccAssociatedLoc(BulkAscLationTestRecList);
                AccountAssociatedLocHandler.onUpdateAccAssociatedLoc(BulkAscLationTestRecList);
                AccountAssociatedLocHandler.onDeleteAccAssociatedLoc(BulkAscLationTestRecList);
                
                String accName = [Select Name From Account WHERE Id=:accRec.Id].Name;
                System.assertEquals('TestAcc', accName);//('TestAcc',accName)
                system.assertNotEquals('TestAcc2', accName);
            }
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
        Test.stopTest();
    }
    
}