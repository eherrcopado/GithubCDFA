/*public without Sharing class ApplicationEmailClass {
    
    public static void sendEmail(List<Account>accList){
       List<Contact>ConList = New List<Contact>();
        Try{
            Id accRecTypeId;
            Account acn;
            Set<Id>accountIdSet= New Set<Id>();
             
            Id applicationCompleteRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Application_Complete').getRecordTypeId();
            Id applicationRejectedRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Application_Rejected').getRecordTypeId();
            
            for(Account acc : accList){
                accRecTypeId = acc.RecordTypeId;
                acn=acc;
                accountIdSet.add(acc.Id);
            }
            
            if(accountIdSet != NULL){
                ConList=[Select Name, Email From Contact Where Recordtype.DeveloperName='RSAContact' AND AccountId =: accountIdSet Limit 1];
            }
            system.debug('ConList'+ConList);
            system.debug(accRecTypeId+ ' accRecTypeId '+acn);
            if((accRecTypeId != NULL || accRecTypeId != '') && (ConList[0].Email != NULL || ConList[0].Email != '')){
                if(accRecTypeId == applicationCompleteRecordTypeId){
                    actualEmailSent(ConList[0].Email, 'Application Approved','CDFA DMS RSA Business Application Approved');
                }else if(accRecTypeId == applicationRejectedRecordTypeId){
                    actualEmailSent(ConList[0].Email, 'Application Rejected','CDFA DMS RSA Business Application Rejected');
                }
            }
        }
        catch(Exception e){
            system.debug('Type==> '+e.getTypeName());
            system.debug('Line==> '+e.getLineNumber());
            system.debug('Cause==> '+e.getCause());
            system.debug('Message==> '+e.getMessage());
        }
    }
    
    public static void actualEmailSent(String toAddress,String emailBody,String subject){
        Try{
            system.debug(toAddress+ ' === Test === '+emailBody);
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {toAddress};
                mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('RSA@fed');
            mail.setSubject(subject);
            mail.setPlainTextBody(emailBody);
            system.debug('mail--> '+mail);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch(Exception e){
            system.debug('Type==> '+e.getTypeName());
            system.debug('Line==> '+e.getLineNumber());
            system.debug('Cause==> '+e.getCause());
            system.debug('Message==> '+e.getMessage());
        }
    }
}
*/

public without Sharing class ApplicationEmailClass{
    
    public static void sendEmail(List<Account>accList){
       List<Contact>ConList = New List<Contact>();
        Try{
            Id accRecTypeId;
            Account acn;
            Set<Id>accountIdSet= New Set<Id>();
             
            Id applicationCompleteRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Application_Complete').getRecordTypeId();
            Id applicationRejectedRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Application_Rejected').getRecordTypeId();
            
            for(Account acc : accList){
                accRecTypeId = acc.RecordTypeId;
                acn=acc;
                accountIdSet.add(acc.Id);
            }
            
            if(accountIdSet != NULL){
                ConList=[Select Name, Email From Contact Where Recordtype.DeveloperName='RSAContact' AND AccountId =: accountIdSet Limit 1];
            }
            system.debug('ConList'+ConList);
            system.debug(accRecTypeId+ ' accRecTypeId '+acn);
            if(ConList.size()>0){
            if((accRecTypeId != NULL || accRecTypeId != '') && (ConList[0].Email != NULL || ConList[0].Email != '')){
                if(accRecTypeId == applicationCompleteRecordTypeId){
                    Try{
						Messaging.reserveSingleEmailCapacity(1);
						Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
						String[] toAddresses = new String[] {ConList[0].Email};
						mail.setToAddresses(toAddresses);
						mail.setSenderDisplayName('RSA@fed');
						mail.setSubject('CDFA DMS RSA Business Application Approved');
						mail.setPlainTextBody('Dear ' + ConList[0].Name + ',');
						mail.setHtmlBody('<Html>'+'<Body>'+ '<p> Dear ' + ConList[0].Name + ',' + '</p>'+'<p>Your Registered Service Agency Business Application has been approved by the California Department of Food and Agriculture. Please login to the <a href="https://cdfa.force.com/rsaportal/s/login/">RSA Portal</a> to view your Account Details.</p><p>If you have any questions, please contact us at: <a href="mailto:rsa@cdfa.ca.gov">rsa@cdfa.ca.gov</a></p><p>Regards,<br>RSA Administrator<br>Division of Measurement Standards<br>California Department of Food and Agriculture<br></p>'+'</Body>'+'</Html>');
						system.debug('mail--> '+mail);
						Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
					}catch(Exception e){
						system.debug('Type==> '+e.getTypeName());
						system.debug('Line==> '+e.getLineNumber());
						system.debug('Cause==> '+e.getCause());
						system.debug('Message==> '+e.getMessage());
					}
                }else if(accRecTypeId == applicationRejectedRecordTypeId){
                    Try{
						Messaging.reserveSingleEmailCapacity(1);
						Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
						String[] toAddresses = new String[] {ConList[0].Email};
						mail.setToAddresses(toAddresses);
						mail.setSenderDisplayName('RSA@fed');
						mail.setSubject('CDFA DMS RSA Business Application Rejected');
						mail.setPlainTextBody('Dear ' +  + ',');
						mail.setHtmlBody('<Html>'+'<Body>'+ '<p> Dear ' + ConList[0].Name + ',' + '</p>'+'<p>Your Registered Service Agency Business Application has been rejected by the California Department of Food and Agriculture. Please contact the RSA team at <a href="mailto:rsa@cdfa.ca.gov">rsa@cdfa.ca.gov</a> with any questions.</p>'+ '<p>Regards,<br>RSA Administrator<br>Division of Measurement Standards<br>California Department of Food and Agriculture<br></p>'+'</Body>'+'</Html>');
						system.debug('mail--> '+mail);
						Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
					}catch(Exception e){
						system.debug('Type==> '+e.getTypeName());
						system.debug('Line==> '+e.getLineNumber());
						system.debug('Cause==> '+e.getCause());
						system.debug('Message==> '+e.getMessage());
					}
                }
            }
            }
        }
        catch(Exception e){
            system.debug('Type==> '+e.getTypeName());
            system.debug('Line==> '+e.getLineNumber());
            system.debug('Cause==> '+e.getCause());
            system.debug('Message==> '+e.getMessage());
        }
    }
}