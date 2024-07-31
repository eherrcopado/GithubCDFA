@isTest//92%
public class NewAgencyController_Test {
    @isTest    
    private static void method1()
    {
        //createNewAccountRecord
        NewAgencyController.createNewAccountRecord();
        //submitApprovalNewRegistration
        
        Try{
            List<Account> accList1 = new list <Account>();
            
            Account rsaAcc1 = TestDataFactory_Community.createAccountTestRec('Grazitti1', 'RSA');
            insert rsaAcc1;
            
            Account acc1 = rsaAcc1;
            
            Contact con = TestDataFactory_Community.createContactTestRec('test', 'account', 'tes'+acc1.id+'@noemail.com', acc1.Id);
            con.License_To_Date__c = System.today().AddDays(-10);
            insert con;
            
            User cmunity_usr = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', con.Id);
            insert cmunity_usr;
            
            RegulatoryAuthorizationType raType = TestDataFactory_Community.getRegAuthType();
            Insert raType;
            
            system.debug('raType - '+raType);
            
            BusinessLicense getBusnLicTestRec = TestDataFactory_Community.getBusnLicTestRec(acc1.Id,con.Id, raType.id);
            insert getBusnLicTestRec;
            
            Schema.Location locationRec = TestDataFactory_Community.getLocationTestRec();
            insert locationRec;
            
            Schema.Address addressRec = TestDataFactory_Community.getAddessRec(locationRec.Id);
            insert addressRec;
            
            Schema.AssociatedLocation ascLocationRec = TestDataFactory_Community.getAscLationTestRec(acc1.Id,locationRec.Id);
            insert ascLocationRec;
            
            NewAgencyController.UserAccountWrapper wrp = new NewAgencyController.UserAccountWrapper();
            wrp.accId = rsaAcc1.Id;
            wrp.renewalAccount = rsaAcc1;
            wrp.conFName = con.FirstName;
            wrp.conLName = con.LastName;
            
            
            system.runAs(cmunity_usr) {
                Test.startTest();
                //createNewAccountRecord
                NewAgencyController.UserAccountWrapper obj = new NewAgencyController.UserAccountWrapper();
                obj = NewAgencyController.createNewAccountRecord();
                //submitApprovalNewRegistration
                NewAgencyController.submitApprovalNewRegistration(accList1);
                Test.stopTest();
            }
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }
    @isTest    
    private static void method2()
    {
        try{
            
            List<Account> accList1 = new list <Account>();
            Account acc1 = TestDataFactory_community.createAccountTestRec('Test Record','Application');
            acc1.Renewal_Process__c='Pending Approval';
            insert acc1;
            
            accList1.add(acc1);   
            Contact con = TestDataFactory_Community.createContactTestRec('test', 'account', 'tes'+acc1.id+'@noemail.com', acc1.Id);
            con.License_To_Date__c = System.today().AddDays(-10);
            insert con;
            
            User cmunity_usr = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', con.Id);
            insert cmunity_usr;
            
            //create RegulatoryAuthorizationType  record 
            RegulatoryAuthorizationType raType = TestDataFactory_Community.getRegAuthType();
            Insert raType;
            system.debug('raType - '+raType);
            
            //create BusinessLicense  record 
            BusinessLicense getBusnLicTestRec = TestDataFactory_Community.getBusnLicTestRec(acc1.Id,con.Id, raType.id);
            getBusnLicTestRec.Status = 'Active';
            insert getBusnLicTestRec;
            
            system.runAs(cmunity_usr) {
                Test.startTest();
                //submitApprovalNewRegistration
                NewAgencyController.submitApprovalNewRegistration(accList1);
                Test.stopTest();
            }
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }
}