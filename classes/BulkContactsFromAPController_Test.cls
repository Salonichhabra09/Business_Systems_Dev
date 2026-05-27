/***********************************************************************************************************************************
* Created By: Prachi Gupta                                                                                                         * 
* Description: This class is test class of to BulkContactsFromAPController.                                                        *
************************************************************************************************************************************/
@isTest(seeAlldata=true)
public class BulkContactsFromAPController_Test {

    @isTest
    static void saveContactsTest1(){
       test.startTest(); 
         Account acc1 = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',Buying_Centre_Id__c = 'Test 1',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc1;
        String Dnumber = [Select AccountNumber from account where id = :acc1.Id].AccountNumber;
        system.debug('Dnumber ' + Dnumber);
         Account_Plan__c ap2 = new Account_Plan__c(Account_Name__c = acc1.id,Quarter__c ='Q1',
                                                   Year__c='2023',Account_Plan_Status__c ='Draft',
                                                   Account_Plan_Type__c='Regional',Buying_Centre_Id__c = 'Test 1',
                                                   Date_of_Last_Plan_Review__c=system.today() - 6);
        insert ap2;
        
         Contact contact=new Contact(lastname='Test Contact',
             AccountId=acc1.id,
             Same_As_The_Account_Billing_Address__c=true,
             Mailing_Address_Line_1__c ='test',
             Mailing_City__c='test',
             Mailing_ZIP_Postal_Code__c ='110094',       
             Mailing_Country__c='INDIA',
             Area_of_Interest__c ='Training',
             Title = 'Test Data',
             Email ='uniqueRecord@shl.com' 
             );
            insert contact;
        String conemail = 'uniqueRecord@shl.com';
       List<BulkContactsFromAPController.ContactWrapper> cwList = new List<BulkContactsFromAPController.ContactWrapper>();
        for(Integer i=0 ;i <10 ; i++){
            BulkContactsFromAPController.ContactWrapper cw = new BulkContactsFromAPController.ContactWrapper();
                cw.AccountNumber = Dnumber;             
                cw.FirstName = 'Test Data';
                cw.LastName = 'Class ' + i;             
                cw.Email = 'testing'+i+'@shl'+i+'.com';
                cw.Phone = '99999999';
                cw.Title = 'Test';
                cw.isTopContact = 'Y'; 
                cw.ReportsToEmail = conemail;
                cw.ReportsToAccount = Dnumber;
                cw.AreaOfInterest  = 'Talent Acquisition - Tech';
             cw.JobLevel = 'Consultant'; 
           cwList.add(cw); 
        } 
        for(Integer i=0 ;i <10 ; i++){
            BulkContactsFromAPController.ContactWrapper cw = new BulkContactsFromAPController.ContactWrapper();
                cw.AccountNumber = Dnumber;             
                cw.FirstName = 'Test Data';
                cw.LastName = 'Class ' + i;             
                cw.Email = 'test'+i+'@shl.com';
                cw.Phone = '99999999';
                cw.Title = 'Test';
                cw.isTopContact = 'Y'; 
                cw.ReportsToEmail = conemail;
                cw.ReportsToAccount = Dnumber;
                cw.JobFunction = 'Graduate Recruitment'; 
             cw.AreaOfInterest  = 'Talent Acquisition - Tech';
           cwList.add(cw); 
        } 
        
          BulkContactsFromAPController.saveContacts(cwList,ap2.id);
        
        
       test.stopTest(); 
    }

