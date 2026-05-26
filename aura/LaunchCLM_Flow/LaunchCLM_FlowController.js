({
    invoke : function(component, event, helper) {
        
        var workspaceAPI = component.find("workspace");
        // var myPageRef = component.get("v.pageReference").state;
        
        let objtName = component.get("v.objectName");
        let opportuntityName = component.get("v.opportuntityName");
        let recId = component.get("v.id");
        let accountName = component.get("v.accountName");
        let accountNumber = component.get("v.accountNumber");
        let profileName = component.get("v.profileName");
        let hasEOLProducts = false;
        
        let url = '';
        
        let billingContactStatus = component.get("v.billingContactStatus");
        let primaryContactStatus = component.get("v.primaryContactStatus");
        
        let CLMContractStatus = component.get("v.CLMContractStatus");
        
        let oppRecord = JSON.stringify(component.get("v.oppRecord"));
        let opportunitySalesPrice = component.get("v.oppRecord").Amount;
        let variationOpportunity = component.get("v.oppRecord").Variation_Opportunity__c;
        let variationReason = component.get("v.oppRecord").Variation_Reason__c;
        
        if((billingContactStatus != null && billingContactStatus != 'Active' && billingContactStatus != '') &&
           (primaryContactStatus!= null && primaryContactStatus != 'Active' && primaryContactStatus != '')){
            var message = 'The Primary Contact and the Billing Contact linked to the opportunity are inactive. Please update the Primary and Billing Contact..';
            helper.showToast(component, event, helper , message);  
            helper.closeTab(component, event, helper , recId);
            
        } 
        else if((billingContactStatus != null && billingContactStatus != 'Active' && billingContactStatus != '')&&
                ((primaryContactStatus!= null && primaryContactStatus == 'Active' && primaryContactStatus!='')||primaryContactStatus=='')){
            
            var message= 'The Billing Contact linked to the opportunity is inactive. Please update the Billing Contact.';
            helper.showToast(component, event, helper , message);  
            helper.closeTab(component, event, helper , recId);
            
        } else if((primaryContactStatus!= null && primaryContactStatus != 'Active' && primaryContactStatus != '')&&
                  ((billingContactStatus != null && billingContactStatus == 'Active' && billingContactStatus != '')||billingContactStatus == '')){
            var message = 'The Primary Contact linked to the opportunity are inactive. Please update the Primary Contact.';
            helper.showToast(component, event, helper , message);  
            helper.closeTab(component, event, helper , recId);
            
        } 
            else {
                
                // Production URL - UnComment before deployment
                opportuntityName = opportuntityName.replace(/&/g, "%26");//added by Prabhat for SSE-24945 on 07 June 2024
                accountName = accountName.replace(/&/g, "%26");//added by Prabhat for SSE-24945 on 07 June 2024
                /*url = 'https://na11.springcm.com/atlas/doclauncher/eos/Opportunity Create Contract?aid=26377&eos[0].Id=' +
                    recId+'&eos[0].System=Salesforce&eos[0].Type=Opportunity&eos[0].Name='+
                    opportuntityName+'&eos[0].ScmPath=/Salesforce/Account/'+
                    accountName+' '+accountNumber+'/Opportunity';*/
                console.log('--url--'+url);
                
                //UAT URL - commment before deployment
                
                url = 'https://uatna11.springcm.com/atlas/doclauncher/eos/Opportunity Create Contract?aid=65440&eos[0].Id=' +
                    recId+'&eos[0].System=Salesforce&eos[0].Type=Opportunity&eos[0].Name='+
                    opportuntityName+'&eos[0].ScmPath=/Salesforce/Account/'+
                    accountName+' '+accountNumber+'/Opportunity';
                
                
                helper.closeTab(component, event, helper , recId); 
                
                if(profileName == 'System Administrator'){
                    helper.checkCLMContractValue(component, event, helper,url,CLMContractStatus);
                    
                } else{
                    
                    if(variationOpportunity == 'Yes' && variationReason == 'Addition to order' && opportunitySalesPrice <= 0){
                        var message = 'Variation Reason cannot be Addition to Order when the cumulative price of the line items amounts to zero or negative.';
                        helper.showToast(component, event, helper , message);  
                        helper.closeTab(component, event, helper , recId);
                    }else{
                        var action = component.get("c.existEOFProducts");
                        action.setParams({
                            "recordId": recId,
                            "objectName": objtName
                        });        
                        action.setCallback(component, function(response) {
                            var state = response.getState();
                            
                            if (state === "SUCCESS") {
                                
                                hasEOLProducts = response.getReturnValue();
                                
                                if(hasEOLProducts){
                                    var message = 'Launch CLM is not possible as Opportunity has 1 or more products that have been marked as "End of Life".';
                                    helper.showToast(component, event, helper , message);  
                                    
                                } else {
                                    
                                    helper.checkCLMContractValue(component, event, helper,url,CLMContractStatus);
                                }                
                            } else {
                                helper.checkCLMContractValue(component, event, helper,url,CLMContractStatus);
                            }
                        });
                        $A.enqueueAction(action);
                        
                    }
                }
            }
    },
    
    
    
})