/**************************************************************************************************************************************
CREATED BY :- PANKHURI JAIN
CREATED DATE :- 23-07-2019
DESCRIPTION :- This class contains Invoice Header trigger related functionalities : before Insert 
1)Setting invoice header's currency same as related contract's currency
2)Defaulting the Invoice Account on Invoice Header with related Contact Account
3)Defaulting the Invoice Contact on Invoice Header with related Billing Contact
***************************************************************************************************************************************/ 

global class InvoiceHeaderTriggerManager_1{
    
    public static void UpdateHeader_CurrencyAccCon(List<Contract_Invoice_Header__c> InvHeaderList){
        Set<Id> OrderIdsSet = new Set<Id>();
        Set<ID> ContactIDsSet=new Set<ID>();
        
        // Creating set of ids of the contracts.
        for(Contract_Invoice_Header__c Inv : InvHeaderList){
            OrderIdsSet.add(Inv.Order__c);
            contactIdsSet.add(Inv.Billing_Contact__c);
        }
        Map<id,Contact> ContactMap=new Map<Id, Contact>([select id, Accountid from contact where id in: ContactIDsSet]);
        // Creating Map of all the contracts related to the set of contract ids.
        // Map<Id,Contract> contractMap = new Map<Id,Contract>([Select id,AccountId,Account.CurrencyIsoCode from Contract where id in :contractIdsSet]);
        Map<id,Order> OrderMap = new Map<Id, Order>([SELECT id,CurrencyIsoCode from Order where id in :OrderIdsSet]);
        for(Contract_Invoice_Header__c Inv : InvHeaderList){
            // Setting invoice header's currency same as related contract's currency.
            if(OrderMap !=null && OrderMap .get(Inv.Order__c)!=null)
                Inv.CurrencyISOCode= OrderMap.get(Inv.Order__c).CurrencyIsoCode;  
            
            // Defaulting the Invoice Account on Invoice Header with related Contact Account
            if(Inv.Billing_Account_Name__c != Null && Inv.Invoice_Account__c==Null){
                if(ContactMap!=Null && ContactMap.get(Inv.Billing_Contact__c) !=null)
                    Inv.Invoice_Account__c = ContactMap.get(Inv.Billing_Contact__c).Accountid;              
            }
            
            // Defaulting the Invoice Contact on Invoice Header with related Billing Contact 
            if(Inv.Billing_Contact__c != Null && Inv.Invoice_Contact__c==Null){
                Inv.Invoice_Contact__c = Inv.Billing_Contact__c ;
            }             
        }  // for-end
    }
    
    public static void CheckCreditNote (List<Contract_Invoice_Header__c> NewList,Map<id,Contract_Invoice_Header__c> NewMap){
        List<Contract_Invoice_Line__c> InvoiceLines = [SELECT Id, Invoice_Header_ID__c, SUN_IM_lookup_code__c FROM Contract_Invoice_Line__c where Invoice_Header_ID__c in :NewList];
        Map<id,List<Contract_Invoice_Line__c>> InvoiceLinesMap = new Map<id,List<Contract_Invoice_Line__c>>();
        Set<String> IMCodes=new Set<String>();
        Map<String,Field_Value_Setting__c> custSettingMap = Field_Value_Setting__c.getAll();       
        String IMCodeValues = custSettingMap.get('Credit Note IM Codes').Value__c;      
        for(String s : IMCodeValues.split(',')) {        
            IMCodes.add(s.trim());
        }
        for(Contract_Invoice_Header__c invoice: NewList){
            List<Contract_Invoice_Line__c> SpecificInvoiceLines = new List<Contract_Invoice_Line__c>();
            for(Contract_Invoice_Line__c invoiceline: InvoiceLines){
                if(invoiceline.Invoice_Header_ID__c == invoice.id){  
                    SpecificInvoiceLines.add(invoiceline);
                }
            }   
            InvoiceLinesMap.put(invoice.id,SpecificInvoiceLines);
            
        }
        for(Contract_Invoice_Header__c invoice: NewList){
            if(NewMap.get(invoice.id).Invoice_Status__c == 'Ready to Invoice' || NewMap.get(invoice.id).Invoice_Status__c == 'Ready for SOE Review'){
                List<Contract_Invoice_Line__c> SpecificInvoiceLines = new List<Contract_Invoice_Line__c>();
                SpecificInvoiceLines = InvoiceLinesMap.get(invoice.id);
                for(Contract_Invoice_Line__c invoiceline:SpecificInvoiceLines){
                    if(!IMCodes.contains(invoiceline.SUN_IM_lookup_code__c)){
                        if(invoice.Invoice_Total__c == 0 && invoice.Credit_Note__c ==true)
                        {
                            invoice.adderror('Credit Note can only be checked with Invoice Total as 0 when all the related invoice lines have Expenses/Freight SUN IM Look Up Code');   
                        }
                    }
                }
            }   
        }
    }
    
    public static void Prevent_Delete_InvoiceHeader(List<Contract_Invoice_Header__c> oldList){
        String userProfileId = UserInfo.getProfileId();
        Profile userProfile = [SELECT Name FROM Profile WHERE Id =:userProfileId].get(0);
        if(userProfile.Name != 'System Administrator'){
            for(Contract_Invoice_Header__c invoice: oldList){
                if(invoice.Invoice_Status__c == 'Sun Order Complete' && invoice.SunSystems_Order_Reference__c != ''){
                    invoice.addError('Invoice Header can not be deleted since its status is "Sun Order Complete".');
                }
            }            
        }
        
    }
    
    // SSE-18850 Update Service End Date on Invoice Header when Mihir selects job on Invoice Header
    public static void updateServiceEndDateForMS(list<Contract_Invoice_Header__c> headerList, Map<Id, Contract_Invoice_Header__c> oldHeaderMap){
        list<Contract_Invoice_Header__c> invoiceHeaderListToUpdate = new list<Contract_Invoice_Header__c>();
        Id jobId = headerList[0].Job_Number__c;
        if(jobId!=null){
            Job__c jobRecord = [SELECT Id, End_Date__c FROM Job__c WHERE Id =: jobId];
            for(Contract_Invoice_Header__c invoiceHeader : headerList){
                if(invoiceHeader.Job_Number__c != oldHeaderMap.get(invoiceHeader.Id).Job_Number__c && invoiceHeader.Job_Number__c != NULL){
                    invoiceHeader.Service_End_Date__c = jobRecord.End_Date__c;
                    invoiceHeaderListToUpdate.add(invoiceHeader);
                }
            }
        }
        
    }
    
    // SSE-18850 Map Job's End Date to Service End Date on Invoice Header
    public static void mapServiceEndDateForMS(list<Contract_Invoice_Header__c> headerList){
        String orderId = headerList[0].Order__c;
        Id oppId = [SELECT Id, Opportunity.Id FROM Order WHERE Id =: orderId].Opportunity.Id;
        Id recordTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Commenced').getRecordTypeId();
        list<Job__c> jobList = [SELECT Id, End_Date__c FROM Job__c WHERE RecordTypeId =: recordTypeId AND JobStatus__c != 'Cancelled' AND Opportunity__c =: oppId Order By CreatedDate];
        if(jobList.size() > 0){
            for(Contract_Invoice_Header__c invoiceHeader : headerList){
                invoiceHeader.Service_End_Date__c = jobList[0].End_Date__c;   
            }
        }
    }
    
    @InvocableMethod
    public static void sendPOEmail(list<list<String>> invoiceHeaderIds){
        
        OrgWideEmailAddress[] owea = [Select Id from OrgWideEmailAddress where Address = 'noreply@shl.com'];    
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        
        list<Contract_Invoice_Header__c> invoiceList = new list<Contract_Invoice_Header__c>();
        list<Contract_Invoice_Header__c> invoiceListToUpdate = new list<Contract_Invoice_Header__c>();
        list<Id> successList = new list<Id>();
        list<Id> errorList = new list<Id>();
        Map<Id, String> errorMap =  new Map<Id, String>();
        Map<Id, Contract_Invoice_Header__c> mapOfData = new Map<Id, Contract_Invoice_Header__c>([SELECT Id, Name, Order__c, Process_Date__c, Awaiting_PO_Notification_Sent_On__c,OAT_Email2__c,
                                                                                                 Order__r.Name, Order__r.Opportunity.Name,
                                                                                                 Order__r.Opportunity.Owner.Email, Order__r.Opportunity.Owner.Name, 
                                                                                                 Order__r.OpportunityId, Order__r.Account.Name, Order__r.Account.Owner.Name
                                                                                                 FROM Contract_Invoice_Header__c 
                                                                                                 WHERE Id IN :invoiceHeaderIds[0]]);
        
        if(mapOfData.size() > 0){
            for(Contract_Invoice_Header__c invoiceRecord : mapOfData.values()){
                invoiceRecord.Awaiting_PO_Notification_Sent_On__c = Date.today();
                invoiceListToUpdate.add(invoiceRecord);
            }   
        }
        
        if(invoiceListToUpdate.size() > 0){
            List<Database.SaveResult> saveResult = Database.update(invoiceListToUpdate, false);
            if(saveResult.size()>0){
                Integer i=0;
                for(Database.SaveResult sr : saveResult){
                    if(sr.isSuccess()){
                        System.debug('Success Id: '+ sr.getId());
                        successList.add(sr.getId());
                    }else{
                        for(Database.Error err : sr.getErrors()){
                            System.debug('Error Id: '+ invoiceListToUpdate.get(i).Id);
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                            errorMap.put(invoiceListToUpdate.get(i).Id, err.getMessage());
                        }
                    }
                    i++;
                }
            }
        }
        
        for(Id successId : successList){
            Contract_Invoice_Header__c invoiceRecord = mapOfData.get(successId);
            DateTime dt = invoiceRecord.Process_Date__c;
            String opportunityLink = '';
            String accountURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + invoiceRecord.Order__r.OpportunityId;
            String dateString = dt.format('dd/MM/YYYY');
            String templateBody = 'Dear '+ invoiceRecord.Order__r.Opportunity.Owner.Name + ',<br/><br/>'+
                'This is a reminder that Invoice ' + invoiceRecord.Name + ' is due for release to ' + invoiceRecord.Order__r.Account.Name + ' against '+
                '<a href='+accountURL+'>'+ invoiceRecord.Order__r.Opportunity.Name +'</a>'+
                ' & ' + invoiceRecord.Order__r.Name + ' on ' + dateString + ', for which we are awaiting a purchase order. <br/><br/>'+
                'Please liaise with your points of contact to ensure that a purchase order is provided to the order assurance team by this deadline.'+
                ' The customer can provide purchase orders to the order assurance team in a number of different ways:<br/><br/>'+
                '<ul> <li>Directly, by emailing purchaseorders@shl.com – quoting the Opportunity Number or Order Number as a reference.</li>'+
                '<li> Through you, which should be forwarded to your business unit’s order assurance mailbox.</li>'+
                '<li>Via the customer’s invoicing portal [for which we already have credentials / for which we need credentials to be provided].</li></ul>'+
                'Please note that if a purchase order is not provided <b> by '+ dateString + '</b>, '+
                'this invoice will be released <b>directly to the Billing Contact on the Salesforce opportunity without a purchase order.</b><br/><br/>'+
                'If you require the invoice to be held back for up to 7 calendar days, '+
                'please submit a request in writing to your business unit’s order assurance mailbox within the next 3 business days.';
            String oppName = invoiceRecord.Order__r.Opportunity.Name;
            String oppId = oppName.substring(oppName.lastIndexOf('/')+1);
            String[] toAddresses = new String[] {invoiceRecord.Order__r.Opportunity.Owner.Email};
                Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
            mailMessage.setToAddresses(toAddresses);
            mailMessage.subject = 'Purchase Order pending for ' + invoiceRecord.Name + ': ' + oppId;
            mailMessage.setHtmlBody(templateBody);
            mailMessage.setOrgWideEmailAddressId(owea[0].Id);
            messages.add(mailMessage);
        }
        
        for(Id errorId : errorMap.keySet()){
            Contract_Invoice_Header__c invoiceRecord = mapOfData.get(errorId);
            String errorMessage = errorMap.get(errorId);
            DateTime dt = invoiceRecord.Process_Date__c;
            String opportunityLink = '';
            String accountURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + invoiceRecord.Order__r.OpportunityId;
            String invoiceURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + invoiceRecord.Id;
            String dateString = dt.format('dd/MM/YYYY');
            String templateBody = 'Dear '+ invoiceRecord.Order__r.Opportunity.Owner.Name + ',<br/><br/>'+
                'There is an Error on record : '+ '<a href='+invoiceURL+'>'+ invoiceRecord.Name +'</a>' + ' (' + errorId + ') ' + '<br/>'+
                'Error Reason: ' + errorMessage + '<br/>';
            
            String oppName = invoiceRecord.Order__r.Opportunity.Name;
            String oppId = oppName.substring(oppName.lastIndexOf('/')+1);
            String[] toAddresses = new String[] {invoiceRecord.Order__r.Opportunity.Owner.Email};
                Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
            mailMessage.setToAddresses(toAddresses);
            mailMessage.subject = 'Error on Invoice ' + invoiceRecord.Name + ': ' + oppId;
            mailMessage.setHtmlBody(templateBody);
            mailMessage.setOrgWideEmailAddressId(owea[0].Id);
            messages.add(mailMessage);
        }
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, false);
        
        for(Messaging.SendEmailResult resultEmail : results){
            if(resultEmail.success){
                System.debug('The email was sent successfully.');
            }else{
                System.debug('The email failed to send: ' + resultEmail.errors[0].message);
            }    
        }
    }
    
    public static void updateInvoiceDateOnPAStreamUpdate(List<Contract_Invoice_Header__c> invoiceHeaderList){
        
        List<Id> invoiceToUpdate = new List<Id>();
        
        for(Contract_Invoice_Header__c invoice : invoiceHeaderList){
            if(invoice.Sun_Invoice_Date__c != null || invoice.Sun_Payment_Due_Date__c !=null){
                invoiceToUpdate.add(invoice.Id);
            }
        }
        
        if(!invoiceToUpdate.isEmpty()){
            for(Contract_Invoice_Header__c invoice : invoiceHeaderList){
                if(invoiceToUpdate.contains(invoice.Id)){
                    invoice.Invoice_Date__c = Date.newInstance(
                        Integer.valueOf(invoice.Sun_Invoice_Date__c.split('/')[2]), // year
                        Integer.valueOf(invoice.Sun_Invoice_Date__c.split('/')[0]), // month
                        Integer.valueOf(invoice.Sun_Invoice_Date__c.split('/')[1])  // day
                    );
                    invoice.Payment_Due_Date__c = Date.newInstance(
                        Integer.valueOf(invoice.Sun_Payment_Due_Date__c.split('/')[2]), // year
                        Integer.valueOf(invoice.Sun_Payment_Due_Date__c.split('/')[0]),  // month
                        Integer.valueOf(invoice.Sun_Payment_Due_Date__c.split('/')[1])   // day
                    );
                }
            }
        }
    }
    
}