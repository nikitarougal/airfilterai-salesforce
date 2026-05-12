@IsTest
public class InquiryProcessingFlowActionTest {

    @IsTest
    static void processCustomerInquiries_shouldProcessInquiry() {
        Filter_Product__c product = TestDataFactory.createFilterProduct(true);
        TestDataFactory.createPricingRule(true);
        Customer_Inquiry__c inquiry = TestDataFactory.createCustomerInquiry(true);

        InquiryProcessingFlowAction.Request request =
            new InquiryProcessingFlowAction.Request();

        request.inquiryId = inquiry.Id;

        List<InquiryProcessingFlowAction.Request> requests =
            new List<InquiryProcessingFlowAction.Request>{ request };

        Test.startTest();
        List<InquiryProcessingFlowAction.Response> responses =
            InquiryProcessingFlowAction.processCustomerInquiries(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals(inquiry.Id, responses[0].inquiryId);
        System.assertEquals('Matched', responses[0].status);

        Customer_Inquiry__c updatedInquiry = [
            SELECT Id,
                   Status__c,
                   Matched_Product__c,
                   Estimated_Unit_Price__c,
                   Estimated_Total_Price__c
            FROM Customer_Inquiry__c
            WHERE Id = :inquiry.Id
            LIMIT 1
        ];

        System.assertEquals('Matched', updatedInquiry.Status__c);
        System.assertEquals(product.Id, updatedInquiry.Matched_Product__c);
        System.assertEquals(12.99, updatedInquiry.Estimated_Unit_Price__c);
        System.assert(updatedInquiry.Estimated_Total_Price__c > 0);
    }

    @IsTest
static void processCustomerInquiries_shouldReturnError_whenInquiryIdMissing() {
    InquiryProcessingFlowAction.Request request =
        new InquiryProcessingFlowAction.Request();

    request.inquiryId = null;

    Test.startTest();
    List<InquiryProcessingFlowAction.Response> responses =
        InquiryProcessingFlowAction.processCustomerInquiries(
            new List<InquiryProcessingFlowAction.Request>{ request }
        );
    Test.stopTest();

    System.assertEquals(1, responses.size());
    System.assertEquals('Error', responses[0].status);
    System.assertEquals('Inquiry Id is missing.', responses[0].message);
}
}