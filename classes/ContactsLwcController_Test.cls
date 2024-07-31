@isTest
public class ContactsLwcController_Test {
    @isTest
    Private static void test_Method(){
        Try{
            Account acc1 = TestDataFactory_community.createAccountTestRec('TestAcc', 'Renewal');
            insert acc1;
			Account acc2 = TestDataFactory_community.createAccountTestRec('TestAcc', 'RSA');
            insert acc2;
            
            Id RSAAgentRecordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('RSAAgent').getRecordTypeId();
            List<Contact> testConList = TestDataFactory_Community.createContactsTestRec(acc1.Id, 5);
            insert testConList;
            
            AccountContactRelation acr = new AccountContactRelation(ContactID =testConList[0].Id, AccountId=acc2.Id, Status__c ='Pending Payment');
            insert acr; 
            
            Agency_Renewal__c ar = new Agency_Renewal__c(Renewal_Account__c=acc1.Id, Status__c='Payment Pending');
            insert ar;
            Agency_Renewal__c ar1 = new Agency_Renewal__c(Renewal_Account__c=acc1.Id, Status__c='Paid');
            insert ar1;
            
            //getContacts
            Test.startTest();
            
            ContactsLwcController.getContacts(acc2.Id);
           	Integer count = [select count() from Contact WHERE Id IN
                                (SELECT contactId FROM AccountContactRelation WHERE AccountId=: acc2.Id AND status__c='Pending Payment')
                                AND RecordTypeId=:RSAAgentRecordTypeId];
            
            //search
            	String searchTerm = 'testkey1';
            	String searchTerm1 ;
                string myObject ;
                String filter = 'key' ;
            	String myQuery = null;
            List <contact> mylist9 = ContactsLwcController.search(searchTerm,myObject,filter);
            List <contact> mylist8 = ContactsLwcController.search(searchTerm1,myObject,filter);
            
            //getAgents
            String searchkey = 'testCon';
            List <contact> mylist = ContactsLwcController.getAgents(searchkey);
                
            //fetchLookupData
            list <sObject> mylist2 = ContactsLwcController.fetchLookupData(searchkey);
            
            //checkPrimaryContact
            Boolean mylist3 =ContactsLwcController.checkPrimaryContact(acc1.Id,testConList[0].Id);

            //addAgent
            list <string> addcon = new list <string>();
                addcon.add(testConList[0].Id);
                addcon.add(testConList[2].Id);
                addcon.add(testConList[3].Id);
            ContactsLwcController.addAgent(addcon,acc2.Id);
            
            //removeAgent
            ContactsLwcController.removeAgent(addcon,acc1.Id);
            
            //getRenewalPaid
            ContactsLwcController.getRenewalPaid(acc1.Id);
            
            List<sObject> countList = [SELECT Id, Name, Status__c, Renewal_Account__c FROM Agency_Renewal__c 
                                       where Renewal_Account__c=: acc1.Id AND status__C IN ('Paid', 'Payment Pending')];
            
            //getPaidStatus
            ContactsLwcController.getPaidStatus(acc1.Id);
            
            List<sObject> countList1 = [SELECT Id, Name, Status__c, Renewal_Account__c FROM Agency_Renewal__c 
                                        where Renewal_Account__c=: acc1.Id AND status__C =: 'Paid'];
            
            //updateAgentStatus 
            Map<id,Agency_Renewal__c> oldmap = new Map<id,Agency_Renewal__c>();
            Map<id,Agency_Renewal__c> newmap = new Map<id,Agency_Renewal__c>();
			Agency_Renewal__c arupdate = new Agency_Renewal__c(Renewal_Account__c=acc1.Id, Status__c='Payment Pending');
            insert arupdate;          
            oldmap.put(arupdate.id, arupdate);
            arupdate.Status__c = 'Paid';
            update arupdate ;        
            newmap.put(arupdate.id, arupdate);
            
            ContactsLwcController.updateAgentStatus(oldmap, newmap);
            Test.stopTest();
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        } 
    }
}