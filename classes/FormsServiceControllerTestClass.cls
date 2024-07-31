@isTest
public class FormsServiceControllerTestClass {
    
    @isTest
    Private static void test_Method(){
        Try{
            Test.startTest();
            Id p = [select id from profile where name='CDFA Agent Community Login User'].id;
            List<String> measuringDevicesNames = New List<String>();
            List<String> weighingDevicesNames = New List<String>();
            String otherWeighingDeviceInfo = 'OtherDeviceInfo';
            String otherMeasuringDevicesInfo = 'otherMeasuringDevicesInfo';
            Account ac = new Account(name ='Grazitti',Registration_Number__c='123', Status__c ='Active', Legal_Entity__c= 'Corporation');
            insert ac; 
            String AccountId = String.valueOf(ac.id);
            List<Contact>testConList = new List<Contact>();
            Id contactRecordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('RSAAgent').getRecordTypeId();
            for(integer i=0; i<5; i++){
                Contact con = new Contact();
                con.Email='abc@xyz.com'+i;
                con.LastName ='testCon'+i;
                con.AccountId = ac.Id;
                con.RecordTypeId = contactRecordTypeId;
                testConList.add(con);
            }
            insert testConList;
            
            User user = new User(alias = 'test123', email='abc@xyz.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                                 ContactId = testConList[0].Id,
                                 timezonesidkey='America/Los_Angeles', username='abc@xyz.com');
            insert user;
            
            Product2 NewProducts = new Product2();
            NewProducts.Name = 'CNG Meters';
            NewProducts.Family = 'Measuring devices';
            NewProducts.IsActive = TRUE;
            Insert NewProducts; 
            
            //List<Asset> devicesAssets = new List<Asset>();
            Asset devicesAsset = new Asset();
            devicesAsset.Name = 'measuringNames';
            devicesAsset.AccountId = ac.id;
            devicesAsset.Product2Id = NewProducts.Id;
            devicesAsset.Device_Type__c = 'Measuring';      
            devicesAsset.Other_Device_Comments__c = 'otherMeasuringDevicesInfo';
            insert devicesAsset;
            
            Asset devicesAsset1 = new Asset();
            devicesAsset1.Name = 'weighingNames';
            devicesAsset1.AccountId = ac.id;
            devicesAsset1.Product2Id = NewProducts.Id;
            devicesAsset1.Device_Type__c = 'Weighing';      
            devicesAsset1.Other_Device_Comments__c = 'otherMeasuringDevicesInfo';
            insert devicesAsset1;
            //Create contentVersion
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
            cdl.LinkedEntityId = ac.id;
            cdl.ContentDocumentId = cvList[0].ContentDocumentId;
            cdl.shareType = 'V';
            insert cdl;  
            System.assertEquals(cdl.ContentDocumentId,cvList[0].ContentDocumentId);
            
            
            Map<ID, String>  mapContentVersion = FormsServiceController.getRelatedFilesByRecordId(ac.Id);
            
            system.debug('mapContentVersion : ' +mapContentVersion.values());
            string mapTitle = mapContentVersion.values()[0];
            System.assertEquals(mapTitle ,'Test Document');
            measuringDevicesNames.add('Device1');
            measuringDevicesNames.add('Device2');
            weighingDevicesNames.add('Device2');
            weighingDevicesNames.add('Device1');
            
            
            /*
            FormsServiceController.deleteExistingAssetsFromTheAccount(AccountId,'Measuring');
            FormsServiceController.deleteExistingAssetsFromTheAccount(AccountId,'Weighing');
            FormsServiceController.createAssetsForDevices(measuringDevicesNames, weighingDevicesNames, otherWeighingDeviceInfo, otherMeasuringDevicesInfo, AccountId);
            FormsServiceController.getExistingAssetsForAnAccount(AccountId);
            FormsServiceController.getAllTheProductsMaster();
            FormsServiceController.getUploadedDocumentsForAnAgency(AccountId);
            FormsServiceController.displayFilesRecord(cdl.Id);
            FormsServiceController.getPreviewDocUrl(cdl.Id);
            */
            FormsServiceController.displayFilesRecord(cdl.Id);
            FormsServiceController.setFormCData(measuringDevicesNames, weighingDevicesNames, otherWeighingDeviceInfo, otherMeasuringDevicesInfo, AccountId);
            List<Asset> astList = FormsServiceController.getExistingAssetsForAnAccount(AccountId);
            system.assert(astList.size() > 0);
            List<Product2> prodList = FormsServiceController.getAllTheProductsMaster();
            system.assert(astList.size() > 0);
            FormsServiceController.getUploadedDocumentsForAnAgency(AccountId);
            FormsServiceController.getPreviewDocUrl(cdl.Id);
             FormsServiceController.updateMeasuringDeviceInfo(ac.Id, 'Hp Power Meter');
                FormsServiceController.updateWeighingDeviceInfo(ac.Id, 'Hp Power Meter');
            
            system.runAs(user){
               // String AccId = ac.Id;
               
            }
            }
        catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
        
    }
    
