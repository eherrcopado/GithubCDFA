public without sharing class RSAAlTriggerHandler {
    
    public static void beforeInsertRSAAl(List<AssociatedLocation>asoLocNewList){

    }
    public static void beforeDeleteRSAAl(List<AssociatedLocation>asoLocOldList,Map<Id,AssociatedLocation>asoLocOldMap){
        
    }
    public static void afterInsertRSAAl(List<AssociatedLocation>asoLocNewList,Map<Id,AssociatedLocation>asoLocNewMap){
        Try{
            
            String AccRecordType;
            String Original_Account_Id;
            String Altype;
            String recType;
            String RenewalStatus;
            ID  locId;
			AssociatedLocation alRecord= new AssociatedLocation();
            
                
            Set<Id>ParentRecordIdSet = New Set<Id>();
            Set<Id>locationIdSet = New Set<Id>();
            for(AssociatedLocation alRec:asoLocNewList){
                ParentRecordIdSet.add(alRec.ParentRecordId);
                locationIdSet.add(alRec.locationid);
                alRecord = alRec;
            }
            
            
            List<Account>accList = [select recordtype.Name, Renewal_Process__c,Registration_Type__c FROM Account where id IN: ParentRecordIdSet limit 1];
            if(!accList.isEmpty()){
                recType = accList[0].recordtype.Name;
                RenewalStatus = accList[0].Renewal_Process__c;
                system.debug('recType=>'+recType+'==RenewalStatus=>'+RenewalStatus);
            }
            
            if(recType == 'RSA' && (RenewalStatus == 'Completed' || RenewalStatus == null)&& accList[0].Registration_Type__c!='New' && alRecord.locationFromAppRecordTypeCreated__c==False){
                system.debug('Inside RSA Account in trigger==>'+ParentRecordIdSet+'  recType==>'+recType);
                //BusinessLicense bl = [select id from BusinessLicense where accountid IN:ParentRecordIdSet and status = 'Active'];                    
                BusinessLicense bl = [select id from BusinessLicense where accountid IN:ParentRecordIdSet order by periodEnd desc LIMIT 1];
                list<RegulatoryTrxnFee> lstRtf = [select id from RegulatoryTrxnFee where accountid IN:ParentRecordIdSet and (status = 'Due' or status = 'Partially Paid') LIMIT 1];
                 
                // Rxn Fee Part
                string ParentRecordIdValue = null;
                for (string setElement : ParentRecordIdSet) {
                    ParentRecordIdValue = setElement;
                    break;
                }
                
                id rtfid;
                if (lstRtf.size() == 0) {
                    RegulatoryTrxnFee newRtf = new RegulatoryTrxnFee();
                    newRtf.accountid = ParentRecordIdValue;
                    newRtf.ParentRecordId = bl.id;
                    newRtf.payment_status__c = 'Due';
                    newRtf.DueDate = system.now();
                    newRtf.DueDate = newRtf.DueDate.addDays(60);
                    newRtf.status = 'Due';
                    //newRtf.Renewal_Account_Id__c= ;
                    insert newRtf;
                    rtfid = newRtf.id;
                } else {
                    rtfid = lstRtf[0].id;
                } // Txn Fee End
                
                // TXN fee Item start
                RegulatoryTrxnFeeItem newRtfi = new RegulatoryTrxnFeeItem();
                newRtfi.RegulatoryTrxnFeeId = rtfid;
                Schema.Location locname = [select name from location where id IN: locationIdSet limit 1];
                newRtfi.name = 'New Location - ' + locname.name;
                newRtfi.FeeAmount = 100;  
                newrtfi.referenceId__c = alRecord.Id; // to add AL Id 
                newRtfi.status__c = 'Due';
                insert newRtfi;
                // TXN fee Item End   
                
            }
        }Catch(Exception e){
            system.debug('Type-->> '+ e.getTypeName());
            system.debug('Line Number-->> '+e.getLineNumber());
            system.debug('Cause-->> '+e.getCause());
            system.debug('Message-->> '+e.getMessage());
        }
    }
    public static void afterUpdateRSAAl(List<AssociatedLocation>asoLocNewList,Map<Id,AssociatedLocation>asoLocNewMap,List<AssociatedLocation>asoLocOldList,Map<Id,AssociatedLocation>asoLocOldMap){
        
    }
    public static void afterDeleteRSAAl(List<AssociatedLocation>asoLocOldList,Map<Id,AssociatedLocation>asoLocOldMap){
        
    }
}