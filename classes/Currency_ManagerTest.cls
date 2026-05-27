@IsTest
private class Currency_ManagerTest {
    
    @IsTest
    static void testCurrencyManagerMethods() {
        // Simulate CurrencyType data - only possible in test context or sandbox/scratch org
        // CurrencyType is a setup object, so you can't insert directly.
        // We'll simulate the logic by mocking responses where possible.
        
        // Using Test.startTest / stopTest to isolate performance
        Test.startTest();

        // Call getAllCurrencyTypes()
        CurrencyType[] allCurrencies = Currency_Manager.getAllCurrencyTypes();

        // Assuming at least one currency is returned
        if (!allCurrencies.isEmpty()) {
            String sampleIsoCode = allCurrencies[0].IsoCode;

            // Test getCurrencyType
            CurrencyType result = Currency_Manager.getCurrencyType(sampleIsoCode, allCurrencies);
            System.assertNotEquals(null, result);
            System.assertEquals(sampleIsoCode, result.IsoCode);

            // If there are at least 2 currencies, test conversion rate
            if (allCurrencies.size() > 1) {
                String fromIso = allCurrencies[0].IsoCode;
                String toIso = allCurrencies[1].IsoCode;
                Double rate = Currency_Manager.getCurrencyConversionRate(fromIso, toIso);
                System.assert(rate > 0);
            }
        }

        Test.stopTest();
    }
}