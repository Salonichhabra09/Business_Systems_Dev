public class ReductionOrderCreationCls {
     public ApexPages.StandardController controller {get; set;}
    public ReductionOrderCreationCls(ApexPages.StandardController controller){
    
    }
    public PageReference getCloseWindow(){
        return new PageReference('/apex/closeFlow');
    }
}