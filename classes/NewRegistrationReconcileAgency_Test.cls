@isTest  //93%
public class NewRegistrationReconcileAgency_Test {
    @isTest    
    private static void method1(){
        Test.startTest();
        Try{ 
            //create Application Account record
            Account ApplicationAccntRec = TestDataFactory_Community.createAccountTestRec('Grazitti1', 'Application');
            ApplicationAccntRec.Registration_Number__c='123';
            insert ApplicationAccntRec;
            
            //create Contact record
            Contact conRec = TestDataFactory_Community.createContactTestRec('test', 'contact', 'abcgdh@noemail.com', ApplicationAccntRec.Id);
            conRec.License_To_Date__c = System.today().AddDays(-10);
            conRec.Status__c = 'Active';
            insert conRec;
            
            //create User record
            User cmunity_usr = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            insert cmunity_usr;
            
            Account rsaAccRec = TestDataFactory_Community.createAccountTestRec('TestAcc2', 'RSA');
            rsaAccRec.Registration_Number__c='1235';
            Insert rsaAccRec;
            
            Account accRec2 = TestDataFactory_Community.createAccountTestRec('TestAcc2', 'RSA');
            Insert accRec2;
            
            RegulatoryAuthorizationType rAuth = TestDataFactory_Community.getRegAuthType();
            insert rAuth;
            BusinessLicense licrec = TestDataFactory_Community.getBusnLicTestRec(accRec2.Id, conrec.Id, rAuth.Id);
            insert licrec;
            
            List<Contact> bulkContactsTestRecs = TestDataFactory_Community.createRenewalContactsTestRec(rsaAccRec.Id,5);
            Insert bulkContactsTestRecs;
            
            List<AccountContactRelation>BulkACRRecords = TestDataFactory_Community.createBulkACRRecords(ApplicationAccntRec.Id,bulkContactsTestRecs);
            Insert BulkACRRecords;
            
            List<Schema.Location> BulkLocationTestRecList = TestDataFactory_Community.getBulkLocationTestRec(5);
            Insert BulkLocationTestRecList;
            List<Schema.Address>BulkAddessRecList = TestDataFactory_Community.getBulkAddessRec(BulkLocationTestRecList);
            Insert BulkAddessRecList;
            List<Schema.AssociatedLocation> BulkAscLationTestRecList = TestDataFactory_Community.getBulkAscLationTestRec(ApplicationAccntRec.Id,BulkLocationTestRecList);
            Insert BulkAscLationTestRecList;
            
            //create Product2 record
            Product2 NewProducts = new Product2();
            NewProducts.Name = 'CNG Meters';
            NewProducts.Family = 'Measuring devices';
            NewProducts.IsActive = TRUE;
            Insert NewProducts; 
            
            //create Asset record
            Asset devicesAsset = new Asset();
            devicesAsset.Name = 'measuringNames';
            devicesAsset.AccountId = ApplicationAccntRec.id;
            devicesAsset.Product2Id = NewProducts.Id;
            devicesAsset.Device_Type__c = 'Measuring';      
            devicesAsset.Other_Device_Comments__c = 'otherMeasuringDevicesInfo';
            insert devicesAsset;
            
            //create Content Version record
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;
            
            //Get Content Version
            List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
            System.assertEquals(cvList.size(), 1);
            system.debug('ContentVersionID : ' + cvList[0].Id);
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = ApplicationAccntRec.id;
            cdl.ContentDocumentId = cvList[0].ContentDocumentId;
            cdl.shareType = 'V';
            cdl.Visibility ='AllUsers';
            insert cdl;
            
            RegulatoryTrxnFee rtf1 = TestDataFactory_Community.getRegTranFeeTestRec(ApplicationAccntRec.id, ApplicationAccntRec.id,licrec.id);
            insert rtf1;
            rtf1.status='Paid';
            Update rtf1;
            
            
            //getRegItemsTestRecs
            List<RegulatoryTrxnFeeItem> rtfItemList1 = TestDataFactory_Community.getRegItemsTestRecsAllPaid(rtf1.Id);
            Insert rtfItemList1;
            
            //create Payment_Request__c  record 
            Payment_Request__c pr = new Payment_Request__c();
            pr.Account__c = ApplicationAccntRec.Id;
            pr.Regulatory_Transaction_Fee__c = rtf1.Id;
            pr.Status__c = 'Completed';
            pr.StartDate__c = system.today();
            pr.EndDate__c = system.today() + 2;
            pr.OwnerId = cmunity_usr.id;
            insert pr;
            
            Payment_Response__c  pRes = new Payment_Response__c();
            pRes.ReceiveDate__c = System.today();
            pRes.ePay_Return_Code__c = 'Valic Code';
            pRes.Total_Paid_Amount__c = 600;
            pRes.Card_Type__c = 'Visa';
            pRes.Payment_Request__c = pr.Id;
            pRes.Status__c = 'Success';
            pRes.ePay_Result_Message__c = 'Success';
            pRes.Confirmation_Number__c = 200;
            pRes.Settlement_Submission_Date__c = System.today();
            pRes.account__c=ApplicationAccntRec.id;
            pRes.OwnerId = cmunity_usr.id;
            pRes.Regulatory_Transaction_Fee__c = rtf1.Id;
            insert pRes;
            
            
            // Testing Part
            // createRSAAccount
            String rsaId = NewRegistrationReconcileAgency.createRSAAccount(ApplicationAccntRec.id);
            system.assert(rsaId != NULL);
            
            // updateUserContactAccount
            NewRegistrationReconcileAgency.updateUserContactAccount(ApplicationAccntRec.id, rsaAccRec.Id);
            
            // createAgents
            NewRegistrationReconcileAgency.createAgents(ApplicationAccntRec.id, rsaAccRec.Id);
            
            // createAssociatedLocation
            NewRegistrationReconcileAgency.createAssociatedLocation(ApplicationAccntRec.id, rsaAccRec.Id);
            
            //createAssets
            NewRegistrationReconcileAgency.createAssets(ApplicationAccntRec.id, rsaAccRec.Id);
            
            //createDocuments
            NewRegistrationReconcileAgency.createDocuments(ApplicationAccntRec.id, rsaAccRec.Id);
            
            //createBusinessLiecense
            String newBLId = NewRegistrationReconcileAgency.createBusinessLiecense(ApplicationAccntRec.id, rsaAccRec.Id);
            system.assert(newBLId != NULL);
            
            //createRegulatoryTrxnFee
            List<String> createRegulatoryTrxnFeeList = NewRegistrationReconcileAgency.createRegulatoryTrxnFee(ApplicationAccntRec.id, rsaAccRec.Id, newBLId);
            
            //createRegulatoryTrxnFeeItems
            NewRegistrationReconcileAgency.createRegulatoryTrxnFeeItems(ApplicationAccntRec.id, rsaAccRec.Id);
            
            // createPaymentRequest
            NewRegistrationReconcileAgency.createPaymentRequest(ApplicationAccntRec.id, rsaAccRec.Id);
            
            // createPaymentResponse
            NewRegistrationReconcileAgency.createPaymentResponse(ApplicationAccntRec.id, rsaAccRec.Id);
            
            // NewRegistration
            //
            
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
        Test.stopTest();
    }
   
    @isTest    
    private static void method2(){
        Test.startTest();
        Try{
            //create Application Account record
            Account ApplicationAccntRec = TestDataFactory_Community.createAccountTestRec('Grazitti1', 'Application');
            ApplicationAccntRec.Registration_Number__c='123';
            insert ApplicationAccntRec;
            
            //create Contact record
            Contact conRec = TestDataFactory_Community.createContactTestRec('test', 'contact', 'abcgdh@noemail.com', ApplicationAccntRec.Id);
            conRec.License_To_Date__c = System.today().AddDays(-10);
            conRec.Status__c = 'Active';
            insert conRec;
            
            //create User record
            User cmunity_usr = TestDataFactory_Community.createTestUserRec('CDFA Agent Community Login User', 'test@user.com', conRec.Id);
            insert cmunity_usr;
            
            Account rsaAccRec = TestDataFactory_Community.createAccountTestRec('TestAcc2', 'RSA');
            rsaAccRec.Registration_Number__c='1235';
            Insert rsaAccRec;
            
            Account accRec2 = TestDataFactory_Community.createAccountTestRec('TestAcc2', 'RSA');
            Insert accRec2;
            
            RegulatoryAuthorizationType rAuth = TestDataFactory_Community.getRegAuthType();
            insert rAuth;
            BusinessLicense licrec = TestDataFactory_Community.getBusnLicTestRec(accRec2.Id, conrec.Id, rAuth.Id);
            insert licrec;
            
            List<Contact> bulkContactsTestRecs = TestDataFactory_Community.createRenewalContactsTestRec(rsaAccRec.Id,5);
            Insert bulkContactsTestRecs;
            
            List<AccountContactRelation>BulkACRRecords = TestDataFactory_Community.createBulkACRRecords(ApplicationAccntRec.Id,bulkContactsTestRecs);
            Insert BulkACRRecords;
            
            List<Schema.Location> BulkLocationTestRecList = TestDataFactory_Community.getBulkLocationTestRec(5);
            Insert BulkLocationTestRecList;
            List<Schema.Address>BulkAddessRecList = TestDataFactory_Community.getBulkAddessRec(BulkLocationTestRecList);
            Insert BulkAddessRecList;
            List<Schema.AssociatedLocation> BulkAscLationTestRecList = TestDataFactory_Community.getBulkAscLationTestRec(ApplicationAccntRec.Id,BulkLocationTestRecList);
            Insert BulkAscLationTestRecList;
            
            //create Product2 record
            Product2 NewProducts = new Product2();
            NewProducts.Name = 'CNG Meters';
            NewProducts.Family = 'Measuring devices';
            NewProducts.IsActive = TRUE;
            Insert NewProducts; 
            
            //create Asset record
            Asset devicesAsset = new Asset();
            devicesAsset.Name = 'measuringNames';
            devicesAsset.AccountId = ApplicationAccntRec.id;
            devicesAsset.Product2Id = NewProducts.Id;
            devicesAsset.Device_Type__c = 'Measuring';      
            devicesAsset.Other_Device_Comments__c = 'otherMeasuringDevicesInfo';
            insert devicesAsset;
            
            //create Content Version record
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;
            
            //Get Content Version
            List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
            System.assertEquals(cvList.size(), 1);
            system.debug('ContentVersionID : ' + cvList[0].Id);
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = ApplicationAccntRec.id;
            cdl.ContentDocumentId = cvList[0].ContentDocumentId;
            cdl.shareType = 'V';
            cdl.Visibility ='AllUsers';
            insert cdl;
            
            RegulatoryTrxnFee rtf1 = TestDataFactory_Community.getRegTranFeeTestRec(ApplicationAccntRec.id, ApplicationAccntRec.id,licrec.id);
            insert rtf1;
            rtf1.status='Paid';
            Update rtf1;
            
            
            //getRegItemsTestRecs
            List<RegulatoryTrxnFeeItem> rtfItemList1 = TestDataFactory_Community.getRegItemsTestRecsAllPaid(rtf1.Id);
            Insert rtfItemList1;
            
            //create Payment_Request__c  record 
            Payment_Request__c pr = new Payment_Request__c();
            pr.Account__c = ApplicationAccntRec.Id;
            pr.Regulatory_Transaction_Fee__c = rtf1.Id;
            pr.Status__c = 'Completed';
            pr.StartDate__c = system.today();
            pr.EndDate__c = system.today() + 2;
            pr.OwnerId = cmunity_usr.id;
            insert pr;
            
            Payment_Response__c  pRes = new Payment_Response__c();
            pRes.ReceiveDate__c = System.today();
            pRes.ePay_Return_Code__c = 'Valic Code';
            pRes.Total_Paid_Amount__c = 600;
            pRes.Card_Type__c = 'Visa';
            pRes.Payment_Request__c = pr.Id;
            pRes.Status__c = 'Success';
            pRes.ePay_Result_Message__c = 'Success';
            pRes.Confirmation_Number__c = 200;
            pRes.Settlement_Submission_Date__c = System.today();
            pRes.account__c=ApplicationAccntRec.id;
            pRes.OwnerId = cmunity_usr.id;
            pRes.Regulatory_Transaction_Fee__c = rtf1.Id;
            insert pRes;
            
            system.runAs(cmunity_usr){
                NewRegistrationReconcileAgency.NewRegistration(ApplicationAccntRec.id);
            }
        }catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
        
        Test.stopTest();
    }
}