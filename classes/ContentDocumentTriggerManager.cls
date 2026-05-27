/**************************************************************************************************************************************
CREATED BY :- PRIYANK ANAND 
CREATED DATE :- 25-08-2019
DESCRIPTION :- This class contains logic to decrease the count of PDFCount__c and CSVCount__c fields, when the file of respected type is deleted on order, this class is called in ContentDocument_Trigger.
***************************************************************************************************************************************/ 

Global class ContentDocumentTriggerManager {
    
    //This method is decreasing the count of PDFCount__c and CSVCount__c fields, when the file of respected type is deleted on order 
    public static void ContentDocument_before(list<ContentDocument> con)
    {    Id profileId=userinfo.getProfileId();
     String profileName=[Select Id,Name from Profile where Id=:profileId].Name; //Forn Profile check
     List<Id> contentDocId = new List<Id>();
     List<Id> contentDocPDFId = new List<Id>(); //List of PDF files
     list<Id> contentDocPDFIds=new list<Id>();
     List<Id> contentDocCSVId = new List<Id>();    
     set<id> contDocLinkedPDF= new set<id>();
     set<id> contDocPDF= new set<id>();
     set<id> contDocLinkedCSV= new set<id>();
     set<id> contDocCSV= new set<id>();
     set<id> contDocLinked= new set<id>();
     set<id> contDoc= new set<id>();
     set<id> contDocLinkedorder=new set<id>();
     set<id> contDocorder=new set<id>();
     set<id> contDocLinkedorderDraft=new set<id>();
     set<id> contDocorderDraft=new set<id>();
     list<contract> conupdated=new  list<contract>();//list to update the record with PDF and CSV count
     Double countpdf=0;
     Double countcsv=0;
     
     set<String> Salesforce_Files_Extension =new set<String>();
     For(Salesforce_Files_Extension__mdt mdRecord : [select Value__c,FIleType__c FROM Salesforce_Files_Extension__mdt])
     {
         Salesforce_Files_Extension.add(mdRecord.FIleType__c);
     }
     
     for(ContentDocument conList : con){  
         contentDocId.add(conList.Id);
         if(conList.FileType=='PDF')
             contDocPDF.add(conList.id);
         //if((con.FileType=='CSV') || (con.FileType=='EXCEL_X')||(con.FileType=='EXCEL_M') ||(con.FileType=='EXCEL'))
         if(Salesforce_Files_Extension.contains(conList.FileType))     
         {
             System.debug('Salesforce_Files_Extension1');
             contDocCSV.add(conList.id);
             System.debug('contDocCSV'+contDocCSV);
         }
     }//End of For For ContentDocument
     
     list<id> contentDocPDFIdlist =new list<id>(contDocPDF);
     list<id> contentDocCSVIdlist =new list<id>(contDocCSV);
     if(contentDocPDFIdlist.size()>0)
     {
         for(ContentDocumentLink cdl : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId In:contentDocPDFIdlist ])
         {   
             contDocLinkedPDF.add(cdl.LinkedEntityId);            
             //  contDoc.add(cdl.ContentDocumentId);
             
         }
     }
     
     if(contentDocCSVIdlist.size()>0)
     {
         for(ContentDocumentLink cdl : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId In:contentDocCSVIdlist])
         {   
             contDocLinkedCSV.add(cdl.LinkedEntityId);            
             //contDoc.add(cdl.ContentDocumentId);
             
         }
     }
     //To Store all ContentDocumentLink as per ContentDocument
     for(ContentDocumentLink cdl : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId In:contentDocId ])
     {   
         contDocLinked.add(cdl.LinkedEntityId);            
         contDoc.add(cdl.ContentDocumentId);
         
     }
     //To Store all ContentDocumentLink as per Contract ContentDocument and linkentityid as current order
     for(ContentDocumentLink cdLinkOrder : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId In:contentDocId and LinkedEntityId IN:contDocLinked])
     {   
         contDocLinkedorder.add(cdLinkOrder.LinkedEntityId);            
         //  contDocorder.add(cdLinkOrder.ContentDocumentId);
         
     }
     //To Store all Contract with status = draft
     list<Contract> contractstatus=[select id,status from contract where id IN:contDocLinkedorder];
     for(Contract contractst:contractstatus)
     {
         if(contractst.Status!='Draft')
         {
             
             contDocorder.add(contractst.Id);
         }
     }
     //To Store all Content document with order status draft  
     for(ContentDocumentLink cdLinkOrderDraft : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId In:contentDocId and LinkedEntityId IN:contDocorder])
     {   
         //    contDocLinkedorderDraft.add(cdLinkOrderDraft.LinkedEntityId);            
         contDocorderDraft.add(cdLinkOrderDraft.ContentDocumentId);
         
     }
     List<Contract> OrderlistPDFDel = [Select id, CSVCount__c,PDFCount__c from Contract where id in: contDocLinkedPDF and status =:'Draft'];
     List<Contract> OrderlistCSVDel = [Select id,CSVCount__c,PDFCount__c from Contract where id in: contDocLinkedCSV and status =:'Draft'];
     
     
     for(ContentDocument ContentDocument : con)
     {   
         try{
             if(contDocorderDraft.contains(ContentDocument.Id) && ProfileName != System.Label.Skip_System_Administrator){
                 
                 ContentDocument.addError('You are only allowed to delete the File(s) when the Contract Status is \'Draft\' .');
                 
             } }
         catch(exception e)
         {
             ContentDocument.addError(e.getMessage());
         }
     }
     if(OrderlistPDFDel.size() > 0){
         for(Contract conupdate:OrderlistPDFDel){
             
             if((conupdate.PDFCount__c !=null) || (conupdate.PDFCount__c !=0))
             {
                 countpdf=conupdate.PDFCount__c;
                 countpdf=countpdf-1;
                 conupdate.PDFCount__c=countpdf;                    
                 conupdated.add(conupdate);     
                 system.debug('conupdatedlist'+conupdated);
             }
         }
     }
     if(OrderlistCSVDel.size() > 0){ //Null Check 
         for(Contract conupdate:OrderlistCSVDel){
             system.debug('insidecsv2');
             countcsv=conupdate.CSVCount__c;
             if((countcsv!=null) &&(countcsv >=0)){
                 
                 countcsv=countcsv-1;
                 conupdate.CSVCount__c=countcsv;                    
                 conupdated.add(conupdate);
                 system.debug('conupdatedlist'+conupdated);
             }//end of if
             
         }//end of for
     }//end of if for size
     try{
         update conupdated;
     }
     catch(exception e)
     {
         system.debug('Error'+e.getMessage());
     }
    }
    
    public static void avoidDeleteFile(Map<Id, ContentDocument> oldMap) {
        STring jobObjectName = 'Job__c';
        Set<Id> contentDocId = new Set<Id>();
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        for(ContentDocument con : oldMap.values()) {
            if(!con.title.contains('CandidateImportRating'))
              contentDocId.add(con.Id);
        }
        if(contentDocId.size()>0){
          List<ContentDocumentLink> docLinkList = [SELECT LinkedEntity.type, ContentDocumentId 
                                                 FROM ContentDocumentLink 
                                                 WHERE ContentDocumentId IN :contentDocId];
          for(ContentDocumentLink link : docLinkList) {
            if(link.LinkedEntity.type == jobObjectName && profileName == 'Managed Service Lightning') {
                ContentDocument content = oldMap.get(link.ContentDocumentId);
                content.addError('You can not delete files on Job record!');
            }
          }
        }
    }
    
     
     //Added by Prachi --SSE-21436
    public static void avoidDeleteAutoGeneratedPDF(list<ContentDocument> oldCDList, map<Id, ContentDocument> oldMap){
        Id systemAdminProfileId = [Select id from Profile where  name like 'System Administrator'].id;
        List<id> contentDocId = new List<id>();
         List<id> contentDocId2 = new List<id>();
         List<Account_Plan__c> apList  = new List<Account_Plan__c>();
        String getUserProfile = UserInfo.getProfileId();
        if(oldCDList!= null ){
            for(ContentDocument cd : oldCDList){
                if(oldMap.get(cd.id).Description == 'This is an autogenerated PDF for Account Plan.'){
                     
                    if(getUserProfile != systemAdminProfileId){
                        
                    
                     cd.addError('This is an auto generated PDF. You do not have access to delete this File.');
                    }
                    else{
                      contentDocId.add(cd.id);  
                    }
                    
                   
                }
                 //Added by Prachi -- SSE-21596
            if(oldMap.get(cd.id).Description == 'This is an autogenerated csv for Uploaded Contacts.'){
                       if(getUserProfile != systemAdminProfileId){
                        
                    
                     cd.addError('This is an auto generated CSV. You do not have access to delete this File.');
                    }
                    else{
                      contentDocId2.add(cd.id);  
                    }
                    
                }
            if(oldMap.get(cd.id).Description == 'This excel template has been created for account plan export functionality. Must not delete and change without consulting with Salesforce Team.') {
                     cd.addError('This excel template has been created for account plan export functionality. You do not have access to delete this File.');
                }   
            }
            if(getUserProfile == systemAdminProfileId && !contentDocId.isEmpty()){
                List<contentVersion> cvList = [Select id,Title , FirstPublishLocationId from Contentversion
                                               where ContentDocumentId in :contentDocId and FirstPublishLocationId!= ''];
                 apList = new List<Account_Plan__c>();
                if(cvList.size()>0){
                    for(contentVersion cv: cvList){
                     Account_Plan__c ap = new Account_Plan__c();
                     ap.id = cv.FirstPublishLocationId;
                     ap.Content_Document_Id__c = '';  
                     apList.add(ap);   
                    }
                    
                }
               
            }
            if(getUserProfile == systemAdminProfileId && !contentDocId2.isEmpty()){
                List<contentVersion> cvList = [Select id,Title , FirstPublishLocationId from Contentversion
                                               where ContentDocumentId in :contentDocId2 and FirstPublishLocationId!= ''];
                 apList = new List<Account_Plan__c>();
                if(cvList.size()>0){
                    for(contentVersion cv: cvList){
                     Account_Plan__c ap = new Account_Plan__c();
                     ap.id = cv.FirstPublishLocationId;
                     ap.Content_Doc_for_Contact_csv__c = '';  
                     apList.add(ap);   
                    }
                    
                }
                
            }
            if(!apList.isEmpty()){
              update apList;  
            }
            
        }
    }
    
}