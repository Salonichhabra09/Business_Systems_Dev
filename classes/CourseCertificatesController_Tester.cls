@isTest(seeAlldata=true)
public class CourseCertificatesController_Tester {
    @isTest static void checkUserPermissionsTest() {
        Test.startTest();
        String result = CourseCertificatesController.checkUserPermissions();
        
        System.assertEquals('ALL', result);
        Test.stopTest();
    }
    
    @isTest static void save_delete_PartnerLogoTest() {
        Test.startTest();
        contact ct = new contact();
           ct.lastname='User';
           ct.firstname= 'firstname';
           ct.email='test@test.com';
           ct.Mailing_Address_Line_1__c ='true address';
           ct.Mailing_City__c='testcity';
           ct.Mailing_ZIP_Postal_Code__c='334001';
           ct.Mailing_Country__c='India';
         insert ct;  
        
        Courses__c courseRec  = new Courses__c();
           courseRec.Course_Director__c = ct.id;
           courseRec.Duration__c='12';
           courseRec.Maximum_Delegates__c=12;
           courseRec.Course_Description__c='description';
           courseRec.Course_Name__c='test';
		insert courseRec; 
       	Courses__c courseRec2  = new Courses__c();
           courseRec2.Course_Director__c = ct.id;
           courseRec2.Duration__c='13';
           courseRec2.Maximum_Delegates__c=13;
           courseRec2.Course_Description__c='description2';
           courseRec2.Course_Name__c='test2';
        insert courseRec2;
        
        String partnerLogoData = 'image';
        String name = 'logo';
        Id courseId = courseRec.id;
        String fileType = 'png';
        
        	String result = CourseCertificatesController.savePartnerLogo(partnerLogoData, name, courseId, fileType);
        	String resultError = CourseCertificatesController.savePartnerLogo('', '', courseId , fileType);
        	String resultDelete = CourseCertificatesController.deletePartnerLogo(courseId);
        	String resultDeleteError = CourseCertificatesController.deletePartnerLogo(ct.Id);
        
        System.assertEquals('SUCCESS', result);
        System.assertNotEquals('SUCCESS', resultError);
        System.assertEquals('SUCCESS', resultDelete);
        System.assertNotEquals('SUCCESS', resultDeleteError);
        Test.stopTest();
    }
    
