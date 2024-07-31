trigger RSAacr on AccountContactRelation (before insert, after insert, after update, before delete) {
    Triggers_Enable__mdt triggerisActive = Triggers_Enable__mdt.getInstance('RSAacr');   
    if(triggerisActive.Is_Active__c == TRUE){
        //added logic to update Agents count on Account
        if(trigger.isBefore){ 
            System.debug('Inside before Trigger');
            List<AccountContactRelation> conList = trigger.new;
            if(trigger.isInsert){
                //contactTriggerHandler.updateStartEndDateOnInsert(conList);            
            }
            if(trigger.isupdate){
                for(AccountContactRelation con:conList){
                    AccountContactRelation acrRec = Trigger.oldMap.get(con.Id);
                   // contactTriggerHandler.updateStartEndDateOnUpdate(con, acrRec); 
                } 
            }
        }
        if(trigger.isAfter){
            if(trigger.isInsert){
                system.debug('is After');
                //contactTriggerHandler.onContactInsert(trigger.new);
            }
            if(trigger.isDelete){
                system.debug('is delete');
                //contactTriggerHandler.onContactdelete(trigger.old);
            }
            if(trigger.isUpdate){
                system.debug('is update');
                //contactTriggerHandler.onContactUpdate(trigger.new);
            }
        }
        //logic to update Agents count ends here
        
        //comment for updating all account contact relation records
        id RSAContactid  = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('RSAContact').getRecordTypeId();
        String userName = UserInfo.getUserId();
        String userEmail = UserInfo.getUserEmail();
        Boolean createTrans = false;
        //system.debug('RSAContactid--> '+RSAContactid);
        //system.debug('userName--> '+userName);
        //system.debug('userEmail--> '+userEmail);
        //system.debug('createTrans--> '+createTrans);
        //system.debug('Trigger.new--> '+Trigger.new);
        String AccRecordType;
        String NewAccRecordType;
        String Original_Account_Id;
        Id newAccId;
        String AgentName;
        String renewalProcess;
        
        
        if (Trigger.IsInsert && (Trigger.isBefore || Trigger.isAfter)){
            for(AccountContactRelation a:Trigger.new){
                system.debug('Trigger.new AccountId--> '+a.AccountId);
                Account[] accCln = [select id,Name,Original_Account_Id__c, recordtype.Name,Renewal_Process__c FROM Account where id = :a.accountid limit 1];
                For(Account acc : accCln){
                    AccRecordType = acc.recordtype.Name;
                    renewalProcess = acc.Renewal_Process__c;
                    Original_Account_Id=acc.Original_Account_Id__c;
                    System.debug('Original_Account_Id in for--->' +Original_Account_Id);
                }
                System.debug('Original_Account_Id outside for--->' +Original_Account_Id);
                system.debug('accCln--> '+accCln);
                System.debug('AccRecordType--->' +AccRecordType);
            }
        }
        
        List<User> lstUser = [Select u.ContactId, u.Contact.recordtypeid, u.Contact.accountid, u.Contact.name, u.Contact.email, u.Profile.Name from User u where u.Id = :userName limit 1];
        system.debug('lstUser--> '+lstUser);
        if (Trigger.isBefore && Trigger.isDelete) {
            system.debug('Trigger.isBefore && Trigger.isDelete --> ');
            
            for (AccountContactRelation b:Trigger.old) {
                
                if(Test.isRunningTest()) continue;
                if (!b.IsDirect && Trigger.isBefore && Trigger.isDelete && lstUser[0].Profile.name.contains('Community') && AccRecordType!='Renewal' && AccRecordType!=null){
                    b.addError('You cannot delete a relationship');
                    system.debug('inside if block AccountContactRelation Delete--> ');
                }
                system.debug('b --> '+b);
                
            }
        } 
        
        else {
            for (AccountContactRelation a:Trigger.new) {
                system.debug('for Trigger.new--> ');
                
                AgentName = [select Name From Contact Where Id=: a.ContactId].Name;
                if(Test.isRunningTest()) continue; 
                
                if (!a.IsDirect && Trigger.isBefore && Trigger.isInsert) {
                    
                    if (lstUser[0].Contact.recordtypeid == RSAContactid) {
                        if(AccRecordType!= 'Renewal' && AccRecordType!= 'Application'){
                            a.accountid = lstUser[0].Contact.accountid;
                        }
                        
                        //else{
                        //newAccId=lstUser[0].Contact.accountid;
                        //system.debug('newAccId==>'+newAccId);
                        //}
                        //for(Account acRenewal: [select id,Original_Account_Id__c, recordtype.Name FROM Account where id = : newAccId limit 1 ]){
                        //Original_Account_Id=acRenewal.Original_Account_Id__c;
                        //}
                        
                        
                        // if(AccRecordType!= 'Renewal')
                        system.debug('renewalProcess 73 --> '+renewalProcess);
                        if(renewalProcess != 'Approved'){
                            system.debug('renewalProcess 73 einside--> '+renewalProcess);
                            a.status__c = 'Pending Payment'; 
                        }
                        contact con = [select name from contact where id = :a.contactid limit 1];
                        a.agent_name__c = con.name;
                        a.main_contact_name__c = lstUser[0].contact.name;
                        a.main_contact_email__c = lstUser[0].contact.email;  
                        a.initiated_by__c = 'Agency';
                        
                        system.debug('if a--> '+a);
                    } else {
                        if (string.isNotBlank(lstUser[0].ContactId))
                            a.contactid = lstUser[0].ContactId;
                        system.debug('renewalProcess 87 --> '+renewalProcess);
                        if(renewalProcess != 'Approved'){
                            system.debug('renewalProcess 87 inside--> '+renewalProcess);
                            a.status__c = 'Pending'; 
                        }
                        
                        a.agent_name__c = lstUser[0].contact.name;
                        a.initiated_by__c = 'Agent';
                        Contact[] con = [select name, email from contact where accountid = :a.accountid limit 1];
                        system.debug('con--> '+con);
                        if(con.size()>0){
                            a.main_contact_email__c = con[0].email;    
                            a.main_contact_name__c = con[0].name;
                        }
                        system.debug('else a--> '+a);
                    } 
                    
                }
                else if (!a.IsDirect && Trigger.isAfter ) {
                    system.debug('Trigger.isAfter--> ');
                    if (trigger.isInsert) {   
                        
                        Task t=new Task();
                        if (a.initiated_by__c == 'Agent' && Trigger.isInsert) {
                            if(lstUser[0].Profile.name == 'CDFA Agent Community Login User'){
                                List<Contact> mc = [Select Id from Contact where accountId = :a.accountid limit 1];
                                system.debug(mc.size()+'size mc --> '+mc);
                                if (mc.size() > 0) {
                                    t.whoid = mc[0].id;
                                    List<User> uc = [Select Id from User where ContactId = :mc[0].id limit 1];
                                    system.debug(uc.size()+'size uc --> '+uc);
                                    if (uc.size() > 0) 
                                        t.ownerid = uc[0].id;
                                }
                                //t.recordtypeid = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Approval').getRecordTypeId();
                                
                                t.whatid = a.accountid;
                                //t.type = 'Agent Approval';
                                t.type = 'Other';
                                t.subject='Please approve ' + lstUser[0].Contact.name;
                                t.status = 'Pending Approval';
                                
                                
                                // t.reminderdatetime = c.status_date__c+ 14;
                                // t.activitydate = c.status_date__c+ 14;
                                // t.IsReminderSet = true;         
                                
                                t.accountcontactrelationship__c = a.id;
                                system.debug('t --> '+t);
                                
                                
                                if(AccRecordType!= 'Renewal' && AccRecordType!= 'Application'){
                                    insert t;
                                }
                                system.debug('t id --> '+t.Id);
                                AccountContactRelation a1 = new AccountContactRelation ();
                                a1.taskid__c = t.id;
                                a1.action__c = '';
                                a1.id = a.id;
                                
                                update a1;
                                system.debug(a1.Id+' a1 --> '+a1);
                            }
                            
                            
                        } else if (a.initiated_by__c == 'Agency' && a.status__c == 'Pending Payment'){
                            createTrans = true;
                            system.debug(' createTrans --> '+createTrans);
                        }
                        
                        
                    }   else {  
                        AccountContactRelation olda = Trigger.oldMap.get(a.ID);
                        system.debug(' olda --> '+olda);
                        if (a.initiated_by__c == 'Agent' && a.status__c == 'Pending Payment' && olda.status__c == 'Pending'){
                            createTrans = true;
                            system.debug(' if createTrans --> '+createTrans);
                        }
                        
                        else if (a.status__c == 'Inactive' && olda.status__c == 'Active') {
                            AccountContactRelation a1 = new AccountContactRelation ();
                            if (lstUser[0].Contact.recordtypeid == RSAContactid) 
                                a1.action__c = 'Agency Inactivation';
                            else
                                a1.action__c = 'Agent Inactivation';
                            
                            a1.id = a.id;
                            update a1;
                            system.debug(a1.Id+' if a1 --> '+a1);
                        }
                    }
                    
                    
                    
                    system.debug(' if createTrans --> '+createTrans);
                    System.debug('AccRecordType----->'+AccRecordType);
                    
                    if (createTrans && (AccRecordType!= 'Renewal' && AccRecordType!= 'Application')) { 
                        system.debug(' if createTrans --> '+a.accountid);
                        BusinessLicense bl = [select id from BusinessLicense where accountid = :a.accountid and status = 'Active'];
                        //Id bl = '0cEBZ000000ADGH2A4';
                        system.debug(' bl --> '+bl);
                        list<RegulatoryTrxnFee> lstRtf = [select id from RegulatoryTrxnFee where accountid = :a.accountid and (status = 'Due' or status = 'Partially Paid')];
                        system.debug(lstRtf.size()+' lstRtf --> '+lstRtf);
                        id rtfid;
                        system.debug(' rtfid --> '+rtfid);
                        if (lstRtf.size() == 0) {
                            RegulatoryTrxnFee newRtf = new RegulatoryTrxnFee();
                            newRtf.accountid = a.accountid;
                            system.debug(' newRtf.accountid --> '+newRtf.accountid);
                            newRtf.ParentRecordId = bl.id;//bl.id;
                            system.debug(' newRtf.ParentRecordId --> '+newRtf.ParentRecordId);
                            newRtf.payment_status__c = 'Due';
                            system.debug(' newRtf.payment_status__c --> '+newRtf.payment_status__c);
                            newRtf.DueDate = system.now();
                            system.debug(' newRtf.DueDate --> '+newRtf.DueDate);
                            newRtf.DueDate = newRtf.DueDate.addDays(60);
                            system.debug(' newRtf.DueDate --> '+newRtf.DueDate);
                            newRtf.status = 'Due';
                            system.debug(' newRtf.status --> '+newRtf.status);
                            insert newRtf;
                            system.debug(' newRtf --> '+newRtf.Id);
                            rtfid = newRtf.id;
                            system.debug(' rtfid dml --> '+rtfid);
                        } else
                            rtfid = lstRtf[0].id;
                        
                        RegulatoryTrxnFeeItem newRtfi = new RegulatoryTrxnFeeItem();
                        newRtfi.RegulatoryTrxnFeeId = rtfid;
                        
                        newRtfi.name = 'New Agent - ' + AgentName; 
                        newRtfi.FeeAmount = 25;
                        newRtfi.status__c = 'Due';
                        insert newRtfi;
                    }   
                    
                    
                    
                }
            }      
            
        }
        //Comment ends here
    }
}