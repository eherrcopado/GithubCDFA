public class NewRegistrationReconcileAgency  {
    @AuraEnabled
    public static void NewRegistration(string agencyId){
         
        system.debug('Shahid'+agencyId);
        String RSAacountId = createRSAAccount(agencyId); // RSA Account Creation
        system.debug('RSAacountId--> '+RSAacountId);
        updateUserContactAccount(agencyId, RSAacountId);
        String newBLRecId = createBusinessLiecense(agencyId,RSAacountId); //create Business Liesense 
        createAgents(agencyId, RSAacountId); // Agents Clone
        createAssociatedLocation(agencyId, RSAacountId); // Associated Location Clone
        createAssets(agencyId, RSAacountId); // Asset Clone
        createDocuments(agencyId, RSAacountId); // Documents Clone
        createRegulatoryTrxnFee(agencyId, RSAacountId,newBLRecId);
        createRegulatoryTrxnFeeItems(agencyId, RSAacountId);
        
        createPaymentRequest(agencyId, RSAacountId);
        createPaymentResponse(agencyId, RSAacountId);
    }
    //createRSAAccount Method for Creating New RSA Account after New Application Approved
    public static String createRSAAccount(String applicationAccountId){
        String newRSAId;
        Try{
            List<Account>RSAaccnList = New List<Account>();// RSA Complete Account List
            List<Account>aplnCmpAcnList = New List<Account>();// Application Complete Account List
            Id RSARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RSA').getRecordTypeId();
            Id applicationCompleteRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Application_Complete').getRecordTypeId();
            // Create New RSA Account
            List<Account> accountsList = [SELECT Id, Name,AccountNumber,DBA_Name__c,Legal_Entity__c,RecordTypeId,Active__c,Registration_Number__c,
                                          Renewal_Process__c,Parent_Account_Id__c,Original_Account_Id__c,
                                          BillingAddress,Phone,Email__c,BillingStreet,BillingCity, BillingState, BillingPostalCode,
                                          BillingCountry,OwnerId,Renewal_Registration_Number__c,Renewal_Registration__c                                           
                                          FROM Account WHERE Id =: applicationAccountId LIMIT 1];
            
            string regNumber;
            for (AggregateResult aggregate : [select max(Registration_Number__c) maxregno from account]){
                regNumber=String.valueOf(aggregate.get('maxregno'));
            }
            integer intRegNumber=Integer.valueOf(regnumber)+1;
            
            if(!accountsList.isEmpty()){
                for(Account ac : accountsList){
                    // Insert Process
                    Account rsaRec = New Account();
                    rsaRec.Name = ac.Name;
                    rsaRec.Status__c = 'Active';
                    rsaRec.RecordTypeID = RSARecordTypeId;
                    rsaRec.Active__c = ac.Active__c;
                    rsaRec.Renewal_Process__c = 'Completed';
                    //rsaRec.Renewal_Registration_Number__c = ac.Renewal_Registration_Number__c; 
                    rsaRec.DBA_Name__c=ac.DBA_Name__c;
                    rsaRec.Legal_Entity__c=ac.Legal_Entity__c;
                    rsaRec.BillingStreet=ac.BillingStreet;
                    rsaRec.BillingCity=ac.BillingCity;
                    rsaRec.BillingState=ac.BillingState;
                    rsaRec.BillingPostalCode=ac.BillingPostalCode;
                    rsaRec.BillingCountry=ac.BillingCountry;
                    rsaRec.Phone=ac.Phone;
                    rsaRec.Email__c=ac.Email__c;
                    rsaRec.OwnerId=ac.OwnerId;
                    rsaRec.Registration_Type__c='Renewal';
                    rsaRec.Registration_Number__c=String.valueOf(intRegNumber);
                    rsaRec.AccountNumber=String.valueOf(intRegNumber);
                    RSAaccnList.add(rsaRec);
                    
                    // Update Process
                    ac.RecordTypeId = applicationCompleteRecordTypeID;
                    ac.Renewal_Process__c = 'Completed';
                    aplnCmpAcnList.add(ac);
                }
            }
            if(!RSAaccnList.isEmpty()){
                Database.DMLOptions dml = new Database.DMLOptions(); 
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true;
                
                Database.SaveResult[] insertSaveResult = Database.insert(RSAaccnList, dml);
                system.debug(insertSaveResult[0].getId());
                newRSAId = insertSaveResult[0].getId();
                system.debug('New Account Id ==> '+newRSAId);
                System.debug('insertSaveResult-----------> '+insertSaveResult);
            }
            if(!aplnCmpAcnList.isEmpty()){
                Update aplnCmpAcnList;
            }
        }catch(Exception e){
            system.debug('Type==> '+e.getTypeName());
            system.debug('Line==> '+e.getLineNumber());
            system.debug('Cause==> '+e.getCause());
            system.debug('Message==> '+e.getMessage());
        }
        return newRSAId;
    } // EO createRSAAccount  
    
    public static void updateUserContactAccount(String applicationAccountId, String rsaNewAccId){
        try{
            List<Contact> usrconList=[SELECT Id, Name, AccountId FROM Contact 
                                      WHERE AccountID=:applicationAccountId AND Status__c='Active' LIMIT 1];  
            usrconList[0].AccountId = rsaNewAccId;
            update usrconList;
            
            //updating primary contacts status
            List<AccountContactRelation> newPrimaryConList = New List<AccountContactRelation>();
            
            List<AccountContactRelation> primaryConList = [SELECT Id,status__c FROM AccountContactRelation 
                                                           WHERE contactId=:usrconList[0].Id AND accountId=:rsaNewAccId];
            if(!primaryConList.isEmpty()){
                for(AccountContactRelation acr : primaryConList){
                    acr.Status__c='Active';
                    newPrimaryConList.add(acr);
                }         
            }
            if(newPrimaryConList.size()>0){
                update newPrimaryConList;
            }      
            
        }catch(Exception e){
            system.debug('Type==> '+e.getTypeName());
            system.debug('Line==> '+e.getLineNumber());
            system.debug('Cause==> '+e.getCause());
            system.debug('Message==> '+e.getMessage());
        }
    }
    
    public static Void createAgents(String applicationAccountId, String rsaNewAccId){
        Try{
            List<AccountContactRelation>newAgentList = New List<AccountContactRelation>();
           
            List<AccountContactRelation>agentList = [SELECT Id,contactId,accountId FROM AccountContactRelation 
                                                     WHERE accountId=: applicationAccountId AND status__c = 'Active' AND contact.Recordtype.DeveloperName='RSAAgent'];
            
            if(!agentList.isEmpty()){
                for(AccountContactRelation acr : agentList){
                    AccountContactRelation acn = New AccountContactRelation();
                    acn.accountId = rsaNewAccId;
                    acn.ContactId = acr.ContactId;
                    acn.Status__c='Active';
                    acn.StartDate = System.today();
                    acn.agentFromAppRecordTypeCreated__c = True;//to identify ACR record copied from Application record type account
                    newAgentList.add(acn);
                }
            }
            
            system.debug(newAgentList.size()+' <--newAgentList Size--> '+newAgentList);
            if(!newAgentList.isEmpty()){
                Insert newAgentList;
            }
        }catch(Exception e){
            system.debug('Type==> '+e.getTypeName());
            system.debug('Line==> '+e.getLineNumber());
            system.debug('Cause==> '+e.getCause());
            system.debug('Message==> '+e.getMessage());
        }
    }
    public static Void createAssociatedLocation(String applicationAccountId, String rsaNewAccId){
        Try{
            List<AssociatedLocation>newAsLocList = New List<AssociatedLocation>();
            List<AssociatedLocation>asLocList = [SELECT LocationId, Location.Name, Type FROM AssociatedLocation
                                                 WHERE ParentRecordId =: applicationAccountId AND status__c = 'Active'];
            
            if(!asLocList.isEmpty()){
                for(AssociatedLocation aslOld : asLocList){
                    AssociatedLocation aslNew = New AssociatedLocation();
                    aslNew.ParentRecordId = rsaNewAccId;
                    aslNew.LocationId = aslOld.LocationId;
                    aslNew.Type = aslOld.Type;
                    aslNew.ActiveFrom = System.today();
                    aslNew.ActiveTo= System.today()+365;
                    aslNew.Status__c='Active';
                    aslNew.locationFromAppRecordTypeCreated__c = True; //to identify Associated Location copied from Application record type account
                    newAsLocList.add(aslNew);
                }
            }
            
            system.debug(newAsLocList.size()+' <--newAsLocList Size--> '+newAsLocList);
            if(!newAsLocList.isEmpty()){
                Insert newAsLocList;
            }
        }catch(Exception e){
            system.debug('Type==> '+e.getTypeName());
            system.debug('Line==> '+e.getLineNumber());
            system.debug('Cause==> '+e.getCause());
            system.debug('Message==> '+e.getMessage());
        }
        
    }
    public static Void createAssets(String applicationAccountId, String rsaNewAccId){
        Try{
            List<Asset> newAssetList = New List<Asset>();
			List<Asset> assetList = [SELECT id, AccountId, Product2Id, name,Device_Type__c,Description,Other_Device_Comments__c 
                                     FROM Asset where AccountId =: applicationAccountId];
            
            if(!assetList.isEmpty()){
                for(Asset oldAst : assetList){
                    Asset newAst = new Asset();
                    newAst.Name = oldAst.Name;
                    newAst.Name = oldAst.Name;
                    newAst.AccountId = rsaNewAccId;
                    newAst.Product2Id = oldAst.Product2Id;
                    newAst.Device_Type__c = oldAst.Device_Type__c;
                    newAst.Other_Device_Comments__c = oldAst.Other_Device_Comments__c;
                    newAst.Description = oldAst.Description;
                    newAssetList.add(newAst);
                }
            }
            
            system.debug(newAssetList.size()+' <--newAssetList Size--> '+newAssetList);
            if(!newAssetList.isEmpty()){
                Insert newAssetList;
            }
        }catch(Exception e){
            system.debug('Type==> '+e.getTypeName());
            system.debug('Line==> '+e.getLineNumber());
            system.debug('Cause==> '+e.getCause());
            system.debug('Message==> '+e.getMessage());
        }
    }
    
    public static Void createDocuments(String applicationAccountId, String rsaNewAccId){
        Try{
            List<ContentDocumentLink>newDocList = New List<ContentDocumentLink>();
            List<ContentDocumentLink>docList = [SELECT ContentDocumentId,ShareType,Visibility FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =: applicationAccountId];
            if(!docList.isEmpty()){
                for(ContentDocumentLink oldCdl: docList){
                    ContentDocumentLink newCdl = New ContentDocumentLink();
                    newCdl.LinkedEntityId = rsaNewAccId;
                    newCdl.ContentDocumentId = oldCdl.ContentDocumentId;
                    newCdl.ShareType = oldCdl.ShareType;
                    newCdl.Visibility = oldCdl.Visibility;
                    newDocList.add(newCdl);
                }
            }
            
            system.debug(newDocList.size()+' <--newDocList Size--> '+newDocList);
            if(!newDocList.isEmpty()){
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true;
                List<Database.SaveResult> insertSaveResultList = Database.insert(newDocList, dml);
                system.debug('insertSaveResultList==> '+insertSaveResultList);
            }
        }catch(Exception e){
            system.debug('Type==> '+e.getTypeName());
            system.debug('Line==> '+e.getLineNumber());
            system.debug('Cause==> '+e.getCause());
            system.debug('Message==> '+e.getMessage());
        }
    }
    
    //Inserting Buisiness License record for account
    public static String createBusinessLiecense(String applicationAccountId, String rsaNewAccId){
        String newBLId;
        
        string agencyName=[select name from account where id=:rsaNewAccId].name;    
            
        Try{
             
            BusinessLicense bl = new BusinessLicense(); 
            bl.Name = agencyName+' BL';
            bl.status = 'Active';
            
            DateTime pstartDate= system.today();
            
            bl.PeriodStart = pstartDate.date().toStartOfMonth();
            bl.PeriodStart =  bl.PeriodStart.addHours(8);
            Datetime pendDate = bl.PeriodStart.addYears(1);
            bl.PeriodEnd = pendDate.addDays(-1);
            //system.debug('PeriodEnd==> '+newBl.PeriodEnd);
            bl.AccountId = rsaNewAccId;
         
            insert bl;
            newBLId=bl.Id;
            
        }catch(Exception e){
            system.debug('Type==> '+e.getTypeName());
            system.debug('Line==> '+e.getLineNumber());
            system.debug('Cause==> '+e.getCause());
            system.debug('Message==> '+e.getMessage());
        }
        return newBLId;
    }
    
    public static List<String> createRegulatoryTrxnFee(String applicationAccountId, String rsaNewAccId, String newBLId){
        List<String>regTxnFeeIdSet = New List<String>();
        Try{
            
            List<RegulatoryTrxnFee>newRegTxnFeeList = new List<RegulatoryTrxnFee>();
            List<RegulatoryTrxnFee>regTxnFeeList = [SELECT Id, AccountId,CalculationDate,Comments,ConfirmationNumber__c,
                                                    ConfirmationMessage__c,Convenience_Fee__c,DueDate,Paid_Date__c,ParentRecordId,
                                                    Payment_Status__c,Status,Taxamount__c,Total_Amount__c, Renewal_Account_Id__c 
                                                    FROM RegulatoryTrxnFee WHERE AccountId =: applicationAccountId];
            if(!regTxnFeeList.isEmpty()){
                for(RegulatoryTrxnFee oldRtf : regTxnFeeList){
                    RegulatoryTrxnFee newRtf = New RegulatoryTrxnFee();
                    newRtf.AccountId=rsaNewAccId;
                    newRtf.CalculationDate=oldRtf.CalculationDate;
                    newRtf.Comments=oldRtf.Comments;
                    newRtf.ConfirmationNumber__c=oldRtf.ConfirmationNumber__c;
                    newRtf.ConfirmationMessage__c=oldRtf.ConfirmationMessage__c;
                    newRtf.Convenience_Fee__c=oldRtf.Convenience_Fee__c;
                    newRtf.DueDate=oldRtf.DueDate;
                    newRtf.Paid_Date__c=oldRtf.Paid_Date__c;
                    newRtf.ParentRecordId=oldRtf.ParentRecordId;
                    newRtf.Payment_Status__c=oldRtf.Payment_Status__c;
                    newRtf.Status=oldRtf.Status;
                    newRtf.Taxamount__c=oldRtf.Taxamount__c;
                    newRtf.Total_Amount__c=oldRtf.Total_Amount__c;
                    newRtf.Renewal_Account_Id__c=oldRtf.Renewal_Account_Id__c;
                    newRegTxnFeeList.add(newRtf);
                }
            }
            if(!newRegTxnFeeList.isEmpty()){
                Database.DMLOptions dml = new Database.DMLOptions(); 
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true;
                
                Database.SaveResult[] insertSaveResult = Database.insert(newRegTxnFeeList, dml);
                for(Database.SaveResult dbs : insertSaveResult){
                    regTxnFeeIdSet.add(dbs.getId());
                }
                system.debug(regTxnFeeIdSet.size()+' Shahid Ids ==> '+regTxnFeeIdSet);
                system.debug(insertSaveResult[0].getId());
                System.debug('<== insertSaveResult-----------> '+insertSaveResult);  
            }
        }catch(Exception e){
            system.debug('Type==> '+e.getTypeName());
            system.debug('Line==> '+e.getLineNumber());
            system.debug('Cause==> '+e.getCause());
            system.debug('Message==> '+e.getMessage());
        }
        return regTxnFeeIdSet;
    }
    
    public static Void createRegulatoryTrxnFeeItems(String applicationAccountId, String rsaNewAccId){
        Try{
            List<RegulatoryTrxnFeeItem>newRegTxnFeeItmList = New List<RegulatoryTrxnFeeItem>();
            List<RegulatoryTrxnFeeItem>regTxnFeeItmList = [SELECT Id,Name,FeeAmount,isSelected__c,RegulatoryTrxnFeeId,Status__c 
                                                           FROM RegulatoryTrxnFeeItem 
                                                           WHERE RegulatoryTrxnFee.AccountId=:applicationAccountId AND
                                                           RegulatoryTrxnFee.status='Paid'];
            
            Id newTxnFeeId = [SELECT Id FROM RegulatoryTrxnFee WHERE AccountId=:rsaNewAccId AND status='Paid'].Id;
            
            if(!regTxnFeeItmList.isEmpty()){
                for(RegulatoryTrxnFeeItem oldRegTxnItm : regTxnFeeItmList){
                    RegulatoryTrxnFeeItem newRegTxnItm = New RegulatoryTrxnFeeItem();
                    newRegTxnItm.Name = oldRegTxnItm.Name;
                    newRegTxnItm.FeeAmount = oldRegTxnItm.FeeAmount;
                    newRegTxnItm.isSelected__c = oldRegTxnItm.isSelected__c;
                    newRegTxnItm.Status__c = oldRegTxnItm.Status__c;
                    newRegTxnItm.RegulatoryTrxnFeeId = newTxnFeeId;
                    newRegTxnFeeItmList.add(newRegTxnItm);
                }
            }
            
            system.debug(newRegTxnFeeItmList.size()+' <--newRegTxnFeeItmList Size--> '+newRegTxnFeeItmList);
            if(!newRegTxnFeeItmList.isEmpty()){
                Database.DMLOptions dml = new Database.DMLOptions(); 
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true;
                
                Database.SaveResult[] insertSaveResult = Database.insert(newRegTxnFeeItmList, dml);
                System.debug('  <== insertSaveResult-----------> '+insertSaveResult);            
            }
                                                            
        }catch(Exception e){
            system.debug('Type==> '+e.getTypeName());
            system.debug('Line==> '+e.getLineNumber());
            system.debug('Cause==> '+e.getCause());
            system.debug('Message==> '+e.getMessage());
        }
    }
    
	//createPaymentRequest Method
	public static Void createPaymentRequest(String applicationAccountId, String rsaNewAccId){
        Try{
            List<Payment_Request__c>newPayReqList = New List<Payment_Request__c>();
            
            List<Payment_Request__c>payReqList = [SELECT Id,Account__c,OwnerId,EndDate__c, StartDate__c, RequestData__c,Regulatory_Transaction_Fee__c, Status__c  FROM Payment_Request__c 
                                                     WHERE Account__c=: applicationAccountId AND Status__c = 'Completed'];
            if(!payReqList.isEmpty()){
                for(Payment_Request__c preq : payReqList){
                    Payment_Request__c preqn  = New Payment_Request__c();
                    preqn.Account__c = rsaNewAccId;
                    preqn.OwnerId = preq.OwnerId;
                    preqn.EndDate__c = preq.EndDate__c;
                    preqn.StartDate__c = preq.StartDate__c;
                    preqn.RequestData__c = preq.RequestData__c;
                    preqn.Regulatory_Transaction_Fee__c = preq.Regulatory_Transaction_Fee__c;
                    preqn.Status__c = preq.Status__c;
                    newPayReqList.add(preqn);
                }
            }            
            system.debug(newPayReqList.size()+' <--newPayReqList Size--> '+newPayReqList);
            if(!newPayReqList.isEmpty()){
                Insert newPayReqList;
            }
        }catch(Exception e){
            system.debug('Type==> '+e.getTypeName());
            system.debug('Line==> '+e.getLineNumber());
            system.debug('Cause==> '+e.getCause());
            system.debug('Message==> '+e.getMessage());
        }
    }// EO createPaymentRequest
    
	//createPaymentResponse Method
	public static Void createPaymentResponse(String applicationAccountId, String rsaNewAccId){
        Try{
            List<Payment_Response__c>newPayRespList = New List<Payment_Response__c>();
            
            List<Payment_Response__c>payRespList = [SELECT Id,Account__c,Payment_Request__c,ReceiveDate__c,ResponseData__c,ePay_Return_Code__c,ePay_Result_Message__c,
                                                    Total_Paid_Amount__c,Confirmation_Number__c,Authorization_Code__c,Settlement_Submission_Date__c,Card_Type__c,
                                                    Unique_ID__c,Regulatory_Transaction_Fee__c,hash__c,Status__c FROM Payment_Response__c WHERE Account__c=: applicationAccountId AND Status__c = 'Success'];
            
            Id newReqId = [SELECT Id From Payment_Request__c WHERE Account__c=:rsaNewAccId AND Status__c = 'Completed'].Id;
            
            if(!payRespList.isEmpty()){
                for(Payment_Response__c pr : payRespList){
                    Payment_Response__c prn  = New Payment_Response__c();
                    prn.Account__c = rsaNewAccId;
                    prn.Payment_Request__c = newReqId;
					prn.ReceiveDate__c = pr.ReceiveDate__c;
					prn.ResponseData__c = pr.ResponseData__c;
                    prn.ePay_Return_Code__c = pr.ePay_Return_Code__c;
                    prn.ePay_Result_Message__c = pr.ePay_Result_Message__c;
                    prn.Confirmation_Number__c = pr.Confirmation_Number__c;
                    prn.Authorization_Code__c = pr.Authorization_Code__c;
                    prn.Settlement_Submission_Date__c = pr.Settlement_Submission_Date__c;
                    prn.Card_Type__c = pr.Card_Type__c;
                    prn.Unique_ID__c = pr.Unique_ID__c;
                    prn.Regulatory_Transaction_Fee__c = pr.Regulatory_Transaction_Fee__c;
                    prn.hash__c = pr.hash__c;
					prn.Total_Paid_Amount__c = pr.Total_Paid_Amount__c;
                    prn.Status__c = pr.Status__c;
                    newPayRespList.add(prn);
                }
            }
            system.debug(newPayRespList.size()+' <--newPayRespList Size--> '+newPayRespList);
            if(!newPayRespList.isEmpty()){
                Insert newPayRespList;
            }
        }catch(Exception e){
            system.debug('Type==> '+e.getTypeName());
            system.debug('Line==> '+e.getLineNumber());
            system.debug('Cause==> '+e.getCause());
            system.debug('Message==> '+e.getMessage());
        }
    }// EO createPaymentResponse    
}