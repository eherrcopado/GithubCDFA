@isTest
public class SendEmailTo_MatchingContact_Test {
    
    public static TestMethod void success_Senario(){
        
        set<id> contactIdSet = new set<id>();
        
        Account accRec = TestDataFactory_Community.createAccountTestRec2('TestAcc', 'RSA');
        Insert accRec;
        
        Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
        Insert conRec;
        
        contactIdSet.add(conRec.id);
        System.Assert(String.isNotBlank(conRec.id),TRUE );
        System.enqueueJob(new SendEmailTo_MatchingContact(contactIdSet, false));
    }
    
    public static TestMethod void success_Senario2(){
        
        set<id> contactIdSet = new set<id>();
        
        Account accRec = TestDataFactory_Community.createAccountTestRec2('TestAcc', 'RSA');
        Insert accRec;
        
        Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
        Insert conRec;
        
        contactIdSet.add(conRec.id);
        System.Assert(String.isNotBlank(conRec.id),TRUE );
        System.enqueueJob(new SendEmailTo_MatchingContact(contactIdSet, True));
    }

}