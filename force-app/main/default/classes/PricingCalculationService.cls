public with sharing class PricingCalculationService {

    public class PricingRequest {
        public Decimal unitPrice;
        public Integer quantity;
        public String productType;
        public Boolean isCustomSize;
    }

    public class PricingResult {
        public Decimal estimatedUnitPrice;
        public Decimal estimatedTotalPrice;
        public Decimal discountPercent;
        public Decimal customSizeFee;
        public String message;
    }

    public static PricingResult calculatePrice(PricingRequest request) {
        PricingResult result = new PricingResult();
        result.discountPercent = 0;
        result.customSizeFee = 0;

        if (request == null || request.unitPrice == null || request.quantity == null || request.quantity <= 0) {
            result.message = 'Missing or invalid pricing input.';
            return result;
        }

        Decimal discountPercent = findBestDiscount(request.productType, request.quantity);
        Decimal subtotal = request.unitPrice * request.quantity;
        Decimal discountAmount = subtotal * (discountPercent / 100);

        Decimal customFee = request.isCustomSize == true
            ? findCustomSizeFee(request.productType)
            : 0;

        result.estimatedUnitPrice = request.unitPrice;
        result.discountPercent = discountPercent;
        result.customSizeFee = customFee;
        result.estimatedTotalPrice = subtotal - discountAmount + customFee;
        result.message = 'Price calculated successfully.';

        return result;
    }

    private static Decimal findBestDiscount(String productType, Integer quantity) {
        if (String.isBlank(productType)) {
            return 0;
        }

        List<Pricing_Rule__c> rules = [
            SELECT Discount_Percent__c
            FROM Pricing_Rule__c
            WHERE Active__c = true
            AND Product_Type__c = :productType
            AND Minimum_Quantity__c <= :quantity
            ORDER BY Minimum_Quantity__c DESC
            LIMIT 1
        ];

        if (rules.isEmpty() || rules[0].Discount_Percent__c == null) {
            return 0;
        }

        return rules[0].Discount_Percent__c;
    }

    private static Decimal findCustomSizeFee(String productType) {
        if (String.isBlank(productType)) {
            return 0;
        }

        List<Pricing_Rule__c> rules = [
            SELECT Custom_Size_Fee__c
            FROM Pricing_Rule__c
            WHERE Active__c = true
            AND Product_Type__c = :productType
            AND Custom_Size_Fee__c != null
            ORDER BY Minimum_Quantity__c ASC
            LIMIT 1
        ];

        if (rules.isEmpty()) {
            return 0;
        }

        return rules[0].Custom_Size_Fee__c == null ? 0 : rules[0].Custom_Size_Fee__c;
    }
}