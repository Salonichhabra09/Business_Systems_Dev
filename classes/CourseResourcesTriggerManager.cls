/**************************************************************************************************************************************
CREATED BY :- RISHABH KANOTRA
CREATED DATE :- 22/08/2019
DESCRIPTION :- This class contains various validations and restrictions to modify CourseResources and its fields and refered from Course_Resources_Trigger triggers : after insert,after update,after delete
***************************************************************************************************************************************/ 
 
Global class CourseResourcesTriggerManager{
    
    //Handling of custom validations when Account is updated
    //If Resource_Role__c  = Course Director then update the related course -> Course_Director__c to the Resource_Name__c of the course resource.
    public static void CRafterInsert(List<Course_Resources__c> newCourseResource){ 
        
        List<Courses__c> CRtoupdate = New List<Courses__c>();
        for (integer i=0;i<newCourseResource.size();i++)
        {  
            Courses__c course = new Courses__c(Id = newCourseResource[i].Course_Name__c);
            if(newCourseResource[i].Resource_Role__c == 'Course Director')
            {  
                course.Course_Director__c =  newCourseResource[i].Resource_Name__c;
                //update course;
                CRtoupdate.add(course);   
            }  
        }
        update CRtoupdate;
    }//CRafterInsert
    
    //Update the related course->Course_Director__c based on different conditions.
    public static void CRafterUpdate(List<Course_Resources__c> oldCourseResource, List<Course_Resources__c> newCourseResource){ 
        
        Set<Courses__c> CRtoupdate2 = New Set<Courses__c>();
        for (integer i=0;i<newCourseResource.size();i++)
        {
            Courses__c course = new Courses__c(Id = newCourseResource[i].Course_Name__c);
            Boolean CourseUpdatedRequired = false;
            if(newCourseResource[i].Resource_Role__c != oldCourseResource[i].Resource_Role__c)
            {
                if(newCourseResource[i].Resource_Role__c == 'Course Director')
                    course.Course_Director__c =  newCourseResource[i].Resource_Name__c;
                else if(oldCourseResource[i].Resource_Role__c == 'Course Director')
                    course.Course_Director__c =  null;
                CourseUpdatedRequired = true; 
            }
            if (newCourseResource[i].Resource_Status__c!= oldCourseResource[i].Resource_Status__c)
            {
                if ((newCourseResource[i].Resource_Role__c == 'Course Director')&& (newCourseResource[i].Resource_Status__c=='Cancelled'))
                {
                    course.Course_Director__c = null;  
                    CourseUpdatedRequired = true;
                } 
            }  
            if(newCourseResource[i].Resource_Name__c != oldCourseResource[i].Resource_Name__c)
            {
                if(newCourseResource[i].Resource_Role__c == 'Course Director')
                {
                    course.Course_Director__c =  newCourseResource[i].Resource_Name__c;
                    CourseUpdatedRequired = true; 
                }
            }
            if(CourseUpdatedRequired)
                CRtoupdate2.add(course);
                //update course;
        }  
        List<Courses__c> CRtoupdate2List = New List<Courses__c>();
        CRtoupdate2List.addAll(CRtoupdate2);
        update CRtoupdate2List;
    }//afterUpdate
    
    //update the related course->Course_Director__c to NULL 
    public static void CRafterDelete(List<Course_Resources__c> oldCourseResource){ 
        
        List<Courses__c> CRtoupdate = New List<Courses__c>();
        for (integer i=0;i<oldCourseResource.size();i++)
        {
            if(oldCourseResource[i].Resource_Role__c == 'Course Director')
            {
                Courses__c course = new Courses__c(Id = oldCourseResource[i].Course_Name__c);
                course.Course_Director__c = null;
                CRtoupdate.add(course);
                //update course;  
            }
        }
        update CRtoupdate;
    }//CRafterDelete
 }