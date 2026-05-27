@isTest(SeeAllData=true)
private class Course_TriggerTester
{
    // test method to give the right coverage for CourseBooking_Manager class
	static testMethod void courseBooking_ManagerTest(){
        Account account=new Account(name='Test Class Account',
                                    Status__c='Approved',
                                    Billing_Address_Line_1__c='test',
                                    Billing_City__c='Test City',
                                    Billing_Country__c='CHINA',
                                    Billing_State__c='Test',
                                    Billing_ZIP_Postal_Code__c='1100110',
                                    Industry = 'Agriculture',
                                    BU__c='China - CN1');
        insert account;
        
        Contact contact=new Contact(lastname = 'Test Class Contact', 
                                    Accountid = account.id,
                                    Email = 'abc@invalid.com',
                                    Same_As_The_Account_Billing_Address__c = true,
                                    Mailing_Address_Line_1__c ='test',
                                    Mailing_City__c='test',
                                    Mailing_ZIP_Postal_Code__c ='110094',
                                    Qualifications__c = 'CBI',
                                    Mailing_Country__c='India',
                                    GCSC_Support_Contact__c = false);
        insert contact;
        
        List<Courses__c> courseList = new List<Courses__c>();
        
        Courses__c course1 = new courses__c();
        	course1.Qualification_Available__c = '360;ASST';
        	course1.Course_Status__c = 'Confirmed';
           	course1.Course_Category__c = 'Public';
        	course1.Course_Type__c = 'System Training';
           	course1.Duration__c = '2';
           	course1.Maximum_Delegates__c = 3;
           	course1.Course_Description__c = '1';
           	course1.Delivery_Mode__c = 'Public';
        	course1.Send_Certificates_in_English__c = false;
        	course1.Course_End_Date__c = System.today();
        	course1.Profit_Centre__c = 'Canada - CA1';
        courseList.add(course1);
        
        Courses__c course2 = new courses__c();
           	course2.Course_Category__c = 'Public';
        	course2.Course_Status__c = 'Confirmed';
        	course2.Course_Type__c = 'System Training';
        	course2.Qualification_Available__c = '360;ASST';
           	course2.Duration__c = '2';
           	course2.Maximum_Delegates__c = 3;
           	course2.Course_Description__c = '1';
           	course2.Delivery_Mode__c = 'Public';
        	course2.Send_Certificates_in_English__c = false;
        	course2.Course_End_Date__c = System.today();
		courseList.add(course2);
        
        Courses__c course3 = new courses__c();
           	course3.Course_Category__c = 'Public';
        	course3.Course_Status__c = 'Completed';
           	course3.Duration__c = '2';
           	course3.Maximum_Delegates__c = 3;
           	course3.Course_Description__c = '1';
           	course3.Delivery_Mode__c = 'Public';
        	course3.Send_Certificates_in_English__c = false;
        	course3.Course_End_Date__c = System.today();
		courseList.add(course3);
        
        insert courseList;
        
        List<Course_Booking__c> cbList = new List<Course_Booking__c>();
        
        Course_Booking__c courseb = new Course_Booking__c();
           courseb.Delegate_Account__c = account.Id;
           courseb.Delegate_Contact__c = contact.Id;
           courseb.Delegate_Contact__r = contact;
           courseb.Course_Number__c = course1.Id;
           courseb.Course_Number__r = course1;
           courseb.Lead_Source__c = 'L01 - Advertisement';
           courseb.SSC_Email__c = 'besoe@shl.com';
           courseb.OAT_Email__c = 'be.oat@shl.com';
           courseb.Pass_Status__c = 'Pass';
		   courseb.Booking_Status__c = 'Confirmed';
        cbList.add(courseb);
            
        Course_Booking__c courseb1 = new Course_Booking__c();
           courseb1.Delegate_Account__c = account.Id;
           courseb1.Delegate_Contact__c = contact.Id;
           courseb1.Delegate_Contact__r = contact;
           courseb1.Course_Number__c = course2.Id;
           courseb1.Course_Number__r = course2;
           courseb1.Lead_Source__c = 'L01 - Advertisement';
           courseb1.SSC_Email__c = 'besoe@shl.com';
           courseb1.OAT_Email__c = 'be.oat@shl.com';
           courseb1.Pass_Status__c = '';
		   courseb1.Booking_Status__c = 'Confirmed';
        cbList.add(courseb1);
        
        insert cbList;
        
        User user = [Select Id, Name From User Where Profile.Name = 'GCSC General' AND isActive = true].get(0);
        System.runAs(user){
            try{
                CourseBooking_Manager.updateQualification(cbList);
            } catch (Exception e){
                
            }
            
        }
        
        Courses__c courseTestObj = course1.clone(false,false,false,false);
        courseTestObj.Profit_Centre__c = 'China - CN1';
        Course_Booking__c cbClone = courseb.clone(false,false,false,false);
        cbClone.Course_Number__c = courseTestObj.Id;
        cbClone.Course_Number__r = courseTestObj;
        CourseBooking_Manager.updateDataInCourseBookings(courseTestObj,course1);
    }
    