    @isTest static void getDataTest(){
        Test.startTest();
		Account account=new Account(name='Test Class Account',
                                    Status__c='Approved',
                                    Billing_Address_Line_1__c='test',
                                    Billing_City__c='Test City',
                                    Billing_Country__c='CHINA',
                                    Billing_State__c='Test',
                                    Billing_ZIP_Postal_Code__c='1100110',
                                    BU__c='China - CN1',
                                    Industry='Agriculture');
        insert account;
        
        List<Contact> conList = new List<Contact>();
        Contact contact=new Contact(lastname='Test Class Contact', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        conList.add(contact);
        
        Contact contact2=new Contact(lastname='Test Class Contact 2', Accountid=account.id);
        contact2.Same_As_The_Account_Billing_Address__c=true;
        contact2.Mailing_Address_Line_1__c ='test 2';
        contact2.Mailing_City__c='test';
        contact2.Mailing_ZIP_Postal_Code__c ='110094';
        contact2.Mailing_Country__c='India';
        conList.add(contact2);
        
        Contact contact3=new Contact(lastname='Test Class Contact 3', Accountid=account.id);
        contact3.Same_As_The_Account_Billing_Address__c=true;
        contact3.Mailing_Address_Line_1__c ='test 3';
        contact3.Mailing_City__c='test';
        contact3.Mailing_ZIP_Postal_Code__c ='110094';
        contact3.Mailing_Country__c='India';
        conList.add(contact3);
        
        insert conList;
        
		courses__c course1 = new courses__c();
           	course1.Course_Category__c = 'Public';
           	course1.Duration__c = '2';
           	course1.Maximum_Delegates__c = 3;
           	course1.Course_Description__c = '1';
           	course1.Delivery_Mode__c = 'Public';
        	course1.Send_Certificates_in_English__c = false;
        	course1.Course_End_Date__c = System.today();
        insert course1;
        
        courses__c course2 = new courses__c();
           	course2.Course_Category__c = 'Public';
           	course2.Duration__c = '2';
           	course2.Maximum_Delegates__c = 3;
           	course2.Course_Description__c = '1';
           	course2.Delivery_Mode__c = 'Public';
        	course2.Send_Certificates_in_English__c = false;
        	course2.Course_End_Date__c = System.today();
        insert course2;
        
        List<Course_Booking__c> cbList = new List<Course_Booking__c>();
        
        Course_Booking__c courseb = new Course_Booking__c();
           courseb.Delegate_Account__c = account.Id;
           courseb.Delegate_Contact__c = contact.Id;
           courseb.Course_Number__c = course1.Id;
           courseb.Lead_Source__c = 'L01 - Advertisement';
           courseb.SSC_Email__c = 'besoe@shl.com';
           courseb.OAT_Email__c = 'be.oat@shl.com';
           courseb.Pass_Status__c = 'Pass';
		   courseb.Booking_Status__c = 'Confirmed';
        	
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
        
       Course_Booking__c courseb3 = new Course_Booking__c();
           courseb3.Delegate_Account__c = account.Id;
           courseb3.Delegate_Contact__c = contact3.Id;
           courseb3.Course_Number__c = course1.Id;
           courseb3.Lead_Source__c = 'L01 - Advertisement';
           courseb3.SSC_Email__c = 'besoe@shl.com';
           courseb3.OAT_Email__c = 'be.oat@shl.com';
           courseb3.Pass_Status__c = ' ';

        insert cbList;
        
        
        List<CourseCertificatesController.PdfDataWrapper> resultList = CourseCertificatesController.getPdfData(course1.Id);
        List<CourseCertificatesController.PdfDataWrapper> resultListNOCB = CourseCertificatesController.getPdfData(course2.Id);
        List<CourseCertificatesController.PdfDataWrapper> resultListNOCourse = CourseCertificatesController.getPdfData(courseb3.Id);
        
        System.assertEquals('SUCCESS', resultList[0].resultMessage);
        System.assertEquals('NO CB', resultListNOCB[0].resultMessage);
        System.assertEquals('NO COURSE', resultListNOCourse[0].resultMessage);
        Test.stopTest();
    }
    
    @isTest static void sendPDFTest(){
        Test.startTest();
        Account account=new Account(name='Test Class Account',
                                    Status__c='Approved',
                                    Billing_Address_Line_1__c='test',
                                    Billing_City__c='Test City',
                                    Billing_Country__c='CHINA',
                                    Billing_State__c='Test',
                                    Billing_ZIP_Postal_Code__c='1100110',
                                    BU__c='China - CN1',Industry='Agriculture');
        insert account;
        
        List<Contact> conList = new List<Contact>();
        Contact contact=new Contact(lastname='Test Class Contact', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        conList.add(contact);
        insert conList;
        
      	courses__c course1 = new courses__c();
           	course1.Course_Category__c = 'Public';
           	course1.Duration__c = '2';
           	course1.Maximum_Delegates__c = 3;
           	course1.Course_Description__c = '1';
           	course1.Delivery_Mode__c = 'Public';
        	course1.Send_Certificates_in_English__c = true;
        	course1.Course_End_Date__c = System.today();
        	course1.Profit_Centre__c = 'Canada - CA1';
        	course1.Delivery_Language__c = '';
        
        insert course1;
       
        List<Course_Booking__c> cbList = new List<Course_Booking__c>();
        Course_Booking__c courseb = new Course_Booking__c();
           courseb.Delegate_Account__c = account.Id;
           courseb.Delegate_Contact__c = contact.Id;
           courseb.Course_Number__c = course1.Id;
           courseb.Lead_Source__c = 'L01 - Advertisement';
           courseb.SSC_Email__c = 'besoe@shl.com';
           courseb.OAT_Email__c = 'be.oat@shl.com';
           courseb.Pass_Status__c = 'Pass';
		   courseb.Booking_Status__c = 'Confirmed';
        	
        cbList.add(courseb);
        insert cbList;
        
        CourseCertificatesController.PdfDataGeneratedWrapper input = new CourseCertificatesController.PdfDataGeneratedWrapper();
        input.cbId = courseb.Id;
        input.pdfBase64String = 'dGVzdCBjbGFzcw==';
		List<CourseCertificatesController.PdfDataGeneratedWrapper> pdfDataObj_List  = new List<CourseCertificatesController.PdfDataGeneratedWrapper>();
        pdfDataObj_List.add(input);
        
        
        String result = CourseCertificatesController.sendPDF (pdfDataObj_List);
        
        System.assertNotEquals('SUCCESS', result);
        Test.stopTest();
    }
    
}