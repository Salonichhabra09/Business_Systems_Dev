@IsTest
public class Account_Contacts_Hierarchy_Test {
    
    @IsTest(seeAlldata=true)
    static void testGetContacts() {
        // Test data setup
        Account acc= new Account();
            acc.Name='Test234';
            acc.BU__c='UK - UK1';
            acc.CurrencyIsoCode='GBP'; 
            acc.Industry='Agriculture';
            acc.Billing_Address_Line_1__c='test23';
            acc.Billing_City__c='test23';
            acc.Same_As_The_Billing_Address__c=true;
            acc.Billing_Country__c='test23';
            acc.Billing_State__c='test23';
            acc.Billing_ZIP_Postal_Code__c='test23'; 
        insert acc;

        Contact con = new Contact(AccountId=acc.Id, 
                                  FirstName='Test', 
                                  LastName='Contact', 
                                  Contact_Status__c='Active', 
                                  Last_Activity_Happen__c = System.today());
        insert con;

        Account_Plan__c accPlan = new Account_Plan__c(Account_Name__c=acc.Id, Who_did_we_last_meet_in_the_organisation__c = con.Id,Account_Plan_Type__c='Global');
        insert accPlan;
        
        //Opportunity opp = new Opportunity(Name='Test Opportunity', 
                                          //StageName='Prospecting', 
                                          //CloseDate=System.today(), 
                                          //AccountId=acc.Id);
        
        Opportunity opp = CreateTestData.getOpportunity(acc.Id,con.Id);
        //insert opp;

        OpportunityContactRole oppConRole = new OpportunityContactRole(ContactId=con.Id, 
                                                                       OpportunityId=opp.Id);
        insert oppConRole;
        
        AccountContactRelation acr = [SELECT id, Roles, ContactId, AccountId 
                                      FROM AccountContactRelation 
                                      WHERE AccountId =: acc.Id 
                                      AND ContactId =: con.Id];
        
        Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = accPlan.Id, 
                                                               Business_Problem_Addressed__c = 'Test', 
                                                               Estimated_Completion_Date__c = System.today(), 
                                                               Solution_Goal__c = 'Goal', 
                                                               Solution_Product_Area__c = 'Training', 
                                                               Strategy_Type__c = 'Product Migration',
                                                               Strategy_Name__c = 'Test', 
                                                               Strategy_Status__c = 'In Progress',
                                                               Account_Contact_Relations__c = acr.Id);
        insert stgoal;
        
