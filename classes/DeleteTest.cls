@isTest(SeeAllData=true)
public class DeleteTest{

@istest
public static void testmethod1(){
 List<RevenueAttribution__c>rlist = [select id from RevenueAttribution__c where Financial_Period_closed__c=false limit 1];
delete rlist;


}
}