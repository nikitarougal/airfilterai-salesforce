public with sharing class FilterMatchingService {
    
    public class MatchRequest {
        public Decimal width;
        public Decimal height;
        public Decimal depth;
        public String mervRating;
    }

    public class MatchResult {
        public Boolean found;
        public Id productId;
        public Decimal unitPrice;
        public Integer leadTimeDays;
        public String message;
    }

    public static MatchResult findMatch(MatchRequest request) {
        MatchResult result = new MatchResult();
        result.found = false;

        if (
            request == null ||
            request.width == null ||
            request.height == null ||
            request.depth == null ||
            String.isBlank(request.mervRating)
        ) {
            result.message = 'Missing required filter dimensions or MERV rating.';
            return result;
        }

        List<Filter_Product__c> products = [
            SELECT Id, Unit_Price__c, Lead_Time_Days__c
            FROM Filter_Product__c
            WHERE Active__c = true
            AND Width__c = :request.width
            AND Height__c = :request.height
            AND Depth__c = :request.depth
            AND MERV_Rating__c = :request.mervRating
            LIMIT 1
        ];

        if (!products.isEmpty()) {
            Filter_Product__c product = products[0];
            result.found = true;
            result.productId = product.Id;
            result.unitPrice = product.Unit_Price__c;
            result.leadTimeDays = product.Lead_Time_Days__c == null
                ? null
                : Integer.valueOf(product.Lead_Time_Days__c);
            result.message = 'Matching filter product found.';
        } else {
            result.message = 'No exact product match found. Custom quote required.';
        }

        return result;
    }
}