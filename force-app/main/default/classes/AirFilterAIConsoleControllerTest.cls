@IsTest
public class AirFilterAIConsoleControllerTest {

    @IsTest
    static void findMatchingProduct_shouldReturnMatch() {
        Filter_Product__c product = TestDataFactory.createFilterProduct(true);

        Test.startTest();
        AirFilterAIConsoleController.ProductMatchResponse response =
            AirFilterAIConsoleController.findMatchingProduct(16, 20, 1, '8');
        Test.stopTest();

        System.assertEquals(true, response.found);
        System.assertEquals(product.Id, response.productId);
        System.assertEquals('AF-16x20x1-M8', response.productName);
        System.assertEquals('Pleated', response.productType);
        System.assertEquals(12.99, response.unitPrice);
    }

    @IsTest
    static void findMatchingProduct_shouldReturnNoMatch() {
        Test.startTest();
        AirFilterAIConsoleController.ProductMatchResponse response =
            AirFilterAIConsoleController.findMatchingProduct(99, 99, 1, '13');
        Test.stopTest();

        System.assertEquals(false, response.found);
        System.assertEquals(null, response.productId);
    }

    @IsTest
    static void createInquiry_shouldCreateAndReturnInquiry() {
        TestDataFactory.createFilterProduct(true);
        TestDataFactory.createPricingRule(true);

        AirFilterAIConsoleController.InquiryRequest request =
            new AirFilterAIConsoleController.InquiryRequest();

        request.firstName = 'Console';
        request.lastName = 'Test';
        request.company = 'Console Test Company';
        request.email = 'console.test@example.com';
        request.phone = '4165550199';
        request.width = 16;
        request.height = 20;
        request.depth = 1;
        request.mervRating = '8';
        request.quantity = 10;
        request.source = 'Manual';

        Test.startTest();
        AirFilterAIConsoleController.InquiryResponse response =
            AirFilterAIConsoleController.createInquiry(request);
        Test.stopTest();

        System.assertNotEquals(null, response.inquiryId);
        System.assertNotEquals(null, response.inquiryName);
        System.assertEquals('Matched', response.status);
        System.assertEquals(12.99, response.estimatedUnitPrice);
        System.assert(response.estimatedTotalPrice > 0);

        Customer_Inquiry__c createdInquiry = [
            SELECT Id, First_Name__c, Last_Name__c, Email__c, Phone__c, Status__c
            FROM Customer_Inquiry__c
            WHERE Id = :response.inquiryId
            LIMIT 1
        ];

        System.assertEquals('Console', createdInquiry.First_Name__c);
        System.assertEquals('Test', createdInquiry.Last_Name__c);
        System.assertEquals('console.test@example.com', createdInquiry.Email__c);
        System.assertEquals('4165550199', createdInquiry.Phone__c);
        System.assertEquals('Matched', createdInquiry.Status__c);
    }

    @IsTest
    static void createInquiry_shouldThrowException_whenRequestIsNull() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            AirFilterAIConsoleController.createInquiry(null);
        } catch (Exception ex) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }
}