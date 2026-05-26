import { LightningElement, api, wire, track } from 'lwc';
import getDiscountRows from '@salesforce/apex/ApprovalDiscountController.getDiscountRows';

export default class ApprovalDiscountController extends LightningElement {
    @api recordId;

    @track rows = [];
    @track error;
    @track isLoading = true;

    columns = [
        {
            label: 'Type',
            fieldName: 'type',
            type: 'text',
            initialWidth: 150
        },
        {
            label: 'Product & Service',
            fieldName: 'productname',
            type: 'text',
            initialWidth: 200
        },
        {
            label: 'Contract Year',
            fieldName: 'dealyear',
            type: 'text',
            initialWidth: 100
        },
        {
            label: 'List Price',
            fieldName: 'listprice',
            type: 'text',
            initialWidth: 100
        },
        {
            label: 'Sales Price',
            fieldName: 'salesprice',
            type: 'text',
            initialWidth: 100
        },
        {
            label: 'Discount %age',
            fieldName: 'discountperage',
            type: 'text',
            initialWidth: 120
        },
		{
            label: 'Discount value',
            fieldName: 'discountvalue',
            type: 'text',
            initialWidth: 120
        }
		
    ];

    @wire(getDiscountRows, { recordId: '$recordId' })
    wiredRows({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.rows = data;
            this.error = undefined;
        } else if (error) {
            // Basic error handling
            this.error = this.reduceError(error);
            this.rows = [];
        }
    }

    get hasData() {
        return this.rows && this.rows.length > 0;
    }

    // Simplified error normalization
    reduceError(error) {
        let message = 'Unknown error';
        if (Array.isArray(error?.body)) {
            message = error.body.map(e => e.message).join(', ');
        } else if (typeof error?.body?.message === 'string') {
            message = error.body.message;
        }
        return message;
    }
}