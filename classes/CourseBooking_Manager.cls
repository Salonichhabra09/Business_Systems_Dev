global class CourseBooking_Manager 
{
    public class CustomException extends Exception {}
    
    WebService static void updateQualification(List<Course_Booking__c> courseBookings)
    {
        //Create a list of delegate contacts whose qualifications need to be updated
        List<Contact> delegates = new List<Contact>();
        Map<Id, Contact> delegatesMap = new Map<Id, Contact>();
        
        //For each course booking
        for(Course_Booking__c courseBooking: courseBookings)
        {
            if(!delegatesMap.containsKey(courseBooking.Delegate_Contact__c))
            {
                //If course has any qualifications 
                if(courseBooking.Course_Number__r.Qualification_Available__c!=null || courseBooking.Course_Number__r.Course_Type__c=='System Training')
                {
                    //Create the delegate whose qualifications need to be updated
                    Contact delegate = new Contact(Id=courseBooking.Delegate_Contact__c);
                    
                    if(courseBooking.Course_Number__r.Qualification_Available__c!=null)
                    {
                        //Add the course qualifications to the delegate's qualifications
                        appendCourseQualifications(delegate, courseBooking.Course_Number__r.Qualification_Available__c, courseBooking.Delegate_Contact__r.Qualifications__c);
                        
                        //Update the Training date of the course qualifications for this delegate            
                        updateTrainingDate(delegate, courseBooking.Course_Number__r.Course_End_Date__c, courseBooking.Course_Number__r.Qualification_Available__c);
                    }
                    
                    //if(courseBooking.Course_Number__r.Course_Name__c.toLowerCase().contains('soda'))
                    if(courseBooking.Course_Number__r.Course_Type__c.contains('System Training'))
                        delegate.SODA__c = courseBooking.Course_Number__r.Course_End_Date__c;
                    
                    //Add this delegate to the list to be updated 
                    delegates.add(delegate);                                                       
                    delegatesMap.put(delegate.Id, delegate);
                }
            }
        }
        
        //If there are any eligible delegates then update their records with the modifications done above.
        if(delegates.size()>0){
            try{
                update delegates;
            }
            catch (System.DmlException e) {
                    String recErrorIdString = (e.getMessage()).substringAfter('id ').substringBefore(';');
            		Id recErrorId = recErrorIdString;
                    String sObjName = '';
                    if(recErrorId != null){
                        sObjName = recErrorId.getSObjectType().getDescribe().getLabel();
                    }
                	String cbNumber = '';
                	String errorMessage = '';
                for(Course_Booking__c cb: courseBookings){
                    if(cb.Delegate_Contact__c == recErrorId){
                        cbNumber = cb.Name;
                        if(sObjName != ''){
                            errorMessage = errorMessage+ 'Error on ' + cbNumber + ':  ' + (e.getDmlMessage(0)).removeEnd('.') + ' on related ' + sObjName + '. ' ;
                        } else {
                            errorMessage = errorMessage+ 'Error on ' + cbNumber + ':  ' + (e.getDmlMessage(0)).removeEnd('.') + '. ';
                        }
                        System.debug('errorMessage --'+ errorMessage);
                    }
                }
                throw new CustomException(errorMessage);
            } catch(System.Exception exp) {
                throw new CustomException(exp.getMessage());
            }
            
        }
            
    }
    
    
    private static void appendCourseQualifications(Contact delegate,String availableCourseQualifications, String existingDelegateQualifications)
    {
        if(existingDelegateQualifications!=null)
        {
            
            String[] AvailableQualification = availableCourseQualifications.Split(';');
            String[] ExistingQualification = existingDelegateQualifications.Split(';');
            
            if (ExistingQualification[0]=='None')
                delegate.Qualifications__c = availableCourseQualifications;
            else
            {           
                delegate.Qualifications__c = existingDelegateQualifications;
                for (integer i=0; i<AvailableQualification.size();i++)
                {
                    Integer k;
                    for (integer j=0;j<ExistingQualification.size();j++)
                    {
                        if(AvailableQualification[i]==ExistingQualification[j])
                        {k=-1;break;}
                    }
                    if(k!=-1)
                        delegate.Qualifications__c += ';' + AvailableQualification[i];
                }
            }  
        }
        else
            delegate.Qualifications__c = availableCourseQualifications;
    }
    
    private static void updateTrainingDate(Contact delegate, Date courseEndDate, String availableCourseQualifications)
    {
        //Add Metadata 
        String[] AvailableQualification = availableCourseQualifications.Split(';');
        Map<String, String> mapQualValueANDFieldLabel = new Map<String, String>();
        List<Qualification__mdt	> qualList = Qualification__mdt.getAll().values();
        for(Qualification__mdt qualObj : qualList){
            mapQualValueANDFieldLabel.put(qualObj.Value__c , qualObj.Field_API__c);
        }
        
        for (integer i=0; i<AvailableQualification.size();i++)
        {
            if(mapQualValueANDFieldLabel.containsKey(AvailableQualification[i])){
                delegate.put(mapQualValueANDFieldLabel.get(AvailableQualification[i]), courseEndDate);
            }
            /*
            if(AvailableQualification[i]=='360')
                delegate.X360__c = courseStartDate;
            else if(AvailableQualification[i]=='ASST')
                delegate.ASST__c = courseStartDate;
            else if(AvailableQualification[i]=='CBI')
                delegate.Interview_training_date__c = courseStartDate;
            else if(AvailableQualification[i]=='JACD')
                delegate.JACD__c = courseStartDate;
            else if(AvailableQualification[i]=='MAS')
                delegate.MFS_training_date__c = courseStartDate;
            else if(AvailableQualification[i]=='MQ')
                delegate.MQ_training_date__c = courseStartDate;
            else if(AvailableQualification[i]=='OPQ')
                delegate.OPQ_training_date__c = courseStartDate;
            else if(AvailableQualification[i]=='OT')
                delegate.Ability_tests_training_date__c = courseStartDate;
            else if(AvailableQualification[i]=='PB')
                delegate.Personaility_Basics__c = courseStartDate;
            else if(AvailableQualification[i]=='TA')
                delegate.Test_admin_training_date__c = courseStartDate;
            else if(AvailableQualification[i]=='BPOA')
                delegate.BPOA__c = courseStartDate;
            else if(AvailableQualification[i]=='A&DC')
                delegate.MAS_training_date__c = courseStartDate;
			*/
        }
    }
    
    public static void copyDataFromCourse(Course_Booking__c courseBooking, Courses__c course)
    {
        // if(course.Course_Name__c == null)
        //     course = [SELECT Course_Name__c, Course_BU__c, Course_Description__c, SSC_Email__c, Course_Start_Date__c,Profit_Centre__c,Course_End_Date__c, Course_Price__c, Course_Type__c, Course_Venue__c, Course_Residential_Price__c ,Extra_night_price__c FROM Courses__c  WHERE Id = :course.Id];
        courseBooking.Course_Name__c = course.Course_Name__c; 
        courseBooking.Course_Booking_BU__c =  course.Course_BU__c; 
        courseBooking.Course_Description__c = course.Course_Description__c; 
        courseBooking.Course_Start_Date__c =  course.Course_Start_Date__c; 
        courseBooking.Course_End_Date__c = course.Course_End_Date__c; 
        courseBooking.Course_Type__c = course.Course_Type__c; 
        courseBooking.Course_Venue__c = course.Course_Venue__c; 
        courseBooking.SSC_Email__c = course.SSC_Email__c;
        courseBooking.Profit_Centre__c=course.Profit_Centre__c;
       // courseBooking.AutomationBypassDateTime__c = System.now(); //Update for SSE-17028
    }
    
    public static void updateDataInCourseBookings(Courses__c oldCourse, Courses__c newCourse)
    {
        if(oldCourse.Course_Name__c != newCourse.Course_Name__c
           || oldCourse.Course_BU__c != newCourse.Course_BU__c
           || oldCourse.Course_Description__c != newCourse.Course_Description__c
           || oldCourse.Course_Start_Date__c != newCourse.Course_Start_Date__c
           || oldCourse.Course_End_Date__c != newCourse.Course_End_Date__c
           || oldCourse.Course_Type__c != newCourse.Course_Type__c
           || oldCourse.Course_Venue__c != newCourse.Course_Venue__c
           || oldCourse.SSC_Email__c != newCourse.SSC_Email__c
           || oldCourse.Profit_Centre__c != newCourse.Profit_Centre__c)
        {
            Courses__c course = new Courses__c();
            course = [SELECT Course_Name__c, Course_BU__c, Course_Description__c, SSC_Email__c, Course_Start_Date__c,Profit_Centre__c,Course_End_Date__c, Course_Price__c, Course_Type__c, Course_Venue__c, Course_Residential_Price__c ,Extra_night_price__c FROM Courses__c  WHERE Id = :newCourse.Id LIMIT 1];
            Course_Booking__c[] courseBookings = [SELECT Id FROM Course_Booking__c WHERE Course_Number__c = :newCourse.Id];
            for(Course_booking__c courseBooking: courseBookings){
                if(newCourse.Course_Name__c == null){
                    copyDataFromCourse(courseBooking, course);
                }
                else{
                    copyDataFromCourse(courseBooking, newCourse);
                }   
            }
            
            update courseBookings;
        }
    }
}