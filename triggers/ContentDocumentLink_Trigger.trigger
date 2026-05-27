trigger ContentDocumentLink_Trigger on ContentDocumentLink (after insert,before delete) {
    if(Trigger_Activation__c.getInstance('ContentDocumentLink_Trigger').Active__c)
    {   
        System.debug('Content Document Link Trigger');
        if(Trigger.IsInsert){
            System.debug('Content Document Link Trigger isInsert');
            if(Trigger.isAfter){
                ContentDocumentLinkTriggerManager.documentAccessControl(Trigger.newMap);
                list<ContentDocumentLink > clist =new list<ContentDocumentLink >(); 
                String linkId;
                for(ContentDocumentLink con : Trigger.new){
                    linkId = con.LinkedEntityId;
                    if(linkId.startsWith('800')){
                        clist.add(con);  
                    }
                }
                if(clist.size()>0)               
                    ContentDocumentLinkTriggerManager.ContentDocLink_Insert(clist);
                //Above code has been added to run the ContentDocLink_Insert method only for Contract records and not for other object records. By Priyank on 20 Dec 2021
            }
        }
        if(Trigger.isDelete)
        {
            if(Trigger.isBefore)
            {
                list<ContentDocumentLink > clist =new list<ContentDocumentLink >(); 
                String linkId;
                for(ContentDocumentLink con : Trigger.old){
                    linkId = con.LinkedEntityId;
                    if(linkId.startsWith('800')){
                        clist.add(con);  
                    }
                }
                if(clist.size()>0) {
                    ContentDocumentLinkTriggerManager.ContentDocLink_BeforeDelete(clist); 
                }
                //Above code has been added to run the ContentDocLink_BeforeDelete method only for Contract records and not for other object records. By Priyank on 20 Dec 2021
            ContentDocumentLinkTriggerManager.avoidFileRemove(Trigger.oldMap);
            }
        }
    }
    
}