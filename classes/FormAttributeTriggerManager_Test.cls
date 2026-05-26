@isTest
public class FormAttributeTriggerManager_Test {
	
    @isTest
    public static void beforeInsert(){
        Form_Attribute__c fa = new Form_Attribute__c();
        fa.Label__c = 'ForTestClass';
        fa.API_Name__c = 'For_Test_Class__c';
        fa.Data_Type__c = 'text';
        fa.Category__c = 'Candidate Import Template';
        fa.Object__c = 'Bureau_Candidate__c';
        
        Test.startTest();
        insert fa;
        fa.Data_Type__c = 'number';
        update fa;
        Test.stopTest(); 
    }
    
    @isTest
    public static void beforeInsertDuplicate(){
        Form_Attribute__c fa = new Form_Attribute__c();
        fa.Label__c = 'ForTestClass';
        fa.API_Name__c = 'For_Test_Class__c';
        fa.Data_Type__c = 'text';
        fa.Category__c = 'Candidate Import Template';
        fa.Object__c = 'Bureau_Candidate__c';
        insert fa;
        
        Form_Attribute__c fa1 = new Form_Attribute__c();
        fa1.Label__c = 'ForTestClass';
        fa1.API_Name__c = 'For_Test_Class__c';
        fa1.Data_Type__c = 'text';
        fa1.Category__c = 'Candidate Import Template';
        fa1.Object__c = 'Bureau_Candidate__c';

        List<Form_Attribute__c> formAttributesList = new List<Form_Attribute__c>{fa1};
        
        Test.startTest();
        FormAttributeTriggerManager.beforeInsertUpdate(formAttributesList, null);
        Test.stopTest();
        
    }
}