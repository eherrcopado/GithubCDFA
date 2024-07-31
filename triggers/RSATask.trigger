trigger RSATask on Task (after update) {

for (task t:Trigger.new) {
    if(Test.isRunningTest()) continue;
    
    Task oldt = Trigger.oldMap.get(t.ID);  
    
    Id examResultReview = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Exam_Result_Review').getRecordTypeId();
    if (t.status == 'Approved' && oldt.status == 'Pending Approval' && t.RecordTypeId != examResultReview) {
        List<AccountContactRelation> acr = [Select Id, status__c from AccountContactRelation where Id = :t.AccountContactRelationship__c limit 1];
        acr[0].status__c = 'Pending Payment';
        update acr;
    } else if (t.status == 'Rejected' && oldt.status == 'Pending Approval' && t.RecordTypeId != examResultReview) {
        List<AccountContactRelation> acr = [Select Id, status__c from AccountContactRelation where Id = :t.AccountContactRelationship__c limit 1];
        acr[0].status__c = 'Inactive';
        acr[0].action__c = 'Agency Rejection';
        update acr;
    }
        
}

}