/*****************************************************************************
CREATED BY :- Prabhat Arora
CREATED DATE :- 21-08-2019
DESCRIPTION :- This class contains Methods to create Rating Progress in context to MS Rating Functionality as per SHL business process,
               this class is being refered from MS_Rating_Trigger, covering the After Insert Events on MS Rating Records. 
******************************************************************************/

Global class MS_RatingTriggerManager{
    
    global MS_RatingTriggerManager(){
        
    }
    //Commented By : Pallavi Jadhav
    //Reason: deprecate Rating Progress
    //Reference: SSE-18140
    /*Public static void CreateRatingProgress(List<Bureau_Rating__c> NewRatingList){
        //Create a set of Respondent Ids of the inserted ratings
        Set<Id> respondentIds = new Set<Id>();
        for(Bureau_Rating__c rating:NewRatingList)
        {
            if(!respondentIds.contains(rating.Respondent__c))
                respondentIds.add(rating.Respondent__c);
        }
        
        //Initiate a Job map that shall be used to get the Job instruments if required.  
        Map<Id, Job__c> jobMap = new Map<Id, Job__c>();
        
        //Create a map of candidates with the set of instrument ids selected for that candidate 
        Map<Id, Set<Id>> respondentsMap = new Map<Id, Set<Id>>();
        
        if(respondentIds.size()>0){
            for(Bureau_Rating_Progress__c existingRatingProgress: [SELECT Id,Rater__c,Bureau_Product__c FROM Bureau_Rating_Progress__c WHERE Rater__c IN :respondentIds ORDER BY Rater__c])
            {
                if(!respondentsMap.containsKey(existingRatingProgress.Rater__c))
                    respondentsMap.put(existingRatingProgress.Rater__c,new Set<Id>());
                Set<Id> instrumentIds = respondentsMap.get(existingRatingProgress.Rater__c);
                if(!instrumentIds.contains(existingRatingProgress.Bureau_Product__c))
                    instrumentIds.add(existingRatingProgress.Bureau_Product__c);
            }
        }
        
        //Initiate a list of rating progress records to be created
        List<Bureau_Rating_Progress__c> ratingsProgressToBeCreated = new List<Bureau_Rating_Progress__c>();
        
        //Loop through each inserted rating and create a rating progress record for each instrument selected for the rating's respondent
        
        Set<Id> allInstrumentsIdsSet = new set<Id>();
        for(Bureau_Rating__c rating:NewRatingList)
        {
            //Get the instruments selected for the current rating's respondent from the respondents map
            Set<Id> respondentInstrumentIds = respondentsMap.get(rating.Respondent__c);
            
            //If there are no instruments selected for the current rating's respondent
            if(respondentInstrumentIds==null)
            {
                //If the rating's Job doesn't exist in the Job map, then fetch the Job along with its instruments
                if(!jobMap.containsKey(rating.Bureau_Job__c))
                    jobMap.put(rating.Bureau_Job__c,[SELECT Id,(SELECT Id FROM Bureau_Products__r WHERE Category__c='Instrument') FROM Job__c WHERE Id=:rating.Bureau_Job__c]); 
                
                //Get the instruments for the Job
                List<Bureau_Product__c> respondentInstruments = jobMap.get(rating.Bureau_Job__c).Bureau_Products__r;
                respondentInstrumentIds =  new Set<Id>();
                for(Bureau_Product__c instrument: respondentInstruments)
                    respondentInstrumentIds.add(instrument.Id);
            }
            allInstrumentsIdsSet.addAll(respondentInstrumentIds);
        }
        Map<Id,Boolean> isInstrument360 = new Map<Id,Boolean>();
        if(allInstrumentsIdsSet.size()>0){
            for(Bureau_Product__c bProduct:[SELECT Id,Item__r.Category__c,Item__c FROM Bureau_Product__c WHERE Category__c ='Instrument' and id in :allInstrumentsIdsSet])
            {
                if(bProduct.Item__r.Category__c == '360 Services')
                    isInstrument360.put(bProduct.id,true);
                else
                    isInstrument360.put(bProduct.id,false);
            }
        }
        for(Bureau_Rating__c rating:NewRatingList)
        {   
            
            //Get the instruments selected for the current rating's respondent from the respondents map
            Set<Id> respondentInstrumentIds = respondentsMap.get(rating.Respondent__c);
            
            //If there are no instruments selected for the current rating's respondent
            if(respondentInstrumentIds==null)
            {
                List<Bureau_Product__c> respondentInstruments = jobMap.get(rating.Bureau_Job__c).Bureau_Products__r;
                respondentInstrumentIds =  new Set<Id>();
                for(Bureau_Product__c instrument: respondentInstruments)
                    respondentInstrumentIds.add(instrument.Id);
            }
            //Add a rating for each instrument of the Job
            for(Id instrumentId: respondentInstrumentIds)
            {
                if(isInstrument360.get(instrumentId))
                {
                    Bureau_Rating_Progress__c ratingProgress = new Bureau_Rating_Progress__c();
                    ratingProgress.Bureau_Rating__c = rating.Id;
                    ratingProgress.Bureau_Product__c = instrumentId;
                    ratingProgress.Status__c = 'Not Started';
                    ratingsProgressToBeCreated.add(ratingProgress);
                }
                else
                {
                    if(rating.Participant__c == rating.Respondent__c)
                    {
                        Bureau_Rating_Progress__c ratingProgress = new Bureau_Rating_Progress__c();
                        ratingProgress.Bureau_Rating__c = rating.Id;
                        ratingProgress.Bureau_Product__c = instrumentId;
                        ratingProgress.Status__c = 'Not Started';
                        ratingsProgressToBeCreated.add(ratingProgress);
                    }
                }
            }
        }
        
        insert ratingsProgressToBeCreated;
    }*/
}