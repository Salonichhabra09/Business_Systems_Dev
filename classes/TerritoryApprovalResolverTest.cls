@IsTest
public class TerritoryApprovalResolverTest {

    static Id oppId;

    @TestSetup
    static void setupData(){

        insert new List<Trigger_Activation__c>{
            new Trigger_Activation__c(Name='Account_Trigger',Active__c=true),
            new Trigger_Activation__c(Name='Task_Trigger',Active__c=true),
            new Trigger_Activation__c(Name='User_Trigger',Active__c=true),
            new Trigger_Activation__c(Name='Opportunity_Trigger',Active__c=true),
            new Trigger_Activation__c(Name='Territory_Trigger',Active__c=true)
        };

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

     User directorUser = new User(
    Alias='diru',
    Email='director@test.com',
    EmailEncodingKey='UTF-8',
    LastName='Director',
    LanguageLocaleKey='en_US',
    LocaleSidKey='en_US',
    ProfileId=p.Id,
    TimeZoneSidKey='Asia/Kolkata',
    UserName='director' + System.currentTimeMillis() + '@test.com'
);

User croUser = new User(
    Alias='crou',
    Email='cro@test.com',
    EmailEncodingKey='UTF-8',
    LastName='CRO',
    LanguageLocaleKey='en_US',
    LocaleSidKey='en_US',
    ProfileId=p.Id,
    TimeZoneSidKey='Asia/Kolkata',
    UserName='cro' + System.currentTimeMillis() + '@test.com'
);

User mdUser = new User(
    Alias='mdu',
    Email='md@test.com',
    EmailEncodingKey='UTF-8',
    LastName='MD',
    LanguageLocaleKey='en_US',
    LocaleSidKey='en_US',
    ProfileId=p.Id,
    TimeZoneSidKey='Asia/Kolkata',
    UserName='md' + System.currentTimeMillis() + '@test.com'
);
        User FBPUser = new User(
    Alias='FBP',
    Email='fbp@test.com',
    EmailEncodingKey='UTF-8',
    LastName='FBP',
    LanguageLocaleKey='en_US',
    LocaleSidKey='en_US',
    ProfileId=p.Id,
    TimeZoneSidKey='Asia/Kolkata',
    UserName='fbp' + System.currentTimeMillis() + '@test.com'
);
        User fbpDUser = new User(
    Alias='fbpD',
    Email='fbpD@test.com',
    EmailEncodingKey='UTF-8',
    LastName='fbpD',
    LanguageLocaleKey='en_US',
    LocaleSidKey='en_US',
    ProfileId=p.Id,
    TimeZoneSidKey='Asia/Kolkata',
    UserName='fbpD' + System.currentTimeMillis() + '@test.com'
);

insert new List<User>{directorUser, croUser, mdUser,FBPUser,fbpDUser};

Territory__c terr = new Territory__c(
    Name='Test Territory',
    Region__c='AMS',
    Commercial_Director__c = directorUser.Id,
    CRO__c = croUser.Id,
    MD__c = mdUser.Id,
    FBP_Team__c = FBPUser.Id,
    FBP_Director__c = fbpDUser.Id
);
insert terr;

        Account acc = new Account(
            Name='Test Account',
            BU__c='UK - UK1',
            CurrencyIsoCode='USD',
            Industry='Agriculture',
            Billing_Address_Line_1__c='Line1',
            Billing_City__c='City',
            Same_As_The_Billing_Address__c=true,
            Billing_Country__c='INDIA',
            Billing_State__c='State',
            Billing_ZIP_Postal_Code__c='Zip',
            Global_Billing_Country__c='AFGHANISTAN',
            Territory__c=terr.Id
        );
        
        insert acc;
        
        Opportunity originalOpp = new Opportunity(
            Name = 'Original Opp',
            AccountId = acc.Id,
            CloseDate = Date.today(),
            StageName = 'Prospecting',
            Amount = 20000000
        );
        insert originalOpp;

        Opportunity opp = new Opportunity(
            Name='Test Opportunity',
            AccountId=acc.Id,
            CloseDate=Date.today(),
            StageName='Prospecting',
            Amount=18000000,
            Products_Discount__c=10,
            Services_Discount__c=5,
            Business_Type__c='Renewal',
            Actual_Contract_Duration__c=12,
            Forecast_Category__c='Pipeline',
            Opportunity_Deal_Year__c=1,
            Renewal_Date__c = Date.newInstance(2026, 12, 12),
            Renewal_Opportunity__c=true,
             Original_Opportunity__c = originalOpp.Id
         
        );
        insert opp;
        acc = [SELECT Id, Territory__c FROM Account WHERE Id = :acc.Id];
        originalOpp = [SELECT Id FROM Opportunity WHERE Id = :originalOpp.Id];
        opp = [SELECT Id FROM Opportunity WHERE Id = :opp.Id];
		oppId = opp.Id;

    }