 @isTest
    static void saveContactsTest2(){
       test.startTest(); 
         Account acc1 = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',Buying_Centre_Id__c = 'Test 1',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc1;
        String Dnumber = [Select AccountNumber from account where id = :acc1.Id].AccountNumber;
        system.debug('Dnumber ' + Dnumber);
         Account_Plan__c ap2 = new Account_Plan__c(Account_Name__c = acc1.id,Quarter__c ='Q1',
                                                   Year__c='2023',Account_Plan_Status__c ='Draft',
                                                   Account_Plan_Type__c='Regional',Buying_Centre_Id__c = 'Test 1',
                                                   Date_of_Last_Plan_Review__c=system.today() - 6);
        insert ap2;
        
         Contact contact=new Contact(lastname='Test Contact',
             AccountId=acc1.id,
             Same_As_The_Account_Billing_Address__c=true,
             Mailing_Address_Line_1__c ='test',
             Mailing_City__c='test',
             Mailing_ZIP_Postal_Code__c ='110094',       
             Mailing_Country__c='INDIA',
             Area_of_Interest__c ='Training',
             Title = 'Test Data',
             Email ='uniqueRecord@shl.com' 
             );
            insert contact;
        String conemail = 'uniqueRecord@shl.com';
       List<BulkContactsFromAPController.ContactWrapper> cwList = new List<BulkContactsFromAPController.ContactWrapper>();
        for(Integer i=0 ;i <10 ; i++){
            BulkContactsFromAPController.ContactWrapper cw = new BulkContactsFromAPController.ContactWrapper();
                cw.AccountNumber = Dnumber;             
                cw.FirstName = 'Test Data';
                cw.LastName = '';             
                cw.Email = 'testing'+i+'@shl'+i+'.com';
                cw.Phone = '99999999';
                cw.Title = 'Test';
                cw.isTopContact = 'Y'; 
                cw.ReportsToEmail = conemail;
                cw.ReportsToAccount = Dnumber;
           cwList.add(cw); 
        } 
        for(Integer i=0 ;i <10 ; i++){
            BulkContactsFromAPController.ContactWrapper cw = new BulkContactsFromAPController.ContactWrapper();
                cw.AccountNumber = Dnumber;             
                cw.FirstName = 'Test Data';
                cw.LastName = 'Class ' + i;             
                cw.Email = '';
                cw.Phone = '99999999';
                cw.Title = 'Test';
                cw.isTopContact = 'Y'; 
                cw.ReportsToEmail = conemail;
                cw.ReportsToAccount = Dnumber;
           cwList.add(cw); 
        } 
        
          BulkContactsFromAPController.saveContacts(cwList,ap2.id);
        
        
       test.stopTest(); 
    }
    @isTest
    static void saveContactsTest3(){
       test.startTest(); 
         Account acc1 = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',Buying_Centre_Id__c = 'Test 1',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc1;
        String Dnumber = [Select AccountNumber from account where id = :acc1.Id].AccountNumber;
        system.debug('Dnumber ' + Dnumber);
         Account_Plan__c ap2 = new Account_Plan__c(Account_Name__c = acc1.id,Quarter__c ='Q1',
                                                   Year__c='2023',Account_Plan_Status__c ='Draft',
                                                   Account_Plan_Type__c='Regional',Buying_Centre_Id__c = 'Test 1',
                                                   Date_of_Last_Plan_Review__c=system.today() - 6);
        insert ap2;
        
         Contact contact=new Contact(lastname='Test Contact',
             AccountId=acc1.id,
             Same_As_The_Account_Billing_Address__c=true,
             Mailing_Address_Line_1__c ='test',
             Mailing_City__c='test',
             Mailing_ZIP_Postal_Code__c ='110094',       
             Mailing_Country__c='INDIA',
             Area_of_Interest__c ='Training',
             Title = 'Test Data',
             Email ='uniqueRecord@shl.com' 
             );
            insert contact;
        String conemail = 'uniqueRecord@shl.com';
       List<BulkContactsFromAPController.ContactWrapper> cwList = new List<BulkContactsFromAPController.ContactWrapper>();
        for(Integer i=0 ;i <10 ; i++){
            BulkContactsFromAPController.ContactWrapper cw = new BulkContactsFromAPController.ContactWrapper();
                cw.AccountNumber = Dnumber;             
                cw.FirstName = 'Test Data';
                cw.LastName = '';             
                cw.Email = '';
                cw.Phone = '99999999';
                cw.Title = 'Test';
                cw.isTopContact = 'Y'; 
                cw.ReportsToEmail = conemail;
                cw.ReportsToAccount = Dnumber;
           cwList.add(cw); 
        } 
        for(Integer i=0 ;i <10 ; i++){
            BulkContactsFromAPController.ContactWrapper cw = new BulkContactsFromAPController.ContactWrapper();
                cw.AccountNumber = Dnumber;             
                cw.FirstName = 'Test Data';
                cw.LastName = 'Class ' + i;             
                cw.Email = 'test Data';
                cw.Phone = '99999999';
                cw.Title = 'Test';
                cw.isTopContact = 'Y'; 
                cw.ReportsToEmail = conemail;
                cw.ReportsToAccount = Dnumber;
           cwList.add(cw); 
        } 
         for(Integer i=0 ;i <10 ; i++){
            BulkContactsFromAPController.ContactWrapper cw = new BulkContactsFromAPController.ContactWrapper();
                cw.AccountNumber = Dnumber;             
                cw.FirstName = 'Test Data';
                cw.LastName = 'Class ' + i;             
                cw.Email = 'test@shl.com';
                cw.Phone = '99999999';
                cw.Title = 'Test';
                cw.isTopContact = 'Y'; 
                cw.ReportsToEmail = 'test Data';
                cw.ReportsToAccount = Dnumber;
           cwList.add(cw); 
        } 
        
          BulkContactsFromAPController.saveContacts(cwList,ap2.id);
        
        
       test.stopTest(); 
    }
    