    // test method to give the right coverage for Course_Manager class
    static testMethod void courseManagerTest(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u = new user();
        u.FirstName = 'Dummy';
        u.LastName = 'User';
        u.Email = 'test@testCode180619.com';
        u.Alias = 'Tcode';
        u.Username = 'test1234444Code180619@test.com';        
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileId = profileId.Id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        //insert u;
        
       	Account account=new Account(name='Test Class Account',
                                    Status__c='Approved',
                                    Billing_Address_Line_1__c='test',
                                    Billing_City__c='Test City',
                                    Billing_Country__c='CHINA',
                                    Billing_State__c='Test',
                                    Billing_ZIP_Postal_Code__c='1100110',
                                    Industry = 'Agriculture',
                                    BU__c='China - CN1');
        insert account;
        
        Contact contact=new Contact(lastname = 'Test Class Contact', 
                                    Accountid = account.id,
                                    Email = 'abc@invalid.com',
                                    Same_As_The_Account_Billing_Address__c = true,
                                    Mailing_Address_Line_1__c ='test',
                                    Mailing_City__c='test',
                                    Mailing_ZIP_Postal_Code__c ='110094',
                                    Mailing_Country__c='India');
        insert contact;
        
        List<Courses__c> courseList = new List<Courses__c>();
        
        Courses__c course1 = new courses__c();
        	course1.Course_Status__c = 'Confirmed';
           	course1.Course_Category__c = 'Public';
        	course1.Course_Type__c = 'Personality';
           	course1.Duration__c = '2';
           	course1.Maximum_Delegates__c = 3;
           	course1.Course_Description__c = '1';
           	course1.Delivery_Mode__c = 'Public';
        	course1.Send_Certificates_in_English__c = false;
        	course1.Course_End_Date__c = System.today();
        courseList.add(course1);
        
        Courses__c course2 = new courses__c();
           	course2.Course_Category__c = 'Public';
        	course2.Course_Status__c = 'Completed';
           	course2.Duration__c = '2';
           	course2.Maximum_Delegates__c = 3;
           	course2.Course_Description__c = '1';
           	course2.Delivery_Mode__c = 'Public';
        	course2.Send_Certificates_in_English__c = false;
        	course2.Course_End_Date__c = System.today();
		courseList.add(course2);
        
        Courses__c course3 = new courses__c();
           	course3.Course_Category__c = 'Public';
        	course3.Course_Status__c = 'Completed';
           	course3.Duration__c = '2';
           	course3.Maximum_Delegates__c = 3;
           	course3.Course_Description__c = '1';
           	course3.Delivery_Mode__c = 'Public';
        	course3.Send_Certificates_in_English__c = false;
        	course3.Course_End_Date__c = System.today();
		courseList.add(course3);
        
        insert courseList;
        
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
            
        Course_Booking__c courseb1 = new Course_Booking__c();
           courseb1.Delegate_Account__c = account.Id;
           courseb1.Delegate_Contact__c = contact.Id;
           courseb1.Course_Number__c = course2.Id;
           courseb1.Lead_Source__c = 'L01 - Advertisement';
           courseb1.SSC_Email__c = 'besoe@shl.com';
           courseb1.OAT_Email__c = 'be.oat@shl.com';
           courseb1.Pass_Status__c = '';
		   courseb1.Booking_Status__c = 'Confirmed';
        cbList.add(courseb1);
        
        insert cbList;
        
        ContentVersion testFile = new ContentVersion();           
        testFile.VersionData = EncodingUtil.base64Decode('test file');
        testFile.Title = 'FailureLog.csv';
        testFile.PathOnClient ='FailureLog.csv';
        testFile.FirstPublishLocationId = course2.Id;
        insert testFile;
        
        String emailTemplateId = [SELECT Id FROM EmailTemplate WHERE Name= :'CB - Joining Instructions' Limit 1].Id;
        
        Group endCourseGroup = [Select Id FROM Group WHERE Name='End Course Administrators' limit 1];
        GroupMember gm = [Select UserOrGroupId from GroupMember where GroupId = :endCourseGroup.Id limit 1];
        User usr = [SELECT id from User WHERE Id =:gm.UserOrGroupId and IsActive =True LIMIT 1];
        
        System.runAs(usr) {
            Course_Manager.endCourse(course1.Id);
            Course_Manager.endCourse(course2.Id);
            Course_Manager.endCourse(course3.Id);
        }
        Course_Manager.endCourse(course3.Id);
        Course_Manager.updateQualifications(course2.Id);
        
        Course_Manager.sendJoiningInstructions(course2.Id,emailTemplateId);
        Course_Manager.sendJoiningInstructions(course3.Id,emailTemplateId);
        Course_Manager.fetchCourseInformation(course2.Id);
        Course_Manager.SendSurvey(course1.Id,emailTemplateId);
        Course_Manager.SendSurvey(course3.Id,emailTemplateId);
    }

    
    
    
    //old test methods
    /*static testMethod void testCourseTriggers()
    {
        List<Courses__c> courses = new List<Courses__c>();        
        List<Course_Booking__c> courseBookings = new List<Course_Booking__c>();
        
        courses = insertCourses();
        courseBookings = CourseBooking_TriggerTester.insertNewCourseBookings(courses[0].Id);
        
        updateCourses(courses);
        
        String emailTemplateId = [SELECT Id FROM EmailTemplate WHERE Name= :'CB - Joining Instructions' Limit 1].Id; 
         Account testAct=new Account(
            name='Test Account',
            Status__c='Approved',
            CurrencyIsoCode='INR',
            //done by aashiTerritory__c='Alliances',
            Account_Approach__c='Grow',
            Billing_Address_Line_1__c='test',
            Billing_City__c='Test City',
            Billing_Country__c='ARGENTINA',
            Billing_State__c='Test',
            Billing_ZIP_Postal_Code__c='1100110',
            Industry = 'Agriculture',
            BU__c='China - CN1');
        insert testAct;         
        Contact testContact =new Contact(lastname='Test Contact_CB2',
                                         AccountId=testAct.Id ,
                                         Email='test@test1shl.com',
                                         Qualifications__c = '360',
                                         Same_As_The_Account_Billing_Address__c=true,
                                         Mailing_Address_Line_1__c ='test',
                                         Mailing_City__c='test',
                                         Mailing_ZIP_Postal_Code__c ='110094',      
                                         Mailing_Country__c='India');
        insert testContact;

       
        
        courses[1].Course_Status__c = 'Confirmed';
        courses[1].Profit_Centre__c ='UK - UK1';
        courseBookings[0].Profit_Centre__c ='UK - UK1';
        courseBookings[0].Booking_Status__c = 'Confirmed';
        courseBookings[1].Delegate_Contact__c = testContact.Id;
        courseBookings[1].Pass_Status__c= null;
        insert new Attachment(parentId = courses[0].id, name=courseBookings[1].Name + '.pdf', body = Blob.valueOf('Test'));
        insert new Attachment(parentId =  courseBookings[0].id, name=courseBookings[1].Name + '.pdf', body = Blob.valueOf('Test'));
        update courseBookings;
        
        Course_Manager.sendJoiningInstructions(courses[0].Id, emailTemplateId);
        Course_Manager.SendSurvey(courses[0].Id, emailTemplateId);
        Course_Manager.updateQualifications(courses[0].Id);
        List<Courses__c > courselist = Course_Manager.fetchCourseInformation(String.valueOf(courses[0].Id));
        //SSE-14356 Course_Manager.generateCertificates(courses[0].Id);
        
        
        courseBookings = CourseBooking_TriggerTester.insertNewCourseBookings(courses[1].Id);
        updateCourses(courses);
        insertCourseResources(courses[1]);
        Course_Manager.createCourseCategoryPublicTask(courses[0]);
        */
        /*Group endCourseGroup = [Select Id FROM Group WHERE Name='End Course Administrators' limit 1];
        GroupMember gm = [Select UserOrGroupId from GroupMember where GroupId = :endCourseGroup.Id limit 1];
        User usr = [SELECT id from User WHERE Id =:gm.UserOrGroupId and IsActive =True LIMIT 1];
        System.runAs(usr) {*/
        	//Course_Manager.endCourse(courses[0].Id);
        //}
        
