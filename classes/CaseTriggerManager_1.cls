/**************************************************************************************************************************************
CREATED BY :- RISHABH KANOTRA
CREATED DATE :- 07-06-2019
DESCRIPTION :- This class contains various validations and functionality to modify case and its fields refered from Case_Trigger triggers :before insert,after insert,before update,after update, before Delete
***************************************************************************************************************************************/ 

Global class CaseTriggerManager_1 {
    
    //Don’t allow user to delete the case record if -            
    //1. User is not system admin
    //2. User is not owner of the case
    //3. User doesn’t have permission set 'Cases: Modify All'
    public static void beforeCaseDelete(List<Case> oldCases){       
        System.debug('beforeCaseDelete START');
        Map<String,PermissionSet> MapPermissionSets=New Map<String,PermissionSet> ();
        String ProfileName=[SELECT Name FROM profile WHERE id =: Userinfo.getProfileId()].Name;
        
        
        for( PermissionSet s:[SELECT Id, Name from PermissionSet where ID
                              in ( SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =:Userinfo.getUserId())])
        {
            MapPermissionSets.put(s.name,s);
        }
        
        
        for (Case case1: oldCases)
        {
            if(!(ProfileName.contains('system admin')) && MapPermissionSets.containsKey('Modify_All') && case1.ownerId!=Userinfo.getUserid())
            {
                case1.addError('You dont have permission to delete the record.');
            }
        }
        System.debug('beforeCaseDelete END');
    }//beforeCaseDelete
    
    // 1. Validation for raising case to Measurement Capabilities team
    // 2. Case_Owner_Name__c is updated with the last name of the owner- Used in validation rules
    public static void beforeInsert_1(List<Case> newCases){
        System.debug('beforeInsert_1 START');
        id selectedRecordType;
        selectedRecordType = Schema.SObjectType.case.getRecordTypeInfosByName().get('Referral').getRecordTypeId();
        
        group gropob= [select id from group where name ='MeasurementCapabilitiesCaseReferralGroup' LIMIT 1];
        
        set<id> gpset=new set<id>();
        
        for(groupmember gm : [select id,UserOrGroupId from groupmember where groupid =:gropob.id]){
            gpset.add(gm.UserOrGroupId);
        }   
        Set<Id> caseOwnerId = new Set<Id>();
        For(Case c:newCases){
            if(trigger.isInsert)
            {
                caseOwnerId.add(c.OwnerId);
            }
            
            if(c.RecordTypeId==selectedRecordType)
            {
                if(c.Assigned_To__c=='Measurement Capabilities')
                {
                    if(!gpset.contains(Userinfo.getUserId())){
                        c.adderror('You do not have the necessary permissions to raise a case to the Measurement Capabilities team.');
                    }
                }
            }
            
            
            // CRI-00001559-end
            
        }
        
        /*Map<Id,String> OwnerName = new Map<Id,String>();
        
        for(User usr : [Select id,FirstName,LastName from User where Id IN: caseOwnerId]){
            OwnerName.put(usr.Id,usr.LastName);
        }
        if(OwnerName.size()>0){
            For(Case c:newCases){
                if(OwnerName.containsKey(c.OwnerId)){
                    c.Case_Owner_Name__c = OwnerName.get(c.OwnerId);
                }
            }
        }*/
        
        System.debug('beforeInsert_1 END');
    }//beforeInsert_1    
    
    public static void beforeInsert_3(List<Case> newCases){
        System.debug('beforeInsert_3 START');
        for(Case cse:newCases){
            if(trigger.isInsert){
                if(cse.Origin == 'Web'){
                    if(cse.Caller_Type__c=='Candidate' ) {
                        cse.Subject = cse.Candidate_Name__c + ' ' +
                            cse.Additional_details_on_your_enquiry__c;
                        for(KB_CaseCountryCodeAndAssignmentEmails__c item : KB_CaseCountryCodeAndAssignmentEmails__c.getAll().values()) {  
                            if(cse.Case_Country__c =='JPN' && cse.Submitted_From__c =='Main website')
                               {
                                if(item.ISO3__c == cse.Case_Country__c && item.Assigned_To__c != NULL 
                                       && item.Platform__c != null ) {
                                        cse.Assigned_To__c= item.Assigned_To__c;
                                        cse.Assignee_Email__c=item.Help_Desk_Email__c;
                                        cse.IsSupport__c = true;
                                        cse.Time_Spent__c = 6;
                                    }
                               }
                               else if(item.ISO3__c == cse.Case_Country__c && item.Assigned_To__c != NULL && 
                               item.Platform__c == null ) {
                                cse.Assigned_To__c= item.Assigned_To__c;
                                cse.Assignee_Email__c=item.Help_Desk_Email__c;
                                cse.IsSupport__c = true;
                                cse.Time_Spent__c = 6;
                            }
                        }
                    } else if(cse.Caller_Type__c=='Customer') {
                        cse.Subject = cse.Admin_Contact__c + ' ' +cse.Additional_details_on_your_enquiry__c;
                        if(cse.Please_select_the_type_of_enquiry__c == 'Product, billing or ordering query' ) {
                            for(KBCaseCustomerExperience__mdt item : KBCaseCustomerExperience__mdt.getAll().values()){  
                                if(item.ISO3__c == cse.Case_Country__c){    
                                    cse.Assigned_To__c= item.Assigned_To__c;    
                                    cse.IsSupport__c = true;    
                                    cse.Time_Spent__c = 6;  
                                }   
                            }   
                
                            /*for(KB_CaseCustomerExperience__c item : KB_CaseCustomerExperience__c.getAll().values()) { 
                                if(item.ISO3__c == cse.Case_Country__c){    
                                    cse.Assigned_To__c= item.Assigned_To__c;    
                                    cse.Assignee_Email__c=item.Help_Desk_Email__c;  
                                    cse.IsSupport__c = true;    
                                    cse.Time_Spent__c = 6;  
                                }   
                            }*/
                        } else {
                            for(KB_CaseCountryCodeAndAssignmentEmails__c item : KB_CaseCountryCodeAndAssignmentEmails__c.getAll().values()) {
                                if(cse.Case_Country__c == 'IND'){
                                    if(item.ISO3__c == cse.Case_Country__c && item.Assigned_To__c != NULL 
                                       && item.Platform__c != null ) {
                                        cse.Assigned_To__c= item.Assigned_To__c;
                                        cse.Assignee_Email__c=item.Help_Desk_Email__c;
                                        cse.IsSupport__c = true;
                                        cse.Time_Spent__c = 6;
                                    }
                                } else {
                                    if(item.ISO3__c == cse.Case_Country__c && item.Assigned_To__c != NULL 
                                       && item.Platform__c == null) {
                                        cse.Assigned_To__c= item.Assigned_To__c;
                                        cse.Assignee_Email__c=item.Help_Desk_Email__c;
                                        cse.IsSupport__c = true;
                                        cse.Time_Spent__c = 6;
                                    }
                                }

                            }
                        }
                    }
                    
                    
                    
                    
                   /* if(cse.Please_select_the_type_of_enquiry__c == 'Product, billing or ordering query' ){
                        for(KB_CaseCustomerSuccess__c item : KB_CaseCustomerSuccess__c.getAll().values()){
                            if(cse.What_platform_are_you_using__c == 'iAssess/AMCAT'){
                                if(item.Platform__c == cse.What_platform_are_you_using__c){
                                    cse.Assigned_To__c= item.Assigned_To__c;
                                    cse.Assignee_Email__c=item.Help_Desk_Email__c;
                                    cse.IsSupport__c = true;
                                    cse.Time_Spent__c = 6;
                                }
                            }
                            else if(cse.What_platform_are_you_using__c != 'iAssess/AMCAT' && cse.What_platform_are_you_using__c != null){
                                if(item.ISO3__c == cse.Case_Country__c){
                                    cse.Assigned_To__c= item.Assigned_To__c;
                                    cse.Assignee_Email__c=item.Help_Desk_Email__c;
                                    cse.IsSupport__c = true;
                                    cse.Time_Spent__c = 6;
                                }
                            }
                        }
                    } else{
                        for(KB_CaseCountryCodeAndAssignmentEmails__c item : KB_CaseCountryCodeAndAssignmentEmails__c.getAll().values()){    
                            if(cse.What_platform_are_you_using__c == 'iAssess/AMCAT'){
                                if(item.Assigned_To__c != NULL && item.Platform__c == cse.What_platform_are_you_using__c){
                                    cse.Assigned_To__c= item.Assigned_To__c;
                                    cse.Assignee_Email__c=item.Help_Desk_Email__c;
                                    cse.IsSupport__c = true;
                                    cse.Time_Spent__c = 6;
                                }
                            }
                            else if(cse.What_platform_are_you_using__c != 'iAssess/AMCAT' && cse.What_platform_are_you_using__c != null ){
                                if(item.ISO3__c == cse.Case_Country__c && item.Assigned_To__c != NULL){
                                    cse.Assigned_To__c= item.Assigned_To__c;
                                    cse.Assignee_Email__c=item.Help_Desk_Email__c;
                                    cse.IsSupport__c = true;
                                    cse.Time_Spent__c = 6;
                                }
                            }
                            
                        }            
                    }*/
                }
                /*
                if(cse.Caller_Type__c=='Candidate' && cse.Origin=='Web'){
                    cse.Subject = cse.Candidate_Name__c + ' ' +cse.Additional_details_on_your_enquiry__c;
                }
                else if(cse.Caller_Type__c=='Customer' && cse.Origin=='Web'){
                    cse.Subject = cse.Admin_Contact__c + ' ' +cse.Additional_details_on_your_enquiry__c;
                }*/
            }
            
            System.debug('Case Assigned TO -> ' +  cse.Assigned_To__c);
        }
        System.debug('beforeInsert_3 END');
    }
    
    // 1. Update closed By to user id
    // 2. Validation for raising case to Measurement Capabilities team
    // 3. Case_Owner_Name__c is updated with the last name of the owner- Used in validation rules
    public static void beforeUpdate_1(List<Case> newCases, Map<id,Case> oldmap){
        System.debug('beforeUpdate_1 START');
        id selectedRecordType;
        selectedRecordType = Schema.SObjectType.case.getRecordTypeInfosByName().get('Referral').getRecordTypeId();
        
        group gropob= [select id from group where name ='MeasurementCapabilitiesCaseReferralGroup' LIMIT 1];
        
        set<id> gpset=new set<id>();
        
        for(groupmember gm : [select id,UserOrGroupId from groupmember where groupid =:gropob.id]){
            gpset.add(gm.UserOrGroupId);
        }   
        Set<Id> caseOwnerId = new Set<Id>();
        For(Case c:newCases){
            
            if(trigger.isUpdate)
            {
                if(c.status=='Resolved/Closed' || c.status=='Resolved/Closed and Escalated')
                {
                    c.Closed_By__c=UserInfo.getUserId();
                }
                if(c.OwnerId != oldmap.get(c.Id).OwnerId)
                {
                    caseOwnerId.add(c.OwnerId);
                }
                
            }
            
            if(c.RecordTypeId==selectedRecordType)
            {
                if(c.Assigned_To__c=='Measurement Capabilities')
                {
                    if(!gpset.contains(Userinfo.getUserId())){
                        c.adderror('You do not have the necessary permissions to raise a case to the Measurement Capabilities team.');
                    }
                }
            }
            
            
            // CRI-00001559-end
            
        }
        
        /*Map<Id,String> OwnerName = new Map<Id,String>();
        
        for(User usr : [Select id,FirstName,LastName from User where Id IN: caseOwnerId]){
            OwnerName.put(usr.Id,usr.LastName);
        }
        if(OwnerName.size()>0){
            For(Case c:newCases){
                if(OwnerName.containsKey(c.OwnerId)){
                    c.Case_Owner_Name__c = OwnerName.get(c.OwnerId);
                }
            }
        }*/
        System.debug('beforeUpdate_1 END');
    }//beforeUpdate_1
    
    //1.Case record type is 'Central PS' then update following fields on case - a.Account, b.Contact, c.Requestor_Country__c
    //2.If Project not null -- Update 'Scoped_Hours_Effort__c'
    public static void beforeInsert_2(List<Case> newCases){
        System.debug('beforeInsert_2 START');
        Set<String> oppIds = new Set<String>();
        Set<String> accIds = new Set<String>();
        set <id> projectids = new set<id>();
        list <ProjectObject__c> projectsinsert = new list<ProjectObject__c>();
        list <ProjectObject__c> projectstoupdate = new list<ProjectObject__c>();
        set <id > setprojectodsinsert = new set <id>();
        set <id> projectidsremoved = new set <id>();
        list <ProjectObject__c> projectsremoved = new list<ProjectObject__c>();
        
        map<id , decimal> projectidDeliveryeffort = new map <id , decimal> ();
        map<id , string >projectidRecordType = new map <id , string>();
        
        String rtId;
        string projectrecordid;
        List<Case> autoPopulateList = new List<Case>(); 
        Map<String,String>OpportunityWithAccount = new Map<String,String>();
        Map<String,String>OppWithPrimaryContact = new Map<String,String>();
        Map<String,String>AccountWithBU = new Map<String,String>();
        
        for(case c : newCases){
            oppIds.add(c.Opportunity__c);
        }        
        
        System.debug('the opps ids'+oppIds);       
        
        for(Opportunity o :[select id,AccountId,Primary_Contact__r.id from opportunity where   id IN :oppIds]){
            OpportunityWithAccount.put(o.id,o.AccountId);
            OppWithPrimaryContact.put(o.id,o.Primary_Contact__r.id);
            accIds.add(o.AccountId);
        }        
        
        System.debug('the accids are'+accIds);
        System.debug('The values of opportunity with a'+OpportunityWithAccount.values());
        
        for(Account a : [select id,BU__c from Account where BU__c!=null AND id IN:accIds]){
            AccountWithBU.put(a.id,a.BU__c);
        }
        
        if(Trigger.isBefore){
            //record type describe call by saloni chhabra on 8/5/2015 to remove soql error on order activation SSE-1362 
            rtId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Central PS').getRecordTypeId();
            projectrecordid = Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
            
            for(case c : newCases){
                if(c.RecordTypeId==rtId){
                    
                    if(c.Opportunity__c!=null || c.Opportunity__c!=''){
                        if(OpportunityWithAccount.get(c.Opportunity__c)!=null){ 
                            c.AccountId=OpportunityWithAccount.get(c.Opportunity__c);
                        }else{
                            System.debug('not found account id');
                        }
                        if(OppWithPrimaryContact.get(c.Opportunity__c)!=null){    
                            c.ContactId= OppWithPrimaryContact.get(c.Opportunity__c);
                        }else{
                            System.debug('not found contact id');
                        }
                        if(AccountWithBU.get(OpportunityWithAccount.get(c.Opportunity__c))!=null){
                            c.Requestor_Country__c=AccountWithBU.get(OpportunityWithAccount.get(c.Opportunity__c));
                        }
                        else{
                            System.debug('not found requestor country');
                        }
                    }    
                    
                    autoPopulateList.add(c);
                    
                    if ((trigger.isinsert && (c.Project__c ) != null)) 
                    {                   
                        
                        setprojectodsinsert.add(c.Project__c );               
                        projectidDeliveryeffort.put(c.Project__c , c.Delivery_Effort_Total__c);
                        
                    }
                    
                }
                
                
            }
            if (setprojectodsinsert.size()>0)
            {
                projectsinsert = [select id ,recordtypeid , recordtype.name  from ProjectObject__c where id in :setprojectodsinsert] ;  
                if ((projectsinsert.size())> 0)
                {
                    for (ProjectObject__c p :projectsinsert )
                    {    projectids.add(p.id);
                     if (p.recordtypeid == projectrecordid)
                     {
                         p.Scoped_Hours_Effort__c = projectidDeliveryeffort.get(p.id);
                         projectstoupdate.add(p);
                     }
                     projectidRecordType.put(p.id , p.recordtype.name);
                    }
                    
                    
                }
            }
            
            if (projectidsremoved.size() > 0)
            {
                projectsremoved = [select id  from ProjectObject__c where id in :projectidsremoved];    
                for (ProjectObject__c p : projectsremoved)
                {
                    p.Scoped_Hours_Effort__c = 0.00;
                    projectstoupdate.add(p);
                }
                
            }
            
            // SSE 762 //
            update projectstoupdate;
            
            for (case c :newCases ){
                
                if (projectids.contains( c.project__c))
                    c.Project_Type__c = projectidRecordType.get(c.project__c);
                
                
            }
        }
         System.debug('beforeInsert_2 END');
    }//beforeInsert_2
    
    //1.Case record type is 'Central PS' then update following fields on case - a.Account, b.Contact, c.Requestor_Country__c
    //2.If Project not null -- Update 'Scoped_Hours_Effort__c' && if Project old type is 'CPS Project then Scoped_Hours_Effort__c = 0.00
    public static void beforeUpdate_2(List<Case> newCases, Map<id,Case> oldmap){
         System.debug('beforeUpdate_2 START');
        Set<String> oppIds = new Set<String>();
        Set<String> accIds = new Set<String>();
        set <id> projectids = new set<id>();
        list <ProjectObject__c> projectsinsert = new list<ProjectObject__c>();
        list <ProjectObject__c> projectstoupdate = new list<ProjectObject__c>();
        set <id > setprojectodsinsert = new set <id>();
        set <id> projectidsremoved = new set <id>();
        list <ProjectObject__c> projectsremoved = new list<ProjectObject__c>();
        
        map<id , decimal> projectidDeliveryeffort = new map <id , decimal> ();
        map<id , string >projectidRecordType = new map <id , string>();
        
        String rtId;
        string projectrecordid;
        List<Case> autoPopulateList = new List<Case>(); 
        Map<String,String>OpportunityWithAccount = new Map<String,String>();
        Map<String,String>OppWithPrimaryContact = new Map<String,String>();
        Map<String,String>AccountWithBU = new Map<String,String>();
        
        for(case c : newCases){
            oppIds.add(c.Opportunity__c);
        }        
        
        System.debug('the opps ids'+oppIds);       
        
        for(Opportunity o :[select id,AccountId,Primary_Contact__r.id from opportunity where   id IN :oppIds]){
            OpportunityWithAccount.put(o.id,o.AccountId);
            OppWithPrimaryContact.put(o.id,o.Primary_Contact__r.id);
            accIds.add(o.AccountId);
        }        
        
        System.debug('the accids are'+accIds);
        System.debug('The values of opportunity with a'+OpportunityWithAccount.values());
        
        for(Account a : [select id,BU__c from Account where BU__c!=null AND id IN:accIds]){
            AccountWithBU.put(a.id,a.BU__c);
        }
        
        if(Trigger.isBefore){
            //record type describe call by saloni chhabra on 8/5/2015 to remove soql error on order activation SSE-1362 
            rtId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Central PS').getRecordTypeId();
            projectrecordid = Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
            
            for(case c : newCases){
                if(c.RecordTypeId==rtId){
                    
                    if(c.Opportunity__c!=null || c.Opportunity__c!=''){
                        if(OpportunityWithAccount.get(c.Opportunity__c)!=null){ 
                            c.AccountId=OpportunityWithAccount.get(c.Opportunity__c);
                        }else{
                            System.debug('not found account id');
                        }
                        if(OppWithPrimaryContact.get(c.Opportunity__c)!=null){    
                            c.ContactId= OppWithPrimaryContact.get(c.Opportunity__c);
                        }else{
                            System.debug('not found contact id');
                        }
                        if(AccountWithBU.get(OpportunityWithAccount.get(c.Opportunity__c))!=null){
                            c.Requestor_Country__c=AccountWithBU.get(OpportunityWithAccount.get(c.Opportunity__c));
                        }
                        else{
                            System.debug('not found requestor country');
                        }
                    }    
                    
                    autoPopulateList.add(c);
                    
                    
                    if (trigger.isupdate)
                    {
                        if(oldmap.get(c.id).project__c != c.project__c )
                        {
                            if(c.project__c!= null )
                            {
                                setprojectodsinsert.add(c.project__c);
                                projectidDeliveryeffort.put(c.project__c  , c.Delivery_Effort_Total__c);                
                            }
                            if(oldmap.get(c.id).project__c != null && oldmap.get(c.id).Project_Type__c == 'CPS Project')
                                projectidsremoved.add(oldmap.get(c.id).project__c);
                            if(c.project__c== null )
                                c.Project_Type__c = '';
                        }
                        
                    }
                }
                
                
            }
            if (setprojectodsinsert.size()>0)
            {
                projectsinsert = [select id ,recordtypeid , recordtype.name  from ProjectObject__c where id in :setprojectodsinsert] ;  
                if ((projectsinsert.size())> 0)
                {
                    for (ProjectObject__c p :projectsinsert )
                    {    projectids.add(p.id);
                     if (p.recordtypeid == projectrecordid)
                     {
                         p.Scoped_Hours_Effort__c = projectidDeliveryeffort.get(p.id);
                         projectstoupdate.add(p);
                     }
                     projectidRecordType.put(p.id , p.recordtype.name);
                    }
                    
                    
                }
            }
            
            if (projectidsremoved.size() > 0)
            {
                projectsremoved = [select id  from ProjectObject__c where id in :projectidsremoved];    
                for (ProjectObject__c p : projectsremoved)
                {
                    p.Scoped_Hours_Effort__c = 0.00;
                    projectstoupdate.add(p);
                }
                
            }
            
            // SSE 762 //
            update projectstoupdate;
            
            for (case c :newCases ){
                
                if (projectids.contains( c.project__c))
                    c.Project_Type__c = projectidRecordType.get(c.project__c);
                
                
            }
        }    
        
        System.debug('beforeUpdate_2 END');
    }//beforeUpdate_2
    
    //1.Logic to update 'Assignee_Email__c' field using 'Assignee_Email_Case_With_BU__c' custom setting.
    //2.Logic to update 'Total_case_time_spent__c' of the job related to that case.
    public static void afterInsert_1(List<Case> newCases){
        System.debug('afterInsert_1 START');
        Set<Id> newCasesIds = new Set<Id>();
        set<ID> jobIdSet = new set<ID>();
        for(Case newCase : newCases){
            
            jobIdSet.add(newCase.Bureau_Job__c);
            // in case of insert when new web case is created it assignee email is already set in web2case form so no need to re assign the email field
            if(newCase.Origin !='Web'){
                newCasesIds.add(newCase.Id);
            }
        }
        
        afterFollowMethod(newCases,newCasesIds,jobIdSet);
        System.debug('afterInsert_1 END');
    }//afterInsert_1
    
    //1.Logic to update 'Assignee_Email__c' field using 'Assignee_Email_Case_With_BU__c' custom setting.
    //2.Logic to update 'Total_case_time_spent__c' of the job related to that case.         
    public static void afterUpdate_1(List<Case> newCases, Map<id,Case> oldmap){
        System.debug('afterUpdate_1 START');
        Set<Id> newCasesIds = new Set<Id>();
        set<ID> jobIdSet = new set<ID>();
        for(Case newCase : newCases){
            if(trigger.isUpdate)
            {
                system.debug('New contact:'+newCase.ContactId);
                system.debug('oldContact:'+oldmap.get(newCase.Id).ContactId);
                if((newCase.Assigned_To__c != oldmap.get(newCase.Id).Assigned_To__c)||(newCase.ContactId != oldmap.get(newCase.Id).ContactId)|| ((newCase.Case_Type__c != oldmap.get(newCase.Id).Case_Type__c) && newCase.origin!='Web' ))
                {
                    newCasesIds.add(newCase.Id);
                    system.debug('New contact:'+newCase.Contact);
                    system.debug('oldContact:'+oldmap.get(newCase.Id).Contact);
                }
                if(newCase.Time_Spent__c !=oldmap.get(newCase.Id).Time_Spent__c)
                    jobIdSet.add(newCase.Bureau_Job__c);
                /*Added below if block to amend 'Time Spent: Case (In Minutes)' field on Job record 
                  when job is link/ delink from Case (SSE-22943) by Aashi*/
                if(newCase.Bureau_Job__c != oldmap.get(newCase.Id).Bureau_Job__c){
                    jobIdSet.add(oldmap.get(newCase.Id).Bureau_Job__c);
                    jobIdSet.add(newCase.Bureau_Job__c);
                }
            }
        }
        afterFollowMethod(newCases,newCasesIds,jobIdSet);
        System.debug('afterUpdate_1 END');
    }//afterUpdate_1
    
    /****************************************************************************************************************************
*             This Method is changed by Prachi Gupta(prachi.gupta@shl.com) under Story SSE-14413                            *   
*                                                                        *                      
*             Change Date: 23-05-2022                                                                                      *
*****************************************************************************************************************************/
    public static void afterFollowMethod(List<Case> newCasesPassed, Set<Id> newCasesIds, set<ID> jobIdSet){
        System.debug('afterFollowMethod START');
        if(newCasesIds.size()>0){
            //List<case> NewCases=newCasesPassed;
            List<case> ListCase=new list<case>();
            List<Assigned_To_Assigned_Email_Mapping__mdt> caeList = Assigned_To_Assigned_Email_Mapping__mdt.getAll().values();
            
            Id recordId = [SELECT Id, SobjectType, DeveloperName , name FROM RecordType where SobjectType = 'Case' and name = 'Referral'].Id; 
            for ( Case c: [select id, Assigned_To__c, Case_Country__c,Origin,RecordTypeId, Account.BU__c ,Case_Type__c , Assignee_Email__c,contact.BU__C from case where id IN: newCasesIds ]){
                if(c.RecordTypeId == recordId){ 
                    List<Assigned_To_Assigned_Email_Mapping__mdt> caeValues = new List<Assigned_To_Assigned_Email_Mapping__mdt>();
                    for(Assigned_To_Assigned_Email_Mapping__mdt cae: caeList){
                        system.debug('Inside 515'+ c.Assigned_To__c);
                        if(c.Assigned_To__c == cae.Assigned_To__c ){ 
                            caeValues.add(cae);
                        }}
                    
                    if(caeValues.size() == 1){
                        system.debug('Inside 535'+ caeValues.get(0).Assignee_Email__c);
                        c.Assignee_Email__c = caeValues.get(0).Assignee_Email__c;
                        ListCase.add(c);
                    }
                    else if(caeValues.size() > 1){
                        List<Assigned_To_Assigned_Email_Mapping__mdt> aemList = new List<Assigned_To_Assigned_Email_Mapping__mdt>();
                        for(Assigned_To_Assigned_Email_Mapping__mdt cae2: caeValues){
                            if(cae2.Case_Type_c__c == c.Case_Type__c && cae2.Check_On_BU_c__c == True && c.contact.BU__c == cae2.BU__c){
                                c.Assignee_Email__c = cae2.Assignee_Email__c; 
                                ListCase.add(c);
                            }
                        }
                        If(ListCase.size()>=0 && ListCase.contains(c) == False){
                            for(Assigned_To_Assigned_Email_Mapping__mdt cae4: caeValues){
                                if(cae4.Case_Type_c__c == c.Case_Type__c && c.contact.BU__c != cae4.BU__c){
                                    c.Assignee_Email__c = cae4.Assignee_Email__c; 
                                    ListCase.add(c);
                                }
                            } 
                        }                     
                        
                        If(ListCase.size()>=0 && ListCase.contains(c) == False){
                            for(Assigned_To_Assigned_Email_Mapping__mdt cae3: caeValues){
                                if(cae3.Check_On_BU_c__c == True && c.contact.BU__c == cae3.BU__c && cae3.Case_Type_c__c != c.Case_Type__c){
                                    c.Assignee_Email__c = cae3.Assignee_Email__c; 
                                    ListCase.add(c);
                                }
                            } 
                        }
                        /*if(cae2.Case_Type_c__c == 'ALL'){
if(cae2.Check_On_BU_c__c == True && c.contact.BU__c == cae2.BU__c){
c.Assignee_Email__c = cae2.Assignee_Email__c; 
ListCase.add(c);
}
}
else if(cae2.Case_Type_c__c == c.Case_Type__c){
if(cae2.Check_On_BU_c__c == False){
c.Assignee_Email__c = cae2.Assignee_Email__c; 
ListCase.add(c);
}
else if(cae2.Check_On_BU_c__c == True && c.contact.BU__c == cae2.BU__c){
c.Assignee_Email__c = cae2.Assignee_Email__c; 
ListCase.add(c);
}
}*/
                        
                        
                    }
                    
                    
                    
                    else{
                        c.Assignee_Email__c = '';
                        ListCase.add(c);
                        
                        
                    }
                }}
            if(Listcase.size()>0 && CaseAssigneeEmailFlagSetter.FirstRun){
                CaseAssigneeEmailFlagSetter.FirstRun=False;
                try {
                    update ListCase;
                }catch(DmlException e) {
                    //System.debug('The following exception has occurred: ' + e.getMessage());
                    for ( Case c:newCasesPassed)
                        c.addError('The following exception has occurred: ' + e.getDmlMessage(0));
                }
                
            }
        }
        
        List<Job__c> jobsList = new List<Job__c>();
        for(Job__c job : [select id  ,Time_Spent_Case__c,(select id , Time_Spent__c from Cases__r) from Job__c where id IN :jobIdSet])
        {
            job.Time_Spent_Case__c = 0;
            for(case cse : job.Cases__r) 
            {
                if(cse.Time_Spent__c!= null)
                    job.Time_Spent_Case__c += cse.Time_Spent__c;
            }
            jobsList.add(job);
        }
        if(jobsList.size()>0)
            update jobsList;
        
         System.debug('afterFollowMethod END');
    }//afterFollowMethod
    
    public static void updateSystemID(List<Case> newCases, Map<Id, Case> oldMap){
    System.debug('updateSystemID START');
        Set<Id> systemSetIds = new Set<Id>();
        for(Case cseObj:newCases){
            if(cseObj.System_Ref__c != null || (cseObj.System_Ref__c != null && cseObj.System_Ref__c != oldMap.get(cseObj.Id).System_Ref__c)){
                systemSetIds.add(cseObj.System_Ref__c);
            }
        }
        
        Map<Id, System__c> mapSystem = new Map<Id, System__c>([SELECT Id, System_Client_ID__c  FROM System__c WHERE ID IN:systemSetIds]);
       
        for(Case cseObj:newCases){
            if(cseObj.System_Ref__c != null && mapSystem.containsKey(cseObj.System_Ref__c) && mapSystem.get(cseObj.System_Ref__c).System_Client_ID__c != null){
                cseObj.System_Id__c  = mapSystem.get(cseObj.System_Ref__c).System_Client_ID__c;    
            }
        }
        System.debug('updateSystemID END');
    }
    
    public static void updateNumberOfChangesOnJob(List<Case> CaseList){
         Set<Id> jobIdSet = new Set<Id>();
         List<Job__c> jobsToUpdate = new List<Job__c>();
         String filter='Managed Services Project';
         String solutionName='Change Request';
        
        for(Case caseRec : CaseList) {
            jobIdSet.add(caseRec.Bureau_Job__c);
        }
        
        for(Job__c jobRec : [SELECT Id, Number_of_Changes__c,(Select id from Cases__r where Problem2__c =: filter and 
                            Solution__c =: solutionName) FROM Job__c WHERE  Id IN :jobIdSet]){
             Integer caseCount = 0;
           //jobRec.Number_of_Changes__c = jobRec.cases__r.size(); // Changes By Priyank Anand for SD-120651
                                for(Case caseRecord:jobRec.cases__r){
                                    caseCount = caseCount+1;
                                }
              jobRec.Number_of_Changes__c =  caseCount;   
           jobsToUpdate.add(jobRec);                      
        }
        if(jobsToUpdate.size() >0){
            update jobsToUpdate;
        }
        
    }
    public static void clearJobValue(List<Case> caseList , Map<Id,Case> oldCaseMap){
        system.debug('inside class');
        Id selectedRecordType = Schema.SObjectType.case.getRecordTypeInfosByName().get('Information only – Front Office').getRecordTypeId();
        system.debug('selectedRecordType' + selectedRecordType);
        if(!caseList.isEmpty()){
            for (Case cases : caseList){
               system.debug('inside for' + cases.isClone());  
           if(cases.isClone() && cases.RecordTypeId == selectedRecordType && 
             (cases.Assigned_To__c.contains('Technical Support') || cases.Assigned_To__c.contains('TAM')) ){
               if( cases.Bureau_Job__c != null ||  cases.Bureau_Job__c != ''){
                    cases.Bureau_Job__c = null; 
                    cases.AutomationBypassDateTime__c = system.now();  
                   
               }
                    
    }
        }
    }
       
    }
    //Added by Aashi for linking Attachment to Case
    /*
    public static void linkAttachmentToCase(List<Case> caseList){
        list<ContentVersion> contentVersions = new list<ContentVersion>();
        
        for(Case caseRecord : caseList){
            System.debug('caseRecord.Attachment_Name__c '+caseRecord.Attachment_Name__c);
            if(caseRecord.Attachment_Body__c != null){
                String base64Content = caseRecord.Attachment_Body__c.substringAfter('base64,');
                try {
                    String base64Data = caseRecord.Attachment_Body__c.substringAfter('base64,');
                    ContentVersion cv = new ContentVersion(
                        Title = caseRecord.Attachment_Name__c,
                        PathOnClient = caseRecord.Attachment_Name__c,
                        VersionData = EncodingUtil.base64Decode(base64Data)
                    );
                    contentVersions.add(cv);
                } catch (Exception e) {
                    System.debug('Error processing attachment: ' + e.getMessage());
                }
            }
        }
        if(!contentVersions.isEmpty()){
            insert contentVersions;
            
            List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>();
            for (ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersions]) {
                //Case parentCase = 
                contentLinks.add(new ContentDocumentLink(
                    ContentDocumentId = cv.ContentDocumentId,
                    LinkedEntityId = caseList[0].Id,
                    ShareType = 'V' // Viewer access
                ));
            }
            
            insert contentLinks;
        }
    }*/
    // Added by Prabhat for linking Attachment from Unymira-ContactUs form on to Cases
    public static void LinkWebFormAttachmentToCase(List<Case> caseList) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        Map<Id, ContentVersion> caseToFileMap = new Map<Id, ContentVersion>();
        
        //Build ContentVersions for all Cases
        for (Case caseRecord : caseList) {
            if (String.isNotBlank(caseRecord.Attachment_Body__c) && String.isNotBlank(caseRecord.Attachment_Name__c)) {
                try {
                    String base64Data = caseRecord.Attachment_Body__c.substringAfter('base64,');
                    ContentVersion cv = new ContentVersion(
                        Title        = caseRecord.Attachment_Name__c,
                        PathOnClient = caseRecord.Attachment_Name__c,
                        VersionData  = EncodingUtil.base64Decode(base64Data)
                    );
                    contentVersions.add(cv);
                    
                    // To Keep relationship: CaseId → ContentVersion
                    caseToFileMap.put(caseRecord.Id, cv);
                } catch (Exception e) {
                    System.debug('Error processing attachment for Case ' + caseRecord.Id + ': ' + e.getMessage());
                }
            }
        }
        
        //Insert all ContentVersions in bulk
        if (!contentVersions.isEmpty()) {
            insert contentVersions;
            
            // Requery to get ContentDocumentId
            List<ContentVersion> insertedVersions = [
                SELECT Id, ContentDocumentId, Title
                FROM ContentVersion
                WHERE Id IN :contentVersions
            ];
            
            // Build a map of Title → ContentVersion (or use another unique identifier)
            Map<String, ContentVersion> titleToVersionMap = new Map<String, ContentVersion>();
            for (ContentVersion cv : insertedVersions) {
                titleToVersionMap.put(cv.Title, cv);
            }
            
            //Build ContentDocumentLinks correctly
            List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>();
            for (Id caseId : caseToFileMap.keySet()) {
                ContentVersion originalCv = caseToFileMap.get(caseId);
                ContentVersion insertedCv = titleToVersionMap.get(originalCv.Title);
                
                if (insertedCv != null) {
                    contentLinks.add(new ContentDocumentLink(
                        ContentDocumentId = insertedCv.ContentDocumentId,
                        LinkedEntityId    = caseId,
                        ShareType         = 'V'
                    ));
                }
            }
            insert contentLinks;
        }
    }
    
}