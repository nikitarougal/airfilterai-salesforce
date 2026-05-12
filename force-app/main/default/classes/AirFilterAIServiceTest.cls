@IsTest
public class AirFilterAIServiceTest {

    @IsTest
    static void findMatch_shouldReturnProduct_whenExactMatchExists() {
        Filter_Product__c product = TestDataFactory.createFilterProduct(true);

        FilterMatchingService.MatchRequest request = new FilterMatchingService.MatchRequest();
        request.width = 16;
        request.height = 20;
        request.depth = 1;
        request.mervRating = '8';

        Test.startTest();
        FilterMatchingService.MatchResult result = FilterMatchingService.findMatch(request);
        Test.stopTest();

        System.assertEquals(true, result.found);
        System.assertEquals(product.Id, result.productId);
        System.assertEquals(12.99, result.unitPrice);
    }

    @IsTest
    static void findMatch_shouldReturnNotFound_whenNoProductExists() {
        FilterMatchingService.MatchRequest request = new FilterMatchingService.MatchRequest();
        request.width = 18;
        request.height = 22;
        request.depth = 1;
        request.mervRating = '13';

        Test.startTest();
        FilterMatchingService.MatchResult result = FilterMatchingService.findMatch(request);
        Test.stopTest();

        System.assertEquals(false, result.found);
        System.assertEquals(null, result.productId);
    }

    @IsTest
    static void calculatePrice_shouldApplyBulkDiscount() {
        TestDataFactory.createPricingRule(true);

        PricingCalculationService.PricingRequest request =
            new PricingCalculationService.PricingRequest();

        request.unitPrice = 10;
        request.quantity = 10;
        request.productType = 'Pleated';
        request.isCustomSize = false;

        Test.startTest();
        PricingCalculationService.PricingResult result =
            PricingCalculationService.calculatePrice(request);
        Test.stopTest();

        System.assertEquals(5, result.discountPercent);
        System.assertEquals(95, result.estimatedTotalPrice);
    }

    @IsTest
    static void processInquiry_shouldUpdateInquiryAsMatched() {
        Filter_Product__c product = TestDataFactory.createFilterProduct(true);
        TestDataFactory.createPricingRule(true);
        Customer_Inquiry__c inquiry = TestDataFactory.createCustomerInquiry(true);

        Test.startTest();
        InquiryProcessingService.processInquiry(inquiry.Id);
        Test.stopTest();

        Customer_Inquiry__c updatedInquiry = [
            SELECT Id,
                   Status__c,
                   Matched_Product__c,
                   Estimated_Unit_Price__c,
                   Estimated_Total_Price__c,
                   Lead_Time_Days__c
            FROM Customer_Inquiry__c
            WHERE Id = :inquiry.Id
            LIMIT 1
        ];

        System.assertEquals('Matched', updatedInquiry.Status__c);
        System.assertEquals(product.Id, updatedInquiry.Matched_Product__c);
        System.assertEquals(12.99, updatedInquiry.Estimated_Unit_Price__c);
        System.assertEquals(123.405, updatedInquiry.Estimated_Total_Price__c);
        System.assertEquals(3, updatedInquiry.Lead_Time_Days__c);
    }

    @IsTest
static void calculatePrice_shouldReturnMessage_whenInputInvalid() {
    Test.startTest();
    PricingCalculationService.PricingResult result =
        PricingCalculationService.calculatePrice(null);
    Test.stopTest();

    System.assertEquals('Missing or invalid pricing input.', result.message);
}

@IsTest
static void calculatePrice_shouldApplyCustomSizeFee() {
    TestDataFactory.createPricingRule(true);

    PricingCalculationService.PricingRequest request =
        new PricingCalculationService.PricingRequest();

    request.unitPrice = 10;
    request.quantity = 1;
    request.productType = 'Pleated';
    request.isCustomSize = true;

    Test.startTest();
    PricingCalculationService.PricingResult result =
        PricingCalculationService.calculatePrice(request);
    Test.stopTest();

    System.assertEquals(25, result.customSizeFee);
    System.assertEquals(35, result.estimatedTotalPrice);
}
}