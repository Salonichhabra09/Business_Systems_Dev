global class NVM_ErrorPaymentController{

public String ErrorMessage{get;set;}
public String Cid{get;set;}
 
    public NVM_ErrorPaymentController(){
        ErrorMessage= ApexPages.currentPage().getParameters().get('err');
        System.debug('**ErrorMessage ' + ErrorMessage);
        
        Cid = ApexPages.currentPage().getParameters().get('Csid');
        System.debug('**CaseId ' + Cid);
    }
    
    public PageReference ReturnHome(){

        PageReference pr = new PageReference('/' + Cid); 
        pr.setRedirect(true);
        return pr;
    }
}