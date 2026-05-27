public with sharing class AirFilterAIConsoleController {

    public class ProductMatchResponse {
        @AuraEnabled public Boolean found { get; set; }
        @AuraEnabled public Id productId { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public Decimal unitPrice { get; set; }
        @AuraEnabled public Integer leadTimeDays { get; set; }
        @AuraEnabled public String productType { get; set; }
        @AuraEnabled public String message { get; set; }
    }

    public class InquiryRequest {
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String company { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public Decimal width { get; set; }
        @AuraEnabled public Decimal height { get; set; }
        @AuraEnabled public Decimal depth { get; set; }
        @AuraEnabled public String mervRating { get; set; }
        @AuraEnabled public Integer quantity { get; set; }
        @AuraEnabled public String source { get; set; }
        @AuraEnabled public String targetUseCase { get; set; }
        @AuraEnabled public String requestedTimeline { get; set; }
    }

    public class InquiryResponse {
        @AuraEnabled public Id inquiryId { get; set; }
        @AuraEnabled public String inquiryName { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public Decimal estimatedUnitPrice { get; set; }
        @AuraEnabled public Decimal estimatedTotalPrice { get; set; }
        @AuraEnabled public String message { get; set; }
    }

    @AuraEnabled(cacheable=false)
    public static ProductMatchResponse findMatchingProduct(
        Decimal width,
        Decimal height,
        Decimal depth,
        String mervRating
    ) {
        ProductMatchResponse response = new ProductMatchResponse();

        FilterMatchingService.MatchRequest request = new FilterMatchingService.MatchRequest();
        request.width = width;
        request.height = height;
        request.depth = depth;
        request.mervRating = mervRating;

        FilterMatchingService.MatchResult result = FilterMatchingService.findMatch(request);

        response.found = result.found;
        response.productId = result.productId;
        response.unitPrice = result.unitPrice;
        response.leadTimeDays = result.leadTimeDays;
        response.message = result.message;

        if (result.found && result.productId != null) {
            Filter_Product__c product = [
                SELECT Id, Name, Product_Type__c
                FROM Filter_Product__c
                WHERE Id = :result.productId
                LIMIT 1
            ];

            response.productName = product.Name;
            response.productType = product.Product_Type__c;
        }

        return response;
    }

    @AuraEnabled(cacheable=false)
    public static InquiryResponse createInquiry(InquiryRequest request) {
        if (request == null) {
            throw new AuraHandledException('Inquiry request is required.');
        }

        System.debug('Incoming inquiry request: ' + JSON.serialize(request));
        System.debug('Email from LWC: ' + request.email);
        System.debug('Phone from LWC: ' + request.phone);

        Customer_Inquiry__c inquiry = new Customer_Inquiry__c(
            First_Name__c = request.firstName,
            Last_Name__c = request.lastName,
            Company__c = request.company,
            Email__c = request.email,
            Phone__c = request.phone,
            Requested_Width__c = request.width,
            Requested_Height__c = request.height,
            Requested_Depth__c = request.depth,
            Requested_MERV_Rating__c = request.mervRating,
            Quantity__c = request.quantity,
            Source__c = String.isBlank(request.source) ? 'Manual' : request.source,
            Target_Use_Case__c = String.isBlank(request.targetUseCase) ? 'Unknown' : request.targetUseCase,
            Requested_Timeline__c = String.isBlank(request.requestedTimeline) ? 'Unknown' : request.requestedTimeline,
            Status__c = 'New'
        );

        insert inquiry;

        Customer_Inquiry__c processedCheck = [
            SELECT Id, Status__c
            FROM Customer_Inquiry__c
            WHERE Id = :inquiry.Id
            LIMIT 1
        ];

        if (processedCheck.Status__c == 'New') {
            InquiryProcessingService.processInquiry(inquiry.Id);
        }

        Customer_Inquiry__c updatedInquiry = [
            SELECT Id,
                   Name,
                   Status__c,
                   Estimated_Unit_Price__c,
                   Estimated_Total_Price__c
            FROM Customer_Inquiry__c
            WHERE Id = :inquiry.Id
            LIMIT 1
        ];

        InquiryResponse response = new InquiryResponse();
        response.inquiryId = updatedInquiry.Id;
        response.inquiryName = updatedInquiry.Name;
        response.status = updatedInquiry.Status__c;
        response.estimatedUnitPrice = updatedInquiry.Estimated_Unit_Price__c;
        response.estimatedTotalPrice = updatedInquiry.Estimated_Total_Price__c;
        response.message = 'Customer inquiry created and processed successfully.';

        return response;
    }
}