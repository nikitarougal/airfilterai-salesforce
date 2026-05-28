public with sharing class InquiryConversionService {

    public class ConversionResult {
        public Id accountId;
        public Id contactId;
        public Id opportunityId;
        public String message;
    }

    public static ConversionResult convertInquiry(Id inquiryId) {
        if (inquiryId == null) {
            throw new AuraHandledException('Customer Inquiry Id is required.');
        }

        Customer_Inquiry__c inquiry = [
            SELECT Id,
                   Name,
                   First_Name__c,
                   Last_Name__c,
                   Company__c,
                   Email__c,
                   Phone__c,
                   Status__c,
                   Estimated_Total_Price__c,
                   Lead_Priority__c,
                   Recommended_Next_Step__c,
                   Related_Account__c,
                   Related_Contact__c,
                   Related_Opportunity__c
            FROM Customer_Inquiry__c
            WHERE Id = :inquiryId
            LIMIT 1
        ];

        if (inquiry.Related_Opportunity__c != null) {
            throw new AuraHandledException('This inquiry has already been converted.');
        }

        Account account = findOrCreateAccount(inquiry);
        Contact contact = findOrCreateContact(inquiry, account.Id);
        Opportunity opportunity = createOpportunity(inquiry, account.Id);

        inquiry.Related_Account__c = account.Id;
        inquiry.Related_Contact__c = contact.Id;
        inquiry.Related_Opportunity__c = opportunity.Id;
        inquiry.Status__c = 'Converted';
        inquiry.Converted_Date__c = Date.today();
        inquiry.Conversion_Notes__c = 'Converted into Account, Contact, and Opportunity.';

        update inquiry;

        ConversionResult result = new ConversionResult();
        result.accountId = account.Id;
        result.contactId = contact.Id;
        result.opportunityId = opportunity.Id;
        result.message = 'Customer inquiry converted successfully.';

        return result;
    }

    private static Account findOrCreateAccount(Customer_Inquiry__c inquiry) {
        String accountName = String.isBlank(inquiry.Company__c)
            ? inquiry.First_Name__c + ' ' + inquiry.Last_Name__c
            : inquiry.Company__c;

        List<Account> accounts = [
            SELECT Id, Name
            FROM Account
            WHERE Name = :accountName
            LIMIT 1
        ];

        if (!accounts.isEmpty()) {
            return accounts[0];
        }

        Account account = new Account(
            Name = accountName,
            Phone = inquiry.Phone__c
        );

        insert account;
        return account;
    }

    private static Contact findOrCreateContact(Customer_Inquiry__c inquiry, Id accountId) {
        if (!String.isBlank(inquiry.Email__c)) {
            List<Contact> contacts = [
                SELECT Id, Email, AccountId
                FROM Contact
                WHERE Email = :inquiry.Email__c
                LIMIT 1
            ];

            if (!contacts.isEmpty()) {
                Contact existingContact = contacts[0];

                if (existingContact.AccountId == null) {
                    existingContact.AccountId = accountId;
                    update existingContact;
                }

                return existingContact;
            }
        }

        Contact contact = new Contact(
            FirstName = inquiry.First_Name__c,
            LastName = String.isBlank(inquiry.Last_Name__c) ? 'Unknown' : inquiry.Last_Name__c,
            Email = inquiry.Email__c,
            Phone = inquiry.Phone__c,
            AccountId = accountId
        );

        insert contact;
        return contact;
    }

    private static Opportunity createOpportunity(Customer_Inquiry__c inquiry, Id accountId) {
        Decimal amount = inquiry.Estimated_Total_Price__c == null
            ? 0
            : inquiry.Estimated_Total_Price__c;

        Opportunity opportunity = new Opportunity(
            Name = 'Air Filter Opportunity - ' + inquiry.Name,
            AccountId = accountId,
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(14),
            Amount = amount
        );

        insert opportunity;
        return opportunity;
    }
}