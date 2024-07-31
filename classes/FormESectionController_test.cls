@isTest
public class FormESectionController_test {
    @isTest
    Private static void test_Method(){
        
        Try{
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;
            List<Contact> testConList = TestDataFactory_Community.createContactsTestRec(accRec.Id, 5);
            insert testConList;
            Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            Account renewalAcc = new Account(Name = 'TestAcc', Registration_Number__c='123', RecordTypeId = accountRecordTypeId);
            Insert renewalAcc;
            Agency_Renewal__c ar = new Agency_Renewal__c(Renewal_Account__c=renewalAcc.Id, Status__c='Payment Pending');
            insert ar;
            
            List<String> myl = new List<String>();
            myl.add('mark z');
            myl.add('My business owns the standards used by my Agency/Agents');
            myl.add('My business uses certified standards owned by county weights');
            myl.add('My business uses certified standards owned by a third-party');
          
            List<Id> PaymentRequestId = New List<Id>();
            List<Payment_Response__c> PaymentResponselist = New List<Payment_Response__c>();
            Payment_Request__c Pr = New Payment_Request__c();
            Pr.Account__c = accRec.id;
            pr.Status__c = 'Completed';
            insert Pr;
        
         PaymentRequestId.add(Pr.id);
            
            Payment_Response__c Prs = New Payment_Response__c();
            Prs.Account__c =accRec.id ;
            Prs.Unique_ID__c = Pr.id;
            Prs.Authorization_Code__c = 'Code';
            Prs.Card_Type__c = 'MC';        
            Prs.Total_Paid_Amount__c = 1500;
            PaymentResponselist.add(Prs);
            insert PaymentResponselist;
            
           /* system.runAs(testUser){
                // getSelectedValues
                FormESectionController.getSelectedValues(myl, accRec.Id);
                
                // updateAgencyApproval
                FormESectionController.updateAgencyApproval(myl, accRec.Id, 'sd');//SIGNTURE                
                List<Agency_Renewal__c> arl = [select id FROM Agency_Renewal__c Where Account__c =: accRec.Id];
                system.debug('size-- '+arl.size());
            } */
            
            List<Agency_Renewal__c> arList = new List<Agency_Renewal__c>();
            for(integer i=0; i<5; i++){
                Agency_Renewal__c agency1 = new Agency_Renewal__c();
                agency1.Business_certified_standards_Third_Party__c =false;
                agency1.Business_owns_the_standards_Agency__c = false;
                agency1.Business_uses_certified_standards_owned__c = false;
                agency1.Renewal_Account__c =renewalAcc.Id;
                agency1.Created_Date__c=DateTime.now();
                agency1.Status__c = 'In Progress';
                arList.add(agency1);
            }
            insert arList;
            
            system.runAs(testUser){
                Test.startTest();
                // getSelectedValues
               // FormESectionController.getSelectedValues_NOTUSED(myl, accRec.Id);
                
                
                // updateAgencyApproval
               FormESectionController.updateAgencyApproval(myl, accRec.Id, renewalAcc.Id, 'sd');//SIGNTURE
                FormESectionController.updateAgencyApproval(myl, accRec.Id, renewalAcc.Id, 'SIGNTURE');//SIGNTURE
                //call getAgencyRenewal
               FormESectionController.getAgencyRenewal(accRec.Id, renewalAcc.Id);
              
                
                // updateStatusPaid
              FormESectionController.updateStatusPaid(accRec.Id, Pr.id);
                
               // FormESectionController.updateAgencyApproval(myl, accRec.Id, 'SIGNTURE');
                
            }
            Test.stopTest();
            
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
        
    }
}