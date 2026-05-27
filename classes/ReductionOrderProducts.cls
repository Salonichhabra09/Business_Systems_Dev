public class ReductionOrderProducts {
    public List<orderitem> orderItemList{get;set;}
    public List<orderitem> currentorderItemList{get;set;}
    Public Set<string> ProductName{get;set;}
    public boolean selected{get;set;}
    public String Orderid{get;set;}
    public String Orderrecordtypeid{get;set;}
    public String OrderRecordtypeName{get;set;}
    public String CurrentOrderid{get;set;}
    public boolean MilestoneSigned{get;set;}
    public List<wrapOrderItem> wrapOrderItemList {get; set;}
    public List<orderitem> selectedOrderItem{get;set;}
    public List<orderitem> ordelinesToUpdate{get;set;}
    public ReductionOrderProducts() {
        Orderid=ApexPages.currentPage().getParameters().get('Orderid');
        Orderrecordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
        CurrentOrderid=ApexPages.currentPage().getParameters().get('Id');
        
        RecordType RecType = [Select Id,DeveloperName From RecordType  Where SobjectType = 'Order' and Id =: Orderrecordtypeid];
        OrderRecordtypeName = RecType.DeveloperName;
        
        if(wrapOrderItemList==null){
            wrapOrderItemList=new List<wrapOrderItem>();
            ProductName = new Set<string>();
            currentorderItemList = [Select id,Product2.name from OrderItem where OrderId=:ApexPages.currentPage().getParameters().get('Id')];
            if(currentorderItemList.size()>0){
                for(OrderItem OI:currentorderItemList){
                    ProductName.add(OI.Product2.name);
                }
            }
            if(test.isRunningTest()){
               orderItemList = [select id,OrderId,Product2.name,UnitPrice,
                                Basis_of_Fees__c,Total_Equivalent_Units__c,
                                Usage_Allowance__c,Quantity,
                                List_Price__c,
                                Order.OrderNumber, PricebookEntryId,Platform__c,Proposition__c,Package__c,
                                TotalPrice,Scoped_CPS_days__c,Scoped_LPS_days__c,
                                Opportunity_Product_Id__c, // Changes related to SSE-19911
                                Number_of_Services__c,//Changes added by Prachi (SSE-SSE-17449)
                                Solution__c//Changes added by Joana (SSE-16464)
                                from OrderItem where OrderId=:ApexPages.currentPage().getParameters().get('Orderid') ];                           
            } 
            else           
               orderItemList=[select id,OrderId,Product2.name,
                              UnitPrice,Basis_of_Fees__c,Total_Equivalent_Units__c,
                              Usage_Allowance__c,Quantity,
                              List_Price__c,
                              Order.OrderNumber,PricebookEntryId,Platform__c,Proposition__c,
                              Package__c,TotalPrice,Scoped_CPS_days__c,Scoped_LPS_days__c,
                              Opportunity_Product_Id__c, // Changes related to SSE-19911
                              Number_of_Services__c,//Changes added by Prachi (SSE-SSE-17449)
                              Solution__c//Changes added by Joana (SSE-16464)
                              from OrderItem 
                              where OrderId=:ApexPages.currentPage().getParameters().get('Orderid') 
                              AND Product2.name NOT IN:ProductName ]; 
          
          if(orderItemList.size()!=0)
            {
                For(orderitem op:orderItemList)
                    wrapOrderItemList.add(new wrapOrderItem(op));  
            } 
            else
              wrapOrderItemList=null;  
        
    }
    }
    public PageReference AddProducts(){
        selectedOrderItem = new List<orderitem>();
        ordelinesToUpdate= new List<orderitem>();
        For(wrapOrderItem rec:wrapOrderItemList)
        {
            if(rec.selected == true){
                rec.InsertOrderitemrec.OrderId=ApexPages.currentPage().getParameters().get('Id');
                rec.InsertOrderitemrec.Quantity = rec.Orderitemrec.Quantity;
                rec.InsertOrderitemrec.List_Price__c = rec.Orderitemrec.List_Price__c; //Changes related to SSE-19910 
                rec.InsertOrderitemrec.Opportunity_Product_Id__c = rec.Orderitemrec.Opportunity_Product_Id__c; //Changes related to SSE-19911
                rec.InsertOrderitemrec.Number_of_Services__c = rec.Orderitemrec.Number_of_Services__c;//Changes added by Prachi (SSE-SSE-17449)
                rec.InsertOrderitemrec.Solution__c = rec.Orderitemrec.Solution__c;//Changes added by Joana (SSE-16464)
                rec.InsertOrderitemrec.PricebookEntryId = rec.Orderitemrec.PricebookEntryId;
                rec.InsertOrderitemrec.Basis_of_Fees__c = rec.Orderitemrec.Basis_of_Fees__c ;
                rec.InsertOrderitemrec.UnitPrice = -rec.Orderitemrec.UnitPrice;
                rec.InsertOrderitemrec.Package__c = rec.Orderitemrec.Package__c;
                rec.InsertOrderitemrec.Platform__c = rec.Orderitemrec.Platform__c;
                rec.InsertOrderitemrec.Proposition__c = rec.Orderitemrec.Proposition__c;
                rec.InsertOrderitemrec.Usage_Allowance__c = rec.Orderitemrec.Usage_Allowance__c;
                rec.InsertOrderitemrec.Total_Equivalent_Units__c = rec.Orderitemrec.Total_Equivalent_Units__c;
                ordelinesToUpdate.add(rec.InsertOrderitemrec);
            }
            
        }
        insert ordelinesToUpdate;
        
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Order Products added Successfully.Thank you!'));
        PageReference pg = new PageReference('/'+ApexPages.currentPage().getParameters().get('Id'));
        pg.setRedirect(true);
        return pg; 
    }
    public class wrapOrderItem {
        public OrderItem Orderitemrec {get; set;}
        public OrderItem InsertOrderitemrec {get; set;}
        public Boolean selected {get; set;}
        public wrapOrderItem(OrderItem a) {
            Orderitemrec = a;
            InsertOrderitemrec = new OrderItem();
            selected = false;
        }
    }

}