//Created by Prabhat Arora on 14-April-2025 to Cover the functionality in Apex Class "SendMailFromOpportunity"

@isTest
private class SendStageEmailClassTest {

    @testSetup
    static void setupTestData() {
        insert new Trigger_Activation__c(Name = 'Account_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'Contact_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'Opportunity_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'OpportunityContactRoleTrigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'Job_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'OpportunityLineItem_Trigger', Active__c = true);
    
        AutomaticJobCreation__c autoJobSettings = new AutomaticJobCreation__c(
            Name = 'Values',
            MS_Line_of_Business__c = 'Consulting,Delivery,Support'
        );
        insert autoJobSettings;
    
        Account acc = TestDataUtility.getAccount();
    
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'testcontact@example.com',
            AccountId = acc.Id
        );
        insert contact;
    
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Information Gathering',
            CloseDate = Date.today().addDays(30),
            Renewal_Date__c= Date.today().addDays(60),
            Price_Increase_Percentage__c=6,
            AccountId = acc.Id,
            Primary_Contact__c = contact.Id,
            Opportunity_Deal_Year__c=1,
            Price_Notification_Email_Bounced__c=true,
            Probability = 20
            
        );
        insert opp;
    
        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId = contact.Id,
            Role = 'Decision Maker',
            IsPrimary = true
        );
        insert ocr;
        
        Product2 p = new Product2(Name = 'Managed Service Product', isActive = true, MS_Type__c = 'Talent Management');
        insert p;
    
        Id standardPBId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = standardPBId, UnitPrice = 100, IsActive = true);
        insert pbe;
    
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 1,
            PricebookEntryId = pbe.Id,
            TotalPrice = 100
        );
        insert oli;
    }

    @isTest
    static void testSendEmailDirectly() {
        // INSERT SETUP OBJECT BEFORE startTest()
        EmailTemplate template = new EmailTemplate(
            Name = 'Test Email Template',
            DeveloperName = 'Test_Email_Template',
            TemplateType = 'custom',
            Subject = 'Test Email',
            HtmlValue = '<p>This is a test</p>',
            FolderId = UserInfo.getUserId(), // or a public folder ID if needed
            IsActive = true
        );
        insert template;
    
        // NON-SETUP LOGIC STARTS HERE
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    
        List<List<String>> oppIdList = new List<List<String>> {
            new List<String>{opp.Id}
        };
    
        Test.startTest();
        SendMailFromOpportunity.SendEmail(oppIdList);
        Test.stopTest();
    
        //System.assert(Limits.getEmailInvocations() > 0, 'Expected at least one email to be sent');
    }
}