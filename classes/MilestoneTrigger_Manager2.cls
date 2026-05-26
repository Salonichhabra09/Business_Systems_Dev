global class MilestoneTrigger_Manager2{

    // To update following fields value: Milestone_Sign_Off_Name__c,Milestone_Code_Lookup__c,Track_change__c ,Track_changes_history__c ,FC_Sign_Off_Name__c ,FC_Sign_Off_Date__c 
    // To send an email to milestone watcher.
    // Restriction on update and throw error if financial period is closed.
    
    public static void MilestoneBeforeUpdateChecks(List<Milestone__c> MilestoneNewList,List<Milestone__c> MilestoneOldList,map<id, Milestone__c> MilestoneOldMap,map<id, Milestone__c> MilestoneNewMap){
        
        Set<String> serviceTypeSet = new Set<String>();
        Set<String> milestoneCodeSet = new Set<String>();
        List<User> userList = [Select id,Profile.Name ,Name from User where id = :UserInfo.getUserId()];
        Set<Id> projectIdsSet = new Set<Id>(); 
        Set<Id> milestoneIdsSet = new Set<Id>();
        Map<String, Schema.SObjectField> fieldSet = Milestone__c.sObjectType.getDescribe().fields.getMap();
        Map<String,String> fieldApiNameLabelMap = new Map<String,String>();
        String trackChangeHistory = 'Track_changes_history__c';
        
        for(String str : fieldSet.KeySet()){
          Schema.DescribeFieldResult fieldDetails = fieldSet.get(str).getDescribe();
          fieldApiNameLabelMap.put(str,fieldDetails.getLabel()+':'+fieldDetails.getRelationshipName());
          system.debug('*Mansha***='+fieldDetails.getLabel()+'****='+fieldDetails.getRelationshipName());
        }
        Set<Id> updatedMilestonePeriodIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();
        
        for(Milestone__c mls : MilestoneNewList){
            
            if(mls.Milestone_Period__c != MilestoneOldMap.get(mls.Id).Milestone_Period__c){
                
                if(mls.Milestone_Period__c != null)
                    updatedMilestonePeriodIds.add(mls.Milestone_Period__c);
                
                if(MilestoneOldMap.get(mls.Id).Milestone_Period__c != null)
                    updatedMilestonePeriodIds.add(MilestoneOldMap.get(mls.Id).Milestone_Period__c);
                
            }
            if(mls != MilestoneOldMap.get(mls.Id)){
                projectIds.add(mls.Project__c);
            }
            if(mls.Service_Type2__c!=null && mls.Milestone_Code2__c!=null){
                serviceTypeSet.add(mls.Service_Type2__c);
                milestoneCodeSet.add(mls.Milestone_Code2__c);
            }           
        }
        Map<String,Id> milestoneCodeMap = new Map<String,Id>();
        for(Milestone_Code__c milestoneCode : [Select id,Service_Type__c,Milestone__c from Milestone_Code__c
                                               where Service_Type__c in :serviceTypeSet and Milestone__c in :milestoneCodeSet])
        milestoneCodeMap.put(milestoneCode.Service_Type__c+milestoneCode.Milestone__c,milestoneCode.id);
        System.debug('*****milestoneCodeMap****'+milestoneCodeMap);
        Map<Id,ProjectObject__c> projectIdMap = new Map<Id,ProjectObject__c>([select name ,Account__c, Account__r.name from ProjectObject__c where id IN:projectIds]);
        Map<id,Milestone_Period__c> updatedMilestonePeriodNameMap=new Map<id,Milestone_Period__c>([select id , name from Milestone_Period__c where id =:updatedMilestonePeriodIds ]);
        Map<Id,String> emailBodyListMap = new Map<Id,String>();
        for(Integer i=0;i<MilestoneNewList.size();i++){
            if(MilestoneNewList[i].Is_Signed__c!= MilestoneOldList[i].Is_Signed__c && MilestoneNewList[i].Is_Signed__c == true){
                MilestoneNewList[i].Milestone_Sign_Off_Name__c = UserInfo.getUserId();
            } 
            if(MilestoneNewList[i].Service_Type2__c!=null && MilestoneNewList[i].Milestone_Code2__c!=null){            
                MilestoneNewList[i].Milestone_Code_Lookup__c = milestoneCodeMap.get(MilestoneNewList[i].Service_Type2__c+MilestoneNewList[i].Milestone_Code2__c);
            }   
            //Below code added against the CRI-1197
            if(MilestoneNewList[i] != MilestoneOldList[i]){
                milestoneIdsSet.add(MilestoneNewList[i].id);
                
                //  --- CRI-1294 by Mansha --          
                String args = ' Hi, <br/><br/> There has been an update to Milestone <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+MilestoneNewList[i].Id+'">'+MilestoneNewList[i].name+'</a> on project <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+projectIdMap.get(MilestoneNewList[i].project__c).Id+'">'+projectIdMap.get(MilestoneNewList[i].project__c).Name+'</a> for Account <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+projectIdMap.get(MilestoneNewList[i].project__c).Account__c+'">'+projectIdMap.get(MilestoneNewList[i].project__c).Account__r.name+'</a> . Here are the details - <br/><br/>';
                args +='<table cellspacing="5" cellpadding="5" width="100%" bgcolor="#CDE8F0"><tr style="font-weight:bold;"><td>Changed Field</td><td>Old Value</td><td>New Value</td></tr>';
                           
                for( string fieldnames : fieldApiNameLabelMap.KeySet()) {
                   if(!fieldnames.equalsIgnoreCase('Month__c') && !fieldnames.equalsIgnoreCase('Milestone_Period_Date__c')){
                       List<String> str = fieldApiNameLabelMap.get(fieldnames).split(':');
                       //This condition is only added to append the updated Track Change to Track Change History for email.
                       if(str[1].indexOf('__r') == -1 || str[1] == 'Milestone_Period__r'){
                       
                            
                           if(fieldnames.equalsIgnoreCase(trackChangeHistory)){
                                if(MilestoneNewList[i].Track_change__c!=MilestoneOldMap.get(MilestoneNewList[i].id).Track_change__c){
                                    args +='<tr><td>'+str[0]+'</td><td>' + MilestoneOldMap.get(MilestoneNewList[i].id).get(fieldnames) + '</td><td>'+ MilestoneNewList[i].get(fieldnames)+'\n'+userList[0].Name+'('+System.now()+')'+'\n'+MilestoneNewList[i].Track_change__c+'</td></tr>';
                                }
                           }else{
                               if(MilestoneNewList[i].get(fieldnames)!=MilestoneOldMap.get(MilestoneNewList[i].id).get(fieldnames)){
                                    String oldValue=String.valueOf(MilestoneOldMap.get(MilestoneNewList[i].id).get(fieldnames));
                                    String newValue=String.valueOf(MilestoneNewList[i].get(fieldnames));
                                    if(str[1] == 'Milestone_Period__r'){
                                        system.debug('@@@@@'+newValue );
                                        system.debug('%%%%%'+oldValue );
                                        system.debug('&&&&&'+MilestoneOldMap.get(MilestoneNewList[i].id).get(fieldnames));
                                        if(newValue != null)
                                            newValue = updatedMilestonePeriodNameMap.get(String.valueOf(MilestoneNewList[i].get(fieldnames))).Name;
                                        else
                                            newValue='';
                                        if(oldValue != null)
                                           
                                             oldValue = updatedMilestonePeriodNameMap.get(String.valueOf(MilestoneOldMap.get(MilestoneNewList[i].id).get(fieldnames))).Name;
                                        else
                                            oldValue = '';
                                    }
                                                                  
                                   args +='<tr><td>'+str[0]+'</td><td>' + oldValue + '</td><td>'+newValue+'</td></tr>';
                                }
                            }
                          
                        }
                    }
                }
                args +='</table>';
                emailBodyListMap.put(MilestoneNewList[i].id,args);
                //--END CRI-1294--
            }
            
            //End code change for CRI-1197
            /*if(MilestoneNewList[i].FC_Sign_Off__c!=MilestoneOldList[i].FC_Sign_Off__c && MilestoneNewList[i].FC_Sign_Off__c==true){
                projectIdsSet.add(MilestoneNewList[i].Project__c);
            }*/
            //if(userList[0].Profile.Name!='New Finance')
            //As we no longer use New Finance profile so adding in custom permission check instead - Saloni on 09/02/2026 as HP change
            if(!FeatureManagement.checkPermission('Modify_Milestone_if_Financial_Period_Closed')){
                //if(MilestoneOldList[i].Is_Signed__c!= MilestoneNewList[i].Is_Signed__c && MilestoneNewList[i].Is_Signed__c && MilestoneNewList[i].Financial_Period_Closed__c)
                if(MilestoneOldList[i].Is_Signed__c!= MilestoneNewList[i].Is_Signed__c && MilestoneNewList[i].Financial_Period_Closed__c){
                    MilestoneNewList[i].addError('Milestone can not be signed or unsigned when financial period is closed.');
                }
                else if(MilestoneOldList[i].Financial_Period_Closed__c && (MilestoneOldList[i].Is_Signed__c || MilestoneNewList[i].Is_Signed__c)){
                    MilestoneNewList[i].addError('Any kind of update is not allowed on milestones when financial period is closed and milestone signed');
                }
            }
        }
      
        //Map<Id,ProjectObject__c> projectMap = new Map<Id,ProjectObject__c>([Select id,Project_Manager__c from ProjectObject__c where id=:projectIdsSet]);
        for(Integer i=0;i<MilestoneNewList.size();i++){
        
            // CRI-1197-- Mansha Ajmani--- code started..
            
            if(MilestoneNewList[i].Track_change__c!=MilestoneOldList[i].Track_change__c){
                if(MilestoneNewList[i].Track_changes_history__c == null)
                    MilestoneNewList[i].Track_changes_history__c = '';
                MilestoneNewList[i].Track_changes_history__c += '\n'+userList[0].Name+'('+System.now()+')'+'\n'+MilestoneNewList[i].Track_change__c;
                MilestoneNewList[i].Track_change__c =null;
            }        
            //Code change end.
            /*if(MilestoneNewList[i].FC_Sign_Off__c!=MilestoneOldList[i].FC_Sign_Off__c && MilestoneNewList[i].FC_Sign_Off__c==true){
               MilestoneNewList[i].FC_Sign_Off_Name__c = UserInfo.getUserId();
               MilestoneNewList[i].FC_Sign_Off_Date__c = Date.today();
            }*/
            
        }
                     
        // CRI-1197-- Mansha Ajmani--- code started..
      /*  
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        List<Milestone__c> milestoneList = [Select id,Name,(select owner.email,ownerId,User__r.email,User__c from Milestone_watchers__r) from Milestone__c where id in :milestoneIdsSet];
        EmailTemplate et=[Select id,Body,subject from EmailTemplate where name='Milestone Update' LIMIT 1];
        for(Milestone__c milstone : milestoneList){       
            string templateHTMLBody = et.Body;
            templateHTMLBody =templateHTMLBody.replace('- {!Milestone__c.Name}','<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+milstone.Id+'" >'+milstone.Name+'</a> ');
            templateHTMLBody =templateHTMLBody.replace('{!Milestone__c.Name}',milstone.Name);  
            List<String> toAddresses = new List<String>();
            //Added by Anjali for SSE-4818 starts here
            List<string> milestoneDistListEmail = Utility.getMilestoneWatcheremail();
            Boolean mwatcherchked = Utility.getMWatcherChecked();
            
            if((MilestoneNewMap.get(milstone.id).BU__c == 'CA1' || MilestoneNewMap.get(milstone.id).BU__c == 'US5') && mwatcherchked == true) {
                if(milestoneDistListEmail != null && milestoneDistListEmail.size()>0) {                
                    for(string s : milestoneDistListEmail) {                   
                        toAddresses.add(s); 
                    }
                }                   
            }
      
            if(milstone.Milestone_watchers__r.size()>0 || toAddresses.size()>0){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.saveAsActivity = false;
                
                for(Milestone_watcher__c milestoneWatcher : milstone.Milestone_watchers__r){
                    toAddresses.add(milestoneWatcher.User__r.email);
                    mail.setTargetObjectId(milestoneWatcher.User__c);
                    System.Debug('******'+mail);
                    
                }
               
                mail.setSubject(et.Subject);
                mail.setToAddresses(toAddresses);             
                mail.setHtmlBody(emailBodyListMap.get(milstone.id));
                allMails.add(mail);
                System.debug(''+allMails);
            }
        }  
        
        Messaging.sendEmail( allMails ); */
   }
}