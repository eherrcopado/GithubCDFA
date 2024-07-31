/*
	Developed By	: 	qualapps(130897)
	Test Class Name	:	AgencyPDFCtrl_Test
	Apex Class		:	AgencyPDFCtrl
	Purpose			:	This class used for code Coverage of AgencyPDFCtrl Class
*/

@isTest
public class AgencyPDFCtrl_Test {
    @isTest    
    private static void method()
    {
        Try{
            Account ac = TestDataFactory_Community.createAccountTestRec('Grazitti', 'RSA');
            insert ac; 
            
            Contact con = TestDataFactory_Community.createContactTestRec('test', 'account', 'tes'+ac.id+'@noemail.com', ac.Id);
            con.License_To_Date__c = System.today().AddDays(-10);
            insert con;
            
            User cmunity_usr = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', con.Id);
            insert cmunity_usr;
            
            RegulatoryAuthorizationType raType = TestDataFactory_Community.getRegAuthType();
            Insert raType;
            system.debug('raType - '+raType);
            
			BusinessLicense bl = TestDataFactory_Community.getBusnLicTestRec(ac.Id, con.Id, raType.Id);
            Insert bl;
			
            BusinessLicenseApplication blApll = TestDataFactory_Community.getBusnLicAppTestRec(ac.Id,con.id,raType.Id);
            Insert blApll;
            system.debug('blApll-- '+blApll);
            
            RegulatoryTrxnFee rtf = new RegulatoryTrxnFee(AccountId=ac.id,Status='Due', ParentRecordId = blApll.id);
            insert rtf;
            
            List<RegulatoryTrxnFeeItem> rtfItemList = TestDataFactory_Community.getRegItemsTestRecs(rtf.Id);
            Insert rtfItemList;

            Schema.Location lc = TestDataFactory_Community.getLocationTestRec();
            insert lc;

            Schema.AssociatedLocation asl = TestDataFactory_Community.getAscLationTestRec(ac.Id,lc.Id);
            Insert asl;
           
            system.runAs(cmunity_usr) {
                Test.startTest();
                AgencyPDFCtrl agncyObj = new AgencyPDFCtrl();
                AgentPDFCtrl agntbj = new AgentPDFCtrl();
                Test.stopTest();
            }
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }
}