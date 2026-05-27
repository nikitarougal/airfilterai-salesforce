public with sharing class InquiryProcessingService {
    
    public static void processInquiry(Id inquiryId) {
        if (inquiryId == null) {
            throw new AuraHandledException('Inquiry Id is required.');
        }
        
        Customer_Inquiry__c inquiry = [
            SELECT Id,
                First_Name__c,
                Last_Name__c,
                Company__c,
                Email__c,
                Phone__c,
                Requested_Width__c,
                Requested_Height__c,
                Requested_Depth__c,
                Requested_MERV_Rating__c,
                Quantity__c,
                Status__c,
                Matched_Product__c,
                Target_Use_Case__c,
                Requested_Timeline__c
            FROM Customer_Inquiry__c
            WHERE Id = :inquiryId
            LIMIT 1
        ];
        
        FilterMatchingService.MatchRequest matchRequest = new FilterMatchingService.MatchRequest();
        matchRequest.width = inquiry.Requested_Width__c;
        matchRequest.height = inquiry.Requested_Height__c;
        matchRequest.depth = inquiry.Requested_Depth__c;
        matchRequest.mervRating = inquiry.Requested_MERV_Rating__c;
        
        FilterMatchingService.MatchResult matchResult = FilterMatchingService.findMatch(matchRequest);
        
        if (matchResult.found) {
            PricingCalculationService.PricingRequest pricingRequest =
                new PricingCalculationService.PricingRequest();
            
            pricingRequest.unitPrice = matchResult.unitPrice;
            pricingRequest.quantity = inquiry.Quantity__c == null
                ? 0
                : Integer.valueOf(inquiry.Quantity__c);
            pricingRequest.productType = 'Pleated';
            pricingRequest.isCustomSize = false;
            
            PricingCalculationService.PricingResult pricingResult =
                PricingCalculationService.calculatePrice(pricingRequest);
            
            inquiry.Matched_Product__c = matchResult.productId;
            inquiry.Estimated_Unit_Price__c = pricingResult.estimatedUnitPrice;
            inquiry.Estimated_Total_Price__c = pricingResult.estimatedTotalPrice;
            inquiry.Lead_Time_Days__c = matchResult.leadTimeDays;
            inquiry.Status__c = 'Matched';
        } else {
            inquiry.Status__c = 'Custom Required';
            inquiry.Matched_Product__c = null;
        }
        
        LeadQualificationService.QualificationResult qualification =
            LeadQualificationService.qualify(inquiry);
        
        inquiry.Lead_Score__c = qualification.score;
        inquiry.Lead_Priority__c = qualification.priority;
        inquiry.Follow_Up_Required__c = qualification.followUpRequired;
        inquiry.Recommended_Next_Step__c = qualification.recommendedNextStep;
        inquiry.Qualification_Notes__c = qualification.notes;
        
        update inquiry;
    }
}