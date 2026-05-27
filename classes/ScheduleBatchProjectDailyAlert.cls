global with sharing class ScheduleBatchProjectDailyAlert implements Schedulable {
 global void execute(SchedulableContext sc) {
  ID BatchId = Database.executeBatch(new Project_Daily_Alert(), 200);
 }
    
}