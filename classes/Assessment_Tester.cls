@isTest
private class Assessment_Tester 
{
     static testMethod void testABTriggers()
     {
        insert new Trigger_Activation__c(Name = 'Assessment_Trigger', Active__c = true);
        //system.debug('Assessment : Insert Started');
        List<Assessment__c> assessments = new List<Assessment__c>();
        Assessment__c assessment = new Assessment__c();
        assessment.Category__c = 'Individual';
        assessment.Name__c = 'Sample Assessment';
        assessment.Description__c = 'Sample Assessment';
        assessment.Duration__c = '24';
        assessment.Profit_Centre__c = 'Belgium - BE5';
        assessment.BU__c = 'Australia';
        assessments.add(assessment);
        insert assessments;
        system.debug('Assessment: Insert Completed' + assessment);
        assessment.Profit_Centre__c = 'Denmark - DK5';
        update assessments;
    
            
    }
    
     static testMethod void testABTriggers1()
     {
        insert new Trigger_Activation__c(Name = 'Assessment_Trigger', Active__c = true);
        //system.debug('Assessment : Insert Started');
        List<Assessment__c> assessments = new List<Assessment__c>();
        Assessment__c assessment = new Assessment__c();
        assessment.Category__c = 'Individual';
        assessment.Name__c = 'Sample Assessment';
        assessment.Description__c = 'Sample Assessment';
        assessment.Duration__c = '24';
        assessment.Profit_Centre__c = 'UK - UK1';
        assessment.BU__c = 'Australia';
        assessments.add(assessment);
        insert assessments;
        system.debug('Assessment: Insert Completed' + assessment);
        
      
    }
    
    
}