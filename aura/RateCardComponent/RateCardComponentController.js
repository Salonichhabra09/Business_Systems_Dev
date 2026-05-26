({
    calculations: function(component, event, helper) {
        var TotalListPrice=parseFloat(component.get("v.simplerecord.Year_1_Total_List_Price__c"))+parseFloat(component.get("v.simplerecord.Year_2_Total_List_Price__c"))+parseFloat(component.get("v.simplerecord.Year_3_Total_List_Price__c"));
        component.set("v.TotalListPrice",TotalListPrice);
        var TotalDiscountAmount=parseFloat(component.get("v.simplerecord.Year_1_Total_Discount_Amount__c"))+parseFloat(component.get("v.simplerecord.Year_2_Total_Discount_Amount__c"))+parseFloat(component.get("v.simplerecord.Year_3_Total_Discount_Amount__c"));
        component.set("v.TotalDiscountAmount",TotalDiscountAmount);
        var TotalSalesPrice=parseFloat(component.get("v.simplerecord.Year_1_Total_Sales_Price__c"))+parseFloat(component.get("v.simplerecord.Year_2_Total_Sales_Price__c"))+parseFloat(component.get("v.simplerecord.Year_3_Total_Sales_Price__c"));
        component.set("v.TotalSalesPrice",TotalSalesPrice);  
        if(TotalListPrice !=0){
            var AggregateDiscount = ((TotalListPrice - TotalSalesPrice)/TotalListPrice )*100;
        }
        else
            AggregateDiscount =0;
        component.set("v.AggregateDiscount",AggregateDiscount);
    }
})