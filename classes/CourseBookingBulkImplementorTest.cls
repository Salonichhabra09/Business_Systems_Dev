/*************This Component is used to handle the creation of Bulk Course Booking from the Courses. ************************
*             Created By: Prachi Gupta(prachi.gupta@shl.com)                                                                *                      
*             Created Date: 28-04-2022                                                                                      *
*****************************************************************************************************************************/

@isTest
public class CourseBookingBulkImplementorTest{

    @isTest(seealldata=true) 
    
    //Test Method For having Duplicate CB for Course.
    static void testMethod1(){
        
        test.StartTest();
        Account testAct=new Account(name='Test Account_CB',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                    Billing_Country__c='CHINA',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert testAct;
        Contact testCont =CreateTestData.getContact(testAct.id);  
        Contact testContact =new Contact(lastname='Test Contact_CB',
                                         AccountId=testAct.Id ,
                                         Same_As_The_Account_Billing_Address__c=true,
                                         Mailing_Address_Line_1__c ='test',
                                         Mailing_City__c='test',
                                         Mailing_ZIP_Postal_Code__c ='110094',      
                                         Mailing_Country__c='India');
        insert testContact;
        
        Courses__c testCourses = new Courses__c(Course_Type__c = 'System' ,Course_Description__c = 'Test',Duration__c = '5',
                                               Profit_Centre__c = 'Canada - CA1' ,Course_Start_Date__c = system.today() ,
                                               Course_End_Date__c = system.today(), Course_Status__c = 'Provisional' , Delivery_Mode__c = 'Online',
                                               Survey_Language__c = 'EN-GB', Course_Name__c = 'FS' , Course_BU__c = 'Canada', Maximum_Delegates__c = 10);
        
        insert testCourses;
        
         Course_Booking__c cb = new Course_Booking__c(Course_Number__c = testCourses.iD , Delegate_Contact__c = testContact.Id ,Booking_Status__c = 'Confirmed');
       insert cb;
        
       Courses__c courseData = CourseBookingBulkImplementor.getCourseData(testCourses.iD);
       Decimal fs = courseData.Course_Free_Spaces__c; 
       system.assertEquals(testCourses.iD , courseData.iD) ;
       List<Course_Booking__c> courseBookingList = new List<Course_Booking__c>();
        for(integer i=0;i<2;i++){
            Course_Booking__c cb2 = new Course_Booking__c(Course_Number__c = testCourses.iD , Delegate_Contact__c = testContact.Id ,Booking_Status__c = 'Confirmed');
            courseBookingList.add(cb2); 
            
        }
        
         Course_Booking__c cb3 = new Course_Booking__c(Course_Number__c = testCourses.iD , Delegate_Contact__c = testCont.Id ,Booking_Status__c = 'Confirmed');
         courseBookingList.add(cb3); 
         CourseBookingBulkImplementor.CBResultWrapper CBR = new CourseBookingBulkImplementor.CBResultWrapper();
         CBR = CourseBookingBulkImplementor.saveCourseBookings(courseBookingList,fs);  
         system.assertEquals('1 Course Bookings records saved successfully', CBR.Message) ;
         system.assertEquals('Success', CBR.MessageType) ;
        test.stopTest();
        
    }
    
    //Test Method For Course having no existing CB.
    @isTest(seealldata=true) 
    static void testMethod2(){
         List<Course_Booking__c> courseBookingList = new List<Course_Booking__c>();  
       
        test.startTest();
        //Test Data
        Account testAct=new Account(name='Test Account_CB',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='CHINA',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert testAct;
        Contact testCont =CreateTestData.getContact(testAct.id); 
        Courses__c testCourses = new Courses__c(Course_Type__c = 'System' ,Course_Description__c = 'Test',Duration__c = '5',
                                               Profit_Centre__c = 'Canada - CA1' ,Course_Start_Date__c = system.today() ,
                                               Course_End_Date__c = system.today(), Course_Status__c = 'Provisional' , Delivery_Mode__c = 'Online',
                                               Survey_Language__c = 'EN-GB', Course_Name__c = 'FS' , Course_BU__c = 'Canada', Maximum_Delegates__c = 10);
      
        insert testCourses;
        
         Contact testContact =new Contact(lastname='Test Contact_CB',
                                         AccountId=testAct.Id ,
                                         Same_As_The_Account_Billing_Address__c=true,
                                         Mailing_Address_Line_1__c ='test',
                                         Mailing_City__c='test',
                                         Mailing_ZIP_Postal_Code__c ='110094',      
                                         Mailing_Country__c='India');
     insert testContact;   
     
     for(integer i=0;i<2;i++){
            Course_Booking__c cb2 = new Course_Booking__c(Course_Number__c = testCourses.iD , Delegate_Contact__c = testContact.Id ,Booking_Status__c = 'Confirmed');
            courseBookingList.add(cb2); 
            
        }
        
         Course_Booking__c cb3 = new Course_Booking__c(Course_Number__c = testCourses.iD , Delegate_Contact__c = testCont.Id ,Booking_Status__c = 'Confirmed');
         courseBookingList.add(cb3); 
        
       
       Courses__c courseData = CourseBookingBulkImplementor.getCourseData(testCourses.iD);
         
       Decimal fs = courseData.Course_Free_Spaces__c; 
       system.assertEquals(testCourses.iD , courseData.iD) ;
       
         CourseBookingBulkImplementor.CBResultWrapper CBR = new CourseBookingBulkImplementor.CBResultWrapper();
         CBR = CourseBookingBulkImplementor.saveCourseBookings(courseBookingList,fs);  
         system.assertEquals('2 Course Bookings records saved successfully', CBR.Message) ;
         system.assertEquals('Success', CBR.MessageType) ;
         test.stopTest();  
        
    }
    
    //Test Method For Course having duplicate CB.
     @isTest(seealldata=true) 
    static void duplicateRecordTest(){
         List<Course_Booking__c> courseBookingList = new List<Course_Booking__c>();  
       
        test.startTest();
        //Test Data
        Account testAct=new Account(name='Test Account_CB',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='CHINA',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert testAct;
        Contact testCont =CreateTestData.getContact(testAct.id); 
        Courses__c testCourses = new Courses__c(Course_Type__c = 'System' ,Course_Description__c = 'Test',Duration__c = '5',
                                               Profit_Centre__c = 'Canada - CA1' ,Course_Start_Date__c = system.today() ,
                                               Course_End_Date__c = system.today(), Course_Status__c = 'Provisional' , Delivery_Mode__c = 'Online',
                                               Survey_Language__c = 'EN-GB', Course_Name__c = 'FS' , Course_BU__c = 'Canada', Maximum_Delegates__c = 10);
      
        insert testCourses;
        
         Contact testContact =new Contact(lastname='Test Contact_CB',
                                         AccountId=testAct.Id ,
                                         Same_As_The_Account_Billing_Address__c=true,
                                         Mailing_Address_Line_1__c ='test',
                                         Mailing_City__c='test',
                                         Mailing_ZIP_Postal_Code__c ='110094',      
                                         Mailing_Country__c='India');
     insert testContact;   
    
            Course_Booking__c cb2 = new Course_Booking__c(Course_Number__c = testCourses.iD , Delegate_Contact__c = testContact.Id ,Booking_Status__c = 'Confirmed');
            insert cb2; 
            
    
        
         Course_Booking__c cb3 = new Course_Booking__c(Course_Number__c = testCourses.iD , Delegate_Contact__c = testContact.Id ,Booking_Status__c = 'Confirmed');
         courseBookingList.add(cb3); 
        
       
       Courses__c courseData = CourseBookingBulkImplementor.getCourseData(testCourses.iD);
         
       Decimal fs = courseData.Course_Free_Spaces__c; 
       system.assertEquals(testCourses.iD , courseData.iD) ;
       
         CourseBookingBulkImplementor.CBResultWrapper CBR = new CourseBookingBulkImplementor.CBResultWrapper();
         CBR = CourseBookingBulkImplementor.saveCourseBookings(courseBookingList,fs);  
         system.assertEquals('Duplicate Course Booking! This Course already has a Course Booking with this Delegate Contact.', CBR.Message) ;
         system.assertEquals('Error', CBR.MessageType) ;
         test.stopTest();  
        
    }
    
    
      //Test Method For negative Case check. When we add CB having no Delegate Contact
     @isTest(seealldata=true) 
    static void CBwithNoDelegateTest(){
         List<Course_Booking__c> courseBookingList = new List<Course_Booking__c>();  
       
        test.startTest();
        //Test Data
        Account testAct=new Account(name='Test Account_CB',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='CHINA',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert testAct;
        Contact testCont =CreateTestData.getContact(testAct.id); 
        Courses__c testCourses = new Courses__c(Course_Type__c = 'System' ,Course_Description__c = 'Test', Duration__c = '5',
                                               Profit_Centre__c = 'Canada - CA1' ,Course_Start_Date__c = system.today() ,
                                               Course_End_Date__c = system.today(), Course_Status__c = 'Provisional' , Delivery_Mode__c = 'Online',
                                               Survey_Language__c = 'EN-GB', Course_Name__c = 'FS' , Course_BU__c = 'Canada', Maximum_Delegates__c = 10);
      
        insert testCourses;
        
         Contact testContact =new Contact(lastname='Test Contact_CB',
                                         AccountId=testAct.Id ,
                                         Same_As_The_Account_Billing_Address__c=true,
                                         Mailing_Address_Line_1__c ='test',
                                         Mailing_City__c='test',
                                         Mailing_ZIP_Postal_Code__c ='110094',      
                                         Mailing_Country__c='India');
     insert testContact;   
    
            Course_Booking__c cb2 = new Course_Booking__c(Course_Number__c = testCourses.iD , Delegate_Contact__c = testContact.Id ,Booking_Status__c = 'Confirmed');
            insert cb2; 
            
    
        
         Course_Booking__c cb3 = new Course_Booking__c(Course_Number__c = testCourses.iD  ,Booking_Status__c = 'Confirmed');
         courseBookingList.add(cb3); 
        
       
       Courses__c courseData = CourseBookingBulkImplementor.getCourseData(testCourses.iD);
         
       Decimal fs = courseData.Course_Free_Spaces__c; 
       system.assertEquals(testCourses.iD , courseData.iD) ;
       
         CourseBookingBulkImplementor.CBResultWrapper CBR = new CourseBookingBulkImplementor.CBResultWrapper();
        try{
         CBR = CourseBookingBulkImplementor.saveCourseBookings(courseBookingList,fs);  
        }catch(AuraHAndledException ex){
             String Message = ex.getMessage();
             system.assert(Message.contains('Script-thrown exception'));
        }
         test.stopTest();
  
           
        
    }
    
}