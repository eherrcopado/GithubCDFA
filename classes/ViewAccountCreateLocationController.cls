/* 
* @ Class Name: ViewAccountCreateLocationController
* @ Objective: This class is used for viewAccountCreateLocation[LWC] Controller.
* @ Developer: QualApps(130897)
* @ Test Class : ViewAccountCreateLocationController_Test
* @ Test Coverage : 95%
* @ Logs Modified By: 
*     User Name      |     Modified Date     |     Comments
* ---------------------------------------------------------------
* 	   130897               24/10/2022              Intial Creation
* 	   130897               24/10/2022              fetchDefaultRecord Method creation
* 	   130897               26/10/2022              createAssociatedLocation Method creation
* 	   130897               27/10/2022              getAllAddress Method creation
* 	   130897               27/10/2022              createAssociatedLocation Method Updation
* 	   130897               28/10/2022              getAssociatedLocationRecord Method creation
* 	   130897               28/10/2022              updateAssociatedLocation Method creation
* 	   130897               02/11/2022              getAccountRelatedAddress Method creation
* 	   130897               09/11/2022              createAssociatedLocation Method Edit for RSA and Renewal Related Creation
* 	   130897               09/11/2022              createRecord Method creation[This is the Generic Method for AsoLoc Record]
* 	   130897               10/11/2022              createAssociatedLocation Method Edit
* 	   130897               10/11/2022              createRecord Method Edit
*/

