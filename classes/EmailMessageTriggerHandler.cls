/****************************************************************
Name            : EmailMessageTriggerHandler
Created         : 10-03-2022
Description     : To take action for all triggers of EmailMessage
********************************************************************/
public class EmailMessageTriggerHandler {
    
    static final String EMAIL_SUBJECT = ExamMessageConstants.CDFA_EXAM_RESULT_EMAIL_SUBJECT;
    static Map<String,String> mapOfLicenseNoToEmailBody = new Map<String,String>();
    /****************************************************************************
    Method : Call on After Insert on EmailMessage 
	****************************************************************************/
    public static void onAfterInsert(List<EmailMessage> newEmailMssgLst) {
		Savepoint sp = Database.setSavepoint();
        try {
         	parseEmails (newEmailMssgLst);   
        } catch (Exception ex) {
            system.debug('Exception'+ex.getStackTraceString());
            Database.rollback(sp);
            /**
             * This is written in the context that every time single email is being processed 
             * from email-to-case functionality, any runtime exception occured is tracted under that 
             * email, hence tagging the error record ParentRecordId__c to email's Parent case id
             * */
            Map<Id, Id> emailToCaseMap = new Map<Id, Id> ();
            for (EmailMessage eachEmailMessage : newEmailMssgLst) {
                emailToCaseMap.put (eachEmailMessage.Id, eachEmailMessage.ParentId);
            }
            
            Person_Examination_Error__c errorRecord = new Person_Examination_Error__c(
                Error__c = ex.getmessage(), 
                ParentRecordId__c  = newEmailMssgLst[0].ParentId, //setting the parent record as a reference to the error caused in processing email 
                Error_Details_Extra__c = System.Label.CDFA_Error_Log_Extra_Error_Detail_Text 
                                          + JSON.serialize(emailToCaseMap) 
			);
            insert errorRecord;
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: System.Label.CDFA_Default_No_Reply_Email_Address  LIMIT 1];

            String recordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + errorRecord.Id;
            
            String errorMessage =String.format(System.Label.CDFA_Error_Log_Email_Message_Text , new List<String>{recordURL, recordURL});
            
            EmailMessagingHelper.sendEmail (
                new String[] {Label.Error_Notification_Email_Address},
                null,
                null,
				System.Label.CDFA_Error_Log_Email_Message_Sender_Display_Name,
                (owea != null && owea.size () > 0) ? owea[0].Id : null,
                System.Label.CDFA_Error_Log_Email_Message_Subject,
                errorMessage,
                errorMessage,
                false,
				false
            );
        }
    }
    
    public static void parseEmails (List<EmailMessage> emailMessageList) {
        Map<String, Map<String, Object>> emailKeyValMap = new Map<String, Map<String, Object>> ();
        Map<String, Map<String, Object>> passScoreEmailMap = new Map<String, Map<String, Object>> ();
        Map<String, Map<String, Object>> failedScoreEmailMap = new Map<String, Map<String, Object>> ();
		List<EmailMessage> failedScoreEmailMessageList = new List<EmailMessage> ();
        Set<String> setOfLicenseNo = new Set<String>();
        Set<Id> contactIdSet = new Set<Id>();
        
        Id examEmailrecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exam_Email').getRecordTypeId();
        
        Set<Id> caseIds = new Set<Id> ();
        for (EmailMessage eachEmail : emailMessageList) {
            if (String.isNotBlank(eachEmail.ParentId) 
                && String.valueOf(eachEmail.ParentId).startsWith ('500')) 
            {
                caseIds.add (eachEmail.ParentId);
            }
        }
        Map<Id, Case> casesMap = new Map<Id, Case> ();
        if (!caseIds.isEmpty ()) {
            casesMap = new Map<Id, Case> (
            	[SELECT Id, RecordTypeId FROM Case WHERE Id IN: caseIds]
            );
        }
        
        for (EmailMessage eachEmail : emailMessageList) {
            if (String.isNotBlank(eachEmail.ParentId) 
                && String.valueOf(eachEmail.ParentId).startsWith ('500')
               	&& eachEmail.Subject == EMAIL_SUBJECT
                && casesMap.containsKey(eachEmail.ParentId)
                && casesMap.get(eachEmail.ParentId).RecordTypeId == examEmailrecordTypeId
               	) 
            { 
                Map<String, Object> eachEmailMessageMap = new Map<String, Object> ();
                
                for (String eachString : eachEmail.TextBody.split('\n|\r\n')) {
					List<String> tempColonSplittedList = eachString.split(': ');
                    
                    String tempStr = tempColonSplittedList[0].replaceAll('-[\\s]|[\\s]-[\\s]', '').replaceAll('[^a-zA-Z0-9:/\\s+]', '').trim ();
                    tempStr = tempStr.endsWith(':') ? tempStr.removeEnd(':') : tempStr;
                    
                    if (tempColonSplittedList.size() > 1) {
                        if(tempStr == ExamMessageConstants.CONTACT_EMAIL_ADDRESS) {
                            eachEmailMessageMap.put (tempStr.trim (), tempColonSplittedList[1].split (' <')[0].trim ());
                        } else {
                         	eachEmailMessageMap.put (tempStr.trim (), tempColonSplittedList[1].trim ());       
                        }
                    } else if (tempColonSplittedList.size() > 0){
                    	eachEmailMessageMap.put (tempStr.trim (), null);                            
                    }
                }
                
                emailKeyValMap.put (eachEmail.Id, eachEmailMessageMap);
                
                if(
                    eachEmailMessageMap.containsKey (ExamMessageConstants.EXAMINATION_SCORE_STRING)
                    && 
                    Double.valueOf(
                        String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.EXAMINATION_SCORE_STRING))
                        .replaceAll ('%', '')
                    ) >= ExamMessageConstants.MIN_MARKS_REQUIRED
                ) {
                    passScoreEmailMap.put (eachEmail.Id, eachEmailMessageMap);
                    
                    if (eachEmailMessageMap.containsKey (ExamMessageConstants.EXAMINATION_TYPE_STRING)) {
                        String examinationType = String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.EXAMINATION_TYPE_STRING)).trim ();
                        
                        if(examinationType == ExamMessageConstants.EXAM_TYPE_RENEW 
                           && eachEmailMessageMap.containsKey (ExamMessageConstants.EXAMINATION_SERVICE_AGENT_LICENSE_NUMBER)){
                            setOfLicenseNo.add (String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.EXAMINATION_SERVICE_AGENT_LICENSE_NUMBER)));
                        }    
                    }                  
                } else if (eachEmailMessageMap.containsKey (ExamMessageConstants.EXAMINATION_SCORE_STRING)
                    && 
                    Double.valueOf(
                        String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.EXAMINATION_SCORE_STRING))
                        .replaceAll ('%', '')
                    ) < ExamMessageConstants.MIN_MARKS_REQUIRED)
                {
                    failedScoreEmailMap.put (eachEmail.Id, eachEmailMessageMap);
                    failedScoreEmailMessageList.add (eachEmail);
                }
            }
        }
        Map<String,Contact> mapOfLicenseNoToContact = new Map<String,Contact>();
        
        if(setOfLicenseNo.size() > 0){
            Set<Id> recordTypeIds = new Set<Id> {
                Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('RSAAgent').getRecordTypeId(),
				Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('RSAContact').getRecordTypeId()
            };
            for(Contact con : [SELECT ID ,License_No__c, FirstName, MiddleName, LastName, Email 
                               FROM Contact 
                               WHERE License_No__c IN : setOfLicenseNo 
                               AND RecordTypeId IN: recordTypeIds 
                               Order By LastModifiedDate DESC]){
                if(!mapOfLicenseNoToContact.containskey(con.License_No__c)) {
                    mapOfLicenseNoToContact.put(con.License_No__c,con);
                }
            }   
        }
        
        List<Task> taskToInsert = new List<Task>();
        List<Contact> contactsToUpsert = new List<Contact>();
        List<Contact> nonMatchingContactsToInsert = new List<Contact>();
        List<Contact> newExamTypeContactsToInsert = new List<Contact>();
        Map<String, Map<String, Object>> licenseNumberToEmailMap = new Map<String, Map<String, Object>> ();
        List<PersonExamination> personExaminationsForInsert = new List<PersonExamination>();
        for (String key : passScoreEmailMap.keySet ()) {
            Map<String, Object> eachEmailMessageMap = passScoreEmailMap.get (key);
            
            String licenseNumber = null;

            if (eachEmailMessageMap.containsKey (ExamMessageConstants.EXAMINATION_SERVICE_AGENT_LICENSE_NUMBER) ) {
                licenseNumber = String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.EXAMINATION_SERVICE_AGENT_LICENSE_NUMBER));
            }
            if (String.isNotBlank(licenseNumber)) {
                licenseNumberToEmailMap.put(licenseNumber, eachEmailMessageMap);
            }
            
            //If exam type is Renew
			if (eachEmailMessageMap.containsKey (ExamMessageConstants.EXAMINATION_TYPE_STRING)
                && String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.EXAMINATION_TYPE_STRING)).trim () 
                	== ExamMessageConstants.EXAM_TYPE_RENEW) {
                //Step 1: check for the contact exact match with below 5 points
                //•	Contact First Name
				//•	Contact Middle Name
				//•	Contact Last Name
				//•	Contact Email Address
				//•	Service Agent License Number 
				
                
                if(mapOfLicenseNoToContact.containskey(licenseNumber)){
                    Contact tempContact = mapOfLicenseNoToContact.get(licenseNumber);
                    
                    Contact contObjFromEmail = new Contact();
                    if (eachEmailMessageMap.containsKey (ExamMessageConstants.CONTACT_FIRST_NAME)) {
                        contObjFromEmail.FirstName = String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.CONTACT_FIRST_NAME));
                    }
                    if (eachEmailMessageMap.containsKey (ExamMessageConstants.CONTACT_MIDDLE_NAME)) {
                        contObjFromEmail.MiddleName =  String.valueOf( eachEmailMessageMap.get (ExamMessageConstants.CONTACT_MIDDLE_NAME) );
                    }
                    if (eachEmailMessageMap.containsKey (ExamMessageConstants.CONTACT_LAST_NAME)) {
                        contObjFromEmail.LastName =  String.valueOf (eachEmailMessageMap.get (ExamMessageConstants.CONTACT_LAST_NAME));
                    }
                    if (eachEmailMessageMap.containsKey (ExamMessageConstants.CONTACT_EMAIL_ADDRESS)) {
                        contObjFromEmail.Email = String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.CONTACT_EMAIL_ADDRESS));  
                    }
                    
                    /*
						Match all 5 fields
						licenseNumber is already verified above
					*/
                    if (contObjFromEmail.FirstName == tempContact.FirstName
                       && contObjFromEmail.MiddleName == tempContact.MiddleName
                       && contObjFromEmail.LastName == tempContact.LastName
                        && contObjFromEmail.Email == tempContact.Email) {
                        //If match found just update the contact details
                        //no need of any approval
                        system.debug('Match Found');
                        contactIdSet.add(tempContact.Id);
                    	contactsToUpsert.add(createContactObj(eachEmailMessageMap, tempContact.Id, licenseNumber));
					} 
                    //If any of the non matching found, create the Create Contact Record -> Review Examinee RT  
                    else {
						nonMatchingContactsToInsert.add(createContactObj(eachEmailMessageMap, null, licenseNumber));
                    }
                } 
                //If any of the non matching found, create the Create Contact Record -> Review Examinee RT  
                else {
                	nonMatchingContactsToInsert.add(createContactObj(eachEmailMessageMap, null, licenseNumber));
               	}
            } 
            //If exam type is New
            else if (eachEmailMessageMap.containsKey (ExamMessageConstants.EXAMINATION_TYPE_STRING)
                && String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.EXAMINATION_TYPE_STRING)).trim () 
                     == ExamMessageConstants.EXAM_TYPE_NEW) {
				newExamTypeContactsToInsert.add(createContactObj(eachEmailMessageMap, null, licenseNumber));
            }
            System.debug('val1: '+ String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.EXAMINATION_TYPE_STRING)).trim () );
            System.debug('eachEmailMessageMap :' +eachEmailMessageMap);
            System.debug('ExamMessageConstants.EXAM_TYPE_RENEW :' + ExamMessageConstants.EXAM_TYPE_RENEW);
        }
        
        List<Case> updateCaseList = new List<Case>();
        
        if(!contactsToUpsert.isEmpty() ||!newExamTypeContactsToInsert.isEmpty() || !nonMatchingContactsToInsert.isEmpty()){  
            //Upsert Contact Records
            if(!contactsToUpsert.isEmpty()){
            	upsert contactsToUpsert;
                // call queuable class to send email
       			System.enqueueJob(new SendEmailTo_MatchingContact(contactIdSet, false));
            }
            
            
            Group reviewExamQueue = [SELECT Id from Group where DeveloperName = 'Exam_Records_Approval' AND Type = 'Queue' LIMIT 1];
            
            Database.DMLOptions dml = new Database.DMLOptions(); 
			dml.DuplicateRuleHeader.AllowSave = true;
            
            if(!newExamTypeContactsToInsert.isEmpty()){
                Database.SaveResult [] result = Database.insert(newExamTypeContactsToInsert, dml);
                
                contactsToUpsert.addAll(newExamTypeContactsToInsert);
                taskToInsert.addAll(createTask(contactsToUpsert, reviewExamQueue.Id));
            }
            
            if(!nonMatchingContactsToInsert.isEmpty()){
                Database.SaveResult [] result = Database.insert(nonMatchingContactsToInsert, dml);
                
                contactsToUpsert.addAll(nonMatchingContactsToInsert);
                taskToInsert.addAll(createTask(contactsToUpsert, reviewExamQueue.Id));
                
                Set<Id> contactIds = new Set<Id> ();
                for (Contact eachContact : nonMatchingContactsToInsert) {
                    contactIds.add (eachContact.Id);
                }
                System.enqueueJob(new SendEmailTo_MatchingContact(contactIds, true));
            }
            
            if(!taskToInsert.isEmpty() && taskToInsert.size()>0){
                 insert taskToInsert;
            }
            
            for(Contact con : contactsToUpsert){
                personExaminationsForInsert.add(
                    createPersonExaminationObj(con, 
						((String.isNotBlank(con.License_No__c) && licenseNumberToEmailMap.containsKey(con.License_No__c)) 
							? licenseNumberToEmailMap.get(con.License_No__c) 
							: null)  ));
            }
            
            //Insert PersonExamination Records
            if(!personExaminationsForInsert.isEmpty()){
                insert personExaminationsForInsert;
                
                for(EmailMessage eachEmail : emailMessageList){
                    if(eachEmail.ParentId !=null 
                       	&& String.valueOf(eachEmail.ParentId).startsWith ('500')
               			&& eachEmail.Subject == EMAIL_SUBJECT
                       	&& casesMap.containsKey(eachEmail.ParentId)
                		&& casesMap.get(eachEmail.ParentId).RecordTypeId == examEmailrecordTypeId
                      ) {
                        Case cse = new Case();
                        cse.Id = eachEmail.ParentId;
                        cse.Status ='Closed';
                        updateCaseList.add(cse);
                    }
                }
                /*if(updateCaseList.size() > 0) {
                    update updateCaseList;
                }*/
            } 
        }
        
        
        if (!failedScoreEmailMap.isEmpty ()) {
            
            for(EmailMessage eachEmail : failedScoreEmailMessageList){
                if(eachEmail.ParentId !=null 
                   && String.valueOf(eachEmail.ParentId).startsWith ('500')
                   && eachEmail.Subject == EMAIL_SUBJECT
                   && casesMap.containsKey(eachEmail.ParentId)
                   && casesMap.get(eachEmail.ParentId).RecordTypeId == examEmailrecordTypeId
                  ) {
                      Case cse = new Case();
                      cse.Id = eachEmail.ParentId;
                      cse.Status ='Closed';
                      updateCaseList.add(cse);
                  }
            }
        }
        
        if(updateCaseList.size() > 0) {
            update updateCaseList;
        }
    }
    
    // Return Contact details get from email body.
    public static PersonExamination createPersonExaminationObj(Contact con, Map<String, Object> eachEmailMessageMap){
        PersonExamination personExaminationRec = new PersonExamination();
        
        Datetime dateExam = DateTime.now();
        
        if (eachEmailMessageMap != null && eachEmailMessageMap.containsKey (ExamMessageConstants.EXAMINATION_DATE)) {
            dateExam = getExaminationDateTime (String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.EXAMINATION_DATE)));
        }
        	
        personExaminationRec.ExaminationDate = dateExam;
        personExaminationRec.EffectiveFrom = dateExam;
        personExaminationRec.EffectiveTo = dateExam.addYears(5);
        personExaminationRec.Result = 'Pass';
        
        if (eachEmailMessageMap != null && eachEmailMessageMap.containsKey (ExamMessageConstants.EXAMINATION_SCORE_STRING)) {
            personExaminationRec.Score = Integer.valueOf(
                        String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.EXAMINATION_SCORE_STRING))
                        .replaceAll ('%', '')
                    );
        }
        personExaminationRec.ContactId = con.Id;
        
        return personExaminationRec;
    }
    
    // Return Contact details get from email body.
    public static Contact createContactObj(Map<String, Object> eachEmailMessageMap, String contactId, String licenseNumber){
        
        Contact con = new Contact();
      
        if(String.isNotBlank(contactId)){
            con.Id = contactId;
        } 
        
        if (eachEmailMessageMap.containsKey (ExamMessageConstants.CONTACT_FIRST_NAME)) {
            con.FirstName = String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.CONTACT_FIRST_NAME));
        }
        if (eachEmailMessageMap.containsKey (ExamMessageConstants.CONTACT_MIDDLE_NAME)) {
            con.MiddleName =  String.valueOf( eachEmailMessageMap.get (ExamMessageConstants.CONTACT_MIDDLE_NAME) );
        }
        if (eachEmailMessageMap.containsKey (ExamMessageConstants.CONTACT_LAST_NAME)) {
         	con.LastName =  String.valueOf (eachEmailMessageMap.get (ExamMessageConstants.CONTACT_LAST_NAME));
        }
        if (eachEmailMessageMap.containsKey (ExamMessageConstants.CONTACT_EMAIL_ADDRESS)) {
         	con.Email = String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.CONTACT_EMAIL_ADDRESS));  
        }   
        if (eachEmailMessageMap.containsKey (ExamMessageConstants.CONTACT_ADDRESS_LINE_1)) {
         	con.MailingStreet = String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.CONTACT_ADDRESS_LINE_1));
        }
        if (eachEmailMessageMap.containsKey (ExamMessageConstants.CONTACT_ADDRESS_CITY)) {
         	con.MailingCity =  String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.CONTACT_ADDRESS_CITY));
        }
        if (eachEmailMessageMap.containsKey (ExamMessageConstants.CONTACT_ADDRESS_STATE)) {
         	con.MailingState = String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.CONTACT_ADDRESS_STATE));
        }
        if (eachEmailMessageMap.containsKey (ExamMessageConstants.CONTACT_ADDRESS_ZIP_CODE)) {
         	con.MailingPostalCode = String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.CONTACT_ADDRESS_ZIP_CODE));
        }
        if (eachEmailMessageMap.containsKey (ExamMessageConstants.CONTACT_PHONE_NUMBER)) {
         	con.Phone = String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.CONTACT_PHONE_NUMBER));
        }
        if (eachEmailMessageMap.containsKey (ExamMessageConstants.PROOF_OF_IDENTITY_TYPE)) {
         	con.Proof_Of_Identity__c = String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.PROOF_OF_IDENTITY_TYPE));
        }        
        if (eachEmailMessageMap.containsKey (ExamMessageConstants.PROOF_OF_IDENTITY_NUMBER)) {
         	con.Identity_No__c = String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.PROOF_OF_IDENTITY_NUMBER));
        }
		con.License_No__c =  licenseNumber;
        if (eachEmailMessageMap.containsKey (ExamMessageConstants.EXAMINATION_DATE)) {
            String dateOfExamString = String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.EXAMINATION_DATE))
                						.substringBefore(' ');
         	con.License_From_Date__c =  Date.parse(dateOfExamString);
            con.License_To_Date__c =  Date.parse(dateOfExamString).addYears(5);
        }
        if(String.isNotBlank(contactId)){
        	con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('RSAAgent').getRecordTypeId();    
        } else {
            con.CDFA_User_Status__c = System.Label.CDFA_User_Status;
            con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Review_Examinee').getRecordTypeId();    
        }
        
        
        // New changes Start
        if (eachEmailMessageMap.containsKey (ExamMessageConstants.EXAMINATION_SCORE_STRING)) {
         	con.Exam_Score__c = Integer.valueOf(
                                            String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.EXAMINATION_SCORE_STRING))
                                            .replaceAll ('%', '')
                    			);
        }
        if (eachEmailMessageMap.containsKey (ExamMessageConstants.EXAMINATION_TYPE_STRING)) {
         	con.Examination_Type__c = String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.EXAMINATION_TYPE_STRING));
        } 
        if (eachEmailMessageMap.containsKey (ExamMessageConstants.EXAMINATION_DATE)) {
         	con.Examination_Date__c = getExaminationDateTime (String.valueOf(eachEmailMessageMap.get (ExamMessageConstants.EXAMINATION_DATE)));
        }
        // New changes end
        
        con.AccountId = System.Label.Agent_AccountId;
        con.Status__c = 'Active';
        
        return con;
    }
    /* Create a  task for Non Matching Renew Examination type and New Examination type and associate with the Contact*/
    public static list<task> createTask(List<Contact> conList, Id taskOwnerId){
        list<task> taskLst = new list<task>();
        try{
            if(!conList.isEmpty() && conList.size()>0){
                for(contact objCon : conList){
                    Task objtask = new Task();
                    objTask.OwnerId = taskOwnerId;
                    objTask.Subject = ExamMessageConstants.TASK_SUBJECT;
                    objTask.Whoid = objCon.id;
                    objTask.ActivityDate = System.today().addDays (5);
                    objTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Exam_Result_Review').getRecordTypeId();     
                    taskLst.add(objtask);
                }
            }
            
        } catch(Exception e){}
        
        return taskLst;
	}
    
    public static DateTime getExaminationDateTime (String examinationDateTimeString) {
        List<String> dateOfExams = examinationDateTimeString.split(' ');
        String dateString = dateOfExams[0];
        String timeString = dateOfExams[1];
        
        List<String> dateValList = dateString.split('/');
        List<String> timeValList = timeString.split(':');
        
        Datetime examDateTime = DateTime.now();
        
        if (dateOfExams [2] == 'PM')
        {
            Integer hrs = Integer.ValueOf(timeValList [0]) > 11 
                			? Integer.ValueOf(timeValList [0]) 
                			: Integer.ValueOf(timeValList [0]) + 12;
            timeValList [0] = String.ValueOf(hrs);
            
        } 
        else if (dateOfExams [2] == 'AM') {
            Integer hrs = Integer.ValueOf(timeValList [0]) == 12
                			? 0
                			: Integer.ValueOf(timeValList [0]);
            timeValList [0] = String.ValueOf(hrs);
            
        }
        
        
        /*String stringDate = year + '-' + month + '-' + day + ' ' + hour + ':'
+ minute +  ':' + second;*/
        
        String stringDate = dateValList [2] + '-' + dateValList [0] + '-' + dateValList [1] + ' ' + timeValList [0] + ':'
            + timeValList [1] +  ':' + timeValList [2];
        
        examDateTime = Datetime.newInstance(
                            Integer.valueOf (dateValList [2]),
                            Integer.valueOf (dateValList [0]),
                            Integer.valueOf (dateValList [1]),
                            Integer.valueOf (timeValList [0]),
                            Integer.valueOf (timeValList [1]),
                            Integer.valueOf (timeValList [2]));
        return examDateTime;
    }
}