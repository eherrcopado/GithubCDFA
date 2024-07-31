public without sharing class FormESectionController {
    
    //update Agency 
    @auraenabled
    public static void updateAgencyApproval(List<string> wrapperText, String accId, String renAccID, String sType) //TOBECHANGED
    {
        Id agencyId;
        Boolean firstChBx = false, secondChBx = false, thirdfChBx = false;
        String sSignture, renewAccId;
        
        //List<Agency_Renewal__c> arl = [select id from Agency_Renewal__c where Account__c =: accId];
        List<Agency_Renewal__c> arl = [select id from Agency_Renewal__c where Renewal_Account__c=:renAccID];
        if(arl.size()>0){
            agencyId = arl[0].Id;
        }else{
            Agency_Renewal__c ast=new Agency_Renewal__c();
            ast.Renewal_Account__c = renAccID;
            ast.Created_Date__c=DateTime.now();
            ast.Status__c = 'In Progress';
            insert ast;
            agencyId = ast.Id;
        }
        
        try{
            List<Agency_Renewal__c> astList = new List<Agency_Renewal__c>();
            if(sType == 'SIGNTURE'){
                sSignture = wrapperText[0];
                renewAccId = wrapperText[1];
            }else{
                for(String s : wrapperText){
                    if(s.containsIgnoreCase('My business owns the standards used by my Agency/Agents') ){
                        firstChBx = true;
                    }else if(s.containsIgnoreCase('My business uses certified standards owned by county weights')){
                        secondChBx = true;
                    }else if(s.containsIgnoreCase('My business uses certified standards owned by a third-party') ){
                        thirdfChBx = true;
                    }else{
                        system.debug('else block');
                    }
                }
            }
            
            try{
                List<Agency_Renewal__c> updaterenewalagency =  New List<Agency_Renewal__c>();
                For (Agency_Renewal__c AgencyRenewal : [Select Id, Status__c from Agency_Renewal__c Where Id =: agencyId]){
                    if(sType == 'SIGNTURE'){
                        AgencyRenewal.Signature__c = sSignture;
                        AgencyRenewal.Status__c = 'Payment Pending';
                        AgencyRenewal.Renewal_Account__c = renewAccId;
                    }else{
                        AgencyRenewal.Business_owns_the_standards_Agency__c = firstChBx;
                        AgencyRenewal.Business_uses_certified_standards_owned__c = secondChBx;
                        AgencyRenewal.Business_certified_standards_Third_Party__c = thirdfChBx;
                    }                   
                    updaterenewalagency.add(AgencyRenewal);
                    system.debug('Update the Renewal Agency Object 1 '+ AgencyRenewal);
                }
                update updaterenewalagency;
                system.debug(updaterenewalagency[0].Id +'updaterenewalagency '+ updaterenewalagency);
            }
            catch (Exception e) { 
                system.debug('Exception FormEController UpdateRenewalAgency' + e.getMessage());        
            }
            //--------------------------------------------------------------------
            
        }catch(Exception ex){
            system.debug('Line Number----> '+ex.getLineNumber());
            system.debug('Type----> '+ex.getTypeName());
            system.debug('Cause----> '+ex.getCause());
        }
    }
    // Get Agency Renewal rec
    @auraenabled
    public static List<wrapper> getAgencyRenewal(String accId, String renAccID){
        
        List<Agency_Renewal__c> garList = [SELECT id, Business_owns_the_standards_Agency__c, Business_uses_certified_standards_owned__c, Business_certified_standards_Third_Party__c 
                                           FROM Agency_Renewal__c 
                                           WHERE Renewal_Account__c =: renAccID];
        
        List<wrapper> wrpList = new List<wrapper>();
        for(Agency_Renewal__c ar: garList){
            wrapper wrp = new wrapper();
            if(ar.Business_owns_the_standards_Agency__c == true){
                wrp.Business_owns_the_standards_Agency = 'My business owns the standards used by my Agency/Agents';
            }if(ar.Business_uses_certified_standards_owned__c == true){
                wrp.Business_uses_certified_standards_owned = 'My business uses certified standards owned by county weights';
            }if(ar.Business_certified_standards_Third_Party__c == true){
                wrp.Business_certified_standards_Third_Party = 'My business uses certified standards owned by a third-party';
            }
            
            if(ar.Business_owns_the_standards_Agency__c == false){
                wrp.Business_owns_the_standards_Agency = '';
            }if(ar.Business_uses_certified_standards_owned__c == false){
                wrp.Business_uses_certified_standards_owned = '';
            }if(ar.Business_certified_standards_Third_Party__c == false){
                wrp.Business_certified_standards_Third_Party = '';
            }
            
            wrp.agencyRenewalId = ar.Id;
            wrpList.add(wrp);
        }
        system.debug('wrpList  Data   '+wrpList);
        return wrpList;
    }
    
    public class wrapper{
        @auraenabled
        public Id agencyRenewalId {set;get;}
        @auraenabled
        public String Business_owns_the_standards_Agency {set;get;}
        @auraenabled
        public String Business_uses_certified_standards_owned {set;get;}
        @auraenabled
        public String Business_certified_standards_Third_Party {set;get;}
    }
    // This Method used to update status value paid
    public static void updateStatusPaid(String accId, String paymentRequestId){
        
        String renAccId = RenewalAgencyController.getRenAccfromPmtReq(paymentRequestId);
        
        if (renAccId == null){
            renAccId = '123123123123123123';
        }
        try{
            List<Agency_Renewal__c> updaterenewalagency =  New List<Agency_Renewal__c>();
            For (Agency_Renewal__c AgencyRenewal : [Select id, status__c from Agency_Renewal__c Where Renewal_Account__c =: renAccId]){
                AgencyRenewal.Status__c = 'Paid';                                      
                updaterenewalagency.add(AgencyRenewal);
            }
            update updaterenewalagency;
        }
        catch (Exception e) { 
            system.debug('Exception FormEController UpdateRenewalAgency' + e.getMessage());        
        }
        //--------------------------------------------------------------------
    }
    
}