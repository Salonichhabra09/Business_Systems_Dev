@isTest(seeAlldata=true)
public class ContactBulkController_Tester {
    //private static final User ADMIN = [Select Id From User Where Profile.Name = 'System Administrator' And IsActive = true Limit 1];
    
	@isTest static void getCourseTest() {
        Test.startTest();
        contact ct = new contact();
           ct.lastname='Generic User';
           ct.firstname= 'firstname';
           ct.email='genericuser@test.com';
           ct.Mailing_Address_Line_1__c ='true address';
           ct.Mailing_City__c='testcity';
           ct.Mailing_ZIP_Postal_Code__c='334001';
           ct.Mailing_Country__c='India';
           
        
        Courses__c courseRec  = new Courses__c();
           courseRec.Course_Director__c = ct.id;
           courseRec.Duration__c='12';
           courseRec.Maximum_Delegates__c=12;
           courseRec.Course_Description__c='description';
           courseRec.Course_Name__c='test';
        
        Courses__c courseRec2 ;

        insert ct;
        insert courseRec;   
            
        courseRec2 = ContactBulkController.getCourse(courseRec.Id);

        System.assertEquals(courseRec.Id, courseRec2.Id);
        Test.stopTest();
    }
    
    
    @isTest static void getAccountsTest() {
        Test.startTest();
		Account account=new Account(
                        name='Test Account',
                        Status__c='Approved',
                        CurrencyIsoCode='INR',
                        //done by aashi Territory__c='Alliances',
                        Account_Approach__c='Grow',
                        Billing_Address_Line_1__c='test',
                        Billing_City__c='Test City',
                        Billing_Country__c='ARGENTINA',
                        Billing_State__c='Test',
                        Billing_ZIP_Postal_Code__c='1100110',
            			Industry = 'Agriculture',
                        BU__c='China - CN1');
		insert account;
        Account accountDetails=[select id, Account_Number__c from Account where id=:account.id];
        List<String> accountsNumber = new List<String>();
        accountsNumber.add(accountDetails.Account_Number__c);
        
        List<Account> accs = ContactBulkController.getAccounts(accountsNumber);
        
        System.assertEquals(accountDetails.Id, accs[0].Id);	
   		Test.stopTest();
    }
    
    
    @isTest static void saveCourseBookingsTest() {
        Test.startTest();
        Account account=new Account(name='Test Class Account',
                                    Status__c='Approved',
                                    Billing_Address_Line_1__c='test',
                                    Billing_City__c='Test City',
                                    Billing_Country__c='ARGENTINA',
                                    Billing_State__c='Test',
                                    Billing_ZIP_Postal_Code__c='1100110',
                                    Industry = 'Agriculture',
                                    BU__c='China - CN1');
        insert account;
        
        List<Contact> conList = new List<Contact>();
        Contact contact=new Contact(lastname='Test Class Contact', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        contact.Email = 'con1@test.com';
        conList.add(contact);


        Contact contact2=new Contact(lastname='Test Dell 2', Accountid=account.id);
        contact2.Same_As_The_Account_Billing_Address__c=true;
        contact2.Mailing_Address_Line_1__c ='test 2';
        contact2.Mailing_City__c='test';
        contact2.Mailing_ZIP_Postal_Code__c ='110094';
        contact2.Mailing_Country__c='India';
        contact2.Email = 'con2@test.com';
        conList.add(contact2);
        
        Contact contact3=new Contact(lastname='Class Contact 3', Accountid=account.id);
        contact3.Same_As_The_Account_Billing_Address__c=true;
        contact3.Mailing_Address_Line_1__c ='test 3';
        contact3.Mailing_City__c='test';
        contact3.Mailing_ZIP_Postal_Code__c ='110094';
        contact3.Mailing_Country__c='India';
        contact3.Email = 'con3@test.com';
        conList.add(contact3);
        
        insert conList;
        
		courses__c course1 = new courses__c();
           course1.Course_Category__c = 'Public';
           course1.Duration__c = '2';
           course1.Maximum_Delegates__c = 3;
           course1.Course_Description__c = '1';
           insert course1;
        
        List<Course_Booking__c> cbList = new List<Course_Booking__c>();
        
        Course_Booking__c courseb = new Course_Booking__c();
           courseb.Delegate_Account__c = account.Id;
           courseb.Delegate_Contact__c = contact.Id;
           courseb.Course_Number__c = course1.Id;
           courseb.Lead_Source__c = 'L01 - Advertisement';
           courseb.SSC_Email__c = 'besoe@shl.com';
           courseb.OAT_Email__c = 'be.oat@shl.com';
           courseb.Pass_Status__c = ' ';
        cbList.add(courseb);
        
        Course_Booking__c courseb2 = new Course_Booking__c();
           courseb2.Delegate_Account__c = account.Id;
           courseb2.Delegate_Contact__c = contact2.Id;
           courseb2.Course_Number__c = course1.Id;
           courseb2.Lead_Source__c = 'L01 - Advertisement';
           courseb2.SSC_Email__c = 'besoe@shl.com';
           courseb2.OAT_Email__c = 'be.oat@shl.com';
           courseb2.Pass_Status__c = ' ';
       cbList.add(courseb2);
       insert cbList;
        
       Course_Booking__c courseb3 = new Course_Booking__c();
           courseb3.Delegate_Account__c = account.Id;
           courseb3.Delegate_Contact__c = contact3.Id;
           courseb3.Course_Number__c = course1.Id;
           courseb3.Lead_Source__c = 'L01 - Advertisement';
           courseb3.SSC_Email__c = 'besoe@shl.com';
           courseb3.OAT_Email__c = 'be.oat@shl.com';
           courseb3.Pass_Status__c = ' ';

         
        
        
        List<Course_Booking__c> courseBookingList = new List<Course_Booking__c>();
        courseBookingList.add(courseb3);
        
        
        ContactBulkController.ContactInsertResultWrapper result = new ContactBulkController.ContactInsertResultWrapper();
        result = ContactBulkController.saveCourseBookings(courseBookingList);
        System.assertEquals(true, result.insertedCB);
        
        ContactBulkController.ContactInsertResultWrapper result2 = new ContactBulkController.ContactInsertResultWrapper();
        result2 = ContactBulkController.saveCourseBookings(cbList);
        System.assertEquals('Duplicate Course Booking! This Course already has a Course Booking with this Delegate Contact.', result2.errorMessage);
        
        Test.stopTest();
        
    }
    
    
    @isTest static void saveContactsTest(){
        Test.startTest();
    	Account account=new Account(name='Test Class 2 Account',
                                    Status__c='Approved',
                                    Billing_Address_Line_1__c='test',
                                    Billing_City__c='Test City',
                                    Billing_Country__c='ARGENTINA',
                                    Billing_State__c='Test',
                                    Billing_ZIP_Postal_Code__c='1100110',
                                    Industry = 'Agriculture',
                                    BU__c='China - CN1');
        insert account;
        
        List<Contact> conList = new List<Contact>();
        Contact contact=new Contact(lastname='Test Class Contact1', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        contact.Email = 'abc@invalid.com';
        conList.add(contact);


        Contact contact2=new Contact(lastname='Test Class Contact2', Accountid=account.id);
        contact2.Same_As_The_Account_Billing_Address__c=true;
        contact2.Mailing_Address_Line_1__c ='test 2';
        contact2.Mailing_City__c='test';
        contact2.Mailing_ZIP_Postal_Code__c ='110094';
        contact2.Mailing_Country__c='India';
        contact2.Email = 'abc@invalid2.com';
        conList.add(contact2);
        
        Contact contact3=new Contact(lastname='Test Class Contact3', Accountid=account.id);
        contact3.Same_As_The_Account_Billing_Address__c=true;
        contact3.Mailing_Address_Line_1__c ='test 3';
        contact3.Mailing_City__c='test';
        contact3.Mailing_ZIP_Postal_Code__c ='110094';
        contact3.Mailing_Country__c='India';
        contact3.Email = 'abc@invalid2.com';
        conList.add(contact3);
        
        Contact contact5=new Contact(lastname='Test Class Contact5', Accountid=account.id);
        contact5.Same_As_The_Account_Billing_Address__c=true;
        contact5.Mailing_Address_Line_1__c ='test 5';
        contact5.Mailing_City__c='test';
        contact5.Mailing_ZIP_Postal_Code__c ='110094';
        contact5.Mailing_Country__c='India';
        contact5.Email = 'abc@invalid.com';
        insert contact5;
        
            ContactBulkController.ContactInsertResultWrapper result = new ContactBulkController.ContactInsertResultWrapper();
            result = ContactBulkController.saveContacts(conList);
           // System.assertEquals(1, result.insertedContacts.size());
        
			List<Contact> conList2 = new List<Contact>();
            Contact contact4=new Contact(lastname='Test Class Contact4', Accountid=account.id);
            contact4.Same_As_The_Account_Billing_Address__c=true;
            contact4.Mailing_Address_Line_1__c ='test 4';
            contact4.Mailing_City__c='test';
            contact4.Mailing_ZIP_Postal_Code__c ='110094';
            contact4.Mailing_Country__c='India';
            contact4.Email = 'abc@invalid2.com';
        	conList2.add(contact4);
        
            ContactBulkController.ContactInsertResultWrapper result2 = new ContactBulkController.ContactInsertResultWrapper();
            result2 = ContactBulkController.saveContacts(conList2);
        	ContactBulkController.ContactInsertResultWrapper result3 = ContactBulkController.saveContacts(conList2);
           // System.assertNotEquals(null, result2.errorMessage);
           // System.assertEquals(0, result2.insertedContacts.size());    
        Test.stopTest();

    }
}