@isTest
public class RenewalProductsChangesFromVariation_Test {
    
    @testSetup static void setup() {
        String valueFV = 'XTRAE-EMP,XTRAE-ASSOC,XTREL,DEB,FREIGHT';
        createFieldValueCustomSettingRecords(valueFV, 'Credit Note IM Codes');  
        
        createTriggerActivationCustomSettingRecords('User', 'User_Trigger');
        createTriggerActivationCustomSettingRecords('Campaign', 'Campaign_Trigger');
        createTriggerActivationCustomSettingRecords('Account', 'Account_Trigger');
        createTriggerActivationCustomSettingRecords('Contact', 'Contact_Trigger');
        createTriggerActivationCustomSettingRecords('Opportunity', 'Opportunity_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityLineItem', 'OpportunityLineItem_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityContactRole', 'OpportunityContactRoleTrigger');
        createTriggerActivationCustomSettingRecords('Contract', 'Contract_Trigger');
        createTriggerActivationCustomSettingRecords('Order', 'Order_Trigger');
        createTriggerActivationCustomSettingRecords('Job__c', 'Job_Trigger');
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Account accountRecord = TestDataUtility.getAccount();
        accountRecord.Industry = 'Education & Educational Services';
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        // Custom Setting for Auto Job creation
        AutomaticJobCreation__c cs = new AutomaticJobCreation__c();
        cs.Name='Values';
        cs.MS_Line_of_Business__c = 'TA - Corporate,Talent Management,TA - Credentialing';
        INSERT cs;
        
        Campaign campaignRecord = TestDataUtility.getCampaign();
        INSERT campaignRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        opportunityRecord.CampaignId = campaignRecord.Id;
        INSERT opportunityRecord;
        
        Id oppPriceBookId = [SELECT Pricebook2Id FROM Opportunity WHERE Id =: opportunityRecord.Id].Pricebook2Id;
        
        // First Product
        Product2 productRecord = TestDataUtility.getProduct2();
        productRecord.Revenue_Category__c='Managed Services';
        productRecord.Renewable__c = 'No';
        productRecord.MS_Product__c = true;
        productRecord.MS_Type__c = 'Talent Management';
        productRecord.Family = 'Services';
        INSERT productRecord;
        
        PricebookEntry pricebookEntryRecord1 = TestDataUtility.getPricebookEntry(productRecord.Id, 'GBP', pricebookId);
        INSERT pricebookEntryRecord1;
        
        PricebookEntry pricebookEntryRecord = TestDataUtility.getPricebookEntry(productRecord.Id, 'GBP', oppPriceBookId);
        INSERT pricebookEntryRecord;
        
        OpportunityLineItem originalOLI = new OpportunityLineItem(RenewableNew__c = 'Ongoing',
                                                        OpportunityId=opportunityRecord.Id,
                                                        PricebookEntryId=pricebookEntryRecord.Id,
                                                        TotalPrice=100,
                                                        Quantity=1,
                                                        Platform__c='iAssess',
                                                        Solution_Cap__c = 12,
                                                        Usage_Allowance__c='Capped', 
                                                        Usage_Cap_or_Estimation__c=1234,
                                                        Basis_of_Fees__c='Applications',
                                                        List_Price__c=100,
                                                        Proposition__c='Graduate Hiring',
                                                        Package__c='Graduate Advanced',
                                                        Product2Id = productRecord.Id);
        INSERT originalOLI;
        
        list<Opportunity> oppToInsert  = new list<Opportunity>();
        Opportunity opportunityRecord2 = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        opportunityRecord2.CampaignId = campaignRecord.Id;
        opportunityRecord2.Skip_Validation_Auto_Renewal__c = true;
        opportunityRecord2.Business_Type__c = 'Renewal';
        opportunityRecord2.Original_Opportunity__c = opportunityRecord.Id;
        oppToInsert.add(opportunityRecord2);
        
        Opportunity opportunityRecord3 = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        opportunityRecord3.CampaignId = campaignRecord.Id;
        opportunityRecord3.Variation_Opportunity__c = 'Yes';
        opportunityRecord3.Variation_Reason__c = 'Addition to order';
        opportunityRecord3.Original_Opportunity__c = opportunityRecord.Id;
        oppToInsert.add(opportunityRecord3);
        
        if(!oppToInsert.isEmpty())
        	INSERT oppToInsert;
        
        OpportunityLineItem placeholderOLI = new OpportunityLineItem(RenewableNew__c = 'Ongoing',
                                                        OpportunityId=opportunityRecord2.Id,
                                                        PricebookEntryId=pricebookEntryRecord.Id,
                                                        TotalPrice=100,
                                                        Quantity=1,
                                                        Platform__c='iAssess',
                                                        Solution_Cap__c = 12,
                                                        Usage_Allowance__c='Capped', 
                                                        Usage_Cap_or_Estimation__c=1234,
                                                        Basis_of_Fees__c='Applications',
                                                        List_Price__c=100,
                                                        Proposition__c='Graduate Hiring',
                                                        Package__c='Graduate Advanced',
                                                        Product2Id = productRecord.Id);
        INSERT placeholderOLI;
        
        OpportunityLineItem variationOLI = new OpportunityLineItem(RenewableNew__c = 'Ongoing',
                                                        OpportunityId=opportunityRecord3.Id,
                                                        PricebookEntryId=pricebookEntryRecord.Id,
                                                        TotalPrice=100,
                                                        Quantity=1,
                                                        Platform__c='iAssess',
                                                        Solution_Cap__c = 12,
                                                        Usage_Allowance__c='Capped', 
                                                        Usage_Cap_or_Estimation__c=1234,
                                                        Basis_of_Fees__c='Applications',
                                                        List_Price__c=100,
                                                        Proposition__c='Graduate Hiring',
                                                        Package__c='Graduate Advanced',
                                                        Product2Id = productRecord.Id);
        INSERT variationOLI;
        
    }
    
