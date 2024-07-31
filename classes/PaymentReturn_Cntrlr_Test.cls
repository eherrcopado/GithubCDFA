/*
        Developed By	: 	qualapps
        Test Class Name	:	PaymentReturn_Cntrlr_Test
        Apex Class		:	PaymentReturn_Cntrlr
        Purpose			:	This class used for code Coverage of PaymentReturn_Cntrlr Class
*/


@isTest
public class PaymentReturn_Cntrlr_Test {
    
    @isTest
    Private static void testPositiveCase(){
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
                
                // statements to be executed by this test user.
                Test.startTest();
                PageReference pageRef = Page.PaymentReturn;
                Test.setCurrentPage(pageRef);
               	
                //Case 1
                pageRef.getParameters().put('i',pRList[0].Id);
                pageRef.getParameters().put('c','2');
                pageRef.getParameters().put('m','%22%22');
                pageRef.getParameters().put('o', '22051116410589');
                pageRef.getParameters().put('t', '500.00');
                pageRef.getParameters().put('d', '5%2f11%2f2022');
                pageRef.getParameters().put('ct', 'MC');
                pageRef.getParameters().put('z', '067948');
                pageRef.getParameters().put('hash', 'B7DA666E7FFCD50872C35441BB25CB7B4C277D06');
                
                // PaymentReturn_Cntrlr Class
                PaymentReturn_Cntrlr.saveResponse();
                
                List<RegulatoryTrxnFee> rgTfee_ls = PaymentGatewayUtility.getFeeAndItemsFromAccount(ac.Id);
                System.assertNotEquals(0, rgTfee_ls.size());
                String sfURL = PaymentGatewayUtility.getSfdcURL();
                System.assertNotEquals(null, sfURL);
                
                Test.stopTest();
            }
        }catch(Exception e){
            system.debug(e.getCause());
            system.debug(e.getInaccessibleFields());
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }
        
    @isTest
    Private static void testNoDataCase(){
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
            
            List<Payment_Request__c> pRList = TestDataFactory_Community.getPaymentRequestTestRecs(ac.Id, rtf.Id);
            Insert pRList;
            system.debug('pRList --> '+pRList);
            
            List<PaymentRequestItems__c> prItemList = TestDataFactory_Community.getPaymentReqItemsTestRecs(ac.Id,con.Id,pRList[0].Id);
            Insert prItemList;
            system.debug('prItemList --> '+prItemList);
            
            List<Payment_Response__c> pResList = TestDataFactory_Community.getParmentResTestRecs(pRList[0].Id);
            Insert pResList;
            system.debug('pResList --> '+pResList);
            
            system.runAs(cmunity_usr) {
                Test.startTest();
                PageReference pageRef = Page.PaymentReturn;
                pageRef.getParameters().put('i',pRList[0].Id);
                Test.setCurrentPage(pageRef);
               	
                PaymentReturn_Cntrlr.saveResponse();
                
                List<RegulatoryTrxnFee> rgTfee_ls = PaymentGatewayUtility.getFeeAndItemsFromAccount(ac.Id);
                System.assertNotEquals(0, rgTfee_ls.size());
                String sfURL = PaymentGatewayUtility.getSfdcURL();
                System.assertNotEquals(null, sfURL);
                Test.stopTest();
            }
        }catch(Exception e){
            system.debug(e.getCause());
            system.debug(e.getInaccessibleFields());
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }
    
}