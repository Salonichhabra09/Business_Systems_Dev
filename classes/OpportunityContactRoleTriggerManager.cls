public class OpportunityContactRoleTriggerManager {
    public static void UpdateOpportunityOnUpdate(List<OpportunityContactRole> OpportunityContactRoleOldList,List<OpportunityContactRole> OpportunityContactRoleNewList){
        List<Opportunity> OpportunitiesToUpdate = new List<Opportunity>();
        Set<Opportunity> OpportunitiesToUpdateSet = new Set<Opportunity>();
        Map<Id,Id> RelatedOpportunitiesMap = new Map<Id,Id>();
        Map<Id,Opportunity> OpportunityMap = new Map<Id,Opportunity>();
        set<Id> RelatedOpportunitiesSet = new Set<Id>();
        
        List<OpportunityContactRole> OtherRelatedBillingContacts = new List<OpportunityContactRole>();
        for(OpportunityContactRole oppContactRole:OpportunityContactRoleNewList){
            RelatedOpportunitiesMap.put(oppContactRole.Id, oppContactRole.OpportunityId);
            RelatedOpportunitiesSet.add(oppContactRole.OpportunityId);
        }
        Map<Id,List<OpportunityContactRole>> OppContactRoleMap = new Map<Id,List<OpportunityContactRole>>();
        List<OpportunityContactRole> AllContactRoles = [select id,contactId,Role,opportunityId from OpportunityContactRole where opportunityId In:RelatedOpportunitiesSet order by CreatedDate desc];
        for(OpportunityContactRole oppconrole:AllContactRoles){
            if(OppContactRoleMap.get(oppconrole.opportunityId)==null){
                List<OpportunityContactRole> OppConList = new List<OpportunityContactRole>();
                OppConList.add(oppconrole);
                OppContactRoleMap.put(oppconrole.opportunityId,OppConList);
            }
            else{
                OppContactRoleMap.get(oppconrole.opportunityId).add(oppconrole); 
            }
        }    
        
        for(Opportunity opp:[select Id,Billing_Contact__c,Primary_Contact__c,Billing_Contact__r.accountId,accountId from Opportunity where Id IN:RelatedOpportunitiesSet]){
            OpportunityMap.put(opp.Id,opp);
        }
        for(integer i=0;i<OpportunityContactRoleOldList.size();i++){
            if( OpportunityContactRoleOldList[i].ContactId!=OpportunityContactRoleNewList[i].ContactId){
                if(OpportunityContactRoleNewList[i].Role=='Billing Contact' || OpportunityContactRoleOldList[i].Role=='Decision Maker / Billing Contact' || OpportunityContactRoleOldList[i].IsPrimary==True){
                    if((OpportunityMap.get(RelatedOpportunitiesMap.get(OpportunityContactRoleNewList[i].id)).Billing_Contact__c==OpportunityContactRoleOldList[i].ContactId || OpportunityMap.get(RelatedOpportunitiesMap.get(OpportunityContactRoleNewList[i].id)).Primary_Contact__c==OpportunityContactRoleOldList[i].ContactId) && userinfo.getProfileId()!=Label.System_Admin_Id_18_Digit)
                        OpportunityContactRoleNewList[i].addError('Contact Cannot be changed as this contact is either Billing contact or Primary contact');  
                }
            }
            if((OpportunityContactRoleOldList[i].Role!=OpportunityContactRoleNewList[i].Role)){
                if(OpportunityContactRoleNewList[i].Role=='Billing Contact'){
                    if(OpportunityMap.get(RelatedOpportunitiesMap.get(OpportunityContactRoleNewList[i].id)).Billing_Contact__c==null ){                        
                        OpportunityMap.get(RelatedOpportunitiesMap.get(OpportunityContactRoleNewList[i].id)).Billing_Contact__c=OpportunityContactRoleNewList[i].ContactId;
                        OpportunitiesToUpdate.add(OpportunityMap.get(RelatedOpportunitiesMap.get(OpportunityContactRoleNewList[i].id)));
                    }
                }
                if(OpportunityContactRoleOldList[i].Role=='Billing Contact' || OpportunityContactRoleOldList[i].Role=='Decision Maker / Billing Contact'){
                    if(OpportunityContactRoleOldList[i].ContactId==OpportunityMap.get(RelatedOpportunitiesMap.get(OpportunityContactRoleOldList[i].id)).Billing_Contact__c){
                        //System.debug('This is value '+OpportunityContactRoleOldList[i].Role);
                        if(OpportunityContactRoleNewList[i].Role!='Decision Maker / Billing Contact' && OpportunityContactRoleNewList[i].Role!='Billing Contact' && userinfo.getProfileId()!=Label.System_Admin_Id_18_Digit)
                                 OpportunityContactRoleNewList[i].addError('Role Cannot be Changed for this contact, as this is a billing contact on Opportunity Header.');
                            
                        
                    /*    If(OtherRelatedBillingContacts.size()>0){
                            //OpportunityMap.get(RelatedOpportunitiesMap.get(OpportunityContactRoleNewList[i].id)).Billing_Contact__c=OtherRelatedBillingContacts[0].ContactId;
                            //OpportunitiesToUpdate.add(OpportunityMap.get(RelatedOpportunitiesMap.get(OpportunityContactRoleNewList[i].id)));
                        }
                        else{
                            if(OpportunityContactRoleNewList[i].Role!='Decision Maker / Billing Contact' )
                                   OpportunityContactRoleNewList[i].addError('Role Cannot be Changed as there is no other contact to mark as billing contact');
                        }    */ 
                    } 
                }
            } 
            if(OpportunityContactRoleOldList[i].IsPrimary!=OpportunityContactRoleNewList[i].IsPrimary){
               if(OpportunityContactRoleNewList[i].IsPrimary==true){
                if(OpportunityMap.get(RelatedOpportunitiesMap.get(OpportunityContactRoleNewList[i].id)).Primary_Contact__c!=OpportunityContactRoleOldList[i].contactId && userinfo.getProfileId()!=Label.System_Admin_Id_18_Digit){
                  OpportunityContactRoleNewList[i].addError('Cannot mark this contact as primary contact, since the associated opportunity already has a primary contact.');  
                }
               }
             /*   if(OpportunityContactRoleNewList[i].IsPrimary==true){
                    OpportunityMap.get(RelatedOpportunitiesMap.get(OpportunityContactRoleNewList[i].id)).Primary_Contact__c = OpportunityContactRoleNewList[i].ContactId; 
                    OpportunitiesToUpdate.add(OpportunityMap.get(RelatedOpportunitiesMap.get(OpportunityContactRoleNewList[i].id))); 
                }*/
                else{
                    if(OpportunityMap.get(RelatedOpportunitiesMap.get(OpportunityContactRoleNewList[i].id)).Primary_Contact__c == OpportunityContactRoleNewList[i].ContactId && userinfo.getProfileId()!=Label.System_Admin_Id_18_Digit){
                        OpportunityContactRoleNewList[i].addError('Primary contact Cannot be Changed, as this is associated with an Opportunity Header.');
                    }
                }
            }
        }
        if(OpportunitiesToUpdate.size()>0){
            OpportunitiesToUpdateSet.addall(OpportunitiesToUpdate);
            OpportunitiesToUpdate.clear();
            OpportunitiesToUpdate.addall(OpportunitiesToUpdateSet);
            //update OpportunitiesToUpdate;
        }
        
    }
    
    public static void UpdateOpportunityOnInsert(List<OpportunityContactRole> OpportunityContactRoleNewList){
        Map<Id,Id> RelatedOpportunitiesMap = new Map<Id,Id>();
        Map<Id,Opportunity> OpportunityMap = new Map<Id,Opportunity>();
        set<Id> RelatedOpportunitiesSet = new Set<Id>();
        List<Opportunity> OpportunitiesToUpdate = new List<Opportunity>();
        
        List<OpportunityContactRole> OtherRelatedBillingContacts = new List<OpportunityContactRole>();
        for(OpportunityContactRole oppContactRole:OpportunityContactRoleNewList){
            RelatedOpportunitiesMap.put(oppContactRole.Id, oppContactRole.OpportunityId);
            RelatedOpportunitiesSet.add(oppContactRole.OpportunityId);
        }
        
        for(Opportunity opp:[select Id,Billing_Contact__c,Primary_Contact__c,accountId from Opportunity where Id IN:RelatedOpportunitiesSet]){
            OpportunityMap.put(opp.Id,opp);
        }
        
        for(OpportunityContactRole oppConRole:OpportunityContactRoleNewList){
            //System.debug('Contact Role account '+oppConRole.Contact.accountId);
            //System.debug('Opportunity Account '+OpportunityMap.get(RelatedOpportunitiesMap.get(oppConRole.id)).accountId);
            if(oppConRole.role=='Billing Contact' && OpportunityMap.get((RelatedOpportunitiesMap.get(oppConRole.Id))).Billing_Contact__c==null){
                //OpportunityMap.get((RelatedOpportunitiesMap.get(oppConRole.Id))).Billing_Contact__c=oppConRole.ContactId;
                //OpportunitiesToUpdate.add(OpportunityMap.get((RelatedOpportunitiesMap.get(oppConRole.Id))));
            }
        }
        if(OpportunitiesToUpdate.size()>0){
            //update OpportunitiesToUpdate;
            }
    }
    
    public static void UpdateOpportunityOnDelete(List<OpportunityContactRole> OpportunityContactRoleNewList){
        Map<Id,Id> RelatedOpportunitiesMap = new Map<Id,Id>();
        Map<Id,Opportunity> OpportunityMap = new Map<Id,Opportunity>();
        set<Id> RelatedOpportunitiesSet = new Set<Id>();
        List<Opportunity> OpportunitiesToUpdate = new List<Opportunity>();
        
        List<OpportunityContactRole> OtherRelatedBillingContacts = new List<OpportunityContactRole>();
        for(OpportunityContactRole oppContactRole:OpportunityContactRoleNewList){
            RelatedOpportunitiesMap.put(oppContactRole.Id, oppContactRole.OpportunityId);
            RelatedOpportunitiesSet.add(oppContactRole.OpportunityId);
        }
        for(Opportunity opp:[select Id,Billing_Contact__c,Primary_Contact__c from Opportunity where Id IN:RelatedOpportunitiesSet]){
            OpportunityMap.put(opp.Id,opp);
        }
        for(OpportunityContactRole oppConRole:OpportunityContactRoleNewList){
            if(oppConRole.IsPrimary==true && OpportunityMap.get(RelatedOpportunitiesMap.get(oppConRole.Id)).Primary_contact__c==oppConRole.ContactId && userinfo.getProfileId()!=Label.System_Admin_Id_18_Digit){
                oppConRole.addError('Primary Contact cannot be deleted.');
            }
            if(oppConRole.Role=='Billing Contact' && OpportunityMap.get(RelatedOpportunitiesMap.get(oppConRole.Id)).Billing_Contact__c==oppConRole.ContactId && userinfo.getProfileId()!=Label.System_Admin_Id_18_Digit){
                oppConRole.addError('Contact cannot be deleted as this is marked as Billing contact on Opportunity.');
            }
        }
        
    }
    
}