public class CloseOpportunitiesOnAccountSanction {
    
    @InvocableMethod(label='Opportunity Close lost on Account Sanction' description='When an account is sanctioned then the related open opportunities are marked closed lost')
    public static void closeLostRelatedOpportunities(List<InputParameters> inputParameters) {
        
        Id accountId = inputParameters[0].accountId;
        Savepoint sp = Database.setSavepoint();
        
        
        try{
            List<Opportunity> relatedOpps = [SELECT Id,StageName FROM Opportunity WHERE AccountId =:accountId AND StageName != :System.Label.Opportunity_Stage_7 AND Variation_Reason__c !='Debooking'];
            
            Map<Id,Opportunity> openOpportunities = new Map<Id,Opportunity>();
            Map<Id,Opportunity> closedWonOpportunities = new Map<Id,Opportunity>();
            
            for(Opportunity opp : relatedOpps){
                if(opp.StageName == System.Label.Opportunity_Stage_6){
                    closedWonOpportunities.put(opp.Id,opp);
                }else{
                    openOpportunities.put(opp.Id,opp);
                }
            }
            
            Set<Opportunity> opportunitiesToCloseLost = new Set<Opportunity>();
            Set<Order> ordersToCancel = new Set<Order>();
            Set<Contract> contractsToCancel = new Set<Contract>();
            List<Id> oppsWithOrder = new List<Id>();
            List<Id> oppsWithCompleteInvoice = new List<Id>();
            List<Id> allContracts = new List<Id>();
            List<Id> contractsToNotCancel = new List<Id>();
            
            List<Order> relatedOrders = [SELECT Id,Status,Order_Year__c,ContractId,OpportunityId,(SELECT Id,Invoice_Status__c FROM Invoice_Headers__r WHERE Invoice_Status__c IN ('Sun Order Complete','Sun Invoice Complete','Invoice Complete')) FROM Order WHERE OpportunityId IN :closedWonOpportunities.keySet() AND Status!='Cancelled' ORDER BY Order_Year__c];
            
            
            for(Order ord : relatedOrders){
                if(ord.ContractId != null){
                    allContracts.add(ord.ContractId);
                }
                if(ord.Invoice_Headers__r.isEmpty()){      
                    Order orderToCancel = new Order();
                    Opportunity oppToClose = new Opportunity();
                    orderToCancel.Id = ord.Id;
                    orderToCancel.Status = 'Cancelled';
                    orderToCancel.Cancellation_Reason__c = 'Sanctioned Account';
                    orderToCancel.Oats_Status__c = 'Cancelled';
                    ordersToCancel.add(orderToCancel);
                    If(ord.OpportunityId != null){
                        oppToClose.Id = ord.OpportunityId;
                        oppToClose.StageName = System.Label.Opportunity_Stage_7;
                        oppToClose.Closed_Lost_Reason__c = 'Sanctioned Account';
                        opportunitiesToCloseLost.add(oppToClose);
                    }
                    
                }else{
                    oppsWithCompleteInvoice.add(ord.OpportunityId);
                    if(ord.ContractId != null){
                    	contractsToNotCancel.add(ord.ContractId);
                    }
                }
            }
            
            for(Id con : allContracts){
                if(!contractsToNotCancel.contains(con)){
                    Contract contractToCancel = new Contract();
                    contractToCancel.Id = con;
                    contractToCancel.Status = 'Cancelled';
                    contractToCancel.Customer_Cancelled_Reason__c = 'Sanctioned Account';
                    contractsToCancel.add(contractToCancel);

                }
            }
            
            for(Opportunity oppToClose : openOpportunities.Values()){ 
                oppToClose.StageName = System.Label.Opportunity_Stage_7;
                oppToClose.Closed_Lost_Reason__c = 'Sanctioned Account';
                opportunitiesToCloseLost.add(oppToClose);
                
            }
            
            for(Opportunity oppToClose : closedWonOpportunities.Values()){ 
                if(!oppsWithOrder.contains(oppToClose.Id) && !oppsWithCompleteInvoice.contains(oppToClose.Id)){
                    oppToClose.StageName = System.Label.Opportunity_Stage_7;
                    oppToClose.Closed_Lost_Reason__c = 'Sanctioned Account';
                    opportunitiesToCloseLost.add(oppToClose);
                }  
            }
                        
            update new List<Order>(ordersToCancel);
            update new List<Contract>(contractsToCancel);
            update new List<Opportunity>(opportunitiesToCloseLost);
        }
        
        catch(Exception e){
            Database.rollback(sp);
            System.debug(e.getMessage());
        }
        
        finally{
            Account acc = new Account();
            acc.Id = accountId;
            acc.Skip_Validation__c = false;
            
            update acc;
            
            DeletePermissionSet();
        }
        
    }
    
    @future
    public static void DeletePermissionSet(){
        List<PermissionSetAssignment> psaList = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId =: System.label.OrderContractViewAllPermissionSet];
        
        if(!psaList.isEmpty()){
            delete psaList;
        }
    }
    
    public class InputParameters{
        @invocableVariable
        public Id accountId;
    }
    
}