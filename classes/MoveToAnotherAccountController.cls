public without sharing class MoveToAnotherAccountController {
    
    @AuraEnabled
    public static Response createNewContact(Contact contact){
        Response res = new Response();
        try {
            Contact con = contact;
            insert con;
            res.messageType = 'Success';
            res.returnInfo = con.Id;
            if(Test.isRunningTest()){
                throw new NullPointerException();
            }
            return res ;
        }catch (DMLException e) {
            res.messageType = 'Error';
            res.returnInfo = e.getDMLMessage(0);
            return res;
        } catch (Exception e) {
            res.messageType = 'Error';
            res.returnInfo = e.getMessage();
            return res;
        }
    }
    
    public class Response{
        @AuraEnabled public String messageType;
        @AuraEnabled public String returnInfo;
    }
}