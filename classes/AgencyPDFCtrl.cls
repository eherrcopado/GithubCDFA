public without sharing class AgencyPDFCtrl {

    public Contact accRec{get;set;}
    public List<RegulatoryTrxnFee> regulatoryRec {get;set;}
    public List<BusinessLicense> businesssRec {get;set;}
    public List<AssociatedLocation> associatePrimaryType {get;set;}
    public List<AssociatedLocation> associateOtherTypes {get;set;}
    public Integer associateLocation{get;set;}
    public Integer associateLocPrim{get;set;}
    public List<AccountContactRelation> accountContactRecords {get;set;}
    public Integer contactRecordSize{get;set;}
    public String periodStart{get;set;}
    public String periodEnd{get;set;}
    public String totalFeeAmount{get;set;}
    public AgencyPDFCtrl() {
        
        User userRec = [select Id,  ContactId  from User where Id =: UserInfo.getUserId()];
        accRec = [Select Id,Name,Phone,AccountId,Account.AccountNumber,Account.Name,Account.DBA_Name__c,Account.BillingStreet, Account.BillingCity, Account.BillingState,
                    Account.BillingPostalCode from Contact where Id = :userRec.ContactId];
        system.debug('accRec--> '+accRec);
        Datetime dtPeriodStart;
        Datetime dtPeriodEnd;
        
        //the line below was found to be commented out as of 12/28/22 presumably by the creator. 
        //businesssRec =[select Id,PeriodStart, PeriodEnd from BusinessLicense where AccountId = :accRec.AccountId AND Status='Active' limit 1];
        businesssRec =[select Id,PeriodStart, PeriodEnd from BusinessLicense where AccountId = :accRec.AccountId order by periodEnd desc LIMIT 1];
        
        if(businesssRec.size() > 0) {
            dtPeriodStart = businesssRec[0].PeriodStart; 
            periodStart = dtPeriodStart.format('MM/dd/yyyy');
            dtPeriodEnd = businesssRec[0].PeriodEnd; 
            periodEnd = dtPeriodEnd.format('MM/dd/yyyy');  
        }
        
        Decimal amount=0;
        Decimal finalAmount = 0;
        //getting regulatory fee created on adding Associated Location/Agent from View Account Page
        List<RegulatoryTrxnFee> regRecList  = [SELECT Id,TotalFeeAmount,Paid_Amount__c FROM RegulatoryTrxnFee 
                                               where parentRecordId=:businesssRec[0].Id 
                                               AND (createddate >= :dtPeriodStart AND createddate <= :dtPeriodEnd) 
                                               AND Renewal_Account_Id__c=Null 
                                               AND (Status='Paid' OR Status = 'Partially Paid')];
        if(regRecList.size() > 0) {
            for(RegulatoryTrxnFee regf:regRecList){
                amount = amount + regf.Paid_Amount__c;
            }
        }
        finalAmount = Amount;   
        //regulatory created on making payment from new/renewal process
        regulatoryRec =[SELECT Id,TotalFeeAmount FROM RegulatoryTrxnFee 
                        WHERE AccountId = :accRec.AccountId AND Renewal_Account_Id__c != null Order BY createddate DESC LIMIT 1];
        if(regulatoryRec.size() > 0) {
            finalAmount = finalAmount + regulatoryRec[0].TotalFeeAmount;   
        }
        totalFeeAmount = '$'+finalAmount;
        system.debug('totalFeeAmount==>'+totalFeeAmount);
        
        associatePrimaryType = [select Id,Location.VisitorAddress.Street,Location.VisitorAddress.city,Location.VisitorAddress.State,Location.VisitorAddress.PostalCode  from AssociatedLocation where Type ='Primary' AND ParentRecordId = :accRec.AccountId limit 1];
        System.debug('Test1');
        associateOtherTypes = [select Id,Location.VisitorAddress.Street,Location.VisitorAddress.city,Location.VisitorAddress.State,Location.VisitorAddress.PostalCode  from AssociatedLocation where Type ='Other' AND ParentRecordId = :accRec.AccountId and status__c = 'Active'];
        System.debug('Test2');
        accountContactRecords = [select Id,Contact.FirstName,Contact.MiddleName, Contact.LastName, Contact.License_No__c,Contact.License_To_Date__c  from AccountContactRelation 
                                 where AccountId = :accRec.AccountId AND status__c = 'Active' AND IsDirect =false];
        system.debug('accountContactRecords size--> '+accountContactRecords.size());
        system.debug('accountContactRecords date--> '+accountContactRecords);
        associateLocPrim= Integer.valueOf(associatePrimaryType.size());
        associateLocation =Integer.valueOf(associateOtherTypes.size());
        System.debug('Test1'+associateLocation);
        contactRecordSize =Integer.valueOf(accountContactRecords.size());
    }
}