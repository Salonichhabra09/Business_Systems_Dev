public class FieldCreationScheduler implements Schedulable{
    
    private String jsonData;
    
    public FieldCreationScheduler(String json) {
        this.jsonData = json;
    }
    
    public void execute(SchedulableContext ctx) {
        System.debug('jsonData: '+ jsonData);
        //FieldCreationController.fieldDataList(jsonData);
        	Id jobID1 = System.enqueueJob(new FieldCreationQueueable(jsonData));
        	System.abortJob(ctx.getTriggerId());    
        
    }
}