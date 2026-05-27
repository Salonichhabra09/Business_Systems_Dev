@isTest(SeeAllData=true)
private class OrderCancellationProjectTest {

    /*
     * Wrapper to return both Order and Project IDs
     */
    private class TestDataWrapper {
        Id orderId;
        Id projectId;
    }

    /*
     * Create minimal test data required for cancellation logic
     */
    private static TestDataWrapper createTestData() {

        TestDataWrapper wrapper = new TestDataWrapper();

        // Use existing Account to avoid Account trigger insert
        Account acc = [
            SELECT Id, CurrencyIsoCode
            FROM Account
            WHERE CurrencyIsoCode != null
            LIMIT 1
        ];

        System.assertNotEquals(null, acc, 'No Account found in org.');

        // Get Project RecordType
        Id projectRtId = Schema.SObjectType.ProjectObject__c
            .getRecordTypeInfosByName()
            .get('Project')
            .getRecordTypeId();

        // Create Project (Open)
        ProjectObject__c project = new ProjectObject__c(
            Project_Name__c = 'Test Project - Cancellation',
            RecordTypeId = projectRtId,
            Account__c = acc.Id,
            CurrencyIsoCode = acc.CurrencyIsoCode,
            Project_Status__c = 'Open'
        );
        insert project;

        wrapper.projectId = project.Id;

        // Standard Pricebook
        Id stdPbId = Test.getStandardPricebookId();

        // Create Order with Pricebook
        Order ord = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            CurrencyIsoCode = acc.CurrencyIsoCode,
            Pricebook2Id = stdPbId
        );
        insert ord;

        wrapper.orderId = ord.Id;

        // Create Product
        Product2 prod = new Product2(
            Name = 'Test Product - PS',
            IsActive = true,
            Revenue_Category__c = 'Professional Services'
        );
        insert prod;

        // Create Pricebook Entry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPbId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true,
            CurrencyIsoCode = acc.CurrencyIsoCode
        );
        insert pbe;

        // Create OrderItem linked to Project
        OrderItem oi = new OrderItem(
            OrderId = ord.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 2,
            UnitPrice = 100,
            Project__c = project.Id,
            Basis_of_Fees__c = 'LPS Days'
        );
        insert oi;

        return wrapper;
    }

    /*
     * TEST 1: Cancellation triggers recalculation
     */
    @isTest
    static void testOrderCancellationTriggersRollup() {

        TestDataWrapper data = createTestData();

        Order ord = [
            SELECT Id, Status
            FROM Order
            WHERE Id = :data.orderId
        ];

        Test.startTest();

        ord.Status = 'Cancelled';
        ord.Cancellation_Reason__c = 'Test Cancellation';
        update ord;

        Test.stopTest(); // Executes Queueable

        ProjectObject__c proj = [
            SELECT Order_Products_Count__c,
                   Total_Orderline_Value_RollUp__c,
                   Scoped_LPS_days_RollUp__c,OwnerId
            FROM ProjectObject__c
            WHERE Id = :data.projectId
        ];

        System.assertEquals(0, proj.Order_Products_Count__c,
            'Order product count should reset to zero.');

        System.assertEquals(0, proj.Total_Orderline_Value_RollUp__c,
            'Total rollup value should reset to zero.');

        System.assertEquals(0, proj.Scoped_LPS_days_RollUp__c,
            'LPS days rollup should reset to zero.');
    }

    /*
     * TEST 2: Completed project should NOT be updated
     */
    @isTest
    static void testCompletedProjectNotUpdated() {

        TestDataWrapper data = createTestData();

        ProjectObject__c proj = [
            SELECT Id, Project_Status__c,OwnerId
            FROM ProjectObject__c
            WHERE Id = :data.projectId
        ];

        proj.Project_Status__c = 'Completed';
        update proj;

        Order ord = [
            SELECT Id
            FROM Order
            WHERE Id = :data.orderId
        ];

        Test.startTest();

        ord.Status = 'Cancelled';
        ord.Cancellation_Reason__c = 'Test Cancellation';
        update ord;

        Test.stopTest();

        ProjectObject__c updatedProj = [
            SELECT Order_Products_Count__c,OwnerId
            FROM ProjectObject__c
            WHERE Id = :data.projectId
        ];

        System.assertEquals(null, updatedProj.Order_Products_Count__c,
            'Completed project should not be recalculated.');
    }
    
    @isTest
static void testRollupServiceWithActiveOrderItems() {

    // Create test data
    TestDataWrapper data = createTestData();

    // Add one CPS item additionally
    Id stdPbId = Test.getStandardPricebookId();

    Account acc = [
        SELECT Id, CurrencyIsoCode
        FROM Account
        WHERE CurrencyIsoCode != null
        LIMIT 1
    ];

    Product2 cpsProd = new Product2(
        Name = 'Test Product - CPS',
        IsActive = true,
        Revenue_Category__c = 'Professional Services'
    );
    insert cpsProd;

    PricebookEntry cpsPbe = new PricebookEntry(
        Pricebook2Id = stdPbId,
        Product2Id = cpsProd.Id,
        UnitPrice = 50,
        IsActive = true,
        CurrencyIsoCode = acc.CurrencyIsoCode
    );
    insert cpsPbe;

    OrderItem cpsItem = new OrderItem(
        OrderId = data.orderId,
        PricebookEntryId = cpsPbe.Id,
        Quantity = 4,
        UnitPrice = 50,
        Project__c = data.projectId,
        Basis_of_Fees__c = 'CPS Days'
    );
    insert cpsItem;

    // Explicitly call rollup service (no cancellation)
    Test.startTest();
    ProjectRollupService.recalculate(
        new Set<Id>{ data.projectId }
    );
    Test.stopTest();

    ProjectObject__c proj = [
        SELECT Order_Products_Count__c,
               Total_Orderline_Value_RollUp__c,
               Scoped_CPS_days_RollUp__c,
               Scoped_LPS_days_RollUp__c,
               CPS_scoped_value__c,
               LPS_scoped_value__c
        FROM ProjectObject__c
        WHERE Id = :data.projectId
    ];

    // We now have:
    // LPS item from createTestData: Qty 2 * 100 = 200
    // CPS item just added: Qty 4 * 50 = 200

    System.assertEquals(2, proj.Order_Products_Count__c);
    System.assertEquals(400, proj.Total_Orderline_Value_RollUp__c);

    System.assertEquals(4, proj.Scoped_CPS_days_RollUp__c);
    System.assertEquals(200, proj.CPS_scoped_value__c);

    System.assertEquals(2, proj.Scoped_LPS_days_RollUp__c);
    System.assertEquals(200, proj.LPS_scoped_value__c);
}
}