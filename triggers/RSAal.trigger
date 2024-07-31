trigger RSAal on AssociatedLocation (before insert, after insert, After Update, After Delete, Before Delete) {
    Triggers_Enable__mdt triggerisActive = Triggers_Enable__mdt.getInstance('RSAal');
   //comment1 for updating all associated location
    if(triggerisActive.Is_Active__c == TRUE){
        String AccRecordType;
        String Original_Account_Id;
        String Altype;
        String recType;
        String RenewalStatus;
        
        ID  locId;
    
        //String userName = UserInfo.getUserId();
    
        if ((Trigger.IsInsert || Trigger.IsUpdate) && (Trigger.isBefore || Trigger.isAfter)){
             String ParentRecId ='';// shahid
            for(AssociatedLocation al:Trigger.new){
                ParentRecId = al.ParentRecordId;
            }
            Account[] accCln = [select id,Original_Account_Id__c, recordtype.Name FROM Account where id = :ParentRecId  limit 1];
                For(Account acc : accCln){
                    AccRecordType = acc.recordtype.Name; 
                    Original_Account_Id=acc.Original_Account_Id__c; 
                }
                system.debug('accCln--> '+accCln);
                System.debug('AccRecordType--->' +AccRecordType);
            
        } //comment1 ends here
        //trigger fire when Associated location record inserted 
        if(trigger.isInsert && trigger.isAfter){
            AccountAssociatedLocHandler.onCreateAccAssociatedLoc(trigger.new);
        }
                
        //trigger fire when Associated location record updated
        if(trigger.isUpdate && trigger.isAfter){   system.debug('inside if isAfter and update line 44');
            AccountAssociatedLocHandler.onUpdateAccAssociatedLoc(trigger.new);
        }
         //trigger fire when Associated location record deleted
        if(Trigger.isBefore && Trigger.isDelete){
            system.debug('on Delete trigger');
            AccountAssociatedLocHandler.onDeleteAccAssociatedLoc(trigger.old);
        }
    //comment2 for updating all associated location
        if(Trigger.isAfter && Trigger.isInsert){
            system.debug('inside if line 44');
            for(AssociatedLocation al2:Trigger.new){
                //Modified for Phase 2
                //String recType = [select recordtype.Name, Renewal_Process__c FROM Account where id = : al2.ParentRecordId limit 1].recordtype.Name; //Modified for Phase 2
                Account[] accRSA = [select recordtype.Name, Renewal_Process__c,Registration_Type__c FROM Account where id = : al2.ParentRecordId limit 1]; //Modified for Phase 2
                recType = accRSA[0].recordtype.Name;
                RenewalStatus = accRSA[0].Renewal_Process__c;
                system.debug('recType=>'+recType+'==RenewalStatus=>'+RenewalStatus);
                system.debug('Account ID in trigger==>'+al2.ParentRecordId);
                
                //List<User> lstUser = [Select u.Profile.Name from User u where u.Id = :userName limit 1];
                //system.debug('lstUser--> '+lstUser);
                //if(lstUser[0].Profile.name.contains('Community') && recType!='Renewal' && recType!=null){
                
                if(recType == 'RSA' && (RenewalStatus == 'Completed' || RenewalStatus == null)&& accRSA[0].Registration_Type__c!='New'){ //Modified for Phase 2 Till Here
               
                    system.debug('Inside RSA Account in trigger==>'+al2.ParentRecordId+'  recType==>'+recType);
                  
                    BusinessLicense bl = [select id from BusinessLicense where accountid = :al2.ParentRecordId and status = 'Active'];                    
                    
                    list<RegulatoryTrxnFee> lstRtf = [select id from RegulatoryTrxnFee where accountid = :al2.ParentRecordId and (status = 'Due' or status = 'Partially Paid')];
                    id rtfid;
                    if (lstRtf.size() == 0) {
                        RegulatoryTrxnFee newRtf = new RegulatoryTrxnFee();
                        newRtf.accountid = al2.ParentRecordId;
                        newRtf.ParentRecordId = bl.id;
                        newRtf.payment_status__c = 'Due';
                        newRtf.DueDate = system.now();
                        newRtf.DueDate = newRtf.DueDate.addDays(60);
                        newRtf.status = 'Due';
                        //newRtf.Renewal_Account_Id__c= ;
                        insert newRtf;
                        rtfid = newRtf.id;
                    
                    } else 
                        rtfid = lstRtf[0].id;
                    RegulatoryTrxnFeeItem newRtfi = new RegulatoryTrxnFeeItem();
                    newRtfi.RegulatoryTrxnFeeId = rtfid;
                    Schema.Location locname = [select name from location where id = :al2.locationid limit 1];
                    newRtfi.name = 'New Location - ' + locname.name;
                    newRtfi.FeeAmount = 100;  
                    
                    newRtfi.status__c = 'Due';
                    insert newRtfi;                
                }
               }
           
        }
   }
    // comment2 ends here
}