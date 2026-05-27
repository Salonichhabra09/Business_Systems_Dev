/*
Description: This class is used for importing the Opportunity Product csv, Discount Summary csv & Rate card pdf
with respect to a Ignite opportunity. Related with VF Page ImportRateCard_VF
Created By: Pankhuri Jain
Created Date: 23/07/2018
Last Modified on: 05/12/2019 as per SSE-10186 by Prabhat Arora
*/

public with sharing class Import_RateCard_Ctr{

    public string nameFile{get;set;}    
    public Blob contentFile{get;set;}    
    String[] filelines = new String[]{};   
    public string OpptID = '';     
    public List<OpportunityLineItem> ExistingOppLineItems;   
    public List<OpportunityLineItem> OppLineItemupload;
    public string opptyName{get;set;} 
    public string opptyId{get;set;}
    public string opptyStageName{get;set;} 
    public string oppCurrency{get;set;}       
    public string nameFile1{get;set;}
    public Blob contentFile1{get;set;}    
    String[] filelines1 = new String[]{};
    public List<Discount_Summary__c> DiscountSumupload;
    public List<Discount_Summary__c> ExistingDiscountSum;
    public Opportunity opptyRec{get;set;}
    public set<string> HiringNeeds = new set<string>();
    public set<string> TalentLevels= new set<string>();
    public set<string> PackageLevels = new set<string>();
    public set<string> Propositions = new set<string>();//added by Prabhat for SSE-10186
    public Attachment tAttachment{get;set;}
    public set<id> InsertedPricebookEntryIds = new set<id>();
    public Set<String> ProductNamesSet = new Set<String>();
   public List<String> SubscriptionProdNamesList = new List<String>();
    public String errorMessage1 {get;set;}
    public String errorMessage2 {get;set;}
    public decimal OpptyProductCount;
    public string opprecordtype{get;set;}
   
    public Import_RateCard_Ctr(){ //Constructor 
       OpptID = System.currentPageReference().getParameters().get('oppId');
       opptyRec = [select id,name,NoOfProducts__c,recordtypeid,StageName,CurrencyIsoCode,TM_Phase__c,Talent_Level__c,Package_Level__c from Opportunity where id =: OpptID ];
       opptyName = opptyRec.Name; 
       opptyId = opptyRec.Id;  
       oppCurrency = opptyRec.CurrencyIsoCode;
       opptyStageName = opptyRec.StageName;
       OpptyProductCount = opptyRec.NoOfProducts__c;
       opprecordtype = opptyrec.recordtypeid;
       System.debug('OppProductCount ' + OpptyProductCount);
       this.tAttachment = new Attachment();
    }
   
   /***This function results in attaching the Rate Card Quote in Notes and attachments commented on 7 Aug 2018***/  
    public Pagereference SaveRateCardAttachment()
    {
       if(this.tAttachment.Body!=null){
         Attachment attach = this.tAttachment.clone(false, true, false, false);
          attach.ParentID = OpptID ;
          this.tAttachment.Body = null;
          try {
              Database.insert(attach);
              ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Rate Card PDF attached successfully'));
          } 
          catch (Exception e) {
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing the Rate Card PDF: '+e.getMessage());
            ApexPages.addMessage(errormsg);                     
          } 
                     
       }
       return null;
    } 
    /***This function reads the CSV file and inserts records into the Opportunity Line object. ***/   
    public void ReadFileOppLineItems()
    {
        opptyRec.Skip_Client_Needs_Validation__c = true;   // Always Make the checkbox true to skip the validation before insert.
        update opptyRec;
       
        try{    
                DeleteRecordsOppLineItems();   
                errorMessage1 = ''; 
                System.debug('**contentFile ' + contentFile);                
                //Convert the uploaded file which is in BLOB format into a string
                nameFile =blobToString(contentFile,'ISO-8859-1');
                System.debug('**nameFile ' + nameFile);
                //Now sepatate every row of the excel file
                filelines = nameFile.split('\n');
                
                //Iterate through every line and create a Opportunity Line item record for each row
                OppLineItemupload = new List<OpportunityLineItem>();
                for (Integer i=1;i<filelines.size();i++){
                    String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');
                    
                    OpportunityLineItem oppl = new OpportunityLineItem();
                    oppl.OpportunityId= OpptID;   
                    if(!Test.isRunningTest()){               
                        oppl.PricebookentryId = inputvalues[0]; 
                        if(inputvalues[0] != ''){
                            InsertedPricebookEntryIds.add(inputvalues[0]);
                            System.debug('**PricebookExcelIds ' + InsertedPricebookEntryIds);
                        }
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
                   //Edited By Virendra Kumar as per SSE-8620 on 25/3/2019
                   // oppl.Platform__c = 'Talent Central';
                   // oppl.Usage_Allowance__c = 'Capped';       
                    oppl.Platform__c = inputvalues[22];     
                    oppl.Usage_Allowance__c = inputvalues[23];      
                    //Edition Ended By Virendra Kumar as per SSE-8620 on 25/3/2019
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
              System.debug('**nameFile2 ' + nameFile);
             if(nameFile == null ||  nameFile == '' || contentfile == null){
                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please Choose your Pricebook Items CSV file before uploading'));
             }
             else{ 
               System.debug('hello');      
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'An error has occured while reading the Pricebook Items CSV file: '+e.getMessage()));                         
             }
            errorMessage1 = e.getMessage();
         }  
             
         try{
            if(errorMessage1 == '' || errorMessage1 == null){
                insert OppLineItemupload;
                //UpdateOppClientNeeds();
            }
         }
         catch (Exception e){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'An error has occured while importing the Pricebook Items: '+e.getMessage()));          
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
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Pricebook Items imported successfully'));
                if(ExistingOppLineItems.size() > 0){
                   delete ExistingOppLineItems;
                }  
                contentFile = null;    
                system.debug('contentFile** ' + contentFile);          
             } 
         }    
         //return null;                   
            
    } 
   
   /***This function reads the CSV file and inserts records into the Discount Summary object. ***/
    public void ReadFileDiscountSum() {

        try{               
               nameFile1 =blobToString(contentFile1,'ISO-8859-1');               
               filelines1 = nameFile1.split('\n'); 
               errorMessage2 = '';
               
               DeleteRecordsDiscountSum(); 
               
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
              if(nameFile1 == null ||  nameFile1 == '' || contentFile1 == null){
                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please Choose your Discount Summary CSV file before uploading'));
              }
              else{        
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'An error has occured while reading the Discount Summary CSV file: '+e.getMessage()));
              }
              errorMessage2 = e.getMessage();
         }       
         try{
            if(errorMessage2 == '' || errorMessage2 == null){
                insert DiscountSumupload;
            }
         }
         catch (Exception e){            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'An error has occured while importing the Discount Summary records: '+e.getMessage()));
            errorMessage2 = e.getMessage();
         }                                   
         //return null;
         System.debug('**ErrorMessage2 ' + errorMessage2);
         if(errorMessage2 == '' || errorMessage2 == null){
            System.debug('**ErrorMessage2: ' + errorMessage2);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Discount Summary Records imported successfully'));
            if(ExistingDiscountSum.size() > 0){
                delete ExistingDiscountSum;
            } 
             contentFile1 = null;    
             system.debug('contentFile1** ' + contentFile1); 
         }      
    } 
  
    /*This function convers the input CSV file in BLOB format into a string
        @param input    Blob data representing correct string in @inCharset encoding
        @param inCharset    encoding of the Blob data (for example 'ISO 8859-1')
    */
    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }
       
    public void UpdateOppClientNeeds(){        
         if(HiringNeeds!=null && HiringNeeds.size()>0){
             if(HiringNeeds.size()==1){
                String HiringNeedValue = new List<String> (HiringNeeds)[0];
                opptyRec.TM_Phase__c = HiringNeedValue;
             }
             else
                opptyRec.TM_Phase__c = 'Mixed';
         }
         if(TalentLevels!=null && TalentLevels.size()>0){
             if(TalentLevels.size()==1){
                String TalentLevelValue = new List<String> (TalentLevels)[0];
                opptyRec.Talent_Level__c= TalentLevelValue;
             }
             else
                opptyRec.Talent_Level__c= 'Mixed';
         }
         if(PackageLevels!=null && PackageLevels.size()>0){
             if(PackageLevels!=null && PackageLevels.size()==1){
                String PackageLevelValue = new List<String> (PackageLevels)[0];
                opptyRec.Package_Level__c= PackageLevelValue;
             }
             else
                opptyRec.Package_Level__c= 'Mixed';
         }
         //Added by prabhat for SSE-10186 started
         if(Propositions!=null && Propositions.size()>0){
             if(Propositions!=null && Propositions.size()==1){
                String PropositionsValue = new List<String> (Propositions)[0];
                opptyRec.Proposition__c = PropositionsValue;
             }
             else
                opptyRec.Proposition__c= 'Mixed';
         }
         //Added by prabhat for SSE-10186 Ended
         // FOR OFFERING    COMMENTED DUE TO SSE-9068  AS OFFERING IS SET MANUALLY NOW AT INFORMATION GATHERING STAGE
        /* System.debug('**InsertedPricebookEntryIds' + InsertedPricebookEntryIds);
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
         if(count == 0 && ProductNamesSet.contains('Units In Advance')){            
            opptyRec.Offering__c = 'Assessments (Consumption-Based)';
         }*/
         // OFFERING END
         opptyRec.Skip_Client_Needs_Validation__c = false;       // This is to ensure no changes in client need section done after insert.
         update opptyRec; 
         HiringNeeds.clear();
         TalentLevels.clear();
         PackageLevels.clear();
         Propositions.clear();
         //ProductNamesSet.clear(); 
         InsertedPricebookEntryIds.clear();    
    }
    
    public void DeleteRecordsOppLineItems() { 
         ExistingOppLineItems = new List<OpportunityLineItem> ();     
         ExistingOppLineItems = [Select id,OpportunityId from OpportunityLineItem where OpportunityId =: OpptID];
         System.debug('**DeleteLines ' + ExistingOppLineItems);             
    }
    
    public void DeleteRecordsDiscountSum() {
         ExistingDiscountSum = new List<Discount_Summary__c>();
         ExistingDiscountSum = [Select id,Opportunity__c from Discount_Summary__c where Opportunity__c =: OpptID];                 
    }
    
    /*public Pagereference returnToOppty(){
        PageReference ReturnPage = new PageReference('/apex/ImportRateCard_VF?oppId='+ OpptID); 
        ReturnPage.setRedirect(true); 
        return ReturnPage;
    }*/
    
    public PageReference cancel() {
        PageReference ReturnPage = new PageReference('/'+OpptID); 
        ReturnPage.setRedirect(true); 
        return ReturnPage;
    }

                  
  }