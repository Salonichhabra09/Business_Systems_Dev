trigger RestrictAttachmentdeleteOrder on Attachment (before delete) {

        Id profileId=userinfo.getProfileId();
        Set<Id> OrderId  = new set<Id>();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        //Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>(); 
        
        
        for(Attachment attachment : Trigger.old)
        {
            OrderId.add(attachment.ParentId);
        }
        List<Contract> Orderlist = [Select id,name,status from Contract where id in: OrderId AND (status =:'Complete' OR status=:'Cancelled' OR status=:'Awaiting PO' OR status=:'Queried' OR status=:'Under Legal Review')];
        
        for(Attachment attachment : Trigger.old)
        {
            String objectAPIName = (String) attachment.ParentId.getSObjectType().getDescribe().getName();
             
            if(!'System Administrator'.Equals(profileName) &&  objectAPIName == 'Contract' && Orderlist.size()>0)
           {
               attachment .addError('You do not have permissions to delete attachment.');
           } 
        }
    
    //edited by Rishabh Kanotra on 29/08/2018 as per SSE-7508 starts here    
    
    List<Contract> conlist = [Select id,name,Status, Opportunity__r.RecordType.Name from Contract where id in: OrderId AND (Status !=:'Draft' AND Status !=:'Rejected') AND Opportunity__r.RecordType.Name =: 'Ignite Opportunity'];
     for(Attachment attachment : Trigger.old)
        {            
            String objectAPINameOpp = (String) attachment.ParentId.getSObjectType().getDescribe().getName();
            if(ProfileName != System.Label.Skip_System_Administrator && conlist.size()>0 && objectAPINameOpp == 'Contract' )
            {
                attachment .addError('You are only allowed to delete the attachment(s) when the Order Status is \'Draft\' or \'Rejected\'.');
            }
            
            
        }
    
        //edited by Rishabh Kanotra on 29/08/2018 as per SSE-7508 ends here
        
}