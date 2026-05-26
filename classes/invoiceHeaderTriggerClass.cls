public class invoiceHeaderTriggerClass
{

public static map<id,Contract_Invoice_Header__c> mapIRidandInvoiceHeader = new map<id,Contract_Invoice_Header__c> (); 
public static map<id,Project_invoice__c> mapIRidandIR = new map<id,Project_invoice__c>();
public static map<id,Contract_Invoice_Header__c> mapoldIRidandInvoiceHeader = new map<id,Contract_Invoice_Header__c> (); 
public static map<id,Contract_Invoice_Header__c> mapdislinkIRidandInvoiceHeader2 = new map<id,Contract_Invoice_Header__c> (); 

public static boolean triggerRun = false;
public static  boolean InvHeaderCreditNote =false;
public static  boolean removeSunInvoice = false;

   //SSE-6223:'Invoice Status' cannot be set as 'Ready to Invoice' OR 'Ready for SOE Review' 
   //IF 'IM Lookup Code' for any of its child invoice line has a value of 'Multiple Options Available' OR 'No valid option available'
   
   public void invoiceStatusValidation(list<Contract_Invoice_Header__c > listInvHeader,list<Contract_Invoice_Header__c > listOldInvHeader,map<id,Contract_Invoice_Header__c> newMap,map<id,Contract_Invoice_Header__c> oldMap )
   {
   
    if(UserInfo.getName() != 'Globus Integration integration')
   {
       set<id> setInvHeadID = new  set<id>();
       list<Contract_Invoice_Line__c> listInvLine = new list<Contract_Invoice_Line__c>();
       map<id,Contract_Invoice_Line__c> mapIHidandInvoiceLines = new map<id,Contract_Invoice_Line__c>();
       for(Contract_Invoice_Header__c invoiceHeader :listInvHeader)
       {
           if(listOldInvHeader!=null && invoiceHeader.Invoice_status__c!= oldMap.get(invoiceHeader.id).Invoice_status__c && (invoiceHeader.Invoice_status__c =='Ready to Invoice' || invoiceHeader.Invoice_status__c =='Ready for SOE Review'||invoiceHeader.Invoice_status__c =='Ready for Sun Transfer')) 
           {
               setInvHeadID.add( invoiceHeader.id);
           }
       }
       if(setInvHeadID!=null && setInvHeadID.size()>0)
       {
            listInvLine = [Select id,Invoice_Header_ID__c  from Contract_Invoice_Line__c where Invoice_Header_ID__c in :setInvHeadID AND (SUN_IM_lookup_code__c = 'Multiple Options Available' OR SUN_IM_lookup_code__c = 'No valid option available' Or SUN_IM_lookup_code__c='' OR SUN_IM_lookup_code__c=null) ];
       }
       if(listInvLine !=null && listInvLine .size()>0)
       {       
           for(Contract_Invoice_Line__c objInvLine :listInvLine )
           {
              mapIHidandInvoiceLines.put(objInvLine.Invoice_Header_ID__c , objInvLine );
           
           }
       }
       
       for(Contract_Invoice_Header__c objInvHeader:listInvHeader)
       {
        if(mapIHidandInvoiceLines!=null && mapIHidandInvoiceLines.size()>0 && mapIHidandInvoiceLines.containskey(objInvHeader.id))
        {
            objInvHeader.addError('Invoice Status cannot be ' +objInvHeader.Invoice_status__c + ' if any of the related invoice lines does not have a valid value in IM Lookup Code');
        }
       
       }
   }
   
   }
   //added by ritika--sse-6539
   public void updateRecentValuesonIR(list<Contract_Invoice_Header__c> newInvoiceHeader,map<id,Contract_Invoice_Header__c> oldmapIH)
{   
triggerRun = true;
System.debug('##ClassNew' + newInvoiceHeader);
System.debug('##ClassOld' + oldmapIH);
set<id> setIRid = new set<id>();
    for (Contract_Invoice_Header__c InvoiceHeader : newInvoiceHeader)
    {
        //Scenario 1 - Invoice header is linked to an invoice request and the invoice header has a Sun Order Number
        if( InvoiceHeader.Invoice_Request__c!=oldmapIH.get(InvoiceHeader.id).Invoice_Request__c || (InvoiceHeader.SunSystems_Order_Reference__c !=oldmapIH.get(InvoiceHeader.id).SunSystems_Order_Reference__c) )//InvoiceHeader.Invoice_Request__c!=null &&
        {
            
            if(InvoiceHeader.Invoice_Request__c!=null)
            {
                 setIRid.add(InvoiceHeader.Invoice_Request__c);    //add new linked Invoice request
                mapIRidandInvoiceHeader.put(InvoiceHeader.Invoice_Request__c,InvoiceHeader); 
                
            }
            if(InvoiceHeader.Invoice_Request__c!=oldmapIH.get(InvoiceHeader.id).Invoice_Request__c && oldmapIH.get(InvoiceHeader.id).Invoice_Request__c!=null )
            {
                 setIRid.add(oldmapIH.get(InvoiceHeader.id).Invoice_Request__c);//adding old inv request 
                 mapoldIRidandInvoiceHeader.put(oldmapIH.get(InvoiceHeader.id).Invoice_Request__c,oldmapIH.get(InvoiceHeader.id)); 
                 mapdislinkIRidandInvoiceHeader2.put(oldmapIH.get(InvoiceHeader.id).Invoice_Request__c,InvoiceHeader); 
                 
            }
             if(InvoiceHeader.Invoice_Request__c==null && oldmapIH.get(InvoiceHeader.id).Invoice_Request__c!=null)//dislink
             {
                 setIRid.add(oldmapIH.get(InvoiceHeader.id).Invoice_Request__c); //dislinking Invoice request
                 mapoldIRidandInvoiceHeader.put(oldmapIH.get(InvoiceHeader.id).Invoice_Request__c,oldmapIH.get(InvoiceHeader.id));
                 mapdislinkIRidandInvoiceHeader2.put(oldmapIH.get(InvoiceHeader.id).Invoice_Request__c,InvoiceHeader); 
                 //mapdislinkIRidandInvoiceHeader2.put(); 
             }
        }
       
    }   
    if(setIRid!=null && setIRid.size()>0)
    {
        updateRecentValuesonInvRequest(setIRid);
    }
}

public static void updateRecentValuesonInvRequest(set<id> invReqId)
{
    list<Project_Invoice__c> listUpdateIR = new list<Project_Invoice__c>();    
    map<id,Project_Invoice__c> mapIdandInvReq = new map<id,Project_Invoice__c>([select id,Status__c,Invoice_Header_Reference__c,Sun_Invoice_No__c,Credit__c from Project_Invoice__c where id in:invReqId]);
    for(id IRid:invReqId )
    {
        if(mapIdandInvReq!=null && mapIdandInvReq.get(IRid)!=null)
        {
        Project_Invoice__c objIR = new Project_Invoice__c();
        objIR = mapIdandInvReq.get(IRid);
        system.debug('>>>>>>mapIdandInvReq'+mapIdandInvReq +'>>>>mapoldIRidandInvoiceHeader'+mapoldIRidandInvoiceHeader );
     
        if(mapoldIRidandInvoiceHeader!=null && mapoldIRidandInvoiceHeader.get(IRid)!=null)
        {
            system.debug('inside else if1.1>>>');
            //no change
            //scenario 5- deletion of Invoice Request from IH.
            system.debug('MAP1' + mapIdandInvReq.get(IRid).Status__c );
            system.debug('MAP2' + mapoldIRidandInvoiceHeader.get(IRid).Invoice_Request__c);
            system.debug('MAP3' + mapdislinkIRidandInvoiceHeader2.get(IRid).Invoice_Request__c);
            
            if(mapIdandInvReq.get(IRid).Status__c == 'Processed' && (mapdislinkIRidandInvoiceHeader2.get(IRid).Invoice_Request__c==null || mapdislinkIRidandInvoiceHeader2.get(IRid).Invoice_Request__c=='') )
            { 
            InvHeaderCreditNote = mapoldIRidandInvoiceHeader.get(IRid).credit_note__c;
            removeSunInvoice = true;
            updateIRonSORdel(objIR); 
                
            }
            else
            {
            System.debug('Entering');
            objIR.Sun_Invoice_No__c = '';
            objIR.Invoice_Header_Reference__c = null;  
            if(objIR.status__c!='Submitted for Processing')
            objIR.status__c = 'In Progress';            
            }  
         } 
        else if(mapIdandInvReq!=null && mapIdandInvReq.get(IRid)!=null && mapIdandInvReq.get(IRid).Status__c == 'Processed' && mapIdandInvReq.get(IRid).Sun_Invoice_No__c != '' &&(mapIRidandInvoiceHeader!=null && mapIRidandInvoiceHeader.get(IRid)!=null && (mapIRidandInvoiceHeader.get(IRid).SunSystems_Order_Reference__c=='' ||mapIRidandInvoiceHeader.get(IRid).SunSystems_Order_Reference__c==null) ))
        {
            system.debug('inside else if1>>>');
            //no change
            //scenario 5- deletion of sun order number from IH
            if(mapIdandInvReq.get(IRid).Status__c == 'Processed' && (mapIRidandInvoiceHeader.get(IRid).SunSystems_Order_Reference__c==null||mapIRidandInvoiceHeader.get(IRid).SunSystems_Order_Reference__c=='') )
            { 
            InvHeaderCreditNote = mapIRidandInvoiceHeader.get(IRid).credit_note__c; removeSunInvoice = true;
            updateIRonSORdel(objIR); 
                
            }
           
        }
        else
        {
            system.debug('inside else >>>');
            if(mapIRidandInvoiceHeader!=null && mapIRidandInvoiceHeader.get(IRid)!=null )
            {
                              
                if(mapIRidandInvoiceHeader.get(IRid).SunSystems_Order_Reference__c!=null && mapIRidandInvoiceHeader.get(IRid).SunSystems_Order_Reference__c!='')
                {  
                    System.debug('Status ' + mapIdandInvReq.get(IRid).Status__c);
                   if(mapIdandInvReq.get(IRid).Status__c!= 'Processed'){
                       
                       objIR.Invoice_Header_Reference__c = mapIRidandInvoiceHeader.get(IRid).Name;
                   }
                   if((mapIRidandInvoiceHeader.get(IRid).Credit_Note__c!= true) || (mapIRidandInvoiceHeader.get(IRid).Credit_Note__c== true && mapIdandInvReq.get(IRid).Credit__c == true)){    // Added by Pankhuri
                    objIR.Sun_Invoice_No__c = mapIRidandInvoiceHeader.get(IRid).SunSystems_Order_Reference__c;
                    objIR.Invoice_Header_Reference__c = mapIRidandInvoiceHeader.get(IRid).Name;
                   } // if end
                }
                else
                {
                   if(mapIdandInvReq.get(IRid).Status__c!= 'Processed'){                    
                       objIR.Invoice_Header_Reference__c = mapIRidandInvoiceHeader.get(IRid).Name;
                       objIR.Sun_Invoice_No__c='';
                   }
                    
                }
            }
            else
            {
                if(mapIdandInvReq.get(IRid).Status__c != 'Processed' )
                {
                    objIR.Invoice_Header_Reference__c=null;
                    objIR.Sun_Invoice_No__c='';
                    if(objIR.status__c!='Submitted for Processing')
                        objIR.status__c = 'In Progress';
                }
            }
          
        }
        listUpdateIR.add(objIR);
        mapIRidandIR.put(objIR.id,mapIdandInvReq.get(IRid));
    }
    }
    if(listUpdateIR!=null && listUpdateIR.size()>0)
    {  
        update listUpdateIR;  

        submitInvoiceReqApproval(listUpdateIR);//submit for approval in case of dislinking 
        processInvoiceRequest(listUpdateIR);//approved it if already submit and inv header and sun ord is not blank
            
    }
    
}
//method to update the status to Processed by calling approval process
public static void  processInvoiceRequest(list<Project_Invoice__c> listInvRequest)
{
    system.debug('mapIRidandIR>>>>'+mapIRidandIR);
    for(Project_Invoice__c objInvReq : listInvRequest)
    {                                                   
        if(mapIRidandIR.get(objInvReq.id).Status__c == 'Submitted for Processing' && mapIRidandIR.get(objInvReq.id).Sun_Invoice_No__c!='')//handling scenario 2
        {
         
         system.debug('mapIRidandIR2>>>>'+mapIRidandIR); 
         if((mapIRidandInvoiceHeader.get(objInvReq.id).Credit_Note__c!= true) || (mapIRidandInvoiceHeader.get(objInvReq.id).Credit_Note__c== true && mapIRidandIR.get(objInvReq.id).Credit__c == true)){  // if condition added by pankhuri
            System.debug('hello1');
                try{
                ProcessInstance processInstance = [Select Id FROM ProcessInstance where targetobjectId = :objInvReq.id AND Status=:'Pending'];         
                ProcessInstanceWorkItem workItem = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstanceId = :processInstance.id];       
                    
                Approval.ProcessWorkitemRequest approvalRequest = new Approval.ProcessWorkitemRequest(); approvalRequest.setComments('Processing invoice.'); approvalRequest.setAction('Approve');
                approvalRequest.setWorkitemId(workItem.Id); Approval.ProcessResult processResult = Approval.process(approvalRequest);
                }
                catch(Exception e){}
            
            } // if end
        }
    } 
system.debug('mapIRidandIR11>>>>'+mapIRidandIR) ;
}
//submit for approval after dislinking
 public static void  submitInvoiceReqApproval(list<Project_Invoice__c> listInvRequest)
    {
        system.debug('inside submitInvoiceReqApproval>>>'+listInvRequest);
        for(Project_Invoice__c objInvReq : listInvRequest)
        {   
            if((mapIRidandIR.get(objInvReq.id).Sun_Invoice_No__c ==''|| mapIRidandIR.get(objInvReq.id).Sun_Invoice_No__c==null)  && mapIRidandIR.get(objInvReq.id).Status__c != 'Submitted for Processing') {
            //Create a process instance for submitting the invoice 
            system.debug('submit for process......');
            Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
            submitRequest.setComments('Submitting invoice for processing.');
            submitRequest.setObjectId(objInvReq.id);
            Approval.ProcessResult processResult = Approval.process(submitRequest);
        }           
        }       
    }
    
