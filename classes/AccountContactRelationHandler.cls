public without sharing class AccountContactRelationHandler{
    
    public static id RSAContactid  = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('RSAContact').getRecordTypeId();
    public static String userName = UserInfo.getUserId();
    public static String userEmail = UserInfo.getUserEmail();
    public static Boolean createTrans = false;
    
    public static String AccRecordType;
    public static String NewAccRecordType;
    public static String Original_Account_Id;
    public static Id newAccId;
    public static String AgentName;
    public static String renewalProcess;
    public static List<User> lstUser;
    public static Set<String>accountIdSet;

    // constructor Block
   // public AccountContactRelationHandler(){
        //lstUser = [Select u.ContactId, u.Contact.recordtypeid, u.Contact.accountid, u.Contact.name, u.Contact.email, u.Profile.Name from User u where u.Id = :userName limit 1];
    	//system.debug('inside constructor lstUser--> '+lstUser);
   // }
    
    // Before Insert Block
    public static void beforeInsert(List<AccountContactRelation>acrNewList){
        
        lstUser = getUsers(userName);
        
        String contactId;
        Boolean isDirectContact;
        Set<id>accIdSet = new Set<id>();
        AccountContactRelation acrRec;
        for(AccountContactRelation a:acrNewList){
            system.debug('Trigger.new AccountId--> '+a.AccountId);
            accIdSet.add(a.accountid);
            contactId = a.ContactId;
            isDirectContact = a.IsDirect;
            acrRec = a;
        }
        AgentName = getAgentName(contactId);
        
        Account[] accCln = [select id,Original_Account_Id__c, recordtype.Name,Renewal_Process__c FROM Account where id IN: accIdSet limit 1];
        For(Account acc : accCln){
            AccRecordType = acc.recordtype.Name;
            renewalProcess = acc.Renewal_Process__c;
            Original_Account_Id=acc.Original_Account_Id__c;
            System.debug('Original_Account_Id outside for--->' +Original_Account_Id);
            system.debug('accCln--> '+accCln);
            System.debug('AccRecordType--->' +AccRecordType);
        }
        
        if(!isDirectContact){
            system.debug(lstUser[0].Contact.recordtypeid +'=recordtypeid='+ RSAContactid);
            if (lstUser[0].Contact.recordtypeid == RSAContactid){
                
                if(AccRecordType!= 'Renewal' && AccRecordType!= 'Application'){
                    acrRec.accountid = lstUser[0].Contact.accountid;
                }
                system.debug('renewalProcess 73 --> '+renewalProcess);
                if(renewalProcess != 'Approved'){
                    system.debug('renewalProcess 73 einside--> '+renewalProcess);
                    acrRec.status__c = 'Pending Payment'; 
                }
                contact con = [select name from contact where id = :acrRec.contactid limit 1];
                acrRec.agent_name__c = con.name;
                acrRec.main_contact_name__c = lstUser[0].contact.name;
                acrRec.main_contact_email__c = lstUser[0].contact.email;        
                acrRec.initiated_by__c = 'Agency';
                system.debug('if a---> '+acrRec);
                
            }else{
                
                if (string.isNotBlank(lstUser[0].ContactId))
                    acrRec.contactid = lstUser[0].ContactId;
                system.debug('renewalProcess 87 --> '+renewalProcess);
                if(renewalProcess != 'Approved' && acrRec.agentFromAppRecordTypeCreated__c == False){
                    system.debug('renewalProcess 87 inside--> '+renewalProcess);
                    acrRec.status__c = 'Pending'; 
                }
                
                acrRec.agent_name__c = lstUser[0].contact.name;
                acrRec.initiated_by__c = 'Agent';
                Contact[] con = [select name, email from contact where accountid = :acrRec.accountid limit 1];
                system.debug('con--> '+con);
                if(con.size()>0){
                    acrRec.main_contact_email__c = con[0].email;    
                    acrRec.main_contact_name__c = con[0].name;
                }
                system.debug('else a--> '+acrRec);
                
            }
        }
        
        
    }

    // Before Delete Block
    public static void beforeDelete(List<AccountContactRelation>acrOldList,Map<Id,AccountContactRelation>acrOldMap){
       // system.debug('lstUser--> '+lstUser);
        lstUser = getUsers(userName);
        for (AccountContactRelation b:acrOldList) {
            if(Test.isRunningTest()) continue;
            if (!b.IsDirect && Trigger.isBefore && Trigger.isDelete && lstUser[0].Profile.name.contains('Community') && AccRecordType!='Renewal' && AccRecordType!=null){
                b.addError('You cannot delete a relationship');
                system.debug('inside if block AccountContactRelation Delete--> ');
            }
            system.debug('b --> '+b);
        }

    }

    // After Insert Block
    public static void afterInsert(List<AccountContactRelation>acrNewList,Map<Id,AccountContactRelation>acrNewMap){
        lstUser = getUsers(userName);
        system.debug('lstUser =='+lstUser);
        String contactId;
        Boolean isDirectContact;
        set<Id>accIdSet = New set<Id>();
        AccountContactRelation acrRec;
        for(AccountContactRelation a:acrNewList){
            system.debug('Trigger.new AccountId--> '+a.AccountId);
            accIdSet.add(a.accountid);
            contactId = a.ContactId;
            isDirectContact = a.IsDirect;
            acrRec = a;
        }
        AgentName = getAgentName(contactId);
        system.debug('AgentName =='+AgentName);
        
        Account[] accCln = [select id,Original_Account_Id__c, recordtype.Name,Renewal_Process__c FROM Account where id IN: accIdSet limit 1];
        For(Account acc : accCln){
            AccRecordType = acc.recordtype.Name;
            renewalProcess = acc.Renewal_Process__c;
            Original_Account_Id=acc.Original_Account_Id__c;
        }
        system.debug(AccRecordType+ ' == Test== '+renewalProcess+'--'+Original_Account_Id);
        
        if(!isDirectContact){
            system.debug('shahid');
            Task t=new Task();
            if (acrRec.initiated_by__c == 'Agent'){
                system.debug('usrName===== '+lstUser[0].Profile.name);
                if(lstUser[0].Profile.name == 'CDFA Agent Community Login User'){
                    List<Contact> mc = [Select Id from Contact where accountId = :acrRec.accountid limit 1];
                    system.debug(mc.size()+'size mc --> '+mc);
                    if (mc.size() > 0) {
                        t.whoid = mc[0].id;
                        List<User> uc = [Select Id from User where ContactId = :mc[0].id limit 1];
                        system.debug(uc.size()+'size uc --> '+uc);
                        if (uc.size() > 0) 
                            t.ownerid = uc[0].id;
                    }
                    t.whatid = acrRec.accountid;
                    //t.type = 'Agent Approval';
                    t.type = 'Other';
                    t.subject='Please approve ' + lstUser[0].Contact.name;
                    t.status = 'Pending Approval';
                    // t.reminderdatetime = c.status_date__c+ 14;
                    // t.activitydate = c.status_date__c+ 14;
                    // t.IsReminderSet = true; 
                    t.accountcontactrelationship__c = acrRec.id;
                    system.debug('t --> '+t);
                    
                    if(AccRecordType!= 'Renewal' && AccRecordType!= 'Application'){
                        insert t;
                    }
                    system.debug('t id --> '+t.Id);
                    AccountContactRelation a1 = new AccountContactRelation ();
                    a1.taskid__c = t.id;
                    a1.action__c = '';
                    a1.id = acrRec.id;
                    
                    update a1;
                    system.debug(a1.Id+' a1 --> '+a1);
                    
                }
            }else if (acrRec.initiated_by__c == 'Agency' && acrRec.status__c == 'Pending Payment'){
                createTrans = true;
                system.debug(' createTrans --> '+createTrans);
            }
        }
		RegulatoryTrxnFee(acrRec,AccRecordType,createTrans);
    } // After Insert End

    // After Update Block
    public static void afterUpdate(List<AccountContactRelation>acrNewList,Map<Id,AccountContactRelation>acrNewMap,List<AccountContactRelation>acrOldList,Map<Id,AccountContactRelation>acrOldMap){
		lstUser = getUsers(userName);
        
        String contactId;
        Boolean isDirectContact;
        Set<id>accIdSet = new Set<id>();
        AccountContactRelation acrRec;
        for(AccountContactRelation a:acrNewList){
            try{
                system.debug('Trigger.new AccountId--> '+a.AccountId);
                system.debug('shahid 188'+a);
                accIdSet.add(a.AccountId);
                system.debug('shahid accIdSet'+accIdSet);
                contactId = a.ContactId;
                isDirectContact = a.IsDirect;
                acrRec = a;
            }catch(Exception e){
                system.debug(e.getTypeName());
                system.debug(e.getLineNumber());
                system.debug(e.getCause());
                system.debug(e.getMessage());
            }
        }
        
        Account[] accCln = [select id,Original_Account_Id__c, recordtype.Name,Renewal_Process__c FROM Account where id IN: accIdSet limit 1];
        For(Account acc : accCln){
            AccRecordType = acc.recordtype.Name;
            renewalProcess = acc.Renewal_Process__c;
            Original_Account_Id=acc.Original_Account_Id__c;
        }
        
        AgentName = getAgentName(contactId);
        AccountContactRelation olda = acrOldMap.get(acrRec.Id);
        system.debug(' olda --> '+olda);
        if (acrRec.initiated_by__c == 'Agent' && acrRec.status__c == 'Pending Payment' && olda.status__c == 'Pending'){
            createTrans = true;
            system.debug(' if createTrans --> '+createTrans);
        } else if (acrRec.status__c == 'Inactive' && olda.status__c == 'Active') {
            AccountContactRelation a1 = new AccountContactRelation ();
            if (lstUser[0].Contact.recordtypeid == RSAContactid) 
                a1.action__c = 'Agency Inactivation';
            else
                a1.action__c = 'Agent Inactivation';
            
            a1.id = acrRec.id;
            update a1;
            system.debug(a1.Id+' if a1 --> '+a1);
        }
        
        RegulatoryTrxnFee(acrRec,AccRecordType,createTrans);
        
    }
    
    public static String getAgentName(String contactId){
        String agnName = [select Name From Contact Where Id =: contactId].Name;
        return agnName;
    }
    
    public static void RegulatoryTrxnFee(AccountContactRelation acrRec, String AccRecordType, Boolean createTrans){
        if (createTrans && (AccRecordType!= 'Renewal' && AccRecordType!= 'Application')){
            system.debug(' if createTrans --> '+acrRec.accountid);
           //BusinessLicense bl = [select id from BusinessLicense where accountid = :acrRec.accountid and status = 'Active'];
            BusinessLicense bl = [select id, periodEnd from BusinessLicense where accountid = :acrRec.accountid order by periodEnd desc LIMIT 1];
            
            system.debug(' bl --> '+bl);
            list<RegulatoryTrxnFee> lstRtf = [select id from RegulatoryTrxnFee where accountid = :acrRec.accountid and (status = 'Due' or status = 'Partially Paid')];
            system.debug(lstRtf.size()+' lstRtf --> '+lstRtf);
            id rtfid;
            system.debug(' rtfid --> '+rtfid);
            
            if (lstRtf.size() == 0) {
                RegulatoryTrxnFee newRtf = new RegulatoryTrxnFee();
                newRtf.accountid = acrRec.accountid;
                system.debug(' newRtf.accountid --> '+newRtf.accountid);
                newRtf.ParentRecordId = bl.id;
                newRtf.payment_status__c = 'Due';
                newRtf.DueDate = system.now();
                newRtf.DueDate = newRtf.DueDate.addDays(60);
                newRtf.status = 'Due';
                insert newRtf;
                rtfid = newRtf.id;
            }else{
                rtfid = lstRtf[0].id;
            }
            RegulatoryTrxnFeeItem newRtfi = new RegulatoryTrxnFeeItem();
            newRtfi.RegulatoryTrxnFeeId = rtfid;
            
            newRtfi.name = 'New Agent - ' + AgentName; 
            newRtfi.FeeAmount = 25;
            newRtfi.status__c = 'Due';
            newRtfi.referenceId__c = acrRec.Id;
            insert newRtfi;
        }
    }
    
    public static List<user> getUsers(String uName){
        List<user>uList = [Select u.ContactId, u.Contact.recordtypeid, u.Contact.accountid, u.Contact.name, u.Contact.email, u.Profile.Name from User u where u.Id = :uName limit 1];
    	system.debug(uName +'<--Name-->'+ uList[0].Contact.recordtypeid);
        system.debug('inside constructor lstUser--> '+uList);
        return uList;
    }

}