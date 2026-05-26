public class ScheduleClassToUpdateConvayrStatusOnJob implements Schedulable{
	
    
    public void execute(SchedulableContext ctx) {
            GetUpdatedRatingsJobs batch = new GetUpdatedRatingsJobs();
			Database.executeBatch(batch, 2000);
    }
}