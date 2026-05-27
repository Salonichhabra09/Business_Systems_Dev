/**
* ----------------------------------------------------------------------------------------
* Class Name     : EligibleOppScheduler
* Author         : Prabhat
* Created Date   : 2025-09-11
* Purpose        : 
*   - Scheduler class that runs the EligibleOppBatch job at a configured daily time.
*   - Allows admins to control schedule via Setup > Apex Classes > Schedule Apex.
* ----------------------------------------------------------------------------------------
*/
 
global with sharing class EligibleOppScheduler implements Schedulable {
 
    /**
     * execute() method
     * Invoked by Salesforce Scheduler at the configured time.
     * Kicks off the batch EligibleOppBatch with a batch size of 200.
     */
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EligibleOppBatch(), 200);
    }
}