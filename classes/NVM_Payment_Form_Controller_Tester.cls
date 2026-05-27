@isTest(seeAllData = true)
public class NVM_Payment_Form_Controller_Tester{

     @isTest static void TestVf(){

        Account account=new Account(Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1');
        account.name='Test Account1'+System.now();
        insert account;
        
        Contact con=new Contact(FirstName='abc',lastname='Test Contact1', Accountid=account.id);
        con.Same_As_The_Account_Billing_Address__c=true;
        con.Mailing_Address_Line_1__c ='test';
        con.Mailing_City__c='test';
        con.Mailing_ZIP_Postal_Code__c ='110094';
        con.Mailing_Country__c='India';
        con.Mailing_State_County__c='AB';
        con.email = 'abc@gmail.com';
        insert con;

        Case c = new Case();
        c.RecordtypeId = '012D0000000V9YhIAK';
        c.Origin = 'Phone';
        c.ContactId = con.id;           
        c.Subject = 'Invoice Payment - ';
        c.Call_Type__c = 'Invoice/Credit/Licence';
        c.Status = 'In Progress';
        c.Caller_Type__c = 'Customer';
        c.Account = account;
        c.Contact = con;
        c.CurrencyIsoCode =  'AUD';           
        c.Case_Country__c = con.Mailing_Country__c;           
        c.Description = 'NVM Case';      
        c.Problem2__c = 'Other';
        c.Solution__c = 'Other';            
        c.Preferred_Language__c = 'English';
        c.Caller_s_Name__c = con.Name;        
        c.First_Name__c= con.FirstName;
        c.Last_Name__c= con.LastName;
        c.Building_Name__c= con.Mailing_Address_Line_1__c;    
        c.Street__c = 'abc';
        c.City_town__c = 'abc';
        c.Zip_Postal__c = '2921';
        c.Country__c = 'ARM';
        c.Case_Country__c  = 'ARM';
        c.State__c = 'NS';
        c.Sun_Reference_No__c = '123';
        c.Ref_Type__c = '123';
        
        insert c;
      
        Test.startTest();    
       
        
        ApexPages.StandardController sc = new ApexPages.standardController(c);                              
        PageReference pageRef = Page.NVM_Payment_Form; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(c.Id));
        pageRef.getParameters().put('selectedCountry','UKR');

        Test.setCurrentPage(pageRef);
   
        NVM_Payment_Form_Controller myPageCon = new NVM_Payment_Form_Controller (sc);
        Test.setMock(HttpCalloutMock.class, new MockHttpNVMResponseGenerator());  // Added by Pankhuri 
        pagereference pg = myPageCon.CallWebService();       
        myPageCon.changeconinfo();
        myPageCon.getCurrencyOption();
        myPageCon.getCountryOption();
        myPageCon.save();
       
        pageRef.getParameters().put('samecont','False');
        myPageCon.changeconinfo();       
       
        Test.stopTest();         

    }

