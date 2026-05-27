/*****************************************************************************
CREATED BY :- Prabhat Arora
CREATED DATE :- 22-07-2019
DESCRIPTION :- This class contains various Methods/Checks/Assignments to controll Project Functionality as per SHL business process,
               this class is being refered from Project_Trigger, covering all the Before/After, Insert & Update Events on Project Records. 
******************************************************************************/

global class ProjectTriggerManager{
    
    /*Public static void GetOrderNumAndOrderLine(List<ProjectObject__c> NewProjectList){
        Set<Id> oppIdsSet = new Set<Id>();
        for(Integer i=0; i< NewProjectList.size();i++){
            if(NewProjectList[i].Opportunity__c!=null)
                oppIdsSet.add(NewProjectList[i].Opportunity__c);
        }
        Map<Id,Opportunity> oppWithOrdersMap;
            if(oppIdsSet.size()>0)
                oppWithOrdersMap = new Map<Id,Opportunity>([Select id,Order__c from Opportunity where id in :oppIdsSet]);
        for(Integer i=0; i< NewProjectList.size();i++){
            NewProjectList[i].Schedule_Defined__c = false;
            if(NewProjectList[i].Opportunity__c!=null && oppWithOrdersMap!=null && oppWithOrdersMap.get(NewProjectList[i].Opportunity__c).Order__c!=null)
                {       
                    NewProjectList[i].Order_Header_Number__c = oppWithOrdersMap.get(NewProjectList[i].Opportunity__c).Order__c;
                    NewProjectList[i].Order_Line_Number__c = null;
                }   
        }
    }*/    
    Public static void PopulateAndUpdateScopedDays(List<ProjectObject__c> NewProjectList){
        system.debug('function call');
        Id selectedRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
        for(Integer i=0; i< NewProjectList.size();i++){
            if(NewProjectList[i].Scoped_Hours_Effort__c  != null && NewProjectList[i].Current_Scoped_Days_Effort__c == null && NewProjectList[i].RecordTypeId == selectedRecordTypeId)
            {
                NewProjectList[i].Current_Scoped_Days_Effort__c = NewProjectList[i].Scoped_Hours_Effort__c;
            }
            If(NewProjectList[i].Additional_Scoped_Days__c  !=  null)
            {
                NewProjectList[i].Current_Scoped_Days_Effort__c = NewProjectList[i].Current_Scoped_Days_Effort__c  + NewProjectList[i].Additional_Scoped_Days__c;
            }
        }
    }
    
    Public static void CreateAdditionalScopedDaysRec(List<ProjectObject__c> NewProjectList){
        List<Additional_Scoped_days__c> AdditionalList =  new List<Additional_Scoped_days__c>();
        for(Integer i=0; i< NewProjectList.size();i++){
            If(NewProjectList[i].Additional_Scoped_Days__c  !=  null)
            {
                system.debug('NewProjectList[i].Additional_Scoped_Days__c'+NewProjectList[i].Additional_Scoped_Days__c);
                Additional_Scoped_days__c AddObj = new Additional_Scoped_days__c();
                AddObj.Additional_Scoped_Days__c = NewProjectList[i].Additional_Scoped_Days__c;
                AddObj.Chargeable__c = NewProjectList[i].Chargeable__c;
                AddObj.Comments__c = NewProjectList[i].additional_scoped_comments__c;
                AddObj.Reason__c = NewProjectList[i].Reason__c;
                AddObj.CPS_Project__c  = NewProjectList[i].id;
                AdditionalList.add(AddObj);
            }
        }
            if(AdditionalList.size()>0){
                insert AdditionalList;
            }   
    }
    
   /* Public static void UpdateOrderHeaderAndLine(List<ProjectObject__c> NewProjectList,List<ProjectObject__c> OldProjectList){
        Set<Id> oppIdsSet = new Set<Id>();
        for(Integer i=0; i< NewProjectList.size();i++){
            if((NewProjectList[i].Opportunity__c!=null && NewProjectList[i].Opportunity__c!= OldProjectList[i].Opportunity__c) || (NewProjectList[i].Opportunity__c!=null) && NewProjectList[i].Order_Line_Number__c == null)
            oppIdsSet.add(NewProjectList[i].Opportunity__c);            
        }
        Map<Id,Opportunity> oppWithOrdersMap;
            if(oppIdsSet.size()>0)
            oppWithOrdersMap = new Map<Id,Opportunity>([Select id,Order__c from Opportunity where id in :oppIdsSet]);
        for(Integer i=0; i< NewProjectList.size();i++){
            if(oppWithOrdersMap != null){
                if(oppWithOrdersMap.containsKey(NewProjectList[i].Opportunity__c)){
                    if(NewProjectList[i].Opportunity__c!=null && oppWithOrdersMap!=null && NewProjectList[i].Opportunity__c != OldProjectList[i].Opportunity__c){     
                    if(oppWithOrdersMap.get(NewProjectList[i].Opportunity__c)!=null && oppWithOrdersMap.get(NewProjectList[i].Opportunity__c).Order__c!=null)
                        NewProjectList[i].Order_Header_Number__c = oppWithOrdersMap.get(NewProjectList[i].Opportunity__c).Order__c;
                    else
                        NewProjectList[i].Order_Header_Number__c = null;
                        NewProjectList[i].Order_Line_Number__c = null;
                    }            
                }
            }           
        }
    }*/
    Public static Integer RunCount=1; //Added by Priyank for SD-57078
    Public static void ValidateAndShowErrors(List<ProjectObject__c> NewProjectList,List<ProjectObject__c> OldProjectList,Map<Id,ProjectObject__c> ProjectOldMap){
        system.debug(UserInfo.getUserId());
        if(RunCount==1 && UserInfo.getUserId()!='0054G00000CSIBqQAP'){ //Added by Priyank for SD-57078
        id selectedRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
        set<Id> groupMemebersIds= new set<Id>();
        Set<Id> groupIds = new Set<Id>();
        set<ID> opsset= new set<ID>();
        group gropob= [select id from group where name ='Ops' LIMIT 1];
        for(groupmember gm : [select id,UserOrGroupId from groupmember where groupid =:gropob.id]){
            opsset.add(gm.UserOrGroupId);
        }
       /* if(NewProjectList[0].RecordTypeId ==  selectedRecordTypeId){
            for(Group gp :[select id from Group where DeveloperName IN ('Central_PS_PM_Other','Central_PS_MIT','Central_PS_CS','Central_PS_Associates','Central_PS_A_O','Central_PS_Tech','Central_PS_QA')]){
            groupIds.add(gp.Id);
            }    
            for(GroupMember  gm : [select id,UserOrGroupId from groupmember where groupid IN: groupIds]){
            groupMemebersIds.add(gm.UserOrGroupId);
            } 
        }*/
        for(Integer i=0; i< NewProjectList.size();i++){
            if((OldProjectList[i].Delivered__c !=null && NewProjectList[i].Delivered__c!=ProjectOldMap.get(NewProjectList[i].id).Delivered__c) && NewProjectList[i].CPS_Project_Manager_New__c!= Userinfo.getUserId()|| (OldProjectList[i].Closed_Project__c !=null && NewProjectList[i].Closed_Project__c!=ProjectOldMap.get(NewProjectList[i].id).Closed_Project__c)){
                //if(!opsset.contains(Userinfo.getUserId())){//Commented to turn off this check based on feedback in SSE-13509
                 NewProjectList[i].adderror('Delivered and closed project Date can only be edited by member of "CPS Project closed/delivered edit rights" group.');
                //}
            }
            /*if(NewProjectList[i].RecordTypeId==selectedRecordTypeId){
                if(groupMemebersIds.isEmpty() == false && !groupMemebersIds.contains(Userinfo.getUserId())){
                    NewProjectList[i].adderror('You do not have permission to edit CPS Projects');
                }
            }  */         
        }
        set<id> projectset = new set<id>();
        for(ProjectObject__c projobj : NewProjectList){
            projectset.add(projobj .id);
        }
        Map<Id,List<Workpacket__c>> workpktmap = new Map<Id,List<Workpacket__c>>();
       List<Workpacket__c> workpacketlist = new List<Workpacket__c>();
        
        //List<ProjectObject__c> tempprojobj = [select id,name from ProjectObject__c   where ID IN : projectset ];
        workpacketlist = [select id , CPS_Project_Number__c , Description__c ,Solution_Type__c , Status__c,Product_PS__c,Agreed_Delivery__c from Workpacket__c where CPS_Project_Number__c IN:projectset];    
            for(Id project:projectset){
                List<Workpacket__c> tempworkpacketlist = new List<Workpacket__c>(); // Changed by Priyank on 8 March 2022
            for(Workpacket__c workpacket:workpacketlist){
                if(workpacket.CPS_Project_Number__c == project){
                    tempworkpacketlist.add(workpacket);
                }
            }
            workpktmap.put(project,tempworkpacketlist);    
            //tempworkpacketlist.clear();
        } 
      /*  for(ProjectObject__c projobj : [select id,name, ( select id , CPS_Project_Number__c , Description__c ,Solution_Type__c , Status__c,Product_PS__c,Agreed_Delivery__c from Workpackets__r) from ProjectObject__c   where ID IN : projectset ]){
            workpktmap.put(projobj.id, projobj.Workpackets__r);
        } */
        for(Integer i=0; i< NewProjectList.size();i++){ 
            if(NewProjectList[i].RecordTypeId==selectedRecordTypeId){
                for(Workpacket__c wkp : workpktmap.get(NewProjectList[i].id)){
                    if((wkp.Status__c!='Closed/Delivered' && wkp.Status__c!='Closed/Cancelled') && (NewProjectList[i].Project_Status__c=='Closed/Delivered')){ // Changed by Priyank on 8 March 2022
                        NewProjectList[i].adderror('Cannot move a CPS project to closed if any related work packets are NOT Closed/Delivered or Closed/Cancelled');
                    }            
                }
            }
        }
        //Added by Prabhat: Preventing Closing LPS Project if any related CPS is still Open as per SSE - 13509
        //Functionality commented as part of SSE-14164
       /* Map<Id,List<ProjectObject__c>> LpsToCPSMap = new Map<Id,List<ProjectObject__c>>();
        for(ProjectObject__c projvar : [select id,name, ( select id, Project_Status__c from Projects1__r) from ProjectObject__c where Id IN:projectset]){
            LpsToCPSMap.put(projvar .id, projvar.Projects1__r);
        } 
        system.debug('In Map'+LpsToCPSMap);
        
        for(Integer i=0; i< NewProjectList.size();i++){   
            if(NewProjectList[i].RecordTypeId!=selectedRecordTypeId){
                for(ProjectObject__c CPSPrj: LpsToCPSMap.get(NewProjectList[i].id)){
                    if(CPSPrj.Project_Status__c!='Closed/Delivered' && CPSPrj.Project_Status__c!='Closed/Cancelled' && NewProjectList[i].Project_Status__c=='Completed'&& OldProjectList[i].Project_Status__c!=NewProjectList[i].Project_Status__c ){
                        //if(CPSPrj.Project_Status__c!='Closed/Cancelled' && NewProjectList[i].Project_Status__c=='Cancelled'){
                        NewProjectList[i].adderror('You cannot close this project as its related CPS Projects are NOT Closed/Delivered or Closed/Cancelled');
                       //}
                    }            
                }
            }
        }*/
        
        //Added by Prabhat: Preventing Closing LPS Project----ENDs Here--
        
        Group gp =[select id,Name,(select id,UserOrGroupId from GroupMembers) from Group where Name='CPS Project closed/delivered edit rights'];
        GroupMember[] groupmembers = gp.Groupmembers;
        Set<String> gmids = new Set<String>();
        for(GroupMember gm:groupmembers){
            gmids.add(gm.UserOrGroupId);
        }
        for(Integer i=0; i< NewProjectList.size();i++){
            system.debug('CPS ManagerId'+NewProjectList[i].CPS_Project_Manager_New__c);
            system.debug('Login UserId'+Userinfo.getUserId());
            if(NewProjectList[i].RecordTypeId==selectedRecordTypeId && !gmids.contains(UserInfo.getUserId()) && NewProjectList[i].CPS_Project_Manager_New__c!= Userinfo.getUserId() && (OldProjectList[i].Project_Status__c  == 'closed/delivered') && NewProjectList[i].Total_Actual_Time__c == OldProjectList[i].Total_Actual_Time__c && Utility.Timesheetinsert == true){
                NewProjectList[i].adderror('Projects with status as Closed/Delivered can only be updated by "CPS Project Manager" or members of "CPS Project closed/delivered Edit rights" Group.');
            }
            if(NewProjectList[i].RecordTypeId==selectedRecordTypeId && NewProjectList[i].Project_Status__c != OldProjectList[i].Project_Status__c  && NewProjectList[i].Project_Status__c == 'closed/delivered' && NewProjectList[i].Date_Project__c == null){
                NewProjectList[i].Date_Project__c = System.now().date();
            }
            if(NewProjectList[i].RecordTypeId==selectedRecordTypeId  && NewProjectList[i].Scope_versus_actual_hours__c > 100 && NewProjectList[i].Reason_for_Additional_CPS_Time__c == null && Utility.Timesheetinsert == true){
                NewProjectList[i].adderror('Reason for Additional CPS Time is mandatory if Scope versus actual days is over 100%');
            }
            if(NewProjectList[i].RecordTypeId==selectedRecordTypeId  && NewProjectList[i].Project_Status__c != OldProjectList[i].Project_Status__c && NewProjectList[i].Project_Status__c == 'Executing' && NewProjectList[i].Handover_from_SD_C__c == null && Utility.Timesheetinsert == true){
                NewProjectList[i].Handover_from_SD_C__c.adderror('Handover from SD&C is mandatory when project status is moved to Executing');
            }   
        }
        }
        Runcount++;
    }
    
    Public static void UpdateScopedDaysAndEffort(List<ProjectObject__c> NewProjectList,List<ProjectObject__c> OldProjectList){
        List<Additional_Scoped_days__c> AdditionalList =  new List<Additional_Scoped_days__c>();
        id selectedRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
        for(Integer i=0; i< NewProjectList.size();i++){
            if(NewProjectList[i].Additional_Scoped_Days__c  != OldProjectList[i].Additional_Scoped_Days__c && (NewProjectList[i].Current_Scoped_Days_Effort__c != null && NewProjectList[i].Additional_Scoped_Days__c!= null) && NewProjectList[i].RecordTypeId == selectedRecordTypeId  ){
                NewProjectList[i].Current_Scoped_Days_Effort__c = NewProjectList[i].Current_Scoped_Days_Effort__c + NewProjectList[i].Additional_Scoped_Days__c;
            }
            if(NewProjectList[i].Scoped_Hours_Effort__c  != null && NewProjectList[i].Current_Scoped_Days_Effort__c == null && NewProjectList[i].RecordTypeId == selectedRecordTypeId){          
                NewProjectList[i].Current_Scoped_Days_Effort__c = NewProjectList[i].Scoped_Hours_Effort__c;
            }
            if(NewProjectList[i].Additional_Scoped_Days__c !=null && NewProjectList[i].Additional_Scoped_Days__c  !=  OldProjectList[i].Additional_Scoped_Days__c){
                Additional_Scoped_days__c AddObj = new Additional_Scoped_days__c();
                AddObj.Additional_Scoped_Days__c = NewProjectList[i].Additional_Scoped_Days__c;
                AddObj.Chargeable__c = NewProjectList[i].Chargeable__c;
                AddObj.Comments__c = NewProjectList[i].additional_scoped_comments__c;
                AddObj.Reason__c = NewProjectList[i].Reason__c;
                AddObj.CPS_Project__c  = NewProjectList[i].id;
                AdditionalList.add(AddObj);
                
            }
        }
        if(AdditionalList.size()>0){
            insert AdditionalList;
        }   
    }
    
    Public static void UpdateProjectMgrAndCordinator(List<ProjectObject__c> NewProjectList,List<ProjectObject__c> OldProjectList){
        for(Integer i=0; i< NewProjectList.size();i++){
            if(NewProjectList[i].Project_Manager__c != OldProjectList[i].Project_Manager__c){
                NewProjectList[i].Old_Project_Manager__c = OldProjectList[i].Project_Manager__c;
            }
            if(NewProjectList[i].Project_Co_ordinator__c != OldProjectList[i].Project_Co_ordinator__c){
                NewProjectList[i].Old_Project_Co_ordinator__c = OldProjectList[i].Project_Co_ordinator__c;
            }
        }
    }
   
    /* Commented by Aashi as this method is not in use */
    /*Public static void RestrictOrderLineRemoval(List<ProjectObject__c> NewProjectList,List<ProjectObject__c> OldProjectList){
        Boolean isAdmin = false;
        for(Profile prf : [Select id,Name from Profile where Name like '%System Admin%']){
            if(prf.Id == UserInfo.getProfileId()){
            isAdmin = true;
            break;}
        }
        Set<Id> projectIdsSet = new Set<Id>();
        for(Integer i=0;i<NewProjectList.size();i++){
            if(NewProjectList[i].Order_Line_Number__c != OldProjectList[i].Order_Line_Number__c && OldProjectList[i].Order_Line_Number__c != null)
                projectIdsSet.add(OldProjectList[i].id);
        }
        Map<Id,ProjectObject__c> projectsMap;
            if(projectIdsSet.size()>0)
            projectsMap = new Map<Id,ProjectObject__c>([Select id ,(SELECT id FROM Milestones__r WHERE Is_Signed__c = True limit 1),(SELECT id FROM Invoices__r WHERE Status__c = 'Submitted for Processing' or Status__c = 'Processed' limit 1) from ProjectObject__c where id in :projectIdsSet]);
        for(Integer i=0; i< NewProjectList.size();i++){
            if(!isAdmin){
                if(projectsMap!=null && projectsMap.get(OldProjectList[i].id)!= null && (projectsMap.get(OldProjectList[i].id).Milestones__r.size()>0 || projectsMap.get(OldProjectList[i].id).Invoices__r.size()>0)){   
                    NewProjectList[i].addError('You cannot disassociate this Order Line Number from Project:'+NewProjectList[i].Name+', as there is either a signed milestone/Submitted for Processing invoice request exists against this project.');
                    continue;
                }
            }
        }
    }*/
    
    Public static void UpdateTimesheetAndInvoices(List<ProjectObject__c> NewProjectList,List<ProjectObject__c> OldProjectList){
        for(Integer i=0; i< NewProjectList.size();i++){
            Timesheet_Manager.updateDataInTimesheets(OldProjectList[i],NewProjectList[i]); 
            try
            {
                ProjectInvoice_Manager.updateDataInInvoices(OldProjectList[i],NewProjectList[i]);
            }
            catch (System.DmlException e) {
                Set<Id> failedInvoiceRequestIdsSet = new Set<Id>();
                for (Integer j = 0; j < e.getNumDml(); j++)
                    failedInvoiceRequestIdsSet.add(e.getDmlId(j));
                String errorMessage = 'Update on Project failed due to following reasons : ';
                //String errorMessage='';
                Map<Id,Project_Invoice__c> failedInvoiceRequestMap = new Map<Id,Project_Invoice__c>([Select id,Name from Project_Invoice__c where id in :failedInvoiceRequestIdsSet]);
                for (Integer j = 0; j < e.getNumDml(); j++) {
                    errorMessage+='\n '+(j+1)+'. Invoice Request " '+failedInvoiceRequestMap.get(e.getDmlId(j)).Name+' " can not be updated because "'+e.getDmlMessage(j)+'"';
                    System.debug(e.getDmlMessage(j));
                }
                NewProjectList[i].addError(errorMessage);
            }
        }           
    }
    /* Commented by Aashi as this method is not in use */
       /* Public static void UpdateOrderLineOnProject(List<ProjectObject__c> NewProjectList,List<ProjectObject__c> OldProjectList){
        List<Contract_Line__c> orderLinesList = new List<Contract_Line__c>();
        for(Integer i=0; i< NewProjectList.size();i++){
            if(OldProjectList[i].Order_Line_Number__c<>NewProjectList[i].Order_Line_Number__c){
                if(NewProjectList[i].Order_Line_Number__c==null){
                    if(OldProjectList[i].Order_Line_Number__c<>null){
                        Contract_Line__c cl = new Contract_Line__c (Id=OldProjectList[i].Order_Line_Number__c);
                        cl.Project__c = null;
                        update cl;}
                }
                else{
                    Contract_Line__c cl = new Contract_Line__c (Id=NewProjectList[i].Order_Line_Number__c);
                    cl.Project__c = NewProjectList[i].id;
                    update cl;
                }            
            }
            if(NewProjectList[i].Order_Line_Number__c != OldProjectList[i].Order_Line_Number__c){
                if(NewProjectList[i].Order_Line_Number__c!=null){
                    Contract_Line__c orderLine = [Select id,Project__c from Contract_Line__c where id = :NewProjectList[i].Order_Line_Number__c];
                    orderLine.Project__c = NewProjectList[i].id;
                    orderLinesList.add(orderLine);
                }
                if(OldProjectList[i].Order_Line_Number__c!=null){
                    Contract_Line__c orderLineOld = [Select id,Project__c from Contract_Line__c where id = :OldProjectList[i].Order_Line_Number__c];
                    orderLineOld.Project__c = null;
                    orderLinesList.add(orderLineOld);
                }
            }
        }   if(orderLinesList.size()>0)
            update orderLinesList;
    }*/
    
    Public static void RestrictProjectDeletion(List<ProjectObject__c> NewProjectList,List<ProjectObject__c> OldProjectList){
        User usr = [Select id,Profile.Name from User where id = :UserInfo.getUserId()];
        Map<Id, Boolean> projectAccessMap = Project_Manager.userCanManageProjects(OldProjectList);
        for(Integer i=0; i< OldProjectList.size();i++){
            if(OldProjectList[i].Id == 'a0920000002roAP')
            OldProjectList[i].addError('This project cannot be deleted as it is used as a Dummy project for "Associate & Other costs with no projects".');
            else
            {
                Boolean userCanDeleteProject = projectAccessMap.get(OldProjectList[i].Id); 
            if(usr.profile.Name!='System Administrator' && usr.profile.Name!='Bullseye Project (Commercial)' )
                OldProjectList[i].addError('You are not authorised to delete this project. Please contact GSD if you believe this to be incorrect.');
            }
        }
    }
    //Commented by Vandita for SSE- 13772
    //Method to update Functional Area value from PS project to related CPS project on new record creation
  /* Public static void PopulateFunctionalAreaOnCPS(List<ProjectObject__c> NewProjectList){
        Id selectedRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
        Set<id> PSID = new Set<id>();
        Map<id,string> PSFucntional = new MAP<id,string>();
        List<ProjectObject__c> PSProjectList = new List<ProjectObject__c>();
        for(Integer i=0; i< NewProjectList.size();i++){
            PSID.add(NewProjectList[i].PS_Project_Number__c);
        }
        if(PSID != null){
            PSProjectList = [Select id,Functional_Area__c from ProjectObject__c where id IN:PSID];
        }
        for(Integer i=0; i< PSProjectList.size();i++){
            PSFucntional.put(PSProjectList[i].id,PSProjectList[i].Functional_Area__c);
        }
        
        for(Integer i=0; i< NewProjectList.size();i++){
            if(NewProjectList[i].PS_Project_Number__c != null && NewProjectList[i].RecordTypeId == selectedRecordTypeId){
                NewProjectList[i].Functional_Area__c = PSFucntional.get(NewProjectList[i].PS_Project_Number__c);
            }
        }
    }
    
    //Method to update Functional Area value from PS project to related CPS project on update of PS project
    Public static void PopulateFunctionalAreaOnCPSUpdate(List<ProjectObject__c> NewProjectList,List<ProjectObject__c> OldProjectList){
        Id selectedRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
        Set<id> PSID = new Set<id>(); 
        Map<id,string> PSFucntional = new MAP<id,string>();
        List<ProjectObject__c> PSProjectList = new List<ProjectObject__c>();
        for(Integer i=0; i< NewProjectList.size();i++){
            PSID.add(NewProjectList[i].PS_Project_Number__c);
        }
        if(PSID != null){
            PSProjectList = [Select id,Functional_Area__c from ProjectObject__c where id IN:PSID];
        }
        for(Integer i=0; i< PSProjectList.size();i++){
            PSFucntional.put(PSProjectList[i].id,PSProjectList[i].Functional_Area__c);
        }
        for(Integer i=0; i< NewProjectList.size();i++){
            if(NewProjectList[i].PS_Project_Number__c != null && OldProjectList[i].PS_Project_Number__c !=NewProjectList[i].PS_Project_Number__c && NewProjectList[i].RecordTypeId == selectedRecordTypeId){
            NewProjectList[i].Functional_Area__c = PSFucntional.get(PSProjectList[i].id);
            }
            
        }
        
    }
    
    //Method to update Functional Area value from PS project to all related CPS project on update of Functional value in PS
    Public static void PopulateFunctionalAreaOnAllCPS(List<ProjectObject__c> NewProjectList,List<ProjectObject__c> OldProjectList){
        Id selectedRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
        Set<id> PSIDCPS = new Set<id>();
        Map<id,string> PSCPSFucntional = new MAP<id,string>();
        List<ProjectObject__c> CPSProjectList = new List<ProjectObject__c>();
        for(Integer i=0; i< NewProjectList.size();i++){
            if(NewProjectList[i].Functional_Area__c != OldProjectList[i].Functional_Area__c && NewProjectList[i].RecordTypeId != selectedRecordTypeId){
              PSIDCPS.add(NewProjectList[i].id);
              PSCPSFucntional.put(NewProjectList[i].id,NewProjectList[i].Functional_Area__c);
            }
        }
        if(PSIDCPS != null){
            CPSProjectList = [Select id,Functional_Area__c,PS_Project_Number__c from ProjectObject__c where PS_Project_Number__c IN:PSIDCPS];
        }
        for(Integer i=0; i< CPSProjectList.size();i++){
            CPSProjectList[i].Functional_Area__c = PSCPSFucntional.get(CPSProjectList[i].PS_Project_Number__c);
        }
        
        update CPSProjectList;
    }
    
   /* Public static void UpdateOrderLines(List<ProjectObject__c> OldProjectList,List<ProjectObject__c> NewProjectList){
        Map<ProjectObject__c,List<OrderItem>> ProjectOrdelineMap = new Map<ProjectObject__c,List<OrderItem>>();
        List<OrderItem> ordelinesToUpdate = new List<OrderItem>();
        for(Integer i=0;i<NewProjectList.size();i++){
            if(NewProjectList[i].Order__c!=null && NewProjectList[i].Order__c!=OldProjectList[i].Order__c)
            {
                List<OrderItem> orderlineslist = [select id,Project__c from OrderItem where OrderId=:NewProjectList[i].Order__c and Project__c=null and Product2.Revenue_Category__c='Professional Services'];
                ProjectOrdelineMap.put(NewProjectList[i],orderlineslist);
            }
        }
        for(ProjectObject__c Project:ProjectOrdelineMap.Keyset()){
            for(OrderItem orderline:ProjectOrdelineMap.get(Project)){
                orderline.Project__c=Project.id;
                ordelinesToUpdate.add(orderline);
            }
        }
        if(ordelinesToUpdate!=null)
           update ordelinesToUpdate;
    } */
    
  /*  Public static void UpdateOrderLinesonInsert(List<ProjectObject__c> NewProjectList){
        Map<ProjectObject__c,List<OrderItem>> ProjectOrdelineMap = new Map<ProjectObject__c,List<OrderItem>>();
        List<OrderItem> ordelinesToUpdate = new List<OrderItem>();
        for(Integer i=0;i<NewProjectList.size();i++){
            if(NewProjectList[i].Order__c!=null)
            {
                List<OrderItem> orderlineslist = [select id,Project__c from OrderItem where OrderId=:NewProjectList[i].Order__c and Project__c=null and Product2.Revenue_Category__c='Professional Services'];
                ProjectOrdelineMap.put(NewProjectList[i],orderlineslist);
            }
        }
        for(ProjectObject__c Project:ProjectOrdelineMap.Keyset()){
            for(OrderItem orderline:ProjectOrdelineMap.get(Project)){
                System.debug('This is project id '+Project.id);
                orderline.Project__c=Project.id;
                ordelinesToUpdate.add(orderline);
            }
        }
        if(ordelinesToUpdate!=null)
           update ordelinesToUpdate;
    } */
    Public static void PopulateSurveyLanguage(List<ProjectObject__c> NewProjectList,List<ProjectObject__c> OldProjectList){
    
     for(integer i=0;i<NewProjectList.size();i++)
     {
     if(OldProjectList[i].Survey_Language__c=='' || (OldProjectList[i].LBU__c!=NewProjectList[i].LBU__c))
     {
     if(NewProjectList[i].LBU__c =='CA1'||NewProjectList[i].LBU__c =='US1'||NewProjectList[i].LBU__c =='US5')
        NewProjectList[i].Survey_Language__c='EN';
      else if(NewProjectList[i].LBU__c =='AD1'||NewProjectList[i].LBU__c =='ME1'||NewProjectList[i].LBU__c =='SA5')       
        NewProjectList[i].Survey_Language__c='EN-AR';
      else if(NewProjectList[i].LBU__c =='AU1'||NewProjectList[i].LBU__c =='NZ1')       
        NewProjectList[i].Survey_Language__c='EN-AU';
      else if(NewProjectList[i].LBU__c =='CN1')       
        NewProjectList[i].Survey_Language__c='EN-CN';
      else if(NewProjectList[i].LBU__c =='DE1'||NewProjectList[i].LBU__c =='DE5')       
        NewProjectList[i].Survey_Language__c='EN-DE';
      else if(NewProjectList[i].LBU__c =='UK1'||NewProjectList[i].LBU__c =='UK5'||NewProjectList[i].LBU__c =='IE1'||NewProjectList[i].LBU__c =='PH1')       
        NewProjectList[i].Survey_Language__c='EN-GB';
      else if(NewProjectList[i].LBU__c =='HK1')       
        NewProjectList[i].Survey_Language__c='EN-HK';
      else if(NewProjectList[i].LBU__c =='IN1')       
        NewProjectList[i].Survey_Language__c='EN-IN';
      else if(NewProjectList[i].LBU__c =='SG1')       
        NewProjectList[i].Survey_Language__c='EN-SG';
      else if(NewProjectList[i].LBU__c =='ZA1')       
        NewProjectList[i].Survey_Language__c='EN-ZA';
      else if(NewProjectList[i].LBU__c =='FR5'||NewProjectList[i].LBU__c =='FR1')       
        NewProjectList[i].Survey_Language__c='FR';
      else if(NewProjectList[i].LBU__c =='IT1')       
        NewProjectList[i].Survey_Language__c='IT';
      else if(NewProjectList[i].LBU__c =='BE5' ||NewProjectList[i].LBU__c =='NL5')       
        NewProjectList[i].Survey_Language__c='EN-BEN';
      else if(NewProjectList[i].LBU__c =='CH1')       
        NewProjectList[i].Survey_Language__c='EN-DE';
      else
        NewProjectList[i].Survey_Language__c='EN-NO';
      }
      else 
       continue;
      
      }
     }
    Public static void PopulateSurveyLanguageOnInsert(List<ProjectObject__c> NewProjectList){
     for(integer i=0;i<NewProjectList.size();i++)
     {
     if(NewProjectList[i].LBU__c =='CA1'||NewProjectList[i].LBU__c =='US1'||NewProjectList[i].LBU__c =='US5')
        NewProjectList[i].Survey_Language__c='EN';
      else if(NewProjectList[i].LBU__c =='AD1'||NewProjectList[i].LBU__c =='ME1'||NewProjectList[i].LBU__c =='SA5')       
        NewProjectList[i].Survey_Language__c='EN-AR';
      else if(NewProjectList[i].LBU__c =='AU1'||NewProjectList[i].LBU__c =='NZ1')       
        NewProjectList[i].Survey_Language__c='EN-AU';
      else if(NewProjectList[i].LBU__c =='CN1')       
        NewProjectList[i].Survey_Language__c='EN-CN';
      else if(NewProjectList[i].LBU__c =='DE1'||NewProjectList[i].LBU__c =='DE5')       
        NewProjectList[i].Survey_Language__c='EN-DE';
      else if(NewProjectList[i].LBU__c =='UK1'||NewProjectList[i].LBU__c =='UK5'||NewProjectList[i].LBU__c =='IE1'||NewProjectList[i].LBU__c =='PH1')       
        NewProjectList[i].Survey_Language__c='EN-GB';
      else if(NewProjectList[i].LBU__c =='HK1')       
        NewProjectList[i].Survey_Language__c='EN-HK';
      else if(NewProjectList[i].LBU__c =='IN1')       
        NewProjectList[i].Survey_Language__c='EN-IN';
      else if(NewProjectList[i].LBU__c =='SG1')       
        NewProjectList[i].Survey_Language__c='EN-SG';
      else if(NewProjectList[i].LBU__c =='ZA1')       
        NewProjectList[i].Survey_Language__c='EN-ZA';
      else if(NewProjectList[i].LBU__c =='FR5'||NewProjectList[i].LBU__c =='FR1')       
        NewProjectList[i].Survey_Language__c='FR';
      else if(NewProjectList[i].LBU__c =='IT1')       
        NewProjectList[i].Survey_Language__c='IT';
      else if(NewProjectList[i].LBU__c =='BE5' ||NewProjectList[i].LBU__c =='NL5')       
        NewProjectList[i].Survey_Language__c='EN-BEN';
      else if(NewProjectList[i].LBU__c =='CH1')       
        NewProjectList[i].Survey_Language__c='EN-DE';
      else
        NewProjectList[i].Survey_Language__c='EN-NO';
       }
     }
    
    //this method prevents user from marking the project as completed if there is any related milestone which is not signed
    Public static void checkMilestones(map<id,ProjectObject__c> NewProjectMap,map<id,ProjectObject__c> oldProjectMap){
        map<ProjectObject__c,list<Milestone__c>> milestonemap = new map<ProjectObject__c,list<Milestone__c>>();
        set<ProjectObject__c> closedProjects = new set<ProjectObject__c>();
        for(ProjectObject__c proj : NewProjectMap.values()){
            if(proj.Project_Status__c == 'Closed' && proj.Project_Status__c != oldProjectMap.get(proj.id).Project_Status__c){
                closedProjects.add(proj);
            }
        }
        for(Milestone__c mil : [select Is_Signed__c,Project__c from Milestone__c where Project__c in:closedProjects]){
            if(milestonemap.get(NewProjectMap.get(mil.Project__c)) == null){
                milestonemap.put(NewProjectMap.get(mil.Project__c),new list<Milestone__c>{mil});
            }
            else{
                milestonemap.get(NewProjectMap.get(mil.Project__c)).add(mil);
            }
        }
        /*for(ProjectObject__c proj : milestonemap.keyset()){
            for(Milestone__c mil : milestonemap.get(proj)){
                if(!mil.Is_Signed__c){
                    NewProjectMap.get(proj.id).addError('This Project cannot be marked as Completed since there are one or more related Milestone which are not signed.');
                }
            }
        } */
        for(ProjectObject__c proj : closedProjects){
            //System.debug('Milestones Values '+Math.roundToLong(proj.Milestones_Value__c));
            //System.debug('TOP Values '+Math.roundToLong(proj.Total_Orderline_Value_RollUp__c));  
            if(proj.Total_Orderline_Value_RollUp__c==null)
                proj.Total_Orderline_Value_RollUp__c=0;
            System.debug('Milestone value '+proj.Milestones_Value__c);
            System.debug('Total Order product value '+Math.roundToLong(proj.Total_Orderline_Value_RollUp__c));
             //Functionality commented as part of SSE-14164
            /*if(milestonemap.containsKey(proj)==false && proj.Total_Orderline_Value_RollUp__c!=0){ // Changed by Priyank on 8 march 2022
                NewProjectMap.get(proj.id).addError('This Project cannot be marked as Completed since there are no Milestones attached to it.');  
            }*/
            system.debug('--->milestonemap<---'+milestonemap.isEmpty());
            if(Math.roundToLong(proj.Milestones_Value__c)!=Math.roundToLong(proj.Total_Orderline_Value_RollUp__c)){
                NewProjectMap.get(proj.id).addError('This Project cannot be marked as Closed since Milestones Value does not match the Total Order Product Value');  
            }
            else if(milestonemap.isEmpty()==false){
                for(Milestone__c mil : milestonemap.get(proj)){
                    if(!mil.Is_Signed__c){
                        NewProjectMap.get(proj.id).addError('This Project cannot be marked as Closed since there are one or more related Milestone which are not signed.');
                    }
                } 
            }
            
        }
        
    }
    
    Public static void UpdateDescriptionNotesOnInsert(List<ProjectObject__c> NewProjectList){
        Map<Id,ContentNote> NewProjectDocumentMap = new Map<Id,ContentNote>();
        List<ContentNote> ContentNotesToInsert = new List<ContentNote>();  
        List<ContentDocumentLink> LinksToInsert = new List<ContentDocumentLink>();
        Datetime contentDate = Date.today();
        for(ProjectObject__c project:NewProjectList)
        {
            if(project.Project_Description__c!=null){
                String newcontent = '<p><b>1. </b>'+contentDate.format('dd-MMM-YYYY')+' '+UserInfo.getName()+' : '+project.Project_Description__c+'</p>';
                ContentNote cnt = new ContentNote();
                cnt.Content = Blob.valueof(newcontent);
                cnt.Title = 'Description Version 1';
                cnt.OwnerId = System.Label.Globus_Development_User_Id;
                ContentNotesToInsert.add(cnt);
                NewProjectDocumentMap.put(project.Id,cnt);
            }
        }
        if(ContentNotesToInsert.size()>0)
            insert ContentNotesToInsert;
        for(Id projectId:NewProjectDocumentMap.keyset()){
            ContentDocumentLink clnk = new ContentDocumentLink();
            clnk.LinkedEntityId = projectId;
            clnk.ContentDocumentId = NewProjectDocumentMap.get(projectId).Id;
            clnk.ShareType = 'I';
            LinksToInsert.add(clnk);
        }
        if(LinksToInsert.size()>0)
            insert LinksToInsert;
        
    }
    public Static Integer RunDescriptioncount = 1;
    Public static void UpdateDescriptionNotes(List<ProjectObject__c> OldProjectList,List<ProjectObject__c> NewProjectList,map<id,ProjectObject__c> NewProjectMap){
        if(RunDescriptioncount==1){
            Map<Id,ProjectObject__c> ProjectsWithChangedDescriptionMap = new Map<Id,ProjectObject__c>();
            Map<String,Id> ProjectsDocumentMap = new Map<String,Id>();  
            Map<Id,ContentNote> NewProjectDocumentMap = new Map<Id,ContentNote>();
            Map<Id,ContentNote> ContentNotesMap = new Map<Id,ContentNote>();
            List<ContentNote> ExistingNotes = new List<ContentNote>();
            List<ContentNote> ContentNotesToUpdate = new List<ContentNote>();
            List<ContentNote> ContentNotesToInsert = new List<ContentNote>();  
            List<ContentDocumentLink> LinksToInsert = new List<ContentDocumentLink>();   
            List<ContentDocumentLink> LinksWithProjects = new List<ContentDocumentLink>();  
            Map<Id,String> ProjectsCompleted = new Map<Id,String>();
            Datetime contentDate = Date.today();
            for(integer i=0;i<NewProjectList.size();i++)
            {
                if(OldProjectList[i].Project_Description__c!=NewProjectList[i].Project_Description__c){
                    ProjectsWithChangedDescriptionMap.put(NewProjectList[i].Id,NewProjectList[i]);
                }
            }
            System.debug('This is ProjectsWithChangedDescriptionMap '+ProjectsWithChangedDescriptionMap);
            if(!ProjectsWithChangedDescriptionMap.isEmpty()){
                LinksWithProjects = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId in :ProjectsWithChangedDescriptionMap.keyset()];
            }
            System.debug('This is LinksWithProjects '+LinksWithProjects);
            if(LinksWithProjects.size()==0 ){
                for(ProjectObject__c project:ProjectsWithChangedDescriptionMap.values()){
                    String newcontent = '<p><b> 1. </b>'+contentDate.format('dd-MMM-YYYY')+' '+UserInfo.getName()+' : '+project.Project_Description__c+'</p>';
                    ContentNote cnt = new ContentNote();
                    cnt.Content = Blob.valueof(newcontent);
                    cnt.Title = 'Description Version 1';
                    ContentNotesToInsert.add(cnt);
                    NewProjectDocumentMap.put(project.Id,cnt);
                }         
            }
            else{
                String MapString;
                for(ContentDocumentLink projectLink:LinksWithProjects){
                    MapString = projectLink.LinkedEntityId+''+projectLink.ContentDocumentId;
                    ProjectsDocumentMap.put(MapString,projectLink.ContentDocumentId);
                }
                System.debug('This is ProjectsDocumentMap '+ProjectsDocumentMap);
                if(!ProjectsDocumentMap.isEmpty()){
                    ExistingNotes =  [SELECT Content, Id, Title FROM ContentNote where Id in :ProjectsDocumentMap.values() and title like '%Description version%'];
                }
                For(ContentNote note:ExistingNotes){
                    ContentNotesMap.put(note.ID,note);
                }
                System.debug('This is ExistingNotes '+ExistingNotes);
                Set<Id> ProjectIdSet = new Set<Id>();
                For(String projectString:ProjectsDocumentMap.keyset()){
                    ProjectIdSet.add(projectString.substring(0,18));
                }
                System.debug('This is ProjectIdSet '+ProjectIdSet);
                List<String> ProjIdNoteIdList = new List<String>();
                For(Id tempprojId: ProjectIdSet){
                    For(ContentNote tempnoteid:ExistingNotes){
                        ProjIdNoteIdList.add(tempprojId+''+tempnoteid.Id);
                    }
                }
                System.debug('This is ProjIdNoteIdList '+ProjIdNoteIdList);
                For(Id projectId:ProjectIdSet){
                    if(ExistingNotes.size()>0){
                        for(String projnoteId:ProjIdNoteIdList){
                            if(ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId))!=null){
                                String[] temparray = ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)).title.split(' ');
                                Integer newversion = Integer.valueof(temparray[2])+1;
                                String newcontent = '<p><b> '+newversion+'. </b>'+contentDate.format('dd-MMM-YYYY')+' '+UserInfo.getName()+' : '+ProjectsWithChangedDescriptionMap.get(projectId).Project_Description__c+'</p>'+ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)).Content.toString();
                                ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)).title = 'Description Version '+newversion;
                                ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)).Content = Blob.valueof(newcontent);
                                ContentNotesToUpdate.add(ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)));
                                ProjectsCompleted.put(projnoteId.substring(0,18),'Update Completed');
                            }
                            
                        }
                        
                    }
                    else{
                        String newcontent ='<p><b> 1. </b>'+contentDate.format('dd-MMM-YYYY')+' '+UserInfo.getName()+' : '+ProjectsWithChangedDescriptionMap.get(projectId).Project_Description__c+'</p>';
                        ContentNote cnt = new ContentNote();
                        cnt.Content = Blob.valueof(newcontent);
                        cnt.Title = 'Description Version 1';
                        ContentNotesToInsert.add(cnt);
                        NewProjectDocumentMap.put(projectId,cnt);
                    }
                    
                }
                System.debug('This is ProjectsCompleted '+ProjectsCompleted);
                For(Id projectId:ProjectIdSet){
                    if(ProjectsCompleted.get(projectId)==null){
                        String newcontent ='<p><b> 1. </b>'+contentDate.format('dd-MMM-YYYY')+' '+UserInfo.getName()+' : '+ProjectsWithChangedDescriptionMap.get(projectId).Project_Description__c+'</p>';
                        ContentNote cnt = new ContentNote();
                        cnt.Content = Blob.valueof(newcontent);
                        cnt.Title = 'Description Version 1';
                        ContentNotesToInsert.add(cnt);
                        NewProjectDocumentMap.put(projectId,cnt);
                    }
                }
                
            }
            if(ContentNotesToUpdate.size()>0)
                Update ContentNotesToUpdate;
            if(ContentNotesToInsert.size()>0)
                insert ContentNotesToInsert;
            for(Id projectId:NewProjectDocumentMap.keyset()){
                ContentDocumentLink clnk = new ContentDocumentLink();
                clnk.LinkedEntityId = projectId;
                clnk.ContentDocumentId = NewProjectDocumentMap.get(projectId).Id;
                clnk.ShareType = 'I';
                LinksToInsert.add(clnk);
            }
            if(LinksToInsert.size()>0)
                insert LinksToInsert;
            
        }
        RunDescriptioncount++;
    }  
    
    /*Public static void editValidation(List<ProjectObject__c> NewProjectList,List<ProjectObject__c> OldProjectList,map<id,ProjectObject__c> oldprojectmap){
        user u = [select id,PSA_Role__c from user where id = :userinfo.getUserId()];
        for(ProjectObject__c p : NewProjectList){
            if((p.RecordType.DeveloperName != 'CPS_Project')&&!(p.Project_Manager__c == userinfo.getUserId()&&u.PSA_Role__c == 'Project Manager')&&(u.PSA_Role__c != 'PSA Lead')&&oldprojectmap.get(p.id).FlowFilter__c == false){
               p.addError('Only Project Manager or PSA Lead can edit a Project');
            }
        }
    }*/
    Public static void ShareWithCoordinatorOnInsert(List<ProjectObject__c> NewProjectList){
        List<ProjectObject__Share> ProjectShares = new List<ProjectObject__Share>();
        For(ProjectObject__c project:NewProjectList){
            if(project.Project_Co_ordinator__c!=null){
                ProjectObject__Share projectrecord = new ProjectObject__Share();
                projectrecord.ParentId = project.Id;
                projectrecord.UserOrGroupId = project.Project_Co_ordinator__c;
                projectrecord.AccessLevel = 'edit';
                projectrecord.RowCause = Schema.ProjectObject__Share.RowCause.Share_with_Project_Co_ordinator__c;
                ProjectShares.add(projectrecord);
            }
        }
        if(ProjectShares.size()!=null){
            insert ProjectShares;
        }
        //Database.SaveResult[] ProjectShareInsertResult = Database.insert(ProjectShares,false);
    }
    Public static void ShareWithCoordinatorOnUpdate(List<ProjectObject__c> NewProjectList,List<ProjectObject__c> OldProjectList){
        List<ProjectObject__Share> ProjectShares = new List<ProjectObject__Share>();
        Map<ProjectObject__c,Id> OldProjectSharing = new Map<ProjectObject__c,Id>();
        List<ProjectObject__Share> ProjectSharesToDelete = new List<ProjectObject__Share>();
        
        For(Integer i=0;i<NewProjectList.size();i++){
            if(NewProjectList[i].Project_Co_ordinator__c!=OldProjectList[i].Project_Co_ordinator__c && NewProjectList[i].Project_Co_ordinator__c!=null){
                ProjectObject__Share projectrecord = new ProjectObject__Share();
                projectrecord.ParentId = NewProjectList[i].Id;
                projectrecord.UserOrGroupId = NewProjectList[i].Project_Co_ordinator__c;
                projectrecord.AccessLevel = 'edit';
                projectrecord.RowCause = Schema.ProjectObject__Share.RowCause.Share_with_Project_Co_ordinator__c;
                ProjectShares.add(projectrecord);
                OldProjectSharing.put(OldProjectList[i],OldProjectList[i].Project_Co_ordinator__c);
            }
            if(NewProjectList[i].Project_Co_ordinator__c!=OldProjectList[i].Project_Co_ordinator__c && NewProjectList[i].Project_Co_ordinator__c == null){
                OldProjectSharing.put(OldProjectList[i],OldProjectList[i].Project_Co_ordinator__c);
            }
        }
        System.debug('OldProjectSharing '+ OldProjectSharing.size());
        if(OldProjectSharing.size()!=null){
            ProjectSharesToDelete = [select Id from ProjectObject__Share where ParentId In :OldProjectSharing.keyset() and UserOrGroupId In :OldProjectSharing.values() and RowCause=:Schema.ProjectObject__Share.RowCause.Share_with_Project_Co_ordinator__c];
            delete ProjectSharesToDelete;
        }
        if(ProjectShares.size()!=null){
            insert ProjectShares;
        }
        //Database.SaveResult[] ProjectShareInsertResult = Database.insert(ProjectShares,false);
    }
    
    Public static void ShareWithCPSGroupMemOnInsert(List<ProjectObject__c> NewProjectList){
        List<ProjectObject__Share> ProjectShares = new List<ProjectObject__Share>();
        Map<ProjectObject__c,Id> OldProjectSharing = new Map<ProjectObject__c,Id>();
        List<ProjectObject__Share> ProjectSharesToDelete = new List<ProjectObject__Share>();
        Id selectedRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
        group gropob= [select id from group where name ='CPS Create Edit Perm Group' LIMIT 1];        
        For(Integer i=0;i<NewProjectList.size();i++){
            if(NewProjectList[i].RecordTypeId == selectedRecordTypeId){
                ProjectObject__Share projectrecord = new ProjectObject__Share();
                projectrecord.ParentId = NewProjectList[i].Id;
                projectrecord.UserOrGroupId = gropob.id;
                projectrecord.AccessLevel = 'edit';
                projectrecord.RowCause = Schema.ProjectObject__Share.RowCause.Manual;
                ProjectShares.add(projectrecord);
            }
        }
        
        if(ProjectShares.size()!=null){
            insert ProjectShares;
        }
    }
    Public static void UpdateProjectStatusOnPMChange(List<ProjectObject__c> NewProjectList,List<ProjectObject__c> OldProjectList){
         For(Integer i=0;i<NewProjectList.size();i++){
             if(OldProjectList[i].Project_Manager__c==null && (OldProjectList[i].Project_Manager__c!=NewProjectList[i].Project_Manager__c)){
                 NewProjectList[i].Project_Status__c = 'In Progress';
             }
         }
    }
    Public static void UpdateReasonforDeliveryTargetVarianceNotesOnInsert(List<ProjectObject__c> NewProjectList){
        Map<Id,ContentNote> NewProjectDocumentMap = new Map<Id,ContentNote>();
        List<ContentNote> ContentNotesToInsert = new List<ContentNote>();  
        List<ContentDocumentLink> LinksToInsert = new List<ContentDocumentLink>();
        Datetime contentDate = Datetime.now();
        for(ProjectObject__c project:NewProjectList)
        {
            if(project.Reason_for_Delivery_Target_Variance__c!=null){
                String newcontent = '<p><b> 1. </b>'+contentDate.format('dd-MMM-YYYY\'T\'HH:mm:ss')+' '+UserInfo.getName()+' : '+project.Reason_for_Delivery_Target_Variance__c+'</p>';
                ContentNote cnt = new ContentNote();
                cnt.Content = Blob.valueof(newcontent);
                cnt.Title = 'Track for Delivery Target Variance Version 1';
                cnt.OwnerId = System.Label.Globus_Development_User_Id;
                ContentNotesToInsert.add(cnt);
                NewProjectDocumentMap.put(project.Id,cnt);
            }
        }
        if(ContentNotesToInsert.size()>0)
            insert ContentNotesToInsert;
        for(Id projectId:NewProjectDocumentMap.keyset()){
            ContentDocumentLink clnk = new ContentDocumentLink();
            clnk.LinkedEntityId = projectId;
            clnk.ContentDocumentId = NewProjectDocumentMap.get(projectId).Id;
            clnk.ShareType = 'I';
            LinksToInsert.add(clnk);
        }
        if(LinksToInsert.size()>0)
            insert LinksToInsert;
        
    }
    
    public Static Integer RunCountForVariance = 1;
    Public static void UpdateReasonforDeliveryTargetVarianceNotes(List<ProjectObject__c> OldProjectList,List<ProjectObject__c> NewProjectList,map<id,ProjectObject__c> NewProjectMap){
        if(RunCountForVariance==1){
            Map<Id,ProjectObject__c> ProjectsWithChangedDescriptionMap = new Map<Id,ProjectObject__c>();
            Map<String,Id> ProjectsDocumentMap = new Map<String,Id>();  
            Map<Id,ContentNote> NewProjectDocumentMap = new Map<Id,ContentNote>();
            Map<Id,ContentNote> ContentNotesMap = new Map<Id,ContentNote>();
            List<ContentNote> ExistingNotes = new List<ContentNote>();
            List<ContentNote> ContentNotesToUpdate = new List<ContentNote>();
            List<ContentNote> ContentNotesToInsert = new List<ContentNote>();  
            List<ContentDocumentLink> LinksToInsert = new List<ContentDocumentLink>();   
            List<ContentDocumentLink> LinksWithProjects = new List<ContentDocumentLink>();  
            Map<Id,String> ProjectsCompleted = new Map<Id,String>();
            Datetime contentDate = Datetime.now();
            for(integer i=0;i<NewProjectList.size();i++)
            {
                if(OldProjectList[i].Reason_for_Delivery_Target_Variance__c!=NewProjectList[i].Reason_for_Delivery_Target_Variance__c){
                    ProjectsWithChangedDescriptionMap.put(NewProjectList[i].Id,NewProjectList[i]);
                }
            }
            System.debug('This is ProjectsWithChangedDescriptionMap '+ProjectsWithChangedDescriptionMap);
            if(!ProjectsWithChangedDescriptionMap.isEmpty()){
                LinksWithProjects = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId in :ProjectsWithChangedDescriptionMap.keyset()];
            }
            System.debug('This is LinksWithProjects '+LinksWithProjects);
            if(LinksWithProjects.size()==0 ){
                for(ProjectObject__c project:ProjectsWithChangedDescriptionMap.values()){
                    String newcontent = '<p><b> 1. </b>'+contentDate.format('dd-MMM-YYYY\'T\'HH:mm:ss')+' '+UserInfo.getName()+' : '+project.Reason_for_Delivery_Target_Variance__c+'</p>';
                    ContentNote cnt = new ContentNote();
                    cnt.Content = Blob.valueof(newcontent);
                    cnt.Title = 'Track for Delivery Target Variance Version 1';
                    ContentNotesToInsert.add(cnt);
                    NewProjectDocumentMap.put(project.Id,cnt);
                }         
            }
            else{
                String MapString;
                for(ContentDocumentLink projectLink:LinksWithProjects){
                    MapString = projectLink.LinkedEntityId+''+projectLink.ContentDocumentId;
                    ProjectsDocumentMap.put(MapString,projectLink.ContentDocumentId);
                }
                System.debug('This is ProjectsDocumentMap '+ProjectsDocumentMap);
                if(!ProjectsDocumentMap.isEmpty()){
                    ExistingNotes =  [SELECT Content, Id, Title FROM ContentNote where Id in :ProjectsDocumentMap.values() and title like '%Track for Delivery Target Variance Version%'];
                }
                For(ContentNote note:ExistingNotes){
                    ContentNotesMap.put(note.ID,note);
                }
                System.debug('This is ExistingNotes '+ExistingNotes);
                Set<Id> ProjectIdSet = new Set<Id>();
                For(String projectString:ProjectsDocumentMap.keyset()){
                    ProjectIdSet.add(projectString.substring(0,18));
                }
                System.debug('This is ProjectIdSet '+ProjectIdSet);
                List<String> ProjIdNoteIdList = new List<String>();
                For(Id tempprojId: ProjectIdSet){
                    For(ContentNote tempnoteid:ExistingNotes){
                        ProjIdNoteIdList.add(tempprojId+''+tempnoteid.Id);
                    }
                }
                System.debug('This is ProjIdNoteIdList '+ProjIdNoteIdList);
                For(Id projectId:ProjectIdSet){
                    if(ExistingNotes.size()>0){
                        for(String projnoteId:ProjIdNoteIdList){
                            if(ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId))!=null){
                                String[] temparray = ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)).title.split(' ');
                                Integer newversion = Integer.valueof(temparray[temparray.size()-1])+1;
                                String newcontent = '<p><b> '+newversion+'. </b>'+contentDate.format('dd-MMM-YYYY\'T\'HH:mm:ss')+' '+UserInfo.getName()+' : '+ProjectsWithChangedDescriptionMap.get(projectId).Reason_for_Delivery_Target_Variance__c+'</p>'+ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)).Content.toString();
                                ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)).title = 'Track for Delivery Target Variance Version '+newversion;
                                ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)).Content = Blob.valueof(newcontent);
                                ContentNotesToUpdate.add(ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)));
                                ProjectsCompleted.put(projnoteId.substring(0,18),'Update Completed');
                            }
                            
                        }
                        
                    }
                    else{
                        String newcontent ='<p><b> 1. </b>'+contentDate.format('dd-MMM-YYYY\'T\'HH:mm:ss')+' '+UserInfo.getName()+' : '+ProjectsWithChangedDescriptionMap.get(projectId).Reason_for_Delivery_Target_Variance__c+'</p>';
                        ContentNote cnt = new ContentNote();
                        cnt.Content = Blob.valueof(newcontent);
                        cnt.Title = 'Track for Delivery Target Variance Version 1';
                        ContentNotesToInsert.add(cnt);
                        NewProjectDocumentMap.put(projectId,cnt);
                    }
                    
                }
                System.debug('This is ProjectsCompleted '+ProjectsCompleted);
                For(Id projectId:ProjectIdSet){
                    if(ProjectsCompleted.get(projectId)==null){
                        String newcontent ='<p><b> 1. </b>'+contentDate.format('dd-MMM-YYYY\'T\'HH:mm:ss')+' '+UserInfo.getName()+' : '+ProjectsWithChangedDescriptionMap.get(projectId).Reason_for_Delivery_Target_Variance__c+'</p>';
                        ContentNote cnt = new ContentNote();
                        cnt.Content = Blob.valueof(newcontent);
                        cnt.Title = 'Track for Delivery Target Variance Version 1';
                        ContentNotesToInsert.add(cnt);
                        NewProjectDocumentMap.put(projectId,cnt);
                    }
                }
                
            }
            if(ContentNotesToUpdate.size()>0)
                Update ContentNotesToUpdate;
            if(ContentNotesToInsert.size()>0)
                insert ContentNotesToInsert;
            for(Id projectId:NewProjectDocumentMap.keyset()){
                ContentDocumentLink clnk = new ContentDocumentLink();
                clnk.LinkedEntityId = projectId;
                clnk.ContentDocumentId = NewProjectDocumentMap.get(projectId).Id;
                clnk.ShareType = 'I';
                LinksToInsert.add(clnk);
            }
            if(LinksToInsert.size()>0)
                insert LinksToInsert;
            
        }
        RunCountForVariance++;
    }  
    
    Public static void UpdateCommentsNotesOnInsert(List<ProjectObject__c> NewProjectList){
        Map<Id,ContentNote> NewProjectDocumentMap = new Map<Id,ContentNote>();
        List<ContentNote> ContentNotesToInsert = new List<ContentNote>();  
        List<ContentDocumentLink> LinksToInsert = new List<ContentDocumentLink>();
        Datetime contentDate = Datetime.now();
        for(ProjectObject__c project:NewProjectList)
        {
            if(project.Comment__c!=null){
                String newcontent = '<p><b> 1. </b>'+contentDate.format('dd-MMM-YYYY\'T\'HH:mm:ss')+' '+UserInfo.getName()+' : '+project.Comment__c+'</p>';
                ContentNote cnt = new ContentNote();
                cnt.Content = Blob.valueof(newcontent);
                cnt.Title = 'Track Comments Version 1';
                cnt.OwnerId = System.Label.Globus_Development_User_Id;
                ContentNotesToInsert.add(cnt);
                NewProjectDocumentMap.put(project.Id,cnt);
            }
        }
        if(ContentNotesToInsert.size()>0)
            insert ContentNotesToInsert;
        for(Id projectId:NewProjectDocumentMap.keyset()){
            ContentDocumentLink clnk = new ContentDocumentLink();
            clnk.LinkedEntityId = projectId;
            clnk.ContentDocumentId = NewProjectDocumentMap.get(projectId).Id;
            clnk.ShareType = 'I';
            LinksToInsert.add(clnk);
        }
        if(LinksToInsert.size()>0)
            insert LinksToInsert;
        
    }
    
    public Static Integer RunCountForComment = 1;
    Public static void UpdateCommentsNotes(List<ProjectObject__c> OldProjectList,List<ProjectObject__c> NewProjectList,map<id,ProjectObject__c> NewProjectMap){
        if(RunCountForComment==1){
        Map<Id,ProjectObject__c> ProjectsWithChangedDescriptionMap = new Map<Id,ProjectObject__c>();
            Map<String,Id> ProjectsDocumentMap = new Map<String,Id>();  
            Map<Id,ContentNote> NewProjectDocumentMap = new Map<Id,ContentNote>();
            Map<Id,ContentNote> ContentNotesMap = new Map<Id,ContentNote>();
            List<ContentNote> ExistingNotes = new List<ContentNote>();
            List<ContentNote> ContentNotesToUpdate = new List<ContentNote>();
            List<ContentNote> ContentNotesToInsert = new List<ContentNote>();  
            List<ContentDocumentLink> LinksToInsert = new List<ContentDocumentLink>();   
            List<ContentDocumentLink> LinksWithProjects = new List<ContentDocumentLink>();  
            Map<Id,String> ProjectsCompleted = new Map<Id,String>();
            Datetime contentDate = Datetime.now();
            for(integer i=0;i<NewProjectList.size();i++)
            {
                if(OldProjectList[i].Comment__c!=NewProjectList[i].Comment__c){
                    ProjectsWithChangedDescriptionMap.put(NewProjectList[i].Id,NewProjectList[i]);
                }
            }
            System.debug('This is ProjectsWithChangedDescriptionMap '+ProjectsWithChangedDescriptionMap);
            if(!ProjectsWithChangedDescriptionMap.isEmpty()){
                LinksWithProjects = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId in :ProjectsWithChangedDescriptionMap.keyset()];
            }
            System.debug('This is LinksWithProjects '+LinksWithProjects);
            if(LinksWithProjects.size()==0 ){
                for(ProjectObject__c project:ProjectsWithChangedDescriptionMap.values()){
                    String newcontent = '<p><b> 1. </b>'+contentDate.format('dd-MMM-YYYY\'T\'HH:mm:ss')+' '+UserInfo.getName()+' : '+project.Comment__c+'</p>';
                    ContentNote cnt = new ContentNote();
                    cnt.Content = Blob.valueof(newcontent);
                    cnt.Title = 'Track Comments Version 1';
                    ContentNotesToInsert.add(cnt);
                    NewProjectDocumentMap.put(project.Id,cnt);
                }         
            }
            else{
                String MapString;
                for(ContentDocumentLink projectLink:LinksWithProjects){
                    MapString = projectLink.LinkedEntityId+''+projectLink.ContentDocumentId;
                    ProjectsDocumentMap.put(MapString,projectLink.ContentDocumentId);
                }
                System.debug('This is ProjectsDocumentMap '+ProjectsDocumentMap);
                if(!ProjectsDocumentMap.isEmpty()){
                    ExistingNotes =  [SELECT Content, Id, Title FROM ContentNote where Id in :ProjectsDocumentMap.values() and title like '%Track Comments Version%'];
                }
                For(ContentNote note:ExistingNotes){
                    ContentNotesMap.put(note.ID,note);
                }
                System.debug('This is ExistingNotes '+ExistingNotes);
                Set<Id> ProjectIdSet = new Set<Id>();
                For(String projectString:ProjectsDocumentMap.keyset()){
                    ProjectIdSet.add(projectString.substring(0,18));
                }
                System.debug('This is ProjectIdSet '+ProjectIdSet);
                List<String> ProjIdNoteIdList = new List<String>();
                For(Id tempprojId: ProjectIdSet){
                    For(ContentNote tempnoteid:ExistingNotes){
                        ProjIdNoteIdList.add(tempprojId+''+tempnoteid.Id);
                    }
                }
                System.debug('This is ProjIdNoteIdList '+ProjIdNoteIdList);
                For(Id projectId:ProjectIdSet){
                    if(ExistingNotes.size()>0){
                        for(String projnoteId:ProjIdNoteIdList){
                            if(ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId))!=null){
                                String[] temparray = ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)).title.split(' ');
                                Integer newversion = Integer.valueof(temparray[temparray.size()-1])+1;
                                String newcontent = '<p><b> '+newversion+'. </b>'+contentDate.format('dd-MMM-YYYY\'T\'HH:mm:ss')+' '+UserInfo.getName()+' : '+ProjectsWithChangedDescriptionMap.get(projectId).Comment__c+'</p>'+ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)).Content.toString();
                                ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)).title = 'Track Comments Version '+newversion;
                                ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)).Content = Blob.valueof(newcontent);
                                ContentNotesToUpdate.add(ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)));
                                ProjectsCompleted.put(projnoteId.substring(0,18),'Update Completed');
                            }
                            
                        }
                        
                    }
                    else{
                        String newcontent ='<p><b> 1. </b>'+contentDate.format('dd-MMM-YYYY\'T\'HH:mm:ss')+' '+UserInfo.getName()+' : '+ProjectsWithChangedDescriptionMap.get(projectId).Comment__c+'</p>';
                        ContentNote cnt = new ContentNote();
                        cnt.Content = Blob.valueof(newcontent);
                        cnt.Title = 'Track Comments Version 1';
                        ContentNotesToInsert.add(cnt);
                        NewProjectDocumentMap.put(projectId,cnt);
                    }
                    
                }
                System.debug('This is ProjectsCompleted '+ProjectsCompleted);
                For(Id projectId:ProjectIdSet){
                    if(ProjectsCompleted.get(projectId)==null){
                        String newcontent ='<p><b> 1. </b>'+contentDate.format('dd-MMM-YYYY\'T\'HH:mm:ss')+' '+UserInfo.getName()+' : '+ProjectsWithChangedDescriptionMap.get(projectId).Comment__c+'</p>';
                        ContentNote cnt = new ContentNote();
                        cnt.Content = Blob.valueof(newcontent);
                        cnt.Title = 'Track Comments Version 1';
                        ContentNotesToInsert.add(cnt);
                        NewProjectDocumentMap.put(projectId,cnt);
                    }
                }
                
            }
            if(ContentNotesToUpdate.size()>0)
                Update ContentNotesToUpdate;
            if(ContentNotesToInsert.size()>0)
                insert ContentNotesToInsert;
            for(Id projectId:NewProjectDocumentMap.keyset()){
                ContentDocumentLink clnk = new ContentDocumentLink();
                clnk.LinkedEntityId = projectId;
                clnk.ContentDocumentId = NewProjectDocumentMap.get(projectId).Id;
                clnk.ShareType = 'I';
                LinksToInsert.add(clnk);
            }
            if(LinksToInsert.size()>0)
                insert LinksToInsert;
            
        }
        RunCountForComment++;
        
        
    }  
    Public static void UpdateReasonsNotesOnInsert(List<ProjectObject__c> NewProjectList){
        Map<Id,ContentNote> NewProjectDocumentMap = new Map<Id,ContentNote>();
        List<ContentNote> ContentNotesToInsert = new List<ContentNote>();  
        List<ContentDocumentLink> LinksToInsert = new List<ContentDocumentLink>();
        Datetime contentDate = Datetime.now();
        for(ProjectObject__c project:NewProjectList)
        {
            if(project.Handover_from_SD_C__c!=null || project.Reason_CPS__c!=null){
                String newcontent = '<p><b> 1. </b>'+contentDate.format('dd-MMM-YYYY\'T\'HH:mm:ss')+' '+UserInfo.getName()+' : '+project.Handover_from_SD_C__c+'-'+project.Reason_CPS__c+'</p>';
                ContentNote cnt = new ContentNote();
                cnt.Content = Blob.valueof(newcontent);
                cnt.Title = 'Track for Reason Version 1';
                cnt.OwnerId = System.Label.Globus_Development_User_Id;
                ContentNotesToInsert.add(cnt);
                NewProjectDocumentMap.put(project.Id,cnt);
            }
        }
        if(ContentNotesToInsert.size()>0)
            insert ContentNotesToInsert;
        for(Id projectId:NewProjectDocumentMap.keyset()){
            ContentDocumentLink clnk = new ContentDocumentLink();
            clnk.LinkedEntityId = projectId;
            clnk.ContentDocumentId = NewProjectDocumentMap.get(projectId).Id;
            clnk.ShareType = 'I';
            LinksToInsert.add(clnk);
        }
        if(LinksToInsert.size()>0)
            insert LinksToInsert;
        
    }
    
    public Static Integer RunCountForReason = 1;
    Public static void UpdateReasonsNotes(List<ProjectObject__c> OldProjectList,List<ProjectObject__c> NewProjectList,map<id,ProjectObject__c> NewProjectMap){
        if(RunCountForReason==1){
        Map<Id,ProjectObject__c> ProjectsWithChangedDescriptionMap = new Map<Id,ProjectObject__c>();
            Map<String,Id> ProjectsDocumentMap = new Map<String,Id>();  
            Map<Id,ContentNote> NewProjectDocumentMap = new Map<Id,ContentNote>();
            Map<Id,ContentNote> ContentNotesMap = new Map<Id,ContentNote>();
            List<ContentNote> ExistingNotes = new List<ContentNote>();
            List<ContentNote> ContentNotesToUpdate = new List<ContentNote>();
            List<ContentNote> ContentNotesToInsert = new List<ContentNote>();  
            List<ContentDocumentLink> LinksToInsert = new List<ContentDocumentLink>();   
            List<ContentDocumentLink> LinksWithProjects = new List<ContentDocumentLink>();  
            Map<Id,String> ProjectsCompleted = new Map<Id,String>();
            Datetime contentDate = Datetime.now();
            for(integer i=0;i<NewProjectList.size();i++)
            {
                if(OldProjectList[i].Handover_from_SD_C__c!=NewProjectList[i].Handover_from_SD_C__c || OldProjectList[i].Reason_CPS__c!=NewProjectList[i].Reason_CPS__c){
                    ProjectsWithChangedDescriptionMap.put(NewProjectList[i].Id,NewProjectList[i]);
                }
            }
            System.debug('This is ProjectsWithChangedDescriptionMap '+ProjectsWithChangedDescriptionMap);
            if(!ProjectsWithChangedDescriptionMap.isEmpty()){
                LinksWithProjects = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId in :ProjectsWithChangedDescriptionMap.keyset()];
            }
            System.debug('This is LinksWithProjects '+LinksWithProjects);
            if(LinksWithProjects.size()==0 ){
                for(ProjectObject__c project:ProjectsWithChangedDescriptionMap.values()){
                    String newcontent = '<p><b> 1. </b>'+contentDate.format('dd-MMM-YYYY\'T\'HH:mm:ss')+' '+UserInfo.getName()+' : '+project.Handover_from_SD_C__c+'-'+project.Reason_CPS__c+'</p>';
                    ContentNote cnt = new ContentNote();
                    cnt.Content = Blob.valueof(newcontent);
                    cnt.Title = 'Track for Reason Version 1';
                    ContentNotesToInsert.add(cnt);
                    NewProjectDocumentMap.put(project.Id,cnt);
                }         
            }
            else{
                String MapString;
                for(ContentDocumentLink projectLink:LinksWithProjects){
                    MapString = projectLink.LinkedEntityId+''+projectLink.ContentDocumentId;
                    ProjectsDocumentMap.put(MapString,projectLink.ContentDocumentId);
                }
                System.debug('This is ProjectsDocumentMap '+ProjectsDocumentMap);
                if(!ProjectsDocumentMap.isEmpty()){
                    ExistingNotes =  [SELECT Content, Id, Title FROM ContentNote where Id in :ProjectsDocumentMap.values() and title like '%Track for Reason Version%'];
                }
                For(ContentNote note:ExistingNotes){
                    ContentNotesMap.put(note.ID,note);
                }
                System.debug('This is ExistingNotes '+ExistingNotes);
                Set<Id> ProjectIdSet = new Set<Id>();
                For(String projectString:ProjectsDocumentMap.keyset()){
                    ProjectIdSet.add(projectString.substring(0,18));
                }
                System.debug('This is ProjectIdSet '+ProjectIdSet);
                List<String> ProjIdNoteIdList = new List<String>();
                For(Id tempprojId: ProjectIdSet){
                    For(ContentNote tempnoteid:ExistingNotes){
                        ProjIdNoteIdList.add(tempprojId+''+tempnoteid.Id);
                    }
                }
                System.debug('This is ProjIdNoteIdList '+ProjIdNoteIdList);
                For(Id projectId:ProjectIdSet){
                    if(ExistingNotes.size()>0){
                        for(String projnoteId:ProjIdNoteIdList){
                            if(ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId))!=null){
                                String[] temparray = ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)).title.split(' ');
                                Integer newversion = Integer.valueof(temparray[temparray.size()-1])+1;
                                String newcontent = '<p><b> '+newversion+'. </b>'+contentDate.format('dd-MMM-YYYY\'T\'HH:mm:ss')+' '+UserInfo.getName()+' : '+ProjectsWithChangedDescriptionMap.get(projectId).Handover_from_SD_C__c+'-'+ProjectsWithChangedDescriptionMap.get(projectId).Reason_CPS__c+'</p>'+ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)).Content.toString();
                                ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)).title = 'Track for Reason Version '+newversion;
                                ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)).Content = Blob.valueof(newcontent);
                                ContentNotesToUpdate.add(ContentNotesMap.get(ProjectsDocumentMap.get(projnoteId)));
                                ProjectsCompleted.put(projnoteId.substring(0,18),'Update Completed');
                            }
                            
                        }
                        
                    }
                    else{
                        String newcontent ='<p><b> 1. </b>'+contentDate.format('dd-MMM-YYYY\'T\'HH:mm:ss')+' '+UserInfo.getName()+' : '+ProjectsWithChangedDescriptionMap.get(projectId).Handover_from_SD_C__c+'-'+ProjectsWithChangedDescriptionMap.get(projectId).Reason_CPS__c+'</p>';
                        ContentNote cnt = new ContentNote();
                        cnt.Content = Blob.valueof(newcontent);
                        cnt.Title = 'Track for Reason Version 1';
                        ContentNotesToInsert.add(cnt);
                        NewProjectDocumentMap.put(projectId,cnt);
                    }
                    
                }
                System.debug('This is ProjectsCompleted '+ProjectsCompleted);
                For(Id projectId:ProjectIdSet){
                    if(ProjectsCompleted.get(projectId)==null){
                        String newcontent ='<p><b> 1. </b>'+contentDate.format('dd-MMM-YYYY\'T\'HH:mm:ss')+' '+ProjectsWithChangedDescriptionMap.get(projectId).Handover_from_SD_C__c+'-'+ProjectsWithChangedDescriptionMap.get(projectId).Reason_CPS__c+'</p>';
                        ContentNote cnt = new ContentNote();
                        cnt.Content = Blob.valueof(newcontent);
                        cnt.Title = 'Track for Reason Version 1';
                        ContentNotesToInsert.add(cnt);
                        NewProjectDocumentMap.put(projectId,cnt);
                    }
                }
                
            }
            if(ContentNotesToUpdate.size()>0)
                Update ContentNotesToUpdate;
            if(ContentNotesToInsert.size()>0)
                insert ContentNotesToInsert;
            for(Id projectId:NewProjectDocumentMap.keyset()){
                ContentDocumentLink clnk = new ContentDocumentLink();
                clnk.LinkedEntityId = projectId;
                clnk.ContentDocumentId = NewProjectDocumentMap.get(projectId).Id;
                clnk.ShareType = 'I';					
                LinksToInsert.add(clnk);
            }
            if(LinksToInsert.size()>0)
                insert LinksToInsert;
            
        }
        RunCountForReason++;
        
        
    }
    
    public static void extendOppAccessToProject_PM_Manager(list<ProjectObject__c> projectList, Map<Id, ProjectObject__c> oldMap){
        list<ProjectObject__Share> projectShareList = new list<ProjectObject__Share>();
        List<Database.SaveResult> saveProjectShareResult = new List<Database.SaveResult>();
        list<Id> projectManagerList = new list<Id>();
        List<Group> managerGroupDetails = new List<Group>();
        Map<Id, Id> userWithGroupIdsMap = new Map<Id,Id>();
        Map<ProjectObject__c,Id> oldProjectSharing = new Map<ProjectObject__c,Id>();
        List<ProjectObject__Share> projectSharingToDelete = new List<ProjectObject__Share>();
        
        for(ProjectObject__c project : projectList){
            projectManagerList.add(project.Project_Manager__c);
        }
        String profileId = System.Label.CommercialProfileId;
        if(projectManagerList.size() > 0){
            //managerGroupDetails = [SELECT Id, RelatedId FROM Group WHERE Type = 'Manager' AND Related.IsActive = true AND RelatedId IN :projectManagerList AND Related.ProfileId != :profileId];
            managerGroupDetails = [SELECT Id, RelatedId FROM Group WHERE Type = 'Manager' AND Related.IsActive = true AND RelatedId IN :projectManagerList];
        }
        if(managerGroupDetails.size() > 0){
            for(Group grp : managerGroupDetails){
                userWithGroupIdsMap.put(grp.RelatedId,grp.Id);
            }
        }
        
        if(userWithGroupIdsMap.size() > 0){
            for(ProjectObject__c project : projectList){
                ProjectObject__Share projectShare = new ProjectObject__Share();
                if(oldMap != null && oldMap.size() > 0){
                    if(project.Project_Manager__c != null && oldMap.get(project.Id).Project_Manager__c != project.Project_Manager__c){
                        projectShare.AccessLevel = 'Edit';
                        projectShare.ParentId = project.Id;
                        projectShare.UserOrGroupId = userWithGroupIdsMap.get(project.Project_Manager__c);
                        projectShare.RowCause = Schema.ProjectObject__Share.RowCause.Share_with_Project_Manager_s_Manager__c;
                        projectShareList.add(projectShare);
                        oldProjectSharing.put(project, oldMap.get(project.Id).Project_Manager__c);
                    }
                    if(project.Project_Manager__c == null && oldMap.get(project.Id).Project_Manager__c != project.Project_Manager__c){
                        oldProjectSharing.put(project, oldMap.get(project.Id).Project_Manager__c);
                    }
                }else{
                    if(project.Project_Manager__c != null){
                        projectShare.AccessLevel = 'Edit';
                        projectShare.ParentId = project.Id;
                        projectShare.UserOrGroupId = userWithGroupIdsMap.get(project.Project_Manager__c);
                        projectShare.RowCause = Schema.ProjectObject__Share.RowCause.Share_with_Project_Manager_s_Manager__c;
                        projectShareList.add(projectShare);
                    }  
                } 
            }
        }
        if(oldProjectSharing.size() > 0){
            projectSharingToDelete = [SELECT Id FROM ProjectObject__Share 
                                      WHERE ParentId In :oldProjectSharing.keyset()
                                      AND RowCause=:Schema.ProjectObject__Share.RowCause.Share_with_Project_Manager_s_Manager__c];
            delete projectSharingToDelete;
        }
        if(projectShareList.size()>0){
            saveProjectShareResult = Database.insert(projectShareList,false);
        }
        
        if(saveProjectShareResult.size()>0){
            Integer i=0;
            for(Database.SaveResult sr : saveProjectShareResult){
                if(sr.isSuccess()){
                    System.debug('Success Id: '+ sr.getId());
                }else{
                    for(Database.Error err : sr.getErrors()){
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Project fields that causes error: ' + err.getFields());
                    }
                }
                i++;
            }
        }
    }

    /*public static void checkCancellationAndOnHoldReason(List<ProjectObject__c> NewProjectList,Map<Id, ProjectObject__c> oldMap){
        for(ProjectObject__c project : NewProjectList){
            String cancelledProjectStatus = System.Label.Project_Status_Cancelled;
            String onHoldProjectStatus = System.Label.Project_Status_On_Hold;
            if(project.Project_Status__c != null && project.Project_Status__c == cancelledProjectStatus && (oldMap == null || oldMap.get(project.Id).Project_Status__c != cancelledProjectStatus)){
                if(project.Cancellation_On_Hold_Reason__c != null 
                    && (project.Cancellation_On_Hold_Reason__c != '	Customer request due to budget' 
                    || project.Cancellation_On_Hold_Reason__c != 'Customer request due to requirement changes'
                    || project.Cancellation_On_Hold_Reason__c != 'Product suitability'
                    || project.Cancellation_On_Hold_Reason__c != 'Duplicate/variation'
                    || project.Cancellation_On_Hold_Reason__c != 'Customer availability - No response')){
                        project.Cancellation_On_Hold_Reason__c.addError('Cancellation Reason can not be other than Customer request due to budget,  if Project Status is Cancelled');
                }
                if(project.Cancellation_On_Hold_Reason__c == null){
                    project.Cancellation_On_Hold_Reason__c.addError('Cancellation Reason is required if Project Status is '+cancelledProjectStatus);
                }
            }
            if(project.Project_Status__c !=null && project.Project_Status__c == onHoldProjectStatus && (oldMap == null || oldMap.get(project.Id).Project_Status__c != onHoldProjectStatus)){
                if(project.Cancellation_On_Hold_Reason__c != null 
                    && (project.Cancellation_On_Hold_Reason__c != '	Customer Readiness - No response' 
                    || project.Cancellation_On_Hold_Reason__c != 'Customer Request - Other priorities'
                    || project.Cancellation_On_Hold_Reason__c != 'Product suitability/issues/roadmap'
                    || project.Cancellation_On_Hold_Reason__c != 'Back with Commercial – Scope creep / Other reasons')){
                        project.Cancellation_On_Hold_Reason__c.addError();
                }
                if(project.Cancellation_On_Hold_Reason__c == null){
                    project.Cancellation_On_Hold_Reason__c.addError('On Hold Reason is required if Project Status is '+ onHoldProjectStatus);
                }
            }
        }
    }*/
}