public with sharing class LeadQualificationService {

    public class QualificationResult {
        public Integer score;
        public String priority;
        public Boolean followUpRequired;
        public String recommendedNextStep;
        public String notes;
    }

    public static QualificationResult qualify(Customer_Inquiry__c inquiry) {
        QualificationResult result = new QualificationResult();
        result.score = 0;
        List<String> notes = new List<String>();

        if (inquiry == null) {
            result.priority = 'Low';
            result.followUpRequired = false;
            result.recommendedNextStep = 'Request More Info';
            result.notes = 'Inquiry data was missing.';
            return result;
        }

        if (inquiry.Quantity__c != null && inquiry.Quantity__c >= 50) {
            result.score += 30;
            notes.add('Large quantity request.');
        } else if (inquiry.Quantity__c != null && inquiry.Quantity__c >= 10) {
            result.score += 15;
            notes.add('Medium quantity request.');
        }

        if (!String.isBlank(inquiry.Company__c)) {
            result.score += 20;
            notes.add('Company provided.');
        }

        if (
            inquiry.Target_Use_Case__c == 'Commercial' ||
            inquiry.Target_Use_Case__c == 'Industrial' ||
            inquiry.Target_Use_Case__c == 'HVAC Contractor'
        ) {
            result.score += 20;
            notes.add('Business-related use case.');
        }

        if (
            inquiry.Requested_Timeline__c == 'ASAP' ||
            inquiry.Requested_Timeline__c == 'This Week'
        ) {
            result.score += 15;
            notes.add('Urgent requested timeline.');
        }

        if (inquiry.Matched_Product__c != null) {
            result.score += 10;
            notes.add('Standard product match found.');
        }

        if (!String.isBlank(inquiry.Email__c) && !String.isBlank(inquiry.Phone__c)) {
            result.score += 10;
            notes.add('Both email and phone provided.');
        }

        if (result.score >= 70) {
            result.priority = 'High';
        } else if (result.score >= 40) {
            result.priority = 'Medium';
        } else {
            result.priority = 'Low';
        }

        result.followUpRequired = result.score >= 40;

        if (result.priority == 'High' && inquiry.Status__c == 'Matched') {
            result.recommendedNextStep = 'Send Quote';
        } else if (result.priority == 'High' && inquiry.Status__c == 'Custom Required') {
            result.recommendedNextStep = 'Call Customer';
        } else if (result.priority == 'Medium') {
            result.recommendedNextStep = 'Request More Info';
        } else {
            result.recommendedNextStep = 'Follow Up Later';
        }

        result.notes = String.join(notes, ' ');

        return result;
    }
}