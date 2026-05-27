/*****************************************************************************
CREATED BY :- Prabhat Arora
CREATED DATE :- 17-06-2019
DESCRIPTION :- This class contains various Methods/Checks/Assignments to controll Lead Functionality as per SHL business process,
               this class is being refered from Lead_Trigger, covering all the Before/After, Insert & Update Events on Lead Records. 
******************************************************************************/


Global class LeadTriggerManager {
    //Method to Match the Address in Contact Address Info Section & Account Billing Info section on Lead
    Public static void AddressMatcher(List<Lead> OldLeads,List<Lead> NewLeads){
        Map<String,String> CountryBUmap = New Map<String,String>();
        for(Country__mdt CountryBuList :[SELECT Id, Country__c, BU__c FROM Country__mdt]){
        CountryBUmap.put(CountryBuList.Country__c,CountryBuList.BU__c);
        }
        for(Integer i=0;i<NewLeads.size();i++){
            if(NewLeads[i].Same_as_contact_address__c==true)
            {     
            if(OldLeads == null || 
              (OldLeads != null &&(NewLeads[i].Same_as_contact_address__c!=OldLeads[i].Same_as_contact_address__c ||
            (NewLeads[i].City_Town__c !=OldLeads[i].City_Town__c || NewLeads[i].Lead_Country__c !=OldLeads[i].Lead_Country__c ||
             NewLeads[i].Zip_Postcode__c !=OldLeads[i].Zip_Postcode__c || NewLeads[i].State_County__c !=OldLeads[i].State_County__c || NewLeads[i].Address_1__c !=OldLeads[i].Address_1__c ||
             NewLeads[i].Address_2__c !=OldLeads[i].Address_2__c || NewLeads[i].Address_3__c !=OldLeads[i].Address_3__c ||
             NewLeads[i].Address_4__c !=OldLeads[i].Address_4__c))))//SSE-16905 - Prachi
                {
                System.debug('*****NewLeads[i].Lead_Country__c*****'+NewLeads[i].Global_Lead_Country__c);   
                string buValue = CountryBUmap.get(NewLeads[i].Global_Lead_Country__c);
                NewLeads[i].Account_BU__c = buValue;//SSE-16905 - Prachi   
                NewLeads[i].Account_BillingCity__c = NewLeads[i].City_Town__c;
                NewLeads[i].Account_BillingCountry__c = NewLeads[i].Global_Lead_Country__c;//SSE-16905 - Prachi
                NewLeads[i].Global_Account_BillingCountry__c = NewLeads[i].Global_Lead_Country__c;   //SSE-16905 - Prachi 
                NewLeads[i].Account_BillingPostalCode__c = NewLeads[i].Zip_Postcode__c;
                NewLeads[i].Account_State_County__c = NewLeads[i].State_County__c;
                NewLeads[i].Account_Billing_Address_Line_1__c = NewLeads[i].Address_1__c;
                NewLeads[i].Account_Billing_Address_Line_2__c = NewLeads[i].Address_2__c;
                NewLeads[i].Account_Billing_Address_Line_3__c = NewLeads[i].Address_3__c;
                NewLeads[i].Account_Billing_Address_Line_4__c = NewLeads[i].Address_4__c;
                }
            }
            else
                NewLeads[i].Account_BU__c = CountryBUmap.get( NewLeads[i].Global_Lead_Country__c);//SSE-16905 - Prachi 
                if(NewLeads[i].CAMID__c !=  NewLeads[i].Contact_CAM_ID__c)
                NewLeads[i].Contact_CAM_ID__c =  NewLeads[i].CAMID__c;
        } 
    }
    //Method to Map Hiring Need,Talent Level,Offering & Talent Segment on the basis of Area of Interest    
    Public static void UserAndProfileChk(List<Lead> NewLeads, Map<id,Lead> OldLeadMap){
        
        List<Profile> profileList = [SELECT Name from Profile where Id=:UserInfo.getProfileId() limit 1];
        
        if(profileList.size() > 0 && profileList[0].Name != null){
            String profile_Name = profileList[0].Name; 
            for(Lead l: NewLeads){
                if((l.Area_of_Interest__c!=OldLeadMap.get(l.id).Area_of_Interest__c) && (profile_Name=='System Administrator'|| profile_Name=='NEW Eloqua User'))
                 {
                     Cls_LeadTrigger_trg.InsertupdateLeadrecords(NewLeads);
                 }        
            }
        }
        
    }
    //Method to Check if the owner of Lead is Queue or User and updating the Assignment Date
    Public static void ChkOwnerIdStatus(List<Lead> NewLeads, Map<id,Lead> OldLeadMap, Map<id,Lead> NewLeadMap){
        for(Lead l: NewLeads){
            if((((String)l.OwnerId).substring(0,3) == '005'  && l.OwnerId != OldLeadMap.get(l.id).OwnerId ) || (l.Status == 'New' && OldLeadMap.get(l.id).Status !=NewLeadMap.get(l.id).Status))
            {
                    system.debug('***********Inside Assignment Date IF Loop*********'+l.ownerId);
                    l.Assignment_Date__c = system.Now();
            }
        }
    }
    
    //Commented the code as method call is commented on the Lead Trigger. (Done as a part of SD-151386)
    /*Public static void ChkQueueOrOwnerAssignment(List<Lead> NewLeads,List<Lead> OldLeads ){
        Group gLeadQueue;
        List<LeadLastAssignedTo__c> leadLastAssignedToList;
        List<Id> queueUserIds = new List<Id>();
        List<User> queueUsersList = new List<User>();
        List<User> queueMembersList;
        Integer lastAssingedCounter =0;
            for(Integer i=0;i<NewLeads.size();i++){
            if(NewLeads[i].OwnerId <> OldLeads[i].OwnerId)
            {            
                //Retrieve the 'ISAM Lead Queue' ID
                if(gLeadQueue==null)
                {
                //Fetching custom setting.
                leadLastAssignedToList =   [SELECT id,LeadLastAssignedTo__c FROM LeadLastAssignedTo__c where Name='Last Assigned User'];
                //Fetching group members from queue.
                gLeadQueue=[Select Id,(Select UserOrGroupId from GroupMembers) from Group where name='ISAM Lead Queue'];
                //Retrieve the current users in ISAM queue
                for(GroupMember member: gLeadQueue.GroupMembers)
                    queueUserIds.add(member.UserOrGroupId);
                
                //Fetching active users only against queue members ids.
                queueMembersList = [Select id,Name from User where isActive=true and id in :queueUserIds order by Name];
                for(User user:queueMembersList)
                    queueUsersList.add(user);
                }
                //System.debug('*****queueUserIds*****'+queueUserIds);
            
                if(NewLeads[i].OwnerId == gLeadQueue.Id && queueUsersList.size()>0)
                {
                
                    System.debug('*****leadLastAssignedToList*****'+leadLastAssignedToList);
                    if(leadLastAssignedToList.size()==0)
                    {
                    LeadLastAssignedTo__c leadLast = new LeadLastAssignedTo__c();
                    leadLast.Name = 'Last Assigned User';
                    leadLast.LeadLastAssignedTo__c = queueUsersList[0].Name;
                    insert leadLast;
                    leadLastAssignedToList = [SELECT id,LeadLastAssignedTo__c FROM LeadLastAssignedTo__c where Name='Last Assigned User'];
                    }
                else
                {
                    for(Integer j=0;j<queueUsersList.size();j++)
                    {
                        if(queueUsersList[j].Name==leadLastAssignedToList[0].LeadLastAssignedTo__c)
                        {
                            lastAssingedCounter = j+1;
                            break;
                        }
                    }
                }
                    if(lastAssingedCounter>=queueUsersList.size())
                    {
                    NewLeads[i].OwnerId = queueUsersList[0].id;
                    leadLastAssignedToList[0].LeadLastAssignedTo__c = queueUsersList[0].Name;
                    }
                    else
                    {
                    NewLeads[i].OwnerId = queueUsersList[lastAssingedCounter].id;
                    leadLastAssignedToList[0].LeadLastAssignedTo__c = queueUsersList[lastAssingedCounter].Name;
                    }
                }
            }
            }
            if(leadLastAssignedToList!=null && leadLastAssignedToList.size()>0)
            update leadLastAssignedToList;
    }*/
    //Method to Send a Mail to Lead Submitter, if Submitter Practice on Lead is not Null     
    Public static void SendMailtoSubmitter(List<Lead> NewLeadstoMail){
        list<lead> ListL = new list<lead>();
        set<id> SetCon=new set<id>();
        set<id> SetOpp=new set<id>();
        List<opportunity> OpptoUpdate=new list<opportunity>();
        List<opportunity> listOpp=new list<Opportunity>();
        List<contact> ListCon=new list<Contact>();

            //Sending email to Lead submitter on lead conversion
            //Fetching Email Template
            EmailTemplate et=[Select id, Body,HtmlValue,subject from EmailTemplate where name=:'Your Referral has been UPDATED'];
            //list of emails
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();   
            string statuslead;
            
            for(Lead lead:NewLeadstoMail)
            {
                if (lead.IsConverted)
                {
                    ListL.add(lead); 
                    SetCon.add(lead.ConvertedContactId);
                    SetOpp.add(lead.ConvertedOpportunityId );
                       
                    if(lead.Submitter_s_CEB_Division__c != null && lead.Submitter_s_Email_Address__c != null &&  Utility.lead_isconveretd == true)
                    {               
                        statuslead = 'Converted';
                        String htmlBody = et.HtmlValue;
                        htmlBody = htmlBody.replace('{!Lead.Status}',statuslead);
                        String plainBody = et.Body;
                        plainBody = plainBody.replace('{!Lead.Status}', statuslead);            
                
                        htmlBody = htmlBody.replace('{!Lead.Owner_fullname__c}',lead.Owner_fullname__c);
                        
                        plainBody = plainBody.replace('{!Lead.Owner_fullname__c}', lead.Owner_fullname__c);
                        htmlBody = htmlBody.replace('{!Lead.Owner_email__c}',lead.Owner_email__c);
                        plainBody = plainBody.replace('{!Lead.Owner_email__c}',lead.Owner_email__c);
                        String leadname;
                        if(lead.FirstName == null)
                        leadname = lead.LastName;
                        else
                        leadname = lead.FirstName+' '+lead.LastName;
                        htmlBody = htmlBody.replace('{!Lead.Name}',leadname);
                        plainBody = plainBody.replace('{!Lead.Name}',leadname);
                        htmlBody = htmlBody.replace('{!Lead.Company}',lead.Company);
                        plainBody = plainBody.replace('{!Lead.Company}',lead.Company);
                        
                        //initiallize messaging method
                        Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();

                        //set object Id
                        singleMail.setwhatId(lead.ConvertedOpportunityId);
                        //set sender email address to submitter's email
                        if(lead.Submitter_s_Email_Address__c != null)
                        {
                            String userEmail = lead.Submitter_s_Email_Address__c; 
                            String[] toAddresses = new String[] {userEmail}; 
                            singleMail.setToAddresses(toAddresses); 
                        }
                        singleMail.setHtmlBody(htmlbody);
                        singleMail.setPlainTextBody(plainBody);
                        singleMail.setSaveAsActivity(false);
                        singleMail.setSubject('Your Referral has been UPDATED');
                        //add mail
                        emails.add(singleMail);
                        Utility.lead_isconveretd = false;
                               
                    }

                }
            }
            //send mail
            Messaging.sendEmail(emails);
            emails.clear();
            
            if (ListL.size()>0){
                        Listopp = [SELECT Id,Primary_Contact__c FROM Opportunity WHERE opportunity.Id in:SetOpp];
                        Listcon = [SELECT Id FROM Contact WHERE Contact.Id in: SetCon];
    
                    for(Lead Lead1:ListL){
                        for ( opportunity opp:ListOpp){
                            for( contact con:Listcon){
                            system.debug('<!---------Convert Leads --------->');
                            if((Lead1.ConvertedOpportunityId==opp.id) && (Lead1.ConvertedContactId==con.id))  
                                opp.Primary_Contact__c = con.id;
                                OpptoUpdate.add(opp);
                                system.debug('<!---------Check Opportunity Fields--------->'  + opp.Primary_Contact__c );
                            }

                        }
                    }
                    system.debug('******Update*******');
                    update OpptoUpdate;
            }
            
        }
        //Method to Trigger the Active Lead Assignment Rule on Lead Insert
        Public static void AssignmentRuleOnInsert(List<Lead> NewLeadstoAR){
            Set<id> LeadSet=new set<id>();
            if(LeadBelowThresholdQueueReAssignment.allow!=False){
                //if(UserInfo.getUserName().contains('eloqua_shl@cebglobal.com'))
                //{
                    List<lead> LeadList=[select id,Lead_stage__C,Urgent_Follow_Up_Required__c, Owner.Name,owner.email ,IsConverted, RecordTypeId, RecordType.Name from Lead where id in : NewLeadstoAR and IsConverted = False];
                    for(Lead L:LeadList)
                    {   
                        if(UserInfo.getUserName().contains('eloqua_shl@cebglobal.com')){
                        if(L.Urgent_Follow_Up_Required__c==True  && L.Owner.Name=='Leads - Below Threshold' )
                        {
                            LeadSet.add(L.id);
                            continue;
                        }
                        else if(L.Lead_Stage__c !=Null)
                        {
                            if( L.Lead_Stage__c=='AQL' && L.Owner.Name=='Leads - Below Threshold')
                            {
                            LeadSet.add(L.id);
                            }
                        }
                            
                    }
                        else if(L.RecordType.Name == 'Referral'){
                               LeadSet.add(L.id); 
                            } 
                    }
                //}
            }
            if(LeadSet.size()>0)
            {
                LeadBelowThresholdQueueReAssignment.ChangeAssignment(LeadSet);
            }
        }
        //Method to Trigger the Active Lead Assignment Rule on Lead Update
        Public static void AssignmentRuleOnUpdate(List<Lead> NewLeadstoAR){
            Set<id> LeadSet=new set<id>();
            if(LeadBelowThresholdQueueReAssignment.allow!=False){
                //if(UserInfo.getUserName().contains('eloqua_shl@cebglobal.com'))
                //{
                    List<lead> LeadList=[select id,Lead_stage__C,Urgent_Follow_Up_Required__c, Owner.Name,owner.email ,IsConverted,RecordTypeId, RecordType.Name,Status from Lead where id in : NewLeadstoAR and IsConverted = False];
                    for(Lead L:LeadList)
                    {   
                        if(UserInfo.getUserName().contains('eloqua_shl@cebglobal.com')){
                        if(L.Owner.Name=='Leads - Below Threshold')
                        {
                            if(L.Urgent_Follow_Up_Required__c==True)
                                {
                                LeadSet.add(L.id);
                                continue;
                                }
                        else if(L.Lead_Stage__c !=Null)
                            {
                                if( L.Lead_Stage__c=='AQL' && L.Owner.Name=='Leads - Below Threshold')
                                {
                                LeadSet.add(L.id);
                                }
                            }
                           
                        }
                        }
                        /* else if(L.RecordType.Name == 'Referral' && L.Status!='Nurturing' 
                                && !OwnerId.startswith('005')){
                               LeadSet.add(L.id); 
                            } */
                    }
                //}
            }
            if(LeadSet.size()>0)
                {
                LeadBelowThresholdQueueReAssignment.ChangeAssignment(LeadSet);
                }
        }
    
    //Change starts for SSE-16905 - Prachi
    //Change starts for SSE-16905 - Prachi
    public static void mapGlobalCountryFields(List<Lead> newLead,Map<Id,Lead> oldLeadMap,
                                              Map<Id,Lead> newLeadMap){
            for(Lead l : newLead){
                try{
            if(oldLeadMap == Null || (oldLeadMap != Null && 
                                         l.Global_Account_BillingCountry__c!= 
                                      oldLeadMap.get(l.Id).Global_Account_BillingCountry__c)){
                l.Account_BillingCountry__c = l.Global_Account_BillingCountry__c;
            }
            if(oldLeadMap == Null || (oldLeadMap != Null && 
                                         l.Global_Lead_Country__c != 
                                      oldLeadMap.get(l.Id).Global_Lead_Country__c )){
                 l.Lead_Country__c = l.Global_Lead_Country__c;                            
            }
            //Changes start for SSE-23920
            Map<String, Set<String>> superRegionValues = getFieldDependencies('Lead','Global_Lead_Country__c','Super_Region__c');
                    if(superRegionValues!=null && superRegionValues.get(l.Global_Lead_Country__c)!=null && superRegionValues.get(l.Global_Lead_Country__c).size()>0){
                    	l.Super_Region__c = new List<String>(superRegionValues.get(l.Global_Lead_Country__c))[0];
                    }
            //Changes end for SSE-23920
           }catch(DmlException ex){
                 Lead actualRecord = newLeadMap.get(l.Id); 
                 actualRecord.addError('We get the following error : ' +
                                        ex.getDmlMessage(0));
           }}
        
    }
     //Changes ends SSE-16905
    
    //Changes start for SSE-23920
     public static Map<String, Set<String>> getFieldDependencies(String objectName, String controllingField, String dependentField){
        Map<String, Set<String>> controllingInfo = new Map<String, Set<String>>();


        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        for(Schema.PicklistEntry currControllingValue : controllingValues){
            controllingInfo.put(currControllingValue.getValue(), new Set<String>());
        }
        for(Schema.PicklistEntry currDependentValue : dependentValues){
            String jsonString = JSON.serialize(currDependentValue);
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            Integer baseCount = 0;
//toLowerCase can be changed to uppercase and getLabel() can be changed to getValue() based on requirement.
            for(Integer curr : hexString.getChars()){
                Integer val = (curr >= 65)?(curr - 65 + 10):(curr - 48);
                    if((val & 8) == 8){controllingInfo.get(controllingValues[baseCount + 0].getValue()).add(currDependentValue.getLabel().toLowerCase());}


                if((val & 4) == 4){controllingInfo.get(controllingValues[baseCount + 1].getValue()).add(currDependentValue.getLabel().toLowerCase());}
                if((val & 2) == 2){controllingInfo.get(controllingValues[baseCount + 2].getValue()).add(currDependentValue.getLabel().toLowerCase());}
                if((val & 1) == 1){controllingInfo.get(controllingValues[baseCount + 3].getValue()).add(currDependentValue.getLabel().toLowerCase());}
                baseCount += 4;
            }            
        } 
        return controllingInfo;
    }
    
      public class MyPickListInfo{
        public String validFor;
    }
    
    //Changes end for SSE-23920
    
    public static void syncLeadsFromEloqua(List<Lead> leadList , Map<Id,Lead> oldLeadMap){
        
        Map<String, Lead> leadEmailMap = new Map<String, Lead>();
        for(Lead lead : leadList){
            if(lead.Email_Opted_In__c != oldLeadMap.get(lead.Id).Email_Opted_In__c	
              || lead.Double_Opted_In__c != oldLeadMap.get(lead.Id).Double_Opted_In__c
              || lead.Inactive_in_Eloqua__c != oldLeadMap.get(lead.Id).Inactive_in_Eloqua__c
              || lead.Email_Undeliverable__c != oldLeadMap.get(lead.Id).Email_Undeliverable__c
              || lead.Do_Not_Contact__c != oldLeadMap.get(lead.Id).Do_Not_Contact__c
              || lead.Constant_Soft_Bounce_Domain__c != oldLeadMap.get(lead.Id).Constant_Soft_Bounce_Domain__c
              || lead.Constant_Soft_Bounce_Contact__c != oldLeadMap.get(lead.Id).Constant_Soft_Bounce_Contact__c
              || lead.Email_Group_Subscription__c != oldLeadMap.get(lead.Id).Email_Group_Subscription__c)
            {
                if (String.isNotBlank(lead.Email)) {
                 	leadEmailMap.put(lead.Email, lead);    
                }  
            }  
        }
        list<Lead> sameEmailLeadList = [SELECT Id, Email, Email_Opted_In__c, Double_Opted_In__c, Inactive_in_Eloqua__c,
                                              Email_Undeliverable__c, Do_Not_Contact__c, 
                                              Global_Lead_Country__c, 
                                        Personal_Email_Address_Domain__c, Constant_Soft_Bounce_Domain__c, Constant_Soft_Bounce_Contact__c,
                                        Email_Group_Subscription__c
                                              FROM Lead
                                              WHERE Email IN :leadEmailMap.keySet()];
        
        if(!sameEmailLeadList.isEmpty()){
            for(Lead lead : sameEmailLeadList){
                lead.Email_Opted_In__c = leadEmailMap.get(lead.Email).Email_Opted_In__c;
                lead.Double_Opted_In__c = leadEmailMap.get(lead.Email).Double_Opted_In__c;
                lead.Inactive_in_Eloqua__c = leadEmailMap.get(lead.Email).Inactive_in_Eloqua__c;
                lead.Email_Undeliverable__c = leadEmailMap.get(lead.Email).Email_Undeliverable__c;
                lead.Do_Not_Contact__c = leadEmailMap.get(lead.Email).Do_Not_Contact__c;
                lead.Constant_Soft_Bounce_Domain__c = leadEmailMap.get(lead.Email).Constant_Soft_Bounce_Domain__c;
                lead.Constant_Soft_Bounce_Contact__c = leadEmailMap.get(lead.Email).Constant_Soft_Bounce_Contact__c;
                lead.Email_Group_Subscription__c = leadEmailMap.get(lead.Email).Email_Group_Subscription__c;
            }
            try{
                UPDATE sameEmailLeadList;   
            }
            catch(DMLException ex){
                System.debug(ex.getMessage());
            }
        }
    }
    
    public static void checkPersonalEmailAddressDomain(List<Lead> leadList, Map<Id,Lead> oldLeadMap){
        
        Set<String> personalDomainSet = new Set<String>();
        Set<String> invalidDomainSet = new Set<String>();
        Boolean getMetadataRecords = false;
        for(Lead lead : leadList){
                if(oldLeadMap == null || (oldLeadMap != null && (lead.Email != oldLeadMap.get(lead.Id).Email || lead.Status != oldLeadMap.get(lead.Id).Status))){
                    if(lead.Email != null){
                        getMetadataRecords = true;
                        break;
                    }
                }
        }
        
        if(getMetadataRecords){
            // Load Email Domains Custom Metadata
            for (Email_Address_Domain__mdt rec : [SELECT Domain__c, Domain_Type__c FROM Email_Address_Domain__mdt WHERE Domain__c != null]) 
            {
                if(rec.Domain_Type__c == 'Invalid'){
                    invalidDomainSet.add(rec.Domain__c.trim().toLowerCase());
                }else{
                 	personalDomainSet.add(rec.Domain__c.trim().toLowerCase());   
                }
            }   
        }
		
        if((!personalDomainSet.isEmpty()) || (!invalidDomainSet.isEmpty())){
            for(Lead lead : leadList){
                if(oldLeadMap == null || (oldLeadMap != null && (lead.Email != oldLeadMap.get(lead.Id).Email || lead.Status != oldLeadMap.get(lead.Id).Status))){
                    if(lead.Email != null){
                        String domain = lead.Email.substringAfter('@').trim().toLowerCase();
                        if(personalDomainSet.contains(domain)){
                            lead.Personal_Email_Address_Domain__c = true;
                        }else if(invalidDomainSet.contains(domain)){
                            lead.Status = 'Active-Invalid Email';
                            lead.Personal_Email_Address_Domain__c = false;
                        }else{
                            lead.Personal_Email_Address_Domain__c = false;
                        }
                    }   
                }
            }   
        }
    }
    
    public static void computeEmailSubscriptionValues(List<Lead> leadList, Map<Id,Lead> oldLeadMap){
        //Email_Subscription_Values__c
        for(Lead lead : leadList){
            if(oldLeadMap == null && lead.Email_Group_Subscription__c != null){
                lead.Email_Subscription_Values__c = (lead.Email_Group_Subscription__c).replace(';', ',');
            }else{
                if(lead.Email_Group_Subscription__c != null && lead.Email_Group_Subscription__c != oldLeadMap.get(lead.Id).Email_Group_Subscription__c){
                    lead.Email_Subscription_Values__c = lead.Email_Group_Subscription__c == null ? null : (lead.Email_Group_Subscription__c).replace(';', ',');   
                }
            }
        }
    }
    
    public static void updateLastUserModifiedAt(List<Lead> leadList, Map<Id,Lead> oldLeadMap){
        for(Lead lead : leadList){
            if(oldLeadMap != null &&
            (lead.Asset_Range__c != oldLeadMap.get(lead.Id).Asset_Range__c 
            || lead.Number_of_Contact_US__c != oldLeadMap.get(lead.Id).Number_of_Contact_US__c
            || lead.Tactic_Range__c != oldLeadMap.get(lead.Id).Tactic_Range__c
            || lead.Last_Campaign_Tactic__c != oldLeadMap.get(lead.Id).Last_Campaign_Tactic__c
            || lead.Number_of_Webinar__c != oldLeadMap.get(lead.Id).Number_of_Webinar__c
            || lead.Last_Campaign_Asset__c != oldLeadMap.get(lead.Id).Last_Campaign_Asset__c
            || lead.Number_of_Events__c != oldLeadMap.get(lead.Id).Number_of_Events__c)
            && lead.Number_of_Campaigns__c == oldLeadMap.get(lead.Id).Number_of_Campaigns__c){
                // do nothing
            }else{
                lead.Last_User_Modified_At__c = System.Now();
            }
        }
    }
}