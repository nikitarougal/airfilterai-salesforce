@IsTest
public class TestDataFactory {

    public static Filter_Product__c createFilterProduct(Boolean doInsert) {
        Filter_Product__c product = new Filter_Product__c(
            Name = 'AF-16x20x1-M8',
            Product_Code__c = 'AF-16x20x1-M8',
            Width__c = 16,
            Height__c = 20,
            Depth__c = 1,
            MERV_Rating__c = '8',
            Product_Type__c = 'Pleated',
            Unit_Price__c = 12.99,
            Lead_Time_Days__c = 3,
            Active__c = true
        );

        if (doInsert) {
            insert product;
        }

        return product;
    }

    public static Pricing_Rule__c createPricingRule(Boolean doInsert) {
        Pricing_Rule__c rule = new Pricing_Rule__c(
            Name = 'Pleated Bulk 10',
            Product_Type__c = 'Pleated',
            Minimum_Quantity__c = 10,
            Discount_Percent__c = 5,
            Custom_Size_Fee__c = 25,
            Active__c = true
        );

        if (doInsert) {
            insert rule;
        }

        return rule;
    }

    public static Customer_Inquiry__c createCustomerInquiry(Boolean doInsert) {
    Customer_Inquiry__c inquiry = new Customer_Inquiry__c(
        First_Name__c = 'John',
        Last_Name__c = 'Smith',
        Company__c = 'Smith HVAC',
        Email__c = 'john.smith@example.com',
        Phone__c = '+1 416 555 0199',
        Requested_Width__c = 16,
        Requested_Height__c = 20,
        Requested_Depth__c = 1,
        Requested_MERV_Rating__c = '8',
        Quantity__c = 10,
        Source__c = 'Manual',
        Status__c = 'New',
        Target_Use_Case__c = 'Commercial',
        Requested_Timeline__c = 'ASAP'
    );

    if (doInsert) {
        insert inquiry;
    }

    return inquiry;
}
}