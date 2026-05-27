/**
 * @Description       : Apex Controller used in Bulk Contact Uploda Functionallity
 * @Unit tests        : ContactBulkController_Tester
 * @Author            : Joana Martins
 * @Group             : 
 * @Last modified on  : 06-06-2022
 * @Last modified by  : Joana Martins
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   06-06-2022   Joana Martins   Initial Version
**/

public class ContactBulkController {
    
    /**
    * Method that returns a Course Object data given it's Id
    *
    * @param CourseId 
    * @return Courses__c 
    */
    @AuraEnabled
    public static Courses__c getCourse(Id CourseId){
        Courses__c course = [SELECT Id, Course_Category__c,Course_Price__c, Partner_Account_Name__c, Course_Free_Spaces__c, CurrencyIsoCode
                             FROM Courses__c 
                             WHERE Id=:CourseId].get(0);
        return course;
    }
    
    /**
    * Method that searchs and returns a List of accounts by their D Number value
    *
    * @param accountsNumber List of accounts D Number to search
    * @return List<Account> 
    */   
    @AuraEnabled
    public static List<Account> getAccounts(List<String> accountsNumber){ 
    	List<Account> accountList = [SELECT Id, Account_Number__c FROM Account WHERE Account_Number__c IN: accountsNumber];
        return accountList;
    }

    
    /**
    * Method that creates course bookings managing it's duplicates within a specific Course
    *
    * @param courseBookingList List of Course Bookings created by the user
    * @return ContactInsertResultWrapper 
    */    
    @AuraEnabled
    public static ContactInsertResultWrapper saveCourseBookings(List<Course_Booking__c> courseBookingList){     
        	List<Course_Booking__c> cbListOfDuplicates = new List<Course_Booking__c>();
        	Set<Id> cbDupDelegateContactsIds = new Set<Id>();
        
            ContactInsertResultWrapper cirw = new ContactInsertResultWrapper();
            cirw.insertedContacts = new List<Contact>();
            cirw.duplicateContacts = new List<Contact>();
        	cirw.errorMessage = '';
        	cirw.insertedCB = false;
        
            String userId = UserInfo.getUserId();
        	String userProfileId = UserInfo.getProfileId();
            Profile userProfile = [SELECT Name FROM Profile WHERE Id =:userProfileId].get(0);
            List<PermissionSetAssignment> userPsList= [SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId, Assignee.Name 
                                                       FROM PermissionSetAssignment 
                                                       WHERE AssigneeId =: userId];
        	List<String> permissionNames = new List<String>();
            if(!userPsList.isEmpty()){  
                for(PermissionSetAssignment psa : userPsList){
                    permissionNames.add(psa.PermissionSet.Name);
                }
                
            }
        
            Courses__c course = [SELECT Id, Course_Free_Spaces__c 
                                 FROM Courses__c 
                                 WHERE Id=:courseBookingList[0].Course_Number__c].get(0);
        
            Decimal cFreeSpaces = course.Course_Free_Spaces__c;
        
       	//Change related to SSE-17028
       	
            //Original Code
                for(Course_Booking__c cb : courseBookingList ){
                    cb.Booking_Status__c = cFreeSpaces <= 0 ? 'Waiting' : 'Confirmed';
                    cFreeSpaces--; 
                }
            
        	// Updated Code
            /*for(Course_Booking__c cb : courseBookingList ){
                if( userProfile.Name == 'System Administrator' || permissionNames.contains('Training')|| permissionNames.contains('CSIT') || permissionNames.contains('GCSC Operations')){
                   cb.Booking_Status__c = cFreeSpaces <= 0 ? 'Waiting' : 'Confirmed'; 
                } else {
                    cb.Booking_Status__c = cFreeSpaces <= 0 ? 'Waiting' : 'Provisional'; 
                }
             	cFreeSpaces--; 
            }*/
        //end change SSE-17028
        
            List<Course_Booking__c> existingCBList = [SELECT Id, Delegate_Contact__c 
                                                      FROM Course_Booking__c  
                                                      WHERE Course_Number__c  =: courseBookingList[0].Course_Number__c];

            //Course has no CB
            if(existingCBList == null || existingCBList.isEmpty()){             
               
                try{
                   Insert courseBookingList;
                   cirw.insertedCB = true;
                }catch(Exception e){
                    cirw.errorMessage = e.getMessage();
                }
               
            } else {
                //Course has CB
                Set<Id> existingCBDelegateIds = new Set<Id>();
                for(Course_Booking__c cb : existingCBList){
                    //Course CB have Delegate Contact value
                    if(cb.Delegate_Contact__c != null){
                        existingCBDelegateIds.add(cb.Delegate_Contact__c);
                    }
                }
                
                if (existingCBDelegateIds == null || existingCBDelegateIds.isEmpty()) {
                    //Course has CB with Delegate Contact == null
                    
                    try{
                       Insert courseBookingList;
                       cirw.insertedCB = true;
                    }catch(Exception e){
                        cirw.errorMessage = e.getMessage();
                    }
                } else {
                    List<Course_Booking__c> cbListToInsert = new List<Course_Booking__c>();

                    for(Course_Booking__c cb2 : courseBookingList){

                        if(existingCBDelegateIds.contains(cb2.Delegate_Contact__c)){
                            cbListOfDuplicates.add(cb2); //CB and Contact exist in system. Return Contact
                            cbDupDelegateContactsIds.add(cb2.Delegate_Contact__c);
                            //Duplicate Contact! A Contact with the same Account and Email already exists in the system. <br/> 
                            cirw.errorMessage = 'Duplicate Course Booking! This Course already has a Course Booking with this Delegate Contact.';
                        } else {
                            cbListToInsert.add(cb2);//CB doesn't exist but Contact exist in system. Insert CB
                        }
                    }
                    
                    if( cbListToInsert != null && !cbListToInsert.isEmpty()){
                        //unique Values
                        Decimal cFreeSpaces1 = course.Course_Free_Spaces__c;
                        
                    //Changes related to SSE-17028
                    
                    	//Original Code
                        for(Course_Booking__c cb3 : cbListToInsert ){
                            cb3.Booking_Status__c = cFreeSpaces1 <= 0 ? 'Waiting' : 'Confirmed';
                            cFreeSpaces1--; 
                        }
                        
                        //Updated Code
                        /*for(Course_Booking__c cb3 : cbListToInsert ){
                            // Check changes by comparing with Original goal - SSE-17028
                            if( userProfile.Name == 'System Administrator'|| permissionNames.contains('Training') || permissionNames.contains('CSIT')|| permissionNames.contains('GCSC Operations')){
                                cb3.Booking_Status__c = cFreeSpaces1 <= 0 ? 'Waiting' : 'Confirmed';
                            } else {
                                 cb3.Booking_Status__c = cFreeSpaces1 <= 0 ? 'Waiting' : 'Provisional';
                            }
                            
                            cFreeSpaces1--; 
                        }*/
                    //end change SSE-17028
                        
                        try{
                           Insert courseBookingList;
                           cirw.insertedCB = true;
                        }catch(Exception e){
                           cirw.errorMessage = e.getMessage();
                        }
                    }
                    
                    if( cbDupDelegateContactsIds != null && !cbDupDelegateContactsIds.isEmpty()){
                        cirw.duplicateContacts = [Select Id, AccountId, FirstName, LastName, Email, Phone, Registration_Number__c, Registration_Number_legacy__c From Contact Where Id IN:cbDupDelegateContactsIds];
                    }
                    
                }
            }
            return cirw;
    }
    
