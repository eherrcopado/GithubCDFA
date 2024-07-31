global class ScheduleAgentAgencyCount implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
        try{
            BatchAgentAgencyCount be = new BatchAgentAgencyCount();
            Id batchId = database.executeBatch(be,50);
            system.debug('batchId--> '+batchId);
        }catch(Exception e){
            system.debug(e.getTypeName());
            system.debug(e.getLineNumber());
            system.debug(e.getCause());
            system.debug(e.getMessage());
        }
    }
}
/*
* Ref : https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_scheduler.htm
ScheduleAgentAgencyCount p = new ScheduleAgentAgencyCount();
String sch = '0 0 1 * * ?';
system.schedule('One Time Pro', sch, p);
//contactTriggerHandler.countAgentsAgencies();
*/