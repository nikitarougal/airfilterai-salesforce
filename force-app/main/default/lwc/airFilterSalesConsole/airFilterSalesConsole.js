import { LightningElement } from 'lwc';
import findMatchingProduct from '@salesforce/apex/AirFilterAIConsoleController.findMatchingProduct';
import createInquiry from '@salesforce/apex/AirFilterAIConsoleController.createInquiry';
import convertInquiry from '@salesforce/apex/AirFilterAIConsoleController.convertInquiry';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AirFilterSalesConsole extends LightningElement {
    width;
    height;
    depth;
    mervRating = '8';
    quantity = 1;

    firstName;
    lastName;
    company;
    email;
    phone;

    matchResult;
    createdInquiry;
    isLoading = false;

    targetUseCase = 'Unknown';
    requestedTimeline = 'Unknown';

    conversionResult;

    get mervOptions() {
        return [
            { label: '8', value: '8' },
            { label: '11', value: '11' },
            { label: '13', value: '13' },
            { label: '16', value: '16' }
        ];
    }

    get matchStatusLabel() {
        if (!this.matchResult) {
            return '';
        }

        return this.matchResult.found ? 'Matched' : 'Custom Required';
    }

    get targetUseCaseOptions() {
        return [
            { label: 'Residential', value: 'Residential' },
            { label: 'Commercial', value: 'Commercial' },
            { label: 'Industrial', value: 'Industrial' },
            { label: 'HVAC Contractor', value: 'HVAC Contractor' },
            { label: 'Unknown', value: 'Unknown' }
        ];
    }

    get requestedTimelineOptions() {
        return [
            { label: 'ASAP', value: 'ASAP' },
            { label: 'This Week', value: 'This Week' },
            { label: 'This Month', value: 'This Month' },
            { label: 'Flexible', value: 'Flexible' },
            { label: 'Unknown', value: 'Unknown' }
        ];
    }

    handleInputChange(event) {
        const fieldName = event.target.name;
        this[fieldName] = event.target.value;
    }

    async handleFindProduct() {
        if (!this.validateFilterFields()) {
            return;
        }

        this.isLoading = true;
        this.matchResult = null;
        this.createdInquiry = null;

        try {
            this.matchResult = await findMatchingProduct({
                width: Number(this.width),
                height: Number(this.height),
                depth: Number(this.depth),
                mervRating: this.mervRating
            });

            this.showToast(
                this.matchResult.found ? 'Product found' : 'No exact match',
                this.matchResult.message,
                this.matchResult.found ? 'success' : 'warning'
            );
        } catch (error) {
            this.showToast('Error finding product', this.getErrorMessage(error), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async handleCreateInquiry() {
        if (!this.validateInquiryFields()) {
            return;
        }

        this.isLoading = true;
        this.createdInquiry = null;

        const request = {
            firstName: this.firstName,
            lastName: this.lastName,
            company: this.company,
            email: this.email,
            phone: this.phone,
            width: Number(this.width),
            height: Number(this.height),
            depth: Number(this.depth),
            mervRating: this.mervRating,
            quantity: Number(this.quantity),
            source: 'Manual',
            targetUseCase: this.targetUseCase,
            requestedTimeline: this.requestedTimeline
        };

        try {
            this.createdInquiry = await createInquiry({ request });

            this.showToast(
                'Inquiry created',
                `${this.createdInquiry.inquiryName} was created successfully.`,
                'success'
            );
        } catch (error) {
            this.showToast('Error creating inquiry', this.getErrorMessage(error), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    validateFilterFields() {
        if (!this.width || !this.height || !this.depth || !this.mervRating) {
            this.showToast(
                'Missing filter details',
                'Please enter width, height, depth, and MERV rating.',
                'warning'
            );
            return false;
        }

        return true;
    }

    validateInquiryFields() {
        if (!this.validateFilterFields()) {
            return false;
        }

        if (!this.quantity || Number(this.quantity) <= 0) {
            this.showToast('Invalid quantity', 'Quantity must be greater than zero.', 'warning');
            return false;
        }

        if (!this.firstName || !this.lastName || (!this.email && !this.phone)) {
    this.showToast(
        'Missing customer details',
        'Please enter first name, last name, and either email or phone.',
        'warning'
    );
    return false;
}

        return true;
    }

    getErrorMessage(error) {
        if (error && error.body && error.body.message) {
            return error.body.message;
        }

        if (error && error.message) {
            return error.message;
        }

        return 'Unexpected error occurred.';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

    async handleConvertInquiry() {
        if (!this.createdInquiry || !this.createdInquiry.inquiryId) {
            this.showToast(
                'No inquiry selected',
                'Create an inquiry before converting it.',
                'warning'
            );
            return;
        }

        this.isLoading = true;
        this.conversionResult = null;

        try {
            this.conversionResult = await convertInquiry({
                inquiryId: this.createdInquiry.inquiryId
            });

            this.showToast(
                'Opportunity created',
                this.conversionResult.message,
                'success'
            );
        } catch (error) {
            this.showToast(
                'Error converting inquiry',
                this.getErrorMessage(error),
                'error'
            );
        } finally {
            this.isLoading = false;
        }
    }
}