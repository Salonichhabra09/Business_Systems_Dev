public class Assessment_Manager 
{
    public static void ChkProfCenter(List<Assessment__c> NewAssessments,List<Assessment__c> OldAssessments)
    {
        List<Assessment__c> modifiedAssessments = new List<Assessment__c>();
        for(Integer i=0; i<trigger.new.size(); i++){
            if(NewAssessments[i].Profit_Centre__c != OldAssessments[i].Profit_Centre__c)
              modifiedAssessments.add(NewAssessments[i]);
        }
            setupAssessmentData(modifiedAssessments);
    
    }
    
    public static void setupAssessmentData(List<Assessment__c> assessments)
    {
        for(Assessment__c assessment: assessments)
        {
            Integer startIndexOfCharacter = assessment.Profit_Centre__c.indexOf('-')+2;
            Integer endIndexOfCharacter = startIndexOfCharacter+2;
            if(assessment.Profit_Centre__c.substring(startIndexOfCharacter,endIndexOfCharacter)=='uk')
                endIndexOfCharacter =startIndexOfCharacter+3;
            assessment.SSC_Email__c = assessment.Profit_Centre__c.substring(startIndexOfCharacter,endIndexOfCharacter) +'SOE@shlgroup.com';
        }   
    }        
}