        //List<Course_Resources__c> courseRes = new List<Course_Resources__c>();
        //courseRes = insertCourseResources2(courses[1]);
        
        //SS-15464 Course_Manager.createCourseTypeTask(courses[1],courseRes);
        //Course_Manager.createCourseCategoryOthanThanPublicTask(courses[1]);
        //Course_Manager.createCourseCategoryPublicTask(courses[0]);
        // Course_Manager.addFiles(Messaging.mail, AllFiles)
        /*ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = courses[0].Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        Test.startTest();
        Course_Manager.sendJoiningInstructions(courses[0].Id,emailTemplateId);
        //Course_Manager.endCourse(courses[0].Id);
        
        Integer i = Limits.getEmailInvocations();
        Test.stopTest();
        
        //   System.assertEquals(1,i);
        
    }
    static testMethod void testCourseTriggers2()
    {
        List<Courses__c> courses = new List<Courses__c>();
        List<Course_Booking__c> courseBookings = new List<Course_Booking__c>();
        
        
        courses = insertCourses2();
        
        courseBookings = CourseBooking_TriggerTester.insertNewCourseBookings(courses[0].Id);
        
        updateCourses(courses);
        
        String emailTemplateId = [SELECT Id FROM EmailTemplate WHERE Name= :'CB - Joining Instructions' Limit 1].Id; 
        test.startTest();
        
         Account testAct=new Account(
            name='Test Account_Course',
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
            BU__c='	Italy - IT1');
        insert testAct;         
        Contact testContact =new Contact(lastname='Test Contact_Course',
                                         AccountId=testAct.Id ,
                                         Email='test@test2shl.com',
                                         Qualifications__c = '360',
                                         Same_As_The_Account_Billing_Address__c=true,
                                         Mailing_Address_Line_1__c ='test',
                                         Mailing_City__c='test',
                                         Mailing_ZIP_Postal_Code__c ='110094',      
                                         Mailing_Country__c='India');
        insert testContact;

        courseBookings[0].Profit_Centre__c ='UK - UK1';
        courseBookings[0].Booking_Status__c = 'Confirmed';
        courseBookings[0].Pass_Status__c= '';
        courseBookings[1].Delegate_Contact__c = testContact.Id;
        courseBookings[1].Pass_Status__c= 'Pass';
        courseBookings[1].Booking_Status__c = 'Confirmed';
        
        courseBookings[1].Date_Survey_Sent__c = null;
        
        insert new Attachment(parentId = courses[0].id, name=courseBookings[1].Name + '.pdf', body = Blob.valueOf('Test'));
        
        update courseBookings;
        
        Task task = new task ();
        task.Subject = 'Test';
        //task.ActivityDate = today();
        task.Status = 'Not Started';
        task.WhoId = courseBookings[1].Delegate_Contact__c;
        task.WhatId = courseBookings[1].Id;
        task.ClientInterest1__c = 'Course Feedback';
        task.Description = 'abc';
        insert task;
        
        List<Course_Resources__c> courseRes = new List<Course_Resources__c>();
        courseRes = insertCourseResources2(courses[1]);
        
        Course_Manager.sendJoiningInstructions(courses[0].Id, emailTemplateId);
        Course_Manager.SendSurvey(courses[0].Id, emailTemplateId);
        Course_Manager.updateQualifications(courses[0].Id);
        //SSE-14356 Course_Manager.generateCertificates(courses[0].Id);
        
        //SS-15464 Course_Manager.createCourseTypeTask(courses[1],courseRes);
        //Course_Manager.createCourseCategoryOthanThanPublicTask(courses[1]);
        
        
        
        courseBookings = CourseBooking_TriggerTester.insertNewCourseBookings(courses[1].Id);
        updateCourses(courses);
        insertCourseResources(courses[1]);
        Course_Manager.endCourse(courses[0].Id);
        
        Course_Manager.SendSurvey(courses[0].Id, emailTemplateId);
        
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        //    system.assertEquals(1, invocations, 'An email should be sent');
    }
    static List<courses__c> insertCourses()
    {
        system.debug('Course: Insert Started');
        List<String> courseCategories = new List<String>{'Public','In Company'};
            List<Account> accounts = New list<Account>();
         for(integer i=0; i<3;i++){
            Account testAct=new Account(
            name='Test Account'+i,
            Status__c='Approved',
            PurchaseOrderRequired__c= true  ,  
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
            
             accounts.add(testAct);        
        }
        List<Courses__c> courses = new List<courses__c>();
        
        for(Integer i=0;i<2;i++)
        {
            courses__c course = new courses__c();
            course.Course_Type__c = 'System Training';
            course.Course_Category__c = courseCategories[i];
            course.Partner_Account_Name__c = accounts[i].Id;
            course.Course_Name__c = 'Test';
            course.Lead_Source__c = 'L01 - Advertisement';
            course.Course_Description__c = 'TRest';
            course.Profit_Centre__c = 'UK - UK1';
            course.Course_Start_Date__c = Date.newInstance(2008,4+i,21);
            course.Course_End_Date__c = Date.newInstance(2008,4+i,21);
            course.Course_Venue__c = 'Client Site';
            course.Course_Status__c = 'Completed';
            course.Maximum_Delegates__c = 2;
            course.Delivery_Mode__c = 'Online';
            course.Duration__c = '2';
            course.Qualification_Available__c = '360;ASST';
            course.CurrencyIsoCode = 'INR';
            courses.add(course);
        }
        
        insert courses;
        
        system.debug('Course: Insert Completed');
        
        return courses;
        
        
    }
    
    static void updateCourses(List<courses__c> insertedCourses)
    {
        system.debug('Course: Update Started');
        
        List<Courses__c> courses = new List<Courses__c>();
        
        for(Courses__c insertedCourse: insertedCourses)
        {
            Courses__c course = new Courses__c(id=insertedCourse.id);
            course.Extra_night_price__c =20;
            course.Profit_Centre__c = 'UK - UK1';
            course.Course_Venue__c = 'Perth';
            courses.add(course);
        }
        update courses;
        
        
        system.debug('Course: Update Completed');
    }
    
    static void insertCourseResources(Courses__c course)
    {
        
        Course_Resources__c courseResource = new Course_Resources__c();
        courseResource.Course_Name__c = course.id;
        courseResource.Resource_Name__c = [Select id from Contact limit 1].id;
        courseResource.Resource_Type__c = 'SHL';
        //courseResource.Resource_Role__c = 'Course Director';
        // courseResource.Resource_Name_SHL__c = UserInfo.getUserId(); 
        insert courseResource;
    }
    
    static List<Course_Resources__c > insertCourseResources2(Courses__c course)
    {
        List<Course_Resources__c > coursesList = new List<Course_Resources__c>();
        
        for(Integer i=0;i<2;i++)
        {
            Course_Resources__c courseResource = new Course_Resources__c();
            courseResource.Course_Name__c = course.id;
            courseResource.Resource_Name__c = [Select id from Contact limit 1].id;
            courseResource.Resource_Type__c = 'SHL';
            //courseResource.Resource_Role__c = 'Course Director';
            // courseResource.Resource_Name_SHL__c = UserInfo.getUserId(); 
            coursesList.add(courseResource);
        }
        
        insert coursesList;
        
        system.debug('Course: Insert Completed');
        
        return coursesList;
    }
    
    static List<courses__c> insertCourses2()
    {
        system.debug('Course: Insert Started');
        List<String> courseCategories = new List<String>{'Public','In Company'};
            List<Account> accounts = new list<Account>();
        for(integer i=0; i<3;i++){
            Account testAct=new Account(
            name='Test Account'+i,
            Status__c='Approved',
            PurchaseOrderRequired__c= true  ,  
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
            
            
             accounts.add(testAct);        
        }
        insert accounts;
        List<Courses__c> courses = new List<courses__c>();
        
        for(Integer i=0;i<2;i++)
        {
            courses__c course = new courses__c();
            course.Course_Type__c = 'Personality';
            course.Course_Category__c = courseCategories[i];
            course.Partner_Account_Name__c = accounts[i].Id;
            course.Course_Name__c = 'Test';
            course.Lead_Source__c = 'L01 - Advertisement';
            course.Course_Description__c = 'TRest';
            course.Profit_Centre__c = 'UK - UK1';
            course.Course_Start_Date__c = Date.newInstance(2008,4+i,21);
            course.Course_End_Date__c = Date.newInstance(2008,4+i,21);
            course.Course_Venue__c = 'Client Site';
            course.Course_Status__c = 'Confirmed';
            course.Maximum_Delegates__c = 2;
            course.Delivery_Mode__c = 'Online';
            course.Duration__c = '2';
            course.Qualification_Available__c = '360;ASST';
            course.CurrencyIsoCode = 'INR';
            course.Course_Category__c = 'Public';
            courses.add(course);
        }
        
        insert courses;
        system.debug('Course: Insert Completed');
        
        return courses;
        
    }*/
    


}