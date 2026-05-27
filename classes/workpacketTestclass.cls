@isTest(seeAllData=true) 
public class workpacketTestclass {

static testMethod void workpacket()
{
    Test.startTest();
        User oppsUser = [SELECT Id FROM User WHERE UserName Like 'globus.development@shlgroup.com%' limit 1];
        RecordType newRT = [select id from RecordType where developerName='CPS_Project' AND SobjectType='ProjectObject__c'];
        System.runAs(oppsUser) {
            ProjectObject__c prj = new ProjectObject__c(CS_Lead__c='Emma Lee',Project_Name__c='CPS Project',RecordTypeId=newRT.Id);
            insert prj;
            
            Workpacket__c  wc = new Workpacket__c (CS_Lead__c='Emma Lee',CPS_Project_Number__c=prj.Id,Actual_Delivery__c=Date.Today(),Agreed_Delivery__c=Date.today().addDays(5),Description__c='Test');
            insert wc;
            
            wc.Actual_Delivery__c =Date.Today().addDays(1);
            update wc;
        }
    Test.stopTest();
}



}