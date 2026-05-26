/***********************************************************************************************************************************
* Created By: Prachi Gupta                                                                                                         * 
* Description: This class is created to show the Add Project Number to Invoice section on Invoice Header.                          *
*              Its getting used in updateProjectDetailsForInvoiceHeader LWC.                                                       *
* Date : 03-Oct-2023                                                                                                               *
************************************************************************************************************************************/

public class UpdateProjectDetailsOnInvHeader {
    
    @AuraEnabled
    public static  returnMessageWrapper getProjectData(string invoiceHeaderId){
     
      returnMessageWrapper rmw = new returnMessageWrapper();
      Contract_Invoice_Header__c invData   = new Contract_Invoice_Header__c();
      List<Contract_Invoice_Line__c>  invLineList = new List<Contract_Invoice_Line__c>(); 
      List<ProjectObject__c>  projectList = new List<ProjectObject__c>(); 
      List<OrderItem> oiList = new List<OrderItem>();  
      Decimal oppDealYear = 0;
      String variationOpp; 
      String orderId;
      List<string> uniqueProjectName = new List<String>();
      Set<Id> oiIdList = new Set<Id>();
      List<projectListWrapper> plw = new List<projectListWrapper>();  
      rmw.showRadioButtons = false;
      rmw.isProjectCancelled  = false;
      rmw.invoiceHasMultipleProject = false;
      rmw.currentProjectSelected ='';  
      Boolean isProjectLinkedwithInvoice = false;  
        try{
           
            if(invoiceHeaderId != ''){
            invData = [SELECT Id, Project_Number__c , Order__c, Order__r.OpportunityId
                       from Contract_Invoice_Header__c where id =:invoiceHeaderId ]; 
                 
                if(invData != null ){
                    Boolean getInvoiceLine = false;
                    
                    if(invData.Project_Number__c == '' || invData.Project_Number__c == null){
                        getInvoiceLine = true;
                    }
                    else if(invData.Project_Number__c.startswith('ORD')){
                         getInvoiceLine = true;
                    }
                    else if(invData.Project_Number__c.startswith('P')){
                          getInvoiceLine = true;
                          isProjectLinkedwithInvoice = true;
                     List<ProjectObject__c> projectObject   = [SELECT Id, name , Project_Status__c 
                           from ProjectObject__c where name = :invData.Project_Number__c];
                        
                        if(!projectObject.isEmpty()){
                            rmw.currentProjectSelected = projectObject[0].Id;
                            
                                
                               if(projectObject[0].Project_Status__c.contains('Cancelled')){       
                                 rmw.isProjectCancelled = true;
                            }
                            else{
                                 rmw.isProjectCancelled = false;
                               
                            }  
                            
                           
                        }
                    }
                    else{
                          getInvoiceLine = true;
                    }
                    if(getInvoiceLine){
                        
                     invLineList   = [SELECT Id ,Order_Product_Id__c 
                                      from Contract_Invoice_Line__c 
                                      where Invoice_Header_ID__c = :invoiceHeaderId 
                                      and Order_Product_Id__r.Product2.Revenue_Category__c  = 'Professional Services'
                                    ];
                       
                        if(!invLineList.isEmpty()){
                            
                            for(Contract_Invoice_Line__c cih:invLineList ){
                                 
                                if(cih.Order_Product_Id__c != null){
                                  oiIdList.add(cih.Order_Product_Id__c);  
                                }
                                
                            }
                           orderId = invData.Order__c; 
                           oiList = [SELECT Id, Project__c ,Project__r.name , Project__r.Project_Status__c  , OrderId  ,Project__r.Project_Manager__r.Name       
                                     from OrderItem where Project__c != '' and id in :oiIdList
                                     and (not Project__r.Project_Status__c like '%Cancell%') ] ;
                           
                            if(!oiList.isEmpty()){
                                for(OrderItem oi : oiList){
                                    if(!uniqueProjectName.contains(oi.Project__r.name) ){
                                        uniqueProjectName.add(oi.Project__r.name); 
                                        String sfdcBaseURL = URL.getOrgDomainUrl().toExternalForm(); 
                                        projectListWrapper pl = new projectListWrapper();
                                        pl.projectURL = sfdcBaseURL+'/'+oi.Project__c;
                                        pl.ProjectNumber = oi.Project__r.name;
                                        pl.ProjectManager = oi.Project__r.Project_Manager__r.Name;
                                        pl.ProjectStatus = oi.Project__r.Project_Status__c;
                                        pl.projectId = oi.Project__c;
                                        plw.add(pl);
                                    }
                                   
                                    
                                }
                                if(!uniqueProjectName.isEmpty()){
                                rmw.ProjectList = plw;
                                rmw.showRadioButtons = true;
                                if(!rmw.isProjectCancelled && isProjectLinkedwithInvoice){
                                    if(uniqueProjectName.size() > 1){
                                       rmw.invoiceHasMultipleProject = true; 
                                    }
                                    else{
                                        rmw.showRadioButtons = false;
                                    }
                                    
                                    }    
                            }
                            }
                            
                       
                        }   
                    }        
                }
           
            }
            rmw.MessageType = 'SUCCESS';        
        }catch(Exception ex){
           rmw.showRadioButtons = false;  
            rmw.MessageType = 'ERROR';
            rmw.Message = ex.getMessage();
           
        } 
        return rmw;
    }
    
    @AuraEnabled
    public static returnMessageWrapper updateProjectNumber(String projectName , String invoiceHeaderId ){
        returnMessageWrapper rmw = new returnMessageWrapper();
        rmw.showRadioButtons = false;
        try{
            Contract_Invoice_Header__c cih = new Contract_Invoice_Header__c( id = invoiceHeaderId, 
                                                                            Project_Number__c = projectName );
            update cih;
            rmw.MessageType = 'SUCCESS';  
        }catch(Exception ex){
            rmw.showRadioButtons = true;
            rmw.MessageType = 'ERROR';
            rmw.Message = ex.getMessage();
        }
        return rmw;
    }
    public class returnMessageWrapper{
        @AuraEnabled public String MessageType;
        @AuraEnabled public String Message;
        @AuraEnabled public List<projectListWrapper> ProjectList;
        @AuraEnabled public Boolean showRadioButtons;   
        @AuraEnabled public Boolean isProjectCancelled; 
        @AuraEnabled public Boolean invoiceHasMultipleProject;
        @AuraEnabled public String currentProjectSelected;
    }
     public class projectListWrapper{
        @AuraEnabled public String ProjectNumber;
        @AuraEnabled public String ProjectManager;
        @AuraEnabled public String ProjectStatus;
        @AuraEnabled public String projectURL;
        @AuraEnabled public String projectId; 
        
       
    }

}