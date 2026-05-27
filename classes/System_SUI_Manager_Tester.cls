@isTest //(SeeAllData=true)
private class System_SUI_Manager_Tester{
    static testMethod void Account_ManagerTest(){
    	list<Trigger_Activation__c> objList = new list<Trigger_Activation__c>();
        Trigger_Activation__c obj = new Trigger_Activation__c();
        obj.Active__c = true;
        obj.Name = 'Account_Trigger';
        obj.Object_Name__c = 'Account';
     	objList.add(obj);
        
        Trigger_Activation__c obj1 = new Trigger_Activation__c();
        obj1.Active__c = true;
        obj1.Name = 'System_Trigger';
        obj1.Object_Name__c = 'System';
        objList.add(obj1);
        insert objList;
        Test.startTest();
        //Code to test system upgrade information 
        System__c systemObj = new System__c(System_Name__c='test',System_Type__c='SODA',System_URL__c='https://cs7.salesforce.com/a0a/e',Status__c='On Hold',Is_Client_System__c=true,Integrated__c='No',SODA_DR__c='2',System_Client_ID__c='sdfsdf',System_Client_Name__c='sdfsdf');
        insert systemObj;
        systemObj.System_Name__c='test2';
        update systemObj;
        
       /* System_Upgrade_Information__c sui = new System_Upgrade_Information__c(Upgrade_Date__c=Date.Today(),System__c=systemObj.Id,Upgrade_Information__c='test');
        insert sui;
        sui.Upgrade_Date__c=Date.Today().addDays(1);
        update sui;
        delete sui;*/
        Test.stopTest();
    
    }
    
