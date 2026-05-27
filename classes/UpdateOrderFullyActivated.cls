public class UpdateOrderFullyActivated {
     
    @AuraEnabled
    Public static void updateOrder(String objOrder){
        String msg = '';
        try{
            //Update Order Record
			Order Orderrecord =[Select id,name,status,Oats_Status__c from Order where id=:objOrder];
			Orderrecord.status= 'Activated';
			Orderrecord.Oats_Status__c = 'Completed';
            update Orderrecord; 
             
        }catch(DmlException e){
            //Any type of Validation Rule error message, Required field missing error message, Trigger error message etc..
            //we can get from DmlException
             
            //Get All DML Messages
            for (Integer i = 0; i < e.getNumDml(); i++) {
                //Get Validation Rule & Trigger Error Messages
                msg =+ e.getDmlMessage(i) +  '\n' ;
            }
            //throw DML exception message
            throw new AuraHandledException(msg);
             
        }catch(Exception e){
            //throw all other exception message
            throw new AuraHandledException(e.getMessage());
        }
        finally {
        }
    } 
}