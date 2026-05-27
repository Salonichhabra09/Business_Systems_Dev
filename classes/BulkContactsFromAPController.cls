/***********************************************************************************************************************************
* Created By: Prachi Gupta                                                                                                         * 
* Description: This class is used to Import Contacts from Account Plan.                                                            *
************************************************************************************************************************************/


public class BulkContactsFromAPController {
 
    @AuraEnabled
    public static ContactInsertResultWrapper saveContacts(List<ContactWrapper> contactWrapperList , String accplanId)
    {
        Set<String> uniqueAccNumber = new Set<String>();
        Set<String> uniqueEmail = new Set<String>();
        Set<String> uniqueReportsToEmail = new Set<String>();
        Set<String> uniqueReportToDNumber = new Set<String>();
        List<Account> accList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        Map<String,String> accountNumberIdMap = new Map<String,String>();
        Map<String,String> contactReportToMap = new Map<String,String>();
        List<Contact> reportsToUpdateList = new List<Contact>();
        List<contact> conData  = new List<Contact>();
        List<ContactWrapper> csvList = new List<ContactWrapper>();
        List<ContactWrapper> errorWrapper = new List<ContactWrapper>();
        List<ContactWrapper> uniqueWrapperInitial = new List<ContactWrapper>();
        List<ContactWrapper> uniqueWrapper = new List<ContactWrapper>();
        Set<Object[]> alreadySeenWrapper = new Set<Object[]>(); 
        Set<Object[]> alreadySeenWrapper1 = new Set<Object[]>(); 
        ContactInsertResultWrapper cirw = new ContactInsertResultWrapper();
        Map<string,string> emailToReportToMap = new Map<string,string>();
        Map<string,string> mapForReportTo = new Map<string,string>();
        Map<string,boolean> accountWithBillingLineMap = new Map<string,boolean>();
        Set<String> uniqueAccountonGrouping = new Set<String>();
        Set<String> ReportsToEmailSet = new Set<String>();
       
        
      
    
        try{
        //Getting the List of Picklist values of Area_of_Interest__c to check if valid value is inserted in CSV or not  
        Schema.DescribeFieldResult aoi = Contact.Area_of_Interest__c.getDescribe();   
        List<Schema.PicklistEntry> aoiValues = aoi.getPicklistValues();  
            Schema.DescribeFieldResult jobFunction = Contact.Job_Function__c.getDescribe();   
        List<Schema.PicklistEntry> jobFunctionValues = jobFunction.getPicklistValues();  
            Schema.DescribeFieldResult jobLevel = Contact.Job_Level__c.getDescribe();   
        List<Schema.PicklistEntry> jobLevelValues = jobLevel.getPicklistValues();  
            
        //Fetching the Content Doc id from Account Plan to check if any CSV is already imported on Account Plan or not   
        Account_Plan__c apData  = [Select id, Content_Doc_for_Contact_csv__c , Account_Plan_Name__c ,Account_Name__c,
                                   Account_Plan_Type__c, Buying_Centre_Id__c  ,
                                   Account_Name__r.Account_Number__c
                                   from Account_Plan__c 
                                   where id =:accplanId];
            
        string accPlanName = apData.Account_Plan_Name__c;
        string contentDocId = apData.Content_Doc_for_Contact_csv__c;
        string apType = apData.Account_Plan_Type__c;    
        uniqueAccountonGrouping.add(apData.Account_Name__r.Account_Number__c);    
            
              if(apType =='Regional'){
             List<Account> accListonGrouping = [SELECT id , Account_Number__c FROM Account 
                                   WHERE Buying_Centre_Id__c =: apData.Buying_Centre_Id__c
                                   AND RecordType.name != 'Competitor Account'];
                  
                  if(!accListonGrouping.isEmpty()){
                      for(Account acc : accListonGrouping){
                           uniqueAccountonGrouping.add(acc.Account_Number__c);
                      }
                     
                  }

        }
           else if(apType == 'Global'){
            Set<Id> allAccountIds = new Set<Id>{apData.Account_Name__c};
            Set<Id> parentIds = new Set<Id>{apData.Account_Name__c};
            List<Account> childAccounts = new List<Account>();
             
            do {
                childAccounts = [SELECT Id , Account_Number__c FROM Account 
                                 WHERE ParentId IN :parentIds AND RecordType.name != 'Competitor Account'];
                parentIds.clear();
                for (Account child : childAccounts){
                    parentIds.add(child.Id);
                    allAccountIds.add(child.Id);
                    uniqueAccountonGrouping.add(child.Account_Number__c);
                }
            } while (childAccounts.size() > 0);
       
             
        }
        
        
        //Getting all the D numbers of Account from CSV and adding in a unique list also removing whitespace from csv.    
        if(!contactWrapperList.isEmpty()){    
                for(ContactWrapper cw : contactWrapperList){
                   
                    cw.AccountNumber = cw.AccountNumber.trim();
                    if(cw.email != null){
                        cw.email = cw.email.trim(); 
                    }
                   
                     if( cw.ReportsToEmail != null){
                    cw.ReportsToEmail = cw.ReportsToEmail.trim();
                     }
                    if( cw.ReportsToAccount != null){
                        cw.ReportsToAccount = cw.ReportsToAccount.trim(); 
                    }
                   
                    uniqueAccNumber.add(cw.AccountNumber.trim());  
                }
                         
            //Fetching id of account corresponding to D number
            if(!uniqueAccNumber.isEmpty()){
                accList = [Select id , account_number__c ,Billing_Address_Line_1__c 
                           from account where account_number__c in :uniqueAccNumber];
            }
       
        
        //A map is created for Account id and account number
        if(!accList.isEmpty()){
            for(Account acc: accList){
             
                accountNumberIdMap.put( acc.account_number__c , acc.id);
                String billingAdd = acc.Billing_Address_Line_1__c;
                if(acc.Billing_Address_Line_1__c != null && billingAdd.length() > 50){
                accountWithBillingLineMap.put(acc.account_number__c , false);    
                }
                else{
                   accountWithBillingLineMap.put(acc.account_number__c , true); 
                }
            }
        }
                      
           for(ContactWrapper cw : contactWrapperList){
               //Key is created to find unique contact rows in CSV on basis of email and account Number                        
   
                 String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
                 Pattern MyPattern = Pattern.compile(emailRegex);
                 Boolean  ReportsToEmailValid = true;        
                 Boolean dataNotCorrect = false;
              
               if((cw.ReportsToEmail == '' || cw.ReportsToEmail == null) && 
                  (cw.isTopContact != 'Y' || cw.isTopContact != 'y')){
                     cw.ImportStatus = 'Error : It is mandatory to give Reports To or select contact as Top Level Contact';
                     dataNotCorrect = true;
                     errorWrapper.add(cw); 
               }
                else if(!accountNumberIdMap.containsKey(cw.AccountNumber) ){
                    cw.ImportStatus = 'Error : This account number does not exist in system ';
                     dataNotCorrect = true;
                     errorWrapper.add(cw); 
               }
                else if((cw.LastName == '' || cw.LastName == null) &&(cw.Email == '' || cw.Email == null)){
                            cw.ImportStatus = 'Error : Contact Last Name and Email can not be Blank.';
                            dataNotCorrect = true;
                            errorWrapper.add(cw); 
                        }
                else if((cw.LastName == '' || cw.LastName == null)){
                            cw.ImportStatus = 'Error : Contact Last Name can not be Blank.';
                            dataNotCorrect = true;
                            errorWrapper.add(cw); 
                        }
                 else if(cw.Email == '' || cw.Email == null){
                            cw.ImportStatus = 'Error : Contact Email can not be Blank.';
                            dataNotCorrect = true;
                            errorWrapper.add(cw); 
                        }
                 else if(cw.Email== cw.ReportsToEmail && cw.AccountNumber == cw.ReportsToAccount){
                            cw.ImportStatus = 'Error : A contact can not reports to itself.';
                            errorWrapper.add(cw); 
                           dataNotCorrect = true;
                        }
               else if(cw.AreaOfInterest == '' || cw.AreaOfInterest == null){
                            cw.ImportStatus = 'Error : Area of Interest can not be blank.';
                            errorWrapper.add(cw); 
                           dataNotCorrect = true;
                        }
               else if(cw.Phone == '' || cw.Phone == null){
                            cw.ImportStatus = 'Error : Phone can not be blank.';
                            errorWrapper.add(cw); 
                           dataNotCorrect = true;
                        }
                else if(cw.Title == '' || cw.Title == null){
                            cw.ImportStatus = 'Error : Title can not be blank.';
                            errorWrapper.add(cw); 
                           dataNotCorrect = true;
                        }
               else if(cw.Title.length() < 2){
                   cw.ImportStatus = 'Error : Title Length should be more than 2 characters.';
                            errorWrapper.add(cw); 
                           dataNotCorrect = true;
               }
               else{
                    Object[] key = new Object[]{ cw.Email, cw.AccountNumber };   
                   
                    if (!alreadySeenWrapper.contains(key)){
                       Matcher MyMatcher   =    MyPattern.matcher(cw.ReportsToEmail);
                       Matcher MyMatcher1 = MyPattern.matcher(cw.email); 
                        if(cw.ReportsToEmail == '' || cw.ReportsToEmail == null){
                            ReportsToEmailValid = true;
                        } 
                        else{
                             ReportsToEmailValid =   MyMatcher.matches();
                        }
                      
                        
                       if(!ReportsToEmailValid){
                                 cw.ImportStatus = 'Error : Please select the valid value for the Reports To Email.';
                                 errorWrapper.add(cw); 
                            }
                        else if(!MyMatcher1.matches()){
                            cw.ImportStatus = 'Error : Please select the valid value for the Email Address.';
                            errorWrapper.add(cw); 
                        }
                        else{
                            Boolean isAoiValid = false;
                             Boolean isJFValid = false;
                             Boolean isJLValid = false;
                            for (Schema.PicklistEntry entry : aoiValues) {
                             
                                if(cw.AreaOfInterest.toLowerCase() == entry.getValue().toLowerCase()){
                               
                                 isAoiValid = true;
                                 dataNotCorrect = true;
                                }
                                }
                             
                                                         
                            if(isAoiValid){
                                
                                if(cw.JobFunction == '' || cw.JobFunction == null){
                                  isJFValid = true;  
                                }
                                else{
                                  for (Schema.PicklistEntry entry : jobFunctionValues) {
                             
                                if(cw.JobFunction.toLowerCase() == entry.getValue().toLowerCase()){
                            
                                 isJFValid = true;
                                 dataNotCorrect = true;
                                }
                                }  
                                }
                                
                                if(isJFValid){
                                    
                                    if(cw.JobLevel == '' || cw.JobLevel == null){
                                    isJLValid = true;  
                                }
                                else{
                                  for (Schema.PicklistEntry entry : jobLevelValues) {
                             
                                  if(cw.JobLevel.toLowerCase() == entry.getValue().toLowerCase()){
                            
                                 isJLValid = true;
                                 dataNotCorrect = true;
                                }
                                }  
                                }
                                    if(isJLValid){
                                      
                                    String emailDNumber = cw.email + cw.AccountNumber;
                                    String ReportsToEmailDNumber = cw.ReportsToEmail + cw.ReportsToAccount; 
                                    emailToReportToMap.put(emailDNumber,ReportsToEmailDNumber);
                                    ReportsToEmailSet.add(ReportsToEmailDNumber);   
                                    uniqueWrapperInitial.add(cw);
                                    alreadySeenWrapper.add(key); 
                                   
                                    mapForReportTo.put(emailDNumber,cw.ReportsToEmail);   
                                    }else{
                                        cw.ImportStatus = 'Error : Please select the valid value for Job Level.';
                                errorWrapper.add(cw);  
                                    }

                                   
                                }
                                else{
                                     cw.ImportStatus = 'Error : Please select the valid value for Job Function.';
                                errorWrapper.add(cw); 
                                }
                                
                            }
                            else{
                                cw.ImportStatus = 'Error : Please select the valid value for Area of Interest.';
                                errorWrapper.add(cw); 
                            }
                            
                        }
                       
                   }
                   else{
                              cw.ImportStatus = 'Error : Duplicate Contact in CSV';
                       
                               errorWrapper.add(cw);                   }
               }
                
            }
          
    //Here checking the unique records which have circular dependency        
            for(ContactWrapper cw : uniqueWrapperInitial){
               String temp = cw.ReportsToEmail + cw.ReportsToAccount; 
               String temp1 = cw.email + cw.AccountNumber;
                if(emailToReportToMap.containsKey(temp) && emailToReportToMap.get(temp) == temp1){
                     cw.ImportStatus = 'Error : The Reports To Contact you selected is already a subordinate of this contact.';
                     errorWrapper.add(cw);
                }
                else{
                    
                    if(!uniqueAccountonGrouping.contains(cw.AccountNumber)){
                        
                         if(!ReportsToEmailSet.contains(temp1)){
                            
                         cw.ImportStatus = 'Error : We can not create this contact since it is either not part of the current D Number or Buying Centre';
                         errorWrapper.add(cw);
                }
                        else{
                             
                            uniqueWrapper.add(cw); 
                        }
                    }
                    else{
                       
                        uniqueWrapper.add(cw); 
                        }
                      
                   
                }
            }
            
//Mapping the wrapper with contacts  after removing all the error records           
            for(ContactWrapper cw : uniqueWrapper){
                
                Contact c = new Contact();
                c.AccountId = accountNumberIdMap.get(cw.AccountNumber);  
                c.Same_As_The_Account_Billing_Address__c = accountWithBillingLineMap.get(cw.AccountNumber);
                c.FirstName = cw.FirstName;
                c.LastName = cw.LastName;             
                c.Email = cw.Email;
                c.Phone = cw.Phone;
                c.Title = cw.Title;
                c.Area_of_Interest__c = cw.AreaOfInterest;
                if(cw.JobFunction != '' && cw.JobFunction != null){
                    c.Job_Function__c = cw.JobFunction; 
                }
                 if(cw.JobLevel != '' && cw.JobLevel != null){
                      c.Job_Level__c = cw.JobLevel; 
                }
              
                if(cw.isTopContact != null && cw.isTopContact != ''){
                     if(cw.isTopContact.toUpperCase() == 'YES' || cw.isTopContact.toUpperCase() == 'Y' || 
                      cw.isTopContact.toUpperCase() == 'TRUE'){
                    c.is_Root_Level_Contact__c = true;
                   }
                }
               
                contactList.add(c);
               
            }
            
            
        
        
       
        List<Id> successIDs = new List<Id>();
        List<Id> duplicateIds = new List<Id>();
        List<sObject> duplicateRecords = new List<sObject>();

        for(Contact cc : contactList){
            cc.AutomationBypassDateTime__c = System.now();
          
        }
       
        Database.SaveResult[] srList = Database.insert(contactList, false); 
       
        for (Database.SaveResult sr : srList) {
         
            if (sr.isSuccess()) {             
                successIDs.add(sr.getId());    // Operation was successful, so get the ID of the record that was processed 
            }
            
            
            for (Database.Error error : sr.getErrors()) {
             
                // If there are duplicates, an error occurs Process only duplicates and not other errors 
                if (error instanceof Database.DuplicateError) {
                    // Handle the duplicate error by first casting it as a DuplicateError class This lets you use methods of that class 
                    Database.DuplicateError duplicateError = (Database.DuplicateError)error;
                    Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                    
                    // Display duplicate error message as defined in the duplicate rule
                    cirw.Message = duplicateResult.getErrorMessage();
                    cirw.MessageType = 'Success';
                    
                    // Return only match results of matching rules that find duplicate records
                    Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
                    
                    // Just grab first match result (which contains the duplicate record found and other match info)
                    Datacloud.MatchResult matchResult = matchResults[0];
                    
                    Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                    
                    // Add matched record to the duplicate records variable
                    for (Datacloud.MatchRecord matchRecord : matchRecords) {
                        duplicateRecords.add(matchRecord.getRecord());
                        duplicateIds.add((string)matchRecord.getRecord().get('id'));
                        
                    }
                    
                } 
                //If any other occures other than duplicate rule
                else {
                    cirw.MessageType = 'Success';
                    cirw.Message =  error.getMessage();
                    System.debug('The following error has occurred.' + error.getStatusCode() + ': ' + error.getMessage());
                    System.debug('Fields that affected this error: ' + error.getFields());                        
                }
                
                
            }
        }
        //For records which are updated successfully adding them into list with Success message
        if(!successIDs.isEmpty() ){
            List<Contact> createdContactData = [select id , Email,  Account.Account_Number__c from contact 
                                                where id in: successIDs ];
            Map<String,Id> createdContactMap = new Map<String,Id>();                
            for(Contact c : createdContactData){
                String emailandDNumber = c.Email.trim() + c.Account.Account_Number__c.trim() ;
                //Map created to update the reports to for created Contact
                
                createdContactMap.put(emailandDNumber.toLowerCase(),c.id);
                for(ContactWrapper cw : uniqueWrapper){
                    ContactWrapper cw1 = new ContactWrapper();
                    if(c.email == cw.email && c.Account.Account_Number__c == cw.AccountNumber){ 
                        
                        cw.ImportStatus = 'Created Successfully';
                       
                    }
                }
            }        
           
          //Creating a list of unique email and account number of Reports to               
            for(ContactWrapper cw : contactWrapperList){
                if(cw.ReportsToEmail != '' && cw.ReportsToEmail != NULL && cw.ReportsToEmail != ' ' ){
                    uniqueReportsToEmail.add(cw.ReportsToEmail);
                    uniqueReportToDNumber.add(cw.ReportsToAccount);  
                }
                
                
            }
           
            //Fetching the id of contacts on basis of reports to email and reports to account number
            if(!uniqueReportsToEmail.isEmpty()){
                conData = [select id , Email,  Account.Account_Number__c from contact 
                           where Account.Account_Number__c in: uniqueReportToDNumber and
                           Email in : uniqueReportsToEmail];
                
            }   
            if(!conData.isEmpty()){
                for(Contact c : conData){
                    String emailandDNumber2 = c.Email + c.Account.Account_Number__c ; 
                    contactReportToMap.put(emailandDNumber2.toLowerCase(), c.id);
                    
                }
            }
            
            //Updating the Reports to value for contact
            List<ContactWrapper> cwList = new  List<ContactWrapper>();   
            Set<Object[]> uniqueRecords = new Set<Object[]>();       
            for (ContactWrapper cw : uniqueWrapper) {           
                Object[] key1 = new Object[]{ cw.AccountNumber, cw.Email,cw.ReportsToEmail, cw.ReportsToAccount };              
                    if (!uniqueRecords.contains(key1)) {
                        cwList.add(cw);
                        uniqueRecords.add(key1);
                    }
                
              
            }
            
            for(ContactWrapper cw : cwList){
                
                if(cw.ReportsToEmail != '' && cw.ReportsToEmail != NULL && cw.ReportsToEmail != ' ' ){
                    String temp = cw.ReportsToEmail + cw.ReportsToAccount;
                    String temp2 = cw.Email.trim() + cw.AccountNumber.trim(); 
                    
                    if(createdContactMap.containsKey(temp2.toLowerCase())){
                        Contact con = new Contact( id = createdContactMap.get(temp2.toLowerCase()),
                                                  reportsToId = contactReportToMap.get(temp.toLowerCase()),
                                                  AutomationBypassDateTime__c = System.now() );  
                      
                       
                        reportsToUpdateList.add(con);
                       
                    }   
                    
                }        
                
            } 
           
            
            if(!reportsToUpdateList.isEmpty()){
                
                
               Database.SaveResult[] updateResult = Database.update(reportsToUpdateList, false);
              // update reportsToUpdateList;
               
            }  
            
        }
        
        //Creating a list of all the records with there corresponding import status
        if(!duplicateIds.isEmpty()){
           List<Contact> duplicateContacts = [SELECT Id, Email,  Account.Account_Number__c , firstName , lastName
                                              FROM Contact Where Id IN:duplicateIds];  
             if(!duplicateContacts.isEmpty()){
                 for(Contact c: duplicateContacts){
                     
                 
                for(ContactWrapper cw : uniqueWrapper){
                    ContactWrapper cw1 = new ContactWrapper();
                    if(c.email == cw.email && c.Account.Account_Number__c == cw.AccountNumber){ 
                     
                        cw.ImportStatus = 'Error: The Contact with same Email and Account Number exists in system' + c.firstName + c.LastName ;
                       
                    }
                }
                 }
             }  
           
        }
        
            for(ContactWrapper cw : uniqueWrapper){
                if(cw.ImportStatus == '' || cw.ImportStatus == null){
                   cw.ImportStatus  = 'Error Occured while creating Contact: Please contact your system Admin';
                }
            }
        if(!uniqueWrapper.isEmpty()){
             csvList.addAll(uniqueWrapper);
        }
        if(!errorWrapper.isEmpty()){
            
            csvList.addAll(errorWrapper);
        }
        
        //Logic for creating csv string starts
   
          if(!csvList.isEmpty()){
           //Defining the header name for csv to be attached in related list of account plan   
           List<String> csvHeaders = new List<String>{'Account Number', 'First Name',	'*Last Name', '*Email','*Phone','*Title','*Area of Interest','Reports To Email','Reports To Account Number','Top Level Contact(Y/N)','Job Function','Job Level','Import Status'};
           List<String> apiNameHeaders = new List<String>{'AccountNumber', 'FirstName',	'LastName', 'Email','Phone','Title','AreaOfInterest','ReportsToEmail','ReportsToAccount','isTopContact','JobFunction' , 'JobLevel','ImportStatus' };    
           String headerRow = String.join(csvHeaders,',') + '\n';
           Integer rowListSize = csvList.size();
           Integer headerSize = apiNameHeaders.size();  
           Integer i = 0; 
           for(ContactWrapper row :csvList){
               
            //assuming the rowList is in the correct format and each string in the list is a new record
            Map<String, Object> objFieldMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(row));
            
            Integer j = 0;
            for(String objField :apiNameHeaders){
                headerRow += objFieldMap.get(objField) != null ? String.valueOf(objFieldMap.get(objField)) : '';
                j++;
                headerRow += j != headerSize ? ',' : '';//add comma separator
            }
            i++;
            if(i != rowListSize) headerRow += '\n';//add new line
              
        }
           ContentVersion cv = generateCSVFile(headerRow ,accplanId , contentDocId , accPlanName);
            // csv is inserted    
            if(cv != null){
            insert cv; 
   }
          //If its first time a csv is uploaded from acocunt plan save the content doc id in account plan
            if(contentDocId == null){
                List<contentversion> cvlist = [select id, ContentDocumentId from contentversion where id = :cv.id];  
                String cdID = '';
                if(!cvlist.isEmpty()){
                   
                    for(contentversion c :cvlist ){
                        cdID = c.ContentDocumentId;
                    }
                 //Updating the sharing type so that file is editable by all commercial users   
                    ContentDocumentLink cdl =[select id , ShareType from ContentDocumentLink 
                                              where ContentDocumentId=:cdID and LinkedEntityId=:accplanId];
                   
                    if(cdl != null){
                        cdl.ShareType ='I';
                    }
                    update cdl;        
                    Account_Plan__c ap = new Account_Plan__c(id = accplanId , Content_Doc_for_Contact_csv__c = cdID);  
                    update ap;
                }  
            }
          
            
           
        }
        
            if(cirw.MessageType != 'ERROR'){
               cirw.MessageType = 'Success';
               cirw.Message = 'CSV File has been uploaded Successfully' ; 
               Integer errorCount = 0;
                if(!errorWrapper.isEmpty()){
                    errorCount = errorWrapper.size();
                }
                if(!uniqueWrapper.isEmpty()){
                   for(ContactWrapper cw : uniqueWrapper){
                if(cw.ImportStatus != 'Created Successfully' ){
                  errorCount = errorCount + 1;
                }
            } 
                }
                
               cirw.errorContacts =  errorCount;
               cirw.totalContacts =   contactWrapperList.size();
                
            
        }   
        }
            else{
               
                cirw.MessageType = 'ERROR';
                cirw.Message = 'CSV File has no data to upload' ; 
            }
        }
        catch(Exception ex){
            cirw.MessageType = 'ERROR';
            cirw.Message = ex.getMessage();
           
        }
        
