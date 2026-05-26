/****************************************

Class Name: ACWebhookCtlr
Author: Abhijeet Tiwari
Description: Upsert leads in SFDC coming from
             Active Campaign

Created Date: Aug 5,2020

=====  Version History =====================

S.No.   Date    Changes Made  Change Owner


****************************************/


@RestResource(urlMapping='/ACIntegration/*')
global class ACWebhookCtlr {
    @HttpPost
    global static void processContact() {
        
        String strContactId,strEmailContact;
 
        RestRequest req = RestContext.request;
        
        system.debug('---> req is '+req );
                
        Map<String,String> mapReq = req.Params;
        
        system.debug('---> mapReq is '+mapReq);
        
        for(String str: mapReq.keySet()){
        
        system.debug('--> key '+str);
        system.debug('--> value '+mapReq.get(str));
        
        }
              
              
        try{
            
        
            if( mapReq.get('contact[tags]')!=null && mapReq.get('contact[fields][16]')!=null && mapReq.get('contact[fields][16]') == 'Marketing Qualified Lead'){            
            
            
               String str = mapReq.get('contact[tags]');
            
              if( str.containsIgnoreCase('Form Fill') || str.containsIgnoreCase('Activity Based') || str.containsIgnoreCase('Request Trial') || 
            str.containsIgnoreCase('Form Fill Ads') || str.containsIgnoreCase('Re-engagement') ){
                
                String strEmail = mapReq.get('contact[email]');
                List<Lead> lstExistingLeads = new List<Lead>();
                
                lstExistingLeads = [select id,firstname,lastname,company,country from Lead WHERE Email=: strEmail];
                
                if( lstExistingLeads.size() == 0 ){
                    
                    AssignmentRule AR = new AssignmentRule();
                   AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
                   
                   //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                   Database.DMLOptions dmlOpts = new Database.DMLOptions();
                   dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                   dmlOpts.EmailHeader.triggerUserEmail = true;                 
                
                   strContactId = mapReq.get('contact[id]');
                   strEmailContact = mapReq.get('contact[email]');
                   
                   Lead objLead = new Lead();
                   objLead.firstname = mapReq.get('contact[first_name]');
                   objLead.lastname = mapReq.get('contact[last_name]');
                   objLead.company = mapReq.get('contact[fields][1]');
                   objLead.email = mapReq.get('contact[email]');                   
                   objLead.Description = mapReq.get('contact[fields][4]');
                   objLead.Title = mapReq.get('contact[fields][8]');
                   objLead.LeadSource = mapReq.get('contact[fields][10]');
                   objLead.Conversion_Source__c = mapReq.get('contact[fields][15]');
                   objLead.purl__c = mapReq.get('contact[fields][17]');
                   objLead.ptype__c = mapReq.get('contact[fields][25]');
                   objLead.Phone =  mapReq.get('contact[phone]');
                   objLead.Contact_Id_in_AC__c = mapReq.get('contact[id]');
                   objLead.Lead_Score_Verification__c = mapReq.get('contact[fields][60]');
                   objLead.Lead_Country__c = mapReq.get('contact[fields][41]');
                   objLead.AM_Lead__c = true;                   
                                   
                   objLead.utm_source__c = mapReq.get('contact[fields][48]');
                   objLead.utm_medium__c = mapReq.get('contact[fields][49]');
                   objLead.utm_campaign__c = mapReq.get('contact[fields][50]');
                   objLead.utm_term__c = mapReq.get('contact[fields][51]');                  

                   objLead.User_Journey__c = mapReq.get('contact[fields][53]');
                   objLead.Journey_Start__c = mapReq.get('contact[fields][56]');
                   objLead.Journey_Last__c = mapReq.get('contact[fields][57]');                  
                   objLead.Industry = mapReq.get('contact[fields][11]');
                   
                   //Setting the DMLOption on Lead instance
                   objLead.setOptions(dmlOpts);                   
                   
                   if(mapReq.get('contact[fields][64]') !=null ){
                       
                       if( mapReq.get('contact[fields][64]') == 'AC')
                           objLead.Lead_System_Source__c = 'Active Campaigns';
                       
                       else
                           objLead.Lead_System_Source__c = mapReq.get('contact[fields][64]');                      
                       
                   }   
                   
                   
                   insert objLead;
                   
                }
                
                else{
                    
                    strContactId = mapReq.get('contact[id]');
                    strEmailContact = mapReq.get('contact[email]');
                    
                    Lead objLead = lstExistingLeads[0];
                    
                    objLead.firstname = mapReq.get('contact[first_name]');
                    objLead.lastname = mapReq.get('contact[last_name]');
                    objLead.company = mapReq.get('contact[fields][1]');
                                                    
                    objLead.Description = mapReq.get('contact[fields][4]');
                    objLead.Title = mapReq.get('contact[fields][8]');
                    objLead.LeadSource = mapReq.get('contact[fields][10]');
                    objLead.Conversion_Source__c = mapReq.get('contact[fields][15]');
                    objLead.purl__c = mapReq.get('contact[fields][17]');
                    objLead.ptype__c = mapReq.get('contact[fields][25]');
                    objLead.Phone =  mapReq.get('contact[phone]');
                    objLead.Contact_Id_in_AC__c = mapReq.get('contact[id]');
                    objLead.Lead_Score_Verification__c = mapReq.get('contact[fields][60]');
                    objLead.Lead_Country__c = mapReq.get('contact[fields][41]');
                    objLead.AM_Lead__c = true;   
                   
                    objLead.utm_source__c = mapReq.get('contact[fields][48]');
                    objLead.utm_medium__c = mapReq.get('contact[fields][49]');
                    objLead.utm_campaign__c = mapReq.get('contact[fields][50]');
                    objLead.utm_term__c = mapReq.get('contact[fields][51]');
                   
                    objLead.Industry = mapReq.get('contact[fields][11]');

                    objLead.User_Journey__c = mapReq.get('contact[fields][53]');
                    objLead.Journey_Start__c = mapReq.get('contact[fields][56]');
                    objLead.Journey_Last__c = mapReq.get('contact[fields][57]');                
                   
                    if( mapReq.get('contact[fields][64]') !=null ){
                       
                       if( mapReq.get('contact[fields][64]') == 'AC')
                           objLead.Lead_System_Source__c = 'Active Campaigns';
                       
                       else
                           objLead.Lead_System_Source__c = mapReq.get('contact[fields][64]');                      
                       
                   }                  
                   
                    update objLead;             
                    
                }                
                
              }
              
            }        
            
            
        }
                
                catch(Exception e){
                    
                  // report exception
                  
                  List<Messaging.SingleEmailMessage> lstExMails = new List<Messaging.SingleEmailMessage>();       
                  Messaging.SingleEmailMessage exceptionmail = new Messaging.SingleEmailMessage();
             
                  String strExSubject = 'Exception occured on AC_SFDC Integration WebCtlr at '+datetime.now().format();
                  String strExBody = 'An Exception has occured during the incoming webhook processing from Active Campaign at '+datetime.now().format()+'.Below are the details:<br/><br/>'+
                  'Line number is '+e.getLineNumber()+'<br/><br/>.Here is the error message: '+e.getMessage()+'<br/><br/>'+
                  'Cause is '+e.getCause()+'<br/><br/>Stack Trace String: '+e.getStackTraceString();
                  exceptionmail.setSubject(strExSubject);
                  exceptionmail.setHTMLBody(strExBody);
            
                  List<String> lstExToAddresses = new List<String>();
                  lstExToAddresses.add(System.Label.Exception_Reporting_Mail);
                      
                  exceptionmail.setToAddresses(lstExToAddresses);      
                  lstExMails.add(exceptionmail);
                  
                          
                  Messaging.sendEmail(lstExMails); 
                  
                }

        }
}