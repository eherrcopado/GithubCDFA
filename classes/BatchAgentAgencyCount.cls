global class BatchAgentAgencyCount implements Database.Batchable<sObject>,Database.stateful {
    public Map<String,Integer> acrMap = New Map<String,Integer>();
    public Map<String,Integer> acrMap2 = New Map<String,Integer>();
    Map<Id,Account>accountNewMap = New Map<Id,Account>();
    Map<Id,contact>contactNewMap = New Map<Id,contact>();
    List<contact>newUpdateList = New List<contact>();
    List<Account>AccountList = New List<Account>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        String condition = 'Contact.recordtype.name=\'RSAAgent\' And Contact.status__c=\'Active\' AND (status__c=\'Active\' OR Account.name=\'Agents\')';
        
        String query = 'SELECT id,contactId,status__C,Account.name,contact.relatedAccountsCount__c,AccountId,relatedAccountsCount__c FROM AccountContactRelation';
        query=query+ ' WHERE '+condition;                                             
        system.debug('query===> '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<AccountContactRelation> allActiveAgents) {
        // process each batch of records
        try{
            // relatedAccountsCount__c Count Update on AccountContactRelation Object Start
            Integer count;
            For(AccountContactRelation acr2 : allActiveAgents){
                if(acrMap.containsKey(acr2.contactId)){
                    count = acrMap.get(acr2.contactId);
                    count++;
                    acrMap.put(acr2.contactId, count);
                    count = 0;
                }else{
                    acrMap.put(acr2.contactId, 1);
                }
            }
            
            For(AccountContactRelation acr3 : allActiveAgents){
                contact con = new contact();
                con.Id = acr3.contactId;
                con.relatedAccountsCount__c= acrMap.get(acr3.contactId);
                //newUpdateList.add(con);
                contactNewMap.put(con.Id,con);
                //AccountContactRelation acr = new AccountContactRelation();
                //acr.Id = acr3.Id;
                //acr.relatedAccountsCount__c = acrMap.get(acr3.contactId);
                //newUpdateList.add(acr);
            }
            // relatedAccountsCount__c Count Update on AccountContactRelation Object End
            
            // Start of Account Agents__c Update
            Integer count2;
            For(AccountContactRelation acr2 : allActiveAgents){
                if(acrMap2.containsKey(acr2.AccountId)){
                    count2 = acrMap2.get(acr2.AccountId);
                    count2++;
                    acrMap2.put(acr2.AccountId, count2);
                    count2 = 0;
                }else{
                    acrMap2.put(acr2.AccountId, 1);
                }
            }
            
            For(AccountContactRelation acr3 : allActiveAgents){
                
                Account acc = new Account();
                acc.Id = acr3.AccountId;
                acc.agents__C  = acrMap2.get(acr3.AccountId);
                accountNewMap.put(acc.Id,acc);
            }
            
            newUpdateList=contactNewMap.values();
            if(!newUpdateList.isEmpty()){
                Update newUpdateList;
            }
            
            AccountList = accountNewMap.values();
            if(!AccountList.isEmpty()){
                Update AccountList;
            }
            
        }catch(Exception e){
            system.debug(e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
}