     static testMethod void testContactUs() {
        id rtId = Schema.SObjectType.System__c.getRecordTypeInfosByName().get('Client System').getRecordTypeId();
        PageReference pg = new PageReference('/SystemView');
        Id RecordTypeId = [select id from RecordType Where sObjectType='System__c' AND DeveloperName !='Client_System'].Id;
        pg.getParameters().put('retURL', '/a0a/o');
        pg.getParameters().put('RecordType', RecordTypeId);
        pg.getParameters().put('ent', '');
        Test.setCurrentPage(pg);
         list<Trigger_Activation__c> objList = new list<Trigger_Activation__c>();
        Trigger_Activation__c obj = new Trigger_Activation__c();
        obj.Active__c = true;
        obj.Name = 'Account_Trigger';
        obj.Object_Name__c = 'Account';
     	objList.add(obj);
        
        Trigger_Activation__c obj1 = new Trigger_Activation__c();
        obj1.Active__c = true;
        obj1.Name = 'System_Trigger';
        obj1.Object_Name__c = 'System';
        objList.add(obj1);
        insert objList;
        system.debug('***PG***='+pg);
        Test.startTest();
            Datetime variable=System.now();
            Account Account1=new Account(name='Test Account1'+variable,Status__c='Approved',
                                        Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                        Billing_Country__c='India',Billing_State__c='Test',
                                        Industry= 'Aviation',
                                        Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
            insert Account1;
            Account Account=new Account(name='Account2'+variable,Status__c='Approved',
                                        Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                        Billing_Country__c='India',Billing_State__c='Test',
                                        Industry= 'Aviation',
                                        Billing_ZIP_Postal_Code__c='1100110',BU__c='UK - UK1');
            insert Account;
            //Account Account1 = CreateTestData.GetAccount1();
            //Account Account = CreateTestData.GetAccount();
            System__c newsys = new System__c();
            newsys.RecordTypeId = RecordTypeId;
            ApexPages.StandardController controller = new ApexPages.StandardController(newsys);
            SystemController sys = new SystemController(controller);
            sys.redirectToStandardpage();
            sys.lookupValue='Test (Alliance)';
            sys.hideAccountPicklist();
            sys.saveChanges();
            sys.cancelChanges();
            newSys.System_Name__c = 'Test System';
            newSys.System_Type__c='ASO';
            newSys.System_URL__c='http://www.test.com';
            newSys.Status__c ='Live';
            newSys.Integrated__c = 'Yes';
            newSys.System_Client_ID__c='System ClientID';
            newSys.System_Client_Name__c='System Client Name';
            newSys.Live_Date__c=Date.Today().addDays(1);
            newSys.Integrator_Account__c = Account1.Id;
            newSys.Integrator_Account_Account_Name__c = 'ADP';
            newSys.Account__c = Account.Id;
            insert newSys;
         
            newsys.RecordTypeId = rtId;
         	newSys.Account__c = Account1.Id;
            //newSys.Integrator_Account__c = Account.Id;
            update newSys;
         	newSys.Status__c = 'On Hold';
            update newSys;

         
            pg.getParameters().remove('RecordType');
         
            Test.setCurrentPage(pg);
            ApexPages.StandardController controller1 = new ApexPages.StandardController(newsys);
            SystemController sys1 = new SystemController(controller1);
            sys1.redirectToStandardpage();
            sys1.saveChanges();
           
        Test.stopTest();
    }
    static testMethod void testContactUs1() {
        id rtId = Schema.SObjectType.System__c.getRecordTypeInfosByName().get('Client System').getRecordTypeId();
        list<Trigger_Activation__c> objList = new list<Trigger_Activation__c>();
        Trigger_Activation__c obj = new Trigger_Activation__c();
        obj.Active__c = true;
        obj.Name = 'Account_Trigger';
        obj.Object_Name__c = 'Account';
     	objList.add(obj);
        
        Trigger_Activation__c obj1 = new Trigger_Activation__c();
        obj1.Active__c = true;
        obj1.Name = 'System_Trigger';
        obj1.Object_Name__c = 'System';
        objList.add(obj1);
        insert objList;
        Test.startTest();
            Account Account = CreateTestData.GetAccount();
            System__c newsys = new System__c();
            newsys.RecordTypeId = rtId;           
            newSys.System_Name__c = 'Test System';
            newSys.System_Type__c='ASO';
            newSys.System_URL__c='http://www.test.com';
            newSys.Status__c ='Live';
            newSys.Integrated__c = 'No';
            newSys.System_Client_ID__c='System ClientID';
            newSys.System_Client_Name__c='System Client Name';
            newSys.Live_Date__c=Date.Today().addDays(1);
            newSys.Integrator_Account__c = Account.Id;          
            newSys.Account__c = Account.Id;
            insert newSys;  
        Test.stopTest();
    }

    static testMethod void testCloneSystem() {
        id rtId = Schema.SObjectType.System__c.getRecordTypeInfosByName().get('Client System').getRecordTypeId();
        list<Trigger_Activation__c> objList = new list<Trigger_Activation__c>();
        Trigger_Activation__c obj = new Trigger_Activation__c();
        obj.Active__c = true;
        obj.Name = 'Account_Trigger';
        obj.Object_Name__c = 'Account';
     	objList.add(obj);
        
        Trigger_Activation__c obj1 = new Trigger_Activation__c();
        obj1.Active__c = true;
        obj1.Name = 'System_Trigger';
        obj1.Object_Name__c = 'System';
        objList.add(obj1);
        insert objList;
        Test.startTest();
            Account Account = CreateTestData.GetAccount();
            System__c newsys = new System__c();
            newsys.RecordTypeId = rtId;           
            newSys.System_Name__c = 'Test System';
            newSys.System_Type__c='ASO';
            newSys.System_URL__c='http://www.test.com';
            newSys.Status__c ='Live';
            newSys.Integrated__c = 'No';
            newSys.System_Client_ID__c='System ClientID';
            newSys.System_Client_Name__c='System Client Name';
            newSys.Live_Date__c=Date.Today().addDays(1);
            newSys.Integrator_Account__c = Account.Id;          
            newSys.Account__c = Account.Id;
            insert newSys;
        Test.stopTest();
    }

}