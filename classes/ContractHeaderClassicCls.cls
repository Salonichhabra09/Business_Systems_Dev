public class ContractHeaderClassicCls {
     public ApexPages.StandardController controller {get; set;}
    public ContractHeaderClassicCls(ApexPages.StandardController controller){
    
    }
    public PageReference getCloseWindow(){
        return new PageReference('/apex/closeFlow');
    }
}