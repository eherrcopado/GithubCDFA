@isTest
public class PaymentResponseHandlerTest {
    
    @isTest
    Public static void test_Method2(){
        Test.startTest();
        ID accid;
        List<Payment_Response__c> PaymentResponselist = New List<Payment_Response__c>();
        List<Payment_Response__c> PaymentResponselist1 = New List<Payment_Response__c>();
        
        Account accRec = TestDataFactory_community.createAccountTestRec('TestAcc', 'RSA');
        insert accRec;
        
        Contact conrec = TestDataFactory_Community.createContactTestRec('bscjhb', 'john', 'abc@xyz.com', accRec.Id);
        insert conrec;
        
        Id RenewalRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Account RenewalAcc = new Account();
        RenewalAcc.Name = 'RenAcc';
        RenewalAcc.Renewal_Registration_Number__c = '123445';
        RenewalAcc.Original_Account_Id__c=accRec.Id;
        RenewalAcc.RecordTypeId = RenewalRecordTypeID;
        Insert RenewalAcc;
        
        User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
        Insert testUser;
        
        system.runAs(testUser){
            RegulatoryAuthorizationType rAuth = TestDataFactory_Community.getRegAuthType();
            insert rAuth;
            
            BusinessLicense bl = TestDataFactory_Community.getBusnLicTestRec(accRec.Id, conrec.Id, rAuth.Id);
            insert bl;
            
            RegulatoryTrxnFee RTF = New RegulatoryTrxnFee();
            rtf.Comments = 'Comments';
            RTF.AccountId = accRec.id;
            rtf.Payment_Status__c = 'Paid';
            rtf.ParentRecordId = bl.id;
            rtf.Status = 'PAID';
            insert rtf;
            
            Payment_Request__c Pr = New Payment_Request__c();
            Pr.Account__c = accRec.id;
            pr.Status__c = 'Completed';
            pr.Regulatory_Transaction_Fee__c = rtf.Id;
            insert Pr;
            
            For (Payment_Request__c PayReq : [Select Id, Status__c, Account__c from Payment_Request__c Where Id=:Pr.id]){
                accid = PayReq.Account__c;
            }
            
            Payment_Response__c  paymentResponse = new Payment_Response__c();
            paymentResponse.ReceiveDate__c = System.today();
            paymentResponse.Account__c =accid;
            paymentResponse.ResponseData__c = 'paymentResponse';
            paymentResponse.ePay_Return_Code__c = 'Valic Code';
            paymentResponse.Total_Paid_Amount__c = 600;
            paymentResponse.Card_Type__c = 'Visa';
            paymentResponse.Payment_Request__c = pr.Id;
            paymentResponse.Status__c = 'Success';
            paymentResponse.ePay_Result_Message__c = 'Success';
            paymentResponse.Confirmation_Number__c = 200;
            paymentResponse.Settlement_Submission_Date__c = System.today();
            PaymentResponselist.add(paymentResponse);
            insert PaymentResponselist;
        }
        Test.stopTest();
    }
}