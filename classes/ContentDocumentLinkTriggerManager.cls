/**************************************************************************************************************************************
CREATED BY :- PRIYANK ANAND 
CREATED DATE :- 26-08-2019
DESCRIPTION :- This class contains logic to increase the count of PDFCount__c and CSVCount__c fields, when the file of respected type is inserted on order, this class is called in ContentDocumentLink_Trigger.
***************************************************************************************************************************************/ 

Global class ContentDocumentLinkTriggerManager {
    
    //This method is increasing the count of PDFCount__c and CSVCount__c fields, when the file of respected type is inserted on order.
    public static void ContentDocLink_Insert(list<ContentDocumentLink> con)
    {
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
        set<id> linkedorderid = new set<id>();
        map<id,id> contentDocIdAcc = new map<id,id>();
        List<ContentDocumentLink> condocacclink = new List<ContentDocumentLink>();
        list<contract> conupdated=new  list<contract>();//list to update the record with PDF and CSV count
        Double countpdf=0;
        Double countcsv=0;
        String fileExtension;
        set<String> Salesforce_Files_Extension =new set<String>();
        
        For(Salesforce_Files_Extension__mdt mdRecord : [select Value__c,FIleType__c FROM Salesforce_Files_Extension__mdt])
            Salesforce_Files_Extension.add(mdRecord.FIleType__c);
        
        for(ContentDocumentLink conlist:con)
        {           
            contentDocId.add(conlist.ContentDocumentid);
            contDocLinked.add(conlist.LinkedEntityId); 
        }
        
        list< ContentVersion> ContentVersionFileExtension = [select FileExtension,FileType,ContentDocumentId from ContentVersion where ContentDocumentId = :contentDocId];  
        system.debug('ContentVersionFileExtension'+ContentVersionFileExtension);
        list<ContentDocument> ContentDocument=[select id,FileType,FileExtension from ContentDocument where id In:contentDocId];
        system.debug('ContentDocument'+ContentDocument);
        if(ContentDocument!=null)
        {for(ContentDocument ContentDocuments: ContentDocument)
        {
            if(ContentDocuments.FileType=='PDF')
                contDocPDF.add(ContentDocuments.id); 
            
            else
                //   if((ContentDocuments.FileType=='CSV') || (ContentDocuments.FileType=='EXCEL_X')||(ContentDocuments.FileType=='EXCEL_M') ||(ContentDocuments.FileType=='EXCEL'))
                if(Salesforce_Files_Extension.contains(ContentDocuments.FileExtension))
                contDocCSV.add(ContentDocuments.id);
        }
        }
        
        list<id> contentDocPDFIdlist =new list<id>(contDocPDF);
        list<id> contentDocCSVIdlist =new list<id>(contDocCSV);
        system.debug('contentDocPDFIdlist'+contentDocPDFIdlist);
        system.debug('contentDocCSVIdlist'+contentDocCSVIdlist);
        
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
        
        List<Contract> OrderlistPDFDel = [Select id, CSVCount__c,PDFCount__c from Contract where id in: contDocLinkedPDF ];
        List<Contract> OrderlistCSVDel = [Select id,CSVCount__c,PDFCount__c from Contract where id in: contDocLinkedCSV];
        system.debug('OrderlistPDFDel'+OrderlistPDFDel);
        system.debug('OrderlistCSVDel'+OrderlistCSVDel);
        if(OrderlistPDFDel!=Null){
            if(OrderlistPDFDel.size() > 0){
                for(Contract conupdate:OrderlistPDFDel){
                    
                    countpdf=conupdate.PDFCount__c;
                    if(countpdf==null)
                        countpdf=0;
                    countpdf=countpdf+1;
                    conupdate.PDFCount__c=countpdf;                    
                    conupdated.add(conupdate);     
                    system.debug('conupdatedlist'+conupdated);
                    
                }
            }}
        if(OrderlistCSVDel!=Null){
            if(OrderlistCSVDel.size() > 0){ //Null Check 
                for(Contract conupdate:OrderlistCSVDel){
                    system.debug('insidecsv2');
                    countcsv=conupdate.CSVCount__c;
                    if(countcsv==null)
                        countcsv=0;
                    countcsv=countcsv+1;
                    conupdate.CSVCount__c=countcsv;                    
                    conupdated.add(conupdate);
                    system.debug('conupdatedlist'+conupdated);
                    
                    
                }//end of for
            }}//end of if for size
        
        //Link files to Account
        for(ContentDocumentLink conlist:con){
            linkedorderid.add(conlist.LinkedEntityId);
            contentDocIdAcc.put(conlist.LinkedEntityId,conlist.ContentDocumentid); 
            
        }
        
        if(linkedorderid!= null && linkedorderid.size()>0){
            List<Contract> OrderlistACClink = [Select id, AccountID  from Contract where id in: linkedorderid];
            if(OrderlistACClink!= null && OrderlistACClink.size()>0){
                for(Contract conlist:OrderlistACClink){
                    ContentDocumentLink condoclink = new ContentDocumentLink();
                    condoclink.LinkedEntityId = conlist.AccountID;
                    condoclink.ContentDocumentid = contentDocIdAcc.get(conlist.id);
                    condoclink.ShareType = 'V';
                    condocacclink.add(condoclink);
                }
            }
            if(condocacclink.size()>0){
                insert condocacclink;
            }
        }
        try{
            update conupdated;
        }
        catch(exception e){
            system.debug('Error'+e.getMessage());
        }
        system.debug('Updated record'+conupdated);
        
    }
    
    public static void ContentDocLink_BeforeDelete(List<ContentDocumentLink> con){
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
        set<id> linkedorderid = new set<id>();
        map<id,id> contentDocIdAcc = new map<id,id>();
        List<ContentDocumentLink> condocacclink = new List<ContentDocumentLink>();
        list<contract> conupdated=new  list<contract>();//list to update the record with PDF and CSV count
        String fileExtension;
        set<String> Salesforce_Files_Extension =new set<String>();
        
        For(Salesforce_Files_Extension__mdt mdRecord : [select Value__c,FIleType__c FROM Salesforce_Files_Extension__mdt])
            Salesforce_Files_Extension.add(mdRecord.FIleType__c);
        
        for(ContentDocumentLink conlist:con)
        {           
            contentDocId.add(conlist.ContentDocumentid);
            contDocLinked.add(conlist.LinkedEntityId); 
        }
        
        list< ContentVersion> ContentVersionFileExtension = [select FileExtension,FileType,ContentDocumentId from ContentVersion where ContentDocumentId = :contentDocId];  
        system.debug('ContentVersionFileExtension'+ContentVersionFileExtension);
        list<ContentDocument> ContentDocument=[select id,FileType,FileExtension from ContentDocument where id In:contentDocId];
        system.debug('ContentDocument'+ContentDocument);
        if(ContentDocument!=null)
        {for(ContentDocument ContentDocuments: ContentDocument)
        {
            if(ContentDocuments.FileType=='PDF')
                contDocPDF.add(ContentDocuments.id); 
            
            else
                //   if((ContentDocuments.FileType=='CSV') || (ContentDocuments.FileType=='EXCEL_X')||(ContentDocuments.FileType=='EXCEL_M') ||(ContentDocuments.FileType=='EXCEL'))
                if(Salesforce_Files_Extension.contains(ContentDocuments.FileExtension))
                contDocCSV.add(ContentDocuments.id);
        }
        }
        
        list<id> contentDocPDFIdlist =new list<id>(contDocPDF);
        list<id> contentDocCSVIdlist =new list<id>(contDocCSV);
        system.debug('contentDocPDFIdlist'+contentDocPDFIdlist);
        system.debug('contentDocCSVIdlist'+contentDocCSVIdlist);
        
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
        
        List<Contract> OrderlistPDFDel = [Select id, CSVCount__c,PDFCount__c from Contract where id in: contDocLinkedPDF ];
        List<Contract> OrderlistCSVDel = [Select id,CSVCount__c,PDFCount__c from Contract where id in: contDocLinkedCSV];
        system.debug('OrderlistPDFDel'+OrderlistPDFDel);
        system.debug('OrderlistCSVDel'+OrderlistCSVDel);
        if(OrderlistPDFDel!=Null){
            if(OrderlistPDFDel.size() > 0){
                for(Contract conupdate:OrderlistPDFDel){
                    conupdate.PDFCount__c=conupdate.PDFCount__c-1;                   
                    conupdated.add(conupdate);     
                    system.debug('conupdatedlist'+conupdated);
                    
                }
            }}
        if(OrderlistCSVDel!=Null){
            if(OrderlistCSVDel.size() > 0){ //Null Check 
                for(Contract conupdate:OrderlistCSVDel){
                    system.debug('insidecsv2');
                    conupdate.CSVCount__c=conupdate.CSVCount__c-1;                    
                    conupdated.add(conupdate);
                    system.debug('conupdatedlist'+conupdated);
                    
                    
                }//end of for
            }}//end of if for size
        
        try{
            update conupdated;
        }
        catch(exception e){
            system.debug('Error'+e.getMessage());
        }
        system.debug('Updated record'+conupdated);
    }
    
    public static void avoidFileRemove(Map<Id, ContentDocumentLink> oldMap) {
        String jobObjectName = 'Job__c';
        Set<Id> contentDocId = new Set<Id>();
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        for(ContentDocumentLink link : oldMap.values()) {
            String objectName = String.valueOf(link.LinkedEntityId.getsobjecttype());
            if(objectName == jobObjectName && profileName == 'Managed Service Lightning') {
                link.addError('You can not remove files on Job record!');
            }
        }
    }
    
    public static void documentAccessControl(Map<Id, ContentDocumentLink> conDocLinkMap){
        
        Set<Id> contentDocIdSet = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();
        list<Order> orderData = new list<Order>();
        list<Id> msOrderIdSet = new list<Id>();
        List<ContentDocumentLink> filteredLinkList = new List<ContentDocumentLink>();
        Map<Id,ContentDocument> contentDocumentMap = new Map<Id,ContentDocument>();
        List<ContentDocument> contentDocumentToUpdate = new List<ContentDocument>();
        List<ContentDocumentLink> linkToInsert = new List<ContentDocumentLink>();
        Set<String> groupNameSet = new Set<String>();
        
        for(ContentDocumentLink link : conDocLinkMap.values()){
            String objectName = String.valueOf(link.LinkedEntityId.getsobjecttype());
            if(objectName == 'Order') {
                contentDocIdSet.add(link.ContentDocumentId);
                orderIdSet.add(link.LinkedEntityId);
            }
        }
        System.debug(orderIdSet);
        if(orderIdSet.size()>0){
            orderData = [SELECT Id FROM Order WHERE Opportunity.MS_Opportunity__c = true AND Id IN :orderIdSet];
            for(Order orderRecord : orderData){
                msOrderIdSet.add(orderRecord.Id);
            }
            
            if(msOrderIdSet.size()>0){
                filteredLinkList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :msOrderIdSet and ContentDocumentId IN :contentDocIdSet];
            }
        }
        
        if(filteredLinkList.size()>0){
            contentDocIdSet.clear();
            for(ContentDocumentLink conLink : filteredLinkList){
                contentDocIdSet.add(conLink.ContentDocumentId);
            }
            
            if(contentDocIdSet.size()>0){
                contentDocumentMap = new Map<Id, ContentDocument>([SELECT Id, SharingPrivacy FROM ContentDocument WHERE Id IN :contentDocIdSet]);
            }
            
            List<Content_Document_Extended_Access__c> custSett = Content_Document_Extended_Access__c.getall().values();
            
            for(Content_Document_Extended_Access__c sett : custSett){
                groupNameSet.add(sett.Name);
            }
            
            list<User> userList = [SELECT Id FROM User WHERE Id IN (SELECT UserorGroupId FROM GroupMember 
                                                    WHERE Group.Type = 'Queue' AND Group.Name IN :groupNameSet) 
                									and isactive=true];
			
            for(ContentDocumentLink conLink : filteredLinkList){
                ContentDocument contentDoc = contentDocumentMap.get(conLink.ContentDocumentId);
                contentDoc.SharingPrivacy = 'P';
                contentDocumentToUpdate.add(contentDoc);
                
                for(User user1 : userList) {
                    ContentDocumentLink newLink = new ContentDocumentLink();
                    newLink.LinkedEntityId = user1.Id;
                    newLink.ShareType = 'V';
                    newLink.ContentDocumentId = conLink.ContentDocumentId;
                    linkToInsert.add(newLink);
                }
            }
        }
        
        if(contentDocumentToUpdate.size()>0 && linkToInsert.size()>0){
            try{
                INSERT linkToInsert;
                UPDATE contentDocumentToUpdate;
            }catch(Exception ex){
                conDocLinkMap.values()[0].addError(ex.getMessage());
            }
        }   
    }
}