public class OrderProductsOnProjectController {
    public List<orderitem> orderItemList{get;set;}
    public boolean selected{get;set;}
    public String Projectid{get;set;}
    public boolean MilestoneSigned{get;set;}
    public List<wrapOrderItem> wrapOrderItemList {get; set;}
    public List<orderitem> selectedOrderItem{get;set;}
    public List<orderitem> ordelinesToAdd{get;set;}
    public List<orderitem> ordelinesToDelete{get;set;}
    public List<PS_Order_Product__c> RelatedPSOrderProducts{get;set;}
    public List<Order> OrderList{get;set;}
    public List<Contract> ContractList{get;set;}
    public Contract OriginalContract{get;set;}
    public boolean HasAccess{get;set;}
    public OrderProductsOnProjectController() {
        Projectid=ApexPages.currentPage().getParameters().get('Project');
        System.debug('This is project id: '+ApexPages.currentPage().getParameters().get('Project'));
        if(ApexPages.currentPage().getParameters().get('Contract')=='')
        {
            wrapOrderItemList=null;
        }
        else{
            OriginalContract = [Select id from Contract where ContractNumber=:ApexPages.currentPage().getParameters().get('Contract')];
            List<Milestone__c> SignedMilestones = [select id from Milestone__c where Project__c=:ApexPages.currentPage().getParameters().get('Project') and Is_Signed__c=True];
            System.debug('This is count '+SignedMilestones.size());
            if(SignedMilestones.size()>0)
                MilestoneSigned=True;
            else
                MilestoneSigned=False;
            
            if(wrapOrderItemList==null){
                wrapOrderItemList=new List<wrapOrderItem>();
                System.debug('This is original contract'+OriginalContract);
                try{
                    ContractList = [select id from contract where Original_Contract__r.id=:OriginalContract.id];
                }
                catch(DmlException e){
                }
                ContractList.add(OriginalContract);
                System.debug('This is contract list '+ContractList);
                if(ContractList!=null){
                    OrderList=[select id from Order where Contract.id In :ContractList];
                }
                System.debug('Orders are '+OrderList.size());
                if(OrderList!=null){
                    orderItemList=[select id,Project__c,Product2.name,Quantity,UnitPrice,Source_of_PS_Scoping__c,Order.OrderNumber,Invoice_Request__r.Name,
                                   Platform__c,Proposition__c,Package__c,TotalPrice,Basis_of_Fees__c,Service_End_Date__c,Order.Order_year__c,
                                   Number_of_Services__c,
                                   Total_Price_PS_Items__c,
                                   Order_Status__c,
                                   Order_Form_Category__c,
                                   Solution__c//Changes added by Joana (SSE-16464)
                                   from OrderItem where OrderID IN :OrderList and Product2.Revenue_Category__c='Professional Services' AND
                                   ((Order_Form_Category__c !='Advisory Services' AND Project__c=null) OR Project__c=:ApexPages.currentPage().getParameters().get('Project'))];
                }
                System.debug('Size is '+orderItemList.size());
                System.debug('Is null '+orderItemList);
                if(orderItemList.size()!=0)
                {
                    For(orderitem op:orderItemList)
                        wrapOrderItemList.add(new wrapOrderItem(op));  
                } 
                else
                    wrapOrderItemList=null;  
            }
        }
        Id profileId=userinfo.getProfileId();
            id userid = UserInfo.getUserId();
            String GCSCCXTS;
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            List<PermissionSetAssignment> assignmentRecord = [SELECT PermissionSetGroup.DeveloperName FROM PermissionSetAssignment WHERE PermissionSetGroup.DeveloperName = 'GCSC_CXTS' AND Assignee.id=: userid];

            if(profileName=='Professional Services'){
                HasAccess = true;
                system.debug('has access '+HasAccess);
            }
            else if(!assignmentRecord.isEmpty())
            {
                HasAccess = false;
                system.debug('has access GCSC '+HasAccess);
            }
            else{
                HasAccess = schema.sObjectType.Order.isUpdateable();
            }
            system.debug('has access '+HasAccess);
    }
    public PageReference AddProducts(){
        selectedOrderItem = new List<orderitem>();
        ordelinesToAdd= new List<orderitem>();
        ordelinesToDelete= new List<orderitem>(); 
        RelatedPSOrderProducts=new List<PS_Order_Product__c>();
        Boolean showerror=false;
        For(wrapOrderItem rec:wrapOrderItemList)
        {
            if(rec.selected==true){
                rec.Orderitemrec.Project__c=Projectid;
                ordelinesToAdd.add(rec.Orderitemrec);
            }
            else
            {
                rec.Orderitemrec.Project__c=null;
                rec.Orderitemrec.Invoice_Request__c=null;
                ordelinesToDelete.add(rec.Orderitemrec);
            }
        }
        if(ordelinesToDelete.size()>0)
        {
            RelatedPSOrderProducts=[select Id,Invoice_Request__r.Status__c,Order_Product__c from PS_Order_Product__c where Order_Product__c IN :ordelinesToDelete];
            /*for(PS_Order_Product__c psprod:RelatedPSOrderProducts)
{
if(psprod.Invoice_Request__r.Status__c=='Processed')
{
showerror=true;
break;
}
else 
continue;  
}*/
        }
        if(RelatedPSOrderProducts.size()>0)
        {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'One of the order product is linked to an associated invoice request, so it cant be removed from the Project.'));
            return null;
        }
        else
        {
            if(ordelinesToAdd.size()>0)
                update ordelinesToAdd;
            update ordelinesToDelete;
            UpdateProjectRollUpFields();
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Order Products added Successfully.Thank you!'));
            PageReference pg = new PageReference('/'+ApexPages.currentPage().getParameters().get('Project'));
            pg.setRedirect(true);
            return pg;
        }
        
    }
    
    public void UpdateProjectRollUpFields(){
        ProjectObject__c Prj=[select id,Order_Products_Count__c,Scoped_CPS_days_RollUp__c,
                              Scoped_LPS_days_RollUp__c,Total_Orderline_Value_RollUp__c from ProjectObject__c where Id=:Projectid];
        List<OrderItem> OrdProdLst=[select id,TotalPrice,Basis_of_Fees__c,Quantity from OrderItem where Project__c=:Prj.Id and Order.Status != 'Cancelled'];
        System.debug('This is order product list '+OrdProdLst.size());   
        if(OrdProdLst!=null && !OrdProdLst.isEmpty()){
            Prj.Order_Products_Count__c=OrdProdLst.size();
        }else{
            Prj.Order_Products_Count__c=0;
        }
        Prj.Scoped_CPS_days_RollUp__c=0;
        Prj.Scoped_LPS_days_RollUp__c=0;
        Prj.LPS_scoped_value__c=0;
        Prj.CPS_scoped_value__c=0;
        Prj.Total_Orderline_Value_RollUp__c=0;
        //update Prj;
        for(OrderItem Op:OrdProdLst){
            if(op.Basis_of_Fees__c=='CPS Days')
            {
                Prj.Scoped_CPS_days_RollUp__c = Prj.Scoped_CPS_days_RollUp__c+ Op.Quantity;
                Prj.CPS_scoped_value__c = Prj.CPS_scoped_value__c + Op.TotalPrice;
            }
            if(op.Basis_of_Fees__c=='LPS Days'){
                Prj.Scoped_LPS_days_RollUp__c = Prj.Scoped_LPS_days_RollUp__c+ Op.Quantity;  
                Prj.LPS_scoped_value__c = Prj.LPS_scoped_value__c + Op.TotalPrice; 
            }
            Prj.Total_Orderline_Value_RollUp__c =Prj.Total_Orderline_Value_RollUp__c+ Op.TotalPrice;
            
        }
        update Prj;
    }
    
    public class wrapOrderItem {
        public OrderItem Orderitemrec {get; set;}
        public Boolean selected {get; set;}
        public wrapOrderItem(OrderItem a) {
            Orderitemrec = a;
            if(a.Project__c==null)
                selected = false;
            else
                selected = true;
        }
    }
}