@isTest(SeeAllData=true)
public class testutilityclass {
    
    @isTest
    static void testUtilityMethods()
    {   
        Datetime variable=System.now();
        String Testname='Test Account'+variable;
        Account account=new Account(name=Testname,Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1',industry='Agriculture');
        insert account;
        
        List<TC_Transition_Slot__c> lTCSlot = new List<TC_Transition_Slot__c>();
        TC_Transition_Slot__c tcslotRec = new TC_Transition_Slot__c();
        
        tcslotRec.Transition_Slot_Description__c = 'test';
        tcslotRec.Transition_Slot_Type__c = 'Standard';
        tcslotRec.Booking_Availability__c = 'Regional slot - bookable';
        tcslotRec.Date__c = system.today().addDays(29);
        tcslotRec.Maximum_Transitions__c = 10;
        lTCSlot.add(tcslotRec);
        
        
        List<Talent_Central__c> lTcRec = new List<Talent_Central__c>();
        Talent_Central__c tcRec = new Talent_Central__c();
        tcRec.Account__c = account.id;
        tcRec.Current_Transition_Activity__c = 'Transition Activity Completed';
        tcRec.TC_Transition_Slot__c = lTCSlot[0].id;
        lTcRec.add(tcRec);
        insert ltcRec;
        
        test.startTest();
        
        Utility.slotProvandConfTotal(lTcRec);
        Utility.delTCTransitionRec(lTcRec);
        Set<string> resultstring = Utility.getOpptyType();
        Set<String> resultstring8=Utility.getAccountTradingStatus();
        String resultstring7=Utility.getOpptyTypeNBBNL();
        String resultstring9=Utility.getOpptyTypeNBBCS();
        Set<string> resultstring2 = Utility.getSystemTransitionStatus();
        string resultstring3 = Utility.getCurrentTransitionActivity();
        Set<string> resultstring4 = Utility.getIMLookupCode();
        string resultstring5 = Utility.getBookingStatus();
        Set<string> resultstring6 = Utility.getSubscriptionPBI();
        Set<string> resultstring10 = Utility.getSubscriptionPBIName(); 
        Set<String> resultstring11=Utility.getOrderLineItemValuesFilter2();
        Set<String> resultstring12=Utility.getOrderLineItemValuesFilter1();
        Set<String> resultstring13=Utility.getOrderLineItemValuesFilter1_1();
        Set<String> resultstring14=Utility.getUlyanaFerreria();
        Set<String> resultstring15=Utility.getAutoRenewalfromOrder();
        Set<String> resultstring16=Utility.getreboostProducts();
        Set<String> resultstring17=Utility.getEACVvaluesforOrder();
        List<String> resultstring18=Utility.getMultiYearOrderLinesName();
        List<String> resultstring19=Utility.getMultiYearOrderLinesPlatform();
        List<String> resultstring20=Utility.getSubscriptionProductSequence();
        List<String> resultstring21=Utility.getMilestoneWatcheremail();
        boolean resultstring22=Utility.getMWatcherChecked();
        
        test.stopTest();
    }
}