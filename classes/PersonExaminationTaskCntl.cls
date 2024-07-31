public with sharing class PersonExaminationTaskCntl {
    public class InvalidValueException extends Exception {}

    @AuraEnabled(cacheable=true)
    public static String getTaskDetailsByTaskId (String taskId){
        try {
            if (String.isBlank (taskId)) {
                throw new InvalidValueException ('Task Id should not be null or empty');
            }

            Task taskObj = [SELECT Id, WhoId FROM TASK WHERE Id =: taskId LIMIT 1];

            return JSON.serialize (taskObj);
        } catch (Exception e) {
            AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
            auraHandledException.setMessage(e.getMessage());
            throw auraHandledException;
        }
    }

    @AuraEnabled
    public static string fetchDuplicateContacts(String contactId){
        try {
            if (String.isBlank (contactId)) {
                throw new InvalidValueException ('Contact Id should not be null or empty');
            }

            Contact tempContact = [SELECT Id, FirstName, LastName, Email, License_No__c FROM Contact WHERE Id =: contactId LIMIT 1];
            /**
             * OR (
                    •	Combination of First Name + Last Name
                    •	Combination of Last Name + License No.
                    •	License No.
                    •	Email address 
                )
             */

            Set<Id> recordTypeIds = new Set<Id> {
                Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('RSAAgent').getRecordTypeId(),
				Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('RSAContact').getRecordTypeId()
            };
            List<Contact> contacts = [
                SELECT Id, FirstName, LastName, MiddleName, Email, License_No__c
                FROM Contact
                WHERE 
                ((FirstName =: tempContact.FirstName AND LastName =: tempContact.LastName)
                    OR (LastName =: tempContact.LastName AND License_No__c =: tempContact.License_No__c)
                    OR (License_No__c =: tempContact.License_No__c)
                    OR (Email =: tempContact.Email))
                AND RecordTypeId IN: recordTypeIds 
                AND Id !=: contactId
                ORDER BY LastName
            ];

            return JSON.serialize (contacts);
        } catch (Exception e) {
            AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
            auraHandledException.setMessage(e.getMessage());
            throw auraHandledException;
        }
    }

    @AuraEnabled
    public static String reviewTask(String taskId, String selectedContactId){
        SavePoint sp = Database.setSavePoint ();
        try {
            if (String.isBlank (taskId)) {
                throw new InvalidValueException ('Task Id should not be null or empty');
            }

            Task taskObj = [SELECT Id, WhoId FROM TASK WHERE Id =: taskId LIMIT 1];

            if (selectedContactId != null) {
                Contact tempContact = [ SELECT Id, FirstName, MiddleName, 
                                        LastName, Email, MailingStreet, MailingCity, 
                                        MailingState, MailingPostalCode, Phone, Proof_Of_Identity__c, Identity_No__c,
                                        License_From_Date__c, License_To_Date__c, Exam_Score__c, Examination_Type__c
                                        FROM Contact 
                                        WHERE Id =: taskObj.WhoId LIMIT 1];
                
                Contact contObjToUpdate = new Contact ();
                contObjToUpdate.FirstName = tempContact.FirstName;
                contObjToUpdate.MiddleName = tempContact.MiddleName;
                contObjToUpdate.LastName = tempContact.LastName;
                contObjToUpdate.Email = tempContact.Email;
                contObjToUpdate.MailingStreet = tempContact.MailingStreet;
                contObjToUpdate.MailingCity = tempContact.MailingCity;
                contObjToUpdate.MailingState = tempContact.MailingState;
                contObjToUpdate.MailingPostalCode = tempContact.MailingPostalCode;
                contObjToUpdate.Phone = tempContact.Phone;
                contObjToUpdate.Proof_Of_Identity__c = tempContact.Proof_Of_Identity__c;
                contObjToUpdate.Identity_No__c = tempContact.Identity_No__c;
                contObjToUpdate.License_From_Date__c = tempContact.License_From_Date__c;
                contObjToUpdate.License_To_Date__c = tempContact.License_To_Date__c;
                contObjToUpdate.Exam_Score__c = tempContact.Exam_Score__c;
                contObjToUpdate.Examination_Type__c = tempContact.Examination_Type__c;
                contObjToUpdate.Id = selectedContactId;
                contObjToUpdate.IsReviewed__c = true;
                update contObjToUpdate;

                update new Task (Id = taskObj.Id, WhoId = selectedContactId, Status = 'Approved');

                List<PersonExamination> personExaminationUpdateList = new List<PersonExamination> ();

                for (PersonExamination eachExamination : [SELECT Id From PersonExamination where ContactId =: taskObj.WhoId]) {
                    personExaminationUpdateList.add (new PersonExamination (Id = eachExamination.Id, ContactId = selectedContactId));
                }

                update personExaminationUpdateList;

                //delete new Contact (Id = taskObj.WhoId);
                new DeleteContactUtil ().deleteContactByContactId (taskObj.WhoId);

            } else {
                update new Contact (Id = taskObj.WhoId, 
                    RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('RSAAgent').getRecordTypeId(),
                    IsReviewed__c = true,
                    CDFA_User_Status__c = 'Activated'
                );

                update new Task (Id = taskObj.Id, Status = 'Approved');
            }

            return JSON.serialize (new Map<String, Object> {'result' => true});
            
        } catch (Exception e) {
            Database.rollback (sp);
            AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
            auraHandledException.setMessage(e.getMessage());
            throw auraHandledException;
        }
    }

    without sharing class DeleteContactUtil {
        String contactId;
        
        void deleteContactByContactId (String contactId) {
			delete new Contact (Id = contactId);            
        }
    }    
}