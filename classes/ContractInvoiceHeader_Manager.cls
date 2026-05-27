global with sharing class ContractInvoiceHeader_Manager
{
    //This method accepts the Id of an Invoice Header as input, creates a clone of the Invoice Header corresponding to this Id as well as the Invoice Lines related to this Invoice Header, inserts these clones in the database and return a SUCESS/ERORR/UNAUTHORISED message
    WebService static String[] superClone(String invoiceHeaderId)
    {
        try
        {
            //Check if the user has permissions to create the Invoice Header & the Invoice Lines 
            if(!(Schema.sObjectType.Contract_Invoice_Header__c.isCreateable() && Schema.sObjectType.Contract_Invoice_Line__c.isCreateable()))
                //Return a Message for no permissions
                return new String[]{'UNAUTHORISED'};
            
            //Create a Clone of the current Invoice Header 
            Contract_Invoice_Header__c newInvoiceHeader = createCloneOfContractInvoiceHeader(invoiceHeaderId);
            //Insert the cloned invoice Header in the Database
            insert newInvoiceHeader;
            
            //Create a Clone of the Invoice Lines related of the current Invoice Header             
            List<Contract_Invoice_Line__c> newInvoiceLineList = createCloneOfContractInvoiceLines(invoiceHeaderId);
            //Iterate through each of the cloned Invoice Lines
            for(Contract_Invoice_Line__c newInvoiceLine:newInvoiceLineList)
            {
                //Set the relationship between the cloned Invoice Line and the cloned Invoice Header
                newInvoiceLine.Invoice_Header_ID__c = newInvoiceHeader.id;
                //Increment the Month of the cloned Invoice Line by 1
                //If the incremented Month is null then return an error message.
                
                /* Commented on 24 Oct 2017 by Pankhuri Jain for SSE-5399, to remove month__c usage
                newInvoiceLine.Month__c = incrementInvoiceLineMonth(newInvoiceLine.Month__c);              
                if(newInvoiceLine.Month__c==null)
                    return new String[]{'The Month for one or more Invoice Lines of this Invoice header is not in the correct date format (yyyymm).'};
                Comment End */
                
            }
            //Insert the list of the cloned Invoice Lines 
            insert newInvoiceLineList;
            
            //Query the Name of new Invoice Header in order to add it in the Success Message 
            newInvoiceHeader = [SELECT Id, Name FROM Contract_Invoice_Header__c WHERE Id = :newInvoiceHeader.id];
            //Return the success message
            return new string[]{'SUCCESS',newInvoiceHeader.id,newInvoiceHeader.Name};
        }
        catch(Exception e)
        {
            System.debug('Failed method: superClone. Error:'+e.getMessage());
            //Return the exception message 
            return new String[]{e.getMessage()};
        }
    }
    
    //This method accepts the Id of an Invoice Header as input, retreives the Invoice Header corresponding to this Id from the database and returns a clone of the retrieved Invoice Header
    private static Contract_Invoice_Header__c createCloneOfContractInvoiceHeader(String invoiceHeaderId)
    {Contract_Invoice_Header__c invoiceheaderclone = new Contract_Invoice_Header__c();
        //Create a string all creatable fields of the Invoice Header object
        String contractInvoiceHeaderFieldsString = getObjectFieldsString(Schema.SObjectType.contract_Invoice_Header__c.fields.getMap());
        //Create a string of the Query required to fetch the Invoice Header to be cloned using the above string of Invoice Header fields
        String contractInvoiceHeaderQuery = String.format('SELECT {0},CurrencyIsoCode FROM Contract_Invoice_Header__c WHERE Id = {1} LIMIT 1',new String[]{contractInvoiceHeaderFieldsString,'\''+invoiceHeaderId+'\''});
        //Retreive the Invoice Header to be cloned by executeing the query created above
        Contract_Invoice_Header__c invoiceHeader = DataBase.query(contractInvoiceHeaderQuery);
        id editRecTypeId = [select Id ,name from RecordType where SobjectType='Contract_Invoice_Header__c' and name = 'Invoice Header'].id;
        
        //update a current date 
        invoiceHeader.Process_Date__c = System.today();
        //Return a clone of the Invoice Header retrieved above
        //return invoiceHeader.clone(false,true);
          invoiceheaderclone = invoiceHeader.clone(false, true);
          invoiceheaderclone.Invoice_Status__c='Draft';
         
            invoiceheaderclone.Sun_Invoice_Number__c= null;
            invoiceheaderclone.Project_Number__c= null;
            invoiceheaderclone.Invoice_Request__c= null;
          //invoiceheaderclone.Invoice_Comments__c= '';//printable Note SSE-6226:commented by ritika
     
            invoiceheaderclone.Alternative_Responsible_Code_1__c= null;
            invoiceheaderclone.Manual_Transfer__c= true;
            invoiceheaderclone.Sales_Type__c= null;
           // invoiceheaderclone.Invoice_Header_Comments__c='';//extended comments:SSE-6226:commented by ritika
          
          invoiceheaderclone.SunSystems_Order_Reference__c= null;
           invoiceheaderclone.RecordTypeId  =editRecTypeId ;//SSE-6226:added by ritika
            invoiceheaderclone.SFDC2SUN_Log__c= null;
            invoiceheaderclone.SFDC2SUN_Transferred_By__c=null;
           invoiceheaderclone.SFDC2SUN_Transferred_On__c=null;
            invoiceheaderclone.SFDC2SUN_Transfer_Status__c='';
                           
        return invoiceheaderclone;
        
    }
    
    //This method accepts the Id of an Invoice Header as input, retreives the list of Invoice Lines related to the Invoice Header corresponding to this Id from the database and returns a cloned list of the retrieved Invoice Lines 
    private static List<Contract_Invoice_Line__c> createCloneOfContractInvoiceLines(String invoiceHeaderId)
    {
        //Create a string all creatable fields of the Invoice Line object
        String contractInvoiceLineFieldsString = getObjectFieldsString(Schema.SObjectType.Contract_Invoice_Line__c.fields.getMap());
        //Create a string of the Query required to fetch the Invoice Lines to be cloned using the above string of Invoice Line fields
        String contractInvoiceLineQuery = String.format('SELECT {0},CurrencyIsoCode FROM Contract_Invoice_Line__c WHERE Invoice_Header_ID__c ={1}',new String[]{contractInvoiceLineFieldsString,'\''+invoiceHeaderId+'\''});
        //Retreive the list of Invoice Lines to be cloned by executeing the query created above
        List<Contract_Invoice_Line__c> invoiceLineList = DataBase.query(contractInvoiceLineQuery);
       
        //Return a cloned list of the Invoice Lines reterieved above
        return invoiceLineList.deepClone(false);
    }
    
    //This method accepts the Month of the Invoice Line, increments the month by 1 and return the incremented month
    private static String incrementInvoiceLineMonth(String invoiceLineMonth)
    {
        //Check if the length of Month is not equal to 6 
        if(invoiceLineMonth.length()==6)
        {
            //If yes, then create a Datetime variable for the Month String 
            Datetime invoiceLineDate = Datetime.newInstance(integer.valueOf(invoiceLineMonth.substring(0,4)), integer.valueOf(invoiceLineMonth.substring(4,6)), 10);
            //Add 1 month to the Datetime variable create above
            invoiceLineDate = invoiceLineDate.addMonths(1);
            //Return the incremented Datetime variable in the form of a string of format 'yyyyMM'
            return invoiceLineDate.format('yyyyMM');
        }
        else
            //If no, then return a null value so that an approriate error message can be thrown
            return null;
    }
    
    //This method accepts the a Map of object fields as an input, creates a comma delimited string of these fields and returns this string of fields
    private static String getObjectFieldsString(Map<String, Schema.SObjectField> objectFieldsMap)
    {
        //Create an empty string of Fields
        string fieldsString = ''; 
        //Iterate through each Field of the Fields Map
        for(Schema.SObjectField field:objectFieldsMap.values())
        {
            //Get the schema description of the current Field
            Schema.DescribeFieldResult fieldDesc = field.getDescribe();
            //Check if the field is creatable and it doesn't have a default value
            if(fieldDesc.isCreateable()==true && fieldDesc.isDefaultedOnCreate()==false)
                //If yes, then append the name of this field to the string of fields followed by a comma 
                fieldsString += fieldDesc.getName() + ',';
        }
        //Return the string of fields generated above after removing the last comma
        return fieldsString.subString(0,fieldsString.lastIndexOf(','));
    }
    
    
}