/****************************************************************
Name            : EmailMessageTriggerHandlerTest
Created         : 10-09-2022
Description     : To cover EmailMessageTriggerHandler apex class
********************************************************************/
@isTest
public class EmailMessageTriggerHandlerTest {
	
    @isTest
    static void createEmailMessageTestOne(){
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
        system.assertEquals(1, conList.size());
        List<PersonExamination> personExaminationList = [SELECT Id FROM PersonExamination];
        system.assertEquals(1, personExaminationList.size());
    }
    
    /*
     * Renew scenario with exact match
	*/
    @isTest
    static void createEmailMessageTestTwo_WithRenew(){
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
        system.assertEquals(1, conList.size());
        List<PersonExamination> personExaminationList = [SELECT Id FROM PersonExamination];
        system.assertEquals(1, personExaminationList.size());
        Task t = [SELECT Id FROM Task where WhoId =:conList[0].Id];
        PersonExaminationTaskCntl.reviewTask (t.Id, null);
        caseRec = new case(Subject = 'Service Agent Exam Results', Priority='High', Origin='Email', RecordTypeId=examEmailrecordTypeId);
        insert caseRec;
        
        emailBody = 'Contact First Name: Cyndi'
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
            + '\n' + 'Examination Type: Renewal'
            + '\n' + 'Examination Score: 93.0%'
            + '\n' + 'Service Agent License Number: 31555';

        emailMsgRec = new EmailMessage(FromAddress = 'test@abc.org',
                                                    ToAddress= 'test@salesforce.com', 
                                                    TextBody = emailBody,
                                                    Subject = 'Service Agent Exam Results ', ParentId = caseRec.Id); 
        insert emailMsgRec;
        conList = [SELECT Id, Exam_Score__c FROM Contact];
        System.assertEquals(93, conList[0].Exam_Score__c, 'Mismatch in Exam score');
        system.assertEquals(1, conList.size());
        personExaminationList = [SELECT Id FROM PersonExamination];
        system.assertEquals(2, personExaminationList.size());
    }
    
    /*
     * Renew scenario with non-match
	*/
    @isTest
    static void createEmailMessageTestThree_WithRenewNonMatch(){
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
        system.assertEquals(1, conList.size());
        List<PersonExamination> personExaminationList = [SELECT Id FROM PersonExamination];
        system.assertEquals(1, personExaminationList.size());
        Task t = [SELECT Id FROM Task where WhoId =:conList[0].Id];
        PersonExaminationTaskCntl.reviewTask (t.Id, null);
        caseRec = new case(Subject = 'Service Agent Exam Results', Priority='High', Origin='Email', RecordTypeId=examEmailrecordTypeId);
        insert caseRec;
        
        emailBody = 'Contact First Name: Cyndir'
            + '\n' + 'Contact Middle Name:'
            + '\n' + 'Contact Last Name: Reimere'
			+ '\n' + 'Contact Address Line 1: 123 Main Street'
            + '\n' + 'Contact Address City: Sacramento'
            + '\n' + 'Contact Address State: CA'
            + '\n' + 'Contact Address ZIP Code: 95814'
            + '\n' + 'Contact Phone Number: 916-767-7671'
            + '\n' + 'Contact Email Address: test@abc.org'
            + '\n' + 'Proof of Identity Type: State Issued Driver\'s License'
            + '\n' + 'Proof of Identity Number: 1'
            + '\n' + 'Examination Date: 4/12/2023 9:20:33 AM'
            + '\n' + 'Examination Type: Renewal'
            + '\n' + 'Examination Score: 93.0%'
            + '\n' + 'Service Agent License Number: 31555';

        emailMsgRec = new EmailMessage(FromAddress = 'test@abc.org',
                                                    ToAddress= 'test@salesforce.com', 
                                                    TextBody = emailBody,
                                                    Subject = 'Service Agent Exam Results ', ParentId = caseRec.Id); 
        insert emailMsgRec;
        conList = [SELECT Id FROM Contact];
        system.assertEquals(2, conList.size());
        personExaminationList = [SELECT Id FROM PersonExamination];
        system.assertEquals(2, personExaminationList.size());
    }
    
