@isTest(SeeAllData=true)
public class CourseBooking_TriggerTester
{
    static testMethod void testCourseBookingTriggers()
    {
        //CourseBookingTriggerManager.updateDeligateAccount(insertNewCourseBookings(null));
        CourseBookingTriggerManager.updateDeligateAccountBeforeUpdate(insertNewCourseBookings(null),insertNewCourseBookings(null));
        List<Course_Booking__c> cb = insertNewCourseBookings(null);
        update cb;
    }
    
    public static List<Course_Booking__c> insertNewCourseBookings(String courseId)
    {
        
   Courses__c testCourses = new Courses__c(Course_Type__c = 'System' ,Course_Description__c = 'Test',
                                                Profit_Centre__c = 'Canada - CA1' ,
                                                Course_Start_Date__c = system.today() ,
                                                Course_End_Date__c = system.today(), Course_Status__c = 'Provisional' , 
                                                Delivery_Mode__c = 'Online',Duration__c = '12',
                                                Survey_Language__c = 'EN-GB', Course_Name__c = 'FS' , Course_BU__c = 'Canada', 
                                                Maximum_Delegates__c = 10);
        
        insert testCourses;
        courseId = testCourses.Id;     
         
        String accountid=[Select id from account limit 1].Id;
        Contact contact=new Contact(lastname='Test Contact',AccountId=accountid,Mailing_Address_Line_1__c ='test',Mailing_City__c='test',Mailing_ZIP_Postal_Code__c ='110094',Mailing_Country__c='India');
        insert contact;
        String contactid=contact.id;
        List<Course_Booking__c> bookings = new List<Course_Booking__c>();
        for(Integer i=0;i<10;i++)
        {
            Course_Booking__c booking = new Course_Booking__c();
            booking.Course_Number__c = courseId;
            booking.Delegate_Contact__c = contactId;
            booking.Delegate_Account__c= accountid;
            booking.Sun_Order_Number__c = '676587';
            booking.Booking_Status__c= 'Confirmed';
            booking.Pass_Status__c= 'Pass';
            booking.Lead_Source__c = 'L01 - Advertisement';
            bookings.add(booking);
        }
        insert bookings; 
        Contact contact1=new Contact(lastname='Test Contact',AccountId=accountid,Mailing_Address_Line_1__c ='test',Mailing_City__c='test',Mailing_ZIP_Postal_Code__c ='110094',Mailing_Country__c='India');
        insert contact1;
            
        bookings[0].Delegate_Contact__c=contact1.id;
        update bookings[0];
        return bookings;
    }
    
}