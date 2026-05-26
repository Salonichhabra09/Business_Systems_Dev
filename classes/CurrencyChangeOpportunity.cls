public class CurrencyChangeOpportunity {

    Public Opportunity opportunity1;
    public String OppId=ApexPages.currentPage().getParameters().get('Id');
      
    public CurrencyChangeOpportunity(ApexPages.StandardController controller) {   
       
        opportunity1=[select id,name,Change_Currency__c,ContractId,Opportunity_Deal_Year__c,Owner.email,Order_Number__c,Order_Status__c,StageName from opportunity where id=:oppId]; // Remove Order_Number__c 
        
        /*if(opportunity1.StageName=='Verbal'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'The currency of opportunity cannot be changed on Verbal Stage. Please change the stage from verbal to change the currency.')); 
        }*/
            
    }
    
   // public list<contract> ListContract=new list<Contract>();
    public Opportunity Opportunity;
    public Contract con{get;set;}
    public list<Order> ListOrder = new list<Order>();
    public list<OpportunityLineItem> OpportunityLineItemToDelete =New list <OpportunityLineItem>();
    public list<OpportunityLineItem> OpportunityLineItemToInsert =new list<OpportunityLineItem>() ;
    public Map<Id,Id> OpportunityLineItemMap =New Map<Id,Id>();
    public Map<Id,OpportunityLineItem> OldandNewOLIMap =New Map<Id,OpportunityLineItem>();
    public list<OrderItem> OrderItemToDelete =New list <OrderItem>();
    public list<OrderItem> OrderItemToInsert =new list<OrderItem>() ;
    public Map<Id,Id> OrderItemMap =New Map<Id,Id>();
    public Map<Id,Id> FutureProdMap =New Map<Id,Id>(); // Added by pankhuri
    //public Map<Id,list<Future_Product__c>> oldOLIToFPMap = new Map<Id,list<Future_Product__c>>(); 
    public Map<Id,Id> NewInsertedLineItemMap = New Map<Id,Id>(); // Added by pankhuri
    public list<currencytype> ListCurrrencyType =new list <currencytype>();
    public list<ProjectObject__c> ListProject=new list<ProjectObject__C>();
    public list<ProjectObject__c> ListProjectToUpdate=new list<ProjectObject__C>();
    public list<Future_Product__c> ListFutureProduct = new list<Future_Product__c>();
    public list<Future_Product__c> ListFutureProductToUpdate = new list<Future_Product__c>();
    public string SelectedCurrency{get;set;}
    public Map<id,pricebookentry> PricebookEntryMap=new map<id,Pricebookentry>();
    public Map<id,pricebookEntry> getPricebookEntryMap(){return PricebookEntryMap;}
    public Map<id,pricebookentry> PricebookEntryMap1=new map<id,Pricebookentry>();
    public set<id> PricebookEntrySet=new set<id>();
    public set<id> Pricebook2Set=new set<id>();
    public set<id> Product2Set=new set<id>();
    public list<string> ProductsUpdated= new list<string>();
    public list<string> getProductsUpdated(){ return ProductsUpdated;}
    public list<OpportunityLineItem> getOpportunityLineItemToInsert() {return OpportunityLineItemToInsert ;}
    public void setOpportunityLineItemToInsert(list<OpportunityLineItem> value) {OpportunityLineItemToInsert= value ;}
    public list<order> OrdersToUpdate = new list<order>();
   
    
    public list<OpportunityLineItem> getOpportunityLineItemToDelete (){return OpportunityLineItemToDelete ;}
    public void setOpportunityLineItemToDelete (list<OpportunityLineItem> value) { if(OpportunityLineItemToDelete.size()>0)
    OpportunityLineItemToDelete.clear(); OpportunityLineItemToDelete = value ;}

    public list<selectOption> getAllCurrencyTypes(){    
        //Fetch the List of Currencies
        list<selectOption> options=new list<selectOption>();
        for(CurrencyType ct:[SELECT IsoCode, ConversionRate,id FROM CurrencyType ORDER BY IsoCode]){
          options.add(new selectOption(ct.ISOCode,ct.ISOCode));
        }
        return options;
    }


    Public void FindRelatedRecords(){           //Fetch Project, Future Servies, OpportunityLineItems from opportunity
        opportunity=[select id,Change_Currency__c,Future_Product_Total_Price__c,Amount,Opportunity_Deal_Year__c ,name,Multi_YearDeal__c,ContractId,Owner.email,Order_Number__c,Order_Status__c, StageName,currencyIsocode,(Select id,name,Sales_Price__c,Product__c,Pricebook_Entry_Id__c,CurrencyIsocode,Contract_Value__c,Opportunity_Product_Id__c,Usage_Cap_or_Estimation__c from Future_Year_Opportunity_Products__r),(select id,CurrencyChangeEmailAlertInitiater__c from Projects__r), (SELECT CurrencyIsoCode,PricebookEntry.Product2Id,PriceBookEntry.Product2.Name,PriceBookEntry.Product2.Revenue_Category__c,Description,HasQuantitySchedule,HasRevenueSchedule,HasSchedule,Id,Invoice_Date__c,ListPrice,OpportunityId,PricebookEntryid,Quantity,ServiceDate,TotalPrice,UnitPrice,Unit_Price__c,start_date__c, End_date__c,Platform__c,Renewable__c,Basis_of_Fees__c,Other__c,Usage_Allowance__c,Usage_Cap_or_Estimation__c ,Hiring_Need__c , Imported_from_Rate_Card_c__c,Level__c,List_Price__c,Package_Level__c,Talent_Level__c,Total_Discount__c,Volume__c,Year_1_Discount__c,Year_1_List_Price__c,Year_1_Sales_Price__c,Year_2_Discount__c,Year_2_List_Price__c,Year_2_Sales_Price__c,Contract_Year__c,Year_3_Discount__c,Year_3_List_Price__c,Year_3_Sales_Price__c,Package__c,Proposition__c,Solution_Cap__c,RenewableNew__c,CurrencyChange__c,Contract_Value__c,Total_Equivalent_Units__c FROM OpportunityLineItems) from opportunity where id=:oppId];        
        if(opportunity.OpportunityLineItems.size()>0){
           for(OpportunityLineItem OLI: opportunity.OpportunityLineItems){            
                 OpportunityLineItemToDelete.add(OLI);
                 PricebookEntrySet.add(OLI.PricebookEntryId);
                 OpportunityLineItemMap.put(OLI.id,OLI.PricebookEntry.Product2Id);
           }
        }
        if(opportunity.Projects__r.size()>0){
          for(ProjectObject__c project:opportunity.Projects__r){
              ListProject.add(Project);                  
          }
        }    
        
        if(opportunity.Future_Year_Opportunity_Products__r.size()>0 && opportunity.Future_Year_Opportunity_Products__r != null){
          for(Future_Product__c futureprod : opportunity.Future_Year_Opportunity_Products__r){              
              ListFutureProduct.add(futureprod);
              FutureProdMap.put(futureprod.Product__c,futureprod.Pricebook_Entry_Id__c);
              /*if(oldOLIToFPMap.containsKey(futureprod.Opportunity_Product_Id__c)){
                oldOLIToFPMap.get(futureprod.Opportunity_Product_Id__c).add(futureprod);
              }
              else{
                  oldOLIToFPMap.put(futureprod.Opportunity_Product_Id__c,new list<Future_Product__c>{futureprod})  ;
              }
              System.debug('Future**' + ListFutureProduct);
              System.debug('oldOLIToFPMap' + oldOLIToFPMap);*/
          }
           
        }
        
        ListOrder = [select id,CurrencyIsoCode,(SELECT Order.id,CurrencyIsoCode,List_Price__c,PricebookEntryId,PricebookEntry.Product2Id,PriceBookEntry.Product2.Name,Quantity,UnitPrice,ListPrice,Platform__c,Basis_of_Fees__c,Usage_Allowance__c,Total_Equivalent_Units__c,Package__c,Proposition__c,Renewable__c,Service_End_Date__c,Opportunity_Product_Id__c FROM Orderitems) from Order where Opportunity.id=:oppId];
        
        if(ListOrder.size()>0)
        {
            for(Order order:ListOrder)
            {
                if(order.orderitems.size()>0)
                {
                    for(OrderItem orderitem:order.orderitems)
                    {
                        OrderItemToDelete.add(orderitem);
                        OrderItemMap.put(orderitem.id,orderitem.PricebookEntry.Product2Id);
                    }
                }
            }
        }
    }

    Public void CreateOpportunityLineItems(){
        for(Pricebookentry PBE:[SELECT id, CurrencyIsoCode,Name,Pricebook2Id,Product2Id,UnitPrice,UseStandardPrice FROM PricebookEntry where id in:PricebookentrySet ]){
            Product2Set.add(PBE.Product2Id);
            Pricebook2Set.add(PBE.Pricebook2Id);
            PricebookEntryMap1.put(PBE.Product2Id,PBE);
        }
        
        for(Pricebookentry PBE1:[SELECT id, CurrencyIsoCode,Name,Pricebook2Id,Product2Id,UnitPrice,UseStandardPrice FROM PricebookEntry where Pricebook2Id in:Pricebook2Set and Product2Id in:Product2Set and CurrencyIsoCode=:SelectedCurrency ]){
            PricebookentryMap.put(PBE1.Product2Id,PBE1);
        }
        
        //Creating new OpportunityLineItems with new PricebookEntry       
        if(PricebookentryMap.size()>0 && OpportunityLineItemMap.size()>0 ){
            for(OpportunityLineItem OLI1:OpportunityLineItemToDelete){     
                  
                OpportunityLineItem OLIinsert=new OpportunityLineItem();            
                OLIinsert.Description =OLI1.Description ;
                OLIinsert.Invoice_Date__c =OLI1.Invoice_Date__c ;
                OLIinsert.OpportunityId =OLI1.OpportunityId ;
                OLIinsert.start_date__c=OLI1.start_date__c;
                OLIinsert.end_date__c=OLI1.End_date__c;
                OLIinsert.PricebookEntryId =PricebookentryMap.get(OpportunityLineItemMap.get(OLI1.id)).Id;
                OLIinsert.Platform__c =OLI1.Platform__c ;
                OLIinsert.Quantity =OLI1.Quantity ;
                OLIinsert.ServiceDate =OLI1.ServiceDate ;
                OLIinsert.TotalPrice =OLI1.TotalPrice ;
                OLIinsert.Hiring_Need__c =OLI1.Hiring_Need__c ;   
                OLIinsert.Imported_from_Rate_Card_c__c =OLI1.Imported_from_Rate_Card_c__c ;
                OLIinsert.List_Price__c =OLI1.List_Price__c ;  
                OLIinsert.Contract_Year__c  = OLI1.Contract_Year__c ;
                 OLIinsert.Package__c = OLI1.Package__c ;
                 OLIinsert.Proposition__c = OLI1.Proposition__c  ;
                OLIinsert.Level__c =OLI1.Level__c ;     
                OLIinsert.Package_Level__c =OLI1.Package_Level__c ;
                OLIinsert.Talent_Level__c =OLI1.Talent_Level__c ;   
                OLIinsert.Total_Discount__c =OLI1.Total_Discount__c ;
                OLIinsert.Volume__c =OLI1.Volume__c ;   
                OLIinsert.Year_1_Discount__c =OLI1.Year_1_Discount__c ;
                OLIinsert.Year_1_List_Price__c =OLI1.Year_1_List_Price__c ;   
                OLIinsert.Year_1_Sales_Price__c =OLI1.Year_1_Sales_Price__c ;
                OLIinsert.Year_2_Discount__c =OLI1.Year_2_Discount__c ;   
                OLIinsert.Year_2_List_Price__c =OLI1.Year_2_List_Price__c ;
                OLIinsert.Year_2_Sales_Price__c =OLI1.Year_2_Sales_Price__c ;   
                OLIinsert.Year_3_Discount__c =OLI1.Year_3_Discount__c ;
                OLIinsert.Year_3_List_Price__c =OLI1.Year_3_List_Price__c ;   
                OLIinsert.Year_3_Sales_Price__c =OLI1.Year_3_Sales_Price__c ;                                
                 //changes added by dimpy
                OLIinsert.Renewable__c=OLI1.Renewable__c;
                OLIinsert.Basis_of_Fees__c=OLI1.Basis_of_Fees__c;
                OLIinsert.Other__c=OLI1.Other__c;
                OLIinsert.Usage_Allowance__c=OLI1.Usage_Allowance__c;
                OLIinsert.Usage_Cap_or_Estimation__c=OLI1.Usage_Cap_or_Estimation__c; 
                OLIinsert.Solution_Cap__c = OLI1.Solution_Cap__c;
                OLIinsert.RenewableNew__c = OLI1.RenewableNew__c;
                OLIinsert.Contract_Value__c = OLI1.Contract_Value__c;
                OLIinsert.Total_Equivalent_Units__c = OLI1.Total_Equivalent_Units__c;
                OLIinsert.CurrencyChange__c = true;
                           
                OpportunityLineItemToInsert.add(OLIinsert);
                OldandNewOLIMap.put(OLI1.id,OLIinsert);
            }
          }

    }
    Public void CreateOrderLineItems(){
        //Creating new Orderitems with new PricebookEntry  
         
        if(PricebookEntryMap.size()>0 && OrderItemMap.size()>0 ){
            for(OrderItem orderitem:OrderItemToDelete){     
                  
                OrderItem orderitemInsert=new OrderItem();            
                orderitemInsert.orderid = orderitem.order.id;
                orderitemInsert.PricebookEntryId =PricebookEntryMap.get(OrderItemMap.get(orderitem.id)).Id;
                orderitemInsert.Quantity = orderitem.Quantity;
                orderitemInsert.UnitPrice = orderitem.UnitPrice;
                orderitemInsert.List_Price__c = orderitem.List_Price__c;
                orderitemInsert.Platform__c = orderitem.Platform__c;
                orderitemInsert.Basis_of_Fees__c = orderitem.Basis_of_Fees__c;
                orderitemInsert.Usage_Allowance__c = orderitem.Usage_Allowance__c;
                orderitemInsert.Total_Equivalent_Units__c = orderitem.Total_Equivalent_Units__c;
                orderitemInsert.Package__c = orderitem.Package__c;
                orderitemInsert.Proposition__c = orderitem.Proposition__c;
                orderitemInsert.Renewable__c = orderitem.Renewable__c;
                orderitemInsert.Service_End_Date__c = orderitem.Service_End_Date__c;
                orderitemInsert.Opportunity_Product_Id__c = orderitem.Opportunity_Product_Id__c;
                           
                OrderItemToInsert.add(orderitemInsert);       
            }
          }

    }

    Public void UpdateNewCurrencyOnOpportunity(){
        getAllCurrencyTypes();       
        FindRelatedRecords();
        CreateOpportunityLineItems();
        
        System.debug('List of Order items1 '+orderitemToInsert);
        
        if(Opportunity.Opportunity_Deal_Year__c != 1){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'The currency of this opportunity cannot be changed as it is not a single year opportunity')); 
            return;
        }
        
        if((Opportunity.StageName=='Closed/Won' || Opportunity.StageName=='Closed Lost' )&&(!((userinfo.getProfileId() .contains( Profile_Ids__c.getvalues('System Administrator').ID__c ))||(userinfo.getProfileId().contains(Profile_Ids__c.getvalues('System Administrator Globus').ID__c)) ||(userinfo.getProfileId().contains(Profile_Ids__c.getvalues('System Administrator GSD').ID__c) )||(userinfo.getProfileId().contains(Profile_Ids__c.getvalues('System Administrator Password Immune').ID__c) )) )){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Currency of Closed Won or Closed Lost Opportunities cannot be changed')); 
            return;
        }
    
        if(SelectedCurrency==opportunity.CurrencyIsoCode){                
             OpportunityLineItemToDelete.clear();
             OpportunityLineItemToInsert.clear();
             OrderitemToDelete.clear();
             OrderitemToInsert.clear();
             ListProjectToUpdate.clear();
             ListProject.clear();
             ProductsUpdated.clear();
             ListFutureProduct.clear();
             ListFutureProductToUpdate.clear();
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'This is already the currency of the Opportunity. Please choose a different currency OR Cancel it !'));
        }
        else{     
            Savepoint sp = Database.setSavepoint();
            try{           
                opportunity.skip_validation__c=True;                    // Set off the PriceBookentry_Required_OppMakingContact validation rule
                update opportunity;
                System.debug('**OpportunityLineItemToDelete :'+OpportunityLineItemToDelete );
                opportunity.Change_Currency__c = true;             // Set checkbox true. Added by pankhuri to avoid OppLineItem trigget to fire on delete. To avoid future prod deletion
                update opportunity;
                             
                Delete OpportunityLineItemToDelete ;
                opportunity.CurrencyIsoCode=SelectedCurrency;
                update opportunity;
                
                Insert OpportunityLineItemToInsert;
                opportunity.Change_Currency__c = false;          // Set checkbox to false once line items gets added.
                update opportunity;
                ProductsUpdated.clear();
                
                for(OpportunityLineItem OLI1: opportunity.OpportunityLineItems){
                    ProductsUpdated.add(OLI1.PriceBookEntry.Product2.name);                   
                }
                
                Opportunity Reopp =[select id,Change_Currency__c,name,ContractId,Owner.email,Order_Number__c,Order_Status__c, StageName,currencyIsocode,(SELECT CurrencyIsoCode,PricebookEntry.Product2Id,PriceBookEntry.Product2.Name,OpportunityId,PricebookEntryid FROM OpportunityLineItems) from opportunity where id=:oppId]; // after insert again get the line items
                for(OpportunityLineItem OLI1: Reopp.OpportunityLineItems){
                     NewInsertedLineItemMap.put(OLI1.PricebookEntry.Product2Id,OLI1.PriceBookEntry.id); // New Items inserted map.
                     System.debug('Map**' + NewInsertedLineItemMap);
                }
                
                opportunity.skip_validation__c=False;                    // Turn On the PriceBookentry_Required_OppMakingContact validation rule
                update opportunity;        
                                
                System.debug('ListFutureProduct** ' + ListFutureProduct);
                for(Future_Product__c FP : ListFutureProduct){                   
                    System.debug('hello**');
                    System.debug('Currency**' +  SelectedCurrency);
                    FP.currencyIsocode = SelectedCurrency;                    
                    FP.Pricebook_Entry_Id__c = NewInsertedLineItemMap.get(FP.Product__c);
                    FP.Opportunity_Product_Id__c = OldandNewOLIMap.get(FP.Opportunity_Product_Id__c).id;
                    System.debug('EntryId**' +  FP.Pricebook_Entry_Id__c);
                    ListFutureProductToUpdate.add(FP);
                }
                //delete ListFutureProduct; // we need to delete the old as it will be created from createfutureservice from opplineitem trigger
                update ListFutureProductToUpdate;
                list<opportunitylineitem> olistoupdate = new list<opportunitylineitem>();
                for(opportunitylineitem oli : OpportunityLineItemToInsert){
                    oli.CurrencyChange__c = false;
                    olistoupdate.add(oli);
                }
                if(olistoupdate.size()>0){
                    update olistoupdate;
                }
                
                            
                
                for( ProjectObject__c PR:ListProject){
                     PR.CurrencyChangeEmailAlertInitiater__c =system.now(); // Update the CurrencyChangeEmailAlertInitiater__c feild of the Project to intiate email alert
                     ListProjectToUpdate.add(PR);
                }
                Update ListProjectToUpdate;
                      
                list<opportunity> OppList= [Select Id, Name,CurrencyIsoCode, (Select Id, Discount_Amount__c,CurrencyIsoCode from Discount_Summaries__r) from opportunity where id=:oppid AND Recordtype.id='012D0000000KN0HIAW'];
                if(opplist.size()>0){
                 for(opportunity Opp:OppList){   
                   List<Discount_Summary__c > DiscountSumarry=new List<Discount_Summary__c >();
                   Opp.CurrencyIsoCode=SelectedCurrency;
                       for(Discount_Summary__c DiscountSumarryCurrency:Opp.Discount_Summaries__r){
                           DiscountSumarryCurrency.CurrencyIsoCode=Opp.CurrencyIsoCode;
                           DiscountSumarry.add(DiscountSumarryCurrency);
                           Update  DiscountSumarry;                                         
                        }           
                  } // Update Discount Summary with new currency
                }    
                
                if(opportunity.ContractId != null){
                System.debug('Id** ' + opportunity.ContractId);
                    Id conid = opportunity.ContractId;
                    List<Order> o = [Select id,ContractId from Order where ContractId =: conid AND OpportunityId =: OppId];
                    con = [Select id,currencyisocode,Total_Contract_Value__c from Contract where id =: opportunity.ContractId]; 
                    System.debug('Order** ' + o);
                    if(o.size() == 0){                                                
                        con.currencyisocode = SelectedCurrency;
                        //con.Total_Contract_Value__c = opportunity.Future_Product_Total_Price__c + opportunity.Amount;
                        Update con;
                    } // Update contract currency if no order is linked to contract
                    else{       
                     System.debug('con **' + con);
                            System.debug('opportunity**' + opportunity);
                        if(con != null && opportunity!=null) {        
                            Map<String, Object> inputs = new Map<String, Object>();
                           
                            inputs.put('ContractId', con);
                            inputs.put('OpportunityID', opportunity);
                            
                            Flow.Interview.Order_Contract_Currency_Change myFlow = new Flow.Interview.Order_Contract_Currency_Change(inputs);
                            myFlow.start();
                        }
                    }
                } 
                else  // contract id is null but
                {
                    Delete orderItemTodelete;
                    for(Order order:ListOrder)
                    {
                        order.CurrencyIsoCode = SelectedCurrency;
                        OrdersToUpdate.add(order);
                    }
                    Update OrdersToUpdate;
                    CreateOrderLineItems();
                    Insert orderitemToInsert;
                    
                }
                
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'The currency has successfully been changed to '+opportunity.CurrencyIsoCode+' on the Opportunity !'));               
           }
           catch(Exception e){
                Database.rollback(sp);
                ProductsUpdated.clear();
                
                string exceptionError=string.valueof(e);
                System.debug('ERROR***'+exceptionError);
                if(exceptionError.contains('FIELD_FILTER_VALIDATION_EXCEPTION') || exceptionError.contains('End_Date__c') || exceptionError.contains('Start_Date__c') || exceptionError.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                   System.debug('ERROR***'+e);
                   ApexPages.addMessages(e); 
                }
                else if(exceptionError.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Pricebook entry is required if the Opportunity stage is Information Gathering or beyond')) // Stage updated from Engage/Diagnose By Priyank
                {
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Pricebook entry is required if the Opportunity stage is Information Gathering or beyond ' )); // Stage updated from Engage/Diagnose By Priyank
                }
            }  // CATCH END            
         } // ELSE END
    }// METHOD END
}