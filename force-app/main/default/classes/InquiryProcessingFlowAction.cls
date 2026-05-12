public with sharing class InquiryProcessingFlowAction {

    public class Request {
        @InvocableVariable(required=true)
        public Id inquiryId;
    }

    public class Response {
        @InvocableVariable
        public Id inquiryId;

        @InvocableVariable
        public String status;

        @InvocableVariable
        public String message;
    }

    @InvocableMethod(
        label='Process Customer Inquiry'
        description='Finds a matching filter product, calculates pricing, and updates the customer inquiry.'
    )
    public static List<Response> processCustomerInquiries(List<Request> requests) {
        List<Response> responses = new List<Response>();

        if (requests == null || requests.isEmpty()) {
            return responses;
        }

        for (Request request : requests) {
            Response response = new Response();
            response.inquiryId = request.inquiryId;

            try {
                if (request.inquiryId == null) {
                    response.status = 'Error';
                    response.message = 'Inquiry Id is missing.';
                } else {
                    InquiryProcessingService.processInquiry(request.inquiryId);

                    Customer_Inquiry__c updatedInquiry = [
                        SELECT Id, Status__c
                        FROM Customer_Inquiry__c
                        WHERE Id = :request.inquiryId
                        LIMIT 1
                    ];

                    response.status = updatedInquiry.Status__c;
                    response.message = 'Inquiry processed successfully.';
                }
            } catch (Exception ex) {
                response.status = 'Error';
                response.message = ex.getMessage();
            }

            responses.add(response);
        }

        return responses;
    }
}