        // Test method call
        Test.startTest();
         Account_Contacts_Hierarchy.getContactHierarchyDetails(acc.Id, accPlan.Id);
        Test.stopTest();
    }
    
    @IsTest(seeAlldata=true)
    static void testHasChildren() {
        // Test data setup
        Account acc= new Account();
            acc.Name='Test234';
            acc.BU__c='UK - UK1';
            acc.CurrencyIsoCode='GBP'; 
            acc.Industry='Agriculture';
            acc.Billing_Address_Line_1__c='test23';
            acc.Billing_City__c='test23';
            acc.Same_As_The_Billing_Address__c=true;
            acc.Billing_Country__c='test23';
            acc.Billing_State__c='test23';
            acc.Billing_ZIP_Postal_Code__c='test23';   
        insert acc;

        Contact parentCon = new Contact(AccountId=acc.Id, FirstName='Parent', LastName='Contact', Contact_Status__c='Active');
        insert parentCon;

        Contact childCon = new Contact(AccountId=acc.Id, FirstName='Child', LastName='Contact', ReportsToId=parentCon.Id, Contact_Status__c='Active');
        insert childCon;
        
        List<Contact> conList = new List<Contact>();
        conList.add(parentCon);
        conList.add(childCon);

        // Test method call
        Test.startTest();
        Integer result = Account_Contacts_Hierarchy.hasChildren(acc.Id,parentCon.Id ,conList);
        Test.stopTest();
    }
    
    @IsTest(seeAlldata=true)
    static void testGetContactOpportunities() {
        // Test data setup
        Account acc= new Account();
        acc.Name='Test234';
        acc.BU__c='UK - UK1';
        acc.CurrencyIsoCode='GBP'; 
        acc.Industry='Agriculture';
        acc.Billing_Address_Line_1__c='test23';
        acc.Billing_City__c='test23';
        acc.Same_As_The_Billing_Address__c=true;
        acc.Billing_Country__c='test23';
        acc.Billing_State__c='test23';
        acc.Billing_ZIP_Postal_Code__c='test23'; 
        insert acc;

        Contact con = new Contact(AccountId=acc.Id, FirstName='Test', LastName='Contact', Contact_Status__c='Active');
        insert con;

        //Opportunity opp = new Opportunity(Name='Test Opportunity', StageName='Prospecting', CloseDate=System.today(), AccountId=acc.Id);
        //insert opp;
        Opportunity opp = CreateTestData.getOpportunity(acc.Id,con.Id);

        OpportunityContactRole oppConRole = new OpportunityContactRole(ContactId=con.Id, OpportunityId=opp.Id);
        insert oppConRole;

        // Test method call
        Test.startTest();
        List<Account_Contacts_Hierarchy.wrapContactOpportunity> result = Account_Contacts_Hierarchy.getContactOpportunities(con.Id, acc.Id);
        Test.stopTest();

    }
    
    @IsTest(seeAlldata=true)
    static void testGetContactStrategies() {
        // Test data setup
        Account acc= new Account();
        acc.Name='Test234';
        acc.BU__c='UK - UK1';
        acc.CurrencyIsoCode='GBP'; 
        acc.Industry='Agriculture';
        acc.Billing_Address_Line_1__c='test23';
        acc.Billing_City__c='test23';
        acc.Same_As_The_Billing_Address__c=true;
        acc.Billing_Country__c='test23';
        acc.Billing_State__c='test23';
        acc.Billing_ZIP_Postal_Code__c='test23'; 
        insert acc;

        Contact con = new Contact(AccountId=acc.Id, FirstName='Test', LastName='Contact', Contact_Status__c='Active');
        insert con;

        Account_Plan__c accPlan = new Account_Plan__c(Account_Name__c=acc.Id);
        insert accPlan;
        
        AccountContactRelation acr = [SELECT id, Roles, ContactId, AccountId 
                                      FROM AccountContactRelation 
                                      WHERE AccountId =: acc.Id 
                                      AND ContactId =: con.Id];
        
        Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = accPlan.Id, 
                                                               Business_Problem_Addressed__c = 'Test', 
                                                               Estimated_Completion_Date__c = System.today(), 
                                                               Solution_Goal__c = 'Goal', 
                                                               Solution_Product_Area__c = 'Training', 
                                                               Strategy_Type__c = 'Product Migration',
                                                               Strategy_Name__c = 'Test', 
                                                               Strategy_Status__c = 'In Progress',
                                                              Account_Contact_Relations__c = acr.Id);
        insert stgoal;
        
        //Strategy_and_Goal__c strat = [SELECT Id, Name,  FROM Strategy_and_Goal__c WHERE Id =: stgoal.Id];
        
        
        //acr.Strategies__c = strat.Name;
        //update acr;
        //AccountContactRelation acr = new AccountContactRelation(AccountId = acc.Id, ContactId = con.Id, Strategies__c = strat.Name);
        //insert acr;
        
        // Test method call
        Test.startTest();
        List<Account_Contacts_Hierarchy.wrapContactStrategy> result = Account_Contacts_Hierarchy.getContactStrategies(con.Id, acc.Id, accPlan.Id);
        Test.stopTest();
    }
    
    @IsTest(seeAlldata=true)
    static void testCreateContact() {
        // Test data setup
        Account acc= new Account();
            acc.Name='Test234';
            acc.BU__c='UK - UK1';
            acc.CurrencyIsoCode='GBP'; 
            acc.Industry='Agriculture';
            acc.Billing_Address_Line_1__c='test23';
            acc.Billing_City__c='test23';
            acc.Same_As_The_Billing_Address__c=true;
            acc.Billing_Country__c='test23';
            acc.Billing_State__c='test23';
            acc.Billing_ZIP_Postal_Code__c='test23'; 
        insert acc;
        
        Contact originalContact = new Contact(
            AccountId = acc.Id,
            LastName = 'Original Contact',
            Contact_Status__c = 'Active'
        );
        insert originalContact;
        
        Contact originalContactChild = new Contact(
            AccountId = acc.Id,
            LastName = 'Original Contact Child',
            Contact_Status__c = 'Active',
            ReportsToId = originalContact.Id
        );
        insert originalContactChild;
        
        Contact newContact = new Contact(
            AccountId = acc.Id,
            LastName = 'New Contact',
            Contact_Status__c = 'Active'
        );
        
        Contact newContact2 = new Contact(
            AccountId = acc.Id,
            LastName = 'New2 Contact2',
            Contact_Status__c = 'Active'
        );
        //Change Prachi SSE-21273
         Contact newContact3 = new Contact(
            AccountId = acc.Id,
            LastName = 'New Contact',
            Contact_Status__c = 'Active'
        );
        Contact newContact4 = new Contact(
            AccountId = acc.Id,
            LastName = 'New Contact',
            Contact_Status__c = 'Active'
        );
        String buttonType = 'Contact';
        Boolean isRootLevel = false;
        //Change End SSE-21273
        
        // Test method call to create a child contact
       Test.startTest();
       String result = Account_Contacts_Hierarchy.createContact(newContact, originalContact.Id , buttonType ,false);//Change Prachi SSE-21273
       String result2 = Account_Contacts_Hierarchy.createContact(newContact2, '' ,  buttonType ,false);//Change Prachi SSE-21273
       String result3 = Account_Contacts_Hierarchy.createContact(newContact3, originalContact.Id , 'Account' ,true);//Change Prachi SSE-21273
       String result4 = Account_Contacts_Hierarchy.createContact(newContact4, '' ,  'Account' ,true);//Change Prachi SSE-21273  
       Test.stopTest();
        
    }
    
    @IsTest(seeAlldata=true)
    static void testReparentContact() {
        // Test data setup
        Account acc= new Account();
            acc.Name='Test234';
            acc.BU__c='UK - UK1';
            acc.CurrencyIsoCode='GBP'; 
            acc.Industry='Agriculture';
            acc.Billing_Address_Line_1__c='test23';
            acc.Billing_City__c='test23';
            acc.Same_As_The_Billing_Address__c=true;
            acc.Billing_Country__c='test23';
            acc.Billing_State__c='test23';
            acc.Billing_ZIP_Postal_Code__c='test23'; 
        insert acc;
        
        Contact originalContact = new Contact(
            AccountId = acc.Id,
            LastName = 'Original Contact',
            Contact_Status__c = 'Active'
        );
        insert originalContact;
        
        Contact newReportsToContact = new Contact(
            AccountId = acc.Id,
            LastName = 'New ReportsTo Contact',
            Contact_Status__c = 'Active'
        );
        insert newReportsToContact;
        
        // Test method call to reparent the contact
        Test.startTest();
        String result = Account_Contacts_Hierarchy.reparentContact(originalContact.Id, newReportsToContact.Id , false);//Added by Prachi SSE-21273
        String result1 = Account_Contacts_Hierarchy.reparentContact('123', newReportsToContact.Id,false);//Added by Prachi SSE-21273
         String result2 = Account_Contacts_Hierarchy.reparentContact(originalContact.Id, newReportsToContact.Id , true);//Added by Prachi SSE-21273
        Test.stopTest();
        
    }
    
    //Added by Prachi SSE-21273
     @IsTest(seeAlldata=true)
    static void testgetActiveContacts(){
        List<contact> conList = new List<contact>();
         List<id> idList = new List<id>();
        Test.startTest();
         Account acc= new Account();
            acc.Name='Test234';
            acc.BU__c='UK - UK1';
            acc.CurrencyIsoCode='GBP'; 
            acc.Industry='Agriculture';
            acc.Billing_Address_Line_1__c='test23';
            acc.Billing_City__c='test23';
            acc.Same_As_The_Billing_Address__c=true;
            acc.Billing_Country__c='test23';
            acc.Billing_State__c='test23';
            acc.Billing_ZIP_Postal_Code__c='test23'; 
        insert acc;
        
        Contact originalContactChild = new Contact(
            AccountId = acc.Id,
            LastName = 'Original Contact Child',
            Contact_Status__c = 'Active'
        );
        insert originalContactChild;
        
        for(Integer i=0;i<=10;i++){
             Contact newContact4 = new Contact(
            AccountId = acc.Id,
            LastName = 'New Contact'+i,
            Contact_Status__c = 'Active'
        );
            conList.add(newContact4);
        }
        
         for(Integer i=0;i<=10;i++){
            Contact newContact4 = new Contact(
            AccountId = acc.Id,
            LastName = 'New Contact Reports To' + i,
            Contact_Status__c = 'Active',
            ReportsToId = originalContactChild.id 
        );
            conList.add(newContact4);
        }
        
         for(Integer i=0;i<=10;i++){
            Contact newContact4 = new Contact(
            AccountId = acc.Id,
            LastName = 'New Contact Reports To' + i,
            Contact_Status__c = 'Active',
            is_Root_Level_Contact__c = true
        );
            conList.add(newContact4);
        }
        
        insert conList;
        
        for(Contact c: conList){
            idList.add(c.id);
        }
        
         Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft',
                                                Date_of_Last_Plan_Review__c=system.today() - 6);
        insert ap;
        
        Account_Contacts_Hierarchy.getContacts(acc.id , ap.id);
        Account_Contacts_Hierarchy.ContactHierarchyWrapper chw = new Account_Contacts_Hierarchy.ContactHierarchyWrapper();
        chw = Account_Contacts_Hierarchy.getActiveContacts(ap.id, '', acc.id, 'Account');
        chw = Account_Contacts_Hierarchy.getActiveContacts(ap.id, originalContactChild.id , acc.id, 'Contact');
        Account_Contacts_Hierarchy.updateReportsToId(originalContactChild.id , idList , 'Contact');
        Account_Contacts_Hierarchy.updateReportsToId('' , idList , 'Account');
        Test.stopTest();
    }
}