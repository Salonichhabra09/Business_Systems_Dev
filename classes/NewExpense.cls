public class NewExpense {
    @AuraEnabled
    public static String fetchUser(){
        //User oUser = [Select id, Name, DefaultCurrencyIsoCode from User where id=: userInfo.getDefaultCurrency()];
        return UserInfo.getDefaultCurrency();
         
    }
    
   }