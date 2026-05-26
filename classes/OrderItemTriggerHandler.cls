public class OrderItemTriggerHandler {
    //Version where BOF filter does not applies to TC

    // ─────────────────────────────────────────────────────────────────────────
    // Allowed Basis of Fee values — applies to Field 2 ONLY
    // ─────────────────────────────────────────────────────────────────────────
    private static final Set<String> ALLOWED_BASIS_OF_FEE = new Set<String>{
        'Candidates',
        'Units',
        'Participants'
    };

    public static void handleOrderItems(List<OrderItem> items, Map<Id, OrderItem> oldMap) {

        Set<Id> orderIdsToProcess = getRelevantOrderIds(items, oldMap);

        if (orderIdsToProcess.isEmpty()) return;

        Map<Id, List<OrderItem>> allItemsMap      = fetchAllOrderItems(orderIdsToProcess);
        Map<Id, List<OrderItem>> filteredItemsMap = filterByBasisOfFee(allItemsMap);

        List<Order> ordersToUpdate = buildOrderRecords(orderIdsToProcess, allItemsMap, filteredItemsMap);

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // STEP 1 : Identify which Orders need reprocessing
    // ─────────────────────────────────────────────────────────────────────────
    private static Set<Id> getRelevantOrderIds(List<OrderItem> items, Map<Id, OrderItem> oldMap) {

        Set<Id> orderIds = new Set<Id>();

        for (OrderItem oi : items) {

            if (oldMap == null) {
                // Insert / Delete / Undelete — always process
                orderIds.add(oi.OrderId);

            } else {
                // Update — only process if a relevant field changed
                OrderItem oldOi = oldMap.get(oi.Id);

                if (oldOi != null) {
                    Boolean relevantFieldChanged =
                        oi.Package__c           !=oldOi.Package__c          ||
                        oi.Solution_Cap__c      != oldOi.Solution_Cap__c    ||
                        oi.Basis_of_Fees__c     != oldOi.Basis_of_Fees__c   ||
                        oi.Usage_Allowance__c   != oldOi.Usage_Allowance__c;

                    if (relevantFieldChanged) {
                        orderIds.add(oi.OrderId);
                    }
                }
            }
        }

        return orderIds;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // STEP 2A : Fetch ALL Order Items for affected Orders (used for Field 1)
    // ─────────────────────────────────────────────────────────────────────────
    private static Map<Id, List<OrderItem>> fetchAllOrderItems(Set<Id> orderIds) {

        Map<Id, List<OrderItem>> orderToItemsMap = new Map<Id, List<OrderItem>>();

        for (Id orderId : orderIds) {
            orderToItemsMap.put(orderId, new List<OrderItem>());
        }

        for (OrderItem oi : [
            SELECT Id,
                   OrderId,
                   Package__c,
                   Solution_Cap__c,
                   Basis_of_Fees__c,
                   Usage_Allowance__c
            FROM   OrderItem
            WHERE  OrderId IN :orderIds
        ]) {
            orderToItemsMap.get(oi.OrderId).add(oi);
        }

        return orderToItemsMap;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // STEP 2B : From the same queried data, filter by Basis of Fee (Field 2)
    //           No additional SOQL — reuses the already-fetched records
    // ─────────────────────────────────────────────────────────────────────────
    private static Map<Id, List<OrderItem>> filterByBasisOfFee(
        Map<Id, List<OrderItem>> allItemsMap
    ) {
        Map<Id, List<OrderItem>> filteredMap = new Map<Id, List<OrderItem>>();

        for (Id orderId : allItemsMap.keySet()) {
            filteredMap.put(orderId, new List<OrderItem>());

            for (OrderItem oi : allItemsMap.get(orderId)) {
                if (ALLOWED_BASIS_OF_FEE.contains(oi.Basis_of_Fees__c)) {
                    filteredMap.get(orderId).add(oi);
                }
            }
        }

        return filteredMap;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // STEP 3 : Build Order records
    //          Field 1 → allItemsMap (no BOF filter)
    //          Field 2 → filteredItemsMap (BOF filter applied)
    // ─────────────────────────────────────────────────────────────────────────
    private static List<Order> buildOrderRecords(
        Set<Id> orderIds,
        Map<Id, List<OrderItem>> allItemsMap,
        Map<Id, List<OrderItem>> filteredItemsMap
    ) {
        List<Order> ordersToUpdate = new List<Order>();

        for (Id orderId : orderIds) {
            List<OrderItem> allItems      = allItemsMap.get(orderId);
            List<OrderItem> filteredItems = filteredItemsMap.get(orderId);

            ordersToUpdate.add(new Order(
                Id                               = orderId,
                Offering_with_Solution_Cap__c    = buildOfferingWithSolutionCap(allItems),      // All items
                Offering_SolCap_BF_UsageAll__c = buildOfferingFullCombined(filteredItems)     // BOF-filtered items
            ));
        }

        return ordersToUpdate;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FIELD 1 : "Offering with Solution Cap" — NO BOF filter
    // Format  : <Offering> - <SolutionCap>, ...
    // ─────────────────────────────────────────────────────────────────────────
    private static String buildOfferingWithSolutionCap(List<OrderItem> items) {

        Set<String> seen   = new Set<String>();
        List<String> parts = new List<String>();

        for (OrderItem oi : items) {
            String offering = String.isBlank(oi.Package__c)
                              ? 'NA' : oi.Package__c;

            String cap      = (oi.Solution_Cap__c == null)
                              ? '0' : String.valueOf(oi.Solution_Cap__c.intValue());

            String combo    = offering + ' - ' + cap;

            if (!seen.contains(combo)) {
                seen.add(combo);
                parts.add(combo);
            }
        }

        return parts.isEmpty() ? '' : String.join(parts, ', ');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FIELD 2 : "Offering-Sol Cap-BF-Usage All (for TC+)" — BOF filter applied
    // Format  : <Offering> – <SolutionCap> – <BasisOfFee> – <UsageAllowance>, ...
    // ─────────────────────────────────────────────────────────────────────────
    private static String buildOfferingFullCombined(List<OrderItem> items) {

        Set<String> seen   = new Set<String>();
        List<String> parts = new List<String>();

        for (OrderItem oi : items) {
            String offering = String.isBlank(oi.Package__c)
                              ? 'NA' : oi.Package__c;

            String cap      = (oi.Solution_Cap__c == null)
                              ? '0' : String.valueOf(oi.Solution_Cap__c.intValue());

            String bof      = String.isBlank(oi.Basis_of_Fees__c)
                              ? 'NA' : oi.Basis_of_Fees__c;

            String usage    = String.isBlank(oi.Usage_Allowance__c)
                              ? 'NA' : oi.Usage_Allowance__c;

            String combo    = offering + ' - ' + cap +
                              ' - ' + bof  +
                              ' - ' + usage;

            if (!seen.contains(combo)) {
                seen.add(combo);
                parts.add(combo);
            }
        }

        return parts.isEmpty() ? '' : String.join(parts, ', ');
    }
}