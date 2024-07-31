trigger PaymentResponse on Payment_Response__c (After insert) {
    
    if(trigger.isInsert && Trigger.isAfter) {
        PaymentResponseHandler Prh =  New PaymentResponseHandler();
        Prh.Paymentresponse(Trigger.new);
        
    }

}