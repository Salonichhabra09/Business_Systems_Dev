public class BillToContactChangeController {
    
    @AuraEnabled
	public static void updateBillToContact(String OrderId,String SelectedContactId){
        Order ordertoupdate = [select id,billtocontactid from order where id=:OrderId];
        ordertoupdate.billtocontactid = SelectedContactId;
        update ordertoupdate;
    }

}