    private static TerritoryApprovalResolver.InputWrapper createInput(String status, String approverField,Id oppId){

        TerritoryApprovalResolver.InputWrapper input = new TerritoryApprovalResolver.InputWrapper();
        input.recordId = oppId;
        input.discountApprovalStatus = status;
        input.originalApprovers = approverField;

        return input;
    }


    @IsTest
    static void testSubmittedForApproval(){
	Opportunity opp = [Select id,Business_Type__c,Renewal_Opportunity__c, Renewal_Date__c,Opportunity_Deal_Year__c,Sales_Price_in_USD__c from opportunity limit 1];

        System.debug('DEBUGG FULL OPP1: ' + opp);
        
        TerritoryApprovalResolver.InputWrapper input =
            createInput('Submitted for Approval','Commercial_Director__c',opp.Id);

        List<TerritoryApprovalResolver.InputWrapper> inputs =
            new List<TerritoryApprovalResolver.InputWrapper>{input};

        Test.startTest();

        List<TerritoryApprovalResolver.OutputWrapper> result =
            TerritoryApprovalResolver.resolveApproval(inputs);

        Test.stopTest();

        System.assert(result.size() > 0);
    }


    @IsTest
    static void testEscalatedLevel1(){
	Opportunity opp = [Select id,Business_Type__c,Renewal_Opportunity__c, Renewal_Date__c,Opportunity_Deal_Year__c,Sales_Price_in_USD__c from opportunity limit 1];

        
        System.debug('DEBUGG FULL OPP2: ' + opp);
        
        TerritoryApprovalResolver.InputWrapper input =
            createInput('Escalated Level 1','CRO__c',opp.Id);

        List<TerritoryApprovalResolver.InputWrapper> inputs =
            new List<TerritoryApprovalResolver.InputWrapper>{input};

        Test.startTest();

        List<TerritoryApprovalResolver.OutputWrapper> result =
            TerritoryApprovalResolver.resolveApproval(inputs);

        Test.stopTest();

        System.assert(result.size() > 0);
    }


    @IsTest
    static void testEscalatedLevel2(){
	Opportunity opp = [Select id,Business_Type__c,Renewal_Opportunity__c, Renewal_Date__c,Opportunity_Deal_Year__c,Sales_Price_in_USD__c from opportunity limit 1];
       
        System.debug('DEBUGG FULL OPP3: ' + opp);
        
        TerritoryApprovalResolver.InputWrapper input =
            createInput('Escalated Level 2','MD__c',opp.Id);

        List<TerritoryApprovalResolver.InputWrapper> inputs =
            new List<TerritoryApprovalResolver.InputWrapper>{input};

        Test.startTest();

        List<TerritoryApprovalResolver.OutputWrapper> result =
            TerritoryApprovalResolver.resolveApproval(inputs);

        Test.stopTest();

        System.assert(result.size() > 0);
    }


    @IsTest
    static void testNullInput(){

        Test.startTest();

        List<TerritoryApprovalResolver.OutputWrapper> result =

            TerritoryApprovalResolver.resolveApproval(null);

        Test.stopTest();

        System.assertEquals(0,result.size());
    }
    @IsTest
static void testLowDecreaseScenario(){

	Opportunity opp = [Select id,Business_Type__c,Renewal_Opportunity__c, Renewal_Date__c,Opportunity_Deal_Year__c,Sales_Price_in_USD__c from opportunity limit 1];

    System.debug('DEBUGG FULL OPP4: ' + opp);
    TerritoryApprovalResolver.InputWrapper input =
        createInput(
            'Submitted for Approval',
            'MD__c;FBP_Director__c;FBP_Team__c',
            opp.Id
        );

    List<TerritoryApprovalResolver.InputWrapper> inputs =
        new List<TerritoryApprovalResolver.InputWrapper>{input};

    Test.startTest();

    List<TerritoryApprovalResolver.OutputWrapper> result =
        TerritoryApprovalResolver.resolveApproval(inputs);

    Test.stopTest();

    System.assertNotEquals(null, result[0].MD);
    System.assertNotEquals(null, result[0].FBPDirector);
    System.assertNotEquals(null, result[0].FBPTeam);
}
   
    

}