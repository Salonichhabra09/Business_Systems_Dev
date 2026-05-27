Public with sharing class Cls_LeadTrigger_trg
{
    Public static void InsertupdateLeadrecords(List<Lead>newLeadList)
    {
    
        for(Lead l:newLeadList)
        {
           /* if(l.Area_of_Interest__c=='CEB High Potential Solution')
                {
                    l.TM_Phase__c='Assess';
                    l.Talent_Segment__c='High Potential';
                    l.Offering__c='CEB High Potential';
                    l.Talent_Level__c='';
                }
                
            else if(l.Area_of_Interest__c=='CEB Enterprise Leadership Solution')
                {
                    l.TM_Phase__c='Assess';
                    l.Talent_Segment__c='Manager / Leader';
                    l.Talent_Level__c='Executive';
                    l.Offering__c='CEB Enterprise Leadership';
                }
            else if(l.Area_of_Interest__c=='CEB Effortless Experience')
                {
                    l.TM_Phase__c='Assess';
                    l.Talent_Segment__c='';
                    l.Offering__c='CEB Effortless Experience';
                    l.Talent_Level__c='';
                    
                }
                
            else if(l.Area_of_Interest__c=='Recruit Entry-level')
                {
                    l.TM_Phase__c='Recruit';
                    l.Talent_Segment__c='';
                    l.Talent_Level__c='Entry-Level / Unskilled';
                    l.Offering__c='';
                }   
            else if(l.Area_of_Interest__c=='Recruit Graduates')
                {
                    l.TM_Phase__c='Recruit';
                    l.Talent_Segment__c='Graduate / Apprentice';
                    l.Offering__c='';
                    l.Talent_Level__c='';
                }
            else if(l.Area_of_Interest__c=='Recruit Functional/Professional')
                {
                    l.TM_Phase__c='Recruit';
                    l.Talent_Segment__c='Functional / Professional';
                    l.Offering__c='';
                    l.Talent_Level__c='';
                
                }
                
            else if(l.Area_of_Interest__c=='Recruit Managers/Leaders')
                {
                    l.TM_Phase__c='Recruit';
                    l.Talent_Segment__c='Manager / Leader';
                    l.Offering__c='';
                    l.Talent_Level__c='';
                }
            else if(l.Area_of_Interest__c=='General Talent Audit/Assessment')
                {
                    l.TM_Phase__c='Assess';
                    l.Talent_Segment__c='';
                    l.Offering__c='Talent Audit';
                    l.Talent_Level__c='';
                }
                            
            else if(l.Area_of_Interest__c=='CEB Functional Talent Assessment')
                {
                    l.TM_Phase__c='Assess';
                    l.Talent_Segment__c='';
                    l.Offering__c='CEB Functional Talent Assessment';
                    l.Talent_Level__c='';
                }
            else if(l.Area_of_Interest__c=='Develop Staff - General')
                {
                    l.TM_Phase__c='Develop';
                    l.Talent_Segment__c='';
                    l.Talent_Level__c='';
                    l.Offering__c='';
                }
                    
            else if(l.Area_of_Interest__c=='Develop Staff - High Potential')
                {
                    l.TM_Phase__c='Develop';
                    l.Talent_Segment__c='High Potential';
                    l.Talent_Level__c='';
                    l.Offering__c='';
                }   
            
            else if(l.Area_of_Interest__c=='Develop Staff - Managers/Leaders')
                {
                    l.TM_Phase__c='Develop';
                    l.Talent_Segment__c='Manager / Leader';
                    l.Talent_Level__c='';
                    l.Offering__c='';
                }   
             // Changes needs to be check.-Start           
             else if(l.Area_of_Interest__c=='Succession Planning')
                {
                    l.TM_Phase__c='Plan';
                    l.Talent_Segment__c='Manager / Leader';
                    l.Talent_Level__c='';
                    l.Offering__c='';
                } */  
                
                
                
                if(l.Area_of_Interest__c=='High Potential Solution')
                {
                    l.TM_Phase__c='Talent Management';
                    l.Offering__c='HiPo';
                    l.Talent_Level__c='Professional Individual Contributor';
                    
                }
                
            else if(l.Area_of_Interest__c=='Enterprise Leadership Assessment')
                {
                    l.TM_Phase__c='Talent Management';
                    l.Talent_Level__c='Senior Leadership';
                    l.Offering__c='Enterprise Leadership';
                        }
            else if(l.Area_of_Interest__c=='Leader Edge')
                {
                    l.TM_Phase__c='Talent Management';
                    l.Offering__c='Leader Edge';
                    l.Talent_Level__c='Senior Leadership';
                      
                }
             else if(l.Area_of_Interest__c=='PreciseFit')
                {
                    l.TM_Phase__c='Talent Acquisition';
                  l.Offering__c='SHL Experiences';
                    l.Talent_Level__c='';
                    
                }
                else if(l.Area_of_Interest__c=='Pre-Hire Entry-level')
                {
                    l.TM_Phase__c='Talent Acquisition';
                    l.Offering__c='';
                    l.Talent_Level__c='Entry Level / Associate';
                    
                }
                else if(l.Area_of_Interest__c=='Pre-Hire Graduates')
                {
                  l.TM_Phase__c='Talent Acquisition';
                   l.Offering__c='';
                    l.Talent_Level__c='Graduate and Intern';
                     
                }
                else if(l.Area_of_Interest__c=='Pre-Hire Functional/Professional')
                {
                    l.TM_Phase__c='Talent Acquisition';
                    l.Offering__c='';
                    l.Talent_Level__c='Professional Individual Contributor';
                    
                }
                else if(l.Area_of_Interest__c=='Pre-Hire Managers/Leaders')
                {
                   l.TM_Phase__c='Talent Acquisition';
                    l.Offering__c='';
                    l.Talent_Level__c='Manager';
                      
                }
                else if(l.Area_of_Interest__c=='Post-Hire Talent Audit/Assessment')
                {
                  l.TM_Phase__c='Talent Management';
                   l.Offering__c='Talent Audit Internal Assessment';
                    l.Talent_Level__c='';
                     
                }
                else if(l.Area_of_Interest__c=='Develop Staff - General')
                {
                    l.TM_Phase__c='Talent Management';
                    l.Offering__c='';
                    l.Talent_Level__c='';
                    
                }
                else if(l.Area_of_Interest__c=='Develop Staff - High Potential')
                {
                    l.TM_Phase__c='Talent Management';
                   l.Offering__c='';
                    l.Talent_Level__c='Professional Individual Contributor';
                    
                }
                else if(l.Area_of_Interest__c=='Develop Staff - Managers/Leaders')
                {
                   l.TM_Phase__c='Talent Management';
                   l.Offering__c='';
                    l.Talent_Level__c='Manager';
                    
                }
                else if(l.Area_of_Interest__c=='Succession Planning')
                {
                  l.TM_Phase__c='Talent Management';
                   l.Offering__c='';
                    l.Talent_Level__c='Manager';
                     
                }
                else if(l.Area_of_Interest__c=='Consulting')
                {
                    l.TM_Phase__c='Talent Acquisition';
                  l.Offering__c='Consulting Services';
                    l.Talent_Level__c='';
                    
                }
                else if(l.Area_of_Interest__c=='Sunstone Analytics')
                {
                    l.TM_Phase__c='Pre-Hire';
                  l.Offering__c='Sunstone Analytics';
                    l.Talent_Level__c='';
                    
                }
             else if(l.Area_of_Interest__c=='-- Please Select --') 
                {
                    l.Area_of_Interest__c='';
                    l.TM_Phase__c='';
                    l.Talent_Level__c='';
                    l.Offering__c='';
                }   
             else
                {
                    l.TM_Phase__c='';
                    l.Talent_Level__c='';
                    l.Offering__c='';
                }


        
        
       }
    
    
    
    
    }
    
    public static void updateLead(List<Lead>newList)
        {
            for(Lead l: newList)
            { 
                if(l.Job_Function__c=='Customer Services / Call Centre'){l.Function__c='Customer Service / Call Center';} 
                else if(l.Job_Function__c=='Finance'){l.Function__c='Finance';}   
                else if(l.Job_Function__c=='Graduate Recruitment'){l.Function__c='';}       
                else if(l.Job_Function__c=='Human Resources' || l.Job_Function__c=='Learning & Development / Training' || l.Job_Function__c=='Recruitment / Talent Acquisition' || l.Job_Function__c=='Talent Management'){l.Function__c='HR';}
                else if(l.Job_Function__c=='Information Technology'){l.Function__c='IT / Technology';}
                else if(l.Job_Function__c=='Legal'){l.Function__c='Legal';}
                else if(l.Job_Function__c=='Marketing'){l.Function__c='Marketing';}
                else if(l.Job_Function__c=='Operations'){l.Function__c='Procurement & Ops';}
                else if(l.Job_Function__c=='Other') {l.Function__c='Unknown';}   
                else if(l.Job_Function__c=='Sales'){l.Function__c='Sales';}
                else{l.Function__c='';}   
        
        
            }
        
        
        }
    


}