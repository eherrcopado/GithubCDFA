public class AssetProductUpdate {
    
    public static void setProductIdForEachAsset(){ 
        List<Asset> updateList = new List<Asset>();
        Map<String,Id> productsMap = new Map<String,Id>();
        for(Asset asset: [select device_type__c,Product2Id,Other_Device_Comments__c,id,name from Asset where  
                          Product2Id=null and (Device_Type__c ='Weighing' or Device_Type__c ='Measuring')]){            
           
           if(asset.Product2Id == null){
               asset.Product2Id = getProductId(productsMap,asset.Name);
               updateList.add(asset);
           }
        }
        system.debug('updateList size -- '+updateList.size());
        if(updateList.size() > 0){
            update updateList;
        }
        
    }  
    
    public static Id getProductId(Map<String,Id> productsMap,String productName){ 
       Id productId ;
        if(productsMap != null && productsMap.isEmpty()){
            for(Product2 prod : [select Id,name from Product2 where isActive=true and family in('Measuring Devices','Weighing Devices')]){
                productsMap.put(prod.name,prod.Id);
            }
			productId = productsMap.get(productName);            
        }else{
            productId = productsMap.get(productName);            
        }        
        return productId;
    }
}