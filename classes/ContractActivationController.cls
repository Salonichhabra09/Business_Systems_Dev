public class ContractActivationController {
     
    @AuraEnabled
    Public static void updateContract(String objContract){
        String msg = '';
        try{
            //Update Contract Record
			Contract Contractrecord =[Select id,name,status from Contract where id=:objContract limit 1];
			Contractrecord.status= 'Accepted';
            update Contractrecord; 
             
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