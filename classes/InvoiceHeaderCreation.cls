public class InvoiceHeaderCreation {
    static list<Integer> MonthsToAddList = new list<Integer>{3, 6, 3};
    static list<Integer> invoicePriceModifierList = new list<Integer>{25, 50, 25};
        static list<String> serviceInvoiceNameList = new list<String>{'25% up front', '50% on milestones', '25% on completion'};
    static Integer NumberOfIH = 1;
    static Integer MonthsToAdd = 12;
    static List<Contract_Invoice_Header__c> InvoiceHeaderToInsert = new List<Contract_Invoice_Header__c>();
    static List<Contract_Invoice_Line__c> InvoiceLines = new List<Contract_Invoice_Line__c>();
    static List<Orderitem> serviceProducts = new list<Orderitem>();
    static List<Orderitem> nonServiceProducts = new list<Orderitem>();
    static List<Orderitem> mSServiceProducts = new list<Orderitem>();
	static List<Orderitem> onlyServiceProducts = new list<Orderitem>();
        
    @AuraEnabled
        public static void CreateInvoiceHeaders(Id OrderId,String ProductBillingFrequency,String ServiceBillingFrequency,String PaymentTerms) {
        
        Order order =[select BU__c,BillToContactId,AccountId,CurrencyIsoCode,PoNumber,EffectiveDate,EndDate,ContractId,Order_Year__c,Course_Booking__c
                      from order 
                      where id=:OrderId limit 1 ];
        

        // Changes start for SSE-17452 (Added by Jai Khandelwal)
        Integer numberOfMonths;
        Decimal numberOfYears;
        List<Contract> contractList = [Select StartDate,Contract_End_Date__c,Subscription_Start_Date__c 
                                       From Contract 
                                       WHERE Id=:order.ContractId];
        if(contractList.size()>0){
            numberOfMonths = contractList[0].Subscription_Start_Date__c.monthsBetween(contractList[0].Contract_End_Date__c);
            numberOfYears = Math.ceil(Decimal.valueOf(numberOfMonths).divide(12,1));
        }
        if(numberOfYears==order.Order_Year__c && contractList.size()>0){
            Integer numberOfMonthsInLastYear =0;
            if(numberOfYears==1){
                numberOfMonthsInLastYear = contractList[0].Subscription_Start_Date__c.monthsBetween(contractList[0].Contract_End_Date__c);
            }
            else{
                numberOfMonthsInLastYear = order.EffectiveDate.monthsBetween(contractList[0].Contract_End_Date__c);
            }
            if(ProductBillingFrequency=='Bi-annual'){
                NumberOfIH = (Integer)Math.ceil(Decimal.valueOf(numberOfMonthsInLastYear).divide(6,1));
                MonthsToAdd = 6;
            }
            
            else if(ProductBillingFrequency=='Quarterly'){
                NumberOfIH = (Integer)Math.ceil(Decimal.valueOf(numberOfMonthsInLastYear).divide(3,1));
                MonthsToAdd = 3;
            }
            
            else if(ProductBillingFrequency=='Monthly'){
                NumberOfIH = numberOfMonthsInLastYear;
                MonthsToAdd = 1;
            }
        }
        else{
        if(ProductBillingFrequency=='Bi-annual'){
            NumberOfIH = 2;
            MonthsToAdd = 6;
        }
        
        else if(ProductBillingFrequency=='Quarterly'){
            NumberOfIH = 4;
            MonthsToAdd = 3;
        }
        
        else if(ProductBillingFrequency=='Monthly'){
            NumberOfIH = 12;
            MonthsToAdd = 1;
        }
    }
     // Changes end for SSE-17452 (Added by Jai Khandelwal)   
        
        List<Orderitem> OrderProducts = [select Id,Platform__c,Total_Price__c,TotalPrice,Usage_Allowance__c,UnitPrice,Basis_of_Fees__c,
                                         Product2.Revenue_Category__c,OrderId,Package__c,Product2.Name,Product2.StockKeepingUnit,
                                         Quantity,Proposition__c, Product2.MS_Product__c 
                                         from orderitem 
                                         where OrderId=:OrderId];
        List<Orderitem> PSOrderProducts = new List<Orderitem>();
        List<Orderitem> NonPSOrderProducts = new List<Orderitem>();
        List<Orderitem> MSServiceOrderProducts = new List<Orderitem>();

        // Changes start for SSE-17452 (Added by Jai Khandelwal)
        Date InvoiceStartDatetemp = order.EffectiveDate;
        Date InvoiceStartDateForProducts;

        if(order.Order_Year__c==1 && contractList.size()>0){
            InvoiceStartDateForProducts = contractList[0].Subscription_Start_Date__c;
        }
        else{
            InvoiceStartDateForProducts = order.EffectiveDate;
        }
         // Changes end for SSE-17452 (Added by Jai Khandelwal)
        /* START Changes for Invoice Header split Story 09 August 2022 by Aashi */

        for(OrderItem orderItem : OrderProducts){
            if(orderItem.UnitPrice!=0){
                if(orderItem.Package__c == 'Service'){
                //if(orderItem.Product2.MS_Product__c){
                    if(orderItem.Product2.Revenue_Category__c == 'Professional Services'){
                        //mSServiceProducts.add(orderItem);
                        serviceProducts.add(orderItem);
                    }else if(orderItem.Product2.Revenue_Category__c == 'Managed Services' && orderItem.Product2.MS_Product__c){
                        mSServiceProducts.add(orderItem);
                    }else{
                        //serviceProducts.add(orderItem);
                        onlyServiceProducts.add(orderItem);
                    }
                }else{
                    nonServiceProducts.add(orderItem);
                }
            }
        }
        
        /*if(mSServiceProducts.size() > 0){
            createInvoiceHeadersList(order, 1, 12, InvoiceStartDatetemp, 'MS Service', mSServiceProducts);
        }
        if(serviceProducts.size() > 0){
            if(ServiceBillingFrequency == '25% up front, 50% on milestones, 25% on completion'){
                createInvoiceHeadersList(order, 3, 0, InvoiceStartDatetemp, 'Service', serviceProducts);
            }else{
                createInvoiceHeadersList(order, 1, 12, InvoiceStartDatetemp, 'Other Services', serviceProducts);
            } 
        }*/
         // Changes start for SSE-17452 (Added by Jai Khandelwal)
        if(nonServiceProducts.size() > 0){
            createInvoiceHeadersList(order, NumberOfIH, MonthsToAdd, InvoiceStartDateForProducts, 'Non-Service', nonServiceProducts,PaymentTerms);
        }
         // Changes end for SSE-17452 (Added by Jai Khandelwal)
        list<Contract_Invoice_Header__c> existingInvoiceHeader = new list<Contract_Invoice_Header__c>();
        existingInvoiceHeader = [Select id from Contract_Invoice_Header__c where Order__c=:OrderId and Invoice_Name__c like 'Invoice 1 of%' LIMIT 1];
        System.debug('existingInvoiceHeader Size --> '+ existingInvoiceHeader.size());
        
        if(onlyServiceProducts.size() > 0){
            if(existingInvoiceHeader.size() == 0){
                createInvoiceHeadersList(order, 1, 12, InvoiceStartDatetemp, 'Other Service', onlyServiceProducts, PaymentTerms);
            }else{
                computeLogic(1, onlyServiceProducts, existingInvoiceHeader, 'Other Service');
                insertInvoiceLines();
            }
        }
        if(mSServiceProducts.size() > 0){
            if(existingInvoiceHeader.size() == 0){
                createInvoiceHeadersList(order, 1, 12, InvoiceStartDatetemp, 'MS Service', mSServiceProducts, PaymentTerms);
            }else{
                computeLogic(1, mSServiceProducts, existingInvoiceHeader, 'MS Service');
                insertInvoiceLines();
            }
        }
        if(serviceProducts.size() > 0){
            if(ServiceBillingFrequency == '25% up front, 50% on milestones, 25% on completion'){
                if(existingInvoiceHeader.size() == 0){
                    createInvoiceHeadersList(order, 3, 0, InvoiceStartDatetemp, 'Service', serviceProducts, PaymentTerms);
                }else{
                    InvoiceStartDatetemp=InvoiceStartDatetemp.addMonths(3);
                    createInvoiceHeadersList(order, 2, 0, InvoiceStartDatetemp, 'Service', serviceProducts, PaymentTerms);
                    computeLogic(1, serviceProducts, existingInvoiceHeader, 'Service');
                    insertInvoiceLines();
                }
            }else if(ServiceBillingFrequency == 'Upon completion'){
                // Separate Invoice Header for PS + Service
                createInvoiceHeadersList(order, 1, 12, InvoiceStartDatetemp, 'PS Service', serviceProducts, PaymentTerms);
            }else if(ServiceBillingFrequency == 'Special Invoicing Instructions' || ServiceBillingFrequency == 'Invoice per milestone'){
                // Separate Invoice Header for PS + Service
                createInvoiceHeadersList(order, 1, 12, InvoiceStartDatetemp, 'PS Service', serviceProducts, PaymentTerms);
            }else{
                if(existingInvoiceHeader.size() == 0){
                    createInvoiceHeadersList(order, 1, 12, InvoiceStartDatetemp, 'PS Service', serviceProducts, PaymentTerms);
                }else{
                    computeLogic(1, serviceProducts, existingInvoiceHeader, 'Other Services');
                    insertInvoiceLines();
                }
            } 
        }

        /* END Changes for Invoice Header split Story 09 August 2022 by Aashi */

        
    }
    
    /* START Changes for Invoice Header split Story 09 August 2022 by Aashi */

    public static Contract_Invoice_Header__c createSingleInvoiceHeader(Order order, Integer MonthsToAdd, Date InvoiceStartDatetemp, String invoiceName, Boolean isFirstNonServiceInvoice, String PaymentTerms){

                                                                           
        Contract_Invoice_Header__c InvoiceHeader = new Contract_Invoice_Header__c();
        InvoiceHeader.Order__c = order.Id;
        InvoiceHeader.BU__c = order.BU__c;
        InvoiceHeader.Billing_Contact__c = order.BillToContactId;
        InvoiceHeader.Invoice_Account__c = order.AccountId;
        InvoiceHeader.Invoice_Contact__c = order.BillToContactId;
        InvoiceHeader.CurrencyIsoCode = order.CurrencyIsoCode;
        InvoiceHeader.Invoice_Status__c = 'Draft';
        InvoiceHeader.Is_Auto_Created__c = True;
        InvoiceHeader.PO_number__c = order.PoNumber;
        
        InvoiceHeader.Service_Start_Date__c = InvoiceStartDatetemp;
        InvoiceHeader.Process_Date__c = InvoiceStartDatetemp;
        InvoiceHeader.Service_End_Date__c = InvoiceStartDatetemp.addMonths(MonthsToAdd).addDays(-1);
        InvoiceHeader.Invoice_Name__c = invoiceName;
        InvoiceHeader.GSSC_Instructions__c = PaymentTerms;                                                                   
        if(isFirstNonServiceInvoice){
            InvoiceHeader.Process_Date__c = System.Today();
        }
		
        //Changes added by Joana Martins SSE-18687 / SSE-19407 
        if(order.Course_Booking__c != 'NA' && order.Course_Booking__c != '' && order.Course_Booking__c != null){
              Course_Booking__c  cb = [Select Invoice_Text_Description__c 
                      FROM Course_Booking__c 
                      Where Name =: order.Course_Booking__c LIMIT 1];
            
            InvoiceHeader.Invoice_Comments__c = cb.Invoice_Text_Description__c;
        }
        //end Changes
        
        return InvoiceHeader;

    }

    public static void createInvoiceHeadersList(Order order, Integer NumberOfIH, Integer MonthsToAdd, Date InvoiceStartDatetemp, String isService, List<Orderitem> productList, String PaymentTerms){
        
        String invoiceName;
       
        List<Orderitem> tempProdList = new List<Orderitem>();
        
        for(Integer i=1;i <= NumberOfIH;i++)
        { 
            Integer indexVar;
            Boolean isFirstNonServiceInvoice = false;
            System.debug('###@@@ i --> '+ i);
            invoiceName = 'Invoice ' + i + ' of ' + NumberOfIH;
            //if(isService == 'Service' || isService == 'Other Services'){
            if(isService == 'Service'){
                indexVar = Math.mod(NumberOfIH, 2)==0 ? Math.mod(i,NumberOfIH) : (i-1);
                MonthsToAdd = MonthsToAddList[indexVar];
                //invoiceName = 'Service ' + invoiceName + ' (' + invoicePriceModifierList[indexVar] + '%)';
                invoiceName = 'Service ' + invoiceName + ' (' + serviceInvoiceNameList[indexVar] + ')';
            }
            if(isService == 'Other Services'){
                invoiceName = 'Service ' + invoiceName;
            }
            if(isService == 'Other Service'){
                invoiceName = 'Other Service';
            }
            if(isService == 'MS Service'){
                invoiceName = 'MS Service (100%)';
            }
            if(isService == 'PS Service'){
                invoiceName = 'PS Service (100%)';
            }
            //SSE-17588 - Uncomment this section before deployment
           /*if(isService == 'Non-Service' && i == 1){
                isFirstNonServiceInvoice = true;
            }*/
            //  SSE-17588 - Comment this section before deployment
            
            if(isService == 'Non-Service' && i == 1 && order.Order_Year__c == 1){
                isFirstNonServiceInvoice = true;
            }
			
            
            InvoiceHeaderToInsert.add(createSingleInvoiceHeader(order, MonthsToAdd, InvoiceStartDatetemp, invoiceName, isFirstNonServiceInvoice, PaymentTerms));
            //Changes added by Prachi SSE-14997
             Integer checkMonth = InvoiceStartDatetemp.month();
             Integer checkYear =  InvoiceStartDatetemp.year();	
            if(checkMonth == 2){
                if(Date.isLeapYear(checkYear)){
                    InvoiceStartDatetemp = InvoiceStartDatetemp=InvoiceStartDatetemp.addMonths(MonthsToAdd)+1;
                }
                else{
                    InvoiceStartDatetemp=InvoiceStartDatetemp.addMonths(MonthsToAdd)+2;
                }
            }
            else{ 
            InvoiceStartDatetemp=InvoiceStartDatetemp.addMonths(MonthsToAdd);
            }
            //Changes End SSE-14997
            //InvoiceStartDatetemp=InvoiceStartDatetemp.addMonths(MonthsToAdd);
        }

        /*if(InvoiceHeaderToInsert.size() > 0){
            insert InvoiceHeaderToInsert;
            // Need to work on this
            Integer i=0;
            //for(Contract_Invoice_Header__c InvoiceHeader : InvoiceHeaderToInsert){
            for(Integer j=0 ; j<InvoiceHeaderToInsert.size() ; j++){
                System.debug('###@@@ productList size --> '+ productList.size());
                for(Orderitem OrderProduct : productList){
                    if(OrderProduct.UnitPrice != 0){
                        if(isService == 'Service'){
                            NumberOfIH = 100/invoicePriceModifierList[i]; 
                        }
                        System.debug('###@@@ NumberOfIH --> '+ NumberOfIH);
                        InvoiceLines.add(CreateInvoiceLine(OrderProduct, InvoiceHeaderToInsert[j], NumberOfIH));
                    }
                    System.debug('************************* Change in Invoice Line *************************');
                }
                i++;
                System.debug('###@@@ After increment i --> '+ i);    
                System.debug('************************* Change in Invoice Header *************************');
            }
        }

        InvoiceHeaderToInsert.clear();
        */
        insertInvoiceHeadersList(NumberOfIH, productList, isService);
        /*if(InvoiceLines.size()>0){
            insert RemoveDuplicateLines(InvoiceLines);
            InvoiceLines.clear();
        }*/
        insertInvoiceLines();
    }

    public static void insertInvoiceHeadersList(Integer NumberOfIH, List<Orderitem> productList, String isService){
        if(InvoiceHeaderToInsert.size() > 0){
            insert InvoiceHeaderToInsert;
            computeLogic(NumberOfIH, productList, InvoiceHeaderToInsert, isService);
        }       
        InvoiceHeaderToInsert.clear();
    }

    public static void computeLogic(Integer NumberOfIH, List<Orderitem> productList, list<Contract_Invoice_Header__c> invoiceHeaderList, String isService){
        Integer indexVar, varIHTOCalculate, i=1;
        varIHTOCalculate = NumberOfIH;
        System.debug('###@@@ varIHTOCalculate --> '+ varIHTOCalculate);
        //for(Contract_Invoice_Header__c InvoiceHeader : invoiceHeaderList){
        for(Integer j=0 ; j<invoiceHeaderList.size() ; j++){
            System.debug('###@@@ productList size --> '+ productList.size());
            for(Orderitem OrderProduct : productList){
                if(OrderProduct.UnitPrice != 0){
                    if(isService == 'Service'){
                        System.debug('###@@@ Before increment i --> '+ i);
                        indexVar = Math.mod(varIHTOCalculate, 2)==0 ? Math.mod(i,varIHTOCalculate) : (i-1);
                        System.debug('indexVar --> '+indexVar);
                        NumberOfIH = 100/invoicePriceModifierList[indexVar]; 
                        System.debug('###@@@ NumberOfIH --> '+ NumberOfIH);
                    }
                    System.debug('###@@@ NumberOfIH --> '+ NumberOfIH);
                    InvoiceLines.add(CreateInvoiceLine(OrderProduct, invoiceHeaderList[j], NumberOfIH));
                }
            }
            i++;
            System.debug('###@@@ After increment i --> '+ i);
        }
    }

    public static void insertInvoiceLines(){
        if(InvoiceLines.size()>0){
            insert RemoveDuplicateLines(InvoiceLines);
            InvoiceLines.clear();
        }
    }
    
    /* END Changes for Invoice Header split Story 09 August 2022 by Aashi */

    public static Contract_Invoice_Line__c CreateInvoiceLine(Orderitem OrderProduct,Contract_Invoice_Header__c InvoiceHeader,Integer NumberOfIH){
        Contract_Invoice_Line__c InvoiceLine = new Contract_Invoice_Line__c();
        InvoiceLine.IsAutoCreated__c = True;
        InvoiceLine.Order_Product_Id__c = OrderProduct.Id;
        InvoiceLine.Platform__c = OrderProduct.Platform__c;
        InvoiceLine.ProductStream_SystemUse__c = OrderProduct.Product2.Revenue_Category__c;
        InvoiceLine.Usage_Allowance__c = OrderProduct.Usage_Allowance__c;
        InvoiceLine.Invoice_Header_ID__c = InvoiceHeader.Id;
        InvoiceLine.PriceCaculated__c = OrderProduct.TotalPrice/NumberOfIH;
        System.debug('InvoiceLine.PriceCaculated__c --> '+InvoiceLine.PriceCaculated__c);
        InvoiceLine.Solution_for_backend_use__c = OrderProduct.Product2.Name+OrderProduct.Product2.StockKeepingUnit+OrderProduct.Package__c+InvoiceHeader.Id;
        if(OrderProduct.Product2.Revenue_Category__c!='Product in advance' && OrderProduct.Product2.Revenue_Category__c!='Product in arrears'){
            InvoiceLine.QuantityFromOrderProduct__c = 1;
            InvoiceLine.Per_Unit_Price_Calculated__c = OrderProduct.TotalPrice/NumberOfIH; 
        }
        else{
            InvoiceLine.QuantityFromOrderProduct__c = OrderProduct.Quantity/NumberOfIH;
            InvoiceLine.Per_Unit_Price_Calculated__c = OrderProduct.UnitPrice;
        }
       
        return InvoiceLine;
    }
    
    @InvocableMethod(label='Remove Duplicate Invoice Lines' description='Returns the list of distinct Invoice Lines' category='Invoice Line')
    public static List<List<Contract_Invoice_Line__c>> RemoveDuplicateLinesInvocable(List<List<Contract_Invoice_Line__c>> InvoiceLinesList) {
        boolean match = false ;
        List<Contract_Invoice_Line__c> InvoiceLines = InvoiceLinesList.get(0);
        List<Contract_Invoice_Line__c> InvoiceLinesWithoutDuplicates = new List<Contract_Invoice_Line__c>(); 
        For(Integer i=0;i<InvoiceLines.size();i++ ){
            if(i==0){
                InvoiceLinesWithoutDuplicates.add(InvoiceLines[i]);
            } 
            else{
                for(Integer j=0;j<InvoiceLinesWithoutDuplicates.size();j++){
                    if(InvoiceLines[i].Solution_for_backend_use__c==InvoiceLinesWithoutDuplicates[j].Solution_for_backend_use__c){
                        match = true;
                        /*if(InvoiceLines[i].ProductStream_SystemUse__c!='Product in advance' && InvoiceLines[i].ProductStream_SystemUse__c!='Product in arrears'){
                            InvoiceLinesWithoutDuplicates[j].PriceCaculated__c = InvoiceLinesWithoutDuplicates[j].PriceCaculated__c+InvoiceLines[i].PriceCaculated__c; 
                            System.debug('InvoiceLinesWithoutDuplicates[j].Per_Unit_Price_Calculated__c--->'+InvoiceLinesWithoutDuplicates[j].Per_Unit_Price_Calculated__c);
                            System.debug('InvoiceLines[i].Per_Unit_Price_Calculated__c--->'+InvoiceLines[i].Per_Unit_Price_Calculated__c);
                            System.debug('InvoiceLines[i].Solution_for_backend_use__c--->'+InvoiceLines[i].Solution_for_backend_use__c);
                            InvoiceLinesWithoutDuplicates[j].Per_Unit_Price_Calculated__c = InvoiceLinesWithoutDuplicates[j].Per_Unit_Price_Calculated__c+InvoiceLines[i].Per_Unit_Price_Calculated__c;
                            InvoiceLinesWithoutDuplicates[j].QuantityFromOrderProduct__c = 1; 
                            System.debug('Inside non advance');
                         }*/
                        // else{
                            InvoiceLinesWithoutDuplicates[j].PriceCaculated__c = InvoiceLinesWithoutDuplicates[j].PriceCaculated__c+InvoiceLines[i].PriceCaculated__c;
                            InvoiceLinesWithoutDuplicates[j].QuantityFromOrderProduct__c = InvoiceLinesWithoutDuplicates[j].QuantityFromOrderProduct__c+InvoiceLines[i].QuantityFromOrderProduct__c;        
                            // System.debug('Inside advance');                       
                        // } 
                    }
                }
                if(match == true){
                    match = false;
                    
                }
                else{
                    InvoiceLinesWithoutDuplicates.add(InvoiceLines[i]);
                }   
            }
        }
        return new List<List<Contract_Invoice_Line__c>>{InvoiceLinesWithoutDuplicates};
    }
    
    public static List<Contract_Invoice_Line__c> RemoveDuplicateLines(List<Contract_Invoice_Line__c> InvoiceLines) {
        boolean match = false ;
        List<Contract_Invoice_Line__c> InvoiceLinesWithoutDuplicates = new List<Contract_Invoice_Line__c>(); 
        For(Integer i=0;i<InvoiceLines.size();i++ ){
            if(i==0){
                InvoiceLinesWithoutDuplicates.add(InvoiceLines[i]);
            } 
            else{
                for(Integer j=0;j<InvoiceLinesWithoutDuplicates.size();j++){
                    if(InvoiceLines[i].Solution_for_backend_use__c==InvoiceLinesWithoutDuplicates[j].Solution_for_backend_use__c){
                        match = true;
                        if(InvoiceLines[i].ProductStream_SystemUse__c!='Product in advance' && InvoiceLines[i].ProductStream_SystemUse__c!='Product in arrears'){
                            InvoiceLinesWithoutDuplicates[j].PriceCaculated__c = InvoiceLinesWithoutDuplicates[j].PriceCaculated__c+InvoiceLines[i].PriceCaculated__c; 
                            InvoiceLinesWithoutDuplicates[j].Per_Unit_Price_Calculated__c = InvoiceLinesWithoutDuplicates[j].Per_Unit_Price_Calculated__c+InvoiceLines[i].Per_Unit_Price_Calculated__c;
                            InvoiceLinesWithoutDuplicates[j].QuantityFromOrderProduct__c = 1; 
                            System.debug('Inside non advance');
                        }
                        else{
                            InvoiceLinesWithoutDuplicates[j].PriceCaculated__c = InvoiceLinesWithoutDuplicates[j].PriceCaculated__c+InvoiceLines[i].PriceCaculated__c;
                            InvoiceLinesWithoutDuplicates[j].QuantityFromOrderProduct__c = InvoiceLinesWithoutDuplicates[j].QuantityFromOrderProduct__c+InvoiceLines[i].QuantityFromOrderProduct__c;        
                            System.debug('Inside advance');                       
                        } 
                    }
                }
                if(match == true){
                    match = false;
                    
                }
                else{
                    InvoiceLinesWithoutDuplicates.add(InvoiceLines[i]);
                }   
            }
        }
        return InvoiceLinesWithoutDuplicates;
    }
     
    @AuraEnabled
    public static Integer CountNonPSNonZeroOrderProducts(String OrderId,String ServiceBillingFrequency){
        System.debug('OrderId '+OrderId);
        Integer NonPSNonZeroOrderProductsCount=0;
        if(ServiceBillingFrequency=='100% Upfront'){
            NonPSNonZeroOrderProductsCount=1;
        }
        else{
            List<OrderItem> OrderProducts = [select id,Total_Price__c,Product2.Revenue_Category__c from Orderitem where OrderId=:OrderId]; 
            For(OrderItem Orderproduct:OrderProducts){ 
                if(Orderproduct.Total_Price__c!=0 && Orderproduct.Product2.Revenue_Category__c!='Professional Services')
                    NonPSNonZeroOrderProductsCount = NonPSNonZeroOrderProductsCount+1; 
            }
            
        }
        return NonPSNonZeroOrderProductsCount;
    }


    
    //fetch picklist values from custom object in lwc
    @AuraEnabled(cacheable=true)
    public static List < customValueWrapper > pickListValueDynamically(String objectApiName, string selectPicklistApi) {
        Schema.SObjectType orderSobjectType = Schema.getGlobalDescribe().get(objectApiName.toLowerCase());
        Schema.DescribeSObjectResult objDescribe = orderSobjectType.getDescribe();     
        map < String, Schema.SObjectField > customFieldMap = objDescribe.fields.getMap();      
        list < Schema.PicklistEntry > custPickValues = customFieldMap.get(selectPicklistApi).getDescribe().getPickListValues();
        list < customValueWrapper > customObjWrapper = new list < customValueWrapper > ();
        for (Schema.PicklistEntry myCustPick: custPickValues) {
            customValueWrapper selectOptionValueWrapper = new customValueWrapper();
            selectOptionValueWrapper.label = myCustPick.getLabel();
            selectOptionValueWrapper.value = myCustPick.getValue();
            customObjWrapper.add(selectOptionValueWrapper);
        }
        
        return customObjWrapper;
    }
     // wrapper class 
    public with sharing class customValueWrapper {
        @auraEnabled public string label {get;set;}
        @auraEnabled public string value {get;set;}
    }

    @AuraEnabled
    public static void updateOrderRecord(String orderId, String productBillingFrequency, String serviceBillingFrequency){
        try {
            Order orderToUpdate = new Order(
                Id = orderId,
                Product_Billing_Frequency__c = productBillingFrequency,
                Service_Billing_Frequency__c = serviceBillingFrequency
            );

            update orderToUpdate;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}