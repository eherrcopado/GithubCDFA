// Class to update StartDate EndDate on ACR and related Accounts count on contact and Agents count for Account after Insert
public class contactTriggerHandler {
    
    //to update ACR start date on insert if status is Active
    public static void beforeInsertMethodCTH(List<AccountContactRelation>asoLocNewList){
        for(AccountContactRelation con: asoLocNewList){
            if(con.Status__c=='Active'){
                con.StartDate = System.Today();
            }
        }
    }
    
    //to update ACR start date and End Date on update if status changed to Active/Inactive
    public static void beforeupdateMethodCTH(List<AccountContactRelation>acrNewList,Map<Id,AccountContactRelation>acrNewMap,List<AccountContactRelation>acrOldList,Map<Id,AccountContactRelation>acrOldMap){
        for(AccountContactRelation acr : acrNewMap.values()){
            if(acrOldMap.get(acr.Id).Status__c != acrNewMap.get(acr.Id).Status__c && acrNewMap.get(acr.Id).Status__c=='Active'){
                acr.StartDate = System.Today();
            }
            if(acrOldMap.get(acr.Id).Status__c != acrNewMap.get(acr.Id).Status__c && acrNewMap.get(acr.Id).Status__c=='Inactive'){
                acr.EndDate = System.Today();
            }
        }
    }
    
    //Update related Accounts count for contact and Agents count for Account after Insert
    public static void afterInsertMethodCTH(List<AccountContactRelation>asoLocNewList,Map<Id,AccountContactRelation>asoLocNewMap){
        system.debug('Inside==');
        //Contact Field Update  // relatedAccountsCount__c
        countUpdate(asoLocNewList, 'INSERT');// After Insert count update
    }
    
    //Update related Accounts count for contact and Agents count for Account after Update
    public static void afterUpdateMethodCTH(List<AccountContactRelation>asoLocNewList,Map<Id,AccountContactRelation>asoLocNewMap,List<AccountContactRelation>asoLocOldList,Map<Id,AccountContactRelation>asoLocOldMap){
        countUpdate(asoLocNewList,'UPDATE');// After update count Update
    }
    
    //Update related Accounts count for contact and Agents count for Account after Delete
    public static void afterDeleteMethodCTH(List<AccountContactRelation>asoLocOldList,Map<Id,AccountContactRelation>asoLocOldMap){
        countUpdate(asoLocOldList,'DELETE');
    }
    
    //Get and Update related Accounts count for contact and Agents count for Account
    public static void countUpdate(List<AccountContactRelation>asoLocNewList, String processType){
        try{
            List<AccountContactRelation> newUpdateList = New List<AccountContactRelation>();
            Set<Id>conIdSet = New Set<Id>();
            Set<Id>acnIdSet = New Set<Id>();
            Map<Id,Decimal> contactMap = New Map<Id,Decimal>();
            Map<Id,Decimal> accountMap = New Map<Id,Decimal>();
            system.debug(asoLocNewList.size()+'asoLocNewList size ==> '+asoLocNewList);
            For(AccountContactRelation acrRec : asoLocNewList){
                if(acrRec.Status__c == 'Active'){
                    conIdSet.add(acrRec.ContactId);
                    acnIdSet.add(acrRec.AccountId);
                }
            }
            system.debug(conIdSet+' Id Sets '+acnIdSet);
            List<Contact>conList = [Select Id,relatedAccountsCount__c FROM contact WHERE Id IN:conIdSet];
            for(Contact con:conList){
                if(con.relatedAccountsCount__c == null){
                    con.relatedAccountsCount__c = 0;
                }
                contactMap.put(con.Id, con.relatedAccountsCount__c);
                system.debug(con.Id +' == ConMap== '+con.relatedAccountsCount__c);
            }
            
            List<Account>acnList = [Select Id,agents__C FROM Account WHERE Id IN:acnIdSet];
            for(Account acn:acnList){
                if(acn.agents__C == null){
                    acn.agents__C = 0;
                }
                accountMap.put(acn.Id, acn.agents__C);
                system.debug(acn.Id +' == AcnMap== '+acn.agents__C);
            }
            
            List<Contact>updateContactList = New List<Contact>();
            List<Account>updateAccountList = New List<Account>();
            Decimal contactCount,accountCount;
            
            For(AccountContactRelation acrRec : asoLocNewList){
                // Contact Start
                if(acrRec.Status__c == 'Active'){
                    if(processType != 'DELETE'){
                        system.debug('Inside insert and update');
                        if(contactMap.containsKey(acrRec.ContactId)){
                            system.debug('value'+contactMap.get(acrRec.ContactId));
                            contactCount = contactMap.get(acrRec.ContactId);
                            contactCount++;
                        }else{
                            contactCount=1;
                            //contactMap.put(acrRec.ContactId, 1);
                        }
                    }else if(processType == 'DELETE'){
                        system.debug('Inside Delete');
                        if(contactMap.containsKey(acrRec.ContactId)){
                            contactCount = contactMap.get(acrRec.ContactId);
                            contactCount--;
                        }
                    } 
                    contact con = New Contact();
                    con.Id = acrRec.ContactId;
                    con.relatedAccountsCount__c=contactCount;//contactCountcontactMap.get(acrRec.ContactId);
                    updateContactList.add(con);
                }// Contact End
                
                if((acrRec.Status__c == 'Active') || (acrRec.Account.Name == 'Agents')){
                    // Account Start
                    if(processType != 'DELETE'){
                        system.debug('Inside insert and update Account');
                        if(accountMap.containsKey(acrRec.AccountId)){
                            accountCount = accountMap.get(acrRec.AccountId);
                            accountCount++;
                        }else{
                            accountCount=1;
                            //accountMap.put(acrRec.AccountId, 1);
                        }
                    }else if(processType == 'DELETE'){
                        system.debug('Inside Delete Account');
                        if(accountMap.containsKey(acrRec.AccountId)){
                            accountCount = accountMap.get(acrRec.AccountId);
                            accountCount--;
                        }
                    }
                    
                    Account acc = New Account();
                    acc.Id = acrRec.AccountId;
                    acc.agents__C = accountCount;//accountMap.get(acrRec.AccountId);
                    updateAccountList.add(acc);
                }
                
            }
            
            
            if(!updateContactList.isEmpty()){
                system.debug('updateContactList'+updateContactList.size());
                update updateContactList;
            }
            if(!updateAccountList.isEmpty()){
                system.debug('updateAccountList'+updateAccountList.size());
                update updateAccountList;
            }            
        }catch(Exception e){
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getCause());
            system.debug(e.getMessage());
        }
    }
}