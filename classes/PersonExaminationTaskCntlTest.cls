@isTest
public with sharing class PersonExaminationTaskCntlTest {
    
    @TestSetup
    static void makeData(){
        
    }

    @isTest
    static void test_getTaskDetailsByTaskId_nullVal () {
        try {
            PersonExaminationTaskCntl.getTaskDetailsByTaskId (null);
        } catch (Exception e) {
            system.debug('e.getMessage()'+e.getMessage());
            System.assert (e.getMessage().contains ('Task Id should not be null or empty'), TRUE);
        }
    }
    @isTest
    static void test_getTaskDetailsByTaskId_success() {
        
        Account accRec = TestDataFactory_Community.createAccountTestRec2('TestAcc', 'RSA');
        Insert accRec;
        
        Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
        Insert conRec;
        
        Task objTask = new Task();
        objTask.Subject = 'Examination Test Task';
        objTask.Status  = '	Pending Approval';
        objTask.Priority   = 'Normal';
        objTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Exam_Result_Review').getRecordTypeId();     
        insert objTask;
        
        String tSkDetails = PersonExaminationTaskCntl.getTaskDetailsByTaskId (objTask.id);
        System.assert (String.IsNotBlank(tSkDetails),TRUE);
    }
    
    @isTest
    static void test_fetchDuplicateContacts_success() {
         Account accRec = TestDataFactory_Community.createAccountTestRec2('TestAcc', 'RSA');
        Insert accRec;
        
        Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
        conRec.License_No__c = '10347';
        Insert conRec;
        
        Contact conRec1 = TestDataFactory_Community.createContactTestRec('testabc','con1','testav@com.com',accRec.Id);
        conRec1.License_No__c = '10347';
        Insert conRec1;
        
        string sContactMatchs = PersonExaminationTaskCntl.fetchDuplicateContacts(conRec.id);
        System.assert (String.IsNotBlank(sContactMatchs),TRUE);
    }
    
    @isTest
    static void test_fetchDuplicateContacts_nullVal () {
        try {
            PersonExaminationTaskCntl.fetchDuplicateContacts (null);
        } catch (Exception e) {
            system.debug('e.getMessage()'+e.getMessage());
            System.assert (e.getMessage().contains ('Contact Id should not be null or empty'), TRUE);
        }
    }
    
    @isTest
    static void test_reviewTask_MapMatchingContact() {
        
        Account accRec = TestDataFactory_Community.createAccountTestRec2('TestAcc', 'RSA');
        Insert accRec;
        
        Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
        Insert conRec;
        
        Contact conRec1 = TestDataFactory_Community.createContactTestRec('testabc','con1','testav@com.com',accRec.Id);
        conRec1.License_No__c = '10347';
        Insert conRec1;
        
        PersonExamination personExaminationRec = new PersonExamination();
        
        
        Datetime dateExam = DateTime.now();
        personExaminationRec.ExaminationDate = dateExam;
        personExaminationRec.EffectiveFrom = dateExam;
        personExaminationRec.EffectiveTo = dateExam.addYears(5);
        personExaminationRec.Result = 'Pass';
       	personExaminationRec.Score = (79);
        personExaminationRec.ContactId = conRec.Id;
        
        insert personExaminationRec;
        
        Task objTask = new Task();
        objTask.Subject = 'Examination Test Task';
        objTask.Status  = '	Pending Approval';
        objTask.Priority   = 'Normal';
        objTask.WhoId   = conRec.id;
        insert objTask;
        
        String tSkDetails = PersonExaminationTaskCntl.reviewTask (objTask.id ,conRec1.id );
        contact objcon = [select id,Name,IsReviewed__c, Last_Reviewed_Date__c from contact where id =:conRec1.id];
        //System.assert (!objcon.IsReviewed__c);
        //System.assert(objcon.Last_Reviewed_Date__c != null);
        System.assertEquals(0, [SELECT Id FROM Contact WHERE Id =: conRec.Id].size ());
    }
    
    @isTest
    static void test_reviewTask_updatedContact() {
                
        Id examEmailrecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exam_Email').getRecordTypeId();
        case caseRec = new case(Subject = 'Service Agent Exam Results', Priority='High', Origin='Email', RecordTypeId=examEmailrecordTypeId);
        insert caseRec;
        
        String emailBody = 'Contact First Name: Cyndi'
            + '\n' + 'Contact Middle Name:'
            + '\n' + 'Contact Last Name: Reimer'
			+ '\n' + 'Contact Address Line 1: 123 Main Street'
            + '\n' + 'Contact Address City: Sacramento'
            + '\n' + 'Contact Address State: CA'
            + '\n' + 'Contact Address ZIP Code: 95814'
            + '\n' + 'Contact Phone Number: 916-767-7671'
            + '\n' + 'Contact Email Address: test@abc.org'
            + '\n' + 'Proof of Identity Type: State Issued Driver\'s License'
            + '\n' + 'Proof of Identity Number: 1'
            + '\n' + 'Examination Date: 4/12/2023 9:20:33 AM'
            + '\n' + 'Examination Type: New'
            + '\n' + 'Examination Score: 92.0%'
            + '\n' + 'Service Agent License Number: 31555';

        EmailMessage emailMsgRec = new EmailMessage(FromAddress = 'test@abc.org',
                                                    ToAddress= 'test@salesforce.com', 
                                                    TextBody = emailBody,
                                                    Subject = 'Service Agent Exam Results ', ParentId = caseRec.Id); 
        insert emailMsgRec;
        List<Contact> conList = [SELECT Id FROM Contact];
        
        Task objTask = [SELECT Id FROM Task WHERE WhoId =: conList[0].Id];
        
        String tSkDetails = PersonExaminationTaskCntl.reviewTask (objTask.id ,NULL );
        contact objcon = [select id,Name,IsReviewed__c from contact where id =:conList[0].id];
        //System.assert (!objcon.IsReviewed__c);
    }
    
    @isTest
    static void test_reviewTask_updatedContact_nullVal () {
        try {
            PersonExaminationTaskCntl.reviewTask (null, null);
        } catch (Exception e) {
            system.debug('e.getMessage()'+e.getMessage());
            System.assert (e.getMessage().contains ('Task Id should not be null or empty'), TRUE);
        }
    }
}