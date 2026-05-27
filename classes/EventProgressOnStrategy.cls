public class EventProgressOnStrategy {
    @InvocableMethod(label='Strategy Progress ' description='Updates the progress on strategy for completed events')
  public static void updateProgressOnStrategy() {
    
    List<Event> eventList = [SELECT Id,Is_Completed__c,endDate,WhatId FROM Event WHERE (Status__c NOT IN ('Completed','Cancelled')) AND endDate < TODAY AND Is_Completed__c=false AND What.Type='Strategy_and_Goal__c'];
    Map<Id,Integer> strategyMap = new Map<Id,Integer>();
    if(eventList.size()>0){
        List<Event> eventToUpdate = new List<Event>();
        for (Event event : eventList) {
        if(strategyMap.get(event.WhatId)==null){
            strategyMap.put(event.whatId,1);
        }else{
            strategyMap.put(event.whatId,strategyMap.get(event.whatId)+1);
        }
        Event eve = new Event();
        eve.Id = event.Id;
        eve.Is_Completed__c = true;
        eventToUpdate.add(eve);
    }
    List<Strategy_and_Goal__c> strategyList = [SELECT Id,Number_of_tasks_completed__c FROM Strategy_and_Goal__c WHERE Id IN :strategyMap.keySet()];
    List<Strategy_and_Goal__c> strategyToUpdate = new List<Strategy_and_Goal__c>();
            for (Strategy_and_Goal__c strategy : strategyList) {
                Strategy_and_Goal__c str = new Strategy_and_Goal__c();
                str.Id = strategy.Id;
                str.Number_of_tasks_completed__c = strategy.Number_of_tasks_completed__c + strategyMap.get(strategy.Id);
                strategyToUpdate.add(str);
            }
    
            update eventToUpdate;
            update strategyToUpdate;
}
    
  }
}