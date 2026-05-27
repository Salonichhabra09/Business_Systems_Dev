@isTest
public class UserTriggerTest {
    
    @isTest(seealldata=true) static void UserCreate() { 
    
        UserRole obj=new UserRole(Name= 'ABC'); 
        insert obj; 
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        Profile pfOAT= [Select Id from profile where Name='OAT']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User uu=new User(firstname = 'ABC', 
        lastName = 'XYZ', 
        email = uniqueName + '@test' + orgId + '.org', 
        Username = uniqueName + '@test' + orgId + '.org', 
        EmailEncodingKey = 'ISO-8859-1', 
        Alias = uniqueName.substring(18, 23), 
        TimeZoneSidKey = 'America/Los_Angeles', 
        LocaleSidKey = 'en_US', 
        LanguageLocaleKey = 'en_US', 
        ProfileId = pf.Id, 
        UserRoleId = obj.Id,
        Case_Teams__c = 'APAC Customer Experience'); 
        insert uu;
        uu.ProfileId = pfOAT.Id;
        uu.Case_Teams__c = 'India Customer Experience';
        update uu;
        
        
        System.runAs(uu) {
        
            //insert new Trigger_Activation__c(Active__c = true, Object_Name__c = 'User', Name = 'User_Trigger');
        
            User u=new User(firstname = 'ABC', 
            lastName = 'XYZ', 
            email = uniqueName + '@test' + orgId + '.org', 
            Username = uniqueName + '@test' + orgId + '.org', 
            EmailEncodingKey = 'ISO-8859-1', 
            Alias = uniqueName.substring(18, 23), 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            LanguageLocaleKey = 'en_US', 
            ProfileId = pf.Id, 
            UserRoleId = obj.Id); 
            //insert u; 
        
        }
        
    }     
}