    @isTest
    static void saveContactsTest4(){
       test.startTest(); 
         Account acc1 = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',Buying_Centre_Id__c = 'Test 1',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc1;
        String Dnumber = [Select AccountNumber from account where id = :acc1.Id].AccountNumber;
        system.debug('Dnumber ' + Dnumber);
         Account_Plan__c ap2 = new Account_Plan__c(Account_Name__c = acc1.id,Quarter__c ='Q1',
                                                   Year__c='2023',Account_Plan_Status__c ='Draft',
                                                   Account_Plan_Type__c='Regional',Buying_Centre_Id__c = 'Test 1',
                                                   Date_of_Last_Plan_Review__c=system.today() - 6);
        insert ap2;
        
         Contact contact=new Contact(lastname='Test Contact',
             AccountId=acc1.id,
             Same_As_The_Account_Billing_Address__c=true,
             Mailing_Address_Line_1__c ='test',
             Mailing_City__c='test',
             Mailing_ZIP_Postal_Code__c ='110094',       
             Mailing_Country__c='INDIA',
             Area_of_Interest__c ='Training',
             Title = 'Test Data',
             Email ='uniqueRecord@shl.com' 
             );
            insert contact;
        String conemail = 'uniqueRecord@shl.com';
       List<BulkContactsFromAPController.ContactWrapper> cwList = new List<BulkContactsFromAPController.ContactWrapper>();
        for(Integer i=0 ;i <10 ; i++){
            BulkContactsFromAPController.ContactWrapper cw = new BulkContactsFromAPController.ContactWrapper();
                cw.AccountNumber = Dnumber;             
                cw.FirstName = 'Test Data';
                cw.LastName = '';             
                cw.Email = conemail;
                cw.Phone = '99999999';
                cw.Title = 'Test';
                cw.isTopContact = 'Y'; 
                cw.ReportsToEmail = conemail;
                cw.ReportsToAccount = Dnumber;
           cwList.add(cw); 
        } 
         for(Integer i=0 ;i <10 ; i++){
            BulkContactsFromAPController.ContactWrapper cw = new BulkContactsFromAPController.ContactWrapper();
                cw.AccountNumber = Dnumber;             
                cw.FirstName = 'Test Data';
                cw.LastName = 'Class ' + i;             
                cw.Email = 'test@shl.com';
                cw.Phone = '99999999';
                cw.Title = 'Test';
                cw.isTopContact = 'Y'; 
                
           cwList.add(cw); 
        } 
         
        
          BulkContactsFromAPController.saveContacts(cwList,ap2.id);
        
        
       test.stopTest(); 
    }
    @isTest
    static void saveContactsTest5(){
       test.startTest(); 
         Account acc1 = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',Buying_Centre_Id__c = 'Test 1',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc1;
        String Dnumber = [Select AccountNumber from account where id = :acc1.Id].AccountNumber;
        system.debug('Dnumber ' + Dnumber);
         Account_Plan__c ap2 = new Account_Plan__c(Account_Name__c = acc1.id,Quarter__c ='Q1',
                                                   Year__c='2023',Account_Plan_Status__c ='Draft',
                                                   Account_Plan_Type__c='Regional',Buying_Centre_Id__c = 'Test 1',
                                                   Date_of_Last_Plan_Review__c=system.today() - 6);
        insert ap2;
        
         Contact contact=new Contact(lastname='Test Contact',
             AccountId=acc1.id,
             Same_As_The_Account_Billing_Address__c=true,
             Mailing_Address_Line_1__c ='test',
             Mailing_City__c='test',
             Mailing_ZIP_Postal_Code__c ='110094',       
             Mailing_Country__c='INDIA',
             Area_of_Interest__c ='Training',
             Title = 'Test Data',
             Email ='uniqueRecord@shl.com' 
             );
            insert contact;
        String conemail = 'uniqueRecord@shl.com';
       List<BulkContactsFromAPController.ContactWrapper> cwList = new List<BulkContactsFromAPController.ContactWrapper>();
        for(Integer i=0 ;i <10 ; i++){
            BulkContactsFromAPController.ContactWrapper cw = new BulkContactsFromAPController.ContactWrapper();
                cw.AccountNumber = Dnumber;             
                cw.FirstName = 'Test Data';
                cw.LastName = '';             
                cw.Email = conemail;
                cw.Phone = '99999999';
                cw.Title = 'Test';
                cw.isTopContact = 'Y'; 
                cw.ReportsToEmail = conemail;
                cw.ReportsToAccount = Dnumber;
                cw.JobFunction = 'Test';
             cw.AreaOfInterest  = 'Talent Acquisition - Tech';
           cwList.add(cw); 
        } 
        for(Integer i=0 ;i <2 ; i++){
            BulkContactsFromAPController.ContactWrapper cw = new BulkContactsFromAPController.ContactWrapper();
                cw.AccountNumber = Dnumber;             
                cw.FirstName = 'Test Data';
                cw.LastName = 'Class ' + i;             
                cw.Email = 'test'+i+'@test.com';
                cw.Phone = '99999999';
                cw.Title = 'Test';
                cw.isTopContact = 'Y'; 
                cw.ReportsToEmail = conemail;
                cw.ReportsToAccount = Dnumber;
                cw.JobFunction = 'Test Recruitment'; 
                
           cwList.add(cw); 
        } 
        for(Integer i=0 ;i <2 ; i++){
            BulkContactsFromAPController.ContactWrapper cw = new BulkContactsFromAPController.ContactWrapper();
                cw.AccountNumber = Dnumber;             
                cw.FirstName = 'Test Data';
                cw.LastName = 'Class ' + i;             
                cw.Email = 'test'+i+'test' +'@shl.com';
                cw.Phone = '99999999';
                cw.Title = 'Test';
                cw.isTopContact = 'Y'; 
                cw.ReportsToEmail = conemail;
                cw.ReportsToAccount = Dnumber;
                cw.JobLevel = 'Test'; 
             cw.AreaOfInterest  = 'Talent Acquisition - Tech';
                
           cwList.add(cw); 
        } 
         
        
          BulkContactsFromAPController.saveContacts(cwList,ap2.id);
        
        
       test.stopTest(); 
    }
}