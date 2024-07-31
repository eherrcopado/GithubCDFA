global class RSAAgentEmailHandler implements Messaging.InboundEmailHandler {
      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
          Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          
try 
  {
   List<Contact> contList= [SELECT Id, Name, Email FROM Contact WHERE Email = 'ray.ashcroft@cdfa.ca.gov' LIMIT 1];
   Task taskObj = new Task();
   taskObj.Description =  email.htmlBody.stripHtmlTags();
   taskObj.Priority = 'Normal';
   taskObj.Status = 'Inbound Email';
   taskObj.Subject = email.subject;
   taskObj.IsReminderSet = true;
   taskObj.ReminderDateTime = System.now()+1;
   system.debug('***email.htmlBody*** '+email.htmlBody);
   if(contList.size()>0)
   {
    taskObj.WhoId =  contList[0].Id;
   }    
   insert taskObj;    
  }
  catch (Exception e) 
  {
     System.debug('Exception : ' + e);
  }
  result.success = true;          
          return result;
      }
  }