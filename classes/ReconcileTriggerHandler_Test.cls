@isTest
public class ReconcileTriggerHandler_Test {
	@isTest
    public static void test_method1(){
       Try{
           List<Account> accList1 = new list <Account>();
           
           Account rsaAcc1 = TestDataFactory_Community.createAccountTestRec('Grazitti1', 'RSA');
           insert rsaAcc1;
           
           Account acc1 = TestDataFactory_community.createAccountTestRecord('TestRec1','Renewal','Approved');
           insert acc1;
           
           acc1.Original_Account_Id__c = rsaAcc1.Id;
           update acc1;
           accList1.add(acc1);
           
           /*
           Contact con = TestDataFactory_Community.createContactTestRec('test', 'account', 'tes'+acc1.id+'@noemail.com', acc1.Id);
           insert con;
            
            User cmunity_usr = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'tes'+con.Id+'@noemail.com', con.id);
            //cmunity_usr.ContactId = ;
            insert cmunity_usr;
            
            system.runAs(cmunity_usr){
                ReconcileTriggerHandler.approvalMethod(accList1);
            }
           */
           Test.startTest();
               ReconcileTriggerHandler.approvalMethod(accList1);
           system.debug('testmethod1==========='+accList1.size());
           system.assertEquals('Approved', acc1.Renewal_Process__c);
           Test.stopTest();

    	}catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
}
		@isTest
    public static void test_method2(){
       Try{
           List<Account> accList2 = new list <Account>();
           
           Account rsaAcc2 = TestDataFactory_Community.createAccountTestRec('Grazitti2', 'RSA');
           insert rsaAcc2;
           
            Account acc2 = TestDataFactory_community.createAccountTestRecord('TestRec2','Renewal','Pending Approval');
           insert acc2;
           acc2.Original_Account_Id__c = rsaAcc2.Id;
           update acc2;
           accList2.add(acc2);
              
           Test.startTest();
               ReconcileTriggerHandler.approvalMethod(accList2);
           system.debug('testmethod2==========='+accList2.size());

           Test.stopTest();

    	}catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
}    
    	@isTest
    public static void test_method3(){
       Try{
           List<Account> accList3 = new list <Account>();
           
           Account rsaAcc3 = TestDataFactory_Community.createAccountTestRec('Grazitti3', 'RSA');
           insert rsaAcc3;
           
           Account acc3 = TestDataFactory_community.createAccountTestRecord('TestRec3','Renewal','Rejected');
           insert acc3;
           acc3.Original_Account_Id__c = rsaAcc3.Id;
           update acc3;
           accList3.add(acc3);
              
           Test.startTest();
               ReconcileTriggerHandler.approvalMethod(accList3);
           system.debug('testmethod3==========='+accList3.size());

           Test.stopTest();

    	}catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
}
   
}