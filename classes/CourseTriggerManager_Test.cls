@isTest(SeeAllData=true)
public class CourseTriggerManager_Test {
    static testMethod void testassignCourseDirector(){
        CourseTriggerManager.assignCourseDirector(insertCourses());
    }
    
    static testMethod void testcopyDataFromCourse(){
        List<courses__c> courses=insertCourses();
        CourseTriggerManager.copyDataFromCourse(CourseBooking_TriggerTester.insertNewCourseBookings(courses[0].Id), courses);
    }    
    
    static testMethod void testupdateDataInCourseBookings(){
        

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
        
        List<Contact> conList = new List<Contact>();
        Contact contact=new Contact(lastname='Test Class Contact', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        conList.add(contact);
        
        Contact contact1=new Contact(lastname='Test Class Contact1', Accountid=account.id);
        contact1.Same_As_The_Account_Billing_Address__c=true;
        contact1.Mailing_Address_Line_1__c ='test1';
        contact1.Mailing_City__c='test1';
        contact1.Mailing_ZIP_Postal_Code__c ='1100941';
        contact1.Mailing_Country__c='India';
        conList.add(contact1);
        
        insert conList;
        Courses__c course = new courses__c();
            course.Course_Type__c = 'System Training';
            course.Course_Category__c = 'Public';
            course.Partner_Account_Name__c = account.Id;
            course.Course_Name__c = 'Test';
            course.Lead_Source__c = 'L01 - Advertisement';
            course.Course_Description__c = 'TRest';
            course.Profit_Centre__c = 'UK - UK1';
            course.Course_Start_Date__c = Date.newInstance(2008,4,21);
            course.Course_End_Date__c = Date.newInstance(2008,5,21);
            course.Course_Venue__c = 'Client Site';
            course.Course_Status__c = 'Completed';
            course.Maximum_Delegates__c = 2;
            course.Delivery_Mode__c = 'Online';
            course.Duration__c = '2';
            course.Qualification_Available__c = '360;ASST';
            course.CurrencyIsoCode = 'INR';
        insert course;
        
        List<Course_Booking__c> cbList = new List<Course_Booking__c>();
        
        Course_Booking__c courseb = new Course_Booking__c();
           courseb.Delegate_Account__c = account.Id;
           courseb.Delegate_Contact__c = contact.Id;
           courseb.Course_Number__c = course.Id;
           courseb.Lead_Source__c = 'L01 - Advertisement';
           courseb.SSC_Email__c = 'besoe@shl.com';
           courseb.OAT_Email__c = 'be.oat@shl.com';
           courseb.Pass_Status__c = 'Pass';
		   courseb.Booking_Status__c = 'Confirmed';
       cbList.add(courseb);
        
        Course_Booking__c courseb1 = new Course_Booking__c();
           courseb1.Delegate_Account__c = account.Id;
           courseb1.Delegate_Contact__c = contact1.Id;
           courseb1.Course_Number__c = course.Id;
           courseb1.Lead_Source__c = 'L01 - Advertisement';
           courseb1.SSC_Email__c = 'besoe@shl.com';
           courseb1.OAT_Email__c = 'be.oat@shl.com';
           courseb1.Pass_Status__c = 'Pass';
		   courseb1.Booking_Status__c = 'Confirmed';	
        cbList.add(courseb1);
        
        insert cbList;
        
        List<courses__c> newList = new List<courses__c>();
        List<courses__c> oldList = new List<courses__c>();
        
        Courses__c oldC = course.clone(true, true, true, true);
        oldList.add(oldC);
        
        course.Profit_Centre__c = 'Australia - AU1';
        update course;
        newList.add(course);

        CourseTriggerManager.updateDataInCourseBookings(oldList, newList);
       
    }
    static testmethod void testCoureTrigger(){
        updateCourses(insertCourses());
    }
    static void updateCourses(List<courses__c> insertedCourses)
    {
        List<courses__c> Courses= new List<courses__c>();
        
        for(courses__c cou: insertedCourses)
        {
            courses__c Course = new courses__c(id=cou.id);
            Course.CurrencyIsoCode = 'USD';
            course.Course_Start_Date__c = Date.newInstance(2008,4,22);
            course.Course_End_Date__c = Date.newInstance(2008,4,22);
            Courses.add(Course);
        }
        update Courses;
    }  
    
 
    static List<courses__c> insertCourses()
    {
        List<String> courseCategories = new List<String>{'Public','In Company'};
        List<Account> accounts = new List<Account>();
          for(integer i=0; i<3;i++){
            Account testAct=new Account(
            name='Test Account'+i,
            Status__c='Approved',
            PurchaseOrderRequired__c= true  ,  
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
            
             accounts.add(testAct);        
        }
        insert accounts;
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
            course.Course_Status__c = 'Confirmed';
            course.Maximum_Delegates__c = 2;
            course.Delivery_Mode__c = 'Online';
            course.Duration__c = '2';
            course.Qualification_Available__c = '360;ASST';
            course.CurrencyIsoCode = 'INR';
            courses.add(course);
        }
        insert courses;    
        return courses;
     }
    

}