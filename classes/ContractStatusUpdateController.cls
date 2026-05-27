public class ContractStatusUpdateController {
    @AuraEnabled
    public static String contractStatusUpdate(Id recId){
        String message = '';
        try{
            Contract ctr = [select Id, Status from Contract where  Id =:recId LIMIT 1];
                if(ctr.Status != 'Under Customer Review'){
                    ctr.Status = 'Under Customer Review';
                    update ctr;
                    message = 'UPDATED';
                } else {
                    message = 'NOT UPDATED';
                }
            return message;
        } catch (DMLException e) {
            message = e.getDmlMessage(0);
            return message;
        } 
    }
}