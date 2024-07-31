public without sharing class RegulatoryTxn {
    
    @AuraEnabled
    public static void CreatePaymentTxn(String RenewAgencyID, Decimal dPenaltyAmount, Decimal dPenaltyPercent){
        try{
            System.debug('Inside RegulatoryTxn.CreatePaymentTxn');
            String orgAgencyID = ReconcileAgency.CheckRenewAgency(RenewAgencyID);
            System.debug('orgAgencyID size'+ orgAgencyID.length());
            
            if (orgAgencyID == null){
                orgAgencyID = '';
            }
            
            if (orgAgencyID != '') {
                String sRegTxnId;
                sRegTxnId = CreateRegulatoryTxn(RenewAgencyID, orgAgencyID);
                System.debug('sRegTxnId size'+ sRegTxnId.length());
                if (sRegTxnId.length() > 0){
                    System.debug('sRegTxnId is null HELLO');
                    RemoveRegulatoryTxnLineItem(sRegTxnId);
                    CreateRegulatoryTxnLineItemLoction(sRegTxnId, RenewAgencyID, orgAgencyID); 
                    CreateRegulatoryTxnLineItemAgent(sRegTxnId, RenewAgencyID, orgAgencyID);  
                    CreateRegulatoryTxnLineItemPenalty(sRegTxnId, RenewAgencyID, orgAgencyID, dPenaltyAmount, dPenaltyPercent);
                } else {
                    System.debug('sRegTxnId is null');
                }
            }
        }catch (Exception e) { 
            system.debug('Exception RegulatoryTxn.CreatePaymentTxn' + e.getMessage());        
        }
    }
    
    @AuraEnabled
    public static String CreateRegulatoryTxn(String renewalAgencyID, String orgAgencyID){
        String sRegulatoryTxnID;
        try{
            //Id RenewalRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            //List<Account> renewalAccountList = new List<Account>([select Id,Name from Account where Original_Account_Id__c= :orgAgencyID AND RecordTypeID = :RenewalRecordTypeID limit 1]);   
            
            list<RegulatoryTrxnFee> lstRtf = [select id,Renewal_Account_Id__c from RegulatoryTrxnFee where accountid = :orgAgencyID and (status = 'Due' or status = 'Partially Paid')];
            
            System.debug('Inside RegulatoryTxn.CreateRegulatoryTxn=');
            
            sRegulatoryTxnID = RenewalAgencyController.getRegTxnFee(renewalAgencyID);
            System.debug('Existing ID '+ sRegulatoryTxnID);
            String busLicID = RenewalAgencyController.getBusLicenseID(orgAgencyID); 
            System.debug('busLicID ID '+ busLicID);
            
            if (sRegulatoryTxnID == null){
                sRegulatoryTxnID = '';
            }
            System.debug('InsidelstRtf.size() ==>'+lstRtf.size());
            System.debug('sRegulatoryTxnID ==>'+sRegulatoryTxnID);
           // List<RegulatoryTrxnFee> renewIdList = [select Id,Renewal_Account_Id__c from RegulatoryTrxnFee where accountid = :orgAgencyID];
            
            if(lstRtf.size() == 0  || (lstRtf.size()>0 && lstRtf[0].Renewal_Account_Id__c==null)){
                
                if (sRegulatoryTxnID == '') {
                    RegulatoryTrxnFee newRtf = new RegulatoryTrxnFee();
                    newRtf.accountid = orgAgencyID;
                    newRtf.ParentRecordId = busLicID;
                    newRtf.payment_status__c = 'Due';
                    newRtf.Renewal_Account_Id__c = renewalAgencyID;
                    newRtf.DueDate = system.now();
                    newRtf.DueDate = newRtf.DueDate.addDays(60);
                    newRtf.status = 'Due';
                    try{
                        insert newRtf;
                        sRegulatoryTxnID = newRtf.Id;
                        //rtfRecId=[select id from RegulatoryTrxnFee where accountid = :accId].Id;
                    }catch (Exception e){
                        sRegulatoryTxnID = '';
                        system.debug('Exception RegulatoryTxn.CreateRegulatoryTxn .. Error inserting RegulatoryTxn' + e.getMessage());
                    }   
                }
                        
            }/*
            else{
                if(lstRtf[0].Renewal_Account_Id__c==null || lstRtf[0].Renewal_Account_Id__c==''){
                    lstRtf[0].Renewal_Account_Id__c = renewalAgencyID;
					system.debug('after updating Renewal_Account_Id__c in RegTxn=>'+ lstRtf[0].Renewal_Account_Id__c);                    
                }               
                sRegulatoryTxnID = lstRtf[0].id;
            }*/
            
        }catch (Exception e) { 
            system.debug('Exception RegulatoryTxn.CreateRegulatoryTxn' + e.getMessage());        
        }
        return sRegulatoryTxnID;
    }
    
    @AuraEnabled
    public static void CreateRegulatoryTxnLineItemLoction(String sRegTxnId, String renewalAgencyID, String orgAgencyID){
        try{
            System.debug('Inside RegulatoryTxn.CreateRegulatoryTxnLineItemLoction');
            
            List<AssociatedLocation> lRenewData = new List<AssociatedLocation>();
            List<RegulatoryTrxnFeeItem> lRegTxnItem = new List<RegulatoryTrxnFeeItem>();
            
            String sFieldName = 'LocationId';
            lRenewData = RenewalAgencyController.getInitialData(renewalAgencyID, 'ACCLOCATION');
            System.debug('lRenewData list ' + lRenewData);
            for(AssociatedLocation sTemp : lRenewData){
                Decimal dFeeAmount;
                System.debug('sTemp.LocationID list ' + sTemp.LocationID);
                String sLocationID = sTemp.LocationID ; //'' get('LocationId');
                String sLocationName = sTemp.Location.Name; //get('Name');
                String sLocationType = sTemp.Type; //get('Type');
                if(sLocationType == 'Primary'){
                    dFeeAmount = 200;
                    sLocationName = 'Primary Location -'  + sLocationName;
                }
                Else {
                    dFeeAmount = 100;
                    sLocationName = 'New Location -' + sLocationName;
                }
                RegulatoryTrxnFeeItem oRegTxnItem = new RegulatoryTrxnFeeItem();
                oRegTxnItem.RegulatoryTrxnFeeId = sRegTxnId;
                oRegTxnItem.name = sLocationName; 
                oRegTxnItem.FeeAmount = dFeeAmount; //New Location - New Agent - 
                oRegTxnItem.status__c = 'Due';
                oRegTxnItem.Asso_Loc_Id__c = sLocationID;
                try{
                    //System.debug('oRegTxnItem list ' + oRegTxnItem);
                    insert oRegTxnItem;
                    lRegTxnItem.add(oRegTxnItem);
                } catch (Exception e) { 
                    system.debug('Exception oRegTxnItem' + e.getMessage());        
                }
                
                
                system.debug('RegulatoryTrxnFeeItem Location list size --- ' + lRegTxnItem.size());
                if(lRegTxnItem.size()>0){
                    System.debug('RegulatoryTrxnFeeItem list ' + lRegTxnItem);
                    try{
                        //insert lRegTxnItem; //Issue with bulkification
                    } catch (Exception e) { 
                        system.debug('Exception RegulatoryTxn.CreateRegulatoryTxnLineItemLoction' + e.getMessage());        
                    }
                }                
            }  
        }catch (Exception e) { 
            system.debug('Exception RegulatoryTxn.CreateRegulatoryTxnLineItemLoction' + e.getMessage());        
        }        
    }
    
    @AuraEnabled
    public static void CreateRegulatoryTxnLineItemAgent(String sRegTxnId, String renewalAgencyID, String orgAgencyID){
        try{
            System.debug('Inside RegulatoryTxn.CreateRegulatoryTxnLineItemAgent');
            
            List<AccountContactRelation> lRenewData = new List<AccountContactRelation>();
            List<RegulatoryTrxnFeeItem> lRegTxnItem = new List<RegulatoryTrxnFeeItem>();
            
            String sFieldName = 'LocationId';
            lRenewData = RenewalAgencyController.getInitialData(renewalAgencyID, 'ACCAGENT');
            for(AccountContactRelation sTemp : lRenewData){
                Decimal dFeeAmount;
                String sAgentID = sTemp.contactid;
                String sAgentName = sTemp.Contact.Name;
                dFeeAmount = 25;
                sAgentName = 'New Agent -'  + sAgentName;                
                
                RegulatoryTrxnFeeItem oRegTxnItem = new RegulatoryTrxnFeeItem();
                oRegTxnItem.RegulatoryTrxnFeeId = sRegTxnId;
                oRegTxnItem.Asso_Loc_Id__c = sAgentID;
                oRegTxnItem.name = sAgentName; 
                oRegTxnItem.FeeAmount = dFeeAmount; //New Location - New Agent - 
                oRegTxnItem.status__c = 'Due';
                lRegTxnItem.add(oRegTxnItem);
                
                try{
                    //System.debug('oRegTxnItem list ' + oRegTxnItem);
                    insert oRegTxnItem;
                    lRegTxnItem.add(oRegTxnItem);
                } catch (Exception e) { 
                    system.debug('Exception oRegTxnItem' + e.getMessage());        
                }
                
                system.debug('RegulatoryTrxnFeeItem Agent list size --- ' + lRegTxnItem.size());
                if(lRegTxnItem.size()>0){
                    System.debug('RegulatoryTrxnFeeItem list ' + lRegTxnItem);
                    //insert lRegTxnItem; 
                }                
            }  
        }catch (Exception e) { 
            system.debug('Exception RegulatoryTxn.CreateRegulatoryTxnLineItemAgent' + e.getMessage());        
        }        
    }
    
    @AuraEnabled
    public static void CreateRegulatoryTxnLineItemPenalty(String sRegTxnId, String renewalAgencyID, String orgAgencyID, Decimal dAmount, Decimal dPercent){
        try{
            System.debug('Inside RegulatoryTxn.CreateRegulatoryTxnLineItemPenalty');            
            if (dAmount>0) {    
                String sPenaltyName; 
                sPenaltyName = 'Penalty Fee -'  + dPercent + '%';              
                
                RegulatoryTrxnFeeItem oRegTxnItem = new RegulatoryTrxnFeeItem();
                oRegTxnItem.RegulatoryTrxnFeeId = sRegTxnId;            
                oRegTxnItem.name = sPenaltyName; 
                oRegTxnItem.FeeAmount = dAmount; //New Location - New Agent - 
                oRegTxnItem.status__c = 'Due';
                System.debug('RegulatoryTrxnFeeItem Penalty list ' + oRegTxnItem);
                insert oRegTxnItem;                            
            }
        }catch (Exception e) { 
            system.debug('Exception RegulatoryTxn.CreateRegulatoryTxnLineItemPenalty' + e.getMessage());        
        }        
    }
    
    @AuraEnabled
    public static void UpdatePaymentTxnDone(String RenewAgencyID){
        try{
            System.debug('Inside RegulatoryTxn.UpdatePaymentTxnDone');
            String sRegulatoryTxnID;
            
            sRegulatoryTxnID = RenewalAgencyController.getRegTxnFee(RenewAgencyID);
            System.debug('Existing sRegulatoryTxnID ID '+ sRegulatoryTxnID);
            
            if (sRegulatoryTxnID == null){
                sRegulatoryTxnID = '';
            }
            
            if (sRegulatoryTxnID != '') {
                UpdateRegulatoryTxnDone(sRegulatoryTxnID);
                UpdateRegulatoryTxnLineItemDone(sRegulatoryTxnID);
            }
            System.debug('Updated sRegulatoryTxn as Paid ID '+ sRegulatoryTxnID);
        }catch (Exception e) { 
            system.debug('Exception RegulatoryTxn.UpdatePaymentTxnDone' + e.getMessage());        
        }
    }
    
    @AuraEnabled
    public static void RemoveRegulatoryTxnLineItem(string RegTxnID){
        try{
            System.debug('Inside RegulatoryTxn.RemoveRegulatoryTxnLineItem');
            
            if (RegTxnID == null){
                RegTxnID = '';
            }
            
            if(RegTxnID!=''){
                system.debug('RegTxnID ' + RegTxnID); 
                List<RegulatoryTrxnFeeItem> lRegTxLnItem = new List<RegulatoryTrxnFeeItem>();
                system.debug('lRegTxLnItem ' + lRegTxLnItem);
                lRegTxLnItem = [Select ID FROM RegulatoryTrxnFeeitem where RegulatoryTrxnFeeId =: RegTxnID];
                delete lRegTxLnItem;
                system.debug('Success Remove '); 
            }
        }catch(Exception e){            
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getCause());
            system.debug(e.getMessage());
            system.debug('Exception ReconcilieAgency.RemoveRegulatoryTxnLineItem' + e.getMessage()); 
        }
    } 
    
    @AuraEnabled
    public static void UpdateRegulatoryTxnDone(string RegTxnID){
        try{
            System.debug('Inside RegulatoryTxn.UpdateRegulatoryTxnDone');
            
            if (RegTxnID == null){
                RegTxnID = '';
            }
            
            if(RegTxnID!=''){
                system.debug('RegTxnID ' + RegTxnID); 
                List<RegulatoryTrxnFee> lRegTx = new List<RegulatoryTrxnFee>();                
                for (RegulatoryTrxnFee oRegTx : [Select ID, Status FROM RegulatoryTrxnFee where Id =: RegTxnID]){
                    oRegTx.Status = 'Paid';
                    oRegTx.Paid_Date__c = system.today();
                    lRegTx.add(oRegTx);
                    System.debug('RegulatoryTrxnFee ' + oRegTx);
                }
                update lRegTx;              
            }
        }catch(Exception e){  
            system.debug('Exception ReconcilieAgency.UpdateRegulatoryTxnDone' + e.getMessage()); 
        }
    }    
    
    @AuraEnabled
    public static void UpdateRegulatoryTxnLineItemDone(string RegTxnID){
        try{
            System.debug('Inside RegulatoryTxn.UpdateRegulatoryTxnLineItemDone');
            if (RegTxnID == null){
                RegTxnID = '';
            }
            
            if(RegTxnID!=''){
                system.debug('RegTxnID ' + RegTxnID); 
                List<RegulatoryTrxnFeeItem> lRegTxLnItem = new List<RegulatoryTrxnFeeItem>();                
                for (RegulatoryTrxnFeeItem oRegTxLnItem : [SELECT id FROM RegulatoryTrxnFeeitem where RegulatoryTrxnFeeId =: RegTxnID]){
                    oRegTxLnItem.status__c = 'Paid';
                    lRegTxLnItem.add(oRegTxLnItem);
                    System.debug('RegulatoryTrxnFeeItem ' + oRegTxLnItem);
                }
                update lRegTxLnItem;                
            }
        }catch(Exception e){  
            system.debug('Exception ReconcilieAgency.UpdateRegulatoryTxnLineItemDone' + e.getMessage()); 
        }
    } 
}