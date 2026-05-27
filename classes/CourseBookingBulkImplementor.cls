/*************This Component is used to handle the creation of Bulk Course Booking from the Courses. ************************
*             Created By: Prachi Gupta(prachi.gupta@shl.com)                                                                *                      
*             Created Date: 20-04-2022                                                                                      *
*****************************************************************************************************************************/

public class CourseBookingBulkImplementor {

    @AuraEnabled
        public static Courses__c getCourseData(Id CourseId){
        system.debug('Course Id '+CourseId);
        return [select Id, Name,Course_Type__c,Course_Category__c,Course_Price__c,CurrencyIsoCode,
                Course_Name__c,Course_Director__c, Course_Free_Spaces__c,Maximum_Delegates__c, Course_Start_Date__c,Course_End_Date__c 
                from Courses__c where Id=:CourseId];
    }
     @AuraEnabled
    public static CBResultWrapper saveCourseBookings(List<Course_Booking__c> CBList, Decimal fs){
         Integer CBCreated ; 
         CBResultWrapper CBR = new CBResultWrapper();
         CBR.Message = '';
         CBR.MessageType = 'Success';
         CBR.duplicateCB = new List<Course_Booking__c>();
        try{
        Decimal fsTemp = fs;    
        List<Course_Booking__c> cbListOfDuplicates = new List<Course_Booking__c>();
            Set<Id> CBDelegateIds = new Set<Id>();
            Set<Id> existingCBDelegateIds = new Set<Id>();
            List<Course_Booking__c> cbListToInsert = new List<Course_Booking__c>();
            List<Course_Booking__c> cbListWithoutDup = new List<Course_Booking__c>();
           
         
            
            for(Course_Booking__c cb : CBList){
                if(!CBDelegateIds.contains(cb.Delegate_Contact__c)){
                    CBDelegateIds.add(cb.Delegate_Contact__c);
                    cbListWithoutDup.add(cb);
                }
                else{
                      
                     CBR.MessageType = 'Error';
                     CBR.Message = 'Duplicate Course Booking! This Course already has a Course Booking with this Delegate Contact.';
                     CBR.duplicateCB.add(cb);
                }
            }
            
            List<Course_Booking__c> existingCBList = [SELECT Id, Delegate_Contact__c 
                                                      FROM Course_Booking__c  
                                                      WHERE Course_Number__c  =: cbListWithoutDup[0].Course_Number__c];
            //Course has no CB
            if(existingCBList.size() <= 0 ){
               
               Insert cbListWithoutDup;
               CBCreated =  cbListWithoutDup.size();
               CBR.MessageType = 'Success';
               CBR.Message =  CBCreated + ' Course Bookings records saved successfully'; } 
            //Course has CB
            else {
                
                for(Course_Booking__c cb : existingCBList){
                    //Course CB have Delegate Contact value
                    if(cb.Delegate_Contact__c != null){
                        
                        existingCBDelegateIds.add(cb.Delegate_Contact__c);
                    }
                }
                
                if (existingCBDelegateIds.size() <= 0 ) {
                    //Course has CB with Delegate Contact == null
                    
                    Insert cbListWithoutDup;
                    CBCreated =  cbListWithoutDup.size(); 
                    CBR.MessageType = 'Success';
                    CBR.Message = CBCreated + ' Course Bookings records saved successfully';}
                //Course has CB with Delegate Contact
                else {
                    
                    for(Course_Booking__c cb2 : cbListWithoutDup){
                       
                        if(existingCBDelegateIds.contains(cb2.Delegate_Contact__c)){
                           
                            cbListOfDuplicates.add(cb2); //CB and Contact exist in system. Return Contact
                             CBR.duplicateCB.add(cb2);
                            CBR.MessageType = 'Error';
                            CBR.Message = 'Duplicate Course Booking! This Course already has a Course Booking with this Delegate Contact.';
                        } else {
                            
                            cbListToInsert.add(cb2);//CB doesn't exist but Contact exist in system. Insert CB
                        }
                    }
                    
                    if( cbListToInsert.size()> 0){
                    
                        insert cbListToInsert;
                        CBCreated =  cbListToInsert.size();
                        CBR.MessageType = 'Success';
                        CBR.Message = CBCreated+ ' Course Bookings records saved successfully';
                    }
      }
            }
            
        return CBR;
        }
        catch(Exception e)
        {
            //return e.getMessage();
            system.debug('In catch' + e.getMessage());
            throw new AuraHandledException('Error while inserting Course Booking' + e.getMessage());
        }}
    
     public class CBResultWrapper{
       
        @AuraEnabled
        public List<Course_Booking__c> duplicateCB { get; set;} 
        @AuraEnabled
        public String Message { get; set;}
        
        @AuraEnabled
         public String MessageType { get; set;}}
    
}