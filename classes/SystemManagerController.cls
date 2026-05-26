public without sharing class SystemManagerController {
    
    @AuraEnabled
    public static List<Bureau_System__c> getBureauSystemDetails(String jobId,Integer limitSize,Integer offset) {
        System.debug('jobId ###'+jobId);
        try {
            list<Bureau_System__c> bureauSystemList = new list<Bureau_System__c>();
            bureauSystemList = [SELECT 	Id, 
                                System__r.Name,
                                System_Type__c,
                                System__r.System_Name__c, 
                                System__r.System_Client_ID__c,
                                System__r.System_Client_Name__c,
                                System__r.Is_Client_System__c,
                                System_URL__c,
                                System_Login__r.Name, 
                                Report_Language__c, 
                                Project_Id__c
                                FROM 	Bureau_System__c
                                WHERE	Bureau_Job__c = :jobId
                                LIMIT :limitSize
                                OFFSET :offset];
            System.debug('bureauSystemList #####'+bureauSystemList);
            return bureauSystemList;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<System__c> getAllSystems(String jobId, Integer limitSize, Integer offset) {
        
        System.debug('jobId ###'+jobId);
        try {
            list<System__c> systemList = new list<System__c>();
            
            Job__c jobRec = new Job__c();
            
            jobRec = [SELECT Id,
                      System_Used__c,
                      Opportunity__r.Account.Id 
                      FROM 	Job__c 
                      WHERE Id = :jobId
                      LIMIT 1];
            
            List<String> systemUsedList = jobRec.System_Used__c.split(';');
            
            systemList = [SELECT Id, 
                          Name,
                          System_Type__c,
                          System_Client_ID__c,
                          System_Name__c, 
                          System_Client_Name__c,
                          Is_Client_System__c,
                          System_URL__c
                          FROM 	System__c
                          WHERE (Account__c = :jobRec.Opportunity__r.Account.Id
                                 OR	RecordType.Name = 'SHL System')
                          AND 	System_Type__c IN :systemUsedList
                          Order by Account__c NULLS LAST
                          LIMIT :limitSize
                          OFFSET :offset];
            System.debug('systemList ###'+systemList);
            return systemList;
            
        } 
        catch (Exception e) {
            System.debug('e.getMessage() ###'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<System__c> getPreselectedSystem(List<String> systemNameList, String jobId) {
        System.debug('systemNameList ####'+systemNameList);
        List<System__c> systemList = [SELECT Id, Name FROM System__c WHERE Name IN :systemNameList];
        return systemList;
    }
    
    @AuraEnabled
    public static String createBureauSystem(List<System__c> systemList, String bureauSystem,
                                            String projectIdMap, String jobId) 
    {
        System.debug('projectIdMap ###'+projectIdMap);
        System.debug('System List from LWC ###'+systemList);
        String message = '';
        Map<String, String> nameprojectIdMap = new Map<String, String>();
        Map<String, Bureau_System__c> existingSystem = new Map<String, Bureau_System__c>();
        List<String> newSysList = new List<String>();
        List<Bureau_System__c> sysToDelete = new List<Bureau_System__c>();
        List<Bureau_System__c> sysToInsert = new List<Bureau_System__c>();
        List<Bureau_System__c> sysToUpdate = new List<Bureau_System__c>();
        
        List<BureauSystemData> bureauList  = (List<BureauSystemData>)System.JSON.deserialize(bureauSystem, List<BureauSystemData>.class);
        List<ProjectIdData> projectIdList  = (List<ProjectIdData>)System.JSON.deserialize(projectIdMap, List<ProjectIdData>.class);                                        
        Job__c jobRec = new Job__c();
        
        jobRec = [SELECT Id, (Select Id, Name, Report_Language__c, Project_Id__c,
                              System__r.Name FROM Bureau_Systems__r),System_Used__c
                  FROM 	Job__c 
                  WHERE Id = :jobId
                  LIMIT 1];
        
        for(Bureau_System__c bObj : jobRec.Bureau_Systems__r) {
            existingSystem.put(bObj.System__r.Name, bObj);
        }
        for(ProjectIdData obj : projectIdList) {
            System.debug('obj.name ###'+obj.name);
            System.debug('obj.projectId ###'+obj.projectId);
            nameprojectIdMap.put(obj.name, obj.projectId);
        }
        
        for(System__c sysObj : systemList) {
            
            if(!existingSystem.containsKey(sysObj.Name)) {
                System.debug('Record can be inserted');
                Bureau_System__c bureauObj = new Bureau_System__c();
                bureauObj.Bureau_Job__c = jobId;
                bureauObj.System__c = sysObj.Id;
                bureauObj.Project_Id__c = nameprojectIdMap.get(sysObj.Name);
                //Insert bureauObj;
                sysToInsert.add(bureauObj);
                if(sysObj.System_Type__c == jobRec.System_Used__c) {
                    jobRec.System_Client_ID__c = sysObj.System_Client_ID__c;
                    jobRec.System_URL__c = sysObj.System_URL__c;
                } 
                   
            }
            if(existingSystem.containsKey(sysObj.Name)) {
                System.debug('Record can be updated');
                Bureau_System__c bureauRec = existingSystem.get(sysObj.Name);
                if(bureauRec.Project_Id__c != nameprojectIdMap.get(sysObj.Name)) 
                {
                    System.debug('Reporting language or Project Id Updated');
                    Bureau_System__c bureauObj = new Bureau_System__c();
                    bureauObj.Id = bureauRec.Id;
                    bureauObj.Project_Id__c = nameprojectIdMap.get(sysObj.Name);
                    UPDATE bureauObj;
                }
            }
            
            newSysList.add(sysObj.Name);
        }
        try {
            INSERT sysToInsert;
            update jobRec;
        }
        catch(DMLException exp) {
            System.debug('Exception ####'+exp.getMessage());
            message = exp.getDmlMessage(0);
        }
        
        for(Bureau_System__c existing : existingSystem.values()) {
            if(!newSysList.contains(existing.System__r.Name)) {
                sysToDelete.add(existing);
            }
        }
        if(!sysToDelete.isEmpty()) {
            try {
                DELETE sysToDelete;
            }
            catch(Exception exp) {
                System.debug('Exception ####'+exp.getMessage());
            }
        }
        return message;
    }
    
    class BureauSystemData {
        String name;
        String lang;
    }
    
    class projectIdData {
        String name;
        String projectId;
    }
}