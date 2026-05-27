global class OpportunityPriceUpdateScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
       OppPriceIncreaseOldStdClauseBatch batch = new OppPriceIncreaseOldStdClauseBatch();
       Database.executeBatch(batch, 100); // batch size = 100
   }
}