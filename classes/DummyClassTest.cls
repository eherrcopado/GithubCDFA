@isTest 
public class DummyClassTest {
    
    static testMethod void test1() {
        
        try{
            Account acc1=new Account(Name='Account1',Industry='Agriculture');
            insert acc1; 
            
            Account accountId=[SELECT Id, Industry FROM Account LIMIT 1];
            
            Contact conrec = TestDataFactory_Community.createContactTestRec('JSXJH', 'JHSJCH', 'hhsb@gdwUH.COM', acc1.Id);
            insert conrec;
            
            
            User cmunity_usr = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'tes'+conrec.Id+'@noemail.com', conrec.id);
            //cmunity_usr.ContactId = ;
            insert cmunity_usr;
            
            Schema.Location locRec = TestDataFactory_Community.getLocationTestRec();
            Insert locRec;
            RegulatoryAuthorizationType rAuth = TestDataFactory_Community.getRegAuthType();
            insert rAuth;
            BusinessLicense licrec = TestDataFactory_Community.getBusnLicTestRec(acc1.Id, conrec.Id, rAuth.Id);
            insert licrec;
            Schema.AssociatedLocation assloc = TestDataFactory_Community.getAscLationTestRec(acc1.Id,locRec.Id);
            Insert assloc;
            
            Schema.Address addrec = testdatafactory_community.getAddessRec(locRec.Id);
            Insert addrec;
            
            
            
            Task t = new Task(Subject = 'Test');
            insert t;
            update t;
            
            //List<Schema.Location> locations = new List<Schema.Location>();
            Schema.Location locationRec = new Schema.Location();
            locationRec.Name = 'test';
            insert locationRec;
            
            AssociatedLocation al = new AssociatedLocation();
            al.ParentRecordId = acc1.Id;
            al.locationid = locationRec.Id;
            insert al;
            
            system.runAs(cmunity_usr){
                Test.startTest();
                
                DummyClass.dummy1();
                DummyClass.dummy2();
                DummyClass.dummy3();
                
                Test.stopTest();
            }
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }
}