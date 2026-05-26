global with sharing class ExportCandidateData implements Database.Batchable<sObject>, Database.Stateful{

    global final String finalQuery;
    global Job__c job;
    global String outputText;
    global Integer processedRecordsCount = 0;
    global String jobRecordTypeName;
    global List<Bureau_System__c> bureauSystemsList;
    global Boolean isExecuteCalled = false;
    global Integer count = 0;
    
    global ExportCandidateData(Job__c jb, Integer count1) {
        job = jb;
        count = count1;
        String query;
        
        query='SELECT Id,Name,First_Name__c,Last_Name__c,Email__c,Phone_Number__c,Country__c,Language__c,Gender__c,Reports_Status__c,Status2__c,Username__c,Product_Assessment__c,System_s__c,Email_as_Username__c,Username_New__c,isExported__c';
        query+=' FROM Bureau_Candidate__c where Bureau_Job__c=\''+job.Id+'\'';
        query+=' AND isExported__c = false';
        query+=' LIMIT 26000';
        
        finalQuery = query;

        List<String> columnHeaderList;
            columnHeaderList = new List<String>{'Record ID','First Name','Last Name','Email Address','Gender','Phone Number','Country','Language','Status','Report Status','Username','Product/Assessment','System(s)','Email as Username?'};
            outputText = '';
            outputText += columnHeaderList[0];
            for(Integer j=1; j<columnHeaderList.size();j++)
                outputText += ','+columnHeaderList[j];
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
      return Database.getQueryLocator(finalQuery);
    }
   
    global void execute(Database.BatchableContext BC,List<Bureau_Candidate__c> scope)
    {
        if(Limits.getHeapSize() < 0.9*Limits.getLimitHeapSize()) {
        for(Bureau_Candidate__c s : scope)
            {
                isExecuteCalled = true;
                processedRecordsCount += 1;

                outputText += '\r\n'+s.get('id');
                outputText += ','+s.get('First_Name__c');
                outputText += ','+(s.get('Last_Name__c')==null?'':s.get('Last_Name__c'));
                outputText += ','+s.get('Email__c');
                outputText += ','+(s.get('Gender__c')==null?'':s.get('Gender__c'));
                outputText += ','+(s.get('Phone_Number__c')==null?'':s.get('Phone_Number__c'));
                outputText += ','+(s.get('Country__c')==null?'':s.get('Country__c'));
                outputText += ','+(s.get('Language__c')==null?'':s.get('Language__c'));
                outputText += ','+(s.get('Status2__c')==null?'':s.get('Status2__c'));
                outputText += ','+(s.get('Reports_Status__c')==null?'':s.get('Reports_Status__c'));
                outputText += ','+(s.get('Username_New__c')==null?'':s.get('Username_New__c'));
                outputText += ',"'+(s.get('Product_Assessment__c')==null?'':s.get('Product_Assessment__c'))+'"';
                outputText += ',"'+(s.get('System_s__c')==null?'':s.get('System_s__c'))+'"';
                outputText += ','+(s.get('Email_as_Username__c')==null?'':s.get('Email_as_Username__c'));
                
                Bureau_Candidate__c bureauCandidate = (Bureau_Candidate__c)s;
                s.isExported__c = true;
            }
            UPDATE scope;
            }
    }

    global void finish(Database.BatchableContext BC)
    {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        
        if(a.Status=='Completed')
        {
            count = count + 1;
            ContentVersion Cv = new ContentVersion();    
            Cv.Origin='C';
            Cv.VersionData = Blob.ValueOf(outputText);
            Cv.Title = job.Name+'CandidateExportSheet'+count+'.csv';
            Cv.PathOnClient = job.Name+'CandidateExportSheet.csv'; 
            Cv.ContentLocation='S';        
            insert Cv;  

            // First get the content document Id from ContentVersion
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:Cv.Id].ContentDocumentId;
             
            //Create ContentDocumentLink
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.Visibility='AllUsers';
            cDe.LinkedEntityId = job.Id;
            cDe.ShareType = 'V';
            insert cDe;    
            

            String previousValue;
            if(job.Capture_Content_Version_Ids_For_Export__c != NULL){
                previousValue = job.Capture_Content_Version_Ids_For_Export__c;
                job.Capture_Content_Version_Ids_For_Export__c = previousValue + ',' + Cv.Id;
            }else{
                job.Capture_Content_Version_Ids_For_Export__c = Cv.Id;
            }
            UPDATE job;

            if(processedRecordsCount == 26000){
                ExportCandidateData b = new ExportCandidateData(job, count);
                Database.executeBatch(b, 200);
            }else if(isExecuteCalled == true && (processedRecordsCount == 0 || processedRecordsCount < 26000)){
                String fullFileURL;
                String messageBody = '';
                List<String> fullFileURLList = new List<String>();
                    
                if(job.Capture_Content_Version_Ids_For_Export__c != NULL){
                    String contentVersionValue = job.Capture_Content_Version_Ids_For_Export__c;
                    List<String> listOfJobIds = contentVersionValue.split(',');
                    for(String aa : listOfJobIds){
                        fullFileURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+aa;
                        fullFileURLList.add(fullFileURL);
                    }
                    for(Integer i=0 ;i<fullFileURLList.size();i++){
                        messageBody = messageBody + 'Please <a href=\''+fullFileURLList[i]+'\' > Click Here - '+job.Name+'CandidateExportSheet'+(i+1)+'.csv </a>to download the candidate upload sheet. </br>';
                    }    
                }
                
                mail.setSubject('Candidate Upload Sheet has been exported successfully. ');
                mail.setHtmlBody(messageBody);
                
                Messaging.SendEmailResult[] res = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                RevertIsExportedOnCandidate b1 = new RevertIsExportedOnCandidate(job);
                Database.executeBatch(b1, 2000);
            }else{
                System.debug('It is a Failure');
            }
        }
        else
        {
            mail.setSubject('Exporting Candidate Upload Sheet has been failed. ');
            mail.setHtmlBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        }  
    }

}