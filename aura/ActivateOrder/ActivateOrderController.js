({
    handleRecordUpdated: function(component, event, helper) {
        debugger;
        var record = component.get('v.Order');
        var OrdStatus = record.Status;
        var RcTypNM = record.RecordType.Name;
        var BukdElswhr = record.Booked_Elsewhere__c;
        var isMSOpprtunity = record.Opportunity.MS_Opportunity__c;
        console.log('isMSOpprtunity --> ',isMSOpprtunity);
        console.log('record.Opportunity.Apply_Price_Increase_Switch__c ',record.Opportunity.Apply_Price_Increase_Switch__c);
        console.log('record.Opportunity.Opportunity_Deal_Year__c --> ',record.Opportunity.Opportunity_Deal_Year__c);
        console.log('record.Opportunity.Price_Increase_Percentage__c -->'+record.Opportunity.Price_Increase_Percentage__c);
        console.log('record.Opportunity.Price_Increase_Clause__c -->'+record.Opportunity.Price_Increase_Clause__c);
        if(RcTypNM == 'Standard Order'){
            if((!record.Opportunity.Apply_Price_Increase_Switch__c && record.Opportunity.Opportunity_Deal_Year__c==1)
                || (!record.Opportunity.Apply_Price_Increase_Switch__c && record.Opportunity.Price_Increase_Percentage__c!=null &&
                (record.Opportunity.Price_Increase_Clause__c=='Standard Auto-Renewal Clause' || 
                    record.Opportunity.Price_Increase_Clause__c=='Non-Standard Auto-Renewal Clause' ||
                    record.Opportunity.Price_Increase_Clause__c=='Standard Inflationary Increase' ||
                    record.Opportunity.Price_Increase_Clause__c=='Non-standard Increase Clause')) ){
                helper.ActivateOrder(component, event, helper);
            }
            else if((record.Opportunity.Price_Increase_Clause__c!='Standard Auto-Renewal Clause' &&
                record.Opportunity.Price_Increase_Clause__c!='Non-Standard Auto-Renewal Clause' &&
                record.Opportunity.Price_Increase_Clause__c!='Standard Inflationary Increase' &&
                record.Opportunity.Price_Increase_Clause__c!='Non-standard Increase Clause') || record.Opportunity.Price_Increase_Clause__c==null
            ){
                helper.ActivateOrder(component, event, helper);
            }
            else{
                var message = 'Price inflation for this year is currently being applied. Please wait for a couple of minutes before clicking the Activate button.';
                var title = 'Error';
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                helper.showToast(component, event, helper , message, title );
            }
            
        }
        else if((isMSOpprtunity && RcTypNM == 'GCSC Order' && OrdStatus != 'Activated' && BukdElswhr == true) || (RcTypNM == 'GCSC Order' && OrdStatus != 'Activated' && BukdElswhr == true)){
            helper.ActivateOrder(component, event, helper);
        }
        else if(RcTypNM == 'GCSC Order' && BukdElswhr == false){
            var message = 'To Activate an Order use: Submit for Approval Button as Booked Elsewhere is marked as unchecked.';
            var title = 'Error';
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
            helper.showToast(component, event, helper , message, title );
        }
    }})