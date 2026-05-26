@isTest
class OpportunityContactHierarchy_Test {
    
    @isTest(seeAlldata=true)
    static void testCreateHierarchy() {
        Account account = new Account(name = 'Test Contact Hierarchy Class',
                                      industry = 'Legal', Status__c = 'Approved',
                                      Billing_Address_Line_1__c = 'test', Billing_City__c = 'Test City',
                                      Billing_Country__c = 'India', Billing_State__c = 'Test',
                                      Billing_ZIP_Postal_Code__c = '1100110', BU__c = 'Australia - AU1');
        insert account;
        
        List<Contact> testContacts = new List<Contact>();
        for(Integer i=0;i<4;i++) {
            testContacts.add(new Contact(LastName = 'TestCon'+i,Email = 'TestCon'+i+'@'+'TestCon'+i+'.com',AccountId=account.Id));
        }
        insert testContacts;
        
        Opportunity opp =
            new Opportunity(name = 'Test Opportunity', AccountID = account.id);
        opp.Billing_Contact__c = testContacts[0].id;
        opp.Closedate = system.today();
        opp.Primary_Contact__c = testContacts[0].id;
        opp.CurrencyIsoCode = 'AUD';
        opp.Unconfirmed_Sun_Order_Number__c = '1234';
        opp.NVM_Credit_Card_ID__c = '1234';
        opp.Amount = 1000;
        opp.Variation_Opportunity__c = 'No';
        opp.Original_Opportunity__c = null;
        opp.Annual_Contract_Value__c = 1000.00;
        opp.StageName = 'Closed Won';
        opp.GCSC__c = 'Phone';
        opp.OpportunityAmountMappedWithLead__c = 323.34; //**********
        opp.OpportunityTypeMappedWithLead__c = 'New Business'; //**********
        opp.Business_Type__c = 'Renewal';
        opp.Forecast_Category__c = 'Commit';
        opp.Multi_YearDeal__c = '1';
        opp.Opportunity_Deal_Year__c = 1;
        
        insert opp;
        
        
        String hierarchyInformationId = OpportunityContactHierarchy.createHierarchyOnOpportunity(opp.Id, 'Default Heirarchy');
        
        Hierarchy_Information__c hierarchyInformation = [SELECT Id FROM Hierarchy_Information__c WHERE Id =:hierarchyInformationId];
        
        OpportunityContactHierarchy.HierarchyDetails hierarchyDetails = OpportunityContactHierarchy.getHierarchyDetails(hierarchyInformationId);
        
        OpportunityContactHierarchy.getHierarchyInformationOfOpportunity(opp.Id);
        
        OpportunityContactHierarchy.HierarchyWrapper placeholder = new OpportunityContactHierarchy.HierarchyWrapper();
        placeholder.IsPlaceholder = true;
        placeholder.Name = 'Test';
        placeholder.Id = 'Placeholder1';
        placeholder.ReportsTo = 'rootlevel';
        placeholder.Children = new List<OpportunityContactHierarchy.HierarchyWrapper>();

        hierarchyDetails.HierarchyList.add(placeholder);
        
        Contact conToReplace = new Contact();
        conToReplace.LastName = 'Hierarchy'+System.Now();
        
        
        OpportunityContactHierarchy.updateHierarchyOnPlaceholderCreation(hierarchyDetails.HierarchyList, hierarchyInformationId);
        
        OpportunityContactHierarchy.updateHierarchyOnDelete(hierarchyDetails.HierarchyList, hierarchyInformationId, new List<Contact>(), testContacts[1].Id);
        
        OpportunityContactHierarchy.updateHierarchyOnReplace(hierarchyDetails.HierarchyList, hierarchyInformationId, testContacts[0].Id, conToReplace, new list<Contact>{testContacts[0]}, null, 'Influencer;Decision Maker');

        OpportunityContactHierarchy.updateHierarchyOnReparent(hierarchyDetails.HierarchyList, hierarchyInformationId, testContacts[0].Id, testContacts[1].Id, false, new list<Contact>{testContacts[0]});
        
        OpportunityContactHierarchy.deleteHierarchy(hierarchyInformationId);
        
        OpportunityContactHierarchy.ContactWrapper con = new OpportunityContactHierarchy.ContactWrapper(1,testContacts[0].Id , 'Mr', 'Test', 'Test', account.Id, testContacts[0].email, 'Test', 'Test', 'Test', 'Test', 'Test');
        OpportunityContactHierarchy.HierarchyWrapper hier = new OpportunityContactHierarchy.HierarchyWrapper('rootlevel', null, null, false, new List<OpportunityContactHierarchy.HierarchyWrapper>());
        //OpportunityContactHierarchy.updateHierarchyOnReparent(hierarchyDetails.HierarchyList, hierarchyInformationId, , , , );
        
    }
    