        return cirw;
    }
        
    //This method is used to create CSV
    @AuraEnabled
    public static ContentVersion generateCSVFile(String rowData , String AccountPlanId , String contentDocId , String accPlanName){
     
        String title = 'Contacts Import.csv';
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //denotes it resides on Salesforce
        cv.Title = title; //title of the file
        cv.PathOnClient = title; // full path within Salesforce this can just be the name of file to be in the library
        cv.VersionData = Blob.valueOf(rowData); //file data
        cv.SharingPrivacy = 'N' ;
        cv.SharingOption = 'A';
        cv.IsMajorVersion = true; 
        if(contentDocId != null && contentDocId != ''){
            Id  ContentDocumentId =  contentDocId;
            cv.ContentDocumentId = ContentDocumentId;  
        } else{ 
            cv.FirstPublishLocationId = AccountPlanId;
            cv.Description = 'This is an autogenerated csv for Uploaded Contacts.'; //Added by Prachi SSE-21436
        }
        return cv;
    }
    
    /*** Wrapper class that holds the data to return*/ 
    public class ContactInsertResultWrapper{
        @AuraEnabled public String MessageType;
        @AuraEnabled public String Message;
        @AuraEnabled public String Status;
        @AuraEnabled public Integer  errorContacts;
        @AuraEnabled public Integer  savedContacts;
        @AuraEnabled public Integer totalContacts;
        
        
    }
    
    public class ContactWrapper{
        @AuraEnabled
        public String AccountNumber { get; set;}
        @AuraEnabled
        public String FirstName { get; set;}
        @AuraEnabled
        public String LastName { get; set;}
        @AuraEnabled
        public String Email { get; set;}
        @AuraEnabled
        public String Phone { get; set;}
        @AuraEnabled
        public String Title { get; set;}
        @AuraEnabled
        public String AreaOfInterest { get; set;}
        @AuraEnabled
        public String ReportsToEmail { get; set;}
        @AuraEnabled
        public String ReportsToAccount { get; set;}
        @AuraEnabled
        public String isTopContact { get; set;}
        @AuraEnabled
        public String ImportStatus { get; set;}
         @AuraEnabled
        public String JobFunction { get; set;}
         @AuraEnabled
        public String JobLevel { get; set;}
    }
      
}