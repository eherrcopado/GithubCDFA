@isTest
public class PaymentResponse_Test {
    
    @isTest
    Private static void testCase(){
        Try{
            Account ac = TestDataFactory_Community.createAccountTestRec('Grazitti', 'RSA');
            insert ac; 
            
            Contact con = TestDataFactory_Community.createContactTestRec('test', 'account', 'tes'+ac.id+'@noemail.com', ac.Id);
            insert con;
            
            User cmunity_usr = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'tes'+con.Id+'@noemail.com', con.id);
            //cmunity_usr.ContactId = ;
            insert cmunity_usr;
            
            RegulatoryAuthorizationType raType = TestDataFactory_Community.getRegAuthType();
            Insert raType;
            system.debug('raType - '+raType);
            
            BusinessLicenseApplication blApll = TestDataFactory_Community.getBusnLicAppTestRec(ac.Id,con.id,raType.Id);
            Insert blApll;
            system.debug('blApll-- '+blApll);
            
            RegulatoryTrxnFee rtf = new RegulatoryTrxnFee(AccountId=ac.id,Status='Due', ParentRecordId = blApll.id);
            insert rtf;
            
            List<RegulatoryTrxnFeeItem> rtfItemList = TestDataFactory_Community.getRegItemsTestRecs(rtf.Id);
            Insert rtfItemList;
            
            List<PaymentGateway_LWC_Cntrlr.UsersinfoWrapper> wrp_lst= new List<PaymentGateway_LWC_Cntrlr.UsersinfoWrapper>();     
            for(RegulatoryTrxnFeeItem itm_rec : rtfItemList){
                PaymentGateway_LWC_Cntrlr.UsersinfoWrapper wrp = new PaymentGateway_LWC_Cntrlr.UsersinfoWrapper();
                wrp.name = itm_rec.Name;
                wrp.recordId = itm_rec.ID;
                //wrp.type = 'Location';
                wrp.amount = itm_rec.FeeAmount;
                wrp.status = itm_rec.Status__c;
                wrp.feeId = itm_rec.RegulatoryTrxnFeeId;
                wrp_lst.add(wrp);
            }
            
            // Payment_Request__c object Data
            List<Payment_Request__c> pRList = TestDataFactory_Community.getPaymentRequestTestRecs(ac.Id, rtf.Id);
            Insert pRList;
            system.debug('pRList --> '+pRList);
            
            // PaymentRequestItems__c Obj
            List<PaymentRequestItems__c> prItemList = TestDataFactory_Community.getPaymentReqItemsTestRecs(ac.Id,con.Id,pRList[0].Id);
            Insert prItemList;
            system.debug('prItemList --> '+prItemList);
            
            // Payment_Response__c object Data
            List<Payment_Response__c> pResList = TestDataFactory_Community.getParmentResTestRecs(pRList[0].Id);
            Insert pResList;
            system.debug('pResList --> '+pResList);
            
            system.runAs(cmunity_usr) {
                Test.startTest();
                PaymentResponseHandler pr = new PaymentResponseHandler();
                pr.Paymentresponse(pResList);
                Test.stopTest();
            }
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }
}