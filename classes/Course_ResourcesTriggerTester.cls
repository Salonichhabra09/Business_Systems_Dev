@isTest(SeeAllData=true)
private class Course_ResourcesTriggerTester
{
    static testMethod void testCourseResourceTriggers()
    {
    
        Contact c = new Contact();
        c.firstname='test';
        c.lastname='test';
        c.email='test@test.com';
        c.Mailing_Address_Line_1__c ='true address';
        c.Mailing_City__c='testcity';
        c.Mailing_ZIP_Postal_Code__c='334001';
        c.Mailing_Country__c='India';
        insert c;
        
        contact ct = new contact();
        ct.lastname='Generic User';
        ct.firstname= 'firstname';
        ct.email='genericuser@test.com';
        ct.Mailing_Address_Line_1__c ='true address';
        ct.Mailing_City__c='testcity';
        ct.Mailing_ZIP_Postal_Code__c='334001';
        ct.Mailing_Country__c='India';
        insert ct;
        
        Courses__c cp  = new Courses__c();
        //cp.Course_Director__c = ct.id;
        cp.Duration__c='12';
        cp.Maximum_Delegates__c=12;
        cp.Course_Description__c='description';
        cp.Course_Name__c=cp.id;
        insert cp;
        
        Course_Resources__c courseResource = new Course_Resources__c();
        courseResource.Course_Name__c = cp.id;
        //courseResource.Resource_Name__c = contactId;
        courseResource.Resource_Name__c = c.Id;
        courseResource.Resource_Role__c = 'Course Director';
        insert courseResource ;
        
        courseResource.Resource_Role__c = 'Tutor 1';
        update courseResource ;
        
        test.starttest();
        
        courseResource.Resource_Name__c = ct.Id;
        courseResource.Resource_Role__c = 'Course Director';
        update courseResource ;
        test.stoptest();
        
        delete courseResource;
    }

}