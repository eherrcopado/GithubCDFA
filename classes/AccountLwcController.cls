public without sharing class AccountLwcController {
    
    
    @AuraEnabled(cacheable=true)
    public static String getPortalUsrActId(String accId) {
        User lgnUser = PaymentGatewayUtility.getUserInfo(UserInfo.getUserId());
        return lgnUser.Contact.AccountID;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static Map<Decimal, List<UsersinfoWrapper>> getLicenseUsersInfo(String accId) {
        
        Decimal totalValue = 0;
        List<UsersinfoWrapper> wrp_lst = new List<UsersinfoWrapper>();
        Map<Decimal, List<UsersinfoWrapper>> totalValues= new Map<Decimal, List<UsersinfoWrapper>>();
        
        try{
            
            List<RegulatoryTrxnFee> fee_Itms_ls = [Select Id,Name,AccountId,Status,TotalFeeAmount,Due_Amount__c,Paid_Amount__c,(Select Id,Name,RegulatoryTrxnFeeId,FeeAmount,Status__c from RegulatoryTrxnFeeItems where Status__c='Due' or Status__c = 'Pending') from RegulatoryTrxnFee where AccountId =:accId AND ( Status =  'Due' OR Status = 'Partially Paid') limit 1];
            
            if(!fee_Itms_ls.isEmpty()){
                for(RegulatoryTrxnFee fee_rec : fee_Itms_ls){
                    
                    totalValue = fee_rec.Due_Amount__c;
                    if(!fee_rec.RegulatoryTrxnFeeItems.isEmpty()){
                        for(RegulatoryTrxnFeeItem itm_rec : fee_rec.RegulatoryTrxnFeeItems){
                            
                            UsersinfoWrapper wrp = new UsersinfoWrapper();
                            wrp.name = itm_rec.Name;
                            wrp.recordId = itm_rec.ID;
                            //wrp.type = 'Location';
                            wrp.amount = itm_rec.FeeAmount;
                            wrp.status = itm_rec.Status__c;
                            wrp.feeId = itm_rec.RegulatoryTrxnFeeId;
                            wrp_lst.add(wrp);
                        }
                    }                
                }
            }
	
            System.debug('totalValue of Items ====>'+totalValue);
            System.debug('wrp_lst ====>'+wrp_lst);
            totalValues.Put(totalValue, wrp_lst);
        }catch(Exception e){
            System.debug(e.getStackTraceString());
        }
        return totalValues;
    }
    
    
    @AuraEnabled
    public static String createPaymentRequest(Id actId, List<UsersinfoWrapper> uiw_ls) {
        
        System.debug('createPaymentRequest actId==>'+actId);
        System.debug('createPaymentRequest uiw_ls ==>'+uiw_ls);
        System.debug('createPaymentRequest uiw_ls size==>'+uiw_ls.size());
        Map<String, List<String>> reqAndItemIds = new Map<String,List<String>>();
        String reqID;
        Decimal allItemsAmount = 0;
        String cmpltUrl = '';
        String fId = '';
        
        Set<Id> wrp_st = new Set<Id>();
        
        try{
            
            for(UsersinfoWrapper urw : uiw_ls){
                fId  = urw.feeID;
                allItemsAmount = allItemsAmount + urw.amount;
                wrp_st.add(urw.recordId);
            }
            
            Payment_Request__c pReq =  new Payment_Request__c();
            pReq.UserId__c = UserInfo.getUserId();
            pReq.StartDate__c = System.Today();
            pReq.Regulatory_Transaction_Fee__c = fId;
            pReq.Status__c = 'Pending';
            pReq.Account__c = actId;
            

            Insert pReq;
            reqID = pReq.Id;
        }catch(Exception e){
            System.debug(e.getStackTraceString());
        }
        
        User lgdUser = PaymentGatewayUtility.getUserInfo(userinfo.getUserId());
        String paymentBaseURL = Label.PaymentGatewatURL;
        String rtrnURL = '?returnurl=' + PaymentGatewayUtility.getSiteURL(Label.Portal_Name) +'/apex/PaymentReturn';
        
        String param = '&ref='+ UserInfo.getUserId()+'&id='+reqID +'&bfn='+ lgdUser.FirstName +'&bmn=&bln='+ lgdUser.LastName +'&custom=' + lgdUser.Name + ',$'+allItemsAmount+'&cfamount=2.00';
        cmpltUrl = paymentBaseURL + rtrnURL +  param;
        
        System.debug('cmpltUrl 2'+cmpltUrl);
        
        System.debug('wrp_st===>'+wrp_st);
        if(!wrp_st.isEmpty()){
            List<RegulatoryTrxnFeeItem> itms_ls = [Select Id,Name,RegulatoryTrxnFeeId,FeeAmount,Status__c from RegulatoryTrxnFeeItem where id in: wrp_st];


            List<RegulatoryTrxnFeeItem> itms_Upd_ls = new List<RegulatoryTrxnFeeItem>();
            for(RegulatoryTrxnFeeItem its : itms_ls){
                RegulatoryTrxnFeeItem rxt = new RegulatoryTrxnFeeItem();
                rxt.status__c = 'Pending';
                rxt.id = its.Id;
                itms_Upd_ls.add(rxt);
            }
			System.debug('itms_Upd_ls===>'+itms_Upd_ls);
            update itms_Upd_ls;

            
            
            
        }
        return cmpltUrl;
        
        //return reqAndItemIds;
    }
    
    
    
    
    public class UsersinfoWrapper{
        @AuraEnabled
        Public Boolean chkbox{get;set;}// Checkbox
        @AuraEnabled
        Public string name{get;set;} // Name
        @AuraEnabled
        Public string type{get;set;} // Type
        @AuraEnabled
        Public Decimal amount{get;set;} // Amount
        @AuraEnabled
        Public String recordId{get;set;}        
        @AuraEnabled
        Public String status{get;set;}
        @AuraEnabled
        Public String feeID{get;set;}
        
    }
    
    
}