public class CompetitorTriggerManager {
    
    public static void CheckAutoCreateDisplacementFieldOnUpdate(List<Competitor__c> NewCompetitors,List<Competitor__c> OldCompetitors){
        ThrowValidationError(NewCompetitors,OldCompetitors);
    }
    
    public static void CheckAutoCreateDisplacementFieldOnInsert(List<Competitor__c> NewCompetitors){
        ThrowValidationError(NewCompetitors,null);        
    }
    
    public static Map<Id,List<Competitor__c>> GetOppCompetitorMap(List<Competitor__c> NewCompetitors){
        Map<Id,List<Competitor__c>> OppCompetitorMap = new Map<Id,List<Competitor__c>>();
        List<Id> OpportunitiyIds = new List<Id>();
        For(Competitor__c Competitor:NewCompetitors){
            OpportunitiyIds.add(Competitor.Opportunity__c);
        }
        List<Opportunity> OpportunityRecords = [select id,(select id,Auto_create_Displacement_Opportunity__c from Competitors__r) from opportunity where Id in:OpportunitiyIds];
        For(Opportunity opp:OpportunityRecords){
            OppCompetitorMap.put(opp.Id,opp.Competitors__r);
        }
        return OppCompetitorMap;
    }
    
    public static void ThrowValidationError(List<Competitor__c> NewCompetitors,List<Competitor__c> OldCompetitors){
        Map<Id,List<Competitor__c>> OppCompetitorMap = GetOppCompetitorMap(NewCompetitors);
        Boolean ThrowValidation=false;
        if(OldCompetitors==null){
            For(Integer i=0;i<NewCompetitors.size();i++){
                if(NewCompetitors[i].Auto_create_Displacement_Opportunity__c=='Yes'){
                    For(Competitor__c competitor:OppCompetitorMap.get(NewCompetitors[i].opportunity__c)){
                        if(competitor.Auto_create_Displacement_Opportunity__c=='Yes'){
                            ThrowValidation=True;
                            break;
                        }
                    } 
                    if(ThrowValidation){
                        NewCompetitors[i].addError('You cannot mark "Yes" on this competitor as there is already competitor with "Yes" is linked.'); 
                    }
                }
            }
        }
        else{
            For(Integer i=0;i<NewCompetitors.size();i++){
                if((NewCompetitors[i].Auto_create_Displacement_Opportunity__c!=OldCompetitors[i].Auto_create_Displacement_Opportunity__c ||
                   NewCompetitors[i].Opportunity__c!=OldCompetitors[i].Opportunity__c)
                   && NewCompetitors[i].Auto_create_Displacement_Opportunity__c=='Yes'){
                       For(Competitor__c competitor:OppCompetitorMap.get(NewCompetitors[i].opportunity__c)){
                           if(competitor.Auto_create_Displacement_Opportunity__c=='Yes'){
                               ThrowValidation=True;
                               break;
                           }
                           
                       }   
                   }
                if(ThrowValidation){
                    NewCompetitors[i].addError('You cannot mark "Yes" on this competitor as there is already competitor with "Yes" is linked.');
                }
            }
        }
    }
}