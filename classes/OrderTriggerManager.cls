Public with sharing class OrderTriggerManager{
    
    @AuraEnabled
    public static Order getOrder(string OrdId) {
        System.debug('Number of Queries used -- OrderTriggerManager.getOrder START ------- ' + Limits.getQueries());
        return [SELECT id,AccountId,Account.BU__c,PoNumber,Variation_Opportunity__c,Variation_Reason__c,BillToContactId,CurrencyIsoCode,EndDate,EffectiveDate,RecordTypeId,MissingInfoOrdProd__c, Reduction_Order__c,TotalAmount, Status, Reduction_Order_Invoice_Created__c, Invoice_Header_Count__c, Product_Billing_Frequency__c, Service_billing_frequency__c, Order_Year__c, Contract.Payment_terms__c,Opportunity.MS_Opportunity__c FROM Order where Id=:OrdId];
    
    }
    
    
    @AuraEnabled
    public static void ChkOrderProd(string OrdId) {
        System.debug('Number of Queries used -- OrderTriggerManager.ChkOrderProd START ------- ' + Limits.getQueries());
        Boolean MissingInfo;
        list<orderitem> OrdProdLstMisngInfo= new list<orderitem>();
        list<orderitem> OrdProdLst=[SELECT Id, OrderId, Quantity, Package__c, Platform__c, Proposition__c, Renewable__c 
                                    FROM OrderItem 
                                    where OrderId=:OrdId];
        system.debug('this-->OrderProdlist'+OrdProdLst);
        if(OrdProdLst!=null && !OrdProdLst.isEmpty()){
            for(OrderItem OrdIt :OrdProdLst){
                if(OrdIt.Package__c==null || OrdIt.Renewable__c==null|| OrdIt.Proposition__c==null){
                    OrdProdLstMisngInfo.add(OrdIt);
                    system.debug('this-->missingProdlist'+OrdProdLstMisngInfo);
                }
            }
            if(OrdProdLstMisngInfo!=null && !OrdProdLstMisngInfo.isEmpty()){
                Order Ordr=getOrder(OrdId);
                Ordr.MissingInfoOrdProd__c=true;
                system.debug('this-->is field val'+Ordr.MissingInfoOrdProd__c);
                update Ordr;
            }
            else{
                Order Ordr=getOrder(OrdId);
                Ordr.MissingInfoOrdProd__c=false;
                system.debug('this-->is Else field val'+Ordr.MissingInfoOrdProd__c);
                update Ordr;
            }
        }
        System.debug('Number of Queries used -- OrderTriggerManager.ChkOrderProd END ------- ' + Limits.getQueries());
    }
    
    /*public static void CheckZeroOrderActivation(list<order> NewOrdLst){
        list<order> OrdLst= new list<order>();
        list<order> FinalOrdLst= new list<order>();
        if(NewOrdLst[0].status == 'Activated' && NewOrdLst[0].Order_Year__c != 0){
        OrdLst=[select id,status,Order_Year__c,contractId from order where Order_Year__c=0 AND contractid=:NewOrdLst[0].ContractId];
        }
        system.debug('this is in OrdLst'+OrdLst);
        if(OrdLst!=null && !OrdLst.isEmpty()){
        for(Order Ord :OrdLst)
        if(Ord.Status!='Activated')
        FinalOrdLst.add(Ord);
        system.debug('this is in final list'+FinalOrdLst);
        }
        if(FinalOrdLst!=null && !FinalOrdLst.isEmpty()){
        for(Order Ordnew :NewOrdLst)
        if(Ordnew.Status == 'Activated' && Ordnew.Order_Year__c!=0){
        system.debug('this is OrderYear'+Ordnew.Order_Year__c);
        Ordnew.addError('This Order Cannnot be Activated, as the Zero Year Order linked to the contract is not yet Activated');
        }
        } 
    }*/
    
    public static void RejectionReasonRequired(list<order> OrderNewList,Map<Id, order>OrdOldMap){
        System.debug('Number of Queries used -- OrderTriggerManager.RejectionReasonRequired START ------- ' + Limits.getQueries());
        Map<Id, Order> RejectedOrderMap = new Map<Id, Order>{};
            String RejComments;
        
        for(Order Ord: OrderNewList){
            /* 
            Get the old object record, and check if the approval status 
            field has been updated to rejected. If so, put it in a map 
            so we only have to use 1 SOQL query to do all checks.
            */
            Order oldOrd = OrdOldMap.get(Ord.Id);
            if (oldOrd.Oats_Status__c != 'Rejected' && Ord.Oats_Status__c == 'Rejected'){ 
                RejectedOrderMap.put(Ord.Id, Ord);
            }
        }
        system.debug('HELLO -- > ' + userinfo.getProfileId());
        if (!RejectedOrderMap.isEmpty()){
             system.debug('HELLO -- > ' + userinfo.getProfileId());
            //Get the most recent approval process instance for the object.
            //If there are some approvals to be reviewed for approval, then
            //get the most recent process instance for each object.
            List<Id> processInstanceIds = new List<Id>{};
            for (Order Ords : [SELECT (SELECT ID
                                           FROM ProcessInstances
                                           ORDER BY CreatedDate DESC
                                           LIMIT 1)
                                   FROM Order
                                   WHERE ID IN :RejectedOrderMap.keySet()]) {
                if(Ords.ProcessInstances.size() > 0){
                    processInstanceIds.add(Ords.ProcessInstances[0].Id);
                }
                
            }
            
            // Now that we have the most recent process instances, we can check
            // the most recent process steps for comments.
           // if(!processInstanceIds.isEmpty()){ //added validation
                for (ProcessInstance pi : [SELECT TargetObjectId,
                                           (SELECT Id, StepStatus, Comments 
                                            FROM Steps
                                            ORDER BY CreatedDate DESC
                                            LIMIT 1 )
                                           FROM ProcessInstance
                                           WHERE Id IN :processInstanceIds
                                           ORDER BY CreatedDate DESC])   
                {                   
                    if ((pi.Steps[0].Comments == null || pi.Steps[0].Comments.trim().length() == 0)){
                        RejectedOrderMap.get(pi.TargetObjectId).addError('Please Provide a Rejection Reason in Comments');
                        
                    }
                    RejComments=pi.Steps[0].Comments;
                    
                    if(RejComments!= null){
                        for(Order Ord: OrderNewList){
                            Ord.Rejection_Reason__c = RejComments;
                        }
                    }
                }
            //} 
        }
      System.debug('Number of Queries used -- OrderTriggerManager.RejectionReasonRequired END ------- ' + Limits.getQueries());
    }
    
    //@AuraEnabled
    public static void CheckInvHeaderWithOrder(list<order>NewOrdList) {
        System.debug('Number of Queries used -- OrderTriggerManager.CheckInvHeaderWithOrder START ------- ' + Limits.getQueries());
        string OrdId=NewOrdList[0].Id;
        List<Contract_Invoice_Header__c> InvList = new  List<Contract_Invoice_Header__c>();
        If(NewOrdList[0].Oats_Status__c== 'Rejected' || NewOrdList[0].status == 'Activated'){
            InvList= [select id,Order__c from Contract_Invoice_Header__c where Order__c =:OrdId];
        }
        system.debug('this is in InvList-->'+InvList);
        for(Order Ord:NewOrdList)
            if(Ord.Oats_Status__c=='Rejected' && Ord.Reduction_Order__c == false && (Ord.RecordType.Name == 'Standard Order' || (Ord.RecordType.Name != 'Standard Order' && Ord.Booked_Elsewhere__c == False))){
                if(InvList!=null && !InvList.isEmpty()){
                    Ord.addError('Order Cannot be Rejected as it has Invoice Header and Invoice Lines linked to it');
                }
            }else if(Ord.Status=='Activated' && Ord.Reduction_Order__c == false && Ord.Variation_Opportunity__c!='Yes' && Ord.Skip_Validation_Auto_Renewal__c == false && (Ord.RecordType.Name == 'Standard Order' || (Ord.RecordType.Name != 'Standard Order' && Ord.Booked_Elsewhere__c == False))){
                if(InvList.isEmpty() && Ord.TotalAmount>0 && Ord.Special_Account__c!=true){
                    Ord.addError('Order Cannot be Activated as it has no Invoice Header and Invoice Lines linked to it');
                }
            }
        //Commented as invoice mandatory check no longer needed fro Reduction orders as part of ATH259
        /*else if(Ord.Status=='Activated' && Ord.Reduction_Order__c == true && Ord.Skip_Validation_Auto_Renewal__c == false && Ord.Reduction_Order_Invoice_Created__c == false){
        Ord.addError('Reduction Order Cannot be Activated as it has no Invoice linked to its Original Order including reduced product(s)');
        }
        else if(Ord.Oats_Status__c=='Rejected' && Ord.Reduction_Order__c == true && Ord.Skip_Validation_Auto_Renewal__c == false && Ord.Reduction_Order_Invoice_Created__c == true){
        Ord.addError('Reduction Order Cannot be Rejected as it has Invoice linked to its Original Order including reduced product(s)');
        }*/
        System.debug('Number of Queries used -- OrderTriggerManager.CheckInvHeaderWithOrder END ------- ' + Limits.getQueries());
    }
    
    public static void RestrictNormalOrderCancellation(list<order>NewOrdList) {
        System.debug('Number of Queries used -- OrderTriggerManager.RestrictNormalOrderCancellation START ------- ' + Limits.getQueries());
        
        Map<id,order> cancelledOrderMap = new map<id,order>();
        Map<id,List<Order>> cancelledOrderContractId_RenewalOrders_Map = new Map<id,List<Order>>();
        Map<id,List<Order>> cancelledOrderId_ReductionOrders_Map = new Map<id,List<Order>>();
        Map<id,List<Contract_Invoice_Header__c>> cancelledOrderId_InvoiceHeaders_Map = new Map<id,List<Contract_Invoice_Header__c>>();
          
        for(order ord : NewOrdList){
            cancelledOrderMap.put(ord.id,ord);
            cancelledOrderId_ReductionOrders_Map.put(ord.id,new list<order>());
            cancelledOrderId_InvoiceHeaders_Map.put(ord.id,new List<Contract_Invoice_Header__c>());
            
            if(ord.contractid != null){
                cancelledOrderContractId_RenewalOrders_Map.put(ord.contractid,new list<order>());
            }
            
        }
        

        // INVOICING COMPLETED LOGIC
		//cannot cancel order if it's invoicing is completed
        for(Contract_Invoice_Header__c inv : [SELECT id,Invoice_Status__c,Order__c 
                                              FROM Contract_Invoice_Header__c 
                                              WHERE Order__c In :cancelledOrderMap.keySet() 
                                              AND (Invoice_Status__c ='Sun Order Complete'OR Invoice_Status__c = 'Sun Invoice Complete')])
        {
            cancelledOrderId_InvoiceHeaders_Map.get(inv.Order__c).add(inv);
        }
        
        
        //RENEWALS LOGIC
        //Cannot cancel order when a renewal order(order of same contract, greater year but not reduction) is activated
        if(cancelledOrderContractId_RenewalOrders_Map != null && cancelledOrderContractId_RenewalOrders_Map.size() > 0){
        
            for(order ord : [SELECT id,Order_Year__c,contractid,status,Reduction_order__c 
                             FROM Order 
                             WHERE contractid in :cancelledOrderContractId_RenewalOrders_Map.keyset() 
                             AND Reduction_order__c = false 
                             AND Status = 'Activated' AND Account.Skip_Validation__c = false]) 
            {
                cancelledOrderContractId_RenewalOrders_Map.get(ord.ContractId).add(ord);
            }
            
		}
         
        //REDUCTION ORDERS LOGIC
        //Cannot cancel order when a reduction order is associated with no products
        for(Order ord1 : [SELECT id,Order_Year__c, Original_Order__c, contractid,TotalAmount,
                          Reduction_order__c, (SELECT id,orderid FROM orderitems)
                          FROM Order 
                          WHERE Original_Order__c in :cancelledOrderMap.keyset() 
                          AND Reduction_order__c = true 
                          AND TotalAmount = 0 ]) 
        {
            if(ord1.orderItems.size() == 0){
                if(cancelledOrderMap.get(ord1.Original_Order__c).Order_Year__c == ord1.Order_Year__c){
                    cancelledOrderId_ReductionOrders_Map.get(ord1.Original_Order__c).add(ord1);
                }
            }
            
        }  
        
		// LOGIC to ADD ERROR TO TRIGGER RECORDS 
        for(order cancelledOrder : NewOrdList){
            
            //INVOICE HEADER Loop
            if(cancelledOrderId_InvoiceHeaders_Map.get(cancelledOrder.Id).size() > 0 ){
                cancelledOrder.addError('Order Cannot be Cancelled as the Invoicing for this Order is Complete.');
            }
            
            
            //RENEWALS Loop
            if(cancelledOrder.ContractId != null && cancelledOrderContractId_RenewalOrders_Map.get(cancelledOrder.ContractId).size() > 0){
            	for(order renewalOrder : cancelledOrderContractId_RenewalOrders_Map.get(cancelledOrder.contractid)){
                        
                	//Cannot cancel order when a renewal order(order of same contract, greater year but not reduction) is activated
                    if(renewalOrder.Order_Year__c > cancelledOrder.Order_Year__c ) {
                    	cancelledOrder.addError('This Order Cannot be Cancelled, as the Renewal Order linked to the contract is Activated');
                    }
                        
            	}
            }
            
            //REDUCTION Loop
            if(cancelledOrderId_ReductionOrders_Map.get(cancelledOrder.Id).size() > 0){
				cancelledorder.addError('This Order Cannot be Cancelled, as there exist a reduction order with no Products, either add products to reduction or Contact your System Admin for Support on this.'); 
            }
       	}

        System.debug('Number of Queries used -- OrderTriggerManager.RestrictNormalOrderCancellation END ------- ' + Limits.getQueries());
    } 
    
    //ORIGINAL RestrictNormalOrderCancellation method 
    /* public static void RestrictNormalOrderCancellation(list<order>NewOrdList) {
        System.debug('Number of Queries used -- OrderTriggerManager.RestrictNormalOrderCancellation START ------- ' + Limits.getQueries());
        Map<id,order> cancelledOrderMap = new map<id,order>();
        Map<id,list<order>> contractWithOrdersMap = new Map<id,list<order>>();
        Map<id,list<orderitem>> ordersWithOrderItemMap = new Map<id,list<orderitem>>();
        
        for(order ord : NewOrdList){
            cancelledOrderMap.put(ord.id,ord);
            contractWithOrdersMap.put(ord.contractid,new list<order>());
        }
        
        for(order ord : [select id,Order_Year__c,contractid,TotalAmount,status,Reduction_order__c 
                         from order 
                         where contractid in :contractWithOrdersMap.keyset()]){
            contractWithOrdersMap.get(ord.ContractId).add(ord);
        }
        
        for(orderitem oi : [select id,orderid,order.contractid 
                            from orderitem 
                            where order.contractid in :contractWithOrdersMap.keyset()]){
            if(ordersWithOrderItemMap.containsKey(oi.orderid)){
                ordersWithOrderItemMap.get(oi.orderid).add(oi);
            }
            else{
                ordersWithOrderItemMap.put(oi.orderid,new list<orderitem>{oi});
            }
        }
        
        //cannot cancel order if it's invoicing is completed
        List<Contract_Invoice_Header__c> InvList = new  List<Contract_Invoice_Header__c>();
        InvList= [select id,Invoice_Status__c,Order__c 
                  from Contract_Invoice_Header__c 
                  where Order__c In :cancelledOrderMap.keySet()];
        
        for(Contract_Invoice_Header__c Inv:InvList){
            if(Inv.Invoice_Status__c=='Sun Order Complete' || Inv.Invoice_Status__c=='Sun Invoice Complete'){
                for(order ord : NewOrdList){
                    if(Inv.Order__c == ord.id){
                        ord.addError('Order Cannot be Cancelled as the Invoicing for this Order is Complete.');
                    }
                }
                
            }
        }
        
        for(order cancelledorder : NewOrdList){
            for(order contractorder : contractWithOrdersMap.get(cancelledorder.contractid)){
                
                //Cannot cancel order when a renewal order(order of greater year but not reduction) is activated
                if(contractorder.Order_Year__c>cancelledorder.Order_Year__c && contractorder.Reduction_order__c==false && contractorder.Status=='Activated'){
                    cancelledorder.addError('This Order Cannot be Cancelled, as the Renewal Order linked to the contract is Activated');
                }
                
                //Cannot cancel order when a reduction order is associated with no products
                if(contractorder.Order_Year__c == cancelledorder.Order_Year__c && contractorder.Reduction_Order__c == true && contractorder.TotalAmount == 0 && ordersWithOrderItemMap.get(contractorder.id) == null){
                    cancelledorder.addError('This Order Cannot be Cancelled, as there exist a reduction order with no Products, either add products to reduction or Contact your System Admin for Support on this.'); 
                }
            }
        }
        System.debug('Number of Queries used -- OrderTriggerManager.RestrictNormalOrderCancellation END ------- ' + Limits.getQueries());
    }*/
    
    
    public static void RestrictGCSCOrderCancellation(list<order>GCSCOrdersList) {
        System.debug('Number of Queries used -- OrderTriggerManager.RestrictGCSCOrderCancellation START ------- ' + Limits.getQueries());
        system.debug('in function');        
        set<order> GCSCOrdersSet = new set<order>(GCSCOrdersList);
        set<order> GCSCReductionOrdersSet = new set<order>();
        Map<order,list<orderitem>> GCSCReductionOrdersWithOrderItemMap = new Map<order,list<orderitem>>();
        
        //cannot cancel order if it's invoicing is completed
        List<Contract_Invoice_Header__c> InvList = new  List<Contract_Invoice_Header__c>();
        InvList= [select id,Invoice_Status__c,Order__c from Contract_Invoice_Header__c where order__c In :GCSCOrdersSet];
        
        for(Contract_Invoice_Header__c Inv:InvList){
            if(Inv.Invoice_Status__c=='Sun Order Complete' || Inv.Invoice_Status__c=='Sun Invoice Complete'){
                for(order ord : GCSCOrdersList) {
                    if(Inv.Order__c == ord.id){
                        ord.addError('Order Cannot be Cancelled as the Invoicing for this Order is Complete.');
                    }
                }
            }
        }
        
        for(order ord : [select id,Original_Order__c 
                         from order 
                         where Reduction_Order__c = true 
                         and Original_Order__c IN :GCSCOrdersSet]){
            GCSCReductionOrdersSet.add(ord);
            GCSCReductionOrdersWithOrderItemMap.put(ord,new list<orderitem>());
            system.debug('reduction order'+ord);
        }
        
        for(orderitem oi : [select id,orderid,order.Original_Order__c 
                            from orderitem 
                            where orderid in :GCSCReductionOrdersSet]){
            if(GCSCReductionOrdersWithOrderItemMap.containskey(oi.order)){
                GCSCReductionOrdersWithOrderItemMap.get(oi.order).add(oi);
            }
            system.debug('orderitem'+oi);
        }
        
        for(order ord : GCSCReductionOrdersWithOrderItemMap.keyset()){
            system.debug('GCSCReductionOrdersWithOrderItemMap'+GCSCReductionOrdersWithOrderItemMap);
            if(GCSCReductionOrdersWithOrderItemMap.get(ord).isempty()){
                for(order ord2 : GCSCOrdersList){
                    if(ord.Original_Order__c == ord2.id){
                        ord2.addError('This Order Cannot be Cancelled, as there exist a reduction order with no Products, either add products to reduction or Contact your System Admin for Support on this.');
                    }
                }
            }
        }
        System.debug('Number of Queries used -- OrderTriggerManager.RestrictGCSCOrderCancellation END ------- ' + Limits.getQueries());
    }
    
    /*public static void RestrictOrderCancellation(list<order>NewOrdList) {
    system.debug('NewOrdList'+NewOrdList);
    system.debug('NewOrdList'+NewOrdList.size());
    system.debug('here two trigger');
    if(NewOrdList[0].Status=='Cancelled'){
    system.debug('here 1');
    set<id> OrdIdSet = new set<id>();
    Decimal CancldOrdYr;
    String ContrctId;
    for(integer i=0; i<NewOrdList.size(); i++){
    system.debug('here 2');
    if(NewOrdList[i].Status=='Cancelled'){
    system.debug('here 3');
    OrdIdSet.add(NewOrdList[i].id);
    CancldOrdYr=NewOrdList[i].Order_Year__c;
    ContrctId=NewOrdList[i].ContractId;
    system.debug('ContrctId'+ContrctId);
    }
    }
    List<Contract_Invoice_Header__c> InvList = new  List<Contract_Invoice_Header__c>();
    List<Contract_Invoice_Header__c> InvListCmpltd = new  List<Contract_Invoice_Header__c>();
    InvList= [select id,Invoice_Status__c,Order__c from Contract_Invoice_Header__c where Order__c =:OrdIdSet];
    for(Contract_Invoice_Header__c Inv:InvList)
    if(Inv.Invoice_Status__c=='Sun Order Complete' || Inv.Invoice_Status__c=='Sun Invoice Complete')
    InvListCmpltd.add(Inv);
    
    for(Order Ord:NewOrdList){
    if(InvListCmpltd!=null && !InvListCmpltd.isEmpty())
    Ord.addError('Order Cannot be Cancelled as the Invoicing for this Order is Completed');
    }
    
    List<Order> OrderList = new  List<Order>();
    List<Order> HighrOrderList = new  List<Order>();
    List<Order> ReductionOrderList = new  List<Order>();
    system.debug('ContrctId'+ContrctId);
    OrderList=[Select id,status,order_year__c,Reduction_order__c,TotalAmount,Invoice_Header_Count__c from order where Contractid=:ContrctId];
    system.debug('OrderList'+OrderList);
    system.debug('OrderListsize'+OrderList.size());
    for(Order Ord:OrderList){
    system.debug('here 4');
    If(Ord.Order_Year__c>CancldOrdYr && Ord.Reduction_order__c==false && Ord.Status=='Activated')
    HighrOrderList.add(Ord);
    }
    for(Order Ord:NewOrdList){
    system.debug('here 5');
    if(HighrOrderList!=null && !HighrOrderList.isEmpty())
    Ord.addError('This Order Cannot be Cancelled, as the Renewal Order linked to the contract is Activated');
    }
    
    for(Order Ord:OrderList){
    system.debug('here 6');
    If(Ord.Order_Year__c==CancldOrdYr && Ord.Reduction_order__c==true && Ord.TotalAmount==0)
    ReductionOrderList.add(Ord);
    //system.debug('In set reduct-->'+ReductionOrderList[0].Reduction_order__c);
    system.debug('this is in reductionlist-->'+ReductionOrderList);
    }
    set<id>ReductionOrdIdSet=new set<id>();
    if(ReductionOrderList!=null && !ReductionOrderList.isEmpty()){
    for(integer i=0; i<ReductionOrderList.size(); i++){
    ReductionOrdIdSet.add(ReductionOrderList[i].id);
    }
    system.debug('In set-->'+ReductionOrdIdSet);
    list<orderitem> OrdprodLst=[Select id,orderid from orderitem where orderid=:ReductionOrdIdSet];
    system.debug('in order prd list-->' +OrdprodLst);
    for(Order Ord:NewOrdList){
    if(OrdprodLst==null || OrdprodLst.isEmpty())
    Ord.addError('This Order Cannot be Cancelled, as there exist a reduction order with no Products, either add products to reduction or Contact your System Admin for Support on this.');
    
    }
    }
    }
    }*/
        
    /* This method updates the Value of Final Submission Date,Submission offset and Activation Offset in Order based on update in
Activated Date, Final Submission Date.*/
    public static void UpdateOrderFieldValues(List<Order> OrderNewList, List<Order> OrderOldList){
        System.debug('Number of Queries used -- OrderTriggerManager.UpdateOrderFieldValues START ------- ' + Limits.getQueries());
        for(Integer i=0;i<OrderNewList.size();i++){
            if(OrderNewList[i].ActivatedDate != OrderOldList[i].ActivatedDate && OrderOldList[i].Submitted_to_OATs__c == NULL){
                OrderNewList[i].Submitted_to_OATs__c = OrderNewList[i].ActivatedDate;
            }
            if(OrderNewList[i].Submitted_to_OATs__c != OrderOldList[i].Submitted_to_OATs__c){
                if(OrderNewList[i].Submitted_to_OATs__c >= OrderNewList[i].Daylight_Start_Date_US_Submission__c && OrderNewList[i].Submitted_to_OATs__c < OrderNewList[i].Daylight_End_Date_US_Submission__c)
                    OrderNewList[i].Submission_Offset__c = -14400000;           
                else
                    OrderNewList[i].Submission_Offset__c = -18000000;
            }
            if(OrderNewList[i].ActivatedDate != OrderOldList[i].ActivatedDate){
                if(OrderNewList[i].ActivatedDate >= OrderNewList[i].Daylight_Start_Date_US_Submission__c && OrderNewList[i].ActivatedDate < OrderNewList[i].Daylight_End_Date_US_Submission__c)
                    OrderNewList[i].Activation_Offset__c = -14400000;        
                else
                    OrderNewList[i].Activation_Offset__c = -18000000;
            }
        }
        System.debug('Number of Queries used -- OrderTriggerManager.UpdateOrderFieldValues END ------- ' + Limits.getQueries());
    }
    
    public static void bookingdatemandatory (list<Order> Ordr){
        System.debug('Number of Queries used -- OrderTriggerManager.bookingdatemandatory START ------- ' + Limits.getQueries());
        for( Order ord :Ordr){
            if((ord.Status =='Activated' || ord.Status =='Service Activated') && ord.Booking_Date__c == null){
                ord.addError('Order cannot be activated if booking date is blank');
            }
        }
        System.debug('Number of Queries used -- OrderTriggerManager.bookingdatemandatory END ------- ' + Limits.getQueries());
    }
    
   
    
    public static void restrictDeleteForOATS (list<Order> Ordr){
        System.debug('Number of Queries used -- OrderTriggerManager.restrictDeleteForOATS START ------- ' + Limits.getQueries());
        string oatid = [select id from profile where name = 'OAT' limit 1].id;
        for(order ord : ordr){
            //system.debug();
            if(userinfo.getProfileId() == oatid){
                ord.adderror('OATs User is not allowed to delete a order');
            }
        }
         System.debug('Number of Queries used -- OrderTriggerManager.restrictDeleteForOATS END ------- ' + Limits.getQueries());
    }
    
    public static void blankOutBillingFrequenciesForExtension(list<Order> orderList){
        
        Set<Id> oppIdsList = new Set<Id>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        String businessType = '';
        
        for(Order orderRecord : orderList){
            oppIdsList.add(orderRecord.OpportunityId);
        }
        
        if(oppIdsList.size() > 0){
            oppMap = new Map<Id, Opportunity>([SELECT Id, Business_Type__c FROM Opportunity WHERE Id IN :oppIdsList]);
            if(oppMap.size() > 0){
                for(Order orderRecord : orderList){
                    businessType = oppMap.get(orderRecord.OpportunityId).Business_Type__c;
                    if(businessType == System.label.ExtensionOpportunityName){
                        orderRecord.Product_Billing_Frequency__c = '';
                        orderRecord.Service_billing_frequency__c = '';
                    }
                }
            }
        }
    }
}