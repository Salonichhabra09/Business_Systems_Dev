/**************************************************************************************************************************************
CREATED BY :- PRIYANK ANAND  
CREATED DATE :- 19-08-2019
DESCRIPTION :- This class contains various validations and assignments on fields of different objects which are creating a event, this class is called in Event_Trigger.
***************************************************************************************************************************************/ 

Global class EventTriggerManager {
    
    //This method is updating the Opportunity_Stage__c field on the event object with the stage of related opportunity
    public static void UpdateOpportunityStage(List<Event> Events){
        map<ID,string> oppWhatIdMap = new map<ID,string>();
        String whatId;
        for(Event evt : Events)
        {
            whatId = evt.WhatId;
            // Abort if other kind of Event
            if(whatId != null && whatId.startsWith('006') && !oppWhatIdMap.keyset().contains(whatId))
            {
                // put whatId into set
                oppWhatIdMap.put(evt.whatId, null);
            }
        }
        if(oppWhatIdMap.size()!=null){
            for(Opportunity parentOpp : [Select Id, StageName from Opportunity where Id IN :oppWhatIdMap.keyset()])
            {
                oppWhatIdMap.put(parentOpp.Id, parentOpp.StageName);
            }
            for( Event evt : Events)
            {
                String whatId1 = evt.WhatId;
                if(whatId1 != null && whatId1.startsWith('006') && oppWhatIdMap.containsKey(whatId1))
                {
                    evt.Opportunity_Stage__c = oppWhatIdMap.get(evt.whatId);
                }
            }
        }
    }
    
    //This method is throwing errors on checking Event_Category__c and Event_Type__c fields on event object on Insert
    public static void CheckEventCategoryAndEventTypeOnInsert(List<Event> NewEvents){
        List<Event> eventList= new List<Event>();
        map<ID,string> oppWhatIdMap = new map<ID,string>();
        String whatId;
        for(Event evt : NewEvents)
        {
            whatId = evt.WhatId;
            // Abort if other kind of Event
            if(whatId != null && whatId.startsWith('006') && !oppWhatIdMap.keyset().contains(whatId))
            {
                // put whatId into set
                oppWhatIdMap.put(evt.whatId, null);
            }
        }
        if(oppWhatIdMap.size()>0){
            eventList= [SELECT id,StartDateTime, Event_Category__c, Event_Type__c,Status__c 
                        FROM Event 
                        WHERE  whatId in :oppWhatIdMap.keyset() 
                        AND Event_Category__c='First sales introduction' 
                        AND Event_Type__c='Sales' 
                        AND Status__c!='Cancelled'];
        }
        for(Integer i=0;i<NewEvents.size();i++)
        {
            if(eventList.size()>0){
                for( Event oppEvent : eventList){
                        if(NewEvents[i].Event_Category__c=='First sales introduction' && NewEvents[i].Event_Type__c=='Sales' && NewEvents[i].Status__c!='Cancelled' && oppEvent.StartDateTime.year()==NewEvents[i].StartDateTime.year())
                        {
                            NewEvents[i].addError('There can only be one event with Event Type = Sales and Event Sub Type = First Sales Interaction with Status other than Cancelled within the same year linked to the same opp.');
                        }
                    
                }   
            }
        }
        
    }
    
    //This method is throwing errors on checking Event_Category__c and Event_Type__c fields on event object on Update
    public static void CheckEventCategoryAndEventTypeOnUpdate(List<Event> NewEvents,List<Event> OldEvents){
        List<Event> eventList= new List<Event>();
        map<ID,string> oppWhatIdMap = new map<ID,string>();
        String whatId;
        for(Event evt : NewEvents)
        {
            whatId = evt.WhatId;
            // Abort if other kind of Event
            if(whatId != null && whatId.startsWith('006') && !oppWhatIdMap.keyset().contains(whatId))
            {
                // put whatId into set
                oppWhatIdMap.put(evt.whatId, null);
            }
        }
        if(oppWhatIdMap.size()>0){
            eventList= [SELECT id,StartDateTime, Event_Category__c, Event_Type__c,Status__c 
                        FROM Event 
                        WHERE  whatId in :oppWhatIdMap.keyset() 
                        AND Event_Category__c='First sales introduction' 
                        AND Event_Type__c='Sales' 
                        AND Status__c!='Cancelled'];
        }
        for(Integer i=0;i<NewEvents.size();i++)
        {
            if(eventList.size()>0){
                for( Event oppEvent : eventList){
                    if((NewEvents[i].Status__c!=OldEvents[i].Status__c && oppEvent.id != NewEvents[i].id ) || NewEvents[i].StartDateTime.year()!=OldEvents[i].StartDateTime.year())
                    {
                        if(NewEvents[i].Event_Category__c=='First sales introduction' && NewEvents[i].Event_Type__c=='Sales' && NewEvents[i].Status__c!='Cancelled' && oppEvent.StartDateTime.year()==NewEvents[i].StartDateTime.year())
                        {
                            NewEvents[i].addError('There can only be one event with Event Type = Sales and Event Sub Type = First Sales Interaction with Status other than Cancelled within the same year linked to the same opp.');
                        }
                    }
                }   
            }
        }
    }
    
    //This method is updating Target_Date__c field of event depending on different  conditions
    public static void UpdateTargetDate(List<Event> Events){
        Map<Id,Opportunity>idAndROpp = new Map<Id,Opportunity>();
        Map<Id,Opportunity>idAndOpp = new Map<Id,Opportunity>();
        Map<Id,Id>OandCMap = new Map<Id,Id>();
        Set<Id>OrignalNonRenID = new Set<id>();
        Set<Id>setOfIds = new Set<Id>();
        Set<string>setOfeventtype = new Set<string>(); 
        Set<string>setOfeventcategory = new Set<string>();
        for(event e : Events){
            setOfIds.add(e.WhatId);
            setOfeventtype.add(e.Event_Type__c);
            setOfeventcategory.add(e.Event_Category__c);
        }
        Map<Id,List<Contract_Line__c>>mapOfCandCL = new Map<Id,List<Contract_Line__c>>();
        if(setOfeventtype.contains('Account Management') && setOfeventcategory.contains('Onboarding'))
        {
            for(Opportunity orr : [select id,Original_Opportunity__r.id,Business_Type__c  from opportunity where Business_Type__c ='Renewal' AND Original_Opportunity__r.id!=null AND StageName!=null AND CreatedDate>=2014-01-01T00:00:00Z AND Id IN:setOfIds ]){
                idAndROpp.put(orr.id,orr);
                OrignalNonRenID.add(orr.Original_Opportunity__r.Id);
            }
            for(Opportunity orr : [select id,Original_Opportunity__r.id,Business_Type__c  from opportunity where  CreatedDate>=2014-01-01T00:00:00Z AND StageName!=null AND Id IN:setOfIds ]){
                idAndOpp.put(orr.id,orr);
            }
            for(opportunity c : [select id,name,Order_Number__r.id,Business_Type__c from opportunity where Business_Type__c!='Renewal' AND CreatedDate>=2014-01-01T00:00:00Z AND Order_Number__r.id!=null AND Id IN:OrignalNonRenID]){
                OAndCMap.put(c.id,c.Order_Number__r.id); 
            }
        }   
            for(Contract_Line__c cli :[select id,Start_date__c,Contract__r.id from Contract_Line__c where Contract__r.Opportunity__c IN :OrignalNonRenID AND IM_Lookup_Code__c like '%Subscription%' order by start_date__c ASC]){
             // for(Contract_Line__c cli :[select id,Start_date__c,Contract__r.id from Contract_Line__c where   IM_Lookup_Code__c like '%Subscription%'  order by start_date__c ASC]){ // commented by Pankhuri on 22/5/2020 due to SOQL query Limit
                if(mapofCAndCl.containsKey(cli.contract__r.id)){
                    mapOfCAndCl.get(cli.contract__r.id).add(cli);
                }else{
                    mapOfCAndCl.put(cli.contract__r.id,new List<contract_line__c>{cli});
                }
            }   
        //}
        System.debug('Map of Contract and Contract Line Item is'+mapofCAndCl);
        for(event e :Events){
            if(e.Event_Type__c=='Account Management' && e.Event_Category__c=='Onboarding' && e.NBB_CrossSell_Events__c == false){
                System.debug('The wid is'+e.Whatid); 
                if(idAndROpp.keySet().contains(e.WhatId)){
                    if(idAndROpp.get(e.WhatId).Business_Type__c!='Renewal'){
                        //e.Target_Date__c= Date.Today();
                    }else{
                        if(idAndROpp.get(e.WhatId).Original_Opportunity__r.id!=null){
                            System.debug('the final value 1 is'+idAndROpp.get(e.WhatId).Original_Opportunity__r.id);       
                            if(OAndCMap.keySet().contains(idAndROpp.get(e.WhatId).Original_Opportunity__r.id)){
                                System.debug('the final value 2 is'+OAndCMap.get(idAndROpp.get(e.WhatId).Original_Opportunity__r.id));
                                if(mapOfCAndCl.keySet().contains(OAndCMap.get(idAndROpp.get(e.WhatId).Original_Opportunity__r.id))){    
                                    System.debug('the final value 3 is'+mapOfCAndCl.get(OAndCMap.get(idAndROpp.get(e.WhatId).Original_Opportunity__r.id))); 
                                    e.Target_Date__c=mapOfCAndCl.get(OAndCMap.get(idAndROpp.get(e.WhatId).Original_Opportunity__r.id))[0].Start_Date__c;
                                }
                                else{
                                    e.Target_Date__c= Date.Today();
                                }
                            }else{
                                e.Target_Date__c= Date.Today();
                            }
                        }else{
                            System.debug('The opportunity do not have any renewal opportunity with it');
                            e.Target_Date__c= Date.Today();
                        }
                    } 
                }
                else{
                    if(idAndOpp.keySet().contains(e.WhatId)){
                        if(idAndOpp.get(e.WhatId).Business_Type__c =='Renewal' && idAndOpp.get(e.WhatId).Original_Opportunity__r.id==null){
                            e.Target_Date__c= Date.Today();
                        }
                    }
                }
            } 
        }
    }
    
    //This method is sending email if user is part of 'MultiUserCalendar Users' group and Send_email_to_assignee__c field is set to true
    public static void SendMail(List<Event> NewEvents,List<Event> OldEvents){
        Group muGroup = [Select Id,(Select UserOrGroupId from GroupMembers) FROM Group WHERE Name in('MultiUserCalendar Users') ];
        Set<Id> userIds = new Set<Id>();
        for(GroupMember member: muGroup.GroupMembers)
            userIds.add(member.UserOrGroupId);
        for(Integer i=0; i<NewEvents.size();i++)
        {
            if(NewEvents[i].Send_email_to_assignee__c && userIds.contains(NewEvents[i].OwnerId))
            {
                if(NewEvents[i].StartDateTime != OldEvents[i].StartDateTime || NewEvents[i].EndDateTime<> OldEvents[i].EndDateTime || NewEvents[i].OwnerId<> OldEvents[i].OwnerId)
                {   
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();      
                    mail.setTargetObjectId(NewEvents[i].OwnerId);   
                    mail.setWhatId(NewEvents[i].Id);  
                    mail.saveAsActivity = false;
                    mail.setTemplateId(System.Label.Event_SendEmailToAssignee);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
        }
    }
    
    //This method is updating Total_Booked_Hours__c field on project object.
    public static void UpdateTotalBookedHours(List<Event> Events){
        set <id>projectidset= new set<id>();
        Id selectedRecordType = Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
        for(event ev :Events)
            projectidset.add(ev.whatId);
        List<ProjectObject__c> updatedProjectList = new List<ProjectObject__c>();
        for(ProjectObject__c proj :[select id,Total_Booked_Hours__c,(select id,Hours_work__c from Events) from ProjectObject__c where ID IN: projectidset and RecordTypeId = :selectedRecordType ]){
            Decimal  i=0;
            for(Event evnt : proj.Events){
                if(evnt.Hours_work__c != null)
                    i += evnt.Hours_work__c;
            }
            if(i!=0)
                proj.Total_Booked_Hours__c = i/7.5;
            else
                proj.Total_Booked_Hours__c = i;
            updatedProjectList.add(proj);
        }
        if(updatedProjectList.size()>0)
            update updatedProjectList;
        
    }

    //This method is to update progress on strategy
    public static void updateCreatedActivitiesOnStrategy(List<Event> Events){
        
        List<Event> eventToProcess = new List<Event>();
        Set<Id> strategyIds = new Set<Id>();

        for (Event event : Events) {
            if(event.whatId!=null && event.WhatId.getSObjectType().getDescribe().getName()=='Strategy_and_Goal__c'){
                eventToProcess.add(event);
                strategyIds.add(event.WhatId);
            }
        }

        if(eventToProcess.size()>0){
            List<Strategy_and_Goal__c> strategyList = [SELECT Id,Number_Of_Tasks_Created__c,Number_of_tasks_completed__c FROM Strategy_and_Goal__c WHERE Id IN :strategyIds];
            Map<Id,Integer> strategyMap = new Map<Id,Integer>();
            Map<Id,Integer> completedEventStrategyMap = new Map<Id,Integer>();
            for (Event event : eventToProcess) {
                if(strategyMap.get(event.WhatId)==null){
                    strategyMap.put(event.whatId,1);
                }else{
                    strategyMap.put(event.whatId,strategyMap.get(event.whatId)+1);
                }
                if(completedEventStrategyMap.get(event.WhatId)==null && event.Status__c.contains('Completed')){
                    completedEventStrategyMap.put(event.whatId,1);
                }else if(completedEventStrategyMap.get(event.WhatId)!=null && event.Status__c.contains('Completed')){
                    completedEventStrategyMap.put(event.whatId,completedEventStrategyMap.get(event.whatId)+1);
                }
            }
            List<Strategy_and_Goal__c> strategyToUpdate = new List<Strategy_and_Goal__c>();
            for (Strategy_and_Goal__c strategy : strategyList) {
                Strategy_and_Goal__c str = new Strategy_and_Goal__c();
                str.Id = strategy.Id;
                str.Number_Of_Tasks_Created__c = strategy.Number_Of_Tasks_Created__c + strategyMap.get(strategy.Id);
                if(completedEventStrategyMap.get(strategy.Id)!=null){
                    str.Number_of_tasks_completed__c = strategy.Number_of_tasks_completed__c + completedEventStrategyMap.get(strategy.Id);
                }
                strategyToUpdate.add(str);
            }
            
            if(strategyToUpdate.size()>0){
                update strategyToUpdate;
            }
        }
    }

    //This method is to update progress on strategy when end date is changed for events and they were marked completed on backend
    public static void updateCompletedActivitiesOnStrategy(List<Event> Events,Map<Id,Event> EventOldMap){
        
        List<Event> eventToProcess = new List<Event>();
        Set<Id> strategyIds = new Set<Id>();

        for (Event event : Events) {
            system.debug(event.EndDateTime.date());
            system.debug(EventOldMap.get(event.id).EndDateTime.date());
            if(event.whatId!=null && event.WhatId.getSObjectType().getDescribe().getName()=='Strategy_and_Goal__c' && ((event.EndDateTime.date()> EventOldMap.get(event.id).EndDateTime.date()) && event.EndDateTime.date()>=System.today()) && (event.Is_Completed__c==true && EventOldMap.get(event.id).Is_Completed__c==true)){
                eventToProcess.add(event);
                strategyIds.add(event.WhatId);
            }
        }

        if(eventToProcess.size()>0){
            List<Strategy_and_Goal__c> strategyList = [SELECT Id,Number_Of_Tasks_Completed__c FROM Strategy_and_Goal__c WHERE Id IN :strategyIds];
            Map<Id,Integer> strategyMap = new Map<Id,Integer>();
            List<Event> eventToUpdate = new List<Event>();
            for (Event event : eventToProcess) {
                if(strategyMap.get(event.WhatId)==null){
                    strategyMap.put(event.whatId,1);
                }else{
                    strategyMap.put(event.whatId,strategyMap.get(event.whatId)+1);
                }
                Event eve = new Event();
                eve.Id = event.Id;
                eve.Is_Completed__c = false;
                eventToUpdate.add(eve);
            }
            List<Strategy_and_Goal__c> strategyToUpdate = new List<Strategy_and_Goal__c>();
            for (Strategy_and_Goal__c strategy : strategyList) {
                Strategy_and_Goal__c str = new Strategy_and_Goal__c();
                str.Id = strategy.Id;
                str.Number_Of_Tasks_Completed__c = strategy.Number_Of_Tasks_Completed__c - strategyMap.get(strategy.Id);
                strategyToUpdate.add(str);
            }
            
            if(strategyToUpdate.size()>0){
                update strategyToUpdate;
            }
        }
    }

    //This method is to update progress on strategy when end date is changed for events and they were marked completed on backend
    public static void updateDeletedActivitiesOnStrategy(List<Event> Events){
        
        List<Event> eventToProcess = new List<Event>();
        Set<Id> strategyIds = new Set<Id>();

        for (Event event : Events) {
            if(event.whatId!=null && event.WhatId.getSObjectType().getDescribe().getName()=='Strategy_and_Goal__c'){
                eventToProcess.add(event);
                strategyIds.add(event.WhatId);
            }
        }

        if(eventToProcess.size()>0){
            List<Strategy_and_Goal__c> strategyList = [SELECT Id,Number_Of_Tasks_Completed__c,Number_Of_Tasks_Created__c FROM Strategy_and_Goal__c WHERE Id IN :strategyIds];
            Map<Id,Integer> strategyMap = new Map<Id,Integer>();
            Map<Id,Integer> completedEventStrategyMap = new Map<Id,Integer>();
            for (Event event : eventToProcess) {
                if(strategyMap.get(event.WhatId)==null){
                    strategyMap.put(event.whatId,1);
                }else{
                    strategyMap.put(event.whatId,strategyMap.get(event.whatId)+1);
                }
                if(completedEventStrategyMap.get(event.WhatId)==null && event.Is_Completed__c==true){
                    completedEventStrategyMap.put(event.whatId,1);
                }else if(completedEventStrategyMap.get(event.WhatId)!=null && event.Is_Completed__c==true){
                    completedEventStrategyMap.put(event.whatId,completedEventStrategyMap.get(event.whatId)+1);
                }
            }
            List<Strategy_and_Goal__c> strategyToUpdate = new List<Strategy_and_Goal__c>();
            for (Strategy_and_Goal__c strategy : strategyList) {
                Strategy_and_Goal__c str = new Strategy_and_Goal__c();
                str.Id = strategy.Id;
                str.Number_Of_Tasks_Created__c = strategy.Number_Of_Tasks_Created__c - strategyMap.get(strategy.Id);
                if(completedEventStrategyMap.get(strategy.Id)!=null){
                    str.Number_of_tasks_completed__c = strategy.Number_of_tasks_completed__c - completedEventStrategyMap.get(strategy.Id);
                }
                strategyToUpdate.add(str);
            }
            
            if(strategyToUpdate.size()>0){
                update strategyToUpdate;
            }
        }
    }

    /*public static void UpdateCompletedEventsOnStrategy(List<Event> events,Map<id,Event> eventOldMap){

        List<Event> eventToProcess = new List<Event>();
        Set<Id> strategyIds = new Set<Id>();

        for (Event event : events) {
            if(event.whatId!=null && event.WhatId.getSObjectType().getDescribe().getName()=='Strategy_and_Goal__c' && event.Status__c.contains('Completed') && !eventOldMap.get(event.Id).Status__c.contains('Completed') && event.Is_Completed__c!=true){
                eventToProcess.add(event);
                strategyIds.add(event.WhatId);
            }
        }

        if(eventToProcess.size()>0){
            List<Strategy_and_Goal__c> strategyList = [SELECT Id,Number_of_tasks_completed__c FROM Strategy_and_Goal__c WHERE Id IN :strategyIds];
            Map<Id,Integer> strategyMap = new Map<Id,Integer>();
            for (Event event : eventToProcess) {
                if(strategyMap.get(event.WhatId)==null){
                    strategyMap.put(event.whatId,1);
                }else{
                    strategyMap.put(event.whatId,strategyMap.get(event.whatId)+1);
                }
            }
            List<Strategy_and_Goal__c> strategyToUpdate = new List<Strategy_and_Goal__c>();
            for (Strategy_and_Goal__c strategy : strategyList) {
                Strategy_and_Goal__c str = new Strategy_and_Goal__c();
                str.Id = strategy.Id;
                str.Number_of_tasks_completed__c = strategy.Number_of_tasks_completed__c + strategyMap.get(strategy.Id);
                strategyToUpdate.add(str);
            }
            
            if(strategyToUpdate.size()>0){
                update strategyToUpdate;
            }
        }
        
    }*/
    
     //Added by Prachi SSE-21600
    public static void UpdateContactTask(List<event> eventList ,Map<id,event> eventOldMap){
        
        List<Contact> contactsToProcess = new List<Contact>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id,String> contactSubject = new Map<Id,String>();
        Map<Id,DateTime> contactDate = new Map<Id,DateTime>();
        Map<Id,DateTime> currentContactDateTime = new Map<Id,DateTime>();
        
       
        if(eventList.size() > 0){
        for (Event ev : eventList) {
            if(eventOldMap!=null){
                if(ev.WhoId!=null && 
                   ev.WhoId.getSObjectType().getDescribe().getName()=='Contact' && 
                   (ev.WhoId!=eventOldMap.get(ev.Id).whoId)){
                    contactIds.add(ev.WhoId);
                    contactSubject.put(ev.whoId,ev.Subject);
                    contactDate.put(ev.whoId,ev.CreatedDate);
                } 
            }else{
                if(ev.WhoId!=null && ev.WhoId.getSObjectType().getDescribe().getName()=='Contact'){
                    contactIds.add(ev.WhoId);
                    contactSubject.put(ev.whoId,ev.Subject);
                    contactDate.put(ev.whoId,ev.CreatedDate);
                }
            }
        }
    }
        if(contactIds.size()>0){
            List<Contact> conList = [Select id, Last_Activity_Happen__c from Contact where id in: contactIds];
            for(Contact c : conList){
                
                 currentContactDateTime.put(c.id,c.Last_Activity_Happen__c);
            }
           
            for (Id conId : contactIds) {
                Contact con = new Contact();
                if(currentContactDateTime.get(conId) < contactDate.get(conId)  || currentContactDateTime.get(conId) == null){
                con.Id = conId;
                con.AutomationBypassDateTime__c = System.Now();
                con.Last_Activity_Happen__c = contactDate.get(conId);
                con.Subject_Discussed__c = contactSubject.get(conId);
                contactsToProcess.add(con);   
                }
                
            }
        }
        
        update contactsToProcess;
        
        
    }
}