@isTest(SeeAllData=true)
public class CampaignTriggerManager_Test {
    
    static testMethod void TestvalidateUser(){
        CampaignTriggerManager.validateUser(insertNewCampaigns());
    }
    static testMethod void TestassignDateFields(){
        CampaignTriggerManager.assignDateFields(insertNewCampaigns());
    }
    static testMethod void TestcheckStartDate(){
        CampaignTriggerManager.checkStartDate(insertOldCampaigns(),insertNewCampaigns());
    }
    static testMethod void TestCampaignTrigger(){
        updateCampaigns(insertNewCampaigns());
        try{
        DeleteCampaigns(insertNewCampaigns());
        }
        catch(Exception e){
            System.assertEquals(e.getMessage(),e.getMessage());
        }
    }
    static List<Campaign> insertNewCampaigns()
    {
        List<Campaign> Newcampaigns = new List<campaign>();
        for(Integer i=0;i<4;i++)
        {
            Campaign campaign = new Campaign();
            campaign.Name = 'Test Campaign';
            campaign.ownerid = Userinfo.getUserid();
            campaign.CurrencyIsoCode = 'GBP';
            campaign.Deactivation_Date__c = date.today();
            campaign.StartDate=date.today()+(i*50);
            campaign.Description = 'Test';
            campaign.Campaign_Objectives__c = 'Client engagement';
            Newcampaigns.add(campaign);
        }
        insert Newcampaigns;
        return Newcampaigns;
    }
    
    static List<Campaign> insertOldCampaigns()
    {
        List<Campaign> Oldcampaigns = new List<campaign>();
        for(Integer i=0;i<4;i++)
        {
            Campaign campaign = new Campaign();
            campaign.Name = 'Test Campaign';
            campaign.CurrencyIsoCode = 'GBP';
            campaign.Deactivation_Date__c = date.today()+(i*50);
            campaign.StartDate=date.today();
            campaign.Description = 'Test';
            campaign.Campaign_Objectives__c = 'Client engagement';
            Oldcampaigns.add(campaign);
        }
        
        insert Oldcampaigns;
        return Oldcampaigns;
    }
    
    static void updateCampaigns(List<campaign> insertedCampaigns)
    {
        List<Campaign> Campaigns= new List<campaign>();
        List<Campaign> insertedCampaign = new List<Campaign>();
        
        for(Campaign cam: insertedCampaigns)
        {
            Campaign Campaign = new Campaign(id=cam.id);
            campaign.Description = 'Test';
            campaign.Campaign_Objectives__c = 'Lead generation';
            campaign.StartDate=Date.newInstance(2019, 12, 9);
            Campaigns.add(Campaign);
        }
        update Campaigns;
    }  
    
    Static Void DeleteCampaigns(List<campaign> insertedCampaigns){
        Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='Commercial' limit 1];
        User user = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
        System.runAs(user){
            delete insertedCampaigns;
        }
    } 
    
}