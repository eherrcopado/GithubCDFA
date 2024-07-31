/*
    Developed By    :   qualapps
    Class Name      :   PaymentGateway_LWC_Cntrlr
    Respective LWC  :   getLicenseUsers.lwc
    Test Class      :   PaymentGateway_LWC_Cntrlr_Test
    Purpose         :   This class will provide required methods for LWC component
*/

public without sharing class PaymentGateway_LWC_Cntrlr {
    
    public class AcctDetailsWrapper{
        @AuraEnabled
        Public string accRecType{get;set;}// Account record Type
        @AuraEnabled
        Public string accName{get;set;} // Account Name
        @AuraEnabled
        Public Date formAvailableDate{get;set;} // Show date from when renewal form is available
        @AuraEnabled
        Public Integer daysToRenewal{get;set;} // Days remaining for Renewal
        
    }
    
    @AuraEnabled(cacheable=true)
    public static String getPortalUsrActId(String accId) {
        User lgnUser = PaymentGatewayUtility.getUserInfo(UserInfo.getUserId());
        return lgnUser.Contact.AccountID;
    }
   
    @AuraEnabled(cacheable=true)
    public static AcctDetailsWrapper getPortalUsrActRecType(String accId) {
             AcctDetailsWrapper acctDetailswrp= new  AcctDetailsWrapper();
        try{
            //Account acct = [SELECT Id,Name,RecordType.Name FROM Account where Id=:accId LIMIT 1];
            List<Account> acctList = [SELECT Id, Name, RecordType.Name, (SELECT PeriodEnd from BusinessLicenses where Status='Active') FROM Account  where Id=:accId LIMIT 1]; 
            for(Account ac:acctList){
                acctDetailswrp.accRecType=ac.RecordType.Name;
                acctDetailswrp.accName=ac.Name;
                for(BusinessLicense bl: ac.BusinessLicenses){
                    Datetime LicenseEndDate = bl.periodEnd;
                    Date formAvailableDate = LicenseEndDate.date()-60;
                    acctDetailswrp.formAvailableDate = formAvailableDate;
                    Long dt1Long = LicenseEndDate.getTime();
                    Long dt2Long = DateTime.now().getTime();
                    Long milliseconds = dt1Long - dt2Long;
                    Long seconds = milliseconds / 1000;
                    Long minutes = seconds / 60;
                    Long hours = minutes / 60;
                    Long days = hours / 24;        
                    Integer daysToRenewal = Integer.valueOf(days);                
                    System.debug('daysToRenewal-->'+daysToRenewal);
                    acctDetailswrp.daysToRenewal = daysToRenewal;
                }
            }  
        }catch(Exception e){
            System.debug(e.getStackTraceString());
        }
        return acctDetailswrp; 
    } 

    @AuraEnabled(cacheable=true)
    public static Map<Decimal, List<UsersinfoWrapper>> getLicenseUsersInfo(String accId) {
        System.debug(accId+'  accId');
        Decimal totalValue = 0;
        List<UsersinfoWrapper> wrp_lst = new List<UsersinfoWrapper>();
        Map<Decimal, List<UsersinfoWrapper>> totalValues= new Map<Decimal, List<UsersinfoWrapper>>();
        
        try{
            
            // Working Query
            // [Select Id,Name,AccountId,Status,TotalFeeAmount,Due_Amount__c,Paid_Amount__c,(Select Id,Name,RegulatoryTrxnFeeId,FeeAmount,Status__c from RegulatoryTrxnFeeItems where Status__c='Due' or Status__c = 'Pending') from RegulatoryTrxnFee where AccountId =:accId AND ( Status =  'Due' OR Status = 'Partially Paid') limit 1];
            List<RegulatoryTrxnFee> fee_Itms_ls = PaymentGatewayUtility.getFeeAndItemsFromAccount(accId);                
            
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
        
        Map<String, List<String>> reqAndItemIds = new Map<String,List<String>>();
        User lgdUser = PaymentGatewayUtility.getUserInfo(userinfo.getUserId());
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
            
            system.debug('wrp_st==>'+wrp_st);
            Payment_Request__c pReq =  new Payment_Request__c();
            pReq.UserId__c = UserInfo.getUserId();
            pReq.StartDate__c = System.Today();
            pReq.Regulatory_Transaction_Fee__c = fId;
            pReq.Status__c = 'Pending';
            pReq.Account__c = actId;
            
            Insert pReq;
            reqID = pReq.Id;
           
           
            
            String paymentBaseURL = Label.PaymentGatewatURL;
            String rtrnURL = '?returnurl=' + PaymentGatewayUtility.getSiteURL(Label.Portal_Name) +'/apex/PaymentReturn';
            
            String param = '&ref='+ Label.Payment_URL_Param_ref +'&id='+reqID +'&bfn='+ lgdUser.FirstName +'&bmn=&bln='+ lgdUser.LastName +'&custom=' + lgdUser.Name + ',$'+allItemsAmount;
            try{
               cmpltUrl = paymentBaseURL + rtrnURL +  param;
            pReq.RequestData__c = cmpltUrl;
            update pReq; 
            }catch(Exception e){
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
        }
            
      
            
            if(!wrp_st.isEmpty()){
                List<RegulatoryTrxnFeeItem> itms_ls = PaymentGatewayUtility.getFeeItems(wrp_st);
                    //[Select Id,Name,RegulatoryTrxnFeeId,FeeAmount,Status__c from RegulatoryTrxnFeeItem where id in: wrp_st];
                
                List<RegulatoryTrxnFeeItem> itms_Upd_ls = new List<RegulatoryTrxnFeeItem>();
                for(RegulatoryTrxnFeeItem its : itms_ls){
                    RegulatoryTrxnFeeItem rxt = new RegulatoryTrxnFeeItem();
                    rxt.status__c = 'Pending';
                    rxt.isSelected__c = true;
                    rxt.id = its.Id;
                    itms_Upd_ls.add(rxt);
                }
               
                update itms_Upd_ls;
                 List<RegulatoryTrxnFeeItem> itms_Upd = [Select Id,isSelected__c from RegulatoryTrxnFeeItem where RegulatoryTrxnFeeId =:fId];
                
            }
        }catch(Exception e){
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
        }
        
        return cmpltUrl;
        
    } // EO createPaymentRequest method
    
     @AuraEnabled
    public static String agencyPaymentReq(Id actId, Id renAccId, Decimal totalAmt) { //SUMANTHCHNG
        system.debug('actId=>'+actId+'  totalAmt=>'+totalAmt);
        User lgdUser = PaymentGatewayUtility.getUserInfo(userinfo.getUserId());
        String reqID;
        Decimal allItemsAmount = 0;
        String cmpltUrl = '';
        String fId = '';
        
        Set<Id> wrp_st = new Set<Id>();
        
        try{
                allItemsAmount = totalAmt;

            
            Payment_Request__c pReq =  new Payment_Request__c();
            pReq.UserId__c = UserInfo.getUserId();
            pReq.StartDate__c = System.Today();
           // pReq.Regulatory_Transaction_Fee__c = fId;
            pReq.Status__c = 'Pending';
            pReq.Account__c = actId;
            pReq.Ren_Acc_id__c = renAccId;
            Insert pReq;
            reqID = pReq.Id;
            
            Account acc = [select id,Renewal_Process__c  from account where id=: actId];
            system.debug('acc  >>> :'+acc);
            acc.Renewal_Process__c ='In Progress';
            update acc;
            
            Account renAcc = [select id,Renewal_Process__c  from account where id=: renAccId];
            system.debug('renAccId >>> :'+renAcc );
            renAcc.Renewal_Process__c ='In Progress';
            update renAcc ;
            
            
            String paymentBaseURL = Label.PaymentGatewatURL;
            String rtrnURL = '?returnurl=' + PaymentGatewayUtility.getSiteURL(Label.Portal_Name) +'/apex/PaymentReturn';
            
            String param = '&ref='+ Label.Payment_URL_Param_ref +'&id='+reqID +'&bfn='+ lgdUser.FirstName +'&bmn=&bln='+ lgdUser.LastName +'&custom=' + lgdUser.Name + ',$'+allItemsAmount;
            cmpltUrl = paymentBaseURL + rtrnURL +  param;
            pReq.RequestData__c = cmpltUrl;
            update pReq;
            System.debug('cmpltUrl 2: '+cmpltUrl);
            //System.debug('wrp_st===>'+wrp_st);
            
            //uncommented on 09 Aug 22
            if(!wrp_st.isEmpty()){
                List<RegulatoryTrxnFeeItem> itms_ls = PaymentGatewayUtility.getFeeItems(wrp_st);
                    //[Select Id,Name,RegulatoryTrxnFeeId,FeeAmount,Status__c from RegulatoryTrxnFeeItem where id in: wrp_st];
                
                List<RegulatoryTrxnFeeItem> itms_Upd_ls = new List<RegulatoryTrxnFeeItem>();
                for(RegulatoryTrxnFeeItem its : itms_ls){
                    RegulatoryTrxnFeeItem rxt = new RegulatoryTrxnFeeItem();
                    rxt.status__c = 'Pending';
                    rxt.id = its.Id;
                    itms_Upd_ls.add(rxt);
                }
                //System.debug('itms_Upd_ls===>'+itms_Upd_ls);
                update itms_Upd_ls;
                
            }
        }catch(Exception e){
            System.debug(e.getStackTraceString());
        }
        
        return cmpltUrl;
        
    } // EO agencyPaymentReq method
    
    
    // Wrapper class to pass the data from Class to LWC cmp
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
    } // EO Wrapper class 
    
    
}