    @isTest static void TestVf_CreateCase(){
    
        Account account=new Account(Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1');
        account.name='Test Account1'+System.now();
        insert account;
        
        Contact con=new Contact(FirstName='abc',lastname='Test Contact1', Accountid=account.id);
        con.Same_As_The_Account_Billing_Address__c=true;
        con.Mailing_Address_Line_1__c ='test';
        con.Mailing_City__c='test';
        con.Mailing_ZIP_Postal_Code__c ='110094';
        con.Mailing_Country__c='India';
        con.Mailing_State_County__c='AB';
        con.email = 'abc@gmail.com';
        insert con;
        
        Test.startTest();
        
        ApexPages.StandardController scn = new ApexPages.standardController(con);
        PageReference pageRef2 = Page.MakePaymentContact; // Add your VF page Name here
        pageRef2.getParameters().put('id', String.valueOf(con.Id));
        Test.setCurrentPage(pageRef2);
        MakePaymentContact myPageCon2 = new MakePaymentContact(scn);
        myPageCon2.createCase();
        
        Test.stopTest(); 
        
    }
    
    @isTest static void TestVf_ErrorClass(){
    
        Account account=new Account(Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1');
        account.name='Test Account1'+System.now();
        insert account;
        
        Contact con=new Contact(FirstName='abc',lastname='Test Contact1', Accountid=account.id);
        con.Same_As_The_Account_Billing_Address__c=true;
        con.Mailing_Address_Line_1__c ='test';
        con.Mailing_City__c='test';
        con.Mailing_ZIP_Postal_Code__c ='110094';
        con.Mailing_Country__c='India';
        con.Mailing_State_County__c='AB';
        con.email = 'abc@gmail.com';
        insert con;
        
        Case c = new Case();
        c.RecordtypeId = '012D0000000V9YhIAK';
        c.Origin = 'Phone';
        c.ContactId = con.id;           
        c.Subject = 'Invoice Payment - ';
        c.Call_Type__c = 'Invoice/Credit/Licence';
        c.Status = 'In Progress';
        c.Caller_Type__c = 'Customer';
        c.Account = account;
        c.Contact = con;
        c.CurrencyIsoCode =  'AUD';           
        c.Case_Country__c = con.Mailing_Country__c;           
        c.Description = 'NVM Case';      
        c.Problem2__c = 'Other';
        c.Solution__c = 'Other';            
        c.Preferred_Language__c = 'English';
        c.Caller_s_Name__c = con.Name;        
        c.First_Name__c= con.FirstName;
        c.Last_Name__c= con.LastName;
        c.Building_Name__c= con.Mailing_Address_Line_1__c;    
        c.Street__c = 'abc';
        c.City_town__c = 'abc';
        c.Zip_Postal__c = '2921';
        c.Country__c = 'ARM';
        c.Case_Country__c  = 'ARM';
        c.State__c = 'NS';
        c.Sun_Reference_No__c = '123';
        c.Ref_Type__c = '123';        
        insert c;
        
        Test.startTest();
       
        PageReference pageRef2 = Page.NVM_ErrorPaymentControllerVF; // Add your VF page Name here
        pageRef2.getParameters().put('err', String.valueOf('this is test error msg'));
        Test.setCurrentPage(pageRef2);
        NVM_ErrorPaymentController myPageCon2 = new NVM_ErrorPaymentController();
        myPageCon2.ReturnHome();
        
        Test.stopTest(); 
        
     }
    
     @isTest static void Test_NVM_PaymentController2(){
        Account account=new Account(Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1');
        account.name='Test Account1'+System.now();
        insert account;
        
        Contact con=new Contact(FirstName='abc',lastname='Test Contact1', Accountid=account.id);
        con.Same_As_The_Account_Billing_Address__c=true;
        con.Mailing_Address_Line_1__c ='test';
        con.Mailing_City__c='test';
        con.Mailing_ZIP_Postal_Code__c ='110094';
        con.Mailing_Country__c='India';
        con.Mailing_State_County__c='AB';
        con.email = 'abc@gmail.com';
        insert con;
        
        Case c = new Case();
        c.RecordtypeId = '012D0000000V9YhIAK';
        c.Origin = 'Phone';
        c.ContactId = con.id;           
        c.Subject = 'Invoice Payment - ';
        c.Call_Type__c = 'Invoice/Credit/Licence';
        c.Status = 'In Progress';
        c.Caller_Type__c = 'Customer';
        c.Account = account;
        c.Contact = con;
        c.CurrencyIsoCode =  'AUD';           
        c.Case_Country__c = con.Mailing_Country__c;           
        c.Description = 'NVM Case';      
        c.Problem2__c = 'Other';
        c.Solution__c = 'Other';            
        c.Preferred_Language__c = 'English';
        c.Caller_s_Name__c = con.Name;        
        c.First_Name__c= con.FirstName;
        c.Last_Name__c= con.LastName;
        c.Building_Name__c= con.Mailing_Address_Line_1__c;    
        c.Street__c = 'abc';
        c.City_town__c = 'abc';
        c.Zip_Postal__c = '2921';
        c.Country__c = 'ARM';
        c.Case_Country__c  = 'ARM';
        c.State__c = 'NS';
        c.Sun_Reference_No__c = '123';
        c.Ref_Type__c = '123';        
        insert c;
        
        Test.startTest();
       
        PageReference pageRef = Page.NVM_PaymentControllerVF; // Add your VF page Name here
        pageRef.getParameters().put('Sid', String.valueOf('123'));
        pageRef.getParameters().put('tk', String.valueOf('1234'));
        pageRef.getParameters().put('t', String.valueOf('123'));
        pageRef.getParameters().put('rtk', String.valueOf('123'));
        pageRef.getParameters().put('Iurl', String.valueOf('iframed'));
        pageRef.getParameters().put('Csid', String.valueOf(c.id));
        Test.setCurrentPage(pageRef);
        NVM_PaymentController2 myPageCon = new NVM_PaymentController2();
        Test.setMock(HttpCalloutMock.class, new MockHttpNVMResponseGenerator());  // Added by Pankhuri 
        myPageCon.PaymentStatus();
       
        Test.stopTest(); 
     }
     
     @isTest static void Test2_NVM_PaymentController2(){
        Account account=new Account(Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1');
        account.name='Test Account1'+System.now();
        insert account;
        
        Contact con=new Contact(FirstName='abc',lastname='Test Contact1', Accountid=account.id);
        con.Same_As_The_Account_Billing_Address__c=true;
        con.Mailing_Address_Line_1__c ='test';
        con.Mailing_City__c='test';
        con.Mailing_ZIP_Postal_Code__c ='110094';
        con.Mailing_Country__c='India';
        con.Mailing_State_County__c='AB';
        con.email = 'abc@gmail.com';
        insert con;
        
        Case c = new Case();
        c.RecordtypeId = '012D0000000V9YhIAK';
        c.Origin = 'Phone';
        c.ContactId = con.id;           
        c.Subject = 'Invoice Payment - ';
        c.Call_Type__c = 'Invoice/Credit/Licence';
        c.Status = 'In Progress';
        c.Caller_Type__c = 'Customer';
        c.Account = account;
        c.Contact = con;
        c.CurrencyIsoCode =  'AUD';           
        c.Case_Country__c = con.Mailing_Country__c;           
        c.Description = 'NVM Case';      
        c.Problem2__c = 'Other';
        c.Solution__c = 'Other';            
        c.Preferred_Language__c = 'English';
        c.Caller_s_Name__c = con.Name;        
        c.First_Name__c= con.FirstName;
        c.Last_Name__c= con.LastName;
        c.Building_Name__c= con.Mailing_Address_Line_1__c;    
        c.Street__c = 'abc';
        c.City_town__c = 'abc';
        c.Zip_Postal__c = '2921';
        c.Country__c = 'ARM';
        c.Case_Country__c  = 'ARM';
        c.State__c = 'NS';
        c.Sun_Reference_No__c = '123';
        c.Ref_Type__c = '123';        
        insert c;
        
        Test.startTest();
       
        PageReference pageRef = Page.NVM_PaymentControllerVF; // Add your VF page Name here
        pageRef.getParameters().put('Sid', String.valueOf('234'));
        pageRef.getParameters().put('tk', String.valueOf('1234'));
        pageRef.getParameters().put('t', String.valueOf('123'));
        pageRef.getParameters().put('rtk', String.valueOf('123'));
        pageRef.getParameters().put('Iurl', String.valueOf('iframed'));
        pageRef.getParameters().put('Csid', String.valueOf(c.id));
        Test.setCurrentPage(pageRef);        
        NVM_PaymentController2 myPageCon = new NVM_PaymentController2();
        Test.setMock(HttpCalloutMock.class, new MockHttpNVMResponseGenerator());  // Added by Pankhuri 
        myPageCon.PaymentStatus();
        
        Test.stopTest(); 
     }


}