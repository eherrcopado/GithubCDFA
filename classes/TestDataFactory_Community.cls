/*
    Class		: 	TestDataFactory_Community
    Objective	: 	Provides Test Data to the Test Classes
    Developer	: 	
*/ 

@isTest
public class TestDataFactory_Community {
    
    
    public static User createTestUserRec(String prflNm,String usrNm, String contactId){    
        
        Id p = [select id from profile where name=: prflNm ].id;
        User usr = new User(alias = 'test123',contactId = contactId, email = usrNm, username =usrNm, emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', profileid = p, country='United States',IsActive =true, timezonesidkey='America/Los_Angeles');
        return usr;
    }
    
    
    public static Contact createContactTestRec(String fName, String lName, String eml,String actId){
        Contact cnt = new Contact(FirstName=fName,LastName=lName,email=eml,AccountId=actId);
        return cnt;
    }
    
    public static Account createAccountTestRec(String act_nm,String recType){
        Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recType).getRecordTypeId();
        Account act = new Account(name = act_nm,RecordTypeId = accountRecordTypeId) ;
        return act;
    }
    
       public static Account createAccountTestRec2(String act_nm,String recType){
        Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recType).getRecordTypeId();
        Account act = new Account(name = act_nm,RecordTypeId = accountRecordTypeId,Registration_Number__c='12345433',
                                        Status__c='Active',Legal_Entity__c='Corporation') ;
        return act;
    }
    //======================= testAccountRecord By Srihari ======Start====//
        public static Account createAccountTestRecord(String act_nm,String recType,string RenewalProcess){
            Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recType).getRecordTypeId();
            Account accRec = new Account(name = act_nm,RecordTypeId = accountRecordTypeId,Renewal_Process__c = RenewalProcess) ;
            return accRec;
        }
    //=======================End==========//
    
    
    public static Messaging.InboundEmail createEmailWithAttachMntTestRec(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Create Contact';
        email.fromAddress = 'someaddress@email.com';
        email.plainTextBody = 'email body';
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            return email;
    }
    
    public Static Schema.Location getLocationTestRec(){
        Schema.Location lc = new Schema.Location();
        lc.name ='test lc';
        lc.LocationType='Business Site';
        return lc;
    }
    
    public static Asset createAssetTestRec(String actId, String contId){
        Asset ast = new Asset(Name='Test Asset',AccountId=actId, ContactId=contId);
        return ast;
    }
    
    
    public static Schema.AssociatedLocation getAscLationTestRec(Id acId, Id lcId){
        Schema.AssociatedLocation asl = new Schema.AssociatedLocation();
        asl.Type ='Primary';
        asl.ParentRecordId = acId;
        asl.LocationId =  lcId;
        asl.Status__c='Active';
        return asl;
    }
    
    public static Schema.Location updateLocationTestRec(String lcId, String addrId){
        Schema.Location lc = new Schema.Location();
        lc.Id = lcId;
        lc.VisitorAddressId = addrId;
        return lc;
    }
    
    public static Schema.Address getAddessRec(Id lcId){
        Schema.Address ad = new Schema.Address();
            ad.parentid = lcId;
            ad.street = '99 S Parker Ave';
            ad.city = 'Rochester';
            ad.state = 'New York';
            ad.postalcode = '14623';
            ad.country = 'USA';
            ad.locationtype = 'Business Site';
        
        return ad;
    }
    
    public static AccountContactRelation getAccConRelTestRec(Id accId, Id conId){
        
        AccountContactRelation acrRec = new AccountContactRelation();       
        acrRec.AccountId=accId;
        acrRec.ContactId=conId;
        acrRec.Agent_Name__c='Test Agent1';
        acrRec.Status__c='Active';
        //acrRec.IsDirect = false;
        return acrRec;
    }
    
    public static RegulatoryAuthorizationType getRegAuthType(){
        RegulatoryAuthorizationType raType = new RegulatoryAuthorizationType();
        raType.Name = 'Test raType';
        raType.RegulatoryAuthCategory = 'License';
        return raType;
    }
    
    public static BusinessLicense getBusnLicTestRec(Id acId, Id conId, Id rAuthTypId){
        BusinessLicense bl = new BusinessLicense(); 
        bl.Name = 'Test BL';
        bl.RegulatoryAuthorizationTypeId = rAuthTypId;
        bl.PeriodStart = system.today()-1;
        bl.PeriodEnd = system.today();
        bl.AccountId = acId;
        bl.ContactId = conId;
        bl.status = 'Active';
        return bl;
    }
    
    public static BusinessLicenseApplication getBusnLicAppTestRec(Id actId, Id cntId, Id regAuthId){
        BusinessLicenseApplication blApll = new BusinessLicenseApplication();
        blApll.AppliedDate = system.now();
        blApll.AccountId = actId;
        blApll.ApplicantId = cntId;
        blApll.LicenseTypeId = regAuthId;
        blApll.Category = 'License';
        blApll.Status = 'Submitted';
        return blApll;
    }
    
    public Static RegulatoryTrxnFee getRegTranFeeTestRec(Id actId,Id renAccId,Id blId){
        RegulatoryTrxnFee rtf = new RegulatoryTrxnFee();
        //rtf.RegulatoryTrxnFeeId=rtfId;
        //rtf_itm1.FeeAmount=100;
        rtf.ParentRecordId=blId;
        rtf.Status = 'Due';
        rtf.AccountId=actId;
        rtf.Renewal_Account_Id__c= renAccId; 
        
        return rtf;  
    }
    
    //RSAL Trigger related Only
    public Static RegulatoryTrxnFee getRegTranFeeTestRec1(Id actId,Id renAccId,Id blId){
        RegulatoryTrxnFee rtf1 = new RegulatoryTrxnFee();
        //rtf1.RegulatoryTrxnFeeId=rtfId;
        //rtf_itm1.FeeAmount=100;
        rtf1.ParentRecordId=blId;
        //rtf1.Status = 'Due';
        rtf1.AccountId=NULL;
        rtf1.Renewal_Account_Id__c= renAccId; 
        
        return rtf1;  
    }
    
    public Static List<RegulatoryTrxnFeeItem> getRegItemsTestRecs(Id rtfId){
        List<RegulatoryTrxnFeeItem> rtfItemList = new List<RegulatoryTrxnFeeItem>();
        for(integer i=0;i<5;i++){
            RegulatoryTrxnFeeItem rtf_itm1 = new RegulatoryTrxnFeeItem();
            rtf_itm1.Name='RegulatoryTrxnFeeItem';
            rtf_itm1.RegulatoryTrxnFeeId=rtfId;
            rtf_itm1.FeeAmount=100;
            if(i>2){
                rtf_itm1.Status__c = 'Paid';
            }
            else{
                rtf_itm1.Status__c = 'Due';
            }
            rtfItemList.add(rtf_itm1);
        }
        return rtfItemList;
    }

    //All paid Reg Trxn Items
    public Static List<RegulatoryTrxnFeeItem> getRegItemsTestRecsAllPaid(Id rtfId){
        List<RegulatoryTrxnFeeItem> rtfItemList = new List<RegulatoryTrxnFeeItem>();
        for(integer i=0;i<2;i++){
            RegulatoryTrxnFeeItem rtf_itm1 = new RegulatoryTrxnFeeItem();
            rtf_itm1.Name='RegulatoryTrxnFeeItem';
            rtf_itm1.RegulatoryTrxnFeeId=rtfId;
            rtf_itm1.FeeAmount=100;
            rtfItemList.add(rtf_itm1);
        }
        return rtfItemList;
    }
    
    
    
    public static List<Payment_Request__c>  getPaymentRequestTestRecs(ID actId, Id rtfId){
        List<Payment_Request__c> pRList = new List<Payment_Request__c>();
        for(integer i=0;i<5;i++){
            Payment_Request__c pr = new Payment_Request__c();
            pr.Account__c = actId;
            pr.Regulatory_Transaction_Fee__c = rtfId;
            pr.Status__c = 'Pending';
            pr.StartDate__c = system.today();
            pr.EndDate__c = system.today() + 2;
            pRList.add(pr);
        }
        return pRList;
    }
    
    public static List<Payment_Request__c>  getPaymentRequestTestRecs1(ID actId, Id rtfId){
        List<Payment_Request__c> pRList1 = new List<Payment_Request__c>();
        for(integer i=0;i<5;i++){
            Payment_Request__c pr = new Payment_Request__c();
            pr.Account__c = actId;
            pr.Regulatory_Transaction_Fee__c = rtfId;
            pr.Status__c = 'Completed';
            pr.StartDate__c = system.today();
            pr.EndDate__c = system.today() + 2;
            pRList1.add(pr);
        }
        return pRList1;
    }
    
    public static  List<PaymentRequestItems__c> getPaymentReqItemsTestRecs(Id acId, Id conId, Id prId){
        List<PaymentRequestItems__c> prItemList = new List<PaymentRequestItems__c>();
            for(integer i=0;i<5;i++){
                PaymentRequestItems__c prItem = new PaymentRequestItems__c();
                prItem.Account__c = acId;
                prItem.Agent__c = conId;
                prItem.Status__c = 'Pending';
                prItem.Payment_Request__c = prId;
                prItemList.add(prItem);
            }
        return prItemList;
    }
    
    
    public static List<Payment_Response__c> getParmentResTestRecs(Id prId){
        List<Payment_Response__c> pResList = new List<Payment_Response__c>();
            for(integer i=0;i<5;i++){
                Payment_Response__c  paymentResponse = new Payment_Response__c();
                paymentResponse.ReceiveDate__c = System.today();
                paymentResponse.ePay_Return_Code__c = 'Valic Code';
                paymentResponse.Total_Paid_Amount__c = 600;
                paymentResponse.Card_Type__c = 'Visa';
                paymentResponse.Payment_Request__c = prId;
                paymentResponse.Status__c = 'Pending';
                paymentResponse.ePay_Result_Message__c = 'Success';
                paymentResponse.Confirmation_Number__c = 200;
                paymentResponse.Settlement_Submission_Date__c = System.today();
                pResList.add(paymentResponse);
            }
        return pResList;
    }
    
    
    
     /*
     public static Lead createLeadTestRec(String lName, String cmp,String sts){
        Lead ld = new Lead(LastName=lName,company=cmp,status=sts);
        return ld;
    }
    
    
    public static PriceBook2 createTestPriceBook(String pbNm){
        Pricebook2 pb = new Pricebook2(Name = pbNm, Description = 'Price Book 2009 Products', IsActive = true);
        return pb;
    }
    
    
    public static Product2 createTestProduct(String prdtNm){
        Product2 prdct = new Product2( Name = prdtNm,  Family = 'Users', isActive = True); 
        return prdct;
    }
    

    public static Campaign createCampaignTestRec(String nm,String octId){
        Campaign cmp = new Campaign(Name=nm,status='In Progress',StartDate=System.today(),EndDate=System.today().addDays(16),Octopus_Campaign_ID__c = octId,isActive=TRUE);
        return cmp;
    }
    
    public Static CampaignMember createCampaignMemberTestRec(String cmpId,String cntctId){
        CampaignMember cmpM = new CampaignMember(campaignId =cmpId, Contactid=cntctId );
        return cmpM;
    }
    
    public Static Task createTaskTestRec(String whoId,String watId,String subj,String stsus,String ownrId,String prirty){
        Task tsk = new Task(WhoId=whoId, WhatId = watId, Subject = subj, Status = stsus, OwnerId = ownrId,Priority = prirty );
        return tsk;
    }
    
    
    public Static Opportunity createOpportunityTestRec(String accId,String recTypeId,String pbId,String stag){
        Opportunity opp=new Opportunity();        
        opp.name='12333';       
        opp.AccountId = accId;
        opp.stagename= stag;
        opp.Open_Date__c=date.ValueOf('2016-05-05');
        opp.CloseDate=date.ValueOf('2016-05-05');
        opp.Key_Issue_Date__c=date.ValueOf('2016-05-05');
        opp.Key_Expiration_Date_for_OppLayout__c=date.ValueOf('2017-05-04');
        opp.RecordTypeId= recTypeId;
        opp.priceBook2Id = pbId;
        opp.Term__c='3 Years';
        opp.Total_Users__c = 2;  
        opp.Subscription_All_Paid__c = false;
        opp.Opp_Lead_Year__c = '2021';
        opp.Opp_Lead_Source__c = 'Website';
        opp.Opp_Sub_Lead_Source__c = 'Web Sales';
        return opp;
    }
    */
    
    public static List<Contact> createContactsTestRec(String accId, Integer nofCons){
        Id contactRecordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('RSAAgent').getRecordTypeId();
        List<Contact>testConList = new List<Contact>();
       for(integer i=0; i<nofCons; i++){
                Contact con = new Contact();
                con.Email='abc@xyz.com'+i;
                con.LastName ='testCon'+i;
                con.AccountId = accId;
                con.RecordTypeId = contactRecordTypeId;
                testConList.add(con);
            }
        return testConList;
    }
    
    public static List<Contact> createRenewalContactsTestRec(String renAccId, Integer nofCons){
        Id contactRecordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('RSAAgent').getRecordTypeId();
        List<Contact>testRenewalConList = new List<Contact>();
       for(integer i=0; i<nofCons; i++){
                Contact con = new Contact();
                con.Email='abcrenewal@xyz.com'+i;
                con.LastName ='testCon renewal'+i;
                con.AccountId = renAccId;
           		con.status__c='Active';
                con.RecordTypeId = contactRecordTypeId;
                testRenewalConList.add(con);
            }
        return testRenewalConList;
    }
    
    public static List<Account> createBulkAccountTestRecs(String act_nm,String recType, Integer noOfRecs){
        List<Account>testAccList = new List<Account>();
        Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recType).getRecordTypeId();
        for(integer k=0; k<noOfRecs; k++){
            Account act = new Account();
            act.name = act_nm+k;
            act.RecordTypeId = accountRecordTypeId;
            act.Registration_Number__c='12345433';
            act.Status__c='Active';
            act.Legal_Entity__c='Corporation';
            testAccList.add(act);
        }
        return testAccList;
    }
    
    public static List<AccountContactRelation>createBulkACRRecords(String accountId,List<Contact> conList){
        List<AccountContactRelation> acrRecsList = New List<AccountContactRelation>();
        for(Contact con : conList){
            AccountContactRelation acrRec = new AccountContactRelation();
            acrRec.AccountId=accountId;
            acrRec.ContactId=con.Id;
            acrRec.Agent_Name__c=con.Name;
            acrRec.Status__c='Active';
            acrRec.initiated_by__c = 'Agent';
            acrRecsList.add(acrRec);
        }
        return acrRecsList;
    }
    
    public Static List<Schema.Location> getBulkLocationTestRec(Integer noofRecs){
        List<Schema.Location> bulkLocationList= New List<Schema.Location>();
        for(integer k=0; k<noOfRecs; k++){
            Schema.Location lc = new Schema.Location();
            lc.name ='test lc '+k;
            lc.LocationType='Business Site';
            bulkLocationList.add(lc);
        }
        return bulkLocationList;
    }
    
    public static List<Schema.Address> getBulkAddessRec(List<Schema.Location> bulkLocationList){
        List<Schema.Address> bulkAddressList= New List<Schema.Address>();
        for(Schema.Location locRec : bulkLocationList){
            Schema.Address ad = new Schema.Address();
            ad.parentid = locRec.Id;
            ad.street = '99 S Parker Ave '+locRec.Name;
            ad.city = 'Rochester';
            ad.state = 'New York';
            ad.postalcode = '14623';
            ad.country = 'USA';
            ad.locationtype = 'Business Site';
            bulkAddressList.add(ad);
        }
        return bulkAddressList;
    }
    
    public static List<Schema.AssociatedLocation> getBulkAscLationTestRec(Id acId,List<Schema.Location> bulkLocationList){
        List<Schema.AssociatedLocation> bulkAssociatedLocationList= New List<Schema.AssociatedLocation>();
        for(Schema.Location locRec : bulkLocationList){
            Schema.AssociatedLocation asl = new Schema.AssociatedLocation();
            asl.Type ='Primary';
            asl.ParentRecordId = acId;
            asl.LocationId =  locRec.Id;
            asl.Status__c='Active';
            bulkAssociatedLocationList.add(asl);
        }
        return bulkAssociatedLocationList;
    }
    
}