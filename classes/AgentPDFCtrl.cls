public with sharing class AgentPDFCtrl {
    public Contact conRec{get;set;}
    public String dateStr{get;set;}
    public AgentPDFCtrl() {
       // String recId =  apexpages.currentpage().getparameters().get('id');
        User userRec = [select Id,ContactId  from User where Id =: UserInfo.getUserId()];
        conRec = [Select Id,Name,License_From_Date__c,License_To_Date__c,License_No__c from Contact where Id =: userRec.ContactId ];
        if(conRec.License_To_Date__c !=null){
            Datetime dt = conRec.License_To_Date__c; 
            dateStr = dt.format('MM/dd/yyyy');
        }
        
    }
}