public without sharing class ViewAccountCreateLocationController {
    
    /* 
    * @ Method Name: fetchDefaultRecord
    * @ Description: This method is used to Display PreSelected Custom Account Lookup in viewAccountCreateLocation Comp.
    * @ Author: QualApps(130897)
    * @ Created Date: 24-10-2022
    * @ Parameters: 
    *       Name      |     Type
    * ------------------------------
    * 	 recordId         	String
    * @ Return: SObject
    */
    @AuraEnabled(cacheable=true)
    public static sObject fetchDefaultRecord(string recordId) {
        string sRecId = recordId;
        string sQuery = 'SELECT Id,Name FROM Account WHERE Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            System.debug('obj '+obj);
            return obj;
        }
        return null;
    }
    
    /* 
    * @ Method Name: createAssociatedLocation
    * @ Description: This method is used to insert Associated Location Record in Account Record [viewAccountCreateLocation Comp].
    * @ Author: QualApps(130897)
    * @ Created Date: 26-10-2022
    * @ Parameters: 
    *       Name      |     Type
    * ------------------------------
    * 	 AddressWrapper         Wrapper Class
    * @ Return: List<AddressWrapper>
    */
    @AuraEnabled
    public static List<AddressWrapper> createAssociatedLocation(AddressWrapper wrapper){
        system.debug(wrapper.locationName+'shahid'+wrapper);
        List<AddressWrapper> addressReturnList = new List<AddressWrapper>();
        Id RSAId=NULL,renewalId=NULL;
        Boolean createRenewalRecord = false;
        Try{
            List<AddressWrapper>rsaWrapper = createRecord(wrapper.parentRecordId, wrapper);
            addressReturnList.addAll(rsaWrapper);
            
            //RSAId = [SELECT Id FROM Account WHERE Id=:wrapper.parentRecordId AND Renewal_Process__c='Draft'].Id;
            Map<Id,Account> accnMap = New Map<Id,Account>([SELECT Id FROM Account WHERE Id=:wrapper.parentRecordId AND Renewal_Process__c='Draft' LIMIT 1]);
            system.debug('RSAId'+accnMap.size());
            if(accnMap.size() != 0){
                Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
                List<Account>acList = [SELECT Id FROM Account WHERE Original_Account_Id__c=:accnMap.keySet() AND recordTypeId=:accountRecordTypeId];
                if(!acList.isEmpty()){
                    renewalId = acList[0].Id;
                    createRenewalRecord = true;
                }
            }
            
            if(createRenewalRecord == true){
                List<AddressWrapper>renewalWrapper = createRecord(renewalId, wrapper);
                addressReturnList.addAll(renewalWrapper);
            }
            
        }Catch(Exception e){
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getCause());
            system.debug(e.getMessage());
        }
        system.debug('addressReturnList size '+addressReturnList.size());
        return addressReturnList;
    }
    
    /* 
    * @ Method Name: getAllAddress
    * @ Description: This method is used to Return All Addresses in the DB [viewAccountCreateLocation Comp].
    * @ Author: QualApps(130897)
    * @ Created Date: 27-10-2022
    * @ Parameters: 
    *       Name      |     Type
    * ------------------------------
    * 	 N/A
    * @ Return: List<sObject>
    */
    @AuraEnabled(cacheable=true)
    public static list<sObject> getAllAddress() {
        List<schema.address>addressList  = [SELECT ParentId, Street, City, State, PostalCode, Country FROM Address]; 
        return addressList;
    }
    
    /* 
    * @ Method Name: getAssociatedLocationRecord
    * @ Description: This method is used to get Specific Associated Location Record based on the Id.[viewAccountCreateLocation Comp].
    * @ Author: QualApps(130897)
    * @ Created Date: 28-10-2022
    * @ Parameters: 
    *       Name      				|     Type
    * -----------------------------------------
    * 	 getAssociatedLocationRecord	String
    * 	accountId						String
    * @ Return: AddressWrapper[Wrapper class object]
    */
    @AuraEnabled//(cacheable=true)
    public static AddressWrapper getAssociatedLocationRecord(String accountId, String associatedLocationId){
        system.debug(accountId +' inside shahid '+associatedLocationId);
        AddressWrapper wrapper = New AddressWrapper();
        Try{
            List<schema.AssociatedLocation>asoLocList = [SELECT Id,LocationId,Location.Name, Location.VisitorAddressId, Location.VisitorAddress.street,
                                                         Location.VisitorAddress.Id,Location.VisitorAddress.city,Location.VisitorAddress.state,
                                                         Location.VisitorAddress.postalcode,Location.VisitorAddress.country,Location.VisitorAddress.County__c
                                                         FROM AssociatedLocation 
                                                         WHERE  ParentRecordId =: accountId AND Id=: associatedLocationId LIMIT 1];
            system.debug('sb2-- '+asoLocList);
            
            if(!asoLocList.isEmpty()){
                for(schema.AssociatedLocation ad : asoLocList){
                    wrapper.ascId=ad.Id;
                    wrapper.locationName=ad.Location.Name;
                    wrapper.street=ad.Location.VisitorAddress.street;
                    wrapper.city=ad.Location.VisitorAddress.city;
                    wrapper.state=ad.Location.VisitorAddress.state;
                    wrapper.country=ad.Location.VisitorAddress.country;
                    wrapper.postalCode=ad.Location.VisitorAddress.postalcode;
                    wrapper.county=ad.Location.VisitorAddress.County__c;
                }
            }
        }Catch(Exception e){
            system.debug('Name ==> '+e.getTypeName());
            system.debug('Line ==> '+e.getLineNumber());
            system.debug('Cause ==> '+e.getCause());
            system.debug('Message ==> '+e.getMessage());
        }
        system.debug('wrapper '+wrapper);
        return wrapper;
    }
    
    /* 
    * @ Method Name: updateAssociatedLocation
    * @ Description: This method is used to Update Address,Location and Associated Location Record based on
    * 				 Associated Location Record ID [viewAccountCreateLocation Comp].
    * @ Author: QualApps(130897)
    * @ Created Date: 28-10-2022
    * @ Parameters: 
    *       Name      		|     Type
    * -----------------------------------------
    * 	 AddressWrapper			wrapper Class
    * @ Return: N/A
    */
    @AuraEnabled
    public static void updateAssociatedLocation(AddressWrapper wrapper){
        Try{
            schema.AssociatedLocation asLocRec = [SELECT LocationId,Location.VisitorAddressId
                                                  FROM AssociatedLocation 
                                                  WHERE  ParentRecordId =: wrapper.parentRecordId 
                                                  AND Id=: wrapper.ascId LIMIT 1];
            List<SObject>updateList = new List<SObject>();
            
            schema.location locRec = new schema.location();
            locRec.Name = wrapper.locationName;
            locRec.Id = asLocRec.LocationId;
            updateList.add(locRec);
            
            schema.Address adrRec = new schema.Address();
            adrRec.Id = asLocRec.Location.VisitorAddressId;
            adrRec.street = wrapper.street;
            adrRec.city = wrapper.city;
            adrRec.state = wrapper.state;
            adrRec.country = wrapper.country;
            adrRec.postalcode = wrapper.postalCode;
            adrRec.County__c = wrapper.county;
            updateList.add(adrRec);
            if(updateList != null){
                update updateList;
            }
        }Catch(Exception e){
            system.debug('Name ==> '+e.getTypeName());
            system.debug('Line ==> '+e.getLineNumber());
            system.debug('Cause ==> '+e.getCause());
            system.debug('Message ==> '+e.getMessage());
        }
    }  
    
    /* 
    * @ Method Name: getAccountRelatedAddress
    * @ Description: This method is used for Account Related AssociatedLocation Address Values to LWC.
    * @ Author: QualApps(130897)
    * @ Created Date: 02-11-2022
    * @ Parameters: 
    *       Name      |     Type
    * ------------------------------
    * 	 accountId         	String
    * @ Return: List<AddressWrapper>
    */
    @AuraEnabled
    public static List<AddressWrapper> getAccountRelatedAddress(String accountId) {
        List<AddressWrapper> AddressWrapperList = New List<AddressWrapper>();
        Try{
            List<schema.AssociatedLocation> allAddress = [SELECT Location.VisitorAddress.street,Location.VisitorAddress.city,
                                                          Location.VisitorAddress.state,Location.VisitorAddress.postalcode,
                                                          Location.VisitorAddress.country FROM AssociatedLocation 
                                                          WHERE ParentRecordId =: accountId];
            system.debug('allAddress '+allAddress.size());
            if(allAddress.size()>0){
                for(schema.AssociatedLocation ad : allAddress){
                    AddressWrapper wrapper= New AddressWrapper();
                    wrapper.street = ad.Location.VisitorAddress.street;
                    wrapper.city = ad.Location.VisitorAddress.city;
                    wrapper.state = ad.Location.VisitorAddress.state;
                    wrapper.postalCode = ad.Location.VisitorAddress.postalcode;
                    wrapper.country = ad.Location.VisitorAddress.country;
                    AddressWrapperList.add(wrapper);
                }
            }
        }Catch(Exception e){
            system.debug('Name ==> '+e.getTypeName());
            system.debug('Line ==> '+e.getLineNumber());
            system.debug('Cause ==> '+e.getCause());
            system.debug('Message ==> '+e.getMessage());
        }
        
        if(!AddressWrapperList.isEmpty()){
            system.debug('AddressWrapperList '+AddressWrapperList);
            return AddressWrapperList;
        }else{
            return NULL;
        }
    }
    
    /* 
    * @ Method Name: createRecord
    * @ Description: This method is used for creation of AssociatedLocations.
    * @ Author: QualApps(130897)
    * @ Created Date: 09-11-2022
    * @ Parameters: 
    *       Name      |     Type
    * ------------------------------
    * 	 accountId         	String
    * 	AddressWrapper 		wrapper
    * @ Return: List<AddressWrapper>
    */
    public static List<AddressWrapper> createRecord(String accountId, AddressWrapper wrapper){
        system.debug(wrapper.locationName+'shahid'+wrapper);
        List<AddressWrapper> addressReturnList = new List<AddressWrapper>();
        Try{
            Schema.Location l = new Schema.Location();
            l.name = wrapper.locationName;
            insert l;
            
            Schema.Address ad = new Schema.Address();
            ad.parentid = l.id;
            ad.street = wrapper.street;
            ad.city = wrapper.city;
            ad.state = wrapper.state;
            ad.postalcode = wrapper.postalcode;
            ad.country = wrapper.country;
            ad.County__c = wrapper.county;
            ad.locationtype = 'Business Site';
            insert ad;
            
            l.VisitorAddressId = ad.id;
            update l;
            
            AssociatedLocation al = new AssociatedLocation();
            al.ParentRecordId = accountId;
            al.type = wrapper.type;
            //al.status__c = 'Active';
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
        }Catch(Exception e){
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getCause());
            system.debug(e.getMessage());
        }
        return addressReturnList;
    }
    // End of Final Method
}