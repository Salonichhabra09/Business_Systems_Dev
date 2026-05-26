global class Course_Manager
{
    /* Commented for SSE-14356
    WebService static String generateCertificates(String  courseId)
    {
        System.debug('Number of Queries used -- CM generateCertificates START ------- ' + Limits.getQueries());
        try
        {           
            List<Course_Booking__c> courseBookings = [SELECT Id,Name FROM Course_Booking__c WHERE Course_Number__c = :courseId AND Booking_Status__c= :'Confirmed' AND Pass_Status__c= :'Pass'];
            
            for(Course_Booking__c courseBooking: courseBookings)
                generateCertificate(courseBooking);
            System.debug('Number of Queries used -- CM generateCertificates END ------- ' + Limits.getQueries());
            return 'SUCCESS';
        }
        catch(System.Exception e)
        {
            System.debug('Number of Queries used -- CM generateCertificates END ------- ' + Limits.getQueries());
            return 'FAILURE: ' + e.getMessage();
        }
    }
    
    public static void generateCertificate(Course_Booking__c courseBooking)
    {
        System.debug('Number of Queries used -- CM generateCertificate START ------- ' + Limits.getQueries());
        // Get the page definition
        PageReference pdfPage = Page.Course_Certificate;
        
        // set the booking id on the page definition
        pdfPage.getParameters().put('id',courseBooking.id);
        
        // generate the pdf Blob
        Blob pdfBlob = pdfPage.getContent();
        
        // create the attachment against the booking
        Attachment a = new Attachment(parentId = courseBooking.id, name=courseBooking.Name + '.pdf', body = pdfBlob);
        
        // insert the attachment
        insert a;
        System.debug('Number of Queries used -- CM generateCertificate END ------- ' + Limits.getQueries());
    }
    */
    
    @AuraEnabled
    WebService static String endCourse(String courseId)
    {
        System.debug('Number of Queries used -- CM endCourse START ------- ' + Limits.getQueries());
        try
        {
            Group endCourseGroup = [Select Id,(Select UserOrGroupId from GroupMembers where UserOrGroupId = :UserInfo.getUserId()) FROM Group WHERE Name='End Course Administrators' ];
            
            if(endCourseGroup.GroupMembers.size()>0)
            {
                Courses__c course = [SELECT Id,Name,Course_Name__c,Course_Status__c, Profit_Centre__c,Course_Category__c,Course_Type__c,Partner_Account_Name__c,Partner_Account_Name__r.OwnerId,Partner_Account_Name__r.Account_Number__c,Partner_Account_Name__r.Name,Course_Director__c,Opportunity__r.Billing_Contact__c, 
                                     (SELECT Id,Name, Pass_Status__c,Course_Number__c,Course_Number__r.id,Delegate_Account__r.Account_Number__c,Delegate_Account__r.Name,Delegate_Account__r.OwnerId,Delegate_Contact__c,Delegate_Contact__r.Name,Delegate_Contact__r.Phone,Delegate_Contact__r.Email FROM Course_Booking__r WHERE Booking_Status__c=:'Confirmed') 
                                     FROM Courses__c WHERE Id=:courseId];
                system.debug('==course.Course_Status__c==>'+course.Course_Status__c);
                //Update the Status of the course to 'Completed'
                if(course.Course_Booking__r.size()==0){
                    System.debug('Number of Queries used -- CM endCourse END ------- ' + Limits.getQueries());
                    return 'NO_CONFIRMED_COURSE_BOOKINGS';
                }
                if(course.Course_Booking__r.size() > 0 && course.Course_Status__c != 'Completed')
                {
                    course.Course_Status__c = 'Completed';
                    try{
                        update course; 
                    }catch(exception e){
                        system.debug('==e.getMessage()==>'+e.getMessage());
                        if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                            String s2 = e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                            return s2;
                        }
                    }
                    
                    //Update the Closed from button for completion survey of the course bookings
                    List<Course_Booking__c> courseBookings = new List<Course_Booking__c>(); 
                    for(Course_Booking__c courseBooking: course.Course_Booking__r){
                        //if(courseBooking.Pass_Status__c != 'Pass')
                        courseBookings.add(new Course_Booking__c(Id=courseBooking.Id,Closed_from_button__c=true)); // Modified by Priyank Anand on 1-Apr-2019 
                    }
                    update courseBookings;     
                    
                    //No longer needed for Non public courses as part of GCSC S4 feedback
                    //if the ProfitCenter of the course is UK then send ThankYou emails to the delegate contacts of each CourseBooking.
                    /* if(course.Profit_Centre__c == 'UK - UK1' && !course.Course_Name__c.toLowerCase().contains('soda') && !course.Course_Type__c.contains('System Training'))
                    {
                        //Create a list of Email Messages to be sent to the delegates
                        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                        
                        //Fetch the Email of the current user
                        String userEmail = [SELECT Email FROM User WHERE id=:UserInfo.getUserId()].Email;
                        
                        for(Course_Booking__c courseBooking: course.Course_Booking__r)
                        {
                            //Create Email Message 
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setTemplateId('00X200000011s2s');
                            mail.setReplyTo(userEmail);
                            mail.setTargetObjectId(courseBooking.Delegate_Contact__c);
                            mail.setWhatId(courseBooking.Id);
                            mail.setSaveAsActivity(true);
                            //Add this email message to the List of Email Messages
                            mails.add(mail);
                        }
                        // Send the ThankYou emails to the contacts.
                        Messaging.sendEmail(mails);
                    }*/
                    
                    //<01/11/2011> Added by Vikas
                    //update to exclude course name "system training/demo" as per SSE-12082 by Saloni Chhabra
                    if(course.Course_Category__c == 'Public' && !course.Course_Type__c.contains('System Training') && !course.Course_Type__c.contains('System Demo'))
                    {       
                        //Call this method to create tasks for Account Owner if course status is Public
                        createCourseCategoryPublicTask(course);
                    }               
                    //No longer needed for Non public courses as part of GCSC S4 feedback
                    /*if((course.Course_Category__c == 'In Company' || course.Course_Category__c == 'Internal' || course.Course_Category__c == 'Partner') && course.Partner_Account_Name__c != null && !course.Course_Type__c.contains('System Training') && !course.Course_Type__c.contains('System Demo'))
                    {
                        //Call this method to create tasks for Account Owner if course status In Company/Internal/Partner and billing account exist for the course linked to
                        createCourseCategoryOthanThanPublicTask(course);
                    }*/
                    
                    //// Following If statement was Commented for SS-15464
                    //Create a list of Course Resources which will be used to assign task to Resource Name(SHL) of course linked to
                    /*List<Course_Resources__c> courseResources = [SELECT Id,Resource_Name_SHL__c FROM Course_Resources__c WHERE Course_Name__c=:course.id AND Resource_Role__c=:'Course Director' AND Resource_Name_SHL__c<>null];
                    if(course.Course_Type__c == 'System Training' && course.Course_Category__c == 'In Company' && courseResources.size()>0)
                    {
                        //Call this method to create tasks for Resource Name(SHL) of Course Resource if course type is System Training and course category is 'In Company'
                        createCourseTypeTask(course,courseResources);                               
                    }*/
                    System.debug('Number of Queries used -- CM endCourse END ------- ' + Limits.getQueries());
                    return 'SUCCESS';
                }
                //if course status is already completed
                else
                {
                    System.debug('Number of Queries used -- CM endCourse END ------- ' + Limits.getQueries());
                    return 'End_Course_cannot_be_Completed';
                }
            }
            else
            {
                System.debug('Number of Queries used -- CM endCourse END ------- ' + Limits.getQueries());
                return 'Course_cannot_be_Ended';
            }
            
        }
        catch(System.Exception e)
        {
            System.debug('Number of Queries used -- CM endCourse END ------- ' + Limits.getQueries());
            return 'FAILURE: ' + e.getMessage();
        }
    }
    
    // Task needs to be created for the course if course category is 'Public'   
    public static void createCourseCategoryPublicTask(Courses__c course)
    {
        System.debug('Number of Queries used -- CM createCourseCategoryPublicTask START ------- ' + Limits.getQueries());
        //Create a list of tasks which will be send to Account Owner
        List<Task> CourseCategoryPublicTasks = new List<Task>();
        //Query dummy user which is inactive to assign task first to dummy as to stop standard task assignment email to go solution for SSE-12082
        List<user> Dummyuser = [Select id from user where Name ='Dummy User' limit 1];

        //Due Date always be a week from the day it is created
        Date dates = System.today();
        dates = dates.addDays(7);
        // Tasks need to be created for all confirmed course booking linked to that course if course category is 'Public' 
        for(Course_Booking__c courseBooking: course.Course_Booking__r)
        {  
            CourseCategoryPublicTasks.add(new task(OwnerId=Dummyuser[0].id,Delegate_Billing_Account_Name__c = courseBooking.Delegate_Account__r.Name,Delegate_Billing_Account_Dnumber__c = courseBooking.Delegate_Account__r.Account_Number__c,AssignedBy__c = UserInfo.getUserName(),
            Subject = 'Call Customer',ActivityDate = dates,Status = 'Not Started',WhoId = courseBooking.Delegate_Contact__c,WhatId = courseBooking.Id,ClientInterest1__c = 'Course Feedback',Description = String.format('{5} has completed course {1}({0}/{2} the course Booking reference for this delegate is {3}({0}/{4}. Please contact the delegate accordingly.'
           ,new String[]{URL.getSalesforceBaseUrl().toExternalForm(),course.Name,course.Id,courseBooking.Name, courseBooking.Id,courseBooking.Delegate_Contact__r.Name})));
        } 
        // Set Send email notification for the task as true
        Database.DMLOptions dmlo = new Database.DMLOptions();
        dmlo.EmailHeader.triggerUserEmail = false; //stopped sending standard email as part of SSE-12082 
        if(!Test.isRunningTest()){  // To avoid soql error in UpdateActualTimeTaken trigger
            database.insert(CourseCategoryPublicTasks, dmlo);
        }
        //System.debug('Number of Queries used -- CM createCourseCategoryPublicTask END ------- ' + Limits.getQueries());
    }
    
    //No longer needed for Non public courses as part of GCSC S4 feedback
    //Task need to be created for the course if course category is 'In Company','Internal' or 'Partner' and billing account exist for the course linked to      
    /*public static void createCourseCategoryOthanThanPublicTask(Courses__c course)
    {
        System.debug('Number of Queries used -- CM createCourseCategoryOthanThanPublicTask START ------- ' + Limits.getQueries());
        //Create a list of tasks which will be send to Account Owner
        List<Task> CourseCategoryOthanThanPublicTasks = new List<Task>();
        //Query dummy user which is inactive to assign task first to dummy as to stop standard task assignment email to go solution for SSE-12082
        List<user> Dummyuser = [Select id from user where Name ='Dummy User' limit 1];
        system.debug('In company Dummyuser'+Dummyuser);
        //Due Date always be a week from the day it is created
        Date dates = System.today();
        dates = dates.addDays(7);
        CourseCategoryOthanThanPublicTasks.add(new task(OwnerId=Dummyuser[0].id,
            										   //OwnerId = course.Partner_Account_Name__r.OwnerId,
            										    Delegate_Billing_Account_Name__c = course.Partner_Account_Name__r.Name,
                                                        Delegate_Billing_Account_Dnumber__c = course.Partner_Account_Name__r.Account_Number__c,
                                                        AssignedBy__c = UserInfo.getUserName(),
                                                        Subject = 'Call Customer',
                                                        ActivityDate = dates,
                                                        Status = 'Not Started',
                                                        WhoId = course.Opportunity__r.Billing_Contact__c,
                                                        WhatId = course.Id,
                                                        ClientInterest1__c = 'Course Feedback',                                                                                             
                                                        Description = String.format('Course {1}({0}/{2} has ended. Please follow up with the lead delegate on the course.'
                                                                                    ,new String[]{URL.getSalesforceBaseUrl().toExternalForm(),course.Name,course.Id})
                                                       )); 
        
        // Set Send email notification for the task as true
        Database.DMLOptions dmlo = new Database.DMLOptions();
        dmlo.EmailHeader.triggerUserEmail = false; // as part of SSE-12082 create a custom email alert
        system.debug('---dmlo.EmailHeader.triggerUserEmail--'+dmlo);
        if(!Test.isRunningTest()){  // To avoid soql error in UpdateActualTimeTaken trigger
            database.insert(CourseCategoryOthanThanPublicTasks, dmlo);
        }
        //System.debug('Number of Queries used -- CM createCourseCategoryOthanThanPublicTask END ------- ' + Limits.getQueries());
    } */
    
    // Commented for SS-15464
    // Task need to be created for the course if course category is 'In Company',course type is 'System Training' and course resources exist for course link to
    /*public static void createCourseTypeTask(Courses__c course, List<Course_Resources__c> courseResources)
    {   
        System.debug('Number of Queries used -- CM createCourseTypeTask START ------- ' + Limits.getQueries());
        User courseDirector = new User(id=courseResources[0].Resource_Name_SHL__c);
        //Create a list of tasks which will be used to send tasks to Resource Name(SHL) of course resource
        List<Task> coursetypeTasks = new List<Task>();
        ////Due Date always be two week from the day it is created
        Date dueDate = System.today().addDays(14);
        coursetypeTasks.add(new task(OwnerId = courseDirector.id,
                                     AssignedBy__c = UserInfo.getUserName(),
                                     Subject = 'Call Customer',
                                     ActivityDate = dueDate,
                                     Status = 'Not Started',
                                     WhatId = course.Id,
                                     ClientInterest1__c = 'Course Feedback',
                                     //Description = String.format('<b>Course {1}({0}/{2} has ended</b>',new String[]{URL.getSalesforceBaseUrl().toExternalForm(),course.Name,course.Id})
                                     Description = String.format('Course {1}({0}/{2} has ended. Please follow up with the lead delegate on the course.'
                                                                 ,new String[]{URL.getSalesforceBaseUrl().toExternalForm(),course.Name,course.Id})
                                    ));                                                
        // Set Send email notification for the task as true
        Database.DMLOptions dmlo = new Database.DMLOptions();
        dmlo.EmailHeader.triggerUserEmail = true;
        if(!Test.isRunningTest()){  // To avoid soql error in UpdateActualTimeTaken trigger
            database.insert(coursetypeTasks, dmlo);
        }
        System.debug('Number of Queries used -- CM createCourseTypeTask END ------- ' + Limits.getQueries());
    }*/
    
    @AuraEnabled
    WebService static String updateQualifications(String courseId) {
        System.debug('Number of Queries used -- CM updateQualifications START ------- ' + Limits.getQueries());
        set<id> idSet = new set<id>();
        List<Courses__c > courseList = new List<Courses__c>();
        if(courseId!=null){
		courseList = [SELECT Id,Course_Name__c ,Course_End_Date__c,Qualification_Available__c,Course_Type__c  FROM Courses__c WHERE Id =:courseId];
            system.debug('courseList '+courseList);
        }
        for(Courses__c crs : courseList){
            if(crs.Qualification_Available__c !='' || crs.Course_Name__c.indexOf('SODA')!=-1||crs.Course_Type__c == 'System Training'){
                idSet.add(crs.Id);
            }
        }
        try
        {
            List<Course_Booking__c> courseBookings = [SELECT Id,Name, Pass_Status__c,Course_Number__r.Course_End_Date__c,Course_Number__r.Course_Type__c,Course_Number__r.Course_Name__c, Course_Number__r.Qualification_Available__c,Delegate_Contact__r.Qualifications__c ,Profit_Centre__c FROM Course_Booking__c WHERE Course_Number__c in: idset AND Booking_Status__c= :'Confirmed'];
            system.debug('==size==>'+courseBookings.size());
            if(courseBookings.size()>0)
            {
                for(Course_Booking__c cBookings: courseBookings){
                    if(cBookings.Pass_Status__c != 'Pass'){
                        cBookings.Pass_Status__c='Pass';
                        //cBookings.Closed_from_button__c=true;
                    }
                }
                update courseBookings;     
                    
                CourseBooking_Manager.updateQualification(courseBookings);
                system.debug('courseBookings'+courseBookings);
                System.debug('Number of Queries used -- CM updateQualifications END ------- ' + Limits.getQueries());
                return '';
            }
            System.debug('Number of Queries used -- CM updateQualifications END ------- ' + Limits.getQueries());
            return '0';
        }
        catch(System.DmlException exp) {
            String recErrorIdString = (exp.getMessage()).substringAfter('id ').substringBefore(';');
            Id recErrorId = recErrorIdString;

            String sObjName = '';
            if(recErrorId != null){
                sObjName = recErrorId.getSObjectType().getDescribe().getLabel();
            }

            String errorMessage = '';
            if(sObjName != ''){
                errorMessage = 'On ' + sObjName +': ' + exp.getDmlMessage(0) ;
            } else {
                errorMessage = exp.getDmlMessage(0) ;
            }

            return errorMessage;
        }
        catch(System.Exception e)
        {
            return e.getMessage();
        }
    }
    
    public static String sendJoiningInstructions(String courseId,String emailTemplateId) {
        System.debug('Number of Queries used -- CM sendJoiningInstructions START 1 ------- ' + Limits.getQueries());
        Savepoint sp = Database.setSavepoint();
        try
        {
            
            Courses__c course1 = [SELECT Id, Date_JI_First_Sent__c,(SELECT Id, Delegate_Contact__c, Delegate_Contact__r.Name, Delegate_Contact__r.Email, Date_JI_Sent__c FROM Course_Booking__r WHERE Booking_Status__c= :'Confirmed' ) FROM Courses__c WHERE Id=:courseId];
            
            if(course1.Course_Booking__r.size()==0){
                System.debug('Number of Queries used -- CM sendJoiningInstructions END ------- ' + Limits.getQueries());
                return 'SUCCESS:Course Bookings are not confirmed for this course';
            }
            
            /*
            Courses__c course = [SELECT Id, Date_JI_First_Sent__c, 
                                 (SELECT Id, Delegate_Contact__c, Delegate_Contact__r.Name, Delegate_Contact__r.Email FROM Course_Booking__r WHERE Booking_Status__c= :'Confirmed' AND Date_JI_Sent__c= :null) 
                                 FROM Courses__c WHERE Id=:courseId];
            */
            List<Course_Booking__c> cbList = new List<Course_Booking__c>();
            for(Course_Booking__c cb : course1.Course_Booking__r){
                if(cb.Date_JI_Sent__c == null){
                    cbList.add(cb);
                }
            }

            //if(course.Course_Booking__r.size()==0)
            if(cbList.size()==0){
                System.debug('Number of Queries used -- CM sendJoiningInstructions END ------- ' + Limits.getQueries());
                return 'SUCCESS:The JI email has already been sent';
            }
            
            // List<Attachment> courseAttachments = [SELECT name, body FROM Attachment WHERE parentId=:courseId]; // Commented by Pankhuri for SSE-8624
            
            // New Added by Pankhuri on 12/2/2019 for SSE-8624
            Set<id> contentDocIds = new Set<id>();
            
            List<ContentDocumentLink> courseDocLink = [Select ContentDocumentId from ContentDocumentLink where LinkedEntityId=:courseId];
            for(ContentDocumentLink contentDocs: courseDocLink){
                contentDocIds.add(contentDocs.ContentDocumentId);
            }

            List<ContentVersion> documents = new List<ContentVersion>{};
            if(contentDocIds.size()>0 && contentDocIds != null){
            	documents.addAll([SELECT Id, Title, FileExtension, FileType,ContentBodyId, VersionData, isLatest, ContentDocumentId 
                                  FROM ContentVersion 
                                  WHERE ContentDocumentId IN :contentDocIds 
                                  AND FileType!='SNOTE' AND (NOT Title LIKE '%PartnerLogo%')]); //Like condition excludes the logos files related to course certificates
            }

            //List<Id> attachmentIds = new List<Id>();
            //attachmentIds.addAll(contentDocIds);
            //End
            
            //Create a list of Email Messages to be sent to the delegates
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            //Create a list of course bookings for which the Date JI sent field is to be updated
            List<Course_Booking__c> courseBookings = new List<Course_Booking__c>();

            for(Course_Booking__c confirmedBooking: cbList)
            {
                if(confirmedBooking.Delegate_Contact__r.Email != null)
                {
                    //Create Email Message 
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(emailTemplateId);
                    mail.setTargetObjectId(confirmedBooking.Delegate_Contact__c);
                    mail.setWhatId(confirmedBooking.Id);
                    mail.setSaveAsActivity(true);
                    
                    //addAttachments(mail, courseAttachments);    // Commented by Pankhuri for SSE-8624
                    addFiles(mail,documents);
                    
               		//Add this email message to the List of Email Messages
                    mails.add(mail);
                    
                    //Added this for viewing attachment on activity history sent by Send JI button
                    /*List<String> entityIds = new List<String>();
                    for(ContentVersion cvr : documents){
                        entityIds.add(cvr.Id);
                    }
                    mail.setEntityAttachments(entityIds);*/
                    
                    //Add this email message to the List of Email Messages
                    //mails.add(mail);
                    //system.debug('**mail*'+mails.size()+'*='+mail);
                        
                    //Add this course booking to the List of Course Bookings to be updated
                    Course_Booking__c courseBooking = new Course_Booking__c(id=confirmedBooking.Id);
                    courseBooking.Date_JI_Sent__c = System.today();
                    courseBookings.add(courseBooking);
                }
            }
            
            if(mails.size()>0)
            {
                //Update the course bookings for populating the Date JI sent field. 
                update courseBookings;
                //If this the first time JI instruction have been sent for this course
                if(course1.Date_JI_First_Sent__c == null)
                {
                    course1.Date_JI_First_Sent__c= System.today();
                    update course1;
                }
                // Send the emails you have created.
                Messaging.sendEmail(mails);  
                System.debug('Number of Queries used -- CM sendJoiningInstructions END ------- ' + Limits.getQueries());
                return 'SUCCESS: ' + mails.size() + ' Joining Instructions email(s) sent successfully.';
            }
            System.debug('Number of Queries used -- CM sendJoiningInstructions END ------- ' + Limits.getQueries());
            return 'FAILURE: NO_VALID_EMAIL';
            
        }
        catch(System.Exception e)
        {
            DataBase.Rollback(sp);
            system.debug('exception'+e.getCause());
            system.debug('exception'+e.getLineNumber());
            system.debug('exception'+e.getMessage());
            system.debug('exception'+e.getStackTraceString());
            system.debug('exception'+e.getTypeName());
            
            System.debug('Number of Queries used -- CM sendJoiningInstructions END ------- ' + Limits.getQueries());
            return 'FAILURE: ' + e.getMessage();
        }
    }
    
    public static String SendSurvey(String courseId,String emailTemplateId) {
        try
        {
            System.debug('Number of Queries used -- CM SendSurvey START ------- ' + Limits.getQueries());
            Courses__c course = [SELECT Id, Date_Survey_first_sent__c,
                                 (SELECT Id, Delegate_Contact__c, Delegate_Contact__r.Name, Delegate_Contact__r.Email FROM Course_Booking__r WHERE Booking_Status__c= 'Confirmed' AND Pass_Status__c!='' and Date_Survey_Sent__c=null) 
                                 FROM Courses__c WHERE Id=:courseId];
            
            if(course.Course_Booking__r.size()==0){
                System.debug('Number of Queries used -- CM SendSurvey END ------- ' + Limits.getQueries());
                return 'SUCCESS:Course Bookings are not confirmed for the selected course and Pass Status cannot be None';
            }
            
            //Create a list of Email Messages to be sent to the delegates
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            //Create a list of course bookings for which the Date Survey sent field is to be updated
            List<Course_Booking__c> courseBookings = new List<Course_Booking__c>();
            
            for(Course_Booking__c confirmedBooking: course.Course_Booking__r)
            {
                if(confirmedBooking.Delegate_Contact__r.Email != null){
                    //Create Email Message 
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(emailTemplateId);
                    mail.setTargetObjectId(confirmedBooking.Delegate_Contact__c);
                    mail.setWhatId(confirmedBooking.Id);
                    mail.setSaveAsActivity(true);
                    
                    //Add this email message to the List of Email Messages
                    mails.add(mail);
                    
                    //Add this course booking to the List of Course Bookings to be updated
                    Course_Booking__c courseBooking = new Course_Booking__c(id=confirmedBooking.Id);
                    courseBooking.Date_Survey_Sent__c = System.today();
                    courseBookings.add(courseBooking);
                }
            }
            
            if(mails.size()>0)
            {
                // Send the emails you have created.
                Messaging.sendEmail(mails);
                
                //Update the course bookings for populating the Date Survey sent field. 
                update courseBookings;
                
                //If this the first time Survey have been sent for this course
                if(course.Date_Survey_first_sent__c == null)
                {
                    course.Date_Survey_first_sent__c= System.today();
                    update course;
                }
                System.debug('Number of Queries used -- CM SendSurvey END ------- ' + Limits.getQueries());
                return 'SUCCESS:Survey email sent successfully.';
            }
            System.debug('Number of Queries used -- CM SendSurvey END ------- ' + Limits.getQueries());
            return 'FAILURE:NO_VALID_EMAIL';
            
        }
        catch(System.Exception e)
        {
            System.debug('Number of Queries used -- CM SendSurvey END ------- ' + Limits.getQueries());
            return 'FAILURE:Failed to send survey.Error-' + e.getMessage();
        }
    }
    
    private static void addFiles(Messaging.SingleEmailMessage mail, List<ContentVersion> AllFiles) {
        System.debug('Number of Queries used -- CM addFiles START ------- ' + Limits.getQueries());
        Map<string, string> mimeTypeMap = new Map<string, string>();
        
        if(AllFiles.size()>0)
        {
            List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
            
            for(ContentVersion document: AllFiles)
            {  
                System.debug('***Type '+ mimeTypeMap.get(document.FileType));              
                Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
                fileAttachment.setBody(document.VersionData);
                fileAttachment.setFileName(document.Title+'.'+document.FileExtension);                                
                fileAttachments.add(fileAttachment);
            }
            mail.setFileAttachments(fileAttachments);                  
        }
        System.debug('Number of Queries used -- CM addFiles END ------- ' + Limits.getQueries());
    }  
    
    @AuraEnabled
    public static List<Courses__c > fetchCourseInformation(String courseId){
        System.debug('Number of Queries used -- CM fetchCourseInformation START ------- ' + Limits.getQueries());
        
        List<Courses__c > courseList = new List<Courses__c>();
        List<Courses__c > courseListValues = new List<Courses__c>();
        if(courseId!=null){
		courseList = [SELECT Id,Course_Name__c ,Qualification_Available__c,Course_Type__c  FROM Courses__c WHERE Id =:courseId];
            system.debug('courseList'+courseList);
        }
        for(Courses__c crs : courseList){
            if(crs.Qualification_Available__c !='' || crs.Course_Name__c.indexOf('SODA')!=-1||crs.Course_Type__c == 'System Training'){
                courseListValues.add(crs);
            }else{
                courseListValues.add(null);
            }
        }

        System.debug('Number of Queries used -- CM fetchCourseInformation END ------- ' + Limits.getQueries());
        return courseListValues;
    }
    
}