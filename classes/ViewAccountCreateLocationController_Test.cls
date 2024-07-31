@isTest
public class ViewAccountCreateLocationController_Test {
	@isTest
    Private static void TestUseCase1(){
        Try{
            Account accRec = TestDataFactory_Community.createAccountTestRec('TestAcc', 'RSA');
            Insert accRec;
            accRec.Renewal_Process__c='Draft';
            Update accRec;
            Account accRenewalRec = TestDataFactory_Community.createAccountTestRec('accRenewalRec', 'Renewal');
            Insert accRenewalRec;
            accRenewalRec.Original_Account_Id__c = accRec.Id;
            update accRenewalRec;
            Contact conRec = TestDataFactory_Community.createContactTestRec('test','con','test@com.com',accRec.Id);
            Insert conRec;
            User testUser = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            Insert testUser;
            RegulatoryAuthorizationType rAuth = TestDataFactory_Community.getRegAuthType();
            insert rAuth;
            BusinessLicense licrec = TestDataFactory_Community.getBusnLicTestRec(accRec.Id, conrec.Id, rAuth.Id);
            insert licrec;
            Schema.Location locRec = TestDataFactory_Community.getLocationTestRec();
            Insert locRec;
            Schema.AssociatedLocation assloc = TestDataFactory_Community.getAscLationTestRec(accRec.Id,locRec.Id);
            Insert assloc;
            Schema.Address addrec = testdatafactory_community.getAddessRec(locRec.Id);
            Insert addrec;
            
            AddressWrapper wrapper= new AddressWrapper();
            wrapper.street='1 INFINITE LOOP';
            wrapper.city='CUPERTINO';
            wrapper.state='CA';
            wrapper.postalcode='95014';
            wrapper.country='USA';
            wrapper.county='Calaveras';
            wrapper.parentRecordId= accRec.Id;
            wrapper.locationName= 'Test Loc 95014';
            wrapper.type = 'Other';
            
            system.runAs(testUser) {
                // statements to be executed by this test user.
                Test.startTest();
                
                sObject objData = ViewAccountCreateLocationController.fetchDefaultRecord(accRec.Id);
                system.assert(objData!=NULL);
                
                List<AddressWrapper>wrapperList = ViewAccountCreateLocationController.createAssociatedLocation(wrapper);
				system.assert(wrapperList.size()>0);
                
                List<schema.address>addressList = ViewAccountCreateLocationController.getAllAddress();
                system.assert(addressList.size()>0);
                
                AddressWrapper wrapperobj = ViewAccountCreateLocationController.getAssociatedLocationRecord(accRec.Id, assloc.Id);
                system.assert(wrapperobj!=NULL);
                
                wrapper.ascId = assloc.Id;
                ViewAccountCreateLocationController.updateAssociatedLocation(wrapper);
                
                List<AddressWrapper>accountRelatedAddressList = ViewAccountCreateLocationController.getAccountRelatedAddress(accRec.Id);
                system.assert(accountRelatedAddressList.size()>0);
                
                Test.stopTest();
            }
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }
}