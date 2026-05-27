@isTest(seeAllData = true)
public class ContentDocument_BeforeDelete_tester {

    public static testMethod void TestdeletecontentDocumentCSV(){
        Datetime variable=System.now();
            String TestAccountname='Test Account'+variable; 
            Account account=new Account(name=TestAccountname,Status__c='Approved',CurrencyIsoCode='INR',
                                        //done by aashi Territory__c='Alliances',
                                        Account_Approach__c='Grow',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1',Industry='Agriculture');
            insert account;
        Contract contract = new Contract();
        contract.AccountId = account.Id;  
        contract.Legal_Order_Name__c = 'test'; 
        contract.CurrencyIsoCode = account.CurrencyIsoCode;
        contract.S2P_Reference_Required__c = 'New';
        contract.Status = 'Draft';
        contract.CustomerSignedDate = Date.Today();
        contract.StartDate = Date.Today();
        contract.ContractTerm = 6;   
        contract.Activated_Date__c=datetime.now();
        contract.Final_Submission_Date_EST__c=datetime.now().addDays(-2);
        contract.Submission_Offset__c = 10;
        contract.Agreement__c = 'Order';
        contract.Subscription_Start_Date__c = Date.Today();
        
        insert contract;   
        
        ContentVersion Cv1 = new ContentVersion();    
        Cv1.Origin='C';
        Cv1.VersionData = Blob.ValueOf('Hello');
        Cv1.Title = 'CandidateUploadSheet.PDF';
        Cv1.PathOnClient ='CandidateUploadSheet.PDF'; 
        Cv1.ContentLocation='S';        
        insert Cv1;  
        // First get the content document Id from ContentVersion
        Id conDoc1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:Cv1.Id].ContentDocumentId;             
        //Create ContentDocumentLink
        ContentDocumentLink cDe1 = new ContentDocumentLink();
        cDe1.ContentDocumentId = conDoc1;
        cDe1.Visibility='AllUsers';
        cDe1.LinkedEntityId = contract.Id; // you can use objectId,GroupId etc
        cDe1.ShareType = 'V'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        //cDe.Visibility = 'InternalUsers';
        insert cDe1; 
        
        Cv1 =  [select ContentDocument.Id from ContentVersion where Id = :Cv1.Id];                
        delete Cv1.ContentDocument; 
        
        
    }
    
    public static testMethod void TestdeletecontentDocumentPDF(){
        Datetime variable=System.now();
        String TestAccountname='Test Account'+variable; 
        Account account=new Account(name=TestAccountname,Status__c='Approved',CurrencyIsoCode='INR',
                                    //done by aashi Territory__c='Alliances',
                                    Account_Approach__c='Grow',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1',Industry='Agriculture');
        insert account;
        Contract contract = new Contract();
        contract.AccountId = account.Id;  
        contract.Legal_Order_Name__c = 'test'; 
        contract.CurrencyIsoCode = account.CurrencyIsoCode;
        contract.S2P_Reference_Required__c = 'New';
        contract.Status = 'Draft';
        contract.CustomerSignedDate = Date.Today();
        contract.StartDate = Date.Today();
        contract.ContractTerm = 6;   
        contract.Activated_Date__c=datetime.now();
        contract.Final_Submission_Date_EST__c=datetime.now().addDays(-2);
        contract.Submission_Offset__c = 10;
        contract.Agreement__c = 'Order';
        contract.Subscription_Start_Date__c = Date.Today();
        
        insert contract;   
        
        ContentVersion Cv1 = new ContentVersion();    
        Cv1.Origin='C';
        Cv1.VersionData = Blob.ValueOf('Hello');
        Cv1.Title = 'CandidateUploadSheet.PDF';
        Cv1.PathOnClient ='CandidateUploadSheet.PDF'; 
        Cv1.ContentLocation='S';        
        insert Cv1;  
        // First get the content document Id from ContentVersion
        Id conDoc1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:Cv1.Id].ContentDocumentId;             
        //Create ContentDocumentLink
        ContentDocumentLink cDe1 = new ContentDocumentLink();
        cDe1.ContentDocumentId = conDoc1;
        cDe1.Visibility='AllUsers';
        cDe1.LinkedEntityId = contract.Id; // you can use objectId,GroupId etc
        cDe1.ShareType = 'V'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        //cDe.Visibility = 'InternalUsers';
        insert cDe1; 
        
        Cv1 =  [select ContentDocument.Id from ContentVersion where Id = :Cv1.Id];                
        delete Cv1.ContentDocument; 
        Contract contract1 = new Contract();
        contract1.AccountId = account.Id;  
        contract1.Legal_Order_Name__c = 'test'; 
        contract1.CurrencyIsoCode = account.CurrencyIsoCode;
        contract1.S2P_Reference_Required__c = 'New';
        contract1.Status = 'Draft';
        contract1.CustomerSignedDate = Date.Today();
        contract1.StartDate = Date.Today();
        contract1.ContractTerm = 6;   
        contract1.Activated_Date__c=datetime.now();
        contract1.Final_Submission_Date_EST__c=datetime.now().addDays(-2);
        contract1.Submission_Offset__c = 10;
        contract1.Agreement__c = 'Order';
        contract1.Subscription_Start_Date__c = Date.Today();
        
        insert contract1;
        Contract contract2 = new Contract();
        contract2.AccountId = account.Id;  
        contract2.Legal_Order_Name__c = 'test'; 
        contract2.CurrencyIsoCode = account.CurrencyIsoCode;
        contract2.S2P_Reference_Required__c = 'New';
        contract2.Status = 'Submitted';
        contract2.CustomerSignedDate = Date.Today();
        contract2.StartDate = Date.Today();
        contract2.ContractTerm = 6;   
        contract2.Activated_Date__c=datetime.now();
        contract2.Final_Submission_Date_EST__c=datetime.now().addDays(-2);
        contract2.Submission_Offset__c = 10;
        contract2.Agreement__c = 'Order';
        contract2.Subscription_Start_Date__c = Date.Today();
        insert contract2;
        
        ContentVersion Cv = new ContentVersion();    
        Cv.Origin='C';
        Cv.VersionData = Blob.ValueOf('Hello');
        Cv.Title = 'CandidateUploadSheet.csv';
        Cv.PathOnClient = 'CandidateUploadSheet.csv'; 
        Cv.ContentLocation='S';        
        insert Cv;  
        // First get the content document Id from ContentVersion
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:Cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.Visibility='AllUsers';
        cDe.LinkedEntityId = contract1.Id; // you can use objectId,GroupId etc
        cDe.ShareType = 'V'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        //cDe.Visibility = 'InternalUsers';
        insert cDe;  
        Cv =  [select ContentDocument.Id from ContentVersion where Id = :Cv.Id];                
        delete Cv.ContentDocument; 
        
        
    }
   
     
}