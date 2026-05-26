/**************************************************************************************************************************************
CREATED BY :- PRIYANK ANAND 
CREATED DATE :- 08-06-2019
DESCRIPTION :- This class contains various validations and assignments on fields of Course object, this class is called in Course_Trigger.
***************************************************************************************************************************************/ 

Global class CourseTriggerManager {
    
    //This method is assigning Course Director field with Generic User id, If course director field is null.
    public static void assignCourseDirector(List<Courses__c> newCourses){
        System.debug('Number of Queries used -- Course TM assignCourseDirector START ------- ' + Limits.getQueries());
        for(Courses__c course:newCourses){
            if(course.Course_Director__c == null)
                course.Course_Director__c=System.label.GenericUserContactId;
            
        }
        System.debug('Number of Queries used -- Course TM  assignCourseDirector END ------- ' + Limits.getQueries());
    }
    
    //This method is copying data from course to course booking after any update on course.
    //used in CourseBookingTriggerManager.updateDeligateAccount
    public static void copyDataFromCourse(List<Course_Booking__c> courseBookings, List<Courses__c> courses) {
        System.debug('Number of Queries used -- Course TM copyDataFromCourse START ------- ' + Limits.getQueries());
        map<id,Courses__c> courseMap = new map<id,Courses__c>();
        for(Courses__c course:courses)
            courseMap.put(course.id,course);
        for(Course_Booking__c courseBooking:courseBookings)
        {
            if(courseMap.get(courseBooking.Course_Number__c)!=null)
            {
                courseBooking.Course_Name__c = courseMap.get(courseBooking.Course_Number__c).Course_Name__c; 
                courseBooking.Course_Booking_BU__c =  courseMap.get(courseBooking.Course_Number__c).Course_BU__c; 
                courseBooking.Course_Description__c = courseMap.get(courseBooking.Course_Number__c).Course_Description__c; 
                courseBooking.Course_Start_Date__c =  courseMap.get(courseBooking.Course_Number__c).Course_Start_Date__c; 
                courseBooking.Course_End_Date__c = courseMap.get(courseBooking.Course_Number__c).Course_End_Date__c; 
                courseBooking.Course_Type__c = courseMap.get(courseBooking.Course_Number__c).Course_Type__c; 
                courseBooking.Course_Venue__c = courseMap.get(courseBooking.Course_Number__c).Course_Venue__c; 
                courseBooking.SSC_Email__c = courseMap.get(courseBooking.Course_Number__c).SSC_Email__c;
                courseBooking.Profit_Centre__c=courseMap.get(courseBooking.Course_Number__c).Profit_Centre__c;
            }
        }
        System.debug('Number of Queries used -- Course TM copyDataFromCourse END ------- ' + Limits.getQueries());
    }
    
    //This method is calling copydatafromcourse method when certain fields are updated on course.
    public static void updateDataInCourseBookings(List<Courses__c> oldCourses, List<Courses__c> newCourses) {
        System.debug('Number of Queries used -- Course TM updateDataInCourseBookings START ------- ' + Limits.getQueries());        
        
        map<id,Courses__c> oldCourseMap = new map<id,Courses__c>();   
        for(Courses__c oldCourse : oldCourses){
            oldCourseMap.put(oldCourse.id,oldCourse);
        }
        
        List<Course_Booking__c> courseBookingsList = [SELECT Id,Course_Number__c, Booking_Status__c, Send_Survey__c, Course_Name__c,Course_Booking_BU__c, Course_Description__c, Course_Start_Date__c, Course_End_Date__c, Course_Type__c, Course_Venue__c, SSC_Email__c, Profit_Centre__c
                                                   	  FROM Course_Booking__c 
                                                      WHERE Course_Number__c IN: oldCourseMap.keySet() Order By Course_Number__c ];
        
        if( courseBookingsList.size() > 0){
            List<Course_Booking__c> cbListToUpdate = new List<Course_Booking__c>();
            for(Courses__c newCourse :newCourses)
            {
                if(newCourse.Course_Name__c != oldCourseMap.get(newCourse.id).Course_Name__c || 
                   newCourse.Course_BU__c != oldCourseMap.get(newCourse.id).Course_BU__c || 
                   newCourse.Course_Description__c != oldCourseMap.get(newCourse.id).Course_Description__c ||
                   newCourse.Course_Start_Date__c != oldCourseMap.get(newCourse.id).Course_Start_Date__c || 
                   newCourse.Course_End_Date__c != oldCourseMap.get(newCourse.id).Course_End_Date__c || 
                   newCourse.Course_Type__c != oldCourseMap.get(newCourse.id).Course_Type__c ||
                   newCourse.Course_Venue__c != oldCourseMap.get(newCourse.id).Course_Venue__c || 
                   newCourse.SSC_Email__c != oldCourseMap.get(newCourse.id).SSC_Email__c ||
                   newCourse.Profit_Centre__c != oldCourseMap.get(newCourse.id).Profit_Centre__c)
                {
                    for(Course_Booking__c cb1: courseBookingsList)
                    {
                        if(cb1.Course_Number__c!=null && cb1.Course_Number__c == newCourse.Id)
                        { 
                            cb1.Course_Name__c = newCourse.Course_Name__c; 
                            cb1.Course_Booking_BU__c =  newCourse.Course_BU__c; 
                            cb1.Course_Description__c = newCourse.Course_Description__c; 
                            cb1.Course_Start_Date__c =  newCourse.Course_Start_Date__c; 
                            cb1.Course_End_Date__c = newCourse.Course_End_Date__c; 
                            cb1.Course_Type__c = newCourse.Course_Type__c; 
                            cb1.Course_Venue__c = newCourse.Course_Venue__c; 
                            cb1.SSC_Email__c = newCourse.SSC_Email__c;
                            cb1.Profit_Centre__c = newCourse.Profit_Centre__c;
     
                            cbListToUpdate.add(cb1);  
                        } 
                    }
                    if(!cbListToUpdate.isEmpty()){
                       update cbListToUpdate; 
                    }
                    
                    
                }
                
                if(newCourse.Course_Status__c == 'Completed'){
                    List<Course_Booking__c> cbSurveyListToUpdate = new List<Course_Booking__c>();
                    for(Course_Booking__c cb2: courseBookingsList)
                    {
                        if(cb2.Course_Number__c!=null && cb2.Course_Number__c == newCourse.Id  && cb2.Booking_Status__c =='Confirmed')
                        { 
                        	cb2.Send_Survey__c=True;
                            cbSurveyListToUpdate.add(cb2);
                        }
                    }
                    if(!cbSurveyListToUpdate.isEmpty()){
                        update cbSurveyListToUpdate;
                    }
                    
                }
                
            }
            
        }
        
        // Below code was refactored and replaced by above code as per SSE-14356, to remove Queries from inside FOR loops
 		/*       
        map<id,Courses__c> newCourseMap = new map<id,Courses__c>();
        for(Courses__c newCourse:newCourses)
            newCourseMap.put(newCourse.id,newCourse);
        for(Courses__c oldCourse:oldCourses)
        {
            if(newCourseMap.get(oldCourse.id)!=null)
            {
                if(oldCourse.Course_Name__c != newCourseMap.get(oldCourse.id).Course_Name__c
                   || oldCourse.Course_BU__c != newCourseMap.get(oldCourse.id).Course_BU__c
                   || oldCourse.Course_Description__c != newCourseMap.get(oldCourse.id).Course_Description__c
                   || oldCourse.Course_Start_Date__c != newCourseMap.get(oldCourse.id).Course_Start_Date__c
                   || oldCourse.Course_End_Date__c != newCourseMap.get(oldCourse.id).Course_End_Date__c
                   || oldCourse.Course_Type__c != newCourseMap.get(oldCourse.id).Course_Type__c
                   || oldCourse.Course_Venue__c != newCourseMap.get(oldCourse.id).Course_Venue__c
                   || oldCourse.SSC_Email__c != newCourseMap.get(oldCourse.id).SSC_Email__c
                   || oldCourse.Profit_Centre__c != newCourseMap.get(oldCourse.id).Profit_Centre__c)
                {
                    List<Course_Booking__c> courseBookings = [SELECT Id,Course_Number__c  FROM Course_Booking__c WHERE Course_Number__c = :newCourseMap.get(oldCourse.id).Id];
                    copyDataFromCourse(courseBookings , newCourses);
                    update courseBookings;
                    
                }
            }

            for(Courses__c newCourse:newCourses)
            {
                if(newCourse.Course_Status__c == 'Completed'){
                    List<Course_Booking__c> courseBookingsforsurvey = [SELECT Id,Course_Number__c,Booking_Status__c,Do_not_Contact_Delegates__c 
																		FROM Course_Booking__c 
																		WHERE Course_Number__c = :newCourseMap.get(oldCourse.id).Id];    
                    List<Course_Booking__c> courseBookingstoUpdate = new List<Course_Booking__c>() ;
                    for(Course_Booking__c courseBooking:courseBookingsforsurvey)
                    {
                        if(courseBooking.Course_Number__c!=null && courseBooking.Booking_Status__c =='Confirmed')
                        {
                            courseBooking.Send_Survey__c=True;
                            courseBookingstoUpdate.add(courseBooking);
                        }
                        
                    }
                    update courseBookingstoUpdate;
                }
            } 
            
        }
		*/
        System.debug('Number of Queries used -- Course TM updateDataInCourseBookings END ------- ' + Limits.getQueries());
    }
    
    
}