    @isTest(seeAlldata=true)
    static void testUpdateContactRole() {
        Account account = new Account(name = 'Test Contact Hierarchy Class',
                                      industry = 'Legal', Status__c = 'Approved',
                                      Billing_Address_Line_1__c = 'test', Billing_City__c = 'Test City',
                                      Billing_Country__c = 'India', Billing_State__c = 'Test',
                                      Billing_ZIP_Postal_Code__c = '1100110', BU__c = 'Australia - AU1');
        insert account;
        
        List<Contact> testContacts = new List<Contact>();
        for(Integer i=0;i<4;i++) {
            testContacts.add(new Contact(LastName = 'TestCon'+i,Email = 'TestCon'+i+'@'+'TestCon'+i+'.com',AccountId=account.Id));
        }
        insert testContacts;
        
        Opportunity opp =
            new Opportunity(name = 'Test Opportunity', AccountID = account.id);
        opp.Billing_Contact__c = testContacts[0].id;
        opp.Closedate = system.today();
        opp.Primary_Contact__c = testContacts[0].id;
        opp.CurrencyIsoCode = 'AUD';
        opp.Unconfirmed_Sun_Order_Number__c = '1234';
        opp.NVM_Credit_Card_ID__c = '1234';
        opp.Amount = 1000;
        opp.Variation_Opportunity__c = 'No';
        opp.Original_Opportunity__c = null;
        opp.Annual_Contract_Value__c = 1000.00;
        opp.StageName = 'Closed Won';
        opp.GCSC__c = 'Phone';
        opp.OpportunityAmountMappedWithLead__c = 323.34; //**********
        opp.OpportunityTypeMappedWithLead__c = 'New Business'; //**********
        opp.Business_Type__c = 'Renewal';
        opp.Forecast_Category__c = 'Commit';
        opp.Multi_YearDeal__c = '1';
        opp.Opportunity_Deal_Year__c = 1;
        
        insert opp;
            
        
        OpportunityContactRole newRole = new OpportunityContactRole(
            OpportunityId = opp.Id, 
            ContactId = testContacts[1].Id, 
            Role = 'Budget Holder'
        );
        insert newRole;
        
        String hierarchyInformationId = OpportunityContactHierarchy.createHierarchyOnOpportunity(opp.Id, 'Default Heirarchy');
        Hierarchy_Information__c hierarchyInformation = [SELECT Id, Opportunity__c FROM Hierarchy_Information__c WHERE Id =:hierarchyInformationId];
        OpportunityContactHierarchy.HierarchyDetails hierarchyDetails = OpportunityContactHierarchy.getHierarchyDetails(hierarchyInformationId);
        Test.startTest();
        OpportunityContactRole newRoleToCreate = new OpportunityContactRole(
            OpportunityId = opp.Id, 
            ContactId = testContacts[3].Id, 
            Role = 'Budget Holder'
        );
        OpportunityContactHierarchy.createContactRoleRecords(new list<OpportunityContactRole>{newRoleToCreate});
        list<OpportunityContactHierarchy.ContactWrapper> listOfcontactWrapper1 = new list<OpportunityContactHierarchy.ContactWrapper>();
        OpportunityContactHierarchy.ContactWrapper contactWrapper1= new OpportunityContactHierarchy.ContactWrapper();
        contactWrapper1.firstName = 'ceofirstname';
        contactWrapper1.lastName = 'ceolastname';
        contactWrapper1.email = 'ceofirstname@test.com';
        contactWrapper1.phone = '9876543211';
        contactWrapper1.role = 'Blocker';
        contactWrapper1.title = 'CEO';
        contactWrapper1.jobFunction = 'Talent Management';
        
        listOfcontactWrapper1.add(contactWrapper1);
        
        OpportunityContactHierarchy.ContactWrapper contactWrapper11= new OpportunityContactHierarchy.ContactWrapper();
        contactWrapper11.firstName = 'chrofirstname';
        contactWrapper11.lastName = 'chrolastname';
        contactWrapper11.email = 'chrofirstname@test.com';
        contactWrapper11.phone = '9876543211';
        contactWrapper11.role = 'Budget Holder;Influencer';
        contactWrapper11.title = 'CHRO';
        contactWrapper11.jobFunction = 'Talent Management';
        
        listOfcontactWrapper1.add(contactWrapper11);
        
        OpportunityContactHierarchy.createContactRecords(listOfcontactWrapper1, hierarchyInformation.Opportunity__c, hierarchyInformationId, 'rootlevel', hierarchyDetails.HierarchyList);
        
        list<OpportunityContactHierarchy.ContactWrapper> listOfcontactWrapper = new list<OpportunityContactHierarchy.ContactWrapper>();
        OpportunityContactHierarchy.ContactWrapper contactWrapper = new OpportunityContactHierarchy.ContactWrapper();
        contactWrapper.id = testContacts[2].Id;
        contactWrapper.role = 'Influencer;Budget Holder';
        listOfcontactWrapper.add(contactWrapper);
        
        OpportunityContactHierarchy.ContactWrapper contactWrapper2 = new OpportunityContactHierarchy.ContactWrapper();
        contactWrapper2.id = testContacts[3].Id;
        contactWrapper2.role = 'Blocker';
        
        listOfcontactWrapper.add(contactWrapper2);
        OpportunityContactHierarchy.updateHierarchyOnExistingContactSelection(listOfcontactWrapper, hierarchyInformation.Opportunity__c, hierarchyInformationId, 'rootlevel', hierarchyDetails.HierarchyList);
		OpportunityContactHierarchy.updateContactRole('Blocker', null, hierarchyDetails.HierarchyList, hierarchyInformationId, testContacts[0].Id);
        list<Opportunity> oppDetails = OpportunityContactHierarchy.getOpportunityDetails(opp.OpportunityId__c);
        OpportunityContactHierarchy.getActiveContacts(0, '', new list<String>{testContacts[0].Id}, account.Id,true);
        OpportunityContactHierarchy.getActiveContacts(0, 'ceo', new list<String>{testContacts[0].Id}, account.Id,true);
         Test.stopTest();
    }
    
    
}