public class OrderProductsOnInvoiceRequestController {
    public List<orderitem> orderItemList{get;set;}
    public boolean selected{get;set;}
    public string InvoiceRequestId {get;set;}
    public List<wrapOrderItem> wrapOrderItemList {get; set;}
    public List<orderitem> selectedOrderItem{get;set;}
    public List<orderitem> ordelinesToUpdate{get;set;}
    public List<Invoice_Billing_Detail__c> InvoiceBillingDetails;
    public List<Invoice_Billing_Detail__c> RelatedInvoiceBillingDetails;
    public List<Invoice_Billing_Detail__c> InvoiceBillingDetailstoDelete;
    public List<PS_Order_Product__c> PSOrderProductstoAdd;
    public List<PS_Order_Product__c> PSOrderProductstoDelete;
    public List<PS_Order_Product__c> RelatedPSOrderProducts;
    public List<PS_Order_Product__c> LatestPSOrderProducts;
    public Project_Invoice__c InvoiceRequest{get;set;}
    
    public OrderProductsOnInvoiceRequestController() {
        InvoiceRequestId=ApexPages.currentPage().getParameters().get('InvoiceRequest');
        System.debug('This is project id: '+ApexPages.currentPage().getParameters().get('Project'));
        System.debug('This is inovice request id: '+ApexPages.currentPage().getParameters().get('InvoiceRequest'));
        InvoiceRequest = [select id,TotalAmount_Product__c,Credit__c,CurrencyIsoCode,Status__c from Project_Invoice__c where id=:InvoiceRequestId];
        RelatedInvoiceBillingDetails = [select Id,Invoice_Request__c,Product__c,Order_Number__c,Order_Product_Id__c from Invoice_Billing_Detail__c where Invoice_Request__c=:InvoiceRequestId];
        RelatedPSOrderProducts = [select Id,Invoice_Request__c,Order_Product__c from PS_Order_Product__c where Invoice_Request__c=:InvoiceRequestId];
        if(wrapOrderItemList==null){
            wrapOrderItemList=new List<wrapOrderItem>();
            For(OrderItem op:[select id,Project__c,Product2.name,Product2.StockKeepingUnit,Quantity,UnitPrice,Order.OrderNumber,Invoice_Request__c, Proposition__c,Package__c,TotalPrice,Platform__c,Source_of_PS_Scoping__c,Service_End_Date__c from OrderItem where Project__r.name=:ApexPages.currentPage().getParameters().get('Project')])
                wrapOrderItemList.add(new wrapOrderItem(op,RelatedPSOrderProducts));
        }
    }
    public PageReference AddProducts(){
        system.debug('wrapOrderItemList'+wrapOrderItemList);
        selectedOrderItem = new List<orderitem>();
        ordelinesToUpdate= new List<orderitem>();
        InvoiceBillingDetails= new List<Invoice_Billing_Detail__c>();
        InvoiceBillingDetailstoDelete = new List<Invoice_Billing_Detail__c>();
        PSOrderProductstoAdd = new List<PS_Order_Product__c >();
        PSOrderProductstoDelete = new List<PS_Order_Product__c >();
        Boolean createrecord=true;
        Boolean createPSrecord=true;
        For(wrapOrderItem rec:wrapOrderItemList)
        {
            if(rec.selected==true){
                For(PS_Order_Product__c PSO: RelatedPSOrderProducts)
                {
                    if(PSO.Order_Product__c == rec.Orderitemrec.id)
                    {
                        createPSrecord=false;
                        break;
                    }
                    else
                        continue;
                } 
                
                if(createPSrecord==true)
                {
                    PS_Order_Product__c PsOrderProduct = new PS_Order_Product__c();
                    PsOrderProduct.Invoice_Request__c = ApexPages.currentPage().getParameters().get('InvoiceRequest');
                    PsOrderProduct.Order_Product__c = rec.Orderitemrec.id;
                    PsOrderProduct.CurrencyIsoCode = InvoiceRequest.CurrencyIsoCode;
                    PSOrderProductstoAdd.add(PsOrderProduct);
                }
                else
                    createPSrecord=true;
            }
            else
            {
                For(PS_Order_Product__c PSOrderproduct: RelatedPSOrderProducts)
                { 
                    if(PSOrderproduct.Order_Product__c== rec.Orderitemrec.id)
                        PSOrderProductstoDelete.add(PSOrderproduct);
                } 
            }
            
        }
        if(PSOrderProductstoAdd.size()>0)
            insert PSOrderProductstoAdd;
        if(PSOrderProductstoDelete.size()>0)
            Delete PSOrderProductstoDelete;
        LatestPSOrderProducts=[select Id,Invoice_Request__c,Order_Product__c,Total_Price__c,Order_Product__r.TotalPrice from PS_Order_Product__c where Invoice_Request__c=:InvoiceRequestId];
        For(wrapOrderItem rec:wrapOrderItemList)
        {
            if(rec.selected==true){
                For(Invoice_Billing_Detail__c IVD: RelatedInvoiceBillingDetails)
                {
                    if(IVD.Product__c == rec.Orderitemrec.Product2.id)
                    {
                        createrecord=false;
                        break;
                    }
                    else
                        continue;
                } 
                if(createrecord==true)
                {
                    Invoice_Billing_Detail__c InvoiceBillingDetail = new Invoice_Billing_Detail__c();
                    InvoiceBillingDetail.Invoice_Request__c = InvoiceRequestId;
                    InvoiceBillingDetail.IM_Code__c = rec.Orderitemrec.Product2.StockKeepingUnit;
                    InvoiceBillingDetail.Product__c = rec.Orderitemrec.Product2.id;
                    InvoiceBillingDetail.Quantity__c= rec.Orderitemrec.Quantity;
                    InvoiceBillingDetail.Order_Number__c= rec.Orderitemrec.Order.OrderNumber;
                    InvoiceBillingDetail.Order_Product_Id__c = rec.Orderitemrec.Id;
                    for(PS_Order_Product__c psorderprod:LatestPSOrderProducts)
                    {
                        if(psorderprod.Order_Product__c==rec.Orderitemrec.id)
                        {
                            if(InvoiceRequest.Credit__c==true && rec.Orderitemrec.UnitPrice>0)
                                InvoiceBillingDetail.Amount_Unit_Price__c = 0-psorderprod.Total_Price__c;
                            else
                                InvoiceBillingDetail.Amount_Unit_Price__c = psorderprod.Total_Price__c;
                            break;
                        }
                        else
                            continue;
                    }
                    InvoiceBillingDetail.CurrencyIsoCode = InvoiceRequest.CurrencyIsoCode;
                    InvoiceBillingDetails.add(InvoiceBillingDetail);
                }
                else
                    createrecord=true;
            }
            else
            {
                For(Invoice_Billing_Detail__c IVD: RelatedInvoiceBillingDetails)
                { 
                    if(IVD.Order_Product_Id__c== rec.Orderitemrec.Id)
                        InvoiceBillingDetailstoDelete.add(IVD);
                }
                
            }
        }
        if(InvoiceBillingDetails.size()>0)
            insert InvoiceBillingDetails;
        if(InvoiceBillingDetailstoDelete.size()>0)
            Delete InvoiceBillingDetailstoDelete; 
        
        UpdateInvoiceRequestProductTotal();
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Order Products added Successfully.Thank you!'));
        PageReference pg = new PageReference('/'+ApexPages.currentPage().getParameters().get('InvoiceRequest'));
        pg.setRedirect(true);
        return pg; 
    }
    public void UpdateInvoiceRequestProductTotal(){
        //List<OrderItem> OrdProdLst=[select id,TotalPrice from OrderItem where Invoice_Request__c=:InvoiceRequestId];
        InvoiceRequest.TotalAmount_Product__c=0;
        InvoiceRequest.Order_Product_count__c=0;
        for(PS_Order_Product__c PSorderprod:LatestPSOrderProducts)
        {
            InvoiceRequest.TotalAmount_Product__c = InvoiceRequest.TotalAmount_Product__c + PSorderprod.Order_Product__r.TotalPrice ;
            InvoiceRequest.Order_Product_count__c = InvoiceRequest.Order_Product_count__c+1;
        }
        update InvoiceRequest;
    }
    public class wrapOrderItem {
        
        public OrderItem Orderitemrec {get; set;}
        public Boolean selected {get; set;}
        public wrapOrderItem(OrderItem a,List<PS_Order_Product__c> RelatedPSOrderProducts ) {
            selected= false;
            Orderitemrec = a;
            for(PS_Order_Product__c PSorderproduct:RelatedPSOrderProducts)
            {
                if(PSorderproduct.order_product__c==a.id)
                {
                    selected = true;
                    break;
                }
                else
                    continue;
            }
            
        }
    }
}