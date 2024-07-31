/*
    Developed By    :   qualapps
    Class Name      :   PaymentReturn_Cntrlr
    Respective VFP  :   PaymentReturn.vfp
    Test Class		:	PaymentGateway_Test
    Purpose         :   This class will provide required methods for PaymentReturn page
*/


public without sharing class PaymentReturn_Cntrlr {
    
    public static String rdirectCommURL{set; get;}
    public static boolean finalRslt {get; set;}
    public Static String commUrL {get; set;}
    public static String rtrnPgImg {get; set;}
    
    public static PageReference saveResponse(){
        
        Map<String,String> queryString = ApexPages.currentPage().getParameters();
        String urlVal = Apexpages.currentPage().getUrl();
        //System.debug('url : '+urlVal);        
        
        finalRslt = createResponse(queryString,urlVal);
        
        User lgnUser = PaymentGatewayUtility.getUserInfo(UserInfo.getUserId());
        
        if(finalRslt){
            // update the Payment response
            String paymentRequestId = queryString.get('i');
            FormESectionController.updateStatusPaid(lgnUser.Contact.AccountId,paymentRequestId);     
        }
        //System.debug('finalRslt : '+finalRslt);
                
        commUrL = PaymentGatewayUtility.getSiteURL(Label.Portal_Name) +'/s';
        rdirectCommURL = commUrL +'/account/'+lgnUser.Contact.AccountId+'/agents';
        rtrnPgImg = Label.ReturnPage_image; //URL.getSalesforceBaseUrl().toExternalForm() + '/'+Label.ReturnPage_image;
        System.debug('rtrnPgImg===>'+rtrnPgImg);
        return null;
    }
    
    
    
    public static boolean createResponse(Map<String,String> qString, String urlVal){
        
        boolean rslt = true;
        String fId = '';
        String reqID = qString.get('i');
        Payment_Request__c prq_rec = new Payment_Request__c();
        RegulatoryTrxnFee fee_rec_upd = new RegulatoryTrxnFee();
        List<RegulatoryTrxnFeeItem> feeItms = new List<RegulatoryTrxnFeeItem>();
        List<RegulatoryTrxnFeeItem> feeItms_upd = new List<RegulatoryTrxnFeeItem>();
        List<RegulatoryTrxnFeeItem> feeItms1 = new List<RegulatoryTrxnFeeItem>();
        try{
            if(reqID != null){
                System.debug('11111 reqID: '+reqID);
                
                List<Payment_Request__c> prq_rec_ls = PaymentGatewayUtility.getPaymentRequestRec(reqID);
                //[select Id,name,Status__c,Account__c,Regulatory_Transaction_Fee__c  from Payment_Request__c where id =: reqID ];
                System.debug('11111 prq_rec_ls: '+prq_rec_ls);
                
                for(Payment_Request__c prq : prq_rec_ls){
                    fId = prq.Regulatory_Transaction_Fee__c;
                    prq_rec = prq;
                }
                
                //System.debug('Fee Id ====>'+fId);
                System.debug('reqID in PRC ====>'+reqID);
                
                // working soql :: // [Select Id,Name,AccountId,Status,TotalFeeAmount,(Select Id,Name,RegulatoryTrxnFeeId,FeeAmount,Status__c from RegulatoryTrxnFeeItems where Status__c = 'Pending') from RegulatoryTrxnFee where id=: fId];
                List<RegulatoryTrxnFee> fee_ls = PaymentGatewayUtility.getFeeAndItemsFromFee(fId);
                
                
             
                for(RegulatoryTrxnFee fee_rec : fee_ls){
                    feeItms1 = fee_rec.RegulatoryTrxnFeeItems;
                    for(RegulatoryTrxnFeeItem fitem : feeItms1){
                        if(fitem.isSelected__c==true){
                          System.debug('fitem ====>'+fitem);  
                           feeItms.add(fitem) ;
                        }
                        
                    }
                    
                }
                system.debug('feeItms in PRC==>'+feeItms);
                
                if(qString.get('c') != null &&  qString.get('m') != null && qString.get('o') != null &&  qString.get('t') != null && 
                   qString.get('d') != null && qString.get('ct') != null && qString.get('z') != null && qString.get('hash') != null && 
                   qString.get('i') != null ){
                       System.debug('22222 reqID: '+qString);
                       Payment_Response__c prs = new Payment_Response__c();
                       prs.ResponseData__c = urlVal;
                       prs.ePay_Return_Code__c =   qString.get('c');
                       prs.ePay_Result_Message__c = qString.get('m');
                       prs.Confirmation_Number__c = Decimal.valueOf( qString.get('o'));
                       prs.Total_Paid_Amount__c = Decimal.valueOf( qString.get('t'));
                       //prs.Settlement_Submission_Date__c = Date.valueOf( qString.get('d'));
                       prs.Authorization_Code__c = qString.get('z');
                       prs.Card_Type__c = qString.get('ct');
                       prs.Unique_ID__c = qString.get('i');
                       prs.hash__c = qString.get('hash');
                       prs.ReceiveDate__c = System.today();
                       prs.Regulatory_Transaction_Fee__c = fId;
                       prs.Payment_Request__c =reqID;
                       prs.Status__c = 'Success';
                       prs.account__c = prq_rec.Account__c;
                       insert prs;
                       
                       prq_rec.EndDate__c = System.Today();
                       prq_rec.Status__c = 'Completed';
                       update prq_rec;
                       
                       for(RegulatoryTrxnFeeItem prqItm: feeItms){
                           prqItm.status__c = 'Paid';
                           prqItm.Payment_Request__c = reqID;
                           feeItms_upd.add(prqItm);
                           System.debug('33333 success ');
                           System.debug('33333 reqID: '+feeItms_upd.size());
                       }
                       update feeItms_upd;
                       
                       
                       // doing after update to set the status of Fee as we the source fields are formula fields
                       fee_rec_upd = PaymentGatewayUtility.getTransactionFeeRec(fId);
                       //[Select Id,Name,AccountId,Status,Payment_Status__c,TotalFeeAmount,Due_Amount__c,Paid_Amount__c from RegulatoryTrxnFee where id =:fId];
                       
                       
                       System.debug('fee_rec_upd====>'+fee_rec_upd);
                       fee_rec_upd.Paid_Date__c = system.today();
                       System.debug('fee_rec_upd.Due_Amount__c===>'+fee_rec_upd.Due_Amount__c);
                       if(Integer.valueOf(fee_rec_upd.Due_Amount__c) > 0){
                          fee_rec_upd.Payment_Status__c = 'Partially Paid';
                           System.debug('updating paid ');
                       }else if(fee_rec_upd.TotalFeeAmount == fee_rec_upd.Paid_Amount__c){
                           fee_rec_upd.Status = 'Paid';
                           fee_rec_upd.Payment_Status__c = 'Paid';
                           System.debug('updating paid ');   
                       }
                       update fee_rec_upd;
                       
                       
                       
                       System.debug('33333 after upate ');
                       
                       System.debug('record inserted===>'+prs.id);
                   }else if(qString.get('c') == null &&  qString.get('m') == null && qString.get('o') == null &&  qString.get('t') == null && 
                            qString.get('d') == null && qString.get('ct') == null && qString.get('z') == null && qString.get('hash') == null && 
                            qString.get('i') != null ){
                                
                                System.debug('4444 failed ');
                                prq_rec.EndDate__c = System.Today();
                                prq_rec.Status__c = 'Cancelled';
                                update prq_rec;
                                
                                for(RegulatoryTrxnFeeItem prqItm: feeItms){
                                    prqItm.status__c = 'Due';
                                    feeItms_upd.add(prqItm);
                                    System.debug('4444 success ');
                                    System.debug('4444 reqID: '+feeItms_upd.size());
                                }
                                update feeItms_upd;
                                rslt = false;
                                
                                // doing after update to set the status of Fee as we the source fields are formula fields
                                fee_rec_upd = PaymentGatewayUtility.getTransactionFeeRec(fId);
                                //fee_rec_upd = [Select Id,Name,AccountId,Status,Payment_Status__c,TotalFeeAmount,Due_Amount__c,Paid_Amount__c from RegulatoryTrxnFee where id =:fId];
                                fee_rec_upd.Status = 'Due';
                                update fee_rec_upd;
                            }
            }
        }catch(Exception e){
            System.debug('Found an exception ==>'+e.getMessage());
            System.debug('Exception stack ==>'+e.getStackTraceString());
        }
        
        return rslt;
        
    } // EO method createResponse
    
}