public without sharing class PaymentGatewayUtility {

    public static User getUserInfo(String uId){
  		system.debug('uID =>'+uId);
        User lgdUser = [select Id,FirstName,LastName,Name,ContactId,Contact.AccountID from user where id=: uId];
        return lgdUser;
    }
    
    
    
    public static String getSiteURL(String siteNm){
        //CDFA Registered Service Agency
        Site site = [SELECT Id FROM Site WHERE UrlPathPrefix =:siteNm LIMIT 1];
        String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
        System.debug('Community url: ' + communityUrl);
        return communityUrl;
    }
    
    public static String getSfdcURL(){
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
    
    
    // This method is being used in AccountLwcController apex class & retun List<RegulatoryTrxnFeeItem> to AccountLwcController controller class
    public Static List<RegulatoryTrxnFeeItem> getFeeItems(set<Id> itmId_st){
       List<RegulatoryTrxnFeeItem> itms_lst = [Select Id,Name,RegulatoryTrxnFeeId,FeeAmount,Status__c,isSelected__c from RegulatoryTrxnFeeItem where id in: itmId_st];
        return itms_lst;
    }
    
    
    // This method is being used in AccountLwcController apex class & return all the Fee & Fee items based on Account ID
    public static  List<RegulatoryTrxnFee> getFeeAndItemsFromAccount(String actId){
        List<RegulatoryTrxnFee> fee_Itms_ls = [Select Id,Name,AccountId,Status,TotalFeeAmount,Due_Amount__c,Paid_Amount__c,
                                               (Select Id,Name,RegulatoryTrxnFeeId,FeeAmount,Status__c from RegulatoryTrxnFeeItems 
                                               where Status__c='Due' or Status__c = 'Pending') 
                                               from RegulatoryTrxnFee where AccountId =:actId AND 
                                               ( Status =  'Due' OR Status = 'Partially Paid') limit 1];
        return fee_Itms_ls;
    }
    
    
    // This method is being used in PaymentReturn_Cntrlr apex class & return the TransactionFee record based on fee id
    public static RegulatoryTrxnFee getTransactionFeeRec(String feeId){
        RegulatoryTrxnFee fee_rec =  [Select Id,Name,AccountId,Status,Payment_Status__c,TotalFeeAmount,Due_Amount__c,Paid_Amount__c from RegulatoryTrxnFee where id =:feeId];
        return fee_rec;
    }
    
    // This method is being used in PaymentReturn_Cntrlr apex class & return the list of PaymentRequest records
    public static  List<Payment_Request__c> getPaymentRequestRec(String paymentReqId){
        List<Payment_Request__c> req_rec_ls = [select Id,name,Status__c,Account__c,Regulatory_Transaction_Fee__c  from Payment_Request__c where id =: paymentReqId ];
        return req_rec_ls;
    }    
        
    // This method is being used in PaymentReturn_Cntrlr apex class  & return all the Fee & Fee items based on Fee ID
    public static  List<RegulatoryTrxnFee> getFeeAndItemsFromFee(String feeId){
        List<RegulatoryTrxnFee> fee_Itms_ls = [Select Id,Name,AccountId,Status,TotalFeeAmount,(Select Id,Name,RegulatoryTrxnFeeId,FeeAmount,Status__c,isSelected__c from RegulatoryTrxnFeeItems where Status__c = 'Pending' OR Status__c = 'Due' ) from RegulatoryTrxnFee where id=: feeId];
        return fee_Itms_ls;
    }
    
}