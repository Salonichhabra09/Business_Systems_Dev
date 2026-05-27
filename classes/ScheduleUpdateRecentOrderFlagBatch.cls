global class ScheduleUpdateRecentOrderFlagBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
        UpdateRecentOrderFlagBatch batch = new UpdateRecentOrderFlagBatch();
        Database.executeBatch(batch, 200);
    }
}