@isTest(seeAlldata=true)
public class HighlightPanelControllerTester {

    @isTest 
    static void fetchFieldsTest(){
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft');
        insert ap;
        
        HighlightPanelController.ReturnWP rwp = new HighlightPanelController.ReturnWP();
      
        Test.startTest();
        rwp =  HighlightPanelController.fetchFields(ap.id,'Account_Plan__c','HighLightPanel');
        system.assertEquals('Draft', rwp.Status);
        system.assertEquals('0', rwp.UnapprovedStrat);
        Test.stopTest();
        
    }
    
    @isTest 
    static void RecordIdBlankTest(){
        
        HighlightPanelController.ReturnWP rwp = new HighlightPanelController.ReturnWP();
        Test.startTest();
        rwp =  HighlightPanelController.fetchFields('','Account_Plan__c','HighLightPanel');
        system.assertEquals('Invalid Id', rwp.message);
       
        Test.stopTest();
        
    }

     @isTest 
    static void BlankFieldSetTest(){
         Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Account_Plan_Type__c='Current',
                                                 Year__c='2023',Account_Plan_Status__c ='Draft');
        insert ap;
        
        HighlightPanelController.ReturnWP rwp = new HighlightPanelController.ReturnWP();
        Test.startTest();
        rwp =  HighlightPanelController.fetchFields(ap.id,'Account_Plan__c','');
        system.assertEquals('Please provide a Field Set Name', rwp.message);
       
        Test.stopTest();
        
    }
    
     @isTest 
    static void InvalidFieldSetTest(){
         Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Type__c='Current',
                                                 Account_Plan_Status__c ='Draft');
        insert ap;
        
        HighlightPanelController.ReturnWP rwp = new HighlightPanelController.ReturnWP();
        Test.startTest();
        rwp =  HighlightPanelController.fetchFields(ap.id,'Account_Plan__c','Test');
        system.assertEquals('Field Set provided is not Valid', rwp.message);
       
        Test.stopTest();
        
    }
}