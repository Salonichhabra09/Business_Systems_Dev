public with sharing class OrderCancellationProjectHandler {

    public static void handle(List<Order> newList,
                              Map<Id, Order> oldMap) {

        if (newList == null || newList.isEmpty()) {
            return;
        }

        Set<Id> cancelledOrderIds = new Set<Id>();

        for (Order ord : newList) {

            if (ord == null || ord.Id == null) continue;

            Order oldOrd = oldMap.get(ord.Id);
            if (oldOrd == null) continue;

            if (ord.Status == 'Cancelled' &&
                oldOrd.Status != 'Cancelled') {

                cancelledOrderIds.add(ord.Id);
            }
        }

        if (!cancelledOrderIds.isEmpty()) {
            System.enqueueJob(
                new ProjectRollupRecalculationQueueable(cancelledOrderIds)
            );
        }
    }
}