public static void updateIRonSORdel(Project_invoice__c invRequest)
{
    boolean InvoiceRequestcreditNote=false;
    system.debug('inside updateIRonSORdel'+invRequest);
     if(invRequest.Credit__c==true && InvHeaderCreditNote == true) // removeSunInvoice==true
    {       
        InvoiceRequestcreditNote = true;
    }   
    else if(InvHeaderCreditNote ==false)
    {       
        InvoiceRequestcreditNote = false;
    }
    
    system.debug('InvoiceRequestcreditNote>>>>'+InvoiceRequestcreditNote );
        List<Contract_Invoice_Header__c> listIH = new list<Contract_Invoice_Header__c>([Select id,Name,SunSystems_Order_Reference__c,Invoice_Request__c,Sales_Type__c,credit_note__c from Contract_Invoice_Header__c where Invoice_Request__c =:invRequest.id and credit_note__c =: InvoiceRequestcreditNote and SunSystems_Order_Reference__c!=null order by createddate desc limit 1]);//((not Sales_Type__c LIKE '%CN') OR Sales_Type__c = ''
        system.debug('listIH>>>>'+listIH);
        if(listIH!=null && listIH.size()>0)
        {
        system.debug('inside if2>>>>');
            invRequest.Sun_Invoice_No__c = listIH[0].SunSystems_Order_Reference__c; invRequest.Invoice_Header_Reference__c= listIH[0].Name;
           
        }
        else
        {
            system.debug('inside else2>>>>');        
            {
            invRequest.Sun_Invoice_No__c = '';
            invRequest.Invoice_Header_Reference__c = null;
            if(invRequest.status__c!='Submitted for Processing')
                invRequest.status__c = 'In Progress';
            }
            
        }
    }

 }