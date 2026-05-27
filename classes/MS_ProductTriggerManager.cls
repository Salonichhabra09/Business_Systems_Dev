/*****************************************************************************
CREATED BY :- Prabhat Arora
CREATED DATE :- 21-08-2019
DESCRIPTION :- This class contains Methods to create Rating Progress records in context to MS Product & Rating Functionality as per SHL business process,
               this class is being refered from MS_Product_Trigger, covering the Before/After Insert/Delete & Update Events on MS Product Records. 
******************************************************************************/
Global class MS_ProductTriggerManager {
    //Commented By : Shubham Singh
    //Reason: deprecate Rating Progress
    //Reference: SSE-19314
    
    /*Public static void setcurencyISOCode(List<Bureau_Product__c> NewProductList){
        Set<Id> jobIdsSet = new Set<Id>();
        for(Integer i=0; i< NewProductList.size();i++)  
            jobIdsSet.add(NewProductList[i].Job__c);
        Map<Id,Job__c> jobsMap = new Map<Id,Job__c>([Select id,CurrencyToBeBilled__c from Job__c where id in :jobIdsSet]);
        for(Integer i=0; i< NewProductList.size();i++)  
            NewProductList[i].CurrencyIsoCode = jobsMap.get(NewProductList[i].Job__c).CurrencyToBeBilled__c;
    }
    
    Public static void DeleteProgressRating(List<Bureau_Product__c> OldProductList){
        Set<Id> bureauProductIdsSet = new Set<Id>();
        List<Bureau_Rating_Progress__c> bRatingProgressToDeleteList = new List<Bureau_Rating_Progress__c>();
        for(Integer i=0;i<OldProductList.size();i++)
            bureauProductIdsSet.add(OldProductList[i].id);
        Map<Id,Bureau_Product__c> bureauProductMap = new Map<Id,Bureau_Product__c>([Select id,(Select id,Status__c from Bureau_Ratings_Progresss__r) from Bureau_Product__c where id in :bureauProductIdsSet]);
        for(Integer i=0;i<OldProductList.size();i++)
        {
            Boolean productCanNotBeDeleted = false;
            for(Bureau_Rating_Progress__c bRP:bureauProductMap.get(OldProductList[i].id).Bureau_Ratings_Progresss__r)
            {
                if(bRP.Status__c == 'In Progress' || bRP.Status__c == 'Completed')
                {
                    productCanNotBeDeleted = true;
                    OldProductList[i].addError('This product cannot be deleted as there are related ratings which are either in progress or completed. Please change the status of these ratings to "Not Started" in order to delete this product.');
                    break;
                }
            }
            if(bureauProductMap.get(OldProductList[i].id).Bureau_Ratings_Progresss__r.size()>0 && productCanNotBeDeleted == false)
                bRatingProgressToDeleteList.addAll(bureauProductMap.get(OldProductList[i].id).Bureau_Ratings_Progresss__r);
        }
        if(bRatingProgressToDeleteList.size()>0){
            if(bRatingProgressToDeleteList.size()<8000){
                delete bRatingProgressToDeleteList;
            }
        }
    }
    
    //Commented By : Pallavi Jadhav
    //Reason: deprecate Rating Progress
    //Reference: SSE-18140
    /*Public static void InsertProgressRating(List<Bureau_Product__c> NewProductList,List<Bureau_Product__c> OldProductList,Boolean IsInsert){
        Set<Id> jobIds = new Set<Id>();
        Set<Id> invoiceOnlyProductIds = new Set<Id>();
        Set<Id> bureauProductIds = new Set<Id>();
        for(Integer i=0;i<NewProductList.size();i++)
        {
            if(NewProductList[i].Item_Type__c=='Instrument')
            {
                bureauProductIds.add(NewProductList[i].id);
                if(IsInsert)
                {
                    if(NewProductList[i].Invoice_Only__c==false)
                        jobIds.add(NewProductList[i].Job__c);
                }
                else if(!IsInsert)
                {
                    if(NewProductList[i].Invoice_Only__c!=OldProductList[i].Invoice_Only__c)
                    {
                        if(NewProductList[i].Invoice_Only__c==false)
                            jobIds.add(NewProductList[i].Job__c);
                        else
                            invoiceOnlyProductIds.add(NewProductList[i].Id);
                    }
                }
            }
        }
        
        Savepoint sp = Database.setSavepoint();
        List<Bureau_Product__c> bureauProductsList = [Select id,Item__r.Category__c,Item__c,Invoice_Only__c,Job__c
                                                      from Bureau_Product__c where id in :bureauProductIds];
        try{
            if(jobIds.size()>0)
            {
                List<Bureau_Rating__c> bureauRatingsList = [Select Id,Participant__r.Bureau_Job__c,Respondent__c FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c IN :jobIds ORDER BY Participant__r.Bureau_Job__c];
                IF(bureauRatingsList.size()>0)
                {
                    Map<Id,List<Bureau_Rating__c>> bureauJobsMap = new Map<Id,List<Bureau_Rating__c>>();
                    List<Bureau_Rating__c> ratingsList;
                    for(Bureau_Rating__c bureauRating:bureauRatingsList)
                    {
                        if(bureauJobsMap.get(bureauRating.Participant__r.Bureau_Job__c)==null)
                        {
                            ratingsList = new List<Bureau_Rating__c>();
                            ratingsList.add(bureauRating);
                            bureauJobsMap.put(bureauRating.Participant__r.Bureau_Job__c,ratingsList);
                        }
                        else 
                            bureauJobsMap.get(bureauRating.Participant__r.Bureau_Job__c).add(bureauRating);
                        
                    }
                    List<Bureau_Rating_Progress__c> ratingProgressList = new List<Bureau_Rating_Progress__c>();
                    for(Bureau_Product__c bureauProduct: bureauProductsList)
                    {
                        if(bureauProduct.Invoice_Only__c==false)
                        {
                            for(Bureau_Rating__c bureauRating:bureauJobsMap.get(bureauProduct.Job__c))
                            {
                                if(bureauProduct.Item__r.Category__c == '360 Services')
                                {
                                    Bureau_Rating_Progress__c ratingProgress = new Bureau_Rating_Progress__c();
                                    ratingProgress.Bureau_Product__c = bureauProduct.id;
                                    ratingProgress.Bureau_Rating__c = bureauRating.id;
                                    ratingProgressList.add(ratingProgress);
                                }
                                else
                                {
                                    if(bureauRating.Participant__c == bureauRating.Respondent__c)
                                    {
                                        Bureau_Rating_Progress__c ratingProgress = new Bureau_Rating_Progress__c();
                                        ratingProgress.Bureau_Product__c = bureauProduct.id;
                                        ratingProgress.Bureau_Rating__c = bureauRating.id;
                                        ratingProgressList.add(ratingProgress);
                                    }
                                }
                            }
                        }
                    }
                    if(ratingProgressList.size()>0){
                        if(ratingProgressList.size()<8000){
                            insert ratingProgressList;
                        }else{
                            manageBureauRatingProgressInsert_Batch createBRP = new manageBureauRatingProgressInsert_Batch(ratingProgressList);
                            ID batchprocessid = Database.executeBatch(createBRP,500);
                        }
                    }
                }
            }
            
            if(invoiceOnlyProductIds.size()>0){
                List<Bureau_Rating_Progress__c> ratingProgressToBeDeleted = [SELECT Id FROM Bureau_Rating_Progress__c WHERE Bureau_Product__c IN:invoiceOnlyProductIds];
               // List<Bureau_Candidate_Score__c> candidateScoresTobeDeleted = [SELECT Id FROM Bureau_Candidate_Score__c WHERE Bureau_Product__c IN:invoiceOnlyProductIds];
                if(ratingProgressToBeDeleted.size()>0)
                    delete ratingProgressToBeDeleted;
             //if(candidateScoresTobeDeleted.size()>0)
               //     delete candidateScoresTobeDeleted; 
            }
            
        }catch(Exception e){
            DataBase.Rollback(sp);
            for(Integer i=0;i<NewProductList.size();i++)
                NewProductList[i].addError(e.getMessage());
        }
    }*/
}