trigger AgencyRenewalTriggger on Agency_Renewal__c (after update) {
    if(trigger.isUpdate && trigger.isAfter){
        system.debug('called');
        ContactsLwcController.updateAgentStatus(Trigger.oldMap,Trigger.newMap);
    }
}