    /*
     * Renew scenario with no-match in any 
	*/
    @isTest
    static void createEmailMessageTestFour_WithRenewNonMatch(){
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
            + '\n' + 'Examination Date: 4/12/2023 9:20:33 PM'
            + '\n' + 'Examination Type: Renewal'
            + '\n' + 'Examination Score: 92.0%'
            + '\n' + 'Service Agent License Number: 31555';

        EmailMessage emailMsgRec = new EmailMessage(FromAddress = 'test@abc.org',
                                                    ToAddress= 'test@salesforce.com', 
                                                    TextBody = emailBody,
                                                    Subject = 'Service Agent Exam Results ', ParentId = caseRec.Id); 
        insert emailMsgRec;
        List<Contact> conList = [SELECT Id FROM Contact];
        system.assertEquals(1, conList.size());
        List<PersonExamination> personExaminationList = [SELECT Id FROM PersonExamination];
        system.assertEquals(1, personExaminationList.size());
    }
    
    /*
     * Failed marks
	*/
    @isTest
    static void createEmailMessageTestFive_FailedMarks(){
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
            + '\n' + 'Examination Type: Renewal'
            + '\n' + 'Examination Score: 29.0%'
            + '\n' + 'Service Agent License Number: 31555';

        EmailMessage emailMsgRec = new EmailMessage(FromAddress = 'test@abc.org',
                                                    ToAddress= 'test@salesforce.com', 
                                                    TextBody = emailBody,
                                                    Subject = 'Service Agent Exam Results ', ParentId = caseRec.Id); 
        insert emailMsgRec;
        List<Contact> conList = [SELECT Id FROM Contact];
        system.assertEquals(0, conList.size());
        List<PersonExamination> personExaminationList = [SELECT Id FROM PersonExamination];
        system.assertEquals(0, personExaminationList.size());
        System.assertEquals('Closed', [SELECT Status FROM Case WHERE Id =: caseRec.Id].Status);
    }
    
    /*
     * Empty License number 
	*/
    @isTest
    static void createEmailMessageTestSix_EmptyLicenseNumber(){
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
            + '\n' + 'Examination Date: 4/12/2023 9:20:33 PM'
            + '\n' + 'Examination Type: New'
            + '\n' + 'Examination Score: 92.0%'
            + '\n' + 'Service Agent License Number:';

        EmailMessage emailMsgRec = new EmailMessage(FromAddress = 'test@abc.org',
                                                    ToAddress= 'test@salesforce.com', 
                                                    TextBody = emailBody,
                                                    Subject = 'Service Agent Exam Results ', ParentId = caseRec.Id); 
        insert emailMsgRec;
        List<Contact> conList = [SELECT Id FROM Contact];
        system.assertEquals(1, conList.size());
        List<PersonExamination> personExaminationList = [SELECT Id FROM PersonExamination];
        system.assertEquals(1, personExaminationList.size());
    }
    
    @isTest
    static void createEmailMessageWithException(){
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
            + '\n' + 'Examination Score: 92.2%'
            + '\n' + 'Service Agent License Number: 31555';

        EmailMessage emailMsgRec = new EmailMessage(FromAddress = 'test@abc.org',
                                                    ToAddress= 'test@salesforce.com', 
                                                    TextBody = emailBody,
                                                    Subject = 'Service Agent Exam Results ', ParentId = caseRec.Id); 
        insert emailMsgRec;
        List<Contact> conList = [SELECT Id FROM Contact];
        system.assertEquals(0, conList.size());
        List<PersonExamination> personExaminationList = [SELECT Id FROM PersonExamination];
        system.assertEquals(0, personExaminationList.size());
    }
}