    public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        INSERT recordToInsert;
    }
    
    public static void createFieldValueCustomSettingRecords(String values, String customSettingName){
        Field_Value_Setting__c fVS = TestDataUtility.getFieldValueSetting(values, customSettingName);
        INSERT fVS;
    }
    
    @isTest
    static void testSyncVariationProductsOnPlaceholderOpp() {
        list<String> variationIds = new list<String>();
        
        Test.startTest();
        List<Opportunity> variationOpps = [SELECT Id, Business_Type__c, Original_Opportunity__c, FormalTender__c FROM Opportunity WHERE Variation_Opportunity__c = 'Yes' AND Variation_Reason__c = 'Addition to order'];
        
        for(Opportunity opp1 : variationOpps){
            variationIds.add(opp1.Id);
        }
        
        list<OpportunityLineItem> oliList = [Select Id,UnitPrice,OpportunityId,PricebookEntryId,RenewableNew__c,TotalPrice,Quantity,Platform__c,Solution_Cap__c,Usage_Allowance__c,Usage_Cap_or_Estimation__c,Basis_of_Fees__c,List_Price__c,Proposition__c,Package__c,Product2Id FROM OpportunityLineItem WHERE OpportunityId IN :variationIds];
        
        List<RenewalProductsChangesFromVariationOpp.InputValues> inputValuesList = new List<RenewalProductsChangesFromVariationOpp.InputValues>();
        RenewalProductsChangesFromVariationOpp.InputValues inputValues = new RenewalProductsChangesFromVariationOpp.InputValues();
        inputValues.opportunityData = variationOpps;
        inputValues.variationOLIData = oliList;
        inputValuesList.add(inputValues);
        RenewalProductsChangesFromVariationOpp.syncVariationProductsOnPlaceholderOpp(inputValuesList);
        Test.stopTest();
        
        // Assert that new OpportunityLineItems are created for the placeholder opportunity
        Opportunity placeholderOpp = [SELECT Id FROM Opportunity WHERE Business_Type__c = 'Renewal' LIMIT 1];
        List<OpportunityLineItem> placeholderLineItems = [SELECT Id, OpportunityId, UnitPrice, Item_Added_From__c FROM OpportunityLineItem WHERE OpportunityId = :placeholderOpp.Id];

        System.assert(!placeholderLineItems.isEmpty(), 'Placeholder Opportunity should have line items');
        
        // Assert that variation opportunities are marked as synced
        List<Opportunity> updatedVariationOpps = [SELECT Id, FormalTender__c FROM Opportunity WHERE Variation_Opportunity__c = 'Yes' AND Variation_Reason__c = 'Addition to order'];
        for (Opportunity opp : updatedVariationOpps) {
            System.assertEquals('Synced Variation', opp.FormalTender__c, 'Variation opportunities should be marked as Synced');
        }
    }
}