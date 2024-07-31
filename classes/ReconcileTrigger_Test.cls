@isTest
public class ReconcileTrigger_Test {
	@isTest
    Private static void Approved_Method(){
        
        Try{
            Account accRec1 = TestDataFactory_Community.createAccountTestRec('TestAcc', 'Renewal');
            Insert accRec1;
            accRec1.Renewal_Process__c = 'Approved';
            update accRec1;
            
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'Renewal');
            Insert accRec;
            accRec.Renewal_Process__c = 'Pending Approval';
            update accRec;
            
            
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;
            
            system.runAs(testUser) {
                Test.startTest();
                
                Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
                Account acc = new Account();
                acc.Name = 'Update Acc';
                acc.Renewal_Process__c = 'Pending Approval';
                acc.Id = accRec.Id;
                acc.RecordTypeId = accountRecordTypeId;
                update acc;
                
                Account acc1 = new Account();
                acc1.Name = 'Update Acc1';
                acc1.Renewal_Process__c = 'Approved';
                acc1.Id = accRec1.Id;
                acc1.RecordTypeId = accountRecordTypeId;
                update acc1;
                
                Test.stopTest();
            }
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
        
    }
    
    @isTest
    Private static void Approved_Method2(){
        
        Try{
            Account accRec1 = TestDataFactory_Community.createAccountTestRec('TestAcc', 'Renewal');
            Insert accRec1;
            accRec1.Renewal_Process__c = 'Rejected';
            update accRec1;
            
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'Renewal');
            Insert accRec;
            accRec.Renewal_Process__c = 'Rejected';
            update accRec;
            
            
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;
            
            system.runAs(testUser) {
                Test.startTest();
                
                Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
                Account acc = new Account();
                acc.Name = 'Update Acc';
                acc.Renewal_Process__c = 'Rejected';
                acc.Id = accRec.Id;
                acc.RecordTypeId = accountRecordTypeId;
                update acc;
                
                Account acc1 = new Account();
                acc1.Name = 'Update Acc1';
                acc1.Renewal_Process__c = 'Rejected';
                acc1.Id = accRec1.Id;
                acc1.RecordTypeId = accountRecordTypeId;
                update acc1;
                
                Test.stopTest();
            }
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
        
    }
}