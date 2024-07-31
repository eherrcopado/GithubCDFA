public class PaymentGatewayQCListController {

    @AuraEnabled
    public static List<Contact> getRelatedContact(Id recordId)
    {
        List<Contact> Conlist = [Select id, name,Role__c,Payment_Statu__c,Amount__c from Contact where AccountId =: recordId];
        return Conlist;
    }
    
    @AuraEnabled
    public static Decimal getTotalAmountContact(Id recordId)
    {
        Decimal countamount=0;
        List<Contact> Conlist = [Select id, name,Role__c,Payment_Statu__c,Amount__c from Contact where AccountId =: recordId];
        for(Contact objCont : Conlist){
            countamount = countamount+objCont.Amount__c;
        }
        return countamount;
    }
    
    @AuraEnabled
    public static List<wrapper> getRelatedLocation(Id recordId)
    {
        List<wrapper> lstWrapper = new List<wrapper>();
        List<AssociatedLocation> associatedloclist = [Select Location.Name,Location.LocationType,Amount__c,Payment_Status__c from AssociatedLocation where ParentRecordId =: recordId];
        System.debug(associatedloclist);
        for(AssociatedLocation al : associatedloclist){
          wrapper wc = new wrapper();
          wc.locationName = al.Location.Name;
          wc.locationType =al.Location.LocationType;
          wc.amount = al.Amount__c;
          wc.paymentStatus = al.Payment_Status__c;
          lstWrapper.add(wc);
        }
        
        return lstWrapper;
    }
    
     @AuraEnabled
    public static Decimal getAmountLocation(Id recordId)
    {
        Decimal countamount=0;
        List<AssociatedLocation> associatedloclist = [Select Location.Name,Location.LocationType,Amount__c,Payment_Status__c from AssociatedLocation where ParentRecordId =: recordId];
        for(AssociatedLocation al : associatedloclist){
          countamount = countamount+al.Amount__c;
        }
        
        return countamount;
    }
    
    @AuraEnabled
    public static void insertPaymentRequest(Id recordId)//List<Payment_Request__c> lstPaymentRequest
    {

        List<Payment_Request__c> Conlist = [Select id from Payment_Request__c ];
        for(Payment_Request__c objCont : Conlist){
           // countamount = countamount+objCont.Amount__c; where Account__c =: lstPaymentReques
        }
        
        Payment_Request__c paymentReq =  new Payment_Request__c();
        //paymentReq.UserId__c = 'TestUserId';
        paymentReq.StartDate__c = System.Today();
        paymentReq.EndDate__c = System.Today();
        paymentReq.RefId__c = '123';
        paymentReq.Status__c = 'Pending';
        paymentReq.Account__c = recordId;
        //paymentReq.Amount__c=100;
        Insert paymentReq;
        
        
        PaymentRequestItems__c paymentReqItems = new PaymentRequestItems__c();
        paymentReqItems.ItemType__c='Add Agent';
        paymentReqItems.Amount__c = 50;
        paymentReqItems.Status__c = 'Pending';
        paymentReqItems.Payment_Request__c = paymentReq.id;
        //paymentReqItems.Agent__c = recordId;
        insert paymentReqItems;
        
        Payment_Response__c paymentResponse = new Payment_Response__c();
        paymentResponse.ReceiveDate__c = System.today();
        paymentResponse.ePay_Return_Code__c = 'Valic Code';
        paymentResponse.Total_Paid_Amount__c = 600;
        paymentResponse.Card_Type__c = 'Visa';
        paymentResponse.Payment_Request__c = paymentReq.id;
        paymentResponse.Status__c = 'Pending';
        paymentResponse.ePay_Result_Message__c = 'Success';
        paymentResponse.Confirmation_Number__c = 200;
        paymentResponse.Settlement_Submission_Date__c = System.today();
        insert paymentResponse;

    }
    
     @AuraEnabled
    public static void insertRequestItem(List<Payment_Response__c> lstPaymentResponses)
    {

        List<Payment_Response__c> Conlist = [Select id from Payment_Response__c ];
        for(Payment_Response__c objCont : Conlist){
		//where AccountId =: lstPaymentResponses
        }

    }
       
	public class wrapper{
        @AuraEnabled public String locationName;
        @AuraEnabled public String locationType;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public String paymentStatus;
    }  
}