    @isTest
    Private static void test_Method2(){
        Try{
            Test.startTest();
            Id p = [select id from profile where name='CDFA Agent Community Login User'].id;
            List<String> measuringDevicesNames = New List<String>();
            List<String> weighingDevicesNames = New List<String>();
            String otherWeighingDeviceInfo = 'OtherDeviceInfo';
            String otherMeasuringDevicesInfo = 'otherMeasuringDevicesInfo';
            Account ac = new Account(name ='Grazitti',Registration_Number__c='123', Status__c ='Active', Legal_Entity__c= 'Corporation');
            insert ac; 
            String AccountId = String.valueOf(ac.id);
            List<Contact>testConList = new List<Contact>();
            Id contactRecordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('RSAAgent').getRecordTypeId();
            for(integer i=0; i<5; i++){
                Contact con = new Contact();
                con.Email='abc@xyz.com'+i;
                con.LastName ='testCon'+i;
                con.AccountId = ac.Id;
                con.RecordTypeId = contactRecordTypeId;
                testConList.add(con);
            }
            insert testConList;
            
            User user = new User(alias = 'test123', email='abc@xyz.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                                 ContactId = testConList[0].Id,
                                 timezonesidkey='America/Los_Angeles', username='abc@xyz.com');
            insert user;
            
            Product2 NewProducts = new Product2();
            NewProducts.Name = 'CNG Meters';
            NewProducts.Family = 'Measuring devices';
            NewProducts.IsActive = TRUE;
            Insert NewProducts; 
            
            //List<Asset> devicesAssets = new List<Asset>();
            Asset devicesAsset = new Asset();
            devicesAsset.Name = 'measuringNames';
            devicesAsset.AccountId = ac.id;
            devicesAsset.Product2Id = NewProducts.Id;
            devicesAsset.Device_Type__c = 'Measuring';      
            devicesAsset.Other_Device_Comments__c = 'otherMeasuringDevicesInfo';
            insert devicesAsset;
            
            Asset devicesAsset1 = new Asset();
            devicesAsset1.Name = 'weighingNames';
            devicesAsset1.AccountId = ac.id;
            devicesAsset1.Product2Id = NewProducts.Id;
            devicesAsset1.Device_Type__c = 'Weighing';      
            devicesAsset1.Other_Device_Comments__c = 'otherMeasuringDevicesInfo';
            insert devicesAsset1;
            
            Asset otherWeighingAsset = new Asset();
            otherWeighingAsset.Name = 'Other Weighing Devices';
            otherWeighingAsset.AccountId = ac.id;
            otherWeighingAsset.Product2Id = NewProducts.Id;
            otherWeighingAsset.Device_Type__c = 'Weighing';      
            otherWeighingAsset.Other_Device_Comments__c = 'Hp Power Meter';
            insert otherWeighingAsset;
            
            Asset otherMeasuringAsset = new Asset();
            otherMeasuringAsset.Name = 'Other Measuring Devices';
            otherMeasuringAsset.AccountId = ac.id;
            otherMeasuringAsset.Product2Id = NewProducts.Id;
            otherMeasuringAsset.Device_Type__c = 'Measuring';      
            otherMeasuringAsset.Other_Device_Comments__c = 'Hp Power Meter';
            insert otherMeasuringAsset;
            
            //Create contentVersion
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
            cdl.LinkedEntityId = ac.id;
            cdl.ContentDocumentId = cvList[0].ContentDocumentId;
            cdl.shareType = 'V';
            insert cdl;  
            System.assertEquals(cdl.ContentDocumentId,cvList[0].ContentDocumentId);
            
            
            Map<ID, String>  mapContentVersion = FormsServiceController.getRelatedFilesByRecordId(ac.Id);
            
            system.debug('mapContentVersion : ' +mapContentVersion.values());
            string mapTitle = mapContentVersion.values()[0];
            System.assertEquals(mapTitle ,'Test Document');
            measuringDevicesNames.add('Device1');
            measuringDevicesNames.add('Device2');
            weighingDevicesNames.add('Device2');
            weighingDevicesNames.add('Device1');
             FormsServiceController.updateMeasuringDeviceInfo(ac.Id, 'Hp Power Meter');
                FormsServiceController.updateWeighingDeviceInfo(ac.Id, 'Hp Power Meter');
            
            system.runAs(user){
               // String AccId = ac.Id;
               
            }
            }
        catch(Exception e){
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
        
    }
    
}