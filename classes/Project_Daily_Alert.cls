global class Project_Daily_Alert implements Database.Batchable <sobject> {
    
    global Database.QueryLocator start (Database.BatchableContext bc){
        
        Date dt = system.today();
        System.debug('Date:'+dt);
       // string recordId = 'a098E000009WnAVQA0';
        String query = 'Select id,Name, Opportunity__c,Opportunity__r.Name, Is_Auto_Created__c,LBU__c, CreatedDate from ProjectObject__c where CreatedDate = TODAY AND Is_Auto_Created__c =true ' ;
        
        System.debug('VK1: '+query);  
        return Database.getquerylocator(query);
        
    }
    //  global List<ProjectObject__c> ProjectList = new List <ProjectObject__c>();
   global void execute (Database.BatchableContext bc , List <ProjectObject__c> scope){
        set<Id> queueIdSet = new set<Id>();
        List<QueueSobject> QueueMembers = [SELECT Id, QueueId, Queue.Name FROM QueueSobject where Queue.name like 'PS Project Manager%'];
        for(QueueSobject qso: QueueMembers){
            queueIdSet.add(qso.QueueId);
        }
        
        List<groupMember> GroupMembers = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember where GroupId IN: queueIdSet];
        
        Set<Id> userIds = new Set<Id>();
        for(groupMember gm:GroupMembers){
            userIds.add(gm.UserOrGroupId);
        }
        
        List<User> users = [Select Id, Name, Email from user where Id IN: userIds and isactive=true];
        Map<Id,String> userToEmail = new Map<Id,String>();
        for(user usr: users){
            userToEmail.put(usr.Id, usr.Email);
        }
        
        Map<Id,List<String>>  QueueToMembersEmails = new Map<Id,List<String>>();
        Map<String,Id>  QueueToQueueName = new Map<String,Id>();
        for(QueueSobject qso: QueueMembers){
            List<String> EmailList = new List<String>();
            if((qso.Queue.Name).contains('CA1') ||(qso.Queue.Name).contains('US5')){
                //EmailList.add('ams-ps-requests@shl.com');
                EmailList.add('ravi.kant@shl.com');
            }
            else{
                for(groupMember gm:GroupMembers){
                    if(gm.GroupId == qso.queueId){
                        EmailList.add(userToEmail.get(gm.UserOrGroupId));
                    }
                }
            }
            QueueToMembersEmails.put(qso.queueId, EmailList);
            QueueToQueueName.put((qso.queue.name).right(3), qso.queueId);
        }
        
        Map<Id,List<String>> projectIdToEmails = new Map<Id,List<String>>();
        Set<Id> projectIds = new Set<Id>();
        for(ProjectObject__c pro: scope){
            projectIdToEmails.put(pro.Id, QueueToMembersEmails.get(QueueToQueueName.get(pro.LBU__c)));
            projectIds.add(pro.Id);
        }
        String projectalerturl;
        String domainURL = System.Label.Org_Domain_URL;
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        AggregateResult[] groupedResults = [Select LBU__c,Max(Id) from ProjectObject__c where id IN:projectIds group by LBU__c ];
        for (AggregateResult ar : groupedResults)  {
            if(ar.get('LBU__c')=='US5' || ar.get('LBU__c')=='CA1' || ar.get('LBU__c')=='CN1' || ar.get('LBU__c')=='HK1'){
       		projectalerturl = domainURL+'/lightning/r/Report/00O4G000007rS5sUAE/view?reportFilters=%5B%7B%22column%22%3A%22ProjectObject__c.LBU__c%22%2C%22value%22%3A%22'
                +ar.get('LBU__c')
                +'%22%2C%22operator%22%3A%22equals%22%2C%22isContextFilter%22%3Atrue%7D%5D';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(projectIdToEmails.get((Id) ar.get('expr0')));
            List<String> ccTo = new List<String>();
            email.setCcAddresses(ccTo);
            email.setSubject('Project Daily Summary Report');
         
            String body = 'Please click the below link to view the daily project summary report, <br/><br/> <a href ='+projectalerturl+'>Click here</a> Thanks.';
            email.setHtmlBody(body);
            
            emails.add(email);
            }
        }
       if(emails.size()>0){
          Messaging.sendEmail(emails); 
       } 
    }
    global void finish( Database.BatchableContext BC){
        
    }
    
}