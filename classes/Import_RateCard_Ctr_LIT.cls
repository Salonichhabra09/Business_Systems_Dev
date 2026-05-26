/*
Description: This class is used for importing the Opportunity Product csv, Discount Summary csv & Rate card pdf
with respect to a Ignite opportunity. Related with VF Page ImportRateCard_VF
Created By: Priyank Anand
Created Date: 23/01/2018
Last Modified on: 05/12/2019 as per SSE-10186 by Prabhat Arora
Last Modified again on: 15/05/2025 by Prabhat Arora during API retirement changes, to make compatible for Lex.
This covers the functionality of redirecting to error msg page, if config line items are edited.
*/

public with sharing class Import_RateCard_Ctr_LIT{
    
    /***This function reads the CSV file and inserts records into the Opportunity Line object. ***/ 
    @AuraEnabled
    public static String ReadFileOppLineItems(Id OpptID,String file)
    {  
        if (String.isBlank(file)) {
        return 'Please Choose Pricebook Items CSV file';
    }
        Opportunity opptyRec = [select id,name,NoOfProducts__c,StageName,CurrencyIsoCode,TM_Phase__c,Talent_Level__c,Package_Level__c from Opportunity where id =: OpptID ];
        opptyRec.Skip_Client_Needs_Validation__c = true;   // Always Make the checkbox true to skip the validation before insert.
        update opptyRec;
        set<id> InsertedPricebookEntryIds = new set<id>();   
        String errorMessage1 = ''; 
        String nameFile;
        Blob contentFile;
        List<OpportunityLineItem> ExistingOppLineItems=DeleteRecordsOppLineItems(OpptID);
        set<string> HiringNeeds = new set<string>();
        set<string> TalentLevels= new set<string>();
        set<string> PackageLevels = new set<string>();
        set<string> Propositions = new set<string>();//added by Prabhat for SSE-10186
        List<OpportunityLineItem> OppLineItemupload = new List<OpportunityLineItem>();
        decimal OpptyProductCount;
        Set<String> ProductNamesSet = new Set<String>();
        List<String> SubscriptionProdNamesList = new List<String>();
        String Errors;
        String[] filelines;
        try{    
            
            filelines = file.split('\n');
            
            //Iterate through every line and create a Opportunity Line item record for each row
            
            for (Integer i=1;i<filelines.size();i++){
                String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');
                
                OpportunityLineItem oppl = new OpportunityLineItem();
                oppl.OpportunityId= OpptID;                 
                oppl.PricebookentryId = inputvalues[0]; 
                if(inputvalues[0] != ''){
                    InsertedPricebookEntryIds.add(inputvalues[0]);
                }
                
                if(inputvalues[1] != ''){   
                    oppl.Hiring_Need__c = inputvalues[1]; 
                    HiringNeeds.add(inputvalues[1]);
                }
                if(inputvalues[2] != ''){ 
                    oppl.Talent_Level__c = inputvalues[2];
                    TalentLevels.add(inputvalues[2]);
                }
                if(inputvalues[3] != ''){ 
                    oppl.Package_Level__c = inputvalues[3];
                    PackageLevels.add(inputvalues[3]);
                }
                oppl.List_Price__c = Decimal.Valueof(inputvalues[4]);
                oppl.Total_Discount__c = Double.valueOf(inputvalues[5]);
                oppl.UnitPrice = Decimal.Valueof(inputvalues[6]);
                if(inputvalues[7] != ''){
                    oppl.Level__c = Integer.Valueof(inputvalues[7]);
                }
                oppl.BASIS_OF_FEES__C = inputvalues[8];
                if(inputvalues[9] != ''){ 
                    oppl.USAGE_CAP_OR_ESTIMATION__C = Integer.Valueof(inputvalues[9]);
                }
                if(inputvalues[10] != ''){ 
                    oppl.Volume__c = Integer.Valueof(inputvalues[10]);
                }    
                oppl.START_DATE__C = date.parse(inputvalues[11]);
                oppl.END_DATE__C = date.parse(inputvalues[12]);
                oppl.Year_1_List_Price__c = Decimal.Valueof(inputvalues[13]);
                if(inputvalues[14] != ''){ 
                    oppl.Year_2_List_Price__c = Decimal.Valueof(inputvalues[14]);
                }
                if(inputvalues[15] != ''){ 
                    oppl.Year_3_List_Price__c = Decimal.Valueof(inputvalues[15]);
                }
                oppl.Year_1_Discount__c = Double.Valueof(inputvalues[16]);
                if(inputvalues[17] != ''){ 
                    oppl.Year_2_Discount__c = Double.Valueof(inputvalues[17]);
                }
                if(inputvalues[18] != ''){ 
                    oppl.Year_3_Discount__c = Double.Valueof(inputvalues[18]);
                }
                oppl.Year_1_Sales_Price__c = Decimal.Valueof(inputvalues[19]); 
                if(inputvalues[20] != ''){                                   
                    oppl.Year_2_Sales_Price__c = Decimal.Valueof(inputvalues[20]); 
                }       
                if(inputvalues[21] != ''){          
                    oppl.Year_3_Sales_Price__c = Decimal.Valueof(inputvalues[21]);
                }
                oppl.Quantity = 1;
                oppl.Platform__c = inputvalues[22];     
                oppl.Usage_Allowance__c = inputvalues[23];      
                //Added by prabhat for SSE-10186 started
                if(inputvalues[24] != ''){ 
                    oppl.Proposition__c = inputvalues[24];
                    Propositions.add(inputvalues[24]);
                }
                //Added by prabhat for SSE-10186 Ended
                oppl.Imported_from_Rate_Card_c__c = true;
                OppLineItemupload.add(oppl);                                                      
            }
        } 
        catch(Exception e){  
            System.debug('**nameFile2 ' + filelines.size());
            if(file == null){
                Errors = 'Please Choose Pricebook Items CSV file before uploading';
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please Choose your Pricebook Items CSV file before uploading'));
            }
            else{ 
                System.debug('hello');    
                Errors =  'An error has occured while reading the Pricebook Items CSV file:'+e.getMessage();
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'An error has occured while reading the Pricebook Items CSV file: '+e.getMessage()));                         
            }
            errorMessage1 = e.getMessage();
            System.debug('hello this is errorMessage1'+errorMessage1);
        }  
        
        try{
            if(errorMessage1 == '' || errorMessage1 == null){
                insert OppLineItemupload;
                System.debug('**InsertedPricebookEntryIds' + InsertedPricebookEntryIds);
                if(InsertedPricebookEntryIds!=null && InsertedPricebookEntryIds.size()>0){                  
                    List<PricebookEntry> pblist = new List<PricebookEntry>();
                    pblist = [select id,product2.name from PricebookEntry where id IN : InsertedPricebookEntryIds];
                    if(pblist!=null && pblist.size()>0){
                        for(PricebookEntry pb : pblist){
                            ProductNamesSet.add(pb.product2.name);
                        }
                    }                     
                }
                System.debug('**ProductNamesSet ' + ProductNamesSet);
                
                Multiyear_Opportunity_Product_Sequence__c  mops = Multiyear_Opportunity_Product_Sequence__c.getValues('Products');
                SubscriptionProdNamesList = mops.Products_Sequence__c.split(',');
                System.debug('SubscriptionProdNames ' + SubscriptionProdNamesList);
                
                Integer count = 0;
                for(String sub: SubscriptionProdNamesList){
                    if(ProductNamesSet.contains(sub)){
                        count = count + 1;
                    }
                }
                system.debug('**count ' + count);
                HiringNeeds.clear();
                TalentLevels.clear();
                PackageLevels.clear();
                Propositions.clear();
                ProductNamesSet.clear(); 
                InsertedPricebookEntryIds.clear();
            }
        }
        catch (Exception e){
            Errors =  'An error has occured while importing the Pricebook Items: '+e.getMessage();
            errorMessage1 = e.getMessage();
        }
        finally {            
            if((errorMessage1 != '' || errorMessage1 != null) && OpptyProductCount > 0){               
                opptyRec.Skip_Client_Needs_Validation__c = false;       // This is to ensure no changes in client need section done after insert.
                update opptyRec; 
            }
            System.debug('**ErrorMessage ' + errorMessage1 );        
            if(errorMessage1 == '' || errorMessage1 == null){
                System.debug('**ErrorMessage: ' + errorMessage1 );
                Errors ='Pricebook Items imported successfully';
                if(ExistingOppLineItems.size() > 0){
                    delete ExistingOppLineItems;
                }  
                file = null;    
                system.debug('contentFile** ' + file);          
            } 
        }           
        return Errors;
    } 
    
    /***This function reads the CSV file and inserts records into the Discount Summary object. ***/
    @AuraEnabled
    public static String ReadFileDiscountSum(Id OpptID,String file) {
        
        string nameFile1;
        String errorMessage2;
        String Error;
        List<Discount_Summary__c> DiscountSumupload;
        string oppCurrency;
        List<Discount_Summary__c> ExistingDiscountSum;
        try{               
            //nameFile1 =blobToString(contentFile1,'ISO-8859-1');               
            String[] filelines1 = file.split('\n'); 
            errorMessage2 = '';
            
            ExistingDiscountSum = new List<Discount_Summary__c>();
            ExistingDiscountSum = [Select id,Opportunity__c from Discount_Summary__c where Opportunity__c =: OpptID];  
            
            DiscountSumupload = new List<Discount_Summary__c>();
            for (Integer i=1;i<filelines1.size();i++){
                String[] inputvalues = new String[]{};
                    inputvalues = filelines1[i].split(',');
                Discount_Summary__c ds1 = new Discount_Summary__c();
                ds1.Opportunity__c = OpptID;
                ds1.Discount_Type__c = inputvalues[1]; 
                ds1.Level__c = inputvalues[2]; 
                ds1.Name__c = inputvalues[3]; 
                if(inputvalues[4] != ''){
                    ds1.Discount_Percentage__c =  Double.Valueof(inputvalues[4]);
                }
                if(inputvalues[5] != ''){
                    ds1.Discount_Amount__c = Decimal.valueof(inputvalues[5]);
                } 
                ds1.Discount_Applied_On__c = date.parse(inputvalues[6]); 
                ds1.Reason_for_the_Discretionary_Discount__c = inputvalues[7];
                ds1.CurrencyIsoCode = oppCurrency;
                DiscountSumupload.add(ds1);           
            }
        }
        catch(Exception e){ 
            if(file == null){
                Error = 'Please Choose your Discount Summary CSV file before uploading';
            }
            else{        
                Error= 'An error has occured while reading the Discount Summary CSV file: '+e.getMessage();
            }
            errorMessage2 = e.getMessage();
            System.debug('hello this is errorMessage2'+errorMessage2);
        }       
        try{
            if(errorMessage2 == '' || errorMessage2 == null){
                insert DiscountSumupload;
            }
        }
        catch (Exception e){            
            errorMessage2 = e.getMessage();
            Error='An error has occured while importing the Discount Summary records: '+e.getMessage();
        }                                   
        if(errorMessage2 == '' || errorMessage2 == null){
            System.debug('**ErrorMessage2: ' + errorMessage2);
            Error='Discount Summary Records imported successfully';
            if(ExistingDiscountSum.size() > 0){
                delete ExistingDiscountSum;
            } 
            file = null;    
            system.debug('contentFile1** ' + file); 
        }
        return Error;
    } 
    
    public static List<OpportunityLineItem> DeleteRecordsOppLineItems(id OpptID) { 
        List<OpportunityLineItem> ExistingOppLineItems = new List<OpportunityLineItem> ();     
        ExistingOppLineItems = [Select id,OpportunityId from OpportunityLineItem where OpportunityId =: OpptID];
        System.debug('**DeleteLines ' + ExistingOppLineItems);        
        return ExistingOppLineItems;
    }
    
}