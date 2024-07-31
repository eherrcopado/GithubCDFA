/**********************************************************************
 Name         : EmailMessageTrigger
 Description  : Trigger to create the Contact record from eamil to case
 Created      : 10-03-2022
***********************************************************************/
trigger EmailMessageTrigger on EmailMessage (After insert) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        EmailMessageTriggerHandler.onAfterInsert(Trigger.new);
    }
}