    /**
    * Method that creates Contacts managing it's duplicates
    *
    * @param contactList List of Contacts created by the user
    * @return ContactInsertResultWrapper 
    */     
    @AuraEnabled
    public static ContactInsertResultWrapper saveContacts(List<Contact> contactList){

        ContactInsertResultWrapper cirw = new ContactInsertResultWrapper();
        List<Id> successIDs = new List<Id>();
        List<Id> duplicateIds = new List<Id>();
        List<sObject> duplicateRecords = new List<sObject>();
        Boolean hasDuplicateResult = false;
        
        //remove entirelly duplicates rows from list of contacts to insert
        Set<Contact> myset = new Set<Contact>();       
        List<Contact> listWithoutDuplicatesAux = new List<Contact>();
        for (Contact s : contactList) {
          if (myset.add(s)) {
            listWithoutDuplicatesAux.add(s);
          }
        }
        
        //remove AccountId/Email duplicates rows from list of contacts to insert
        List<Contact> listWithoutDuplicates = new List<Contact>();
        Set<Object[]> alreadySeen = new Set<Object[]>();       
        for (Contact c : listWithoutDuplicatesAux) {
            
        //Changes start for story - SSE-16635
        Object[] key = new Object[]{ c.AccountId, c.Email }; // original code
        //Object[] key = new Object[]{c.Email }; // change SSE-16635 (change on hold until further confirmation) 
        //Changes end for story - SSE-16635
        

        if (!alreadySeen.contains(key)) {
            listWithoutDuplicates.add(c);
            alreadySeen.add(key);
          }
        }
        
        // Update related to SSE-17028 / SSE-16635
        for(Contact cc : listWithoutDuplicates){
            cc.AutomationBypassDateTime__c = System.now();
        }
        // end Update
        
        Database.SaveResult[] srList = Database.insert(listWithoutDuplicates, false);
        
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {  
                successIDs.add(sr.getId());    // Operation was successful, so get the ID of the record that was processed          
            } else {
				for (Database.Error error : sr.getErrors()) {
                	// If there are duplicates, an error occurs Process only duplicates and not other errors 
                    if (error instanceof Database.DuplicateError) {
                        // Handle the duplicate error by first casting it as a DuplicateError class This lets you use methods of that class 
                        Database.DuplicateError duplicateError = (Database.DuplicateError)error;
                        Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                        
                        // Display duplicate error message as defined in the duplicate rule
                        cirw.errorMessage = duplicateResult.getErrorMessage();

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
                        hasDuplicateResult = true;
                    } else {
                       // errors.add('Error -- ' + error.getMessage());
                        cirw.errorMessage = error.getMessage(); // Update related to SSE-17028            
                        System.debug('The following error has occurred.' + error.getStatusCode() + ': ' + error.getMessage());
                        System.debug('Fields that affected this error: ' + error.getFields());                        
                    }
                }
                
            }
        }
        
        cirw.insertedContacts = [SELECT Id, AccountId, Email, FirstName, LastName, Phone, Registration_Number__c, Registration_Number_legacy__c FROM Contact Where Id IN:successIDs]; 
        
        if(hasDuplicateResult){
           cirw.duplicateContacts = [SELECT Id, AccountId, Email, FirstName, LastName, Phone, Registration_Number__c, Registration_Number_legacy__c FROM Contact Where Id IN:duplicateIds];   
        } else {
            cirw.duplicateContacts = new List<Contact>();
        }
             
        return cirw;
    }
    
    /**
    * Wrapper class that holds the data to return
    */ 
    public class ContactInsertResultWrapper{
        @AuraEnabled
        public List<Contact> insertedContacts { get; set;}
        
        @AuraEnabled
        public List<Contact> duplicateContacts { get; set;}
        
        @AuraEnabled
        public String errorMessage { get; set;}
        
        @AuraEnabled
        public Boolean insertedCB { get; set;}
    }
}