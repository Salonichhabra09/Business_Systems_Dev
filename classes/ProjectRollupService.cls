public with sharing class ProjectRollupService {

    public static void recalculate(Set<Id> projectIds) {

        if (projectIds == null || projectIds.isEmpty()) {
            return;
        }

        // Fetch only OPEN projects
        List<ProjectObject__c> projects = [
            SELECT Id,
                   Order_Products_Count__c,
                   Scoped_CPS_days_RollUp__c,
                   Scoped_LPS_days_RollUp__c,
                   Total_Orderline_Value_RollUp__c,
                   CPS_scoped_value__c,
                   LPS_scoped_value__c
            FROM ProjectObject__c
            WHERE Id IN :projectIds
            AND Project_Status__c NOT IN ('Completed', 'Cancelled')
        ];

        if (projects.isEmpty()) {
            return;
        }

        // Map for quick lookup
        Map<Id, ProjectObject__c> projectMap = new Map<Id, ProjectObject__c>(projects);

        // Reset all values to zero first
        for (ProjectObject__c p : projects) {
            p.Order_Products_Count__c = 0;
            p.Scoped_CPS_days_RollUp__c = 0;
            p.Scoped_LPS_days_RollUp__c = 0;
            p.CPS_scoped_value__c = 0;
            p.LPS_scoped_value__c = 0;
            p.Total_Orderline_Value_RollUp__c = 0;
        }

        // Query ALL valid OrderItems for those projects
        List<OrderItem> orderItems = [
            SELECT Id,
                   Project__c,
                   TotalPrice,
                   Quantity,
                   Basis_of_Fees__c
            FROM OrderItem
            WHERE Project__c IN :projectMap.keySet()
            AND Order.Status != 'Cancelled'
        ];

        // Apply EXACT same logic as VF controller
        for (OrderItem oi : orderItems) {

            ProjectObject__c p = projectMap.get(oi.Project__c);
            if (p == null) continue;

            // Count
            p.Order_Products_Count__c++;

            // Total value
            if (oi.TotalPrice != null) {
                p.Total_Orderline_Value_RollUp__c += oi.TotalPrice;
            }

            // CPS
            if (oi.Basis_of_Fees__c == 'CPS Days') {
                if (oi.Quantity != null)
                    p.Scoped_CPS_days_RollUp__c += oi.Quantity;

                if (oi.TotalPrice != null)
                    p.CPS_scoped_value__c += oi.TotalPrice;
            }

            // LPS
            if (oi.Basis_of_Fees__c == 'LPS Days') {
                if (oi.Quantity != null)
                    p.Scoped_LPS_days_RollUp__c += oi.Quantity;

                if (oi.TotalPrice != null)
                    p.LPS_scoped_value__c += oi.TotalPrice;
            }
        }

        update projects;
    }
}