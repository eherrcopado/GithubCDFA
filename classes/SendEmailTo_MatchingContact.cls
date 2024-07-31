/*
 contacid is passed as paramater and send email to those conatact via flow
*/
public with sharing class SendEmailTo_MatchingContact implements Queueable {
	public Set<Id> contactIds;
	public Boolean isReviewRequired;        
    public SendEmailTo_MatchingContact(Set<Id> contactIds, Boolean isReviewRequired){
        this.contactIds = contactIds;
        this.isReviewRequired = isReviewRequired;
    }
    
    public void execute(QueueableContext context) {
        try{
            Map<String,Object> params = new Map<String, Object>();
            params.put('ContactId_List',contactIds);
            params.put('isReviewRequired',isReviewRequired);
            Flow.Interview.Person_Examination_Review_with_or_without_exact_match flowInterview = new Flow.Interview.Person_Examination_Review_with_or_without_exact_match(params);
            flowInterview.start();
        }catch(exception e){}        
    }  
}