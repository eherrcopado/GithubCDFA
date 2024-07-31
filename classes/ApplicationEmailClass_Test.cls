@isTest
public class ApplicationEmailClass_Test {
    @isTest
    Private static void TestUseCase1(){
        Try{
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'Application_Complete');
            Insert accRec;
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;
            
            List<Account>accList = new List<Account>();
            accList.add(accRec);
            
            system.runAs(testUser) {
                // statements to be executed by this test user.
                Test.startTest();
                ApplicationEmailClass.sendEmail(accList);
                Test.stopTest();
            }
        }catch(Exception e){
            system.debug(e.getCause());
        }
    }
    
    @isTest
    Private static void TestUseCase2(){
        Try{
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'Application_Rejected');
            Insert accRec;
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;
            
            List<Account>accList = new List<Account>();
            accList.add(accRec);
            
            system.runAs(testUser) {
                // statements to be executed by this test user.
                Test.startTest();
                ApplicationEmailClass.sendEmail(accList);
                Test.stopTest();
            }
        }catch(Exception e){
            system.debug(e.getCause());
        }
    }
}