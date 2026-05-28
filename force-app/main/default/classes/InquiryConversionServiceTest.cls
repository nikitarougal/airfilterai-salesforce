@IsTest
public class InquiryConversionServiceTest {

    @IsTest
    static void convertInquiry_shouldCreateAccountContactAndOpportunity() {
        TestDataFactory.createFilterProduct(true);
        TestDataFactory.createPricingRule(true);
        Customer_Inquiry__c inquiry = TestDataFactory.createCustomerInquiry(true);

        InquiryProcessingService.processInquiry(inquiry.Id);

        Test.startTest();
        InquiryConversionService.ConversionResult result =
            InquiryConversionService.convertInquiry(inquiry.Id);
        Test.stopTest();

        System.assertNotEquals(null, result.accountId);
        System.assertNotEquals(null, result.contactId);
        System.assertNotEquals(null, result.opportunityId);

        Customer_Inquiry__c convertedInquiry = [
            SELECT Id,
                   Status__c,
                   Related_Account__c,
                   Related_Contact__c,
                   Related_Opportunity__c,
                   Converted_Date__c
            FROM Customer_Inquiry__c
            WHERE Id = :inquiry.Id
            LIMIT 1
        ];

        System.assertEquals('Converted', convertedInquiry.Status__c);
        System.assertEquals(result.accountId, convertedInquiry.Related_Account__c);
        System.assertEquals(result.contactId, convertedInquiry.Related_Contact__c);
        System.assertEquals(result.opportunityId, convertedInquiry.Related_Opportunity__c);
        System.assertEquals(Date.today(), convertedInquiry.Converted_Date__c);
    }

    @IsTest
    static void convertInquiry_shouldPreventDuplicateConversion() {
        TestDataFactory.createFilterProduct(true);
        TestDataFactory.createPricingRule(true);
        Customer_Inquiry__c inquiry = TestDataFactory.createCustomerInquiry(true);

        InquiryProcessingService.processInquiry(inquiry.Id);
        InquiryConversionService.convertInquiry(inquiry.Id);

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            InquiryConversionService.convertInquiry(inquiry.Id);
        } catch (Exception ex) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }
}