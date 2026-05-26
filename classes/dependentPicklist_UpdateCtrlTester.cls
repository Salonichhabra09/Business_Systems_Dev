@isTest(SeeAllData=true)
public class dependentPicklist_UpdateCtrlTester {
    @isTest
    public static void test(){
        //String AcId=[select id from Account].Id;
        Account acc= new Account();
            acc.Name='Test234';
            acc.BU__c='AP Region - P10';
            acc.CurrencyIsoCode='GBP'; 
            acc.Industry='Consulting';
            acc.Billing_Address_Line_1__c='test23';
            acc.Billing_City__c='test23';
            acc.Same_As_The_Billing_Address__c=true;
            acc.Billing_Country__c='test23';
            acc.Billing_State__c='test23';
            acc.Billing_ZIP_Postal_Code__c='test23';           
            
        insert acc;
        //Account account=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        //insert account;
        
        Test.startTest();
        Contact con=new Contact();
        con.LastName='Test';
        con.Accountid=acc.Id;
        con.phone='9876772772';
        con.Email='abc@ymail.com';
        con.Same_As_The_Account_Billing_Address__c=true;
        insert con;
        Opportunity oppty=new Opportunity(name='Test Opportunity', AccountID=acc.Id,Offering__c='Enterprise Leadership',Talent_Level__c='Leader',Talent_Segment__c='Volume',Client_Business_Function__c='HR');
        //Opportunity oppty = CreateTestData.getOpportunity(AcId,Con.Id);
        Case case34 = new case(AccountId=acc.Id,ContactId=Con.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Customer Systems Training',Issues__c = 'Platform-related', Product1__c = 'Ability - Verify',Opportunity__c=oppty.Id);

        
        dependentPicklist_UpdateCtrl.decimalToBinary(12);
        dependentPicklist_UpdateCtrl.base64ToBits('Test');
        dependentPicklist_UpdateCtrl.PicklistEntryWrapper PicklistEntryWrapperobj= new dependentPicklist_UpdateCtrl.PicklistEntryWrapper();
        String active=PicklistEntryWrapperobj.active;
        String defaultValue=PicklistEntryWrapperobj.defaultValue;
        String label=PicklistEntryWrapperobj.label;
        
        String value=PicklistEntryWrapperobj.value;
        String validFor=PicklistEntryWrapperobj.validFor;
        dependentPicklist_UpdateCtrl.getDependentMap(case34,'PreChatCountry__c','PreChatLanguage__c');
        
        Test.stopTest();
        
    }
    @isTest
    public static void test2(){
        string India;
        Test.startTest();
        dependentPicklist_UpdateCtrl.getButtonId('Belgium','French','Product, billing or ordering query');
        dependentPicklist_UpdateCtrl.getCntryAbrvtn_CSet(India);
        Test.stopTest();
    }
}