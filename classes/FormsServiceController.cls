public without sharing class FormsServiceController {
    
    @AuraEnabled
    public static void setFormCData(List<String> measuringDevicesNames,List<String> weighingDevicesNames,
                                    String otherWeighingDeviceInfo, String otherMeasuringDevicesInfo,
                                    String acctId){
        createAssetsForDevices(measuringDevicesNames,weighingDevicesNames,otherWeighingDeviceInfo,otherMeasuringDevicesInfo, acctId );
    }    
    
    public static void createAssetsForDevices(List<String> measuringDevicesNames, List<String> weighingDevicesNames,
                                               String otherWeighingDevicesInfo,String otherMeasuringDevicesInfo,String acctId3 ){
    
   //system.debug('measuring devices ---'+measuringDevicesNames+'---'+measuringDevicesNames.size());
    if(measuringDevicesNames!=null && measuringDevicesNames.size()>0 && measuringDevicesNames.get(0).length()>0){
         deleteExistingAssetsFromTheAccount(acctId3,'Measuring');
    }else if(measuringDevicesNames.size() == 0){
          deleteExistingAssetsFromTheAccount(acctId3,'Measuring');
    }else if(measuringDevicesNames!=null && measuringDevicesNames.size()==1 && otherMeasuringDevicesInfo!=null && !otherMeasuringDevicesInfo.equals('') && otherMeasuringDevicesInfo.length()>1){
         updateMeasuringDeviceInfo(acctId3, otherMeasuringDevicesInfo);
     }
    
   // system.debug('weighing devices ---'+weighingDevicesNames+'---'+weighingDevicesNames.size()+'-- weighn info --'+otherWeighingDevicesInfo);
     if(weighingDevicesNames!=null && weighingDevicesNames.size()>0 && weighingDevicesNames.get(0).length()>0){
         deleteExistingAssetsFromTheAccount(acctId3,'Weighing');
     }else if(weighingDevicesNames.size() == 0){
         deleteExistingAssetsFromTheAccount(acctId3,'Weighing');
     }else if(weighingDevicesNames!=null && weighingDevicesNames.size()==1 && otherWeighingDevicesInfo!=null && !otherWeighingDevicesInfo.equals('') && otherWeighingDevicesInfo.length()>1){
         updateWeighingDeviceInfo(acctId3,otherWeighingDevicesInfo);
     }
        List<Asset> devicesAssets = new List<Asset>();
        Map<String,Id> productsMap = new Map<String,Id>();
        if(measuringDevicesNames!=null && measuringDevicesNames.size()>0 && measuringDevicesNames.get(0).length()>0) {
            for(String measuringNames: measuringDevicesNames){    
                Asset devicesAsset = new Asset();
                devicesAsset.Name = measuringNames;
                devicesAsset.AccountId = acctId3;
                devicesAsset.Product2Id = getProductId(productsMap,measuringNames);
                devicesAsset.Device_Type__c = 'Measuring';
                if(measuringNames.equalsIgnoreCase('Other Measuring Devices')){
                    devicesAsset.Other_Device_Comments__c = otherMeasuringDevicesInfo;
                    devicesAsset.Description = otherMeasuringDevicesInfo;
               }
                devicesAssets.add(devicesAsset);
            }          
        }
       //  system.debug('otherWeighingDevicesInfo --'+otherWeighingDevicesInfo);                                          
        if(weighingDevicesNames!=null && weighingDevicesNames.size()>0 && weighingDevicesNames.get(0).length()>0) {
           for(String weighingNames: weighingDevicesNames){
                Asset devicesAsset = new Asset();
                devicesAsset.Name = weighingNames;
                devicesAsset.AccountId = acctId3;
                devicesAsset.Product2Id = getProductId(productsMap,weighingNames);
                devicesAsset.Device_Type__c = 'Weighing';
                if(weighingNames.equalsIgnoreCase('Other Weighing Devices')){
                    devicesAsset.Other_Device_Comments__c = otherWeighingDevicesInfo;
                    devicesAsset.Description = otherWeighingDevicesInfo;
                }
                devicesAssets.add(devicesAsset);
            }
        }
             if(devicesAssets!=null && !devicesAssets.isEmpty()) {
                    Database.SaveResult[] srList = Database.insert(devicesAssets,false);                  	
              }
    }    
    @TestVisible
    private static void updateMeasuringDeviceInfo(String acctId3, String otherMeasuringDevicesInfo){
        Asset updateMeasuringDevicesInfoAsset;
        for(Asset existingAsset : [select id,name,Other_Device_Comments__c,Description,device_type__c from Asset where AccountId= :acctId3 And Device_Type__c ='Measuring']){
            if(existingAsset.name.equals('Other Measuring Devices')){
                updateMeasuringDevicesInfoAsset = existingAsset;
                updateMeasuringDevicesInfoAsset.Other_Device_Comments__c = otherMeasuringDevicesInfo;
                updateMeasuringDevicesInfoAsset.Description = otherMeasuringDevicesInfo;
            }
        }
        if(updateMeasuringDevicesInfoAsset !=null ){
            update updateMeasuringDevicesInfoAsset;
        }
    }
    @TestVisible
    private static void updateWeighingDeviceInfo(String acctId3, String otherWeighingDevicesInfo){
        Asset updateWeighingDevicesInfoAsset;
        for(Asset existingAsset : [select id,name,Other_Device_Comments__c,Description,device_type__c from Asset where AccountId= :acctId3 And Device_Type__c ='Weighing']){
            if(existingAsset.name.equals('Other Weighing Devices')){
                updateWeighingDevicesInfoAsset = existingAsset;
                updateWeighingDevicesInfoAsset.Other_Device_Comments__c = otherWeighingDevicesInfo;
                updateWeighingDevicesInfoAsset.Description = otherWeighingDevicesInfo;
            }
        }
        if(updateWeighingDevicesInfoAsset !=null ){
            update updateWeighingDevicesInfoAsset;
        }
    }
    
    public static void deleteExistingAssetsFromTheAccount(String acctId1,String devicetype){
        List<Asset> existingAssetsListToDelete = new List<Asset>();
        for(Asset asset: [select id,name,device_type__c from Asset where AccountId= :acctId1 
                          And (Device_Type__c = :devicetype or Device_Type__c = :devicetype)]){
            existingAssetsListToDelete.add(asset);
        }
        if(existingAssetsListToDelete.size()>0){
            Database.DeleteResult[] deleteResult =  Database.delete(existingAssetsListToDelete,false);
        }
    }
    
    @AuraEnabled//(cacheable=true)
    public static List<Asset> getExistingAssetsForAnAccount(String acctId){
        // List<Asset> myAsset = [select device_type__c,Other_Device_Comments__c,id,name from Asset where AccountId =:acctId 
        //                        And (Device_Type__c ='Weighing' or Device_Type__c ='Measuring')]; 
     	List<Asset> myAsset = [select device_type__c,Other_Device_Comments__c,Description,id,name from Asset where AccountId =:acctId 
                               And (Device_Type__c ='Weighing' or Device_Type__c ='Measuring')]; 
        return myAsset;
    }
    
    @AuraEnabled (cacheable=true)
    public static List<Product2> getAllTheProductsMaster(){     
       return new List<Product2>([select id,name,isActive,family from Product2 where isActive=true and family in('Measuring Devices','Weighing Devices') order by name asc]); 
    }
    
    @AuraEnabled
    public static List<sObject> getUploadedDocumentsForAnAgency(String acctId){ 
       return new List<ContentDocumentLink>([SELECT ContentDocumentId FROM ContentDocumentLink where LinkedEntityId in 
                                ( SELECT Id FROM account where id= :acctId)]); 
    }
    
    public static Id getProductId(Map<String,Id> productsMap,String productName){ 
       Id productId ;
        if(productsMap != null && productsMap.isEmpty()){
            for(Product2 prod : [select Id,name,isActive from Product2 where isActive=true]){
                productsMap.put(prod.name,prod.Id);
            }
         	productId = productsMap.get(productName);            
        }else{
            productId = productsMap.get(productName);            
        } 
        return productId;
    }
    
    @AuraEnabled//(cacheable=true)
        public static Map<ID, String> getRelatedFilesByRecordId(String recordId) {
                  
            List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
            List<ID> fileIDs = new List<ID>();
            for (ContentDocumentLink docLink : files) {
                fileIDs.add(docLink.ContentDocumentId);
            }
     
            List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
            Map<ID, String> mapIdTitle = new Map<ID, String>();        
             
            List<ContentDistribution> cdRecList= new List<ContentDistribution>();
            for(ContentVersion cvRec: docs){
                ContentDistribution cdRec= new ContentDistribution(
                                Name = cvRec.Title,
                                ContentVersionId = cvRec.Id,
                                PreferencesAllowViewInBrowser= true,
                				PreferencesNotifyOnVisit=false);
                cdRecList.add(cdRec);   
            }
            if(cdRecList.size()>0){
              insert cdRecList;  
            }
            for (ContentVersion docLink : docs) {
                mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
            }
            return mapIdTitle;
        }
    
    @auraenabled
    public static String getPreviewDocUrl(string contentDocId){
        List<ContentDistribution> insertedCDRecList= [SELECT ContentDownloadUrl  FROM ContentDistribution WHERE ContentDocumentId =:contentDocId];
        String docUrl= insertedCDRecList.get(0).ContentDownloadUrl ;
        return docUrl;
    }//EO getPreviewDocUrl
    
    @auraenabled
    public static void displayFilesRecord(string recordId){
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE Id = :recordId];
        Delete files;
    }
}