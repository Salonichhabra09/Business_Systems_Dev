public class CreateVariation{

public boolean Showbutton{get;set;}
public Opportunity opportunity{get;set;}
public string OppName{get;set;}
public string CloseDate{get;set;}
public list<Opportunity> OriginalOpportunity=new list<opportunity>();
Public string Recordtype{get;set;}
public String oppId{get;set;}
    public boolean orderstatus {get;set;}
       public String RecordType1 {get;set;}
  
    public list <Order> originalorder = new list <Order>();
//Added by--Starts--Prabhat Arora: for SSE-7065
List<SelectOption> options = new List<SelectOption>(); 
String UpdRecType;
//Added by--Ends--Prabhat Arora: for SSE-7065

public CreateVariation(apexpages.standardcontroller stdController){
    
    this.opportunity = (Opportunity)stdController.getRecord();
    //oppId = ApexPages.currentPage().getParameters().get('opportunity.id');
    oppId = opportunity.id;
    system.debug('OptyId before TT=*>'+oppId);
    if(oppId==null){
        oppId = ApexPages.currentPage().getParameters().get('OptyId');
        }
    system.debug('RecordType Id==*>'+Recordtype);
    system.debug('OptyId after TT=*>'+oppId);
    
//OriginalOpportunity=[select id, name, Original_Opportunity__c,StageName,Business_Type__c,Order_Status__c,Variation_Opportunity__c,Proposition__c,Proposition_Detail__c,TM_Phase__c,Talent_Level__c,Talent_Segment__c,Offering__c,Client_Business_Function__c from opportunity where StageName='Closed/Won' AND Variation_Opportunity__c = 'No' AND  Order_Status__c= 'Complete' AND id =: oppId limit 1]; //Changes added by Apoorva for SSE-113  Added "TM Phase, Talent_Level__c,Talent_Segment__c,Offering__c,Client_Business_Function__c".
originalorder = [Select id, Status, OpportunityId,Order_Year__c from Order where Status =:'Activated'and Order_Year__c != 0 and OpportunityId =: oppId];
    System.debug('originalorder');
    if(originalorder.size()>0)
           

        orderstatus = true;
        else 
        {
            orderstatus = false;
        }
           System.debug('orderstatus');
    OriginalOpportunity=[select id, name, Original_Opportunity__c,StageName,RecordType.Name,Client_Business_Function__c,Business_Type__c,Order_Status__c,Variation_Opportunity__c,Proposition_Detail__c,TM_Phase__c,Talent_Segment__c,Previous_Record_Type__c from opportunity where StageName='Closed/Won' AND Variation_Opportunity__c = 'No' AND  Order_activated_and_greater_than_zero__c   ='TRUE' AND id =: oppId limit 1]; // Edited by Priyank on 14/7/2020
    if(OriginalOpportunity.size()>0)
        {
            oppId = OriginalOpportunity[0].id;
            system.debug('oppId:===>'+oppId);
            date dt=System.today();
            closedate=dt.format();
            ApexPages.currentPage().getParameters().put('RFPTender', 'false');
            //closedate= String.valueOf(dt);
            
            ApexPages.currentPage().getParameters().put('OppName', OriginalOpportunity[0].name);
            if(OriginalOpportunity[0].TM_Phase__c != null){
                            system.debug('TM_Phase__c:===>'+OriginalOpportunity[0].TM_Phase__c);
            ApexPages.currentPage().getParameters().put('Proposition',EncodingUtil.urlEncode(OriginalOpportunity[0].TM_Phase__c,'UTF-8'));
            }
            system.debug('TM_Phase__c:===>'+OriginalOpportunity[0].TM_Phase__c);            
          //ApexPages.currentPage().getParameters().put('PropositionDetail',OriginalOpportunity[0].Proposition_Detail__c ); Changes added by Apoorva for SSE-113 Commented this line of code to remove reference of Proposition Details field.
            ApexPages.currentPage().getparameters().put('CloseDate',closedate);
			  ApexPages.currentPage().getparameters().put('Function',OriginalOpportunity[0].Client_Business_Function__c);            
            ApexPages.currentPage().getparameters().put('UserName',UserInfo.getName());
            ApexPages.currentPage().getparameters().put('BusinessType',OriginalOpportunity[0].Business_Type__c);
           // ApexPages.currentPage().getparameters().put('RecordType1',OriginalOpportunity[0].Previous_Record_Type__c  );
  // ApexPages.currentPage().getparameters().put('BusinessType',OriginalOpportunity[0].Business_Type__c);
            
            //Added--Start by Apoorva Gautam For SSE-113---Date--22June-2015
           /* if(OriginalOpportunity[0].Talent_Level__c!=null ){
            ApexPages.currentPage().getParameters().put('TalentLevel',OriginalOpportunity[0].Talent_Level__c  );
            }
            //if(OriginalOpportunity[0].Talent_Segment__c!=null){
            //ApexPages.currentPage().getParameters().put('TalentSegment',OriginalOpportunity[0].Talent_Segment__c );
            //}
            if(OriginalOpportunity[0].Offering__c!=null){
            ApexPages.currentPage().getParameters().put('Offerings',OriginalOpportunity[0].Offering__c );
            }
            if(OriginalOpportunity[0].Client_Business_Function__c!=null){
            ApexPages.currentPage().getParameters().put('Function',EncodingUtil.urlEncode(OriginalOpportunity[0].Client_Business_Function__c,'UTF-8' ));
            } */ // commented by Priyank on 14/7/2020
            //Added---Ended by Apoorva Gautam For SSE-113---Date--22June-2015
           
            ShowButton =true;
        }
            else
        {
            ShowButton =false;}
        }
    
    
        
//Added by--Starts--Prabhat Arora: for SSE-7065     
   
        
    
        Public String getRecordtype()
            {
            
            return Recordtype;
            }
        
        
        
        public PageReference RecSelPage() 
            {            
            string id = ApexPages.currentPage().getParameters().get('id');            
            system.debug('Opporty ID===>'+oppId);    
            PageReference secondPage = new PageReference('/apex/IgniteRecTypeSel_vfpage?OptyId='+id);
            secondPage.setRedirect(true);
            return secondPage;
            }
            
        public List<SelectOption> getItems(){
            String ConfiguratorLabel = System.label.IgniteRecordType;
            String StandardLabel = System.label.StandardRecordType; 
                options.add(new SelectOption(ConfiguratorLabel ,'Configurator')); 
                options.add(new SelectOption(StandardLabel ,'Standard'));
            Recordtype = 'Configurator'; 
            return options; 
            }
            
        public void setRecordtype(String Recordtype)
            {
            this.Recordtype = Recordtype;
            system.debug('Oppty ID 3==>'+Recordtype);
            }
            
        public pageReference cancel() {
        string id = ApexPages.currentPage().getParameters().get('OptyId');
        PageReference opptyRecPage = new PageReference('/apex/IgnniteCreateVariation_vfpage?id='+id);
        opptyRecPage.setRedirect(true);
        return opptyRecPage ;    
    }         
//Added by--Ends--Prabhat Arora: for SSE-7065

}