@isTest
public class ACR_RelationshipMapController_Test {

    @isTest(seeAlldata=true)
    static void setupTestData() {
        Account account = new Account(name = 'Test Contact Hierarchy Class',
                                      industry = 'Legal', Status__c = 'Approved',
                                      Billing_Address_Line_1__c = 'test', Billing_City__c = 'Test City',
                                      Billing_Country__c = 'India', Billing_State__c = 'Test',
                                      Billing_ZIP_Postal_Code__c = '1100110', BU__c = 'Australia - AU1', Buying_Centre_Id__c='aa');
        insert account;
        
        List<Contact> testContacts = new List<Contact>();
        for(Integer i=0;i<4;i++) {
            testContacts.add(new Contact(LastName = 'TestCon'+i,Email = 'TestCon'+i+'@'+'TestCon'+i+'.com',AccountId=account.Id));
        }
        insert testContacts;
        
        String influenceJson = '[{"id":"'+testContacts[0].id + '-' + testContacts[1].id +'","target":"'+testContacts[1].id + '","source":"'+testContacts[0].id+'" }]';
        
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
        opp.StageName = 'New';
        opp.GCSC__c = 'Phone';
        opp.OpportunityAmountMappedWithLead__c = 323.34; //**********
        opp.OpportunityTypeMappedWithLead__c = 'New Business'; //**********
        opp.Business_Type__c = 'Renewal';
        opp.Forecast_Category__c = 'Commit';
        opp.Multi_YearDeal__c = '1';
        opp.Opportunity_Deal_Year__c = 1;
        
        insert opp;
        
        List<OpportunityContactRole> contactRoleList = new List<OpportunityContactRole>();
        OpportunityContactRole contactRole = new OpportunityContactRole();
        
        contactRole.ContactId = testContacts[0].Id;
        contactRole.OpportunityId = opp.Id;
        
        insert contactRole;

        Opportunity opp1=
            new Opportunity(name = 'Test Opportunity', AccountID = account.id);
        opp1.Billing_Contact__c = testContacts[0].id;
        opp1.Closedate = system.today();
        opp1.Primary_Contact__c = testContacts[0].id;
        opp1.CurrencyIsoCode = 'AUD';
        opp1.Unconfirmed_Sun_Order_Number__c = '1234';
        opp1.NVM_Credit_Card_ID__c = '1234';
        opp1.Amount = 1000;
        opp1.Variation_Opportunity__c = 'No';
        opp1.Original_Opportunity__c = null;
        opp1.Annual_Contract_Value__c = 1000.00;
        opp1.StageName = 'Closed Lost';
        opp1.GCSC__c = 'Phone';
        opp1.OpportunityAmountMappedWithLead__c = 323.34; //**********
        opp1.OpportunityTypeMappedWithLead__c = 'New Business'; //**********
        opp1.Business_Type__c = 'Renewal';
        opp1.Forecast_Category__c = 'Commit';
        opp1.Multi_YearDeal__c = '1';
        opp1.Opportunity_Deal_Year__c = 1;
        
        insert opp1;
        
        OpportunityContactRole contactRole1= new OpportunityContactRole();
        
        contactRole1.ContactId = testContacts[2].Id;
        contactRole1.OpportunityId = opp1.Id;
        
        insert contactRole1;
        Test.startTest();
        String hierarchyInformationId = ACR_RelationshipMapController.createHierarchyOnAccount(account.Id, 'Test Hierarchy');
        Hierarchy_Information__c hierarchyInformation = [SELECT Id, Account__c FROM Hierarchy_Information__c WHERE Id = :hierarchyInformationId LIMIT 1];
        ACR_RelationshipMapController.HierarchyDetails hierarchyDetails = ACR_RelationshipMapController.getHierarchyDetails(hierarchyInformationId);
        
        ACR_RelationshipMapController.HierarchyWrapper placeholder = new ACR_RelationshipMapController.HierarchyWrapper();
        placeholder.IsPlaceholder = true;
        placeholder.Name = 'Test';
        placeholder.Id = 'Placeholder1';
        placeholder.ReportsTo = 'rootlevel';
        placeholder.Children = new List<ACR_RelationshipMapController.HierarchyWrapper>();
        
        ACR_RelationshipMapController.HierarchyWrapper contactInMap = new ACR_RelationshipMapController.HierarchyWrapper();
        contactInMap.IsPlaceholder = false;
        contactInMap.Name = testContacts[0].Name;
        contactInMap.Id = testContacts[0].Id;
        contactInMap.ReportsTo = 'rootlevel';
        contactInMap.Children = new List<ACR_RelationshipMapController.HierarchyWrapper>();

        hierarchyDetails.HierarchyList.add(placeholder);
        hierarchyDetails.HierarchyList.add(contactInMap);
        
        list<ACR_RelationshipMapController.ContactWrapper> listOfcontactWrapper1 = new list<ACR_RelationshipMapController.ContactWrapper>();
        ACR_RelationshipMapController.ContactWrapper contactWrapper1= new ACR_RelationshipMapController.ContactWrapper();
        contactWrapper1.firstName = 'ceofirstname';
        contactWrapper1.lastName = 'ceolastname';
        contactWrapper1.email = 'ceofirstname@test.com';
        contactWrapper1.phone = '9876543211';
        contactWrapper1.persona = 'Other';
        contactWrapper1.title = 'CEO';
        contactWrapper1.advocacyLevel = 'Weak';
        contactWrapper1.areaOfInterest = 'Training';
        contactWrapper1.jobFunction = 'Talent Management';
        contactWrapper1.accountId = account.Id;
        
        listOfcontactWrapper1.add(contactWrapper1);
        
        // Creating an instance using the parameterized constructor
        ACR_RelationshipMapController.ContactWrapper contactWrapper09 = new ACR_RelationshipMapController.ContactWrapper(
            1, '003XXXXXXXXXXXX', null, 'John', 'Doe', '001XXXXXXXXXXXX', 'john.doe@example.com', 'Manager', 'Advocate', 'CEO', 'Admin', '1234567890', 'Influencer', 'Technology'
        );
        
        // Creating child instances
        List<ACR_RelationshipMapController.HierarchyWrapper> childList = new List<ACR_RelationshipMapController.HierarchyWrapper>{
            new ACR_RelationshipMapController.HierarchyWrapper('002XXXXXXXXXXXX', 'Child 1', '001XXXXXXXXXXXX', true, null),
            new ACR_RelationshipMapController.HierarchyWrapper('003XXXXXXXXXXXX', 'Child 2', '001XXXXXXXXXXXX', false, null)
        };
        
        // Creating a parent instance using the parameterized constructor
        ACR_RelationshipMapController.HierarchyWrapper hierarchyWrapper09 = new ACR_RelationshipMapController.HierarchyWrapper('001XXXXXXXXXXXX', 'Parent', null, true, childList);
       
        
        ACR_RelationshipMapController.ContactWrapper contactWrapper11= new ACR_RelationshipMapController.ContactWrapper();
        contactWrapper11.firstName = 'chrofirstname';
        contactWrapper11.lastName = 'chrolastname';
        contactWrapper11.email = 'chrofirstname@test.com';
        contactWrapper11.phone = '9876543211';
        contactWrapper11.persona = 'Head of TM';
        contactWrapper11.title = 'CHRO';
        contactWrapper11.advocacyLevel = 'None';
        contactWrapper11.areaOfInterest = 'Training';
        contactWrapper11.jobFunction = 'Talent Management';
        contactWrapper11.accountId = account.Id;
        
        list<ACR_RelationshipMapController.ContactWrapper> listOfcontactWrapper = new list<ACR_RelationshipMapController.ContactWrapper>();
        ACR_RelationshipMapController.ContactWrapper contactWrapper = new ACR_RelationshipMapController.ContactWrapper();
        contactWrapper.id = testContacts[2].Id;
        contactWrapper.persona = 'Head of TM';
        listOfcontactWrapper.add(contactWrapper);
        
        list<ACR_RelationshipMapController.ContactWrapper> listOfcontactWrapper01 = new list<ACR_RelationshipMapController.ContactWrapper>();
        ACR_RelationshipMapController.ContactWrapper contactWrapper01 = new ACR_RelationshipMapController.ContactWrapper();
        contactWrapper01.id = testContacts[3].Id;
        contactWrapper01.persona = 'Head of TM';
        listOfcontactWrapper01.add(contactWrapper01);
        
        ACR_RelationshipMapController.ContactWrapper contactWrapper2 = new ACR_RelationshipMapController.ContactWrapper();
        contactWrapper2.id = testContacts[3].Id;
        contactWrapper2.role = 'Other';
        
        Contact conToReplace = new Contact();
        conToReplace.LastName = 'Hierarchy'+System.Now();
        ACR_RelationshipMapController.updateHierarchyOnPlaceholderCreation(hierarchyDetails.HierarchyList, hierarchyInformationId);
        ACR_RelationshipMapController.updateHierarchyOnExistingContactSelection(listOfcontactWrapper, hierarchyInformation.Account__c, hierarchyInformationId, 'rootlevel', hierarchyDetails.HierarchyList);
        ACR_RelationshipMapController.updateHierarchyOnExistingContactSelection(listOfcontactWrapper, hierarchyInformation.Account__c, hierarchyInformationId, testContacts[2].Id, hierarchyDetails.HierarchyList);
        
        ACR_RelationshipMapController.HierarchyDetails hierarchyDetails01 = ACR_RelationshipMapController.getHierarchyDetails(hierarchyInformationId);
        ACR_RelationshipMapController.HierarchyWrapper placeholder01 = new ACR_RelationshipMapController.HierarchyWrapper();
        placeholder01.IsPlaceholder = true;
        placeholder01.Name = 'Test';
        placeholder01.Id = 'Placeholder1';
        placeholder01.ReportsTo = testContacts[2].Id;
        placeholder01.Children = new List<ACR_RelationshipMapController.HierarchyWrapper>();
        hierarchyDetails01.HierarchyList.add(placeholder01);
        ACR_RelationshipMapController.updateHierarchyOnPlaceholderCreation(hierarchyDetails.HierarchyList, hierarchyInformationId);
        ACR_RelationshipMapController.updateInfluenceJSON(influenceJson, hierarchyInformationId);
        ACR_RelationshipMapController.updateConflictJSON(influenceJson, hierarchyInformationId);
        ACR_RelationshipMapController.GetContactWrapper conWrapper00 = ACR_RelationshipMapController.getActiveContacts(0, '', new list<String>{testContacts[0].Id}, account.Id,true, null);
        ACR_RelationshipMapController.GetContactWrapper conWrapper01 = ACR_RelationshipMapController.getActiveContacts(0, 'ceo', new list<String>{testContacts[0].Id}, account.Id,true, null);
        //ACR_RelationshipMapController.GetContactWrapper conWrapper02 = ACR_RelationshipMapController.getActiveContacts(0, 'ceo', new list<String>{testContacts[0].Id}, account.Id,false, null);
        ACR_RelationshipMapController.GetContactWrapper conWrapper03 = ACR_RelationshipMapController.getActiveContacts(0, '', new list<String>{testContacts[0].Id}, account.Id,false, 'aa');
        ACR_RelationshipMapController.GetContactWrapper conWrapper04 = ACR_RelationshipMapController.getActiveContacts(0, 'ceo', new list<String>(), account.Id,true, 'aa');
        ACR_RelationshipMapController.createContactRecords(listOfcontactWrapper1, hierarchyInformation.Account__c, hierarchyInformationId, 'rootlevel', hierarchyDetails.HierarchyList);
        ACR_RelationshipMapController.getListOfRelationships(account.Id);
        ACR_RelationshipMapController.updateAdvocacyLevelOnContact('Weak', hierarchyDetails.HierarchyList, hierarchyInformationId, testContacts[0].Id);
        ACR_RelationshipMapController.updateRelationshipMapOnReplace(hierarchyDetails.HierarchyList, hierarchyInformationId, testContacts[0].Id, conToReplace, new list<Contact>{testContacts[0]}, testContacts[0].Id);
        ACR_RelationshipMapController.updateInfluenceJSON(influenceJson, hierarchyInformationId);
        ACR_RelationshipMapController.updateConflictJSON(influenceJson, hierarchyInformationId);
        ACR_RelationshipMapController.updateRelationshipMap(hierarchyDetails.HierarchyList, hierarchyInformationId,testContacts[0].Id);
        ACR_RelationshipMapController.updateEconomicBuyerOrIOPsychologistStatus(testContacts[0].Id, account.Id, 'Add','Economic Buyer');
        ACR_RelationshipMapController.updateEconomicBuyerOrIOPsychologistStatus(testContacts[0].Id, account.Id, 'Remove','Economic Buyer');
        ACR_RelationshipMapController.updateEconomicBuyerOrIOPsychologistStatus(testContacts[0].Id, account.Id, 'Add','IO Psychologist');
        ACR_RelationshipMapController.updateEconomicBuyerOrIOPsychologistStatus(testContacts[0].Id, account.Id, 'Remove','IO Psychologist');
        ACR_RelationshipMapController.insertNote('Note 1', testContacts[0].Id);
        ACR_RelationshipMapController.updateNote('Note 1', testContacts[0].Id);
        ACR_RelationshipMapController.getNote(testContacts[0].Id);
        ACR_RelationshipMapController.renameHierarchy('New Hierarchy', hierarchyInformationId);
        //ACR_RelationshipMapController.ActivityAndAddressWrapper activityAndAddress = ACR_RelationshipMapController.getActivityMetricData(testContacts[0].Id);
        ACR_RelationshipMapController.updateInfluenceJSON(influenceJson, hierarchyInformationId);
        ACR_RelationshipMapController.updateConflictJSON(influenceJson, hierarchyInformationId);
        ACR_RelationshipMapController.getInfluenceAndConflictDetails(hierarchyInformationId);
		ACR_RelationshipMapController.deleteInfluenceConflictLine(hierarchyInformationId, testContacts[0].Id + '-' + testContacts[1].Id, 'Influence');
        ACR_RelationshipMapController.deleteInfluenceConflictLine(hierarchyInformationId, testContacts[0].Id + '-' + testContacts[1].Id, 'Conflict');
        
        Opportunity oppToUpdate = new Opportunity();
        oppToUpdate.Id = opp.Id;
        oppToUpdate.StageName = System.Label.Opportunity_Stage_7;
        oppToUpdate.CloseDate = System.Today();
        update oppToUpdate;
       
        
        ACR_RelationshipMapController.getHierarchyDetails(hierarchyInformationId);
        
		ACR_RelationshipMapController.deleteHierarchy(hierarchyInformationId);

        Test.stopTest();
    }
}