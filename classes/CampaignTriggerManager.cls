/**************************************************************************************************************************************
CREATED BY :- PRIYANK ANAND	
CREATED DATE :- 07-06-2019
DESCRIPTION :- This class contains various validations and assignments on fields of Campaign object, this class is called in Campaign_Trigger.
***************************************************************************************************************************************/ 
 
Global class CampaignTriggerManager {
    //This method is validating the user, if user can delete campaign or not? User should not be allowed to delete other's campaign if they are not member of DeleteCampignUsers Group. 
    public static void validateUser(List<Campaign> campaigns){
        Set<Id> superusers= new Set<Id>();
        Group usergroup =[select id,(select id,userorgroupid from groupmembers) from group where name='DeleteCampignUsers'];
        for(groupmember member : usergroup.groupmembers)
            superusers.add(member.userorgroupid);
        
        for ( Campaign campaign:campaigns)
        {
            if( campaign.ownerid != Userinfo.getUserid() )
            {
                if(!superusers.contains(Userinfo.getUserId()))
                    campaign.adderror('You don\'t have permission to delete the campaign.');
            }    
        }  
    } 
    
    //This method is assigning fields related to start date.If Campaign start date is blank, then 'Start Date will be set as the current date.
    //Year, Month and Fiscal Quarter values should automatically populate on the basis of Start Date.
    public static void assignDateFields(List<Campaign> campaigns){
        
        for(Campaign campaign :campaigns ){
            if(campaign.StartDate==null)
                campaign.StartDate=Date.today();
            Date startdate=campaign.StartDate;
            campaign.Year__c=string.valueOf(startdate.year());
            campaign.Month__c=string.valueOf(startdate.month());
            if(campaign.Month__c=='1' || campaign.Month__c=='2'||campaign.Month__c=='3')
            {
                campaign.Fiscal_Quarter__c='Q1';
            }
            else
            {
                if(campaign.Month__c=='4' || campaign.Month__c=='5'||campaign.Month__c=='6')
                {
                    campaign.Fiscal_Quarter__c='Q2';
                }
                else
                {
                    if(campaign.Month__c=='7' || campaign.Month__c=='8'||campaign.Month__c=='9')
                    {
                        campaign.Fiscal_Quarter__c='Q3';
                    }
                    else
                    {
                        campaign.Fiscal_Quarter__c='Q4';
                    }
                }
            }
        }
        
    }
    
    //This method is checking if start date is being updated! If yes then assignDateFields will be called.
    public static void checkStartDate(List<Campaign> oldcampaigns,List<Campaign> newcampaigns){
        List<Campaign> usedCampaigns= new List<Campaign>();
        for(Integer i=0;i<oldcampaigns.size();i++){
            if(oldcampaigns[i].StartDate!=newcampaigns[i].StartDate){
                usedCampaigns.add(newcampaigns[i]);
            }
        }
        if(usedCampaigns.size()>0)
            assignDateFields(usedCampaigns);
        
    }

    /**
     * @description Captures the previous values of Offer__c and Type fields before update.
     *              This method stores the old field values in Old_Asset__c and Old_Tactic__c fields
     *              to enable tracking of changes and triggering downstream processes when these 
     *              critical fields are modified.
     * 
     * @param newcampaigns List of Campaign records with new values (Trigger.new)
     * @param oldCampaignsMap Map of Campaign records with old values (Trigger.oldMap)
     * 
     * @see CampaignLeadMetricsBatch - Uses Old_Asset__c and Old_Tactic__c to identify modified campaigns
     * @see LeadCampaignService.calculateLeadFieldsForScoring - Checks for field changes using these fields
     * 
     */
    public static void captureOldValues(List<Campaign> newcampaigns, Map<Id, Campaign> oldCampaignsMap) {
        for (Campaign c : newcampaigns) {
            Campaign oldCampaign = oldCampaignsMap.get(c.Id);
            // If Offer__c (Asset) field has changed, store the old value
            if(c.Offer__c != oldCampaign.Offer__c) {
                c.Old_Asset__c = oldCampaign.Offer__c;
            }else{
                c.Old_Asset__c = null;
            }
            // If Type (Tactic) field has changed, store the old value
            if(c.Type != oldCampaign.Type) {
                c.Old_Tactic__c = oldCampaign.Type;
            }else{
                c.Old_Tactic__c = null;
            }
        }
    }
}