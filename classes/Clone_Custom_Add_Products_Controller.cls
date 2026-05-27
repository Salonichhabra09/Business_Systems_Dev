public with sharing class Clone_Custom_Add_Products_Controller  {
    // Variables Decleration : START
    public Opportunity currentopp {get;set;}
    public list<FutureProductWrapper> FPWList{get;set;}
    public list<Future_Product__c> FutureProductsToUpsert{get;set;}
    public list<Future_Product__c> productsToDelete = new list<Future_Product__c>();
    public Integer rowIndex {get;set;}
    public list<SelectOption>AvailableProductList{get;set;}
    public list<SelectOption>AvailableConYearsList{get;set;}
    public Map<Id,Id> prodIdToPBEntryIDmap;
    public Map<id,string> prodIdToProdNamemap;
    public String JsonMap{get;set;}
    public boolean createDeleteFlag{get;set;}
    public boolean showflag{get;set;}
    public Map<id,OpportunityLineItem> prodIdToOLIMap;
    public Map<id,list<Future_Product__c>> prodIdToFPMap;
    public Map<Integer,list<Future_Product__c>> yearWiseProductMap;
    public set<id> subProdIdSet;
    public integer noOfProducts{
        get{
        return FPWList.size();
        }
                                set;}
    
    //public boolean subscriptionFlag{get;set;} // Added by pankhuri
    //public list<Future_Product__c> SubscriptionFutureProduct = new list<Future_Product__c>(); // Added by pankhuri
    // Variables Decleration : END
    
    public Clone_Custom_Add_Products_Controller(ApexPages.StandardController stdController) {
        // Variables Initialization : START
        createDeleteFlag = true;
        rowIndex = 0;    
        showflag = true;  
        FPWList = new list<FutureProductWrapper>();
        prodIdToOLIMap = new Map<id,OpportunityLineItem>();
        prodIdToPBEntryIDmap = new Map<Id,Id>();
        prodIdToProdNamemap = new Map<Id,string>();
        prodIdToFPMap = new Map<id,list<Future_Product__c>>();
        yearWiseProductMap = new Map<Integer,list<Future_Product__c>>();
        AvailableProductList = new list<SelectOption>();
        AvailableConYearsList = new list<SelectOption>();
        AvailableProductList.add(new SelectOption('','--- select a product ---'));
        Schema.DescribeFieldResult fieldResult = Future_Product__c.Contract_Year__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        subProdIdSet = new set<id>();
        //Future_Product__c fp = (Future_Product__c)stdController.getRecord();
        currentopp = [SELECT Id,recordtypeid,contractid,CurrencyIsoCode,StageName,Name,Multi_YearDeal__c,Business_Type__c,Opportunity_Deal_Year__c,Original_Opportunity__c FROM Opportunity WHERE Id = :ApexPages.currentPage().getParameters().get('id')];//:ApexPages.currentPage().getParameters().get('id')'0063H000002MW8x'
        // Variables Initialization : END
        
        // IF opportunity multi year : START
        //system.debug('debug 1'+prodIdToProdNamemap);
        
        if(currentopp.RecordTypeId == '012D0000000KN0H'){
            showflag = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please edit or modify products from configurator API Tool for both current period and future period on ignite opportunity'); 
            ApexPages.addMessage(myMsg);  
        }
        
        else{
        
        if(currentopp.Multi_YearDeal__c !=null && currentopp.Multi_YearDeal__c != '' && currentopp.Multi_YearDeal__c != '1'){
            
        for(Future_Product__c fupr : [select id,Service_End_Date__c,CurrencyIsoCode,Contract_Value__c,name,
                                      //Changes added by Prachi (SSE-SSE-17449)                
                                      Number_of_Services__c,
                                      //Changes End Prachi (SSE-SSE-17449)
                                      Opportunity__c,Product__c,Product__r.name,RenewableNew__c,Contract_Year__c,
                                      Quantity__c,ListPrice__c,Sales_Price__c,Line_Description__c,Platform__c,Basis_of_Fees__c,Other__c,Usage_Allowance__c,Usage_Cap_or_Estimation__c,Proposition__c,Package__c,Booking_Type__c,Solution_Cap__c from Future_Product__c where Opportunity__c = :currentopp.id]){
            if(fupr.RenewableNew__c != 'Ongoing'){ //fupr.Product__r.Revenue_Category__c != 'Subscription'
                FPWList.add(new FutureProductWrapper(fupr,fupr.Product__c,fupr.Product__r.name,fupr.Contract_Year__c,false)); // Modified by Pankhuri
            }
            else{
                FPWList.add(new FutureProductWrapper(fupr,fupr.Product__c,fupr.Product__r.name,fupr.Contract_Year__c,true));   
                subProdIdSet.add(fupr.Product__c);
            }
        }
        
        for(OpportunityLineItem oli : [select Product2id,Product2.name,
                                       //Changes added by Prachi (SSE-SSE-17449)
                                       Number_of_Services__c,
                                       //Changes End Prachi (SSE-SSE-17449)
                                       RenewableNew__c,Solution_Cap__c,Service_End_Date__c,pricebookentryid,UnitPrice,Contract_Year__c,Quantity,List_Price__c,Description,Platform__c,Basis_of_Fees__c,Other__c,Usage_Allowance__c,Usage_Cap_or_Estimation__c,Proposition__c,Package__c,Booking_Type__c from OpportunityLineItem where opportunityid = :currentopp.id]){
            
            prodIdToPBEntryIDmap.put(oli.Product2id,oli.pricebookentryid);
            prodIdToOLIMap.put(oli.Product2id,oli);
            prodIdToProdNamemap.put(oli.Product2Id,oli.product2.name);
            
            if(oli.RenewableNew__c != 'Ongoing') //oli.Product2.Revenue_Category__c != 'Subscription' ||
                AvailableProductList.add(new SelectOption(oli.Product2Id,oli.product2.name));
            /*if(oli.RenewableNew__c == 'Ongoing' && !subProdIdSet.contains(oli.Product2Id)){ //oli.Product2.Revenue_Category__c == 'Subscription' &&  
                for(integer i=1; i<integer.valueOf(currentopp.Multi_YearDeal__c); i++){
                    FPWList.add(new FutureProductWrapper(new Future_Product__c(Opportunity__c = currentopp.id,
                                                                               Product__c = oli.Product2id,
                                                                               Contract_Year__c = String.Valueof(i+1),                                                                              
                                                                               Quantity__c = oli.Quantity,
                                                                               ListPrice__c = oli.List_Price__c,
                                                                               Sales_Price__c = oli.UnitPrice,
                                                                               Line_Description__c = oli.Description,
                                                                               Platform__c = oli.Platform__c,
                                                                               Basis_of_Fees__c = oli.Basis_of_Fees__c,
                                                                               Other__c = oli.Other__c,
                                                                               Usage_Allowance__c = oli.Usage_Allowance__c,
                                                                               Usage_Cap_or_Estimation__c = oli.Usage_Cap_or_Estimation__c,
                                                                               Proposition__c = oli.Proposition__c,
                                                                               Package__c = oli.Package__c,
                                                                               Booking_Type__c = oli.Booking_Type__c,
                                                                               Service_End_Date__c = oli.Service_End_Date__c,
                                                                               Contract_Value__c = 0.0,
                                                                               CurrencyIsoCode = currentopp.CurrencyIsoCode),
                                                         oli.product2.id,oli.product2.name,String.Valueof(i+1),true));
                }
            }*/
        }
        
        for( Schema.PicklistEntry f : ple)
        {
            if(integer.valueOf(f.getValue())>1 && integer.valueOf(f.getValue())<=integer.valueOf(currentopp.Multi_YearDeal__c))
                AvailableConYearsList.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        if(currentopp.StageName == 'Closed/Won' || currentopp.StageName == 'Closed Lost'){     // Added by pankhuri on 7 Oct
            createDeleteFlag = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Products will be locked for any modification when Opportunity stage is Closed Won'); 
            ApexPages.addMessage(myMsg);
        }
        
        if(currentopp.Business_Type__c == 'Renewal' && currentopp.Opportunity_Deal_Year__c != 1){
            createDeleteFlag = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'You cannot Create/Delete Products of a Renewal Opportunity'); 
            ApexPages.addMessage(myMsg);
            for(OpportunityLineItem oli : [select Product2id,Product2.name,Service_End_Date__c,pricebookentryid,Quantity,List_Price__c,Description,Platform__c,Basis_of_Fees__c,Other__c,Usage_Allowance__c,Usage_Cap_or_Estimation__c,Proposition__c,Package__c,Booking_Type__c from OpportunityLineItem where opportunityid = :currentopp.Original_Opportunity__c]){
                prodIdToPBEntryIDmap.put(oli.Product2id,oli.pricebookentryid);
                AvailableProductList.add(new SelectOption(oli.Product2Id,oli.product2.name));
                prodIdToProdNamemap.put(oli.Product2Id,oli.product2.name);
                prodIdToOLIMap.put(oli.Product2id,oli);
            }
        }
            
        // Code for sorting FutureProductWrapperList to put subscription products at Top : START
        list<FutureProductWrapper> templist1 = new list<FutureProductWrapper>();
        list<FutureProductWrapper> templist2 = new list<FutureProductWrapper>();
        for(FutureProductWrapper fpw : FPWList){
            if( fpw.fp.RenewableNew__c == 'Ongoing'){ //fpw.fp.Product__r.Revenue_Category__c == 'Subscription' &&
                templist1.add(fpw);
            }
            else{
               templist2.add(fpw); 
            }
        }
        FPWList.clear();
        FPWList.addAll(templist1);
        FPWList.addAll(templist2);
        JsonMap=JSON.serialize(prodIdToOLIMap);
        // Code for sorting FutureProductWrapperList to put subscription products at Top : END
        }// IF opportunity multi year : END
        else{ // IF opportunity not multi year : START
            //system.debug('here');
            showflag = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Future Section is available only for Multi Year Opportunities'); 
            ApexPages.addMessage(myMsg);
        }
        }
        // IF opportunity not multi year : END
        //for(FutureProductWrapper fpw : FPWList){
        //   system.debug('fpw:'+fpw);
        //}
    }
    
    /*public void addProduct(){
        FPWList.add(new FutureProductWrapper(new Future_Product__c(Opportunity__c = currentopp.id
                                                                   ,Product__c = null
                                                                   ,Contract_Year__c = ''
                                                                   ,Quantity__c = null
                                                                   ,ListPrice__c = null
                                                                   ,Sales_Price__c = null
                                                                   ,Line_Description__c = ''
                                                                   ,Platform__c = ''
                                                                   ,Basis_of_Fees__c = ''
                                                                   ,Other__c = ''
                                                                   ,Usage_Allowance__c = ''
                                                                   ,Usage_Cap_or_Estimation__c = null
                                                                   ,Proposition__c = ''
                                                                   ,Package__c = ''
                                                                   ,Booking_Type__c = ''
                                                                   ,Contract_Value__c = null
                                                                   ,Service_End_Date__c = null
                                                                   ,RenewableNew__c = null
                                                                   ,CurrencyIsoCode = currentopp.CurrencyIsoCode),
                                                                    '','','',false));  //Modified by Pankhuri
    }
    
    public PageReference deleteRow(){
            rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
            if(FPWList.get(rowIndex).fp.id != null)
                productsToDelete.add(FPWList.get(rowIndex).fp);
            FPWList.remove(rowIndex);
            return null;
    }*/
    
    public PageReference saveProducts(){
        boolean flag = true;
        //system.debug('here 1');
        for(integer index = 0;index<FPWList.size();index++){
            //system.debug('here 2');
            //system.debug(index+'fpwlist'+FPWList.get(index));
            if(FPWList.get(index).prodid == ''|| FPWList.get(index).prodid == null){
               flag = false; 
            }
            if(FPWList.get(index).fp.Basis_of_Fees__c == null){
                flag = false;
            }
            if(FPWList.get(index).fp.quantity__c == null || FPWList.get(index).fp.quantity__c == 0){
                flag = false;
            }
            
             if(FPWList.get(index).fp.Number_of_Services__c == null){
                flag = false;
            }
            if(FPWList.get(index).fp.ListPrice__c == null){
                flag = false;
            }
            if(FPWList.get(index).fp.Sales_Price__c == null){
                flag = false;
            }
            if(FPWList.get(index).fp.Proposition__c == null || FPWList.get(index).fp.Proposition__c == ''){
                flag = false;
            }
            if(FPWList.get(index).fp.Package__c == null || FPWList.get(index).fp.Package__c == ''){
                flag = false;
            }
        }
        if(flag){
            //system.debug('here 3');
        FutureProductsToUpsert = new list<Future_Product__c>();
        
        for(FutureProductWrapper fpw : FPWList){
            fpw.fp.Product__c = fpw.prodid;
            fpw.fp.Contract_Year__c = fpw.selectedConYear;
            fpw.fp.CurrencyIsoCode = currentopp.CurrencyIsoCode;
            if(prodIdToPBEntryIDmap.keySet().contains(fpw.fp.Product__c)){
                fpw.fp.Pricebook_Entry_Id__c = prodIdToPBEntryIDmap.get(fpw.fp.Product__c);
            }
            if(prodIdToOLIMap.keySet().contains(fpw.fp.Product__c)){
                fpw.fp.RenewableNew__c = prodIdToOLIMap.get(fpw.fp.Product__c).RenewableNew__c;
            }
            
            //system.debug('prodIdToFPMap'+prodIdToFPMap);
            if(prodIdToFPMap != null && prodIdToFPMap.containsKey(fpw.fp.Product__c)){
                prodIdToFPMap.get(fpw.fp.Product__c).add(fpw.fp);
            }
            else{
                prodIdToFPMap.put(fpw.fp.Product__c,new list<Future_Product__c>{fpw.fp});
            }
            if(yearWiseProductMap != null && yearWiseProductMap.containsKey(integer.valueOf(fpw.fp.Contract_Year__c))){
                yearWiseProductMap.get(integer.valueOf(fpw.fp.Contract_Year__c)).add(fpw.fp);
            }
            else{
                yearWiseProductMap.put(integer.valueOf(fpw.fp.Contract_Year__c),new list<Future_Product__c>{fpw.fp});
            }
            FutureProductsToUpsert.add(fpw.fp);
        }
            //system.debug('prodIdToFPMap'+prodIdToFPMap);
            //system.debug('yearWiseProductMap'+yearWiseProductMap);
            for(integer i = 2;i<=integer.valueOf(currentopp.Multi_YearDeal__c) && !yearWiseProductMap.isEmpty();i++){
                //system.debug('yearWiseProductMap'+yearWiseProductMap);
                for(Future_Product__c fp : yearWiseProductMap.get(i)){
                    if(i==2){
                        fp.Contract_Value__c = prodIdToOLIMap.get(fp.Product__c).UnitPrice;
                    }
                    if(i>2){
                        //system.debug('here 1');
                        for(Future_Product__c fp2 : prodIdToFPMap.get(fp.Product__c)){
                            //system.debug('here 2');
                            if((integer.valueOf(fp2.Contract_Year__c)+1) == integer.valueOf(fp.Contract_Year__c)){
                                //system.debug('here 3');
                                fp.Contract_Value__c = fp2.Sales_Price__c;
                            }
                    }
                }
            }
            }
            
        try{
            if(productsToDelete.size()>0){
                delete productsToDelete;
            /*for(Future_Product__c fp : productsToDelete){
            system.debug('productsToDelete'+fp);
            }*/
            }
            if(FutureProductsToUpsert.size()>0){
                upsert FutureProductsToUpsert;
            /*for(Future_Product__c fp : FutureProductsToUpsert){
            system.debug('FutureProductsToUpsert'+fp);
            }*/
            }
        }
        catch(Exception e){
           //pexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,e.getMessage()); 
           //ApexPages.addMessage(myMsg);
            return null;
        }
        PageReference pg = new PageReference('/'+currentopp.id);
        pg.setRedirect(true);
        return pg;
        }
        return null;
    }
    
    public PageReference Cancelled(){
        PageReference pg = new PageReference('/'+currentopp.id);
        pg.setRedirect(true);
        return pg;
    }
       
    public class FutureProductWrapper{
        public Future_Product__c fp{get;set;} 
        public String prodid{get;set;}
        public String prodname{get;set;}
        public String selectedConYear{get;set;}
        public boolean subs{get;set;} // Added by pankhuri for Subscription flag check
        FutureProductWrapper(Future_Product__c fp,string prodid,string prodname,string selectedConYear,boolean subs){
            this.fp = fp;
            this.prodid = prodid;
            this.prodname = prodname;
            this.selectedConYear = selectedConYear;
            this.subs = subs; // Added by pankhuri for Subscription flag check
        }
    }
}