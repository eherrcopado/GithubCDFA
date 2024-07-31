@isTest
public class AccountLwcController_Test {
    @isTest
    Private static void testData(){
        
        Try{
            
            Account ac = TestDataFactory_Community.createAccountTestRec('Grazitti', 'RSA');
            insert ac; 
            
            Contact con = TestDataFactory_Community.createContactTestRec('test', 'account', 'tes'+ac.id+'@noemail.com', ac.Id);
            insert con;
            
            User cmunity_usr = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'tes'+con.Id+'@noemail.com', con.id);
            
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
            
            Account renRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'Renewal');
            Insert renRec;
            
            system.runAs(cmunity_usr) {
                // statements to be executed by this test user.
                Test.startTest();
                
                // getPortalUsrActId Method
                String AccountID = AccountLwcController.getPortalUsrActId(ac.Id);
                system.assertEquals(AccountID, ac.Id);
                
                List<RegulatoryTrxnFee> rtfList = PaymentGatewayUtility.getFeeAndItemsFromAccount(ac.Id);
                Map<Decimal, List<AccountLwcController.UsersinfoWrapper>> ssersinfoWrapperMap=AccountLwcController.getLicenseUsersInfo(ac.Id);
                
                List<AccountLwcController.UsersinfoWrapper>wrp_lst2 = new List<AccountLwcController.UsersinfoWrapper>();
                AccountLwcController.UsersinfoWrapper wrp = new AccountLwcController.UsersinfoWrapper();
                wrp.chkbox=true;
                wrp.name = 'Test';
                wrp.amount=100;
                wrp_lst2.add(wrp);
                AccountLwcController.createPaymentRequest(ac.Id,wrp_lst2);
                
                Test.stopTest();
            }
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
        
    }

}