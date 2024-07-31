public Without Sharing class RegTranFeeItemCreation {
 @auraenabled
     Public static void createPenaltyRegFeeItem (String accId, Decimal penaltyFee) {
        //accId Renewal Account ID
        system.debug(accId+'<--accId  penaltyFee-->'+penaltyFee);
        Id rtfRecId; //

        list<RegulatoryTrxnFee> lstRtf = [select id from RegulatoryTrxnFee where accountid = :accId];
  		
        // Decimal Penalty = penaltyFee; 
        // Decimal scaledDecimal = Penalty.setScale(2);
        if(lstRtf.size()==0){
            RegulatoryTrxnFee newRtf = new RegulatoryTrxnFee();
            newRtf.accountid = accId;
            //newRtf.ParentRecordId = bl.id;
            newRtf.payment_status__c = 'Due';
            newRtf.DueDate = system.now();
            newRtf.DueDate = newRtf.DueDate.addDays(60);
            newRtf.status = 'Due';
            insert newRtf;
            rtfRecId=[select id from RegulatoryTrxnFee where accountid = :accId].Id;
        } 
        else{
             rtfRecId=lstRtf[0].Id;
        }
   
        List<RegulatoryTrxnFeeItem> rtiList= [SELECT Id FROM RegulatoryTrxnFeeItem where RegulatoryTrxnFeeId = :rtfRecId AND name = 'Penalty Fee'];
        if(rtiList.size()==0){
            RegulatoryTrxnFeeItem newRtfi = new RegulatoryTrxnFeeItem();
            newRtfi.RegulatoryTrxnFeeId = lstRtf[0].Id;
            newRtfi.name = 'Penalty Fee'; 
            newRtfi.FeeAmount = penaltyFee;
            newRtfi.status__c = 'Due';
            system.debug(newRtfi.FeeAmount+' <------newRtfi.PenaltyFeeAmount && status__c--> '+newRtfi.status__c);
            insert newRtfi;    
        }
        else{
            for(RegulatoryTrxnFeeItem rtfirec:rtiList){
                rtfirec.FeeAmount = penaltyFee;
            }
            update rtiList;
        }
  
    }

    
  
    Public static void createAgentRegFeeItem (Id RTFId, String AccName){
        Integer agentFeeAmt=25;
        //list<RegulatoryTrxnFee> lstRtf = [select id from RegulatoryTrxnFee where id = :RTFId];
       // List<RegulatoryTrxnFeeItem> rtiList= New List<RegulatoryTrxnFeeItem>();
         if(RTFId!= NULL){
        RegulatoryTrxnFeeItem newRtfi = new RegulatoryTrxnFeeItem();
        newRtfi.RegulatoryTrxnFeeId = RTFId;
        newRtfi.name = AccName; 
        newRtfi.FeeAmount = agentFeeAmt;
        newRtfi.status__c = 'Due';
        system.debug(newRtfi.FeeAmount+' <------newRtfi.AgentFeeAmount && status__c--> '+newRtfi.status__c);
        insert newRtfi;    
        }
         
    }
    Public static void createLocationRegFeeItem (Id RTFId, Id LocId, String Type){//, string renAccId
        
        System.debug('Inside createLocationRegFeeItem');
        Integer FeeAmount;
        String NewLocName;
        
        
        if(Type == 'Primary'){
          FeeAmount = 200;
        }
        Else {
            FeeAmount = 100;
        }
       // list<RegulatoryTrxnFee> lstRtf = [select id from RegulatoryTrxnFee where id = :RTFId];
        List<Schema.Location> Loclist = [Select name from Location Where id = :LocId];
        //Id assLocId= [Select Id from AssociatedLocation where ParentRecordId=:renAccId AND LocationId=:LocId].Id;
        For(Schema.Location Loc : Loclist){
            NewLocName = Loc.Name;
        }
      //  List<RegulatoryTrxnFeeItem> rtiList= [SELECT Id FROM RegulatoryTrxnFeeItem where RegulatoryTrxnFeeId = :lstRtf[0].Id];
        if(RTFId!= NULL){
        RegulatoryTrxnFeeItem newRtfi = new RegulatoryTrxnFeeItem();
        newRtfi.RegulatoryTrxnFeeId = RTFId;
        newRtfi.name = NewLocName; 
        newRtfi.FeeAmount = FeeAmount;
        newRtfi.status__c = 'Due';
        //newRtfi.Asso_Loc_Id__c= assLocId;
        system.debug(newRtfi.FeeAmount+' <------newRtfi.LocationFeeAmount && status__c--> '+newRtfi.status__c);
        insert newRtfi;    
        }        
       
  
    }
    /*
    public static void handleAsoLocInsDel(String acctId){//acctId is renewal account id
    List<AssociatedLocation> alList= [Select id from AssociatedLocation where ParentRecordId=:acctId];

    List<RegulatoryTrxnFeeItem> rtiList= [SELECT Id FROM RegulatoryTrxnFeeItem 
                                        where RegulatoryTrxnFeeId In 
                                        (select id from RegulatoryTrxnFee 
                                         where accountid =:acctId and 
                                         (status = 'Due' or status = 'Partially Paid')) ];
        
            List<RegulatoryTrxnFeeItem> rtiInsList = new List<RegulatoryTrxnFeeItem>();
        	List<RegulatoryTrxnFeeItem> rtiDelList = new List<RegulatoryTrxnFeeItem>();
        
			for(AssociatedLocation al:alList){
                for (RegulatoryTrxnFeeItem rti:rtiList){
                    if(al.Id!=rti.Asso_Loc_Id__c){
                        rtiInsList.add(rti);
                    }
                    else{
                        rtiDelList.add(rti);
                    }
                }
                
            }
        		system.debug('rtiInsList size=>'+rtiInsList.size());
                //insert rtiInsList;
                //delete rtiDelList;
           // List<Schema.Location> Loclist = [Select name from Location Where id = :LocId];
        }
*/
    
}