/**************************************************************************************************************************************
CREATED BY :- PRIYANK ANAND 
CREATED DATE :- 09-06-2019
DESCRIPTION :- This class contains assignments of fields of Course Booking object, this class is called in CourseBooking_Trigger.
***************************************************************************************************************************************/ 
 
Global class CourseBookingTriggerManager {
    //This method is updating delegate account field of course booking and calling copydatafromcourse method. 
    public static void updateDeligateAccount(List<Course_Booking__c> newCourseBooking){
       
        List<Course_Booking__c> cbListWithoutDup = new List<Course_Booking__c>();
        
        System.debug('Number of Queries used -- CB TM updateDeligateAccount START ------- ' + Limits.getQueries());
        Set<Id> contactIds = new Set<Id>();
        Set<Id> courseIds = new Set<Id>();
        
       cbListWithoutDup= getExistingCBForSameCourse(newCourseBooking);
        for(Course_Booking__c booking:cbListWithoutDup)
        {
            if(!contactIds.contains(booking.Delegate_Contact__c))
                contactIds.add(booking.Delegate_Contact__c);
            if(!courseIds.contains(booking.Course_Number__c))
                courseIds.add(booking.Course_Number__c);
        }
        Map<Id,Contact> contactsMap = new Map<Id,Contact> ([SELECT Id,AccountId, Account.OwnerId from Contact WHERE Id IN:contactIds]);
        if(cbListWithoutDup.size()>0){
        for(Course_Booking__c booking :cbListWithoutDup)
        {
            booking.Delegate_Account__c = contactsMap.get(booking.Delegate_Contact__c).Accountid; 
            booking.Delegate_Account_Owner__c = contactsMap.get(booking.Delegate_Contact__c).Account.OwnerId;
        }
        List<Courses__c> courses= new List<Courses__c>([SELECT Course_Name__c, Course_BU__c, Course_Description__c, SSC_Email__c, Course_Start_Date__c,Profit_Centre__c,Course_End_Date__c, Course_Price__c, Course_Type__c, Course_Venue__c, Course_Residential_Price__c ,Extra_night_price__c FROM Courses__c  WHERE Id IN:courseIds]);  
        CourseTriggerManager.copyDataFromCourse(Trigger.new,courses);
        System.debug('Number of Queries used -- CB TM updateDeligateAccount END ------- ' + Limits.getQueries());
        }}
    
    //This method is updating delegate account field of course booking if delegate contact is updated.
    public static void updateDeligateAccountBeforeUpdate(List<Course_Booking__c> newCourseBooking,List<Course_Booking__c> oldCourseBooking){
        System.debug('Number of Queries used -- CB TM updateDeligateAccountBeforeUpdate START ------- ' + Limits.getQueries());
        
        Set<Id> ContactIds = new Set<Id>();
        List<Course_Booking__c> cbListWithoutDup = new List<Course_Booking__c>();
        integer j = 0;
        
        for(Course_Booking__c Coursebookings:newCourseBooking)  
        {   if(Coursebookings.Delegate_Contact__c != oldCourseBooking[j].Delegate_Contact__c ){
            	ContactIds.add(Coursebookings.Delegate_Contact__c);  
        	}
         j++;
        }
        if(ContactIds.size()!=0 && !ContactIds.isEmpty() ){
            Map<Id,Contact> ContactsMap =new Map<Id,Contact> ([SELECT Id,AccountId,Account.OwnerId from Contact WHERE Id IN:ContactIds]);
            List<Course_Booking__c> cbList = new List<Course_Booking__c>();
            
            for(integer i=0;i<newCourseBooking.size();i++)
            {    
                if( newCourseBooking[i].Delegate_Account__c !=null)
                { 
                    if(newCourseBooking[i].Delegate_Contact__c != oldCourseBooking[i].Delegate_Contact__c)
                    {  
                       
                        cbList.add(newCourseBooking[i]);
                     }
                    
                  
                }
                else
                {
                    newCourseBooking[i].Delegate_Account__c = ContactsMap.get(newCourseBooking[i].Delegate_Contact__c).Accountid;
                    newCourseBooking[i].Delegate_Account_Owner__c = ContactsMap.get(newCourseBooking[i].Delegate_Contact__c).Account.OwnerId;
                }     
            } 
            
              if(cbList.size() > 0){
                 
                        cbListWithoutDup = getExistingCBForSameCourse(cbList);
                  for(integer i=0;i<cbListWithoutDup.size();i++){
                       system.debug('Inside for');
                        cbListWithoutDup[i].Delegate_Account__c = ContactsMap.get(cbListWithoutDup[i].Delegate_Contact__c).Accountid;
                        cbListWithoutDup[i].Delegate_Account_Owner__c = ContactsMap.get(cbListWithoutDup[i].Delegate_Contact__c).Account.OwnerId;
                  }}
        }
        System.debug('Number of Queries used -- CB TM updateDeligateAccountBeforeUpdate END ------- ' + Limits.getQueries());
    }
    
    //This method is used to get all the Course Bookings related to a Course -- SSE-15464.
    public static List<Course_Booking__c> getExistingCBForSameCourse(List<Course_Booking__c> newCourseBooking){
        
        List<Course_Booking__c> cbList = new List<Course_Booking__c>();
        List<Courses__c> newCourseList = new List<Courses__c>();
        List<Course_Booking__c> cbListWithoutDup = new List<Course_Booking__c>();
        Map<id , List<Course_Booking__c>> newCBMap = new Map<id , List<Course_Booking__c>>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> courseIds = new Set<Id>();
        
          for(Course_Booking__c booking:newCourseBooking)
        {
            if(!contactIds.contains(booking.Delegate_Contact__c))
                contactIds.add(booking.Delegate_Contact__c);
            if(!courseIds.contains(booking.Course_Number__c))
                courseIds.add(booking.Course_Number__c);
        }
        newCourseList = [SELECT Id ,name, (Select Id ,Course_Number__c, Delegate_Contact__c from Course_Booking__r) 
                         FROM Courses__c  WHERE Id IN:courseIds]; 
        
        if(newCourseList.size() > 0){
        for(Courses__c cb : newCourseList){
         newCBMap.put(cb.id , cb.Course_Booking__r);
        }}
        
        if(!newCBMap.isEmpty()){
            for(id cb2 :newCBMap.keyset() ){      
             cbListWithoutDup=   dupCBCheck(cb2,newCBMap.get(cb2),newCourseBooking);
                
            }
        }
        
        return cbListWithoutDup;
        
        
       
    }
      //This method is used to Check that Duplicate CB are not created under a Course -- SSE-15464.
    public static List<Course_Booking__c> dupCBCheck(id courseId, List<Course_Booking__c> relatedCB ,List<Course_Booking__c> newCourseBooking ){
          
        Set<Id> existingCBDelegateIds = new Set<Id>();
        List<Course_Booking__c> cbListWithoutDup = new List<Course_Booking__c>();
        for(Course_Booking__c cb1 :relatedCB ){
            existingCBDelegateIds.add(cb1.Delegate_Contact__c);
        }
        for(Course_Booking__c cb2 :newCourseBooking ){
       
            if(cb2.Course_Number__c == courseId && existingCBDelegateIds.contains(cb2.Delegate_Contact__c)){
                
                 
                cb2.addError('The Course Booking for this Delegate Contact already Exists on the Course.');
            }
            else{
                cbListWithoutDup.add(cb2);
            }
        }
        return cbListWithoutDup;
    }
    
}