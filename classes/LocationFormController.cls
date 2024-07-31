public without sharing class LocationFormController {
    @AuraEnabled//(cacheable=true)
    public static List<sObject> getLocation(String accId){
        List<sobject> returnList = New List<sobject>();
        System.debug(accId+ '- accId ');
        Try{
            returnList = [SELECT Id,visitorId__c, LocationId,  Type, Status__c, ParentRecordId, Address__c, 
                          AssociatedLocationNumber, Location.Name FROM AssociatedLocation 
                          WHERE ParentRecordId =: accId AND (Status__c='Pending Payment' OR Status__c='Active')];
        }Catch(Exception e){
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getCause());
            system.debug(e.getMessage());
        }
        return returnList;
    }
    
    @AuraEnabled(cacheable=true)
    public static list<sObject> getLookupAddress(string searchKey) {
        //SELECT Id, Address__c  FROM AssociatedLocation  Where Address__c like '%%' order by createdDate DESC LIMIT 10
        string sWildCardText = '%' + searchKey + '%';
        
        List<schema.address>returnList  = [SELECT ParentId, Street, City, State, PostalCode, Country FROM Address
                                           Where ParentId != null and ((Street Like : sWildCardText) OR (City Like : sWildCardText)
                                                                       OR (State Like : sWildCardText) OR (PostalCode Like : sWildCardText)
                                                                       OR (Country Like : sWildCardText))]; 

        return returnList;
        
    }
    
    @AuraEnabled
    public static void createALocation(string accId, string addrId){     
        Id LocationID = [Select parentid from Address Where id =:addrId].parentId;

        Schema.AssociatedLocation NewAssociatedLocation = New Schema.AssociatedLocation();
        NewAssociatedLocation.ParentRecordId = accId;
        NewAssociatedLocation.status__c = 'Pending Payment';
        NewAssociatedLocation.Type = 'Other';
        NewAssociatedLocation.LocationId = LocationID;
        insert NewAssociatedLocation;      
    }
    //addAssociatedLocation, removeAssociatedLocation
    @AuraEnabled
    public static List<sObject> addAssociatedLocation(List<String> wrapperList, Id accId){
        Set<String> WrapperSet = New Set<String>();
        WrapperSet.addall(wrapperList);
        //id locationId =  [SELECT id FROM Location WHERE Account__c =: accId].id;
        List<schema.AssociatedLocation> AssocLocationList = new List<schema.AssociatedLocation>();
        try{
            if(WrapperSet!=null)
            {
                List<Schema.Address> AddrList = [Select ParentId from address Where id IN:WrapperSet];
                If(!AddrList.isEmpty()) {
                    For(Schema.address addr :AddrList) {  
                        schema.AssociatedLocation al = New schema.AssociatedLocation();
                        al.ParentRecordId = accid;
                        al.status__c = 'Active';
                        al.Type = 'Other';
                        al.LocationId = addr.ParentId;
                        AssocLocationList.add(al);                            
                    }
                    If(!AssocLocationList.isEmpty()) {
                        Database.SaveResult[] insertSaveResult = Database.insert(AssocLocationList, false);
                        
                    }                      
                }               
      
            }
            
        }catch(Exception e){
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getCause());
            system.debug(e.getMessage());
        }
        return AssocLocationList;
    }
    @AuraEnabled
    public static void removeAssociatedLocation(List<String> removeList, Id accId){

        Set<String> WrapperSet = New Set<String>();
        Set<Id> addrID = New Set<Id>();
        Set<Id> locID = New Set<Id>();
        List<schema.AssociatedLocation> delLoc = New List<schema.AssociatedLocation>();
        WrapperSet.addall(removeList);
        //id locationId =  [SELECT id FROM Location WHERE Account__c =: accId].id;
        List<schema.AssociatedLocation> AssocLocationList = new List<schema.AssociatedLocation>();
        List<schema.AssociatedLocation> DelasLoc = new List<schema.AssociatedLocation>();
        try{
            if(WrapperSet!=null)
            {
                List<Schema.Address> AddrList = [Select ID,ParentId from address Where id IN:WrapperSet];
                For(Schema.Address DelAddr : AddrList) {
                    addrID.add(DelAddr.id);
                    locID.add(DelAddr.ParentId);
                }
                
                DelasLoc = [SELECT id FROM AssociatedLocation WHERE  visitorId__c in:addrID AND LocationId in:locID AND ParentRecordId =:accId];
                
                //delLoc.add(DelasLoc);
                
                try{
                    if(DelasLoc != NULL){
                        delete DelasLoc;
                    }
                }catch(Exception e){
                    system.debug(e.getTypeName());
                    system.debug(e.getLineNumber());
                    system.debug(e.getCause());
                    system.debug(e.getMessage());
                }              
                
                
            }
            
        }catch(Exception e){
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getCause());
            system.debug(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    //public static void createLocation(String actId, List<AddressInfoWrapper> addressWrapper){
    public static List<AddressWrapper> createLocation(String actId, String street, String city, String province, String country, String postalcode,String county){
        List<AddressWrapper> addressReturnList = new List<AddressWrapper>();
        
        try{
            List<schema.AssociatedLocation> newList = [SELECT Id, Type FROM AssociatedLocation 
                                                   		WHERE parentRecordId =: actId];
            
            
            Schema.Location l = new Schema.Location();
            l.name = street + '-Location';
            insert l;
            
            Schema.Address ad = new Schema.Address();
            ad.parentid = l.id;
            ad.street = street;
            ad.city = city;
            ad.state = province;
            ad.postalcode = postalcode;
            ad.country = country;
            ad.County__c = county;
            ad.locationtype = 'Business Site';
            insert ad;
            
            l.VisitorAddressId = ad.id;
            update l;
            
            AssociatedLocation al = new AssociatedLocation();
            al.ParentRecordId = actId;
            if(newList.size()>0){
               al.type = 'Other'; 
            }else{
                al.type = 'Primary';
            }
            
            al.status__c = 'Active';
            al.LocationId = l.id;
            insert al;
            
            String fullAddress = ad.street +', '+ad.city +', '+ad.state +', '+ad.country +', '+ad.postalcode;
            
            AddressWrapper wrp = new AddressWrapper();
            wrp.address = fullAddress;
            wrp.type = al.type;
            wrp.ascId = al.Id;
            wrp.addresId = ad.id;
            wrp.locationId = l.id;
            wrp.status = al.Status__c;
            wrp.parentRecordId = al.ParentRecordId;
            wrp.associatedLocationNumber = al.AssociatedLocationNumber;
            
            addressReturnList.add(wrp);
            //locationId,status,parentRecordId,associatedLocationNumber
        }catch(Exception e){
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getCause());
            system.debug(e.getMessage());
        }
        return addressReturnList;
    }
    
    // to Check Duplicate Address it needs 2 params (street, postalCode)
    @AuraEnabled(cacheable=true)
    public static Boolean getDuplicateAddress(string street, string postalCode){
        Boolean checkDuplicate = false;
        Try{
            Integer addr = [SELECT count() FROM Address
                            WHERE Street =: street AND PostalCode =: postalCode];
            if(addr != 0){
                checkDuplicate = true;
            }else{
                checkDuplicate = false;
            }
            system.debug('checkDuplicate-- '+checkDuplicate);
            
        }Catch(Exception e){
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getCause());
            system.debug(e.getMessage());
        }
        return checkDuplicate;
    }
    
    public class AddressWrapper{
        @AuraEnabled
        Public string address{get;set;} // Full Address fron Addres obj
        @AuraEnabled
        Public string type{get;set;}// AssocaiteLocation Type
        @AuraEnabled
        Public string ascId{get;set;}// AssocaiteLocation Id
        @AuraEnabled
        Public string addresId{get;set;}// Address Id
        @AuraEnabled
        Public string locationId{get;set;} // Location Id 
        @AuraEnabled
        Public string status{get;set;}// Status__c
        @AuraEnabled
        Public string parentRecordId{get;set;}// Account Id
        @AuraEnabled
        Public string associatedLocationNumber{get;set;}// Associated Location Number
        @AuraEnabled
        Public string Location{get;set;}// Associated Location Number
    }
    
    
    // Type Change
    @AuraEnabled
    public static void changeAssociatedLocation(Id orgPrLocId,Id newPrLocId, Id accId){
        List<schema.AssociatedLocation> oldList = [SELECT Id, Type FROM AssociatedLocation 
                                                   WHERE parentRecordId =: accId AND Id =:orgPrLocId];
        
        List<schema.AssociatedLocation> newList = [SELECT Id, Type FROM AssociatedLocation 
                                                   WHERE parentRecordId =: accId AND Id =:newPrLocId];
        List<AssociatedLocation> updAssocLocList =  New List<AssociatedLocation>();
        
        Try{
            
            // Old Value
            if(oldList.size()>0){
                AssociatedLocation asl = new AssociatedLocation();
                For (AssociatedLocation updAssocLoc :oldList ){
                    asl.Type = 'Other';
                    asl.Id = updAssocLoc.Id;
                    updAssocLocList.add(asl);
                }
                //update asl;
            }
            
            
            // new Value
            if(newList.size()>0){
                AssociatedLocation asl = new AssociatedLocation();
                For (AssociatedLocation aslobj :newList ){
                    asl.Type = 'Primary';
                    asl.Id = aslobj.Id;
                    updAssocLocList.add(asl);
                }
                //update asl;
            }
            
            //system.debug(updAssocLocList.size()+' <--- update List size --> '+updAssocLocList);
            if(!updAssocLocList.isEmpty()){
                   upsert updAssocLocList;
            }
        }catch(Exception e){
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getCause());
            system.debug(e.getMessage());
        }
        
    }
    
    
    // 
    @AuraEnabled
    public static List<AddressWrapper> addAssociatedLocation2(String addressId, Id accountId){
        // First Check This Account comtains any Associated Location
        List<schema.AssociatedLocation> asLocList = [SELECT Id FROM AssociatedLocation 
                                                     WHERE ParentRecordId =: accountId];
        // if asLocList size 0 then Type is Primary else Other
        
        List<AddressWrapper> addressReturnList = new List<AddressWrapper>();

        List<schema.AssociatedLocation> AssocLocationList = new List<schema.AssociatedLocation>();
        try{
            if(addressId != null)
            {
                List<Schema.Address> AddrList = [Select ParentId from address Where id =: addressId];
                
                If(!AddrList.isEmpty()) {
                    For(Schema.address addr :AddrList) {  
                        schema.AssociatedLocation al = New schema.AssociatedLocation();
                        al.ParentRecordId = accountId;
                        //al.status__c = 'Active';
                        if(asLocList.size() == 0){
                            al.Type = 'Primary';
                        }else{
                            al.Type = 'Other';
                        }
                        al.LocationId = addr.ParentId;
                        AssocLocationList.add(al);
                        
                        
                    }
                    If(!AssocLocationList.isEmpty()) {
                        Database.SaveResult[] insertSaveResult = Database.insert(AssocLocationList, false);
                        List <schema.AssociatedLocation> aslList = [SELECT id,Address__c,type,LocationId,Status__c,ParentRecordId,AssociatedLocationNumber,visitorId__c,Location.Name FROM AssociatedLocation WHERE Id =: AssocLocationList[0].Id ];
                        
                        for(schema.AssociatedLocation asl : aslList){
                            AddressWrapper wrp = new AddressWrapper();
                            wrp.address = asl.Address__c;
                            wrp.type = asl.type;
                            wrp.ascId = asl.Id;
                            wrp.addresId = asl.visitorId__c;
                            wrp.locationId = asl.LocationId;
                            wrp.status = asl.Status__c;
                            wrp.parentRecordId = asl.ParentRecordId;
                            wrp.associatedLocationNumber = asl.AssociatedLocationNumber;
                            wrp.Location = asl.Location.Name;
                            
                            
                            addressReturnList.add(wrp);
                        }
                    }
                }
            }
            
        }catch(Exception e){
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getCause());
            system.debug(e.getMessage());
        }
        system.debug(addressReturnList.size()+' addressReturnList--> '+addressReturnList);
        return addressReturnList;
    }
       
}