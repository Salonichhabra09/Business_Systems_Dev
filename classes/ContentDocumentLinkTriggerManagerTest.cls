@isTest(SeeAllData = true)
public class ContentDocumentLinkTriggerManagerTest {

    @isTest
    public static void ContentDocLink_InsertTest() {
        Test.startTest();
        Account accountRecord = TestDataUtility.getAccount();
        INSERT accountRecord;
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        Opportunity opp = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        opp.ownerid=UserInfo.getUserId();
        opp.StageName='proposal';
        opp.Closedate=system.today();
        opp.Primary_Contact__c=contactRecord.id;
        opp.Billing_Contact__c=contactRecord.id;
        opp.CurrencyIsoCode='AUD';
        opp.NVM_Credit_Card_ID__c='1234';
        opp.Amount=1000;
        opp.Variation_Opportunity__c='NO';
        opp.OppUpdatedByOrderOn__c=Date.today();
        opp.Original_Opportunity__c=null;
        opp.Annual_Contract_Value__c=1000.00;
        opp.Business_Type__c='New customer: subscription';
        opp.CurrencyISOCode='GBP';
        opp.RecordTypeID=System.label.StandardRecordType;
        opp.Forecast_Category__c='Pipeline';//Forecast
        opp.Multi_YearDeal__c='1';
        opp.Offering__c='OPQ';
        opp.Talent_Segment__c='Volume';
        opp.TM_Phase__c='Post-Hire';
        //opp.contractid=contractRecord.id;
        insert opp;
        Contract contractRecord = TestDataUtility.getContract(accountRecord.id, opp.id);
        contractRecord.Payment_terms__c = '30 days';
        contractRecord.Run_Order_Creation_Flow__c=true;
        contractRecord.PDFCount__c = 1;
        contractRecord.CSVCount__c = 0;
        contractRecord.Product_Billing_Frequency__c = 'Monthly';
        INSERT contractRecord;
        
        ContentVersion cv2 = new ContentVersion();
        cv2.VersionData = Blob.valueOf('Hello');
        cv2.Title = '_ContractSheet.pdf';
         cv2.PathOnClient='/' + 'Test' + '.pdf'; 
        System.debug('Content Version cv '+cv2);
        insert cv2;
        
        System.debug('File Type ###'+cv2.FileType);
        
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv2.id].ContentDocumentId;
        cdl2.LinkedEntityId = contractRecord.id;
        cdl2.ShareType = 'V';
        insert cdl2;
        Test.stopTest();
    }
    
    @isTest
    public static void ContentDocLink_BeforeDeleteTest() {
        Test.startTest();
        Account accountRecord = TestDataUtility.getAccount();
        INSERT accountRecord;
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        Opportunity opp = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        opp.ownerid=UserInfo.getUserId();
        opp.StageName='proposal';
        opp.Closedate=system.today();
        opp.Primary_Contact__c=contactRecord.id;
        opp.Billing_Contact__c=contactRecord.id;
        opp.CurrencyIsoCode='AUD';
        opp.NVM_Credit_Card_ID__c='1234';
        opp.Amount=1000;
        opp.Variation_Opportunity__c='NO';
        opp.OppUpdatedByOrderOn__c=Date.today();
        opp.Original_Opportunity__c=null;
        opp.Annual_Contract_Value__c=1000.00;
        opp.Business_Type__c='New customer: subscription';
        opp.CurrencyISOCode='GBP';
        opp.RecordTypeID=System.label.StandardRecordType;
        opp.Forecast_Category__c='Pipeline';//Forecast
        opp.Multi_YearDeal__c='1';
        opp.Offering__c='OPQ';
        opp.Talent_Segment__c='Volume';
        opp.TM_Phase__c='Post-Hire';
        //opp.contractid=contractRecord.id;
        insert opp;
        Contract contractRecord = TestDataUtility.getContract(accountRecord.id, opp.id);
        contractRecord.Payment_terms__c = '30 days';
        contractRecord.Run_Order_Creation_Flow__c=true;
        contractRecord.PDFCount__c = 1;
        contractRecord.CSVCount__c = 0;
        contractRecord.Product_Billing_Frequency__c = 'Monthly';
        INSERT contractRecord;
        
        ContentVersion cv2 = new ContentVersion();
        cv2.VersionData = Blob.valueOf('Hello');
        cv2.Title = '_ContractSheet.pdf';
         cv2.PathOnClient='/' + 'Test' + '.pdf'; 
        System.debug('Content Version cv '+cv2);
        insert cv2;
        
        System.debug('File Type ###'+cv2.FileType);
        
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv2.id].ContentDocumentId;
        cdl2.LinkedEntityId = contractRecord.id;
        cdl2.ShareType = 'V';
        insert cdl2;
        
        DELETE cdl2;
            
        Test.stopTest();
        
    }
    
    @isTest
    public static void documentAccessControlTest() {
        Test.startTest();
        Account accountRecord = TestDataUtility.getAccount();
        INSERT accountRecord;
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        Opportunity opp = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        opp.ownerid=UserInfo.getUserId();
        opp.StageName='proposal';
        opp.Closedate=system.today();
        opp.Primary_Contact__c=contactRecord.id;
        opp.Billing_Contact__c=contactRecord.id;
        opp.CurrencyIsoCode='AUD';
        opp.NVM_Credit_Card_ID__c='1234';
        opp.Amount=1000;
        opp.Variation_Opportunity__c='NO';
        opp.OppUpdatedByOrderOn__c=Date.today();
        opp.Original_Opportunity__c=null;
        opp.Annual_Contract_Value__c=1000.00;
        opp.Business_Type__c='New customer: subscription';
        opp.CurrencyISOCode='GBP';
        opp.RecordTypeID=System.label.StandardRecordType;
        opp.Forecast_Category__c='Pipeline';//Forecast
        opp.Multi_YearDeal__c='1';
        opp.MS_Opportunity__c = true;
        opp.Offering__c='OPQ';
        opp.Talent_Segment__c='Volume';
        opp.TM_Phase__c='Post-Hire';
        //opp.contractid=contractRecord.id;
        insert opp;
        Contract contractRecord = TestDataUtility.getContract(accountRecord.id, opp.id);
        contractRecord.Payment_terms__c = '30 days';
        contractRecord.Run_Order_Creation_Flow__c=true;
        contractRecord.PDFCount__c = 1;
        contractRecord.CSVCount__c = 0;
        contractRecord.Product_Billing_Frequency__c = 'Monthly';
        INSERT contractRecord;
        
        Order Ord=new order();
        Ord.OpportunityId = opp.Id;
        Ord.AccountId=accountRecord.id;
        Ord.ContractId=contractRecord.id;
        Ord.Order_Year__c = 1;
        Ord.Booked_Elsewhere__c = False;
        Ord.EffectiveDate=date.today();
        Ord.Submission_Offset__c = -18000000;
        //Ord.ActivatedDate =date.today();
        Ord.Activation_Offset__c = -18000000;
        Ord.Status='Draft';
        Ord.Pricebook2Id = '01s2000000000vQAAQ';
        Ord.Rejection_Reason__c='Rejecting request with a comment.';
        insert Ord;
        
        ContentVersion cv2 = new ContentVersion();
        cv2.VersionData = Blob.valueOf('Hello');
        cv2.Title = '_ContractSheet.pdf';
         cv2.PathOnClient='/' + 'Test' + '.pdf'; 
        System.debug('Content Version cv '+cv2);
        insert cv2;
        
        System.debug('File Type ###'+cv2.FileType);
        
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv2.id].ContentDocumentId;
        cdl2.LinkedEntityId = Ord.id;
        cdl2.ShareType = 'V';
        insert cdl2;
        
        DELETE cdl2;
            
        Test.stopTest();
        
    }
}