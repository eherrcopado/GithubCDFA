public class ReconcileTriggerHandler{
    
    public static void beforeUpdateMethod(List<Account>accNewList,Map<Id,Account>accNewMap,List<Account>accOldList,Map<Id,Account>accOldMap){
        Try{
            for(Account acc : accNewMap.values()){
                if(accNewMap.get(acc.Id).Status__c =='InActive' && accOldMap.get(acc.Id).Status__c =='Active'){
                    acc.Cancel_Date__c = system.today();
                }
            }
        }catch(Exception e){
            system.debug('Type before update==> '+e.getTypeName());
            system.debug('Line before update==> '+e.getLineNumber());
            system.debug('Cause before update==> '+e.getCause());
            system.debug('Message before update==> '+e.getMessage());
        }
    }
    
    public static void approvalMethod(List<Account> accList){
        Try{
            Id RenewalRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
            Id applicationRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Application').getRecordTypeId();
            Id accRecTyprId;
            String AccountID;
            List<Account>updateAccountList = new List<Account>();
            Account accn;
            
            set<Id> accountIds = new set<Id>();
            
            For(Account Acc: accList){
               accountIds.add(acc.id);
            }
            
            
            Map<Id,account> mapAccs =new Map<Id,account>();
            For(Account Acc: accList){
                accn = acc;
                accRecTyprId = acc.RecordTypeId;
            }
            
            // Start of Renewal Condition
            // step 1
            if(( accn.RecordTypeId == RenewalRecordTypeID || accn.RecordTypeId ==applicationRecordTypeID ) && accn.Renewal_Process__c == 'Approved'){
                AccountID = String.valueOf(accn.id);
                
                if(accn.RecordTypeId == RenewalRecordTypeID){
                    Id OriginalAccountId = [select Id,Original_Account_Id__c from Account where Id = :accn.id limit 1].Original_Account_Id__c;
                    if(OriginalAccountId != NULL){
                        List<Account> renewalAccountList2 = [Select Renewal_Process__c, id from Account Where Id =: OriginalAccountId];
                        if(renewalAccountList2.size()>0){
                            renewalAccountList2[0].Renewal_Process__c = 'Approved';
                            update renewalAccountList2;
                        }
                    }
                    ReconcileAgency.Renew(AccountID);
                }else if(accn.RecordTypeId == applicationRecordTypeID){
                    NewRegistrationReconcileAgency.NewRegistration(AccountID);
                }
            }
            
            // step 2
            Try{
                if(accn.Renewal_Process__c == 'Pending Approval' && (accn.RecordTypeId == RenewalRecordTypeID || accn.RecordTypeId ==applicationRecordTypeID) ) {           
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    approvalRequest.setComments('Account Submitted for approval');
                    approvalRequest.setObjectId(accn.Id);
                    approvalRequest.setSubmitterId(accn.OwnerId); 
                    approvalRequest.setSkipEntryCriteria(true);
                    Approval.ProcessResult approvalResult = Approval.process(approvalRequest);
                }
            }catch(Exception e){
                system.debug('Type==> '+e.getTypeName());
                system.debug('Line==> '+e.getLineNumber());
                system.debug('Cause==> '+e.getCause());
                system.debug('Message==> '+e.getMessage());
            }
            
            // Renewal Reject step 3
            if(( accn.RecordTypeId == RenewalRecordTypeID || accn.RecordTypeId ==applicationRecordTypeID) && accn.Renewal_Process__c == 'Rejected'){
                Id RenewalRejectRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Renewal_Rejected').getRecordTypeId();
                Id applicationRejectedRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Application_Rejected').getRecordTypeId();
                
                Account ac = new Account();
                ac.id = accn.Id;
                if(accn.RecordTypeId == RenewalRecordTypeID){
                    ac.RecordTypeId = RenewalRejectRecordTypeID;
                    
                    Id OriginalAccountId = [select Id,Original_Account_Id__c from Account where Id = :accn.id limit 1].Original_Account_Id__c;
                    if(OriginalAccountId != NULL){
                        List<Account> renewalAccountList2 = [Select Renewal_Process__c, id from Account Where Id =: OriginalAccountId];
                        if(renewalAccountList2.size()>0){
                            renewalAccountList2[0].Renewal_Process__c = 'Rejected';
                            update renewalAccountList2;
                        }
                    }
                    
                }else if(accn.RecordTypeId ==applicationRecordTypeID){
                    ac.RecordTypeId = applicationRejectedRecordTypeID;
                }
                updateAccountList.add(ac);
                
                
            }
            if(!updateAccountList.isEmpty()){
                system.debug('Rejected 3');
                update updateAccountList;
            }
        }catch(Exception e){
            system.debug('Type==>approvalMethod '+e.getTypeName());
            system.debug('Line==>approvalMethod '+e.getLineNumber());
            system.debug('Cause==>approvalMethod '+e.getCause());
            system.debug('Message==>approvalMethod '+e.